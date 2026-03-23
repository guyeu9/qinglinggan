import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/ai/ai_embedding_service.dart';
import 'package:light_idea/application/ai/ai_relation_service.dart';
import 'package:light_idea/application/ai/ai_synthesis_service.dart';
import 'package:light_idea/application/ai/ai_understanding_service.dart';
import 'package:light_idea/application/task_queue/ai_task_queue.dart';
import 'package:light_idea/core/logger/app_logger.dart';
import 'package:light_idea/core/utils/result.dart';
import 'package:light_idea/data/api/api_models.dart';
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
  group('AITaskQueue', () {
    late _FakeUnderstandingService understandingService;
    late _FakeEmbeddingService embeddingService;
    late _FakeRelationService relationService;
    late _FakeSynthesisService synthesisService;
    late _FakeTaskRepository taskRepository;
    late _FakeIdeaRepository ideaRepository;
    late _FakeAnalysisRepository analysisRepository;
    late _FakeCategoryRepository categoryRepository;
    late _FakeTagRepository tagRepository;
    late _FakeAssociationRepository associationRepository;
    late AITaskQueue queue;

    setUp(() {
      understandingService = _FakeUnderstandingService();
      embeddingService = _FakeEmbeddingService();
      relationService = _FakeRelationService();
      synthesisService = _FakeSynthesisService();
      taskRepository = _FakeTaskRepository();
      ideaRepository = _FakeIdeaRepository();
      analysisRepository = _FakeAnalysisRepository();
      categoryRepository = _FakeCategoryRepository();
      tagRepository = _FakeTagRepository();
      associationRepository = _FakeAssociationRepository();
      queue = AITaskQueue(
        understandingService: understandingService,
        embeddingService: embeddingService,
        relationService: relationService,
        synthesisService: synthesisService,
        taskRepository: taskRepository,
        ideaRepository: ideaRepository,
        analysisRepository: analysisRepository,
        categoryRepository: categoryRepository,
        tagRepository: tagRepository,
        associationRepository: associationRepository,
        logger: _FakeLogger(),
      );
    });

    test('基础分析在快照失配时应丢弃写入并回退 AIStatus 为 pending', () async {
      final original = _buildIdea(content: 'original');
      ideaRepository.idea = original;
      ideaRepository.onGetById = () async {
        final current = ideaRepository.idea;
        if (current == null) return null;
        if (current.aiStatus == AIStatus.processing) {
          ideaRepository.idea = current.copyWith(
            content: 'changed content',
            updatedAt: current.updatedAt.add(const Duration(seconds: 1)),
          );
        }
        return ideaRepository.idea;
      };

      final result = await queue.enqueue(original.id);
      expect(result.wasEnqueued, isTrue);

      await _waitUntil(() => taskRepository.completedStatuses.contains(TaskStatus.completed));

      expect(analysisRepository.savedAnalyses, isEmpty);
      expect(ideaRepository.updatedStatusCalls, contains('${original.id}:${AIStatus.pending.name}'));
    });

    test('TaskType.fullAnalysis 应串行完成基础分析与关联分析', () async {
      final original = _buildIdea(content: 'full analysis');
      ideaRepository.idea = original;
      relationService.relations = [
        AssociationEntity(
          id: 1,
          sourceIdeaId: original.id,
          targetIdeaId: 2,
          type: RelationType.similar,
          reason: '主题接近',
          confidence: 0.95,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      embeddingService.searchResult = [
        SimilarIdea(
          idea: _buildIdea(id: 2, content: 'candidate', embedding: <double>[0.3, 0.4]),
          similarity: 0.91,
        ),
      ];

      final result = await queue.enqueue(
        original.id,
        taskType: TaskType.fullAnalysis,
        force: true,
      );
      expect(result.wasEnqueued, isTrue);

      await _waitUntil(() => taskRepository.completedStatuses.contains(TaskStatus.completed));

      expect(analysisRepository.savedAnalyses, hasLength(1));
      expect(analysisRepository.updatedAnalyses, hasLength(1));
      expect(analysisRepository.updatedAnalyses.single.tagResults, [1]);
      expect(associationRepository.savedAssociations, hasLength(1));
      expect(associationRepository.savedAssociations.single.targetIdeaId, 2);
      expect(ideaRepository.idea?.embedding, <double>[0.1, 0.2, 0.3]);
      expect(ideaRepository.idea?.tagIds, [1]);
      expect(ideaRepository.idea?.aiStatus, AIStatus.completed);
      expect(taskRepository.statusHistory, containsAllInOrder([TaskStatus.processing, TaskStatus.completed]));
      expect(taskRepository.tasks.single.taskType, TaskType.fullAnalysis);
    });

    test('TaskType.fullAnalysis 在基础分析失败且不可重试时不应继续执行关联分析', () async {
      final original = _buildIdea(content: 'unauthorized analysis');
      ideaRepository.idea = original;
      understandingService.analyzeHandler = (_) async => Result.error('401 unauthorized');
      relationService.relations = [
        AssociationEntity(
          id: 1,
          sourceIdeaId: original.id,
          targetIdeaId: 2,
          type: RelationType.similar,
          reason: '不应被保存',
          confidence: 0.9,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      embeddingService.searchResult = [
        SimilarIdea(
          idea: _buildIdea(id: 2, content: 'candidate', embedding: <double>[0.3, 0.4]),
          similarity: 0.91,
        ),
      ];

      final result = await queue.enqueue(
        original.id,
        taskType: TaskType.fullAnalysis,
        force: true,
      );
      expect(result.wasEnqueued, isTrue);

      await _waitUntil(() => taskRepository.statusHistory.contains(TaskStatus.failed));

      expect(associationRepository.savedAssociations, isEmpty);
      expect(analysisRepository.savedAnalyses, isEmpty);
      expect(taskRepository.statusHistory, containsAllInOrder([TaskStatus.processing, TaskStatus.failed]));
      expect(ideaRepository.updatedStatusCalls, contains('${original.id}:${AIStatus.failed.name}'));
    });

    test('关联分析在保存前快照失配时应丢弃关联写入', () async {
      final original = _buildIdea(
        content: 'idea',
        embedding: <double>[0.1, 0.2],
      );
      ideaRepository.idea = original;
      associationRepository.savedAssociations.clear();
      relationService.relations = [
        AssociationEntity(
          id: 1,
          sourceIdeaId: original.id,
          targetIdeaId: 2,
          type: RelationType.similar,
          reason: '相似主题',
          confidence: 0.9,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      embeddingService.searchResult = [
        SimilarIdea(
          idea: _buildIdea(id: 2, content: 'candidate', embedding: <double>[0.3, 0.4]),
          similarity: 0.88,
        ),
      ];

      var getByIdCount = 0;
      ideaRepository.onGetById = () async {
        getByIdCount++;
        final current = ideaRepository.idea;
        if (current == null) return null;
        if (getByIdCount == 3) {
          ideaRepository.idea = current.copyWith(
            content: 'mutated before save',
            updatedAt: current.updatedAt.add(const Duration(seconds: 1)),
          );
        }
        return ideaRepository.idea;
      };

      final result = await queue.enqueue(
        original.id,
        taskType: TaskType.relationAnalysis,
        force: true,
      );
      expect(result.wasEnqueued, isTrue);

      await _waitUntil(() => taskRepository.completedStatuses.contains(TaskStatus.completed));

      expect(associationRepository.savedAssociations, isEmpty);
    });

    test('可重试失败应回退任务为 pending 且不将 AIStatus 置为 failed', () async {
      final original = _buildIdea(content: 'retry path');
      ideaRepository.idea = original;
      understandingService.analyzeHandler = (_) async => Result.error('temporary error');

      final result = await queue.enqueue(original.id);
      expect(result.wasEnqueued, isTrue);

      await _waitUntil(() => taskRepository.statusHistory.contains(TaskStatus.pending));

      expect(taskRepository.retryCounts[result.task!.id], 1);
      expect(taskRepository.statusHistory, containsAllInOrder([TaskStatus.processing, TaskStatus.pending]));
      expect(taskRepository.errorMessages[result.task!.id], 'Exception: AI理解失败: temporary error');
      expect(ideaRepository.updatedStatusCalls, isNot(contains('${original.id}:${AIStatus.failed.name}')));
      expect(ideaRepository.idea?.aiStatus, AIStatus.processing);
    });

    test('超过最大重试次数后应将任务与 AIStatus 标记为 failed', () async {
      final original = _buildIdea(content: 'final failure');
      ideaRepository.idea = original;
      understandingService.analyzeHandler = (_) async => Result.error('temporary error');
      taskRepository.initialRetryCount = 2;

      final result = await queue.enqueue(original.id);
      expect(result.wasEnqueued, isTrue);

      await _waitUntil(() => taskRepository.statusHistory.contains(TaskStatus.failed));

      expect(taskRepository.retryCounts[result.task!.id], 3);
      expect(taskRepository.statusHistory, containsAllInOrder([TaskStatus.processing, TaskStatus.failed]));
      expect(taskRepository.errorMessages[result.task!.id], 'Exception: AI理解失败: temporary error');
      expect(ideaRepository.updatedStatusCalls, contains('${original.id}:${AIStatus.failed.name}'));
      expect(ideaRepository.idea?.aiStatus, AIStatus.failed);
    });
  });
}

IdeaEntity _buildIdea({
  int id = 1,
  required String content,
  List<double>? embedding,
}) {
  final now = DateTime(2024, 1, 1, 12);
  return IdeaEntity(
    id: id,
    content: content,
    createdAt: now,
    updatedAt: now,
    embedding: embedding,
    aiStatus: AIStatus.pending,
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('等待异步队列处理超时');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

class _FakeUnderstandingService extends AIUnderstandingService {
  _FakeUnderstandingService()
      : super(
          _FakeOpenAIClient(),
          _FakeCategoryRepository(),
          _FakeLogger(),
        );

  Future<Result<AIAnalysisResult>> Function(String text)? analyzeHandler;

  @override
  Future<Result<AIAnalysisResult>> analyze(String text) async {
    if (analyzeHandler != null) {
      return analyzeHandler!(text);
    }
    return Result.success(
      const AIAnalysisResult(
        categoryName: '分类',
        tags: <String>['标签1'],
        summary: '总结',
        aiHint: '提示',
      ),
    );
  }
}

class _FakeEmbeddingService extends AIEmbeddingService {
  _FakeEmbeddingService()
      : super(
          _FakeOpenAIClient(),
          _FakeIdeaRepository(),
          _FakeLogger(),
        );

  List<SimilarIdea> searchResult = [];

  @override
  Future<Result<List<double>>> generateEmbedding(String text) async {
    return Result.success(<double>[0.1, 0.2, 0.3]);
  }

  @override
  Future<Result<List<SimilarIdea>>> findSimilarIdeas(
    int currentIdeaId, {
    int topN = 10,
    double threshold = 0.3,
  }) async {
    return Result.success(<SimilarIdea>[]);
  }

  @override
  Future<Result<List<SimilarIdea>>> searchSimilar(
    List<double> queryEmbedding, {
    int topN = 10,
    double threshold = 0.3,
    int? excludeId,
  }) async {
    return Result.success(searchResult);
  }
}

class _FakeRelationService implements AIRelationService {
  List<AssociationEntity> relations = [];

  @override
  Future<Result<List<AssociationEntity>>> judgeRelations({
    required IdeaEntity currentIdea,
    required List<IdeaEntity> candidates,
  }) async {
    return Result.success(relations);
  }
}

class _FakeSynthesisService extends AISynthesisService {
  _FakeSynthesisService()
      : super(
          _FakeOpenAIClient(),
          _FakeLogger(),
        );

  @override
  Future<Result<SynthesisOutput>> generateSynthesis({
    required IdeaEntity currentIdea,
    required List<AssociationEntity> associations,
    required List<IdeaEntity> relatedIdeas,
  }) async {
    return Result.success(
      const SynthesisOutput(
        commonPoints: <String>[],
        differences: <String>[],
        mergedIdea: '',
      ),
    );
  }
}

class _FakeTaskRepository implements AITaskRepository {
  final List<AITaskEntity> tasks = [];
  final List<TaskStatus> completedStatuses = [];
  final List<TaskStatus> statusHistory = [];
  final Map<int, String?> errorMessages = {};
  final Map<int, int> retryCounts = {};
  int initialRetryCount = 0;

  @override
  Future<AITaskEntity> save(AITaskEntity task) async {
    final saved = task.copyWith(
      id: tasks.length + 1,
      retryCount: initialRetryCount,
    );
    tasks.add(saved);
    retryCounts[saved.id] = saved.retryCount;
    return saved;
  }

  @override
  Future<AITaskEntity?> getById(int id) async {
    return tasks.cast<AITaskEntity?>().firstWhere((task) => task?.id == id, orElse: () => null);
  }

  @override
  Future<AITaskEntity?> getByIdeaId(int ideaId) async {
    return tasks.cast<AITaskEntity?>().firstWhere((task) => task?.ideaId == ideaId, orElse: () => null);
  }

  @override
  Future<List<AITaskEntity>> getPendingTasks() async => [];

  @override
  Future<List<AITaskEntity>> getProcessingTasks() async => [];

  @override
  Future<void> update(AITaskEntity task) async {
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
      retryCounts[task.id] = task.retryCount;
    }
  }

  @override
  Future<void> updateStatus(int id, TaskStatus status, {String? errorMessage}) async {
    completedStatuses.add(status);
    statusHistory.add(status);
    final index = tasks.indexWhere((task) => task.id == id);
    if (index >= 0) {
      final current = tasks[index];
      tasks[index] = current.copyWith(
        status: status,
        errorMessage: errorMessage ?? current.errorMessage,
        completedAt: status == TaskStatus.completed ? DateTime.now() : current.completedAt,
      );
      errorMessages[id] = tasks[index].errorMessage;
      retryCounts[id] = tasks[index].retryCount;
    }
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index >= 0) {
      final updated = tasks[index].copyWith(retryCount: tasks[index].retryCount + 1);
      tasks[index] = updated;
      retryCounts[id] = updated.retryCount;
    }
  }

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
  IdeaEntity? idea;
  Future<IdeaEntity?> Function()? onGetById;
  final List<String> updatedStatusCalls = [];

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async => idea;

  @override
  Future<IdeaEntity?> getById(int id) async {
    if (onGetById != null) {
      return onGetById!();
    }
    return idea;
  }

  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async => idea == null ? [] : [idea!];

  @override
  Future<List<IdeaEntity>> getByCategory(int categoryId) async => [];

  @override
  Future<List<IdeaEntity>> getByPage(int offset, int limit) async => [];

  @override
  Future<int> count({bool includeDeleted = false}) async => idea == null ? 0 : 1;

  @override
  Future<void> update(IdeaEntity idea) async {
    this.idea = idea;
  }

  @override
  Future<void> updateAIStatus(int id, AIStatus status) async {
    updatedStatusCalls.add('$id:${status.name}');
    final current = idea;
    if (current != null && current.id == id) {
      idea = current.copyWith(aiStatus: status);
    }
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

class _FakeAnalysisRepository implements AIAnalysisRepository {
  final List<AIAnalysisEntity> savedAnalyses = [];
  final List<AIAnalysisEntity> updatedAnalyses = [];

  @override
  Future<AIAnalysisEntity> save(AIAnalysisEntity analysis) async {
    savedAnalyses.add(analysis);
    return analysis.copyWith(id: savedAnalyses.length);
  }

  @override
  Future<AIAnalysisEntity?> getById(int id) async => null;

  @override
  Future<AIAnalysisEntity?> getByIdeaId(int ideaId) async => null;

  @override
  Future<List<AIAnalysisEntity>> getAll() async => savedAnalyses;

  @override
  Future<void> update(AIAnalysisEntity analysis) async {
    updatedAnalyses.add(analysis);
  }

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
  final List<AssociationEntity> savedAssociations = [];

  @override
  Future<AssociationEntity> save(AssociationEntity association) async {
    savedAssociations.add(association);
    return association;
  }

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

class _FakeOpenAIClient extends OpenAIClient {
  _FakeOpenAIClient() : super(baseUrl: 'https://example.com');
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
