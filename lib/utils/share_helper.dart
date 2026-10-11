import 'package:share_plus/share_plus.dart';

import '../config/site_config.dart';

/// Opens the OS share sheet (WhatsApp, Telegram, etc.) with a public link.
Future<ShareResult> shareCourse({
  required String title,
  String? slug,
  String? fallbackUrl,
}) {
  final url = _resolveUrl(
    SiteConfig.courseShareUrl(slug),
    fallbackUrl,
  );
  return SharePlus.instance.share(
    ShareParams(
      title: title,
      subject: title,
      text: url.isEmpty ? title : '$title\n$url',
    ),
  );
}

Future<ShareResult> shareProduct({
  required String title,
  String? id,
  String? fallbackUrl,
}) {
  final url = _resolveUrl(
    SiteConfig.productShareUrl(id),
    fallbackUrl,
  );
  return SharePlus.instance.share(
    ShareParams(
      title: title,
      subject: title,
      text: url.isEmpty ? title : '$title\n$url',
    ),
  );
}

String _resolveUrl(String primary, String? fallback) {
  final p = primary.trim();
  if (_isPublicHttp(p)) return p;
  final fb = fallback?.trim() ?? '';
  if (_isPublicHttp(fb)) return fb;
  return p;
}

bool _isPublicHttp(String value) {
  if (!(value.startsWith('http://') || value.startsWith('https://'))) {
    return false;
  }
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) return false;
  if (uri.host == 'localhost' || uri.host.startsWith('127.')) return false;
  // Never share the removed marketing domain.
  if (uri.host == 'cakeyousef.ir' || uri.host == 'www.cakeyousef.ir') {
    return false;
  }
  return true;
}
