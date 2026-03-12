import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/domain/entities/idea.dart';

void main() {
  group('IdeaEntity', () {
    test('should create idea with required fields', () {
      final idea = IdeaEntity(
        id: 1,
        content: 'Test idea',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(idea.id, 1);
      expect(idea.content, 'Test idea');
      expect(idea.isDeleted, false);
      expect(idea.aiStatus, AIStatus.pending);
    });

    test('should create idea with all fields', () {
      final idea = IdeaEntity(
        id: 1,
        content: 'Test idea',
        categoryId: 2,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isDeleted: true,
        aiStatus: AIStatus.completed,
        tagIds: [1, 2, 3],
      );

      expect(idea.categoryId, 2);
      expect(idea.isDeleted, true);
      expect(idea.aiStatus, AIStatus.completed);
      expect(idea.tagIds, [1, 2, 3]);
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final idea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final copied = idea.copyWith(content: 'Updated idea');

        expect(copied.id, 1);
        expect(copied.content, 'Updated idea');
        expect(copied.createdAt, idea.createdAt);
      });

      test('should keep original values when not provided', () {
        final idea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final copied = idea.copyWith();

        expect(copied.id, idea.id);
        expect(copied.content, idea.content);
      });
    });

    group('equality', () {
      test('should be equal when id and content are same', () {
        final idea1 = IdeaEntity(
          id: 1,
          content: 'Test',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final idea2 = IdeaEntity(
          id: 1,
          content: 'Test',
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(idea1, equals(idea2));
      });

      test('should not be equal when ids are different', () {
        final idea1 = IdeaEntity(
          id: 1,
          content: 'Test',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final idea2 = IdeaEntity(
          id: 2,
          content: 'Test',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(idea1, isNot(equals(idea2)));
      });

      test('should not be equal when content is different', () {
        final idea1 = IdeaEntity(
          id: 1,
          content: 'Test 1',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final idea2 = IdeaEntity(
          id: 1,
          content: 'Test 2',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(idea1, isNot(equals(idea2)));
      });
    });

    group('toString', () {
      test('should contain id and content', () {
        final idea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(idea.toString(), contains('id: 1'));
        expect(idea.toString(), contains('Test idea'));
      });

      test('should truncate long content in toString', () {
        final longContent = 'a' * 100;
        final idea = IdeaEntity(
          id: 1,
          content: longContent,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(idea.toString(), contains('...'));
      });
    });
  });
}
