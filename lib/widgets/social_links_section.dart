import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'section_header.dart';

class _SocialLink {
  final String title;
  final String handle;
  final String url;
  final IconData icon;
  final List<Color> gradient;

  const _SocialLink({
    required this.title,
    required this.handle,
    required this.url,
    required this.icon,
    required this.gradient,
  });
}

const _links = <_SocialLink>[
  _SocialLink(
    title: 'اینستاگرام',
    handle: '@cakeyousef',
    url: 'https://www.instagram.com/cakeyousef/',
    icon: Icons.camera_alt_rounded,
    gradient: [Color(0xFFFEDA77), Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
  ),
  _SocialLink(
    title: 'یوتیوب',
    handle: 'cakeyousef_com',
    url: 'https://www.youtube.com/channel/UC1LSWREGmRiiDeQv_BbbI9Q',
    icon: Icons.play_arrow_rounded,
    gradient: [Color(0xFFFF4E45), Color(0xFFCC0000)],
  ),
  _SocialLink(
    title: 'آپارات',
    handle: 'Cakeyousef',
    url: 'https://www.aparat.com/Cakeyousef',
    icon: Icons.videocam_rounded,
    gradient: [Color(0xFFED145B), Color(0xFFC40D4A)],
  ),
  _SocialLink(
    title: 'تلگرام',
    handle: '@cakeyousef_com',
    url: 'https://t.me/cakeyousef_com',
    icon: Icons.send_rounded,
    gradient: [Color(0xFF37AEE2), Color(0xFF1E96C8)],
  ),
  _SocialLink(
    title: 'بله',
    handle: 'پشتیبانی بله',
    url: 'https://web.bale.ai/chat?uid=4464649913',
    icon: Icons.chat_bubble_rounded,
    gradient: [Color(0xFF00C2A8), Color(0xFF009B86)],
  ),
  _SocialLink(
    title: 'واتساپ',
    handle: '۰۹۱۰۵۹۴۷۶۷۳',
    url: 'https://wa.me/989105947673',
    icon: Icons.phone_rounded,
    gradient: [Color(0xFF25D366), Color(0xFF128C7E)],
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
      children: [
        const SectionHeader(title: 'صفحات اجتماعی ما'),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'ما را دنبال کنید و با ما در ارتباط باشید',
              style: AppFonts.vazirmatn(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warm400,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: AppColors.isDark
                    ? [
                        const Color(0xFF1E1E2C),
                        const Color(0xFF2A2418),
                      ]
                    : [
                        const Color(0xFFFFFCF8),
                        const Color(0xFFFFF3D6),
                        Colors.white,
                      ],
              ),
              border: Border.all(
                color: AppColors.gold300.withValues(
                  alpha: AppColors.isDark ? 0.22 : 0.42,
                ),
              ),
              boxShadow: AppColors.cardShadowLg,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _links.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = _links[index];
                      return _SocialChip(
                        item: item,
                        onTap: () => _open(item.url),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < _links.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _SocialTile(
                    item: _links[i],
                    onTap: () => _open(_links[i].url),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialChip extends StatefulWidget {
  final _SocialLink item;
  final VoidCallback onTap;

  const _SocialChip({required this.item, required this.onTap});

  @override
  State<_SocialChip> createState() => _SocialChipState();
}

class _SocialChipState extends State<_SocialChip> {
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
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.gradient.last.withValues(alpha: 0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(2.2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFonts.vazirmatn(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  final _SocialLink item;
  final VoidCallback onTap;

  const _SocialTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card.withValues(alpha: AppColors.isDark ? 0.7 : 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradient,
                  ),
                ),
                child: Icon(item.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppFonts.vazirmatn(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.handle,
                      textDirection: item.title == 'واتساپ'
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      style: AppFonts.vazirmatn(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warm400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.gold50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold300.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.north_east_rounded,
                  size: 16,
                  color: AppColors.gold700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
