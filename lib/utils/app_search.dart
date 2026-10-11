import '../data/messenger_data.dart';
import '../models/catalog_models.dart';
import '../models/models.dart';
import '../state/courses_repository.dart';
import '../state/products_repository.dart';

enum SearchGroup {
  courses,
  products,
  support,
  pages,
}

extension SearchGroupX on SearchGroup {
  String get label => switch (this) {
        SearchGroup.courses => 'دوره‌ها',
        SearchGroup.products => 'محصولات فیزیکی',
        SearchGroup.support => 'پشتیبانی',
        SearchGroup.pages => 'بخش‌های اپ',
      };

  String get iconName => switch (this) {
        SearchGroup.courses => 'course',
        SearchGroup.products => 'product',
        SearchGroup.support => 'support',
        SearchGroup.pages => 'page',
      };
}

enum SearchTarget {
  course,
  product,
  chat,
  tabMessenger,
  tabCourses,
  tabShop,
  about,
  calculator,
  colorMixer,
  social,
}

class SearchHit {
  final SearchGroup group;
  final SearchTarget target;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? courseId;
  final String? courseSlug;
  final CourseItem? course;
  final ShopProductDto? product;
  final ChatConversation? chat;
  final int score;

  const SearchHit({
    required this.group,
    required this.target,
    required this.title,
    required this.subtitle,
    required this.score,
    this.imageUrl,
    this.courseId,
    this.courseSlug,
    this.course,
    this.product,
    this.chat,
  });
}

class SearchGrouped {
  final SearchGroup group;
  final List<SearchHit> hits;

  const SearchGrouped({required this.group, required this.hits});
}

/// Global home search across courses, products, support and app sections.
class AppSearch {
  static const minQueryLength = 3;

