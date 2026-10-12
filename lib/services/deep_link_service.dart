import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/auth_api.dart';
import '../state/auth_session.dart';
import '../utils/app_messenger.dart';

/// Handles `cakeyousef://auth` (login) and `cakeyousef://payment` (ZarinPal return) deep links.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final _appLinks = AppLinks();
  final _authApi = AuthApi();
  StreamSubscription<Uri>? _sub;
  bool _started = false;
  bool _handlingAuth = false;
  String? _lastHandledCode;

  /// True while exchanging a login code (UI can show a spinner).
  bool get isExchanging => _handlingAuth;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    debugPrint('DeepLinkService: starting');

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        debugPrint('DeepLinkService: initial link $initial');
        unawaited(_handle(initial));
      }
    } catch (e) {
      debugPrint('DeepLink initial: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('DeepLinkService: stream link $uri');
        unawaited(_handle(uri));
      },
      onError: (Object e) => debugPrint('DeepLink stream: $e'),
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }

  Future<void> _handle(Uri uri) async {
    if (uri.scheme != 'cakeyousef') return;

    switch (uri.host) {
      case 'auth':
        await _handleAuth(uri);
      case 'payment':
        await _handlePayment(uri);
      default:
        debugPrint('Unhandled deep link: $uri');
    }
  }

  Future<void> _handleAuth(Uri uri) async {
    final code = uri.queryParameters['code']?.trim() ?? '';
    if (code.isEmpty) {
      debugPrint('Auth deep link missing code: $uri');
      AuthSession.instance.setAuthError('کد ورود از مرورگر دریافت نشد');
      return;
    }
    if (_handlingAuth) return;
    if (_lastHandledCode == code) {
      debugPrint('Auth deep link already handled for this code');
      return;
    }

    _handlingAuth = true;
    _lastHandledCode = code;
    AuthSession.instance.clearAuthError();
    try {
      debugPrint('DeepLinkService: exchanging code…');
      final result = await _authApi.exchangeToken(code);
      await AuthSession.instance.applyLogin(result);
      debugPrint('DeepLinkService: login applied');
      showAppMessage('ورود موفق بود', success: true);
    } on ApiException catch (e) {
      debugPrint('Auth exchange failed: $e');
      _lastHandledCode = null; // allow retry with a fresh browser login
      AuthSession.instance.setAuthError(e.message);
    } catch (e) {
      debugPrint('Auth exchange error: $e');
      _lastHandledCode = null;
      AuthSession.instance.setAuthError('ورود از مرورگر ناموفق بود');
    } finally {
      _handlingAuth = false;
    }
  }

  String? _lastHandledPayment;

  /// `cakeyousef://payment?status=success|failed&orderId=…&ref=…`
  /// sent by the site's ZarinPal callback after the bank round-trip.
  Future<void> _handlePayment(Uri uri) async {
    final params = uri.queryParameters;
    final status = (params['status'] ?? params['payment'] ?? '').trim();
    final orderId = params['orderId'] ?? '';
    final key = '$status:$orderId:${params['ref'] ?? ''}';
    if (_lastHandledPayment == key) return;
    _lastHandledPayment = key;

    if (status == 'success') {
      final ref = params['ref']?.trim() ?? '';
      showAppMessage(
        ref.isEmpty
            ? 'پرداخت موفق بود؛ سفارش شما ثبت شد'
            : 'پرداخت موفق بود — کد پیگیری: $ref',
        success: true,
        duration: const Duration(seconds: 6),
      );
      // New enrolments / orders appear in My Courses and Profile.
      await AuthSession.instance.refreshAccount().catchError((_) {});
    } else {
      final reason = params['reason'] ?? '';
      showAppMessage(
        reason == 'canceled'
            ? 'پرداخت لغو شد'
            : 'پرداخت انجام نشد. اگر مبلغی کسر شده، طبق روال بانکی برمی‌گردد.',
        error: true,
        duration: const Duration(seconds: 6),
      );
    }
  }

  /// Authorize URL for Option A (open with url_launcher / Custom Tabs).
  Future<String> resolveAuthorizeUrl({bool register = false}) async {
    if (register) {
      return ApiConfig.appRegisterUrl(
        redirectUri: ApiConfig.authRedirectUri,
      );
    }
    return _authApi.fetchAuthorizeUrl(
      redirectUri: ApiConfig.authRedirectUri,
    );
  }
}
