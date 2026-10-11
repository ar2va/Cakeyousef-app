import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/app_page_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _phoneMobile = '09105947673';
  static const _phoneLandline = '02191302531';
  static const _email = 'cakeyousef11@gmail.com';
  static const _address =
      'اردبیل، میدان ایثار، شهرک صنعتی شماره یک، خیابان صنعتگران ۲، پلاک ۱';

  /// Approx. for Ardabil Industrial Town #1 (میدان ایثار).
  static const _lat = 38.2253706;
  static const _lng = 48.3260193;

  Future<void> _launch(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMaps(List<Uri> candidates) async {
    for (final uri in candidates) {
      try {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (ok) return;
      } catch (_) {
        // try next candidate
      }
    }
  }

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label کپی شد',
          style: AppFonts.vazirmatn(fontWeight: FontWeight.w700),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: AppPageBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.card.withValues(alpha: 0.92),
              foregroundColor: AppColors.dark900,
              title: Text(
                'درباره ما',
                style: AppFonts.vazirmatn(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.dark900,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  children: [
                    _HeroCard(),
                    const SizedBox(height: 16),
                    _StoryCard(),
                    const SizedBox(height: 16),
                    _ContactBlock(
                      title: 'تماس بگیرید',
                      icon: Icons.phone_in_talk_rounded,
                      children: [
                        _InfoTile(
                          icon: Icons.smartphone_rounded,
                          title: 'موبایل',
                          value: '۰۹۱۰۵۹۴۷۶۷۳',
                          actionLabel: 'تماس',
                          onTap: () => _launch(Uri.parse('tel:$_phoneMobile')),
                          onLongPress: () =>
                              _copy(context, _phoneMobile, 'شماره موبایل'),
                        ),
                        _InfoTile(
                          icon: Icons.call_rounded,
                          title: 'تلفن ثابت',
                          value: '۰۲۱۹۱۳۰۲۵۳۱',
                          actionLabel: 'تماس',
                          onTap: () =>
                              _launch(Uri.parse('tel:$_phoneLandline')),
                          onLongPress: () =>
                              _copy(context, _phoneLandline, 'شماره ثابت'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ContactBlock(
                      title: 'آدرس ما',
                      icon: Icons.location_on_rounded,
                      children: [
                        _InfoTile(
                          icon: Icons.map_rounded,
                          title: 'آدرس مجموعه',
                          value: _address,
                          actionLabel: 'کپی',
                          multiline: true,
                          onTap: () => _copy(context, _address, 'آدرس'),
                          onLongPress: () =>
                              _copy(context, _address, 'آدرس'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _NavigationSection(
                      onOpen: _openMaps,
                      lat: _lat,
                      lng: _lng,
                      address: _address,
                    ),
                    const SizedBox(height: 12),
                    _ContactBlock(
                      title: 'ایمیل ما',
                      icon: Icons.mail_rounded,
                      children: [
                        _InfoTile(
                          icon: Icons.alternate_email_rounded,
                          title: 'پست الکترونیکی',
                          value: _email,
                          actionLabel: 'ارسال',
                          ltr: true,
                          onTap: () =>
                              _launch(Uri.parse('mailto:$_email')),
                          onLongPress: () =>
                              _copy(context, _email, 'ایمیل'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationSection extends StatelessWidget {
  final Future<void> Function(List<Uri> candidates) onOpen;
  final double lat;
  final double lng;
  final String address;

  const _NavigationSection({
    required this.onOpen,
    required this.lat,
    required this.lng,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final q = Uri.encodeComponent(address);
    final apps = <_MapApp>[
      _MapApp(
        title: 'گوگل مپ',
        subtitle: 'Google Maps',
        icon: Icons.map_rounded,
        colors: const [Color(0xFF34A853), Color(0xFF4285F4)],
        urls: [
          Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
          ),
          Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$q',
          ),
          Uri.parse('geo:$lat,$lng?q=$lat,$lng($q)'),
        ],
      ),
      _MapApp(
        title: 'نشان',
        subtitle: 'Neshan',
        icon: Icons.navigation_rounded,
        colors: const [Color(0xFFFF6B35), Color(0xFFE85D04)],
        urls: [
          Uri.parse('https://nshn.ir/?lat=$lat&lng=$lng'),
          Uri.parse('neshan://?ll=$lat,$lng'),
          Uri.parse('https://maps.neshan.org/@$lat,$lng,16.0z'),
        ],
      ),
      _MapApp(
        title: 'بلد',
        subtitle: 'Balad',
        icon: Icons.explore_rounded,
        colors: const [Color(0xFF00BFA5), Color(0xFF00897B)],
        urls: [
          Uri.parse(
            'https://balad.ir/location?latitude=$lat&longitude=$lng',
          ),
          Uri.parse('https://balad.ir/#16/$lat/$lng'),
          Uri.parse('https://balad.ir/search?q=$q'),
        ],
      ),
      _MapApp(
        title: 'Map.ir',
        subtitle: 'نقشه ایرانی',
        icon: Icons.public_rounded,
        colors: const [Color(0xFF5B6CFF), Color(0xFF3949AB)],
        urls: [
          Uri.parse('https://map.ir/@$lat,$lng,16z'),
          Uri.parse('https://map.ir/search?text=$q'),
        ],
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.warm200.withValues(alpha: 0.55),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مسیریابی',
                      style: AppFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark900,
                      ),
                    ),
                    Text(
                      'با نقشه دلخواهتان به مجموعه برسید',
                      style: AppFonts.vazirmatn(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warm400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: apps.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final app = apps[index];
              return _MapAppCard(
                app: app,
                onTap: () => onOpen(app.urls),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MapApp {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final List<Uri> urls;

  const _MapApp({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.urls,
  });
}

class _MapAppCard extends StatefulWidget {
  final _MapApp app;
  final VoidCallback onTap;

  const _MapAppCard({required this.app, required this.onTap});

  @override
  State<_MapAppCard> createState() => _MapAppCardState();
}

class _MapAppCardState extends State<_MapAppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
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
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                app.colors.first.withValues(alpha: 0.14),
                app.colors.last.withValues(alpha: 0.08),
                AppColors.card,
              ],
            ),
            border: Border.all(
              color: app.colors.first.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: app.colors.last.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: app.colors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: app.colors.last.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(app.icon, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.north_east_rounded,
                    size: 16,
                    color: app.colors.last,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                app.title,
                style: AppFonts.vazirmatn(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark900,
                ),
              ),
              Text(
                app.subtitle,
                style: AppFonts.vazirmatn(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warm400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.isDark
              ? [
                  const Color(0xFF2A2418),
                  const Color(0xFF1E1E2C),
                ]
              : [
                  const Color(0xFFFFF3D6),
                  const Color(0xFFFFF8F0),
                  Colors.white,
                ],
        ),
        border: Border.all(
          color: AppColors.gold300.withValues(
            alpha: AppColors.isDark ? 0.22 : 0.45,
          ),
        ),
        boxShadow: AppColors.cardShadowLg,
      ),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.gold300.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold500.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.cake_rounded,
                size: 48,
                color: AppColors.gold600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'آکادمی کیک یوسف',
            textAlign: TextAlign.center,
            style: AppFonts.vazirmatn(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.dark900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold50,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.gold300.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'از ۱۳۹۸ تا امروز · آموزش تخصصی قنادی',
              style: AppFonts.vazirmatn(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.gold700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.warm200.withValues(alpha: 0.55),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'داستان ما',
                style: AppFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'آکادمی کیک یوسف از سال ۱۳۹۸ با هدف آموزش اصولی و کاربردی هنر قنادی فعالیت می‌کند. ما با ارائه دوره‌های آموزشی در زمینه کیک‌سازی، شیرینی‌های تر و خشک، باقلوا و تزئین کیک، به شما کمک می‌کنیم تا از یادگیری در خانه شروع کنید و قدم‌به‌قدم مهارت‌های خود را ارتقا دهید.',
            style: AppFonts.vazirmatn(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.dark800,
              height: 1.9,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold50.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gold300.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              'آموزش‌های مرحله‌به‌مرحله، رسپی‌های دقیق و پشتیبانی آموزشی، همراه شما هستند تا با اطمینان بیشتر تمرین کنید، حرفه‌ای شوید و مسیر کسب درآمد از هنر قنادی را بسازید.',
              style: AppFonts.vazirmatn(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.dark800,
                height: 1.85,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ContactBlock({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.warm200.withValues(alpha: 0.55),
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppFonts.vazirmatn(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String actionLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool multiline;
  final bool ltr;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.actionLabel,
    required this.onTap,
    this.onLongPress,
    this.multiline = false,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.creamDark.withValues(alpha: AppColors.isDark ? 0.55 : 0.65),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              crossAxisAlignment: multiline
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.gold300.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.gold700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.vazirmatn(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warm400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
                        style: AppFonts.vazirmatn(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark900,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    actionLabel,
                    style: AppFonts.vazirmatn(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
