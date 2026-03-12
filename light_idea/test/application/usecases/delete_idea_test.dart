import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/usecases/delete_idea.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/repositories/idea_repository.dart';
import 'package:light_idea/core/utils/result.dart';
import 'package:light_idea/core/logger/app_logger.dart';

void main() {
  late DeleteIdeaUseCase useCase;
  late _MockIdeaRepository mockRepository;
  late _MockLogger mockLogger;

  setUp(() {
    mockRepository = _MockIdeaRepository();
    mockLogger = _MockLogger();
    useCase = DeleteIdeaUseCase(mockRepository, mockLogger);
  });

  group('DeleteIdeaUseCase', () {
    group('execute', () {
      test('should soft delete idea by default', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1);

        expect(result.isSuccess, true);
        expect(mockRepository.softDeleteCalled, true);
        expect(mockRepository.permanentDeleteCalled, false);
      });

      test('should permanent delete when permanent is true', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1, permanent: true);

        expect(result.isSuccess, true);
        expect(mockRepository.permanentDeleteCalled, true);
        expect(mockRepository.softDeleteCalled, false);
      });

      test('should fail if idea does not exist', () async {
        mockRepository.existingIdea = null;

        final result = await useCase.execute(1);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('不存在'));
      });

      test('should log success message for soft delete', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        await useCase.execute(1);

        expect(mockLogger.infoCalled, true);
        expect(mockLogger.lastInfoMessage, contains('软删除'));
      });

      test('should log success message for permanent delete', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        await useCase.execute(1, permanent: true);

        expect(mockLogger.infoCalled, true);
        expect(mockLogger.lastInfoMessage, contains('永久删除'));
      });

      test('should log warning if idea does not exist', () async {
        mockRepository.existingIdea = null;

        await useCase.execute(1);

        expect(mockLogger.warningCalled, true);
      });

      test('should handle repository exception', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        mockRepository.shouldThrow = true;

        final result = await useCase.execute(1);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('失败'));
        expect(mockLogger.errorCalled, true);
      });

      test('should handle permanent delete exception', () async {
        mockRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        mockRepository.shouldThrow = true;

        final result = await useCase.execute(1, permanent: true);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('失败'));
      });
    });
  });
}

class _MockIdeaRepository implements IdeaRepository {
  IdeaEntity? existingIdea;
  bool shouldThrow = false;
  bool softDeleteCalled = false;
  bool permanentDeleteCalled = false;

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
  Future<void> update(IdeaEntity idea) async {}

  @override
  Future<void> updateAIStatus(int id, AIStatus status) async {}

  @override
  Future<void> updateEmbedding(int id, List<double> embedding) async {}

  @override
  Future<void> softDelete(int id) async {
    softDeleteCalled = true;
    if (shouldThrow) {
      throw Exception('Database error');
    }
  }

  @override
  Future<void> restore(int id) async {}

  @override
  Future<void> permanentDelete(int id) async {
    permanentDeleteCalled = true;
    if (shouldThrow) {
      throw Exception('Database error');
    }
  }

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
  String? lastInfoMessage;

  @override
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    infoCalled = true;
    lastInfoMessage = message;
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
