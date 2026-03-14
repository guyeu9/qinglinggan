import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserConfig {
  UserConfig._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    wOptions: WindowsOptions(),
  );
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  static String? _cachedUserName;
  static String? _cachedUserEmail;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      _cachedUserName = await _storage.read(key: _userNameKey);
      _cachedUserEmail = await _storage.read(key: _userEmailKey);
    } catch (_) {
      _cachedUserName = null;
      _cachedUserEmail = null;
    }
    _initialized = true;
  }

  static Future<void> setUserName(String name) async {
    await _storage.write(key: _userNameKey, value: name);
    _cachedUserName = name;
  }

  static Future<String?> getUserName() async {
    if (!_initialized) {
      await initialize();
    }
    return _cachedUserName;
  }

  static Future<void> setUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
    _cachedUserEmail = email;
  }

  static Future<String?> getUserEmail() async {
    if (!_initialized) {
      await initialize();
    }
    return _cachedUserEmail;
  }

  static String? get cachedUserName => _cachedUserName;
  static String? get cachedUserEmail => _cachedUserEmail;

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    _cachedUserName = null;
    _cachedUserEmail = null;
    _initialized = false;
  }

  static bool get isInitialized => _initialized;
}
