import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_config.dart';
import '../models/catalog_models.dart';
import '../screens/course_detail_screen.dart';
import '../state/courses_repository.dart';
import '../state/sliders_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/app_nav.dart';
import '../utils/network_image.dart';

/// Cinematic home hero from `/api/content/sliders`.
class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider>
    with SingleTickerProviderStateMixin {
  final _repo = SlidersRepository.instance;
  late final PageController _pageController;
  late final AnimationController _progress;

  int _index = 0;
  static const _pageDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _progress = AnimationController(vsync: this, duration: _pageDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _goNext();
      });
    _repo.addListener(_onRepo);
    _repo.load();
    if (_repo.hasData) _startProgress();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    _progress.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onRepo() {
    if (!mounted) return;
    setState(() {});
    if (_repo.hasData) {
      if (_index >= _repo.slides.length) _index = 0;
      _startProgress();
    } else {
      _progress.stop();
      _progress.value = 0;
    }
  }

  void _startProgress() {
    if (!_repo.hasData || _repo.slides.length <= 1) {
      _progress.stop();
      _progress.value = 0;
      return;
    }
    _progress
      ..duration = _pageDuration
      ..forward(from: 0);
  }

  void _goNext() {
    if (!mounted || _repo.slides.length <= 1) return;
    final next = (_index + 1) % _repo.slides.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int i) {
    setState(() => _index = i);
    _startProgress();
  }

  void _onUserDrag() {
    _progress.stop();
  }

  Future<void> _openSlide(HomeSlideDto slide) async {
    final href = slide.ctaHref.trim();
    if (href.isEmpty) return;

    final path = href.startsWith('http')
        ? Uri.tryParse(href)?.path ?? href
        : href;

    if (path.startsWith('/courses/') || path.startsWith('courses/')) {
      final slug = path.replaceFirst(RegExp(r'^/?courses/'), '').split('/').first;
      if (slug.isNotEmpty) {
        final repo = CoursesRepository.instance;
        if (!repo.hasData) await repo.load();
        CourseDto? match;
        for (final c in repo.courses) {
          if (c.slug == slug || c.id == slug) {
            match = c;
            break;
          }
        }
        if (match != null && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(course: match!.toCourseItem()),
            ),
          );
          return;
        }
        if (mounted) MainTabScope.go(context, 1);
        return;
      }
    }

    if (path.contains('/shop') ||
        path.contains('/products') ||
        path.startsWith('/product')) {
      if (mounted) MainTabScope.go(context, 3);
      return;
    }

    final uri = href.startsWith('http')
        ? Uri.tryParse(href)
        : Uri.tryParse('${ApiConfig.host}${href.startsWith('/') ? href : '/$href'}');
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        if (_repo.loading && !_repo.hasData) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: _BannerSkeleton(),
          );
        }
        if (!_repo.hasData) return const SizedBox.shrink();

        final slides = _repo.slides;
        return Column(
          children: [
            SizedBox(
              height: 196,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollStartNotification && n.dragDetails != null) {
                    _onUserDrag();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: _onPageChanged,
                  padEnds: true,
                  itemBuilder: (context, i) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double scale = 1;
                        if (_pageController.position.haveDimensions) {
                          final page = _pageController.page ?? _index.toDouble();
                          final dist = (page - i).abs().clamp(0.0, 1.0);
                          scale = 1 - (dist * 0.05);
                        }
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: _BannerCard(
                        slide: slides[i],
                        active: i == _index,
                        progress: i == _index ? _progress : null,
                        showProgress: slides.length > 1,
                        onTap: () => _openSlide(slides[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (slides.length > 1) ...[
              const SizedBox(height: 12),
              _DotRow(
                count: slides.length,
                index: _index,
                progress: _progress,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final HomeSlideDto slide;
  final bool active;
  final Animation<double>? progress;
  final bool showProgress;
  final VoidCallback onTap;

  const _BannerCard({
    required this.slide,
    required this.active,
    required this.onTap,
    this.progress,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final eyebrow = slide.eyebrow.isNotEmpty ? slide.eyebrow : slide.alt;
    final title = slide.title.isNotEmpty ? slide.title : eyebrow;
    final cta = slide.ctaLabel.isNotEmpty ? slide.ctaLabel : 'مشاهده';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: slide.hasCta ? onTap : null,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold500.withValues(
                    alpha: active ? 0.18 : 0.08,
                  ),
                  blurRadius: active ? 22 : 14,
                  offset: const Offset(0, 8),
                ),
                ...AppColors.cardShadow,
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppColors.creamDark),
                  AppNetworkImage(
                    url: slide.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                      ),
                    ),
                  ),
                  // Cinematic overlays
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                        stops: const [0, 0.38, 1],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppColors.gold500.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  if (showProgress)
                    Positioned(
                      top: 12,
                      left: 14,
                      right: 14,
                      child: _SegmentBar(
                        active: active,
                        progress: progress,
                      ),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eyebrow.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                            child: Text(
                              eyebrow,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.vazirmatn(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (title.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.vazirmatn(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.3,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                        if (slide.hasCta) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: AppColors.goldGlow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cta,
                                    style: AppFonts.vazirmatn(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  final bool active;
  final Animation<double>? progress;

  const _SegmentBar({required this.active, this.progress});

  @override
  Widget build(BuildContext context) {
    final track = Colors.white.withValues(alpha: 0.28);
    final fill = Colors.white.withValues(alpha: 0.95);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: track),
            if (active && progress != null)
              AnimatedBuilder(
                animation: progress!,
                builder: (_, __) => FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: progress!.value.clamp(0.0, 1.0),
                  child: ColoredBox(color: fill),
                ),
              )
            else if (!active)
              const SizedBox.shrink()
            else
              ColoredBox(color: fill),
          ],
        ),
      ),
    );
  }
}

class _DotRow extends StatelessWidget {
  final int count;
  final int index;
  final Animation<double> progress;

  const _DotRow({
    required this.count,
    required this.index,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final active = i == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: active ? AppColors.goldGradient : null,
                color: active ? null : AppColors.warm300.withValues(alpha: 0.7),
              ),
            );
          }),
        );
      },
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 196,
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.warm200.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.gold500,
          ),
        ),
      ),
    );
  }
}
