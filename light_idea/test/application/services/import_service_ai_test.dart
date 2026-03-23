import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/ai/ai_embedding_service.dart';
import 'package:light_idea/application/ai/ai_relation_service.dart';
import 'package:light_idea/application/ai/ai_synthesis_service.dart';
import 'package:light_idea/application/ai/ai_understanding_service.dart';
import 'package:light_idea/application/services/import_service.dart';
import 'package:light_idea/application/task_queue/ai_task_queue.dart';
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
  group('ImportService', () {
    late ImportService service;
    late _FakeIdeaRepository ideaRepository;
    late _FakeCategoryRepository categoryRepository;
    late _FakeTagRepository tagRepository;
    late _FakeTaskQueue taskQueue;
    late _FakeLogger logger;

    setUp(() {
      ideaRepository = _FakeIdeaRepository();
      categoryRepository = _FakeCategoryRepository();
      tagRepository = _FakeTagRepository();
      taskQueue = _FakeTaskQueue();
      logger = _FakeLogger();
      service = ImportService(
        ideaRepository: ideaRepository,
        categoryRepository: categoryRepository,
        tagRepository: tagRepository,
        aiTaskQueue: taskQueue,
        logger: logger,
      );
    });

    test('JSON 导入新灵感时应以 fullAnalysis + force:true 触发 AI', () async {
      final result = await service.importFromJson(
        '[{"content":"new idea"}]',
        triggerAIAnalysis: true,
      );

      expect(result.isSuccess, isTrue);
      expect(taskQueue.calls, hasLength(1));
      expect(taskQueue.calls.single.taskType, TaskType.fullAnalysis);
      expect(taskQueue.calls.single.force, isTrue);
    });

    test('JSON merge 导入已存在灵感时应以 fullAnalysis + force:true 触发 AI', () async {
      ideaRepository.ideaById[5] = IdeaEntity(
        id: 5,
        content: 'existing',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final result = await service.importFromJson(
        '[{"id":5,"content":"merged content"}]',
        strategy: ConflictStrategy.merge,
        triggerAIAnalysis: true,
      );

      expect(result.isSuccess, isTrue);
      expect(taskQueue.calls, hasLength(1));
      expect(taskQueue.calls.single.ideaId, 5);
      expect(taskQueue.calls.single.taskType, TaskType.fullAnalysis);
      expect(taskQueue.calls.single.force, isTrue);
    });

    test('AI 任务跳过时应记录错误并累加 skipCount', () async {
      taskQueue.enqueueResult = EnqueueResult.skipped('任务已在队列中');

      final result = await service.importFromJson(
        '[{"content":"skip idea"}]',
        triggerAIAnalysis: true,
      );

      expect(result.isSuccess, isTrue);
      final importResult = result.dataOrNull!;
      expect(importResult.successCount, 1);
      expect(importResult.skipCount, 1);
      expect(importResult.errorCount, 0);
      expect(importResult.errors.single, contains('AI任务未入队'));
    });
  });
}

class _EnqueueCall {
  final int ideaId;
  final TaskType taskType;
  final bool force;

  const _EnqueueCall({
    required this.ideaId,
    required this.taskType,
    required this.force,
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

  final List<_EnqueueCall> calls = [];
  EnqueueResult? enqueueResult;

  @override
  Future<EnqueueResult> enqueue(
    int ideaId, {
    TaskType taskType = TaskType.basicAnalysis,
    bool force = false,
  }) async {
    calls.add(_EnqueueCall(ideaId: ideaId, taskType: taskType, force: force));
    return enqueueResult ??
        EnqueueResult.enqueued(
          AITaskEntity(
            id: calls.length,
            ideaId: ideaId,
            taskType: taskType,
            status: TaskStatus.pending,
            createdAt: DateTime(2024, 1, 1),
          ),
        );
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

class _FakeIdeaRepository implements IdeaRepository {
  final Map<int, IdeaEntity> ideaById = {};
  int nextId = 100;

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async {
    final saved = idea.copyWith(id: idea.id > 0 ? idea.id : nextId++);
    ideaById[saved.id] = saved;
    return saved;
  }

  @override
  Future<IdeaEntity?> getById(int id) async => ideaById[id];

  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async => ideaById.values.toList();

  @override
  Future<List<IdeaEntity>> getByCategory(int categoryId) async => [];

  @override
  Future<List<IdeaEntity>> getByPage(int offset, int limit) async => [];

  @override
  Future<int> count({bool includeDeleted = false}) async => ideaById.length;

  @override
  Future<void> update(IdeaEntity idea) async {
    ideaById[idea.id] = idea;
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

class _FakeCategoryRepository implements CategoryRepository {
  int _nextId = 1;

  @override
  Future<CategoryEntity?> getById(int id) async => null;

  @override
  Future<CategoryEntity?> getByName(String name) async => null;

  @override
  Future<List<CategoryEntity>> getAll() async => [];

  @override
  Future<CategoryEntity> save(CategoryEntity category) async => category.copyWith(id: _nextId++);

  @override
  Future<void> update(CategoryEntity category) async {}

  @override
  Future<void> delete(int id) async {}

  @override
  Future<int> count() async => 0;
}

class _FakeTagRepository implements TagRepository {
  int _nextId = 1;

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
  Future<TagEntity> saveIfNotExists(String name) async => TagEntity(id: _nextId++, name: name, createdAt: DateTime(2024, 1, 1));

  @override
  Future<int> count() async => 0;
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
