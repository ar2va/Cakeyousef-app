import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the Bearer token in platform secure storage (Keystore / Keychain).
///
/// Migrates any legacy token left in SharedPreferences on first read.
class SecureTokenStore {
  SecureTokenStore._();
  static final SecureTokenStore instance = SecureTokenStore._();

  static const _tokenKey = 'auth_token';
  static const _expiresAtKey = 'auth_expires_at';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<String?> readToken() async {
    try {
      final secure = await _secure.read(key: _tokenKey);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (e) {
      debugPrint('SecureTokenStore read token: $e');
    }

    // One-time migration from older SharedPreferences storage.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_tokenKey);
    if (legacy == null || legacy.isEmpty) return null;

    await writeToken(legacy);
    await prefs.remove(_tokenKey);
    return legacy;
  }

  Future<DateTime?> readExpiresAt() async {
    try {
      final raw = await _secure.read(key: _expiresAtKey);
      if (raw != null && raw.isNotEmpty) {
        final ms = int.tryParse(raw);
        if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    } catch (e) {
      debugPrint('SecureTokenStore read expires: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyMs = prefs.getInt(_expiresAtKey);
    if (legacyMs == null) return null;

    final expires = DateTime.fromMillisecondsSinceEpoch(legacyMs);
    await writeExpiresAt(expires);
    await prefs.remove(_expiresAtKey);
    return expires;
  }

  Future<void> writeToken(String token) async {
    await _secure.write(key: _tokenKey, value: token);
    // Ensure plaintext copy is gone.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> writeExpiresAt(DateTime? expiresAt) async {
    if (expiresAt == null) {
      await _secure.delete(key: _expiresAtKey);
    } else {
      await _secure.write(
        key: _expiresAtKey,
        value: '${expiresAt.millisecondsSinceEpoch}',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expiresAtKey);
  }

  Future<void> clear() async {
    try {
      await _secure.delete(key: _tokenKey);
      await _secure.delete(key: _expiresAtKey);
    } catch (e) {
      debugPrint('SecureTokenStore clear: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiresAtKey);
  }
}
