import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_colors.dart';

/// Branded course video player (Chewie + video_player).
class CourseVideoPlayer extends StatefulWidget {
  final String url;
  final String? title;
  final String? posterUrl;
  final bool autoPlay;
  final VoidCallback? onEnded;

  const CourseVideoPlayer({
    super.key,
    required this.url,
    this.title,
    this.posterUrl,
    this.autoPlay = true,
    this.onEnded,
  });

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer>
    with WidgetsBindingObserver {
  static const _rotatable = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
  static const _landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  /// Players overlap briefly when switching lessons (new initState runs
  /// before the old dispose), so rotation is unlocked by reference count.
  static int _activePlayers = 0;

  VideoPlayerController? _video;
  ChewieController? _chewie;
  String? _error;
  bool _loading = true;

  bool _wasFullScreen = false;
  bool _fullScreenFromRotation = false;
  bool _suppressAutoUntilPortrait = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activePlayers++;
    SystemChrome.setPreferredOrientations(_rotatable);
    _init(widget.url);
  }

  @override
  void didUpdateWidget(covariant CourseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _init(widget.url);
    }
  }

  Future<void> _init(String url) async {
    await _disposePlayers();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      setState(() {
        _loading = false;
        _error = 'آدرس ویدیو نامعتبر است';
      });
      return;
    }

    final video = VideoPlayerController.networkUrl(uri);
    try {
      await video.initialize();
      if (!mounted) {
        await video.dispose();
        return;
      }
      final chewie = ChewieController(
        videoPlayerController: video,
        autoPlay: widget.autoPlay,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: _kSpeeds,
        optionsTranslation: OptionsTranslation(
          playbackSpeedButtonText: 'سرعت پخش',
          subtitlesButtonText: 'زیرنویس',
          cancelButtonText: 'انصراف',
        ),
        customControls: const _ControlsWithSpeed(),
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.gold500,
          handleColor: AppColors.gold600,
          bufferedColor: AppColors.gold300.withValues(alpha: 0.45),
          backgroundColor: Colors.white24,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: AppColors.gold500,
          handleColor: AppColors.gold600,
          bufferedColor: AppColors.gold300.withValues(alpha: 0.45),
          backgroundColor: Colors.white24,
        ),
        placeholder: Container(color: AppColors.dark900),
        autoInitialize: true,
        deviceOrientationsOnEnterFullScreen: _landscape,
        deviceOrientationsAfterFullScreen: _rotatable,
        errorBuilder: (_, message) => _ErrorPane(message: message),
      );
      video.addListener(_onVideoTick);
      chewie.addListener(_onFullScreenChanged);
      _wasFullScreen = false;
      setState(() {
        _video = video;
        _chewie = chewie;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncOrientation());
    } catch (e) {
      await video.dispose();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'پخش ویدیو ممکن نیست';
      });
    }
  }

  void _onVideoTick() {
    final v = _video;
    if (v == null || !v.value.isInitialized) return;
    final pos = v.value.position;
    final dur = v.value.duration;
    if (dur.inMilliseconds > 0 &&
        pos >= dur - const Duration(milliseconds: 400)) {
      widget.onEnded?.call();
    }
  }

  void _onFullScreenChanged() {
    final c = _chewie;
    if (c == null || c.isFullScreen == _wasFullScreen) return;
    _wasFullScreen = c.isFullScreen;

    if (c.isFullScreen) {
      if (_fullScreenFromRotation) {
        // Chewie locks landscape on enter; keep the sensor free so turning
        // the phone back upright exits fullscreen.
        scheduleMicrotask(
          () => SystemChrome.setPreferredOrientations(_rotatable),
        );
      }
    } else {
      _fullScreenFromRotation = false;
      if (_isLandscape) _suppressAutoUntilPortrait = true;
    }
  }

  bool get _isLandscape {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return false;
    final size = views.first.physicalSize;
    return size.width > size.height;
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOrientation());
  }

  void _syncOrientation() {
    final c = _chewie;
    if (!mounted || c == null) return;

    if (!_isLandscape) {
      _suppressAutoUntilPortrait = false;
      if (c.isFullScreen && _fullScreenFromRotation) c.exitFullScreen();
      return;
    }
    if (!c.isFullScreen && !_suppressAutoUntilPortrait) {
      _fullScreenFromRotation = true;
      c.enterFullScreen();
    }
  }

  Future<void> _disposePlayers() async {
    _video?.removeListener(_onVideoTick);
    _chewie?.removeListener(_onFullScreenChanged);
    _chewie?.dispose();
    await _video?.dispose();
    _chewie = null;
    _video = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activePlayers--;
    if (_activePlayers <= 0) {
      _activePlayers = 0;
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]);
    }
    _disposePlayers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: AppColors.dark900,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.gold500),
                )
              else if (_error != null)
                _ErrorPane(message: _error!)
              else if (_chewie != null)
                Chewie(controller: _chewie!)
              else
                const SizedBox.shrink(),
              if (widget.title != null && widget.title!.trim().isNotEmpty)
                Positioned(
                  left: 10,
                  right: 10,
                  top: 10,
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.vazirmatn(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kSpeeds = <double>[0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

String _speedLabel(double speed) {
  final text = speed == speed.roundToDouble()
      ? speed.toStringAsFixed(0)
      : speed.toString();
  return '$text×';
}

/// Material controls plus an always-reachable speed button; shown inline
/// and in fullscreen because Chewie reuses `customControls` for both.
class _ControlsWithSpeed extends StatefulWidget {
  const _ControlsWithSpeed();

  @override
  State<_ControlsWithSpeed> createState() => _ControlsWithSpeedState();
}

class _ControlsWithSpeedState extends State<_ControlsWithSpeed> {
  bool _visible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _showTemporarily();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showTemporarily() {
    _hideTimer?.cancel();
    if (!_visible) setState(() => _visible = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  Future<void> _pickSpeed(VideoPlayerController video) async {
    _hideTimer?.cancel();
    final current = video.value.playbackSpeed;
    final chosen = await showModalBottomSheet<double>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SpeedSheet(current: current),
    );
    if (chosen != null) await video.setPlaybackSpeed(chosen);
    if (mounted) _showTemporarily();
  }

  @override
  Widget build(BuildContext context) {
    final chewie = ChewieController.of(context);
    final video = chewie.videoPlayerController;
    final full = chewie.isFullScreen;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _showTemporarily(),
      child: Stack(
        children: [
          const MaterialControls(),
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              top: full,
              left: full,
              right: false,
              bottom: false,
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: IgnorePointer(
                  ignoring: !_visible,
                  child: ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: video,
                    builder: (context, value, _) {
                      final speed = value.playbackSpeed;
                      final changed = speed != 1;
                      return Material(
                        color: changed
                            ? AppColors.gold500
                            : Colors.black.withValues(alpha: 0.5),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () => _pickSpeed(video),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.speed_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _speedLabel(speed),
                                  textDirection: TextDirection.ltr,
                                  style: GoogleFonts.vazirmatn(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedSheet extends StatelessWidget {
  final double current;

  const _SpeedSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warm300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.speed_rounded, color: AppColors.gold600),
                const SizedBox(width: 8),
                Text(
                  'سرعت پخش',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final speed in _kSpeeds)
                  _SpeedOption(
                    speed: speed,
                    selected: speed == current,
                    onTap: () => Navigator.of(context).pop(speed),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedOption extends StatelessWidget {
  final double speed;
  final bool selected;
  final VoidCallback onTap;

  const _SpeedOption({
    required this.speed,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldGradient : null,
          color: selected ? null : AppColors.creamDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected ? AppColors.goldGlow : null,
        ),
        child: Column(
          children: [
            Text(
              _speedLabel(speed),
              textDirection: TextDirection.ltr,
              style: GoogleFonts.vazirmatn(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.dark900,
              ),
            ),
            Text(
              speed == 1 ? 'عادی' : (speed < 1 ? 'آهسته' : 'سریع'),
              style: GoogleFonts.vazirmatn(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.warm400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  final String message;
  const _ErrorPane({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded,
                color: Colors.white54, size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Poster placeholder before a lesson is selected / when locked.
class CourseVideoPoster extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onPlay;
  final bool locked;

  const CourseVideoPoster({
    super.key,
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.onPlay,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: courseGradient,
                ),
              ),
            ),
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: locked ? null : AppColors.goldGradient,
                    color: locked ? Colors.black54 : null,
                    boxShadow: locked ? null : AppColors.goldGlow,
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: locked ? 28 : 40,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const courseGradient = [Color(0xFFF59E0B), Color(0xFFB45309)];
