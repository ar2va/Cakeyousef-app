import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: AppColors.warm200.withValues(alpha: 0.55),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppColors.isDark ? 0.32 : 0.06,
            ),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(6, 10, 6, bottom + 8),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.forum_outlined,
            activeIcon: Icons.forum_rounded,
            label: 'پیام‌رسان',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: 'آموزش‌ها',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _CenterNavItem(
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            label: 'فروشگاه',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'پروفایل',
            selected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? AppColors.gold50.withValues(alpha: 0.85)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (selected) const _ActiveAura(size: 42, stroke: 2.4),
                    AnimatedScale(
                      scale: selected ? 1.06 : 1,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        selected ? activeIcon : icon,
                        size: selected ? 24 : 22,
                        color: selected ? AppColors.gold600 : AppColors.warm400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: AppFonts.vazirmatn(
                  fontSize: selected ? 11 : 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  color: selected ? AppColors.gold700 : AppColors.warm400,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final bool selected;

  const _CenterNavItem({required this.onTap, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: const Offset(0, -14),
              child: SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (selected) const _ActiveAura(size: 68, stroke: 2.8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      width: selected ? 56 : 52,
                      height: selected ? 56 : 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppColors.goldGlow,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: selected ? 0.95 : 0.55,
                          ),
                          width: selected ? 2.5 : 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: Text(
                'خانه',
                style: AppFonts.vazirmatn(
                  fontSize: selected ? 11.5 : 10.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? AppColors.gold700 : AppColors.gold500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium active-tab aura: comet trail + counter arc + soft pulse.
/// Inspired by Material indeterminate progress & iOS activity rings.
class _ActiveAura extends StatefulWidget {
  final double size;
  final double stroke;

  const _ActiveAura({required this.size, required this.stroke});

  @override
  State<_ActiveAura> createState() => _ActiveAuraState();
}

class _ActiveAuraState extends State<_ActiveAura>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _breathe;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(
      parent: _breathe,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_spin, _pulse]),
      builder: (_, __) {
        final breathe = 0.96 + (_pulse.value * 0.06);
        return Transform.scale(
          scale: breathe,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _ActiveAuraPainter(
              progress: _spin.value,
              stroke: widget.stroke,
              glow: 0.35 + (_pulse.value * 0.35),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveAuraPainter extends CustomPainter {
  final double progress;
  final double stroke;
  final double glow;

  _ActiveAuraPainter({
    required this.progress,
    required this.stroke,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final angle = progress * 2 * math.pi;

    // Soft ambient track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.45
        ..color = AppColors.gold300.withValues(alpha: 0.18)
        ..strokeCap = StrokeCap.round,
    );

    // Outer glow halo (pulses with breathe)
    canvas.drawCircle(
      center,
      radius + stroke * 0.35,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 1.8
        ..color = AppColors.gold400.withValues(alpha: 0.08 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..strokeCap = StrokeCap.round,
    );

    // Primary comet arc — bright head, fading tail
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    final primary = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 1.55,
        colors: [
          AppColors.gold500.withValues(alpha: 0.0),
          AppColors.gold500.withValues(alpha: 0.25),
          AppColors.gold400,
          AppColors.gold300,
          Colors.white.withValues(alpha: 0.95),
        ],
        stops: const [0.0, 0.35, 0.62, 0.82, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 1.45, false, primary);

    // Bright head tip
    const tipAngle = -math.pi / 2 + math.pi * 1.45;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(
      tip,
      stroke * 0.55,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.drawCircle(
      tip,
      stroke * 0.28,
      Paint()..color = Colors.white,
    );
    canvas.restore();

    // Secondary counter-rotating arc (depth, Material-style)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-angle * 0.65 + math.pi * 0.55);
    canvas.translate(-center.dx, -center.dy);

    final secondary = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.65
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 0.9,
        colors: [
          AppColors.gold600.withValues(alpha: 0.0),
          AppColors.gold600.withValues(alpha: 0.45),
          AppColors.gold500.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.72, false, secondary);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ActiveAuraPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.stroke != stroke ||
      oldDelegate.glow != glow;
}
