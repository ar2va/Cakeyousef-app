import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/account_models.dart';
import '../models/models.dart';
import '../state/auth_session.dart';
import '../state/courses_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/network_image.dart';
import '../widgets/app_page_background.dart';
import '../widgets/auth_sheet.dart';
import 'course_detail_screen.dart';

/// Purchased / enrolled courses only (from account dashboard).
class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final _session = AuthSession.instance;
  final _courses = CoursesRepository.instance;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onChanged);
    _courses.addListener(_onChanged);
    _courses.load();
    if (_session.isLoggedIn) {
      _session.refreshAccount();
    }
  }

  @override
  void dispose() {
    _session.removeListener(_onChanged);
    _courses.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openCourse(DashboardCourse enrolled) async {
    CourseItem course;
    final match = _courses.courses.where(
      (c) =>
          c.slug == enrolled.slug ||
          c.id == enrolled.id ||
          c.slug == enrolled.id ||
          c.id == enrolled.slug,
    );
    if (match.isNotEmpty) {
      course = match.first.toCourseItem().copyAsPurchased();
    } else {
      course = CourseItem(
        emoji: '🎂',
        title: enrolled.title,
        instructor: 'آکادمی کیک یوسف',
        price: 'خریداری‌شده',
        rating: '—',
        reviews: '',
        tags: const [],
        gradientColors: const [AppColors.gold300, AppColors.gold600],
        imageUrl: enrolled.imageUrl.isEmpty ? null : enrolled.imageUrl,
        id: enrolled.id,
        slug: enrolled.slug,
        hasPurchased: true,
        isFree: false,
      );
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = _session.isLoggedIn;
    final loading =
        loggedIn && _session.accountLoading && _session.enrolledCourses.isEmpty;
    final courses = _session.enrolledCourses;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: AppPageBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.dark800,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'دوره‌های من',
                            style: AppFonts.vazirmatn(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.dark900,
                            ),
                          ),
                          Text(
                            'فقط دوره‌های خریداری‌شده',
                            style: AppFonts.vazirmatn(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warm400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (loggedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_toFa(courses.length)} دوره',
                          style: AppFonts.vazirmatn(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: !loggedIn
                    ? _LoginPrompt(
                        onLogin: () => showAuthSheet(context),
                      )
                    : loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.gold600,
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.gold600,
                            onRefresh: () => _session.refreshAccount(),
                            child: courses.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    children: const [
                                      SizedBox(height: 80),
                                      _EmptyPurchased(),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics(),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      28,
                                    ),
                                    itemCount: courses.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final c = courses[index];
                                      return _PurchasedCourseTile(
                                        course: c,
                                        onTap: () => _openCourse(c),
                                      );
                                    },
                                  ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toFa(int n) {
    const en = '0123456789';
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    return '$n'.split('').map((ch) {
      final i = en.indexOf(ch);
      return i < 0 ? ch : fa[i];
    }).join();
  }
}

class _PurchasedCourseTile extends StatelessWidget {
  final DashboardCourse course;
  final VoidCallback onTap;

  const _PurchasedCourseTile({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: course.imageUrl.isNotEmpty
                      ? AppNetworkImage(
                          url: course.imageUrl,
                          width: 84,
                          height: 84,
                        )
                      : ColoredBox(
                          color: AppColors.gold50,
                          child: Icon(
                            Icons.school_rounded,
                            color: AppColors.gold600,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'خریداری‌شده',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: AppColors.dark900,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مشاهده و ادامه یادگیری',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: AppColors.warm400),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final VoidCallback onLogin;

  const _LoginPrompt({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.gold50,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.gold600,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'برای دیدن دوره‌های خریداری‌شده وارد شوید',
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.dark900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'پس از ورود، فقط دوره‌هایی که خریده‌اید اینجا نمایش داده می‌شود.',
              textAlign: TextAlign.center,
              style: AppFonts.vazirmatn(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.warm400,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold500,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'ورود به حساب',
                style: AppFonts.vazirmatn(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPurchased extends StatelessWidget {
  const _EmptyPurchased();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.gold50,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: AppColors.gold600,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'هنوز دوره‌ای خریداری نکرده‌اید',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.dark900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'از بخش آموزش‌ها دوره مورد نظرتان را انتخاب و خرید کنید.',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.warm400,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

extension on CourseItem {
  CourseItem copyAsPurchased() {
    return CourseItem(
      emoji: emoji,
      title: title,
      instructor: instructor,
      price: price,
      oldPrice: oldPrice,
      rating: rating,
      reviews: reviews,
      tags: tags,
      discount: discount,
      badge: badge,
      badgeColor: badgeColor,
      gradientColors: gradientColors,
      isFree: isFree,
      imageUrl: imageUrl,
      description: description,
      lessons: lessons,
      id: id,
      slug: slug,
      studentsLabel: studentsLabel,
      chapterTitles: chapterTitles,
      videoLessons: videoLessons,
      siteUrl: siteUrl,
      learnPoints: learnPoints,
      requirements: requirements,
      featureLabels: featureLabels,
      level: level,
      durationLabel: durationLabel,
      hasPurchased: true,
      instructorAvatar: instructorAvatar,
      instructorBio: instructorBio,
      courseType: courseType,
      onlineSupport: onlineSupport,
      finalExam: finalExam,
      category: category,
    );
  }
}
