import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/course_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/network_image.dart';

/// Compact course card sized by its parent (home shows them two per row).
class CourseCard extends StatelessWidget {
  final CourseItem course;

  const CourseCard({super.key, required this.course});

  void _open(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CourseDetailScreen(course: course),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: AppColors.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.warm200.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          onTap: () => _open(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CourseCover(course: course),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.vazirmatn(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark900,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.instructor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.vazirmatn(
                                fontSize: 10.5,
                                color: AppColors.warm400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.gold400,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            course.rating,
                            style: AppFonts.vazirmatn(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark800,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 10),
                      _PriceBlock(course: course),
                    ],
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

class _PriceBlock extends StatelessWidget {
  final CourseItem course;

  const _PriceBlock({required this.course});

  @override
  Widget build(BuildContext context) {
    if (course.isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'رایگان',
          style: AppFonts.vazirmatn(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF16A34A),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (course.oldPrice != null)
          Text(
            course.oldPrice!,
            maxLines: 1,
            softWrap: false,
            style: AppFonts.vazirmatn(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.warm400,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.warm400,
            ),
          ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: course.price,
                  style: AppFonts.vazirmatn(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold700,
                  ),
                ),
                TextSpan(
                  text: ' تومان',
                  style: AppFonts.vazirmatn(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warm400,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _CourseCover extends StatelessWidget {
  final CourseItem course;

  const _CourseCover({required this.course});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        course.imageUrl != null && course.imageUrl!.trim().isNotEmpty;
    final topLeftLabel = course.badge ??
        (course.tags.isNotEmpty ? course.tags.first.label : null);
    final topLeftBg = course.badge != null
        ? course.badgeColor.withValues(alpha: 0.92)
        : Colors.black.withValues(alpha: 0.42);

    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: course.gradientColors,
              ),
            ),
          ),
          if (hasImage)
            AppNetworkImage(
              url: course.imageUrl!,
              fit: BoxFit.cover,
              placeholderColor: Colors.transparent,
              errorWidget: const SizedBox.shrink(),
            )
          else
            Center(
              child: Text(course.emoji, style: const TextStyle(fontSize: 40)),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x26000000),
                  Color(0x00000000),
                  Color(0x8C000000),
                ],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          if (hasImage)
            Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.3),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          if (course.discount != null)
            PositionedDirectional(
              top: 8,
              start: 8,
              child: _CoverChip(
                label: course.discount!,
                bg: Colors.white.withValues(alpha: 0.94),
                fg: AppColors.gold700,
              ),
            ),
          if (topLeftLabel != null)
            PositionedDirectional(
              top: 8,
              end: 8,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: _CoverChip(
                  label: topLeftLabel,
                  bg: topLeftBg,
                  fg: Colors.white,
                ),
              ),
            ),
          if (course.lessons != null)
            PositionedDirectional(
              bottom: 8,
              start: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_lesson_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    course.lessons!,
                    style: AppFonts.vazirmatn(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ).copyWith(
                      shadows: const [
                        Shadow(color: Color(0x66000000), blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _CoverChip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.vazirmatn(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
