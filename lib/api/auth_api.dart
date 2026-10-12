import 'package:flutter/foundation.dart' show debugPrint;

import 'api_client.dart';
import 'api_config.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String imageUrl;
  final String userType;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.userType,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: '${json['id'] ?? ''}',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      imageUrl: ApiConfig.mediaUrl(json['image']?.toString()),
      userType: json['userType']?.toString() ?? '',
    );
  }
}

class AuthLoginResult {
  final String token;
  final String tokenType;
  final int expiresIn;
  final AuthUser user;

  const AuthLoginResult({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'];
    if (userMap is! Map) {
      throw const ApiException('پاسخ لاگین بدون اطلاعات کاربر است');
    }
    final token = json['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw const ApiException('توکن دریافت نشد');
    }
    return AuthLoginResult(
      token: token,
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: _asInt(json['expiresIn']),
      user: AuthUser.fromJson(Map<String, dynamic>.from(userMap)),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Authorize URL for browser / Custom Tab login.
  ///
  /// Tries Nest guide endpoint first; falls back to `/app-login`.
  Future<String> fetchAuthorizeUrl({
    String redirectUri = ApiConfig.authRedirectUri,
  }) async {
    try {
      final body = await _client.get(
        '${ApiConfig.authBaseUrl}/auth/authorize',
        query: {'redirect_uri': redirectUri},
      );
      final url = body['authorizeUrl']?.toString().trim() ?? '';
      if (url.isNotEmpty) return url;
    } on ApiException catch (e) {
      debugPrint('auth/authorize unavailable ($e) — using app-login fallback');
    } catch (e) {
      debugPrint('auth/authorize error ($e) — using app-login fallback');
    }
    return ApiConfig.appLoginUrl(redirectUri: redirectUri);
  }

  /// Exchange one-time deep-link code for Bearer token.
  Future<AuthLoginResult> exchangeToken(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw const ApiException('کد ورود نامعتبر است');
    }

    final body = await _client.post(
      '${ApiConfig.authBaseUrl}/auth/token-exchange',
      body: {'code': trimmed},
    );
    return AuthLoginResult.fromJson(body);
  }

  /// Direct login with phone/email + password (optional, no browser).
  Future<AuthLoginResult> login({
    required String identifier,
    required String password,
  }) async {
    final body = await _client.post(
      '${ApiConfig.authBaseUrl}/auth/login',
      body: {
        'identifier': identifier.trim(),
        'password': password,
      },
    );
    return AuthLoginResult.fromJson(body);
  }
}