  static String normalize(String input) {
    var s = input.trim().toLowerCase();
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    const en = '0123456789';
    final buf = StringBuffer();
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      final iFa = fa.indexOf(ch);
      if (iFa >= 0) {
        buf.write(en[iFa]);
        continue;
      }
      final iAr = ar.indexOf(ch);
      if (iAr >= 0) {
        buf.write(en[iAr]);
        continue;
      }
      // Arabic/Persian ye & ke
      if (ch == 'ي' || ch == 'ى') {
        buf.write('ی');
        continue;
      }
      if (ch == 'ك') {
        buf.write('ک');
        continue;
      }
      buf.write(ch);
    }
    return buf.toString().replaceAll(RegExp(r'\s+'), ' ');
  }

  static int _score(String haystack, String needle) {
    final h = normalize(haystack);
    final n = needle;
    if (h.isEmpty || n.isEmpty) return 0;
    if (h == n) return 100;
    if (h.startsWith(n)) return 80;
    if (h.contains(' $n') || h.contains(n)) return 60;
    // token match
    final tokens = n.split(' ').where((t) => t.length >= 2);
    var hits = 0;
    for (final t in tokens) {
      if (h.contains(t)) hits++;
    }
    if (hits > 0) return 40 + hits * 5;
    return 0;
  }

  static int _bestScore(Iterable<String?> fields, String query) {
    var best = 0;
    for (final f in fields) {
      if (f == null || f.trim().isEmpty) continue;
      final s = _score(f, query);
      if (s > best) best = s;
    }
    return best;
  }

  static List<SearchGrouped> search(String rawQuery) {
    final query = normalize(rawQuery);
    if (query.length < minQueryLength) return const [];

    final hits = <SearchHit>[
      ..._searchCourses(query),
      ..._searchProducts(query),
      ..._searchSupport(query),
      ..._searchPages(query),
    ];

    hits.sort((a, b) => b.score.compareTo(a.score));

    final order = [
      SearchGroup.courses,
      SearchGroup.products,
      SearchGroup.support,
      SearchGroup.pages,
    ];
    final grouped = <SearchGrouped>[];
    for (final g in order) {
      final list = hits.where((h) => h.group == g).take(8).toList();
      if (list.isNotEmpty) {
        grouped.add(SearchGrouped(group: g, hits: list));
      }
    }
    return grouped;
  }

  static List<SearchHit> _searchCourses(String query) {
    final repo = CoursesRepository.instance;
    final out = <SearchHit>[];
    for (final c in repo.courseItems) {
      final score = _bestScore([
        c.title,
        c.description,
        c.instructor,
        c.category,
        ...c.tags.map((t) => t.label),
        c.level,
      ], query);
      if (score <= 0) continue;
      out.add(
        SearchHit(
          group: SearchGroup.courses,
          target: SearchTarget.course,
          title: c.title,
          subtitle: c.instructor.isNotEmpty
              ? c.instructor
              : (c.category ?? 'دوره آموزشی'),
          imageUrl: c.imageUrl,
          course: c,
          courseId: c.id,
          courseSlug: c.slug,
          score: score,
        ),
      );
    }
    return out;
  }

  static List<SearchHit> _searchProducts(String query) {
    final repo = ProductsRepository.instance;
    final out = <SearchHit>[];
    for (final p in repo.products) {
      final score = _bestScore([
        p.title,
        p.description,
        p.longDescription,
        p.category,
        p.priceLabel,
      ], query);
      if (score <= 0) continue;
      out.add(
        SearchHit(
          group: SearchGroup.products,
          target: SearchTarget.product,
          title: p.title,
          subtitle: p.category.isNotEmpty
              ? '${p.category} · ${p.priceLabel} تومان'
              : '${p.priceLabel} تومان',
          imageUrl: p.imageUrl.isEmpty ? null : p.imageUrl,
          product: p,
          score: score,
        ),
      );
    }
    return out;
  }

  static List<SearchHit> _searchSupport(String query) {
    final out = <SearchHit>[];

    for (final c in MessengerData.allChats) {
      final score = _bestScore([
        c.title,
        c.subtitle,
        c.lastMessage,
      ], query);
      if (score <= 0) continue;
      out.add(
        SearchHit(
          group: SearchGroup.support,
          target: SearchTarget.chat,
          title: c.title,
          subtitle: c.subtitle.isNotEmpty ? c.subtitle : c.lastMessage,
          chat: c,
          score: score,
        ),
      );
    }

    // Always-available support shortcuts when keywords match.
    final supportKeywords = {
      'پشتیبانی': 90,
      'پشتيباني': 90,
      'support': 85,
      'چت': 70,
      'پیام': 65,
      'پیامرسان': 80,
      'پیام‌رسان': 80,
      'تیکت': 70,
      'مشاوره': 70,
      'سوال': 55,
    };
    var supportScore = 0;
    for (final e in supportKeywords.entries) {
      final s = _score(e.key, query);
      if (s > 0) supportScore = supportScore < e.value ? e.value : supportScore;
      if (query.contains(normalize(e.key)) || normalize(e.key).contains(query)) {
        supportScore = supportScore < e.value ? e.value : supportScore;
      }
    }
    // Also score query against label
    final labelScore = _bestScore(['پشتیبانی', 'پیام‌رسان', 'گفتگو با پشتیبانی'], query);
    if (labelScore > supportScore) supportScore = labelScore;

    if (supportScore > 0) {
      out.add(
        SearchHit(
          group: SearchGroup.support,
          target: SearchTarget.tabMessenger,
          title: 'پشتیبانی و پیام‌رسان',
          subtitle: 'گفتگو و کانال‌های پشتیبانی',
          score: supportScore,
        ),
      );
    }
    return out;
  }

  static List<SearchHit> _searchPages(String query) {
    const pages = <({
      SearchTarget target,
      String title,
      String subtitle,
      List<String> keys,
    })>[
      (
        target: SearchTarget.tabCourses,
        title: 'آموزش‌ها',
        subtitle: 'لیست همه دوره‌ها',
        keys: ['آموزش', 'دوره', 'کلاس', 'courses'],
      ),
      (
        target: SearchTarget.tabShop,
        title: 'فروشگاه',
        subtitle: 'محصولات فیزیکی',
        keys: ['فروشگاه', 'محصول', 'خرید', 'shop'],
      ),
      (
        target: SearchTarget.about,
        title: 'درباره ما',
        subtitle: 'آدرس، تماس و معرفی آکادمی',
        keys: [
          'درباره',
          'آدرس',
          'تماس',
          'اردبیل',
          'ایمیل',
          'cakeyousef',
          'آکادمی',
        ],
      ),
      (
        target: SearchTarget.calculator,
        title: 'محاسبه مواد',
        subtitle: 'ابزار محاسبه مواد کیک',
        keys: ['محاسبه', 'مواد', 'رسپی', 'calculator'],
      ),
      (
        target: SearchTarget.colorMixer,
        title: 'ترکیب رنگ',
        subtitle: 'ابزار ترکیب رنگ خامه',
        keys: ['رنگ', 'ترکیب', 'خامه', 'color'],
      ),
      (
        target: SearchTarget.social,
        title: 'صفحات اجتماعی',
        subtitle: 'اینستاگرام، تلگرام، واتساپ و…',
        keys: [
          'اجتماعی',
          'اینستاگرام',
          'تلگرام',
          'واتساپ',
          'بله',
          'آپارات',
          'یوتیوب',
          'instagram',
          'telegram',
        ],
      ),
    ];

    final out = <SearchHit>[];
    for (final p in pages) {
      var score = _bestScore([p.title, p.subtitle, ...p.keys], query);
      for (final k in p.keys) {
        final s = _score(k, query);
        if (query.contains(normalize(k))) {
          score = score < 75 ? 75 : score;
        }
        if (s > score) score = s;
      }
      if (score <= 0) continue;
      out.add(
        SearchHit(
          group: SearchGroup.pages,
          target: p.target,
          title: p.title,
          subtitle: p.subtitle,
          score: score,
        ),
      );
    }
    return out;
  }
}
