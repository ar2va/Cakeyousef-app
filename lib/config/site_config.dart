class SiteConfig {
  static const siteUrl = 'https://www.cakeyousef.ir';

  /// Host used for in-app APK updates.
  static const apkHostUrl = 'https://dl.cakeyousef.com';

  /// Direct APK download (overwrite this file on each release).
  static const apkDownloadUrl = '$apkHostUrl/apk/cakeyousef.apk';

  /// Public version manifest on the same host.
  static const appVersionUrl = '$apkHostUrl/apk/app-version.json';

  static String courseCheckoutUrl(String? slug) {
    if (slug == null || slug.isEmpty) return siteUrl;
    return '$siteUrl/course/${Uri.encodeComponent(slug)}';
  }

  static String productCheckoutUrl(String? id) {
    if (id == null || id.isEmpty) return '$siteUrl/shop';
    return '$siteUrl/product/${Uri.encodeComponent(id)}';
  }
}
