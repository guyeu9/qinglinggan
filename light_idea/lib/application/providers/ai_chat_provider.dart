import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/idea.dart';
import '../ai/ai_chat_service.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<IdeaEntity>? referencedIdeas;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.referencedIdeas,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    List<IdeaEntity>? referencedIdeas,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      referencedIdeas: referencedIdeas ?? this.referencedIdeas,
    );
  }
}

class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final List<IdeaEntity> referencedIdeas;

  const AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.referencedIdeas = const [],
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    List<IdeaEntity>? referencedIdeas,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      referencedIdeas: referencedIdeas ?? this.referencedIdeas,
    );
  }
}

class AIChatNotifier extends StateNotifier<AIChatState> {
  final AIChatService _chatService;

  AIChatNotifier(this._chatService) : super(const AIChatState());

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    final result = await _chatService.chat(content);

    if (result.isSuccess) {
      final response = result.dataOrNull!;
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: response.content,
        isUser: false,
        timestamp: DateTime.now(),
        referencedIdeas: response.referencedIdeas,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
        referencedIdeas: response.referencedIdeas,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorOrNull ?? '发送消息失败',
      );
    }
  }

  Future<void> searchIdeas(String query) async {
    if (query.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '搜索: $query',
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    final result = await _chatService.searchByNaturalLanguage(query);

    if (result.isSuccess) {
      final ideas = result.dataOrNull!;

      String content;
      if (ideas.isEmpty) {
        content = '没有找到相关的灵感记录。';
      } else {
        content = '找到 ${ideas.length} 条相关灵感：\n';
        for (var i = 0; i < ideas.length && i < 5; i++) {
          content += '\n${i + 1}. ${ideas[i].content}';
        }
        if (ideas.length > 5) {
          content += '\n\n...还有 ${ideas.length - 5} 条结果';
        }
      }

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: content,
        isUser: false,
        timestamp: DateTime.now(),
        referencedIdeas: ideas,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
        referencedIdeas: ideas,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorOrNull ?? '搜索失败',
      );
    }
  }

  Future<void> reviewHistory({int days = 15}) async {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '总结最近 $days 天的灵感',
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    final result = await _chatService.reviewRecentIdeas(days: days);

    if (result.isSuccess) {
      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: result.dataOrNull!,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorOrNull ?? '回顾失败',
      );
    }
  }

  void clearChat() {
    state = const AIChatState();
  }
}
