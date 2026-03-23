import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/ai/ai_embedding_service.dart';
import 'package:light_idea/application/ai/ai_relation_service.dart';
import 'package:light_idea/application/ai/ai_synthesis_service.dart';
import 'package:light_idea/application/ai/ai_understanding_service.dart';
import 'package:light_idea/application/task_queue/ai_task_queue.dart';
import 'package:light_idea/application/providers/app_providers.dart';
import 'package:light_idea/application/providers/idea_detail_provider.dart';
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
  group('IdeaDetailNotifier', () {
    late ProviderContainer container;
    late _FakeIdeaRepository ideaRepository;
    late _FakeAIAnalysisRepository analysisRepository;
    late _FakeAITaskRepository taskRepository;
    late _FakeTaskQueue taskQueue;
    late _FakeAssociationRepository associationRepository;
    late _FakeTagRepository tagRepository;
    late _FakeEmbeddingService embeddingService;

    setUp(() {
      ideaRepository = _FakeIdeaRepository();
      analysisRepository = _FakeAIAnalysisRepository();
      taskRepository = _FakeAITaskRepository();
      taskQueue = _FakeTaskQueue();
      associationRepository = _FakeAssociationRepository();
      tagRepository = _FakeTagRepository();
      embeddingService = _FakeEmbeddingService();

      container = ProviderContainer(
        overrides: [
          ideaRepositoryProvider.overrideWithValue(ideaRepository),
          aiAnalysisRepositoryProvider.overrideWithValue(analysisRepository),
          aiTaskRepositoryProvider.overrideWithValue(taskRepository),
          associationRepositoryProvider.overrideWithValue(associationRepository),
          tagRepositoryProvider.overrideWithValue(tagRepository),
          aiEmbeddingServiceProvider.overrideWithValue(embeddingService),
          aiTaskQueueProvider.overrideWithValue(taskQueue),
          categoryRepositoryProvider.overrideWithValue(_FakeCategoryRepository()),
          loggerProvider.overrideWithValue(_FakeLogger()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('`refreshAnalysis()` 应以 fullAnalysis + force:true 入队', () async {
      final notifier = container.read(ideaDetailProvider.notifier);
      final idea = _buildIdea();
      ideaRepository.idea = idea;
      notifier.state = notifier.state.copyWith(idea: idea);

      await notifier.refreshAnalysis();

      expect(taskQueue.lastIdeaId, idea.id);
      expect(taskQueue.lastTaskType, TaskType.fullAnalysis);
      expect(taskQueue.lastForce, isTrue);
    });

    test('`updateContent()` 内容未变化时不应删除分析或重建任务', () async {
      final notifier = container.read(ideaDetailProvider.notifier);
      final idea = _buildIdea(content: 'same content');
      notifier.state = notifier.state.copyWith(idea: idea);
      ideaRepository.idea = idea;

      final success = await notifier.updateContent('  same content  ');

      expect(success, isTrue);
      expect(taskQueue.lastIdeaId, isNull);
      expect(analysisRepository.deletedIdeaIds, isEmpty);
      expect(taskRepository.deletedIdeaIds, isEmpty);
      expect(ideaRepository.updatedIdeas, hasLength(1));
      expect(ideaRepository.updatedIdeas.single.content, 'same content');
    });

    test('`updateContent()` 内容变化时应清理旧数据并强制 fullAnalysis', () async {
      final notifier = container.read(ideaDetailProvider.notifier);
      final idea = _buildIdea(content: 'old content');
      notifier.state = notifier.state.copyWith(idea: idea);
      ideaRepository.idea = idea;

      final success = await notifier.updateContent('new content');

      expect(success, isTrue);
      expect(analysisRepository.deletedIdeaIds, [idea.id]);
      expect(taskRepository.deletedIdeaIds, [idea.id]);
      expect(taskQueue.lastIdeaId, idea.id);
      expect(taskQueue.lastTaskType, TaskType.fullAnalysis);
      expect(taskQueue.lastForce, isTrue);
      expect(ideaRepository.updatedStatusCalls, contains('${idea.id}:${AIStatus.pending.name}'));
      expect(ideaRepository.updatedIdeas.last.content, 'new content');
      expect(ideaRepository.updatedIdeas.last.contentHash, IdeaEntity.computeContentHash('new content'));
    });
  });
}

IdeaEntity _buildIdea({
  int id = 1,
  String content = 'original content',
}) {
  final now = DateTime(2024, 1, 1, 12);
  return IdeaEntity(
    id: id,
    content: content,
    createdAt: now,
    updatedAt: now,
  );
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

class _FakeIdeaRepository implements IdeaRepository {
  IdeaEntity? idea;
  final List<IdeaEntity> updatedIdeas = [];
  final List<String> updatedStatusCalls = [];

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async => idea;

  @override
  Future<IdeaEntity?> getById(int id) async => idea;

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
    this.idea = idea;
    updatedIdeas.add(idea);
  }

  @override
  Future<void> updateAIStatus(int id, AIStatus status) async {
    updatedStatusCalls.add('$id:${status.name}');
  }

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
  final List<int> deletedIdeaIds = [];

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
    deletedIdeaIds.add(ideaId);
  }
}

class _FakeAITaskRepository implements AITaskRepository {
  final List<int> deletedIdeaIds = [];

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
    deletedIdeaIds.add(ideaId);
  }

  @override
  Future<void> deleteCompletedTasks() async {}

  @override
  Future<AITaskEntity?> getActiveTaskByIdeaId(int ideaId) async => null;

  @override
  Future<AITaskEntity?> getLatestTaskByIdeaId(int ideaId) async => null;
}

class _FakeUnderstandingService extends AIUnderstandingService {
  _FakeUnderstandingService()
      : super(
          _FakeOpenAIClient(),
          _FakeCategoryRepository(),
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

class _FakeEmbeddingService extends AIEmbeddingService {
  _FakeEmbeddingService()
      : super(
          _FakeOpenAIClient(),
          _FakeIdeaRepository(),
          _FakeLogger(),
        );

  @override
  Future<Result<List<double>>> generateEmbedding(String text) async => Result.success(<double>[]);

  @override
  Future<Result<List<SimilarIdea>>> findSimilarIdeas(
    int currentIdeaId, {
    int topN = 10,
    double threshold = 0.3,
  }) async => Result.success(<SimilarIdea>[]);

  @override
  Future<Result<List<SimilarIdea>>> searchSimilar(
    List<double> queryEmbedding, {
    int topN = 10,
    double threshold = 0.3,
    int? excludeId,
  }) async => Result.success(<SimilarIdea>[]);
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
