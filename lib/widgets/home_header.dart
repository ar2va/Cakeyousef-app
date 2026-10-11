import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/about_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/color_mixer_screen.dart';
import '../screens/course_detail_screen.dart';
import '../screens/material_calculator_screen.dart';
import '../screens/product_detail_screen.dart';
import '../theme/app_colors.dart';
import '../utils/app_nav.dart';
import '../utils/app_search.dart';
import '../utils/network_image.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  List<SearchGrouped> _groups = const [];
  bool _showPanel = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    _focus.addListener(() {
      if (_focus.hasFocus) {
        final q = AppSearch.normalize(_controller.text);
        if (q.length >= AppSearch.minQueryLength) {
          setState(() {
            _groups = AppSearch.search(_controller.text);
            _showPanel = true;
          });
        }
        return;
      }
      if (_controller.text.trim().isEmpty) {
        setState(() => _showPanel = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _controller.text;
    final groups = AppSearch.search(q);
    setState(() {
      _groups = groups;
      _showPanel = AppSearch.normalize(q).length >= AppSearch.minQueryLength;
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _groups = const [];
      _showPanel = false;
    });
    _focus.unfocus();
  }

  Future<void> _openHit(SearchHit hit) async {
    _focus.unfocus();
    // Hide live results before navigating so the home header collapses.
    setState(() {
      _showPanel = false;
      _groups = const [];
    });

    switch (hit.target) {
      case SearchTarget.course:
        if (hit.course == null) return;
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => CourseDetailScreen(course: hit.course!),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return;
      case SearchTarget.product:
        if (hit.product == null) return;
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ProductDetailScreen(product: hit.product!),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return;
      case SearchTarget.chat:
        if (hit.chat == null) return;
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ChatScreen(conversation: hit.chat!),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return;
      case SearchTarget.tabMessenger:
        MainTabScope.go(context, 0);
        return;
      case SearchTarget.tabCourses:
        MainTabScope.go(context, 1);
        return;
      case SearchTarget.tabShop:
        MainTabScope.go(context, 3);
        return;
      case SearchTarget.about:
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AboutScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return;
      case SearchTarget.calculator:
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MaterialCalculatorScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return;
      case SearchTarget.colorMixer:
        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ColorMixerScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return;
      case SearchTarget.social:
        final scroll = PrimaryScrollController.maybeOf(context);
        if (scroll != null && scroll.hasClients) {
          await scroll.animateTo(
            scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
          );
        }
        return;
    }
  }

  IconData _groupIcon(SearchGroup g) => switch (g) {
        SearchGroup.courses => Icons.school_rounded,
        SearchGroup.products => Icons.shopping_bag_rounded,
        SearchGroup.support => Icons.support_agent_rounded,
        SearchGroup.pages => Icons.apps_rounded,
      };

  IconData _fallbackIcon(SearchHit hit) => switch (hit.target) {
        SearchTarget.course => Icons.menu_book_rounded,
        SearchTarget.product => Icons.inventory_2_rounded,
        SearchTarget.chat || SearchTarget.tabMessenger =>
          Icons.chat_bubble_outline_rounded,
        SearchTarget.tabCourses => Icons.school_rounded,
        SearchTarget.tabShop => Icons.storefront_rounded,
        SearchTarget.about => Icons.info_outline_rounded,
        SearchTarget.calculator => Icons.calculate_rounded,
        SearchTarget.colorMixer => Icons.palette_rounded,
        SearchTarget.social => Icons.share_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final queryLen = AppSearch.normalize(_controller.text).length;
    final showHint = _showPanel && queryLen >= AppSearch.minQueryLength;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              height: 92,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconButton(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.dark700,
                          size: 22,
                        ),
                        Positioned(
                          top: -4,
                          left: -4,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '۳',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 58,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'آکادمی کیک یوسف',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _IconButton(
                    onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                    child: Icon(
                      Icons.menu_rounded,
                      color: AppColors.dark700,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.warm400, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          textAlign: TextAlign.right,
                          textInputAction: TextInputAction.search,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dark800,
                          ),
                          decoration: InputDecoration(
                            hintText: 'جستجو در دوره‌ها، محصولات و پشتیبانی…',
                            hintStyle: GoogleFonts.vazirmatn(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warm400,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: _clear,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.warm400,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: AppColors.warm400,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showHint) ...[
                  Divider(height: 1, color: AppColors.warm200.withValues(alpha: 0.55)),
                  _LiveResultsPanel(
                    groups: _groups,
                    groupIcon: _groupIcon,
                    fallbackIcon: _fallbackIcon,
                    onTap: _openHit,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveResultsPanel extends StatelessWidget {
  final List<SearchGrouped> groups;
  final IconData Function(SearchGroup) groupIcon;
  final IconData Function(SearchHit) fallbackIcon;
  final Future<void> Function(SearchHit) onTap;

  const _LiveResultsPanel({
    required this.groups,
    required this.groupIcon,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Row(
          children: [
            Icon(Icons.search_off_rounded, color: AppColors.warm400, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'نتیجه‌ای پیدا نشد',
                textAlign: TextAlign.right,
                style: GoogleFonts.vazirmatn(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 340),
      child: ListView(
        shrinkWrap: true,
        primary: false,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        children: [
          for (final g in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Row(
                children: [
                  Icon(groupIcon(g.group), size: 16, color: AppColors.gold500),
                  const SizedBox(width: 6),
                  Text(
                    g.group.label,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${g.hits.length}',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warm400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...g.hits.map(
              (hit) => _HitTile(
                hit: hit,
                fallbackIcon: fallbackIcon(hit),
                onTap: () => onTap(hit),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HitTile extends StatelessWidget {
  final SearchHit hit;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _HitTile({
    required this.hit,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = hit.imageUrl != null && hit.imageUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 44,
                  color: AppColors.cream,
                  child: hasImage
                      ? AppNetworkImage(
                          url: hit.imageUrl!,
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                        )
                      : Icon(fallbackIcon, size: 20, color: AppColors.warm400),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hit.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warm400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.warm200,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _IconButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
