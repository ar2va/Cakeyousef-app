import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/about_screen.dart';
import '../screens/color_mixer_screen.dart';
import '../screens/material_calculator_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/app_nav.dart';
import 'section_header.dart';

/// App navigation shortcuts (not catalog mock data).
const _quickAccess = <QuickAccessItem>[
  QuickAccessItem(
    title: 'فروشگاه',
    icon: Icons.shopping_bag_rounded,
    iconColor: Color(0xFFB8912E),
    bgColor: Color(0xFFFFF3D6),
    artwork: 'assets/images/quick/shop.png',
  ),
  QuickAccessItem(
    title: 'دوره‌های من',
    icon: Icons.menu_book_rounded,
    iconColor: Color(0xFF8B6914),
    bgColor: Color(0xFFFFF8E8),
    artwork: 'assets/images/quick/courses.png',
  ),
  QuickAccessItem(
    title: 'پشتیبانی',
    icon: Icons.headset_mic_rounded,
    iconColor: Color(0xFFC27803),
    bgColor: Color(0xFFFFF0D6),
    artwork: 'assets/images/quick/support.png',
  ),
  QuickAccessItem(
    title: 'محاسبه مواد',
    icon: Icons.calculate_rounded,
    iconColor: Color(0xFFB45309),
    bgColor: Color(0xFFFFEDD5),
    artwork: 'assets/images/quick/calculator.png',
  ),
  QuickAccessItem(
    title: 'ترکیب رنگ',
    icon: Icons.palette_rounded,
    iconColor: Color(0xFFBE185D),
    bgColor: Color(0xFFFCE7F3),
    artwork: 'assets/images/quick/color.png',
  ),
  QuickAccessItem(
    title: 'درباره ما',
    icon: Icons.storefront_rounded,
    iconColor: Color(0xFFD4A843),
    bgColor: Color(0xFFFFF9E6),
    artwork: 'assets/images/quick/about.png',
  ),
];

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  void _open(BuildContext context, QuickAccessItem item) {
    if (item.title == 'فروشگاه') {
      MainTabScope.go(context, 3);
      return;
    }
    if (item.title == 'دوره‌های من') {
      MainTabScope.go(context, 1);
      return;
    }
    if (item.title == 'پشتیبانی') {
      MainTabScope.go(context, 0);
      return;
    }

    if (item.title == 'ترکیب رنگ') {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ColorMixerScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      return;
    }

    if (item.title == 'محاسبه مواد') {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MaterialCalculatorScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      return;
    }

    if (item.title == 'درباره ما') {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AboutScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'دسترسی سریع'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var row = 0; row < 2; row++) ...[
                if (row > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    for (var col = 0; col < 3; col++) ...[
                      if (col > 0) const SizedBox(width: 10),
                      Expanded(
                        child: _AccessCard(
                          item: _quickAccess[row * 3 + col],
                          onTap: () =>
                              _open(context, _quickAccess[row * 3 + col]),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccessCard extends StatefulWidget {
  const _AccessCard({
    required this.item,
    required this.onTap,
  });

  final QuickAccessItem item;
  final VoidCallback onTap;

  @override
  State<_AccessCard> createState() => _AccessCardState();
}

class _AccessCardState extends State<_AccessCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final dark = AppColors.isDark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 118,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: AppColors.card,
            border: Border.all(
              color: AppColors.warm200.withValues(alpha: 0.55),
            ),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -16,
                child: IgnorePointer(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          item.iconColor.withValues(alpha: dark ? 0.18 : 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                child: Column(
                  children: [
                    Expanded(
                      child: item.artwork != null
                          ? Image.asset(
                              item.artwork!,
                              fit: BoxFit.contain,
                              cacheWidth: 160,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (_, __, ___) => Icon(
                                item.icon,
                                color: item.iconColor,
                                size: 34,
                              ),
                            )
                          : Icon(
                              item.icon,
                              color: item.iconColor,
                              size: 34,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.vazirmatn(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
