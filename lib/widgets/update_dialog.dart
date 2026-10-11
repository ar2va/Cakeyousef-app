import 'package:flutter/material.dart';

import '../services/app_updater.dart';
import '../services/version_checker.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../utils/format_utils.dart';
import 'store_brand_icons.dart';

Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateCheckResult result,
}) async {
  if (!result.needsUpdate || result.remote == null) return;

  final remote = result.remote!;
  final force = result.kind == UpdateKind.force;

  await showDialog<void>(
    context: context,
    barrierDismissible: !force,
    builder: (dialogContext) {
      return PopScope(
        canPop: !force,
        child: _UpdateDialogBody(
          result: result,
          remote: remote,
          force: force,
        ),
      );
    },
  );
}

class _UpdateDialogBody extends StatefulWidget {
  const _UpdateDialogBody({
    required this.result,
    required this.remote,
    required this.force,
  });

  final UpdateCheckResult result;
  final AppVersionInfo remote;
  final bool force;

  @override
  State<_UpdateDialogBody> createState() => _UpdateDialogBodyState();
}

class _UpdateDialogBodyState extends State<_UpdateDialogBody> {
  bool _busy = false;
  double? _progress;
  String? _error;

  Future<void> _autoUpdate() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _progress = 0;
      _error = null;
    });
    try {
      await AppUpdater().downloadAndInstall(
        widget.remote.downloadUrl,
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _progress = p);
        },
      );
      if (!widget.force && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = toFaDigits(widget.result.currentVersion);
    final latest = toFaDigits(widget.remote.latestVersion);

    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.force ? 'بروزرسانی ضروری' : 'نسخه جدید آماده است',
        style: AppFonts.vazirmatn(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.dark900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.remote.message.isNotEmpty
                ? widget.remote.message
                : 'نسخه جدید با بهبودها آماده است.',
            style: AppFonts.vazirmatn(
              fontSize: 14,
              height: 1.6,
              color: AppColors.dark700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'نسخه فعلی: $current  |  جدید: $latest',
            style: AppFonts.vazirmatn(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.warm400,
            ),
          ),
          const SizedBox(height: 16),
          _UpdateOptionTile(
            enabled: false,
            icon: const GooglePlayIcon(size: 30),
            title: 'بروزرسانی از گوگل پلی',
            subtitle: 'به‌زودی فعال می‌شود',
            onTap: null,
          ),
          const SizedBox(height: 8),
          _UpdateOptionTile(
            enabled: false,
            icon: const BazaarIcon(size: 30),
            title: 'بروزرسانی از بازار',
            subtitle: 'به‌زودی فعال می‌شود',
            onTap: null,
          ),
          const SizedBox(height: 8),
          _UpdateOptionTile(
            enabled: !_busy,
            icon: Icon(
              Icons.system_update_alt_rounded,
              size: 28,
              color: AppColors.gold600,
            ),
            title: 'بروزرسانی خودکار',
            subtitle: _busy ? 'در حال دانلود…' : 'دانلود مستقیم و نصب',
            emphasized: true,
            onTap: _busy ? null : _autoUpdate,
          ),
          if (_progress != null) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: _progress,
              color: AppColors.gold500,
              backgroundColor: AppColors.gold50,
            ),
            const SizedBox(height: 6),
            Text(
              'در حال دانلود… ${toFaDigits('${((_progress ?? 0) * 100).round()}')}٪',
              style: AppFonts.vazirmatn(
                fontSize: 11.5,
                color: AppColors.warm400,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: AppFonts.vazirmatn(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!widget.force)
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(
              'بعداً',
              style: AppFonts.vazirmatn(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.warm400,
              ),
            ),
          ),
      ],
    );
  }
}

class _UpdateOptionTile extends StatelessWidget {
  const _UpdateOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.emphasized = false,
    this.onTap,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool emphasized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = emphasized
        ? AppColors.gold50
        : AppColors.warm100.withValues(alpha: enabled ? 1 : 0.55);
    final border = emphasized
        ? AppColors.gold300
        : AppColors.warm200.withValues(alpha: enabled ? 1 : 0.5);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Center(child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.vazirmatn(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: enabled
                        ? AppColors.dark900
                        : AppColors.dark700.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.vazirmatn(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? AppColors.warm400
                        : AppColors.warm400.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          if (enabled)
            Icon(Icons.chevron_left_rounded, color: AppColors.gold600)
          else
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AppColors.warm400.withValues(alpha: 0.55),
            ),
        ],
      ),
    );

    // Keep brand icon colors, but fade the whole row so it reads as disabled.
    final faded = enabled ? content : Opacity(opacity: 0.42, child: content);

    if (!enabled || onTap == null) return faded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: faded,
      ),
    );
  }
}
