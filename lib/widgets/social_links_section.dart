import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'section_header.dart';

class _SocialLink {
  final String title;
  final String handle;
  final String url;
  /// Local brand asset: `.png` or `.svg` (official marks, not custom icons).
  final String asset;
  final Color brandColor;

  const _SocialLink({
    required this.title,
    required this.handle,
    required this.url,
    required this.asset,
    required this.brandColor,
  });
}

const _links = <_SocialLink>[
  _SocialLink(
    title: 'اینستاگرام',
    handle: '@cakeyousef',
    url: 'https://www.instagram.com/cakeyousef/',
    asset: 'assets/images/social/instagram.png',
    brandColor: Color(0xFFE4405F),
  ),
  _SocialLink(
    title: 'یوتیوب',
    handle: 'cakeyousef_com',
    url: 'https://www.youtube.com/channel/UC1LSWREGmRiiDeQv_BbbI9Q',
    asset: 'assets/images/social/youtube.svg',
    brandColor: Color(0xFFFF0000),
  ),
  _SocialLink(
    title: 'آپارات',
    handle: 'Cakeyousef',
    url: 'https://www.aparat.com/Cakeyousef',
    asset: 'assets/images/social/aparat.svg',
    brandColor: Color(0xFFED145B),
  ),
  _SocialLink(
    title: 'تلگرام',
    handle: '@cakeyousef_com',
    url: 'https://t.me/cakeyousef_com',
    asset: 'assets/images/social/telegram.png',
    brandColor: Color(0xFF26A5E4),
  ),
  _SocialLink(
    title: 'بله',
    handle: 'پشتیبانی بله',
    url: 'https://web.bale.ai/chat?uid=4464649913',
    asset: 'assets/images/social/bale.png',
    brandColor: Color(0xFF00C2A8),
  ),
  _SocialLink(
    title: 'واتساپ',
    handle: '۰۹۱۰۵۹۴۷۶۷۳',
    url: 'https://wa.me/989105947673',
    asset: 'assets/images/social/whatsapp.png',
    brandColor: Color(0xFF25D366),
  ),
];

class SocialLinksSection extends StatelessWidget {
  const SocialLinksSection({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'صفحات اجتماعی ما'),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'ما را دنبال کنید و با ما در ارتباط باشید',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warm400,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _links.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final item = _links[index];
              return _SocialCard(
                item: item,
                onTap: () => _open(item.url),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SocialCard extends StatefulWidget {
  final _SocialLink item;
  final VoidCallback onTap;

  const _SocialCard({required this.item, required this.onTap});

  @override
  State<_SocialCard> createState() => _SocialCardState();
}

class _SocialCardState extends State<_SocialCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.warm200.withValues(alpha: 0.55),
            ),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: -18,
                left: -14,
                child: IgnorePointer(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          item.brandColor.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _BrandBadge(item: item),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppFonts.vazirmatn(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      textDirection: item.title == 'واتساپ'
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      style: AppFonts.vazirmatn(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warm400,
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

class _BrandBadge extends StatelessWidget {
  final _SocialLink item;

  const _BrandBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    final isSvg = item.asset.endsWith('.svg');
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: item.brandColor.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: item.brandColor.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(7),
      child: isSvg
          ? SvgPicture.asset(
              item.asset,
              fit: BoxFit.contain,
            )
          : Image.asset(
              item.asset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Icon(
                Icons.link_rounded,
                color: item.brandColor,
                size: 20,
              ),
            ),
    );
  }
}
