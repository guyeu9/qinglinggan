import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/ai/ai_chat_service.dart';
import 'package:light_idea/application/providers/ai_chat_provider.dart';

void main() {
  group('ChatResponse', () {
    test('should create response with content only', () {
      const response = ChatResponse(content: 'Hello');

      expect(response.content, 'Hello');
      expect(response.referencedIdeas, isEmpty);
    });

    test('should create response with referenced ideas', () {
      const response = ChatResponse(
        content: 'Found these ideas',
        referencedIdeas: [],
      );

      expect(response.content, 'Found these ideas');
      expect(response.referencedIdeas, isEmpty);
    });
  });

  group('ChatMessage', () {
    test('should create user message', () {
      final message = ChatMessage(
        id: '1',
        content: 'Hello',
        isUser: true,
        timestamp: DateTime(2026, 1, 1, 10, 0),
      );

      expect(message.id, '1');
      expect(message.content, 'Hello');
      expect(message.isUser, true);
      expect(message.referencedIdeas, isNull);
    });

    test('should create AI message with referenced ideas', () {
      final message = ChatMessage(
        id: '2',
        content: 'Here are your ideas',
        isUser: false,
        timestamp: DateTime(2026, 1, 1, 10, 1),
        referencedIdeas: [],
      );

      expect(message.isUser, false);
      expect(message.referencedIdeas, isNotNull);
      expect(message.referencedIdeas, isEmpty);
    });

    test('should copyWith correctly', () {
      final original = ChatMessage(
        id: '1',
        content: 'Original',
        isUser: true,
        timestamp: DateTime(2026, 1, 1),
      );

      final copied = original.copyWith(content: 'Updated');

      expect(copied.id, '1');
      expect(copied.content, 'Updated');
      expect(copied.isUser, true);
    });
  });

  group('AIChatState', () {
    test('should create default state', () {
      const state = AIChatState();

      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.referencedIdeas, isEmpty);
    });

    test('should create state with messages', () {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Hello',
          isUser: true,
          timestamp: DateTime.now(),
        ),
      ];

      final state = AIChatState(messages: messages);

      expect(state.messages.length, 1);
      expect(state.messages.first.content, 'Hello');
    });

    test('should create loading state', () {
      const state = AIChatState(isLoading: true);

      expect(state.isLoading, true);
    });

    test('should create error state', () {
      const state = AIChatState(error: 'Something went wrong');

      expect(state.error, 'Something went wrong');
    });

    test('should copyWith correctly', () {
      const original = AIChatState(isLoading: true);
      final copied = original.copyWith(isLoading: false, error: 'Error');

      expect(copied.isLoading, false);
      expect(copied.error, 'Error');
    });
  });
}
