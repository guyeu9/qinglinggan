import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/domain/entities/ai_analysis.dart';
import 'package:light_idea/domain/entities/idea.dart';

void main() {
  group('IdeaEntity', () {
    test('`computeContentHash` 应对首尾空白归一化后生成相同哈希', () {
      final hash1 = IdeaEntity.computeContentHash('hello world');
      final hash2 = IdeaEntity.computeContentHash('  hello world  ');

      expect(hash1, hash2);
    });

    test('`copyWith` 在内容变更时应刷新 contentHash', () {
      final idea = IdeaEntity(
        id: 1,
        content: 'old content',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = idea.copyWith(content: 'new content');

      expect(updated.contentHash, IdeaEntity.computeContentHash('new content'));
      expect(updated.contentHash, isNot(equals(idea.contentHash)));
    });

    test('`hasSameContent` 应忽略首尾空白差异', () {
      final idea = IdeaEntity(
        id: 1,
        content: 'same content',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(idea.hasSameContent('  same content  '), isTrue);
      expect(idea.hasSameContent('different content'), isFalse);
    });
  });

  group('AIAnalysisEntity', () {
    test('`matchesIdeaSnapshot` 在 hash 与 updatedAt 同时匹配时返回 true', () {
      final updatedAt = DateTime(2024, 1, 1, 12, 0, 0);
      final analysis = AIAnalysisEntity(
        id: 1,
        ideaId: 10,
        createdAt: updatedAt,
        updatedAt: updatedAt,
        sourceContentHash: 'abc12345',
        sourceIdeaUpdatedAt: updatedAt,
      );

      expect(
        analysis.matchesIdeaSnapshot(
          contentHash: 'abc12345',
          updatedAt: updatedAt,
        ),
        isTrue,
      );
    });

    test('`matchesIdeaSnapshot` 在 hash 或 updatedAt 不匹配时返回 false', () {
      final updatedAt = DateTime(2024, 1, 1, 12, 0, 0);
      final analysis = AIAnalysisEntity(
        id: 1,
        ideaId: 10,
        createdAt: updatedAt,
        updatedAt: updatedAt,
        sourceContentHash: 'abc12345',
        sourceIdeaUpdatedAt: updatedAt,
      );

      expect(
        analysis.matchesIdeaSnapshot(
          contentHash: 'different',
          updatedAt: updatedAt,
        ),
        isFalse,
      );
      expect(
        analysis.matchesIdeaSnapshot(
          contentHash: 'abc12345',
          updatedAt: updatedAt.add(const Duration(seconds: 1)),
        ),
        isFalse,
      );
    });
  });
}
