class ApiConfig {
  /// Public website (Next.js via Nginx :80). Content / media / app-login.
  static const String host = 'http://62.60.188.164';

  /// Nest mobile API (JWT auth + account). Exposed on :4000 today.
  /// Content still uses [host]/api/... (Next.js).
  static const String apiHost = 'http://62.60.188.164:4000';

  /// Authenticated mobile routes: `/api/v1/auth/*`, `/api/v1/account/*`.
  static String get authBaseUrl => '$apiHost/api/v1';

  /// Same as [authBaseUrl] — account Bearer APIs live on Nest v1.
  static String get baseUrl => authBaseUrl;

  /// Deep link after browser / Custom Tab login.
  static const String authRedirectUri = 'cakeyousef://auth';

  /// Deep link after Zarinpal payment (wired with checkout later).
  static const String paymentRedirectUri = 'cakeyousef://payment';

  /// Browser login page (Option A). Same shape as authorizeUrl in the API guide.
  static String appLoginUrl({
    String redirectUri = authRedirectUri,
  }) {
    final q = Uri.encodeQueryComponent(redirectUri);
    return '$host/app-login?redirect_uri=$q';
  }

  /// Browser register page; after success site returns via app-callback deep link.
  static String appRegisterUrl({
    String redirectUri = authRedirectUri,
  }) {
    final q = Uri.encodeQueryComponent(redirectUri);
    return '$host/auth?mode=signup&app_redirect=$q';
  }

  /// Relative media paths → absolute URL on website host.
  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$host$path';
    return '$host/$path';
  }
}
