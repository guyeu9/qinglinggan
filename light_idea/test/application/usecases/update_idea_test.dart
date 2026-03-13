import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/usecases/update_idea.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/repositories/idea_repository.dart';

import 'package:light_idea/core/logger/app_logger.dart';

void main() {
  late UpdateIdeaUseCase useCase;
  late _MockIdeaRepository mockRepository;
  late _MockLogger mockLogger;

  setUp(() {
    mockRepository = _MockIdeaRepository();
    mockLogger = _MockLogger();
    useCase = UpdateIdeaUseCase(mockRepository, mockLogger);
  });

  group('UpdateIdeaUseCase', () {
    group('execute', () {
      test('should update idea with valid content', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1, 'Updated content');

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.content, 'Updated content');
      });

      test('should trim content before updating', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1, '  Updated content  ');

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.content, 'Updated content');
      });

      test('should fail with empty content', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1, '');

        expect(result.isError, true);
        expect(result.errorOrNull, contains('空'));
      });

      test('should fail with whitespace only content', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1, '   ');

        expect(result.isError, true);
        expect(result.errorOrNull, contains('空'));
      });

      test('should fail with content exceeding max length', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1, 'a' * 10001);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('超过'));
      });

      test('should fail if idea does not exist', () async {
        mockRepository.existingIdea = null;

        final result = await useCase.execute(1, 'Updated content');

        expect(result.isError, true);
        expect(result.errorOrNull, contains('不存在'));
      });

      test('should fail if idea is deleted', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          isDeleted: true,
        );

        final result = await useCase.execute(1, 'Updated content');

        expect(result.isError, true);
        expect(result.errorOrNull, contains('删除'));
      });

      test('should reset aiStatus to pending', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          aiStatus: AIStatus.completed,
        );

        final result = await useCase.execute(1, 'Updated content');

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.aiStatus, AIStatus.pending);
      });

      test('should update updatedAt timestamp', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final beforeUpdate = DateTime.now();
        final result = await useCase.execute(1, 'Updated content');

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.updatedAt.isAfter(beforeUpdate.subtract(const Duration(seconds: 1))), true);
      });

      test('should log success message', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        await useCase.execute(1, 'Updated content');

        expect(mockLogger.infoCalled, true);
      });

      test('should handle repository exception', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Original content',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        mockRepository.shouldThrow = true;

        final result = await useCase.execute(1, 'Updated content');

        expect(result.isError, true);
        expect(result.errorOrNull, contains('失败'));
      });
    });
  });
}

class _MockIdeaRepository implements IdeaRepository {
  IdeaEntity? existingIdea;
  bool shouldThrow = false;

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async => idea;

  @override
  Future<IdeaEntity?> getById(int id) async => existingIdea;

  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async => [];

  @override
  Future<List<IdeaEntity>> getByCategory(int categoryId) async => [];

  @override
  Future<List<IdeaEntity>> getByPage(int offset, int limit) async => [];

  @override
  Future<int> count({bool includeDeleted = false}) async => 0;

  @override
  Future<void> update(IdeaEntity idea) async {
    if (shouldThrow) {
      throw Exception('Database error');
    }
  }

  @override
  Future<void> updateAIStatus(int id, AIStatus status) async {}

  @override
  Future<void> updateEmbedding(int id, List<double> embedding) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> restore(int id) async {}

  @override
  Future<void> permanentDelete(int id) async {}

  @override
  Future<List<IdeaEntity>> searchByContent(String keyword) async => [];

  @override
  Future<List<IdeaEntity>> getDeleted() async => [];

  @override
  Future<void> clearDeleted() async {}

  @override
  Future<List<IdeaEntity>> getIdeasWithEmbedding({int limit = 100, int offset = 0}) async => [];

  @override
  Future<int> countIdeasWithEmbedding() async => 0;
}

class _MockLogger implements AppLogger {
  bool infoCalled = false;
  bool errorCalled = false;
  bool warningCalled = false;

  @override
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    infoCalled = true;
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    warningCalled = true;
  }

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    errorCalled = true;
  }

  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {}
}
