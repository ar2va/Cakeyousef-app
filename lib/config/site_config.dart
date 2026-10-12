import '../api/api_config.dart';

class SiteConfig {
  /// Public web origin — same host the content API serves (slider hrefs, etc.).
  static String get siteUrl => ApiConfig.host;

  /// GitHub repo used for in-app updates via Releases.
  /// Repository must be public so users can read releases and download APK.
  static const githubOwner = 'Pouya-Mohammadi-Parsa';
  static const githubRepo = 'cakeyousef';

  /// Latest published release (non-draft, non-prerelease).
  static const githubLatestReleaseUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  /// Fallback version JSON on GitHub (no hardcoded marketing domain).
  static const appVersionUrl =
      'https://raw.githubusercontent.com/$githubOwner/$githubRepo/main/app-version.json';

  /// Matches API slider deep links: `/courses/{slug}`.
  static String courseCheckoutUrl(String? slug) {
    if (slug == null || slug.isEmpty) return siteUrl;
    return Uri.parse(siteUrl)
        .replace(pathSegments: ['courses', slug])
        .toString();
  }

  static String productCheckoutUrl(String? id) {
    if (id == null || id.isEmpty) return '$siteUrl/shop';
    return Uri.parse(siteUrl)
        .replace(pathSegments: ['shop', id])
        .toString();
  }

  /// Public page URL for native share sheets.
  static String courseShareUrl(String? slug) => courseCheckoutUrl(slug);

  static String productShareUrl(String? id) => productCheckoutUrl(id);
}
