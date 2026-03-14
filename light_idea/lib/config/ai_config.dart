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
  static const _chatModelKey = 'chat_model';
  static const _embeddingApiKeyKey = 'embedding_api_key';
  static const _embeddingBaseUrlKey = 'embedding_base_url';
  static const _embeddingDimensionKey = 'embedding_dimension';
  static const _enableAIKey = 'enable_ai';
  static const _apiBaseUrlKey = 'api_base_url';

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

  static Future<void> setChatModel(String model) async {
    await _storage.write(key: _chatModelKey, value: model);
  }

  static Future<String> getChatModel() async {
    final model = await _storage.read(key: _chatModelKey);
    return model ?? defaultChatModel;
  }

  static Future<void> setEmbeddingApiKey(String key) async {
    await _storage.write(key: _embeddingApiKeyKey, value: key);
  }

  static Future<String?> getEmbeddingApiKey() async {
    return await _storage.read(key: _embeddingApiKeyKey);
  }

  static Future<void> setEmbeddingBaseUrl(String url) async {
    await _storage.write(key: _embeddingBaseUrlKey, value: url);
  }

  static Future<String> getEmbeddingBaseUrl() async {
    final url = await _storage.read(key: _embeddingBaseUrlKey);
    return url ?? 'https://api.openai.com/v1/embeddings';
  }

  static Future<void> setEmbeddingDimension(int dimension) async {
    await _storage.write(key: _embeddingDimensionKey, value: dimension.toString());
  }

  static Future<int> getEmbeddingDimension() async {
    final dimension = await _storage.read(key: _embeddingDimensionKey);
    return dimension != null ? int.tryParse(dimension) ?? embeddingDimension : embeddingDimension;
  }

  static Future<void> setEnableAI(bool enable) async {
    await _storage.write(key: _enableAIKey, value: enable.toString());
  }

  static Future<bool> getEnableAI() async {
    final value = await _storage.read(key: _enableAIKey);
    return value != 'false';
  }

  static Future<void> setApiBaseUrl(String url) async {
    await _storage.write(key: _apiBaseUrlKey, value: url);
  }

  static Future<String> getApiBaseUrl() async {
    final url = await _storage.read(key: _apiBaseUrlKey);
    return url ?? apiBaseUrl;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    _cachedApiKey = null;
    _initialized = false;
  }
}
