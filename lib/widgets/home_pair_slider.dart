import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One-row home slider: each page shows two cards side-by-side.
/// Supports manual swipe and optional auto-advance.
class HomePairSlider extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final Duration autoInterval;
  final bool autoPlay;
  final EdgeInsetsGeometry padding;

  const HomePairSlider({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 268,
    this.autoInterval = const Duration(seconds: 4),
    this.autoPlay = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<HomePairSlider> createState() => _HomePairSliderState();
}

class _HomePairSliderState extends State<HomePairSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _page = 0;

  int get _pageCount => (widget.itemCount + 1) ~/ 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _restartAuto();
  }

  @override
  void didUpdateWidget(covariant HomePairSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoInterval != widget.autoInterval) {
      if (_page >= _pageCount && _pageCount > 0) {
        _page = 0;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      }
      _restartAuto();
    }
  }

  void _restartAuto() {
    _timer?.cancel();
    if (!widget.autoPlay || _pageCount <= 1) return;
    _timer = Timer.periodic(widget.autoInterval, (_) => _goNext());
  }

  void _goNext() {
    if (!mounted || !_pageController.hasClients || _pageCount <= 1) return;
    final next = (_page + 1) % _pageCount;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _onUserInteraction() {
    // Pause briefly after manual swipe, then resume.
    _timer?.cancel();
    if (!widget.autoPlay || _pageCount <= 1) return;
    _timer = Timer(widget.autoInterval, _restartAuto);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification && n.dragDetails != null) {
                _onUserInteraction();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pageCount,
              padEnds: false,
              onPageChanged: (i) {
                setState(() => _page = i);
              },
              itemBuilder: (context, pageIndex) {
                final left = pageIndex * 2;
                final right = left + 1;
                return Padding(
                  padding: widget.padding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: widget.itemBuilder(context, left),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: right < widget.itemCount
                            ? widget.itemBuilder(context, right)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (_pageCount > 1) ...[
          const SizedBox(height: 12),
          _Dots(count: _pageCount, index: _page),
        ],
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: active ? AppColors.goldGradient : null,
            color: active ? null : AppColors.warm300.withValues(alpha: 0.7),
          ),
        );
      }),
    );
  }
}
