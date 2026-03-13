import 'dart:convert';
import '../../core/exceptions/ai_exceptions.dart';

class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}

class ChatCompletionRequest {
  final String model;
  final List<ChatMessage> messages;
  final double? temperature;
  final int? maxTokens;

  const ChatCompletionRequest({
    required this.model,
    required this.messages,
    this.temperature,
    this.maxTokens,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
      };
}

class ChatCompletionResponse {
  final String id;
  final String object;
  final DateTime created;
  final String model;
  final List<ChatChoice> choices;
  final Usage usage;

  const ChatCompletionResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: DateTime.fromMillisecondsSinceEpoch((json['created'] as int) * 1000),
      model: json['model'] as String,
      choices: (json['choices'] as List)
          .map((e) => ChatChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: Usage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  String? get content => choices.isNotEmpty ? choices.first.message.content : null;
}

class ChatChoice {
  final int index;
  final ChatMessage message;
  final String? finishReason;

  const ChatChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'] as int,
      message: ChatMessage.fromJson(json['message'] as Map<String, dynamic>),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

class Usage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }
}

class EmbeddingRequest {
  final String model;
  final String input;

  const EmbeddingRequest({
    required this.model,
    required this.input,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'input': input,
      };
}

class EmbeddingResponse {
  final String id;
  final String object;
  final List<EmbeddingData> data;
  final String model;
  final Usage usage;

  const EmbeddingResponse({
    required this.id,
    required this.object,
    required this.data,
    required this.model,
    required this.usage,
  });

  factory EmbeddingResponse.fromJson(Map<String, dynamic> json) {
    return EmbeddingResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      data: (json['data'] as List)
          .map((e) => EmbeddingData.fromJson(e as Map<String, dynamic>))
          .toList(),
      model: json['model'] as String,
      usage: Usage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  List<double>? get embedding => data.isNotEmpty ? data.first.embedding : null;
}

class EmbeddingData {
  final int index;
  final List<double> embedding;
  final String object;

  const EmbeddingData({
    required this.index,
    required this.embedding,
    required this.object,
  });

  factory EmbeddingData.fromJson(Map<String, dynamic> json) {
    return EmbeddingData(
      index: json['index'] as int,
      embedding: (json['embedding'] as List).map((e) => (e as num).toDouble()).toList(),
      object: json['object'] as String,
    );
  }
}

class AIAnalysisResult {
  final int? categoryId;
  final String? categoryName;
  final List<String> tags;
  final String summary;
  final String aiHint;

  const AIAnalysisResult({
    this.categoryId,
    this.categoryName,
    this.tags = const [],
    this.summary = '',
    this.aiHint = '',
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      categoryId: json['categoryId'] as int?,
      categoryName: json['categoryName'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      summary: json['summary'] as String? ?? '',
      aiHint: json['aiHint'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'tags': tags,
        'summary': summary,
        'aiHint': aiHint,
      };

  static AIAnalysisResult parseFromJsonString(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw AIEmptyResponseException();
    }

    try {
      final cleaned = jsonString
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return AIAnalysisResult.fromJson(json);
    } on FormatException catch (e) {
      throw AIResponseParseException(
        'JSON 格式解析失败',
        rawContent: jsonString,
        cause: e,
      );
    } on TypeError catch (e) {
      throw AIInvalidResponseStructureException(
        'JSON 结构不符合预期',
        rawContent: jsonString,
        cause: e,
      );
    }
  }
}
