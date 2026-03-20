import 'dart:async';
import 'package:dio/dio.dart';
import '../../config/ai_config.dart';
import '../../core/services/log_service.dart';
import 'api_models.dart';

class OpenAIClient {
  final Dio _dio;
  final int _maxRetryCount;
  final int _retryDelaySeconds;

  OpenAIClient({
    int maxRetryCount = AIConfig.maxRetryCount,
    int retryDelaySeconds = AIConfig.retryDelaySeconds,
    int timeoutSeconds = AIConfig.defaultTimeoutSeconds,
  })  : _maxRetryCount = maxRetryCount,
        _retryDelaySeconds = retryDelaySeconds,
        _dio = Dio(BaseOptions(
          baseUrl: AIConfig.apiBaseUrl,
          connectTimeout: Duration(seconds: timeoutSeconds),
          receiveTimeout: Duration(seconds: timeoutSeconds),
        ));

  Future<Map<String, dynamic>> _getHeaders() async {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
    };
    final apiKey = await AIConfig.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    return headers;
  }

  Future<ChatCompletionResponse> chatCompletion(
    List<ChatMessage> messages, {
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    final actualModel = model ?? AIConfig.defaultChatModel;
    logService.i('OpenAIClient', 'chatCompletion开始: model=$actualModel');
    
    final request = ChatCompletionRequest(
      model: actualModel,
      messages: messages,
      temperature: temperature ?? AIConfig.defaultTemperature,
      maxTokens: maxTokens ?? AIConfig.defaultMaxTokens,
    );

    return _executeWithRetry(() async {
      final headers = await _getHeaders();
      logService.d('OpenAIClient', '发送请求: baseUrl=${_dio.options.baseUrl}');
      
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: request.toJson(),
        options: Options(headers: headers),
      );
      
      logService.i('OpenAIClient', 'chatCompletion响应成功: status=${response.statusCode}');
      return ChatCompletionResponse.fromJson(response.data!);
    });
  }

  Future<EmbeddingResponse> embedding(
    String input, {
    String? model,
  }) async {
    final request = EmbeddingRequest(
      model: model ?? AIConfig.defaultEmbeddingModel,
      input: input,
    );

    return _executeWithRetry(() async {
      final headers = await _getHeaders();
      final response = await _dio.post<Map<String, dynamic>>(
        '/embeddings',
        data: request.toJson(),
        options: Options(headers: headers),
      );
      return EmbeddingResponse.fromJson(response.data!);
    });
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() action) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < _maxRetryCount) {
      try {
        return await action();
      } on DioException catch (e) {
        lastException = e;

        if (e.response?.statusCode == 429) {
          retryCount++;
          if (retryCount < _maxRetryCount) {
            final delay = _retryDelaySeconds * (1 << (retryCount - 1));
            await Future<void>.delayed(Duration(seconds: delay));
            continue;
          }
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          retryCount++;
          if (retryCount < _maxRetryCount) {
            await Future<void>.delayed(Duration(seconds: _retryDelaySeconds));
            continue;
          }
        }

        rethrow;
      }
    }

    throw lastException ?? Exception('Max retry count exceeded');
  }

  Future<List<double>> generateEmbedding(String content) async {
    final response = await embedding(content);
    return response.embedding ?? [];
  }

  Future<String> chat(String systemPrompt, String userMessage) async {
    final response = await chatCompletion([
      ChatMessage(role: 'system', content: systemPrompt),
      ChatMessage(role: 'user', content: userMessage),
    ]);
    return response.content ?? '';
  }
}
