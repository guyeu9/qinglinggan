import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/ai/ai_embedding_service.dart';
import 'package:light_idea/application/ai/ai_relation_service.dart';
import 'package:light_idea/application/ai/ai_synthesis_service.dart';
import 'package:light_idea/application/ai/ai_understanding_service.dart';
import 'package:light_idea/application/task_queue/ai_task_queue.dart';
import 'package:light_idea/application/usecases/reanalyze_idea.dart';
import 'package:light_idea/core/logger/app_logger.dart';
import 'package:light_idea/core/utils/result.dart';
import 'package:light_idea/data/api/openai_client.dart';
import 'package:light_idea/domain/entities/ai_analysis.dart';
import 'package:light_idea/domain/entities/ai_task.dart';
import 'package:light_idea/domain/entities/association.dart';
import 'package:light_idea/domain/entities/category.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/entities/tag.dart';
import 'package:light_idea/domain/repositories/ai_analysis_repository.dart';
import 'package:light_idea/domain/repositories/ai_task_repository.dart';
import 'package:light_idea/domain/repositories/association_repository.dart';
import 'package:light_idea/domain/repositories/category_repository.dart';
import 'package:light_idea/domain/repositories/idea_repository.dart';
import 'package:light_idea/domain/repositories/tag_repository.dart';

void main() {
  group('ReanalyzeIdeaUseCase', () {
    late ReanalyzeIdeaUseCase useCase;
    late _FakeTaskQueue taskQueue;
    late _FakeLogger logger;

    setUp(() {
      taskQueue = _FakeTaskQueue();
      logger = _FakeLogger();
      useCase = ReanalyzeIdeaUseCase(taskQueue, logger);
    });

    test('应以 fullAnalysis + force:true 触发重新分析', () async {
      final result = await useCase.execute(123);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isTrue);
      expect(taskQueue.lastIdeaId, 123);
      expect(taskQueue.lastTaskType, TaskType.fullAnalysis);
      expect(taskQueue.lastForce, isTrue);
    });

    test('当 ideaId 非法时应返回错误', () async {
      final result = await useCase.execute(0);

      expect(result.isError, isTrue);
      expect(taskQueue.lastIdeaId, isNull);
    });

    test('当任务被跳过时应返回 success(false)', () async {
      taskQueue.result = EnqueueResult.skipped('任务已存在');

      final result = await useCase.execute(2);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isFalse);
    });
  });
}

class _FakeTaskQueue extends AITaskQueue {
  _FakeTaskQueue()
      : super(
          understandingService: _FakeUnderstandingService(),
          embeddingService: _FakeEmbeddingService(),
          relationService: _FakeRelationService(),
          synthesisService: _FakeSynthesisService(),
          taskRepository: _FakeAITaskRepository(),
          ideaRepository: _FakeIdeaRepository(),
          analysisRepository: _FakeAIAnalysisRepository(),
          categoryRepository: _FakeCategoryRepository(),
          tagRepository: _FakeTagRepository(),
          associationRepository: _FakeAssociationRepository(),
          logger: _FakeLogger(),
        );

  int? lastIdeaId;
  TaskType? lastTaskType;
  bool? lastForce;
  EnqueueResult result = EnqueueResult.enqueued(
    AITaskEntity(
      id: 1,
      ideaId: 1,
      taskType: TaskType.fullAnalysis,
      status: TaskStatus.pending,
      createdAt: DateTime(2024, 1, 1),
    ),
  );

  @override
  Future<EnqueueResult> enqueue(
    int ideaId, {
    TaskType taskType = TaskType.basicAnalysis,
    bool force = false,
  }) async {
    lastIdeaId = ideaId;
    lastTaskType = taskType;
    lastForce = force;
    return result;
  }
}

class _FakeUnderstandingService extends AIUnderstandingService {
  _FakeUnderstandingService()
      : super(
          _FakeOpenAIClient(),
          _FakeCategoryRepository(),
          _FakeLogger(),
        );
}

class _FakeEmbeddingService extends AIEmbeddingService {
  _FakeEmbeddingService()
      : super(
          _FakeOpenAIClient(),
          _FakeIdeaRepository(),
          _FakeLogger(),
        );
}

class _FakeSynthesisService extends AISynthesisService {
  _FakeSynthesisService()
      : super(
          _FakeOpenAIClient(),
          _FakeLogger(),
        );
}

class _FakeRelationService implements AIRelationService {
  @override
  Future<Result<List<AssociationEntity>>> judgeRelations({
    required IdeaEntity currentIdea,
    required List<IdeaEntity> candidates,
  }) async {
    return Result.success(<AssociationEntity>[]);
  }
}

class _FakeOpenAIClient extends OpenAIClient {
  _FakeOpenAIClient() : super(baseUrl: 'https://example.com');
}

class _FakeAITaskRepository implements AITaskRepository {
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
  Future<void> deleteByIdeaId(int ideaId) async {}

  @override
  Future<void> deleteCompletedTasks() async {}

  @override
  Future<AITaskEntity?> getActiveTaskByIdeaId(int ideaId) async => null;

  @override
  Future<AITaskEntity?> getLatestTaskByIdeaId(int ideaId) async => null;
}

class _FakeIdeaRepository implements IdeaRepository {
  @override
  Future<IdeaEntity> save(IdeaEntity idea) async => idea;

  @override
  Future<IdeaEntity?> getById(int id) async => null;

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

class _FakeAIAnalysisRepository implements AIAnalysisRepository {
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
  Future<void> deleteByIdeaId(int ideaId) async {}
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<CategoryEntity?> getById(int id) async => null;

  @override
  Future<CategoryEntity?> getByName(String name) async => null;

  @override
  Future<List<CategoryEntity>> getAll() async => [];

  @override
  Future<CategoryEntity> save(CategoryEntity category) async => category;

  @override
  Future<void> update(CategoryEntity category) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<int> count() async => 0;
}

class _FakeTagRepository implements TagRepository {
  @override
  Future<TagEntity?> getById(int id) async => null;

  @override
  Future<TagEntity?> getByName(String name) async => null;

  @override
  Future<List<TagEntity>> getAll() async => [];

  @override
  Future<List<TagEntity>> getByIds(List<int> ids) async => [];

  @override
  Future<TagEntity> save(TagEntity tag) async => tag;

  @override
  Future<List<TagEntity>> saveAll(List<String> names) async => [];

  @override
  Future<TagEntity> saveIfNotExists(String name) async => TagEntity(id: 1, name: name, createdAt: DateTime(2024, 1, 1));

  @override
  Future<int> count() async => 0;
}

class _FakeAssociationRepository implements AssociationRepository {
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
  Future<void> deleteByIdeaId(int ideaId) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<int> countByIdeaId(int ideaId) async => 0;

  @override
  Future<int> countByIdeaIdAndType(int ideaId, RelationType type) async => 0;
}

class _FakeLogger implements AppLogger {
  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {}
}
