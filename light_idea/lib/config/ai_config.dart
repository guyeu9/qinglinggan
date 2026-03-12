import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AIConfig {
  AIConfig._();

  static const String defaultChatModel = 'gpt-4o-mini';
  static const String defaultEmbeddingModel = 'text-embedding-3-small';
  
  static const int embeddingDimension = 1536;
  
  static const int defaultMaxTokens = 1000;
  static const double defaultTemperature = 0.3;
  
  static const int defaultTimeoutSeconds = 60;
  static const int maxRetryCount = 3;
  static const int retryDelaySeconds = 2;
  
  static const String apiBaseUrl = 'https://api.openai.com/v1';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    wOptions: WindowsOptions(),
  );
  static const _apiKeyKey = 'openai_api_key';

  static String? _cachedApiKey;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      _cachedApiKey = await _storage.read(key: _apiKeyKey);
    } catch (_) {
      _cachedApiKey = null;
    }
    _initialized = true;
  }

  static Future<void> setApiKey(String key) async {
    await _storage.write(key: _apiKeyKey, value: key);
    _cachedApiKey = key;
  }

  static Future<String?> getApiKey() async {
    if (!_initialized) {
      await initialize();
    }
    return _cachedApiKey;
  }

  static Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeyKey);
    _cachedApiKey = null;
  }

  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  static String? get cachedApiKey => _cachedApiKey;
  
  static bool get isInitialized => _initialized;
}
