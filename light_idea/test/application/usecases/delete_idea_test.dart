import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/usecases/delete_idea.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/repositories/idea_repository.dart';
import 'package:light_idea/domain/repositories/association_repository.dart';
import 'package:light_idea/domain/repositories/ai_analysis_repository.dart';
import 'package:light_idea/domain/repositories/ai_task_repository.dart';
import 'package:light_idea/domain/entities/association.dart';
import 'package:light_idea/domain/entities/ai_analysis.dart';
import 'package:light_idea/domain/entities/ai_task.dart';

import 'package:light_idea/core/logger/app_logger.dart';

void main() {
  late DeleteIdeaUseCase useCase;
  late _MockIdeaRepository mockIdeaRepository;
  late _MockAssociationRepository mockAssociationRepository;
  late _MockAIAnalysisRepository mockAnalysisRepository;
  late _MockAITaskRepository mockTaskRepository;
  late _MockLogger mockLogger;

  setUp(() {
    mockIdeaRepository = _MockIdeaRepository();
    mockAssociationRepository = _MockAssociationRepository();
    mockAnalysisRepository = _MockAIAnalysisRepository();
    mockTaskRepository = _MockAITaskRepository();
    mockLogger = _MockLogger();
    useCase = DeleteIdeaUseCase(
      mockIdeaRepository,
      mockAssociationRepository,
      mockAnalysisRepository,
      mockTaskRepository,
      mockLogger,
    );
  });

  group('DeleteIdeaUseCase', () {
    group('execute', () {
      test('should soft delete idea by default', () async {
        mockIdeaRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1);

        expect(result.isSuccess, true);
        expect(mockIdeaRepository.softDeleteCalled, true);
        expect(mockIdeaRepository.permanentDeleteCalled, false);
        expect(mockAssociationRepository.deleteByIdeaIdCalled, true);
        expect(mockAnalysisRepository.deleteByIdeaIdCalled, true);
        expect(mockTaskRepository.deleteByIdeaIdCalled, true);
      });

      test('should permanent delete when permanent is true', () async {
        mockIdeaRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = await useCase.execute(1, permanent: true);

        expect(result.isSuccess, true);
        expect(mockIdeaRepository.permanentDeleteCalled, true);
        expect(mockIdeaRepository.softDeleteCalled, false);
      });

      test('should fail if idea does not exist', () async {
        mockIdeaRepository.existingIdea = null;

        final result = await useCase.execute(1);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('不存在'));
      });

      test('should log success message for soft delete', () async {
        mockIdeaRepository.existingIdea = IdeaEntity(
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
        mockIdeaRepository.existingIdea = IdeaEntity(
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
        mockIdeaRepository.existingIdea = null;

        await useCase.execute(1);

        expect(mockLogger.warningCalled, true);
      });

      test('should handle repository exception', () async {
        mockIdeaRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        mockIdeaRepository.shouldThrow = true;

        final result = await useCase.execute(1);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('失败'));
        expect(mockLogger.errorCalled, true);
      });

      test('should handle permanent delete exception', () async {
        mockIdeaRepository.existingIdea = IdeaEntity(
          id: 1,
          content: 'Test idea',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        mockIdeaRepository.shouldThrow = true;

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
  Future<int> count({bool includeDeleted = false}) async => 1;

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
  Future<List<IdeaEntity>> getIdeasWithEmbedding({int limit = 100, int offset = 1}) async => [];

  @override
  Future<int> countIdeasWithEmbedding() async => 0;
}

class _MockAssociationRepository implements AssociationRepository {
  bool deleteByIdeaIdCalled = false;

  @override
  Future<AssociationEntity> save(AssociationEntity association) async => association;

  @override
  Future<List<AssociationEntity>> getBySourceIdeaId(int ideaId) async => [];

  @override
  Future<List<AssociationEntity>> getByTargetIdeaId(int ideaId) async => [];

  @override
  Future<List<AssociationEntity>> getByIdeaId(int ideaId) async => [];

  @override
  Future<List<AssociationEntity>> getByIdeaIdAndType(int ideaId, RelationType type) async => [];

  @override
  Future<AssociationEntity?> getById(int id) async => null;

  @override
  Future<void> deleteBySourceIdeaId(int ideaId) async {}

  @override
  Future<void> deleteByIdeaId(int ideaId) async {
    deleteByIdeaIdCalled = true;
  }

  @override
  Future<void> deleteAll() async {}

  @override
  Future<int> countByIdeaId(int ideaId) async => 0;

  @override
  Future<int> countByIdeaIdAndType(int ideaId, RelationType type) async => 0;
}

class _MockAIAnalysisRepository implements AIAnalysisRepository {
  bool deleteByIdeaIdCalled = false;

  @override
  Future<AIAnalysisEntity> save(AIAnalysisEntity analysis) async => analysis;

  @override
  Future<AIAnalysisEntity?> getById(int id) async => null;

  @override
  Future<AIAnalysisEntity?> getByIdeaId(int ideaId) async => null;

  @override
  Future<List<AIAnalysisEntity>> getAll() async => [];

  @override
  Future<void> update(AIAnalysisEntity analysis) async {}

  @override
  Future<void> updateStatus(int id, AnalysisStatus status) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> deleteByIdeaId(int ideaId) async {
    deleteByIdeaIdCalled = true;
  }
}

class _MockAITaskRepository implements AITaskRepository {
  bool deleteByIdeaIdCalled = false;

  @override
  Future<AITaskEntity> save(AITaskEntity task) async => task;

  @override
  Future<AITaskEntity?> getById(int id) async => null;

  @override
  Future<AITaskEntity?> getByIdeaId(int ideaId) async => null;

  @override
  Future<List<AITaskEntity>> getPendingTasks() async => [];

  @override
  Future<List<AITaskEntity>> getProcessingTasks() async => [];

  @override
  Future<void> update(AITaskEntity task) async {}

  @override
  Future<void> updateStatus(int id, TaskStatus status, {String? errorMessage}) async {}

  @override
  Future<void> incrementRetryCount(int id) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> deleteByIdeaId(int ideaId) async {
    deleteByIdeaIdCalled = true;
  }

  @override
  Future<void> deleteCompletedTasks() async {}

  @override
  Future<AITaskEntity?> getActiveTaskByIdeaId(int ideaId) async => null;

  @override
  Future<AITaskEntity?> getLatestTaskByIdeaId(int ideaId) async => null;
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
