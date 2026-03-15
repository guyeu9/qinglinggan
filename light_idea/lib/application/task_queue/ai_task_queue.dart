import 'dart:async';
import 'dart:collection';
import '../../domain/entities/ai_task.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/association.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/ai_task_repository.dart';
import '../../domain/repositories/idea_repository.dart';
import '../../domain/repositories/ai_analysis_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/association_repository.dart';
import '../../core/logger/app_logger.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/ai_exceptions.dart';
import '../ai/ai_understanding_service.dart';
import '../ai/ai_embedding_service.dart';
import '../ai/ai_relation_service.dart';
import '../ai/ai_synthesis_service.dart';

enum EnqueueStatus { enqueued, skipped }

class EnqueueResult {
  final EnqueueStatus status;
  final AITaskEntity? task;
  final String? reason;

  const EnqueueResult._(this.status, this.task, [this.reason]);

  factory EnqueueResult.enqueued(AITaskEntity task) =>
      EnqueueResult._(EnqueueStatus.enqueued, task);

  factory EnqueueResult.skipped(String reason, [AITaskEntity? task]) =>
      EnqueueResult._(EnqueueStatus.skipped, task, reason);

  bool get wasEnqueued => status == EnqueueStatus.enqueued;
  bool get wasSkipped => status == EnqueueStatus.skipped;
}

class AITaskQueue {
  final Queue<AITaskEntity> _queue = Queue();
  final AIUnderstandingService _understandingService;
  final AIEmbeddingService _embeddingService;
  final AIRelationService _relationService;
  final AISynthesisService _synthesisService;
  final AITaskRepository _taskRepository;
  final IdeaRepository _ideaRepository;
  final AIAnalysisRepository _analysisRepository;
  final CategoryRepository _categoryRepository;
  final TagRepository _tagRepository;
  final AssociationRepository _associationRepository;
  final AppLogger _logger;

  bool _isProcessing = false;

  AITaskQueue({
    required AIUnderstandingService understandingService,
    required AIEmbeddingService embeddingService,
    required AIRelationService relationService,
    required AISynthesisService synthesisService,
    required AITaskRepository taskRepository,
    required IdeaRepository ideaRepository,
    required AIAnalysisRepository analysisRepository,
    required CategoryRepository categoryRepository,
    required TagRepository tagRepository,
    required AssociationRepository associationRepository,
    required AppLogger logger,
  })  : _understandingService = understandingService,
        _embeddingService = embeddingService,
        _relationService = relationService,
        _synthesisService = synthesisService,
        _taskRepository = taskRepository,
        _ideaRepository = ideaRepository,
        _analysisRepository = analysisRepository,
        _categoryRepository = categoryRepository,
        _tagRepository = tagRepository,
        _associationRepository = associationRepository,
        _logger = logger;

  Future<EnqueueResult> enqueue(int ideaId, {TaskType taskType = TaskType.basicAnalysis}) async {
    _logger.info('入队AI任务: ideaId=$ideaId, type=$taskType');

    final activeTask = await _taskRepository.getActiveTaskByIdeaId(ideaId);
    if (activeTask != null) {
      _logger.info('任务已存在，跳过入队: ideaId=$ideaId, taskId=${activeTask.id}');
      return EnqueueResult.skipped('任务已在队列中', activeTask);
    }

    final latestTask = await _taskRepository.getLatestTaskByIdeaId(ideaId);
    if (latestTask != null &&
        latestTask.status == TaskStatus.completed &&
        latestTask.completedAt != null &&
        DateTime.now().difference(latestTask.completedAt!) < const Duration(hours: 24)) {
      _logger.info('任务最近已完成，跳过入队: ideaId=$ideaId');
      return EnqueueResult.skipped('任务已在24小时内完成', latestTask);
    }

    final task = AITaskEntity(
      id: 0,
      ideaId: ideaId,
      taskType: taskType,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
    );

    final savedTask = await _taskRepository.save(task);
    _queue.add(savedTask);

    _logger.info('任务入队成功: ideaId=$ideaId, taskId=${savedTask.id}');
    unawaited(_processNext());

    return EnqueueResult.enqueued(savedTask);
  }

  Future<void> _processNext() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    final task = _queue.removeFirst();

    try {
      await _taskRepository.updateStatus(task.id, TaskStatus.processing);
      await _ideaRepository.updateAIStatus(task.ideaId, AIStatus.processing);

      await _runBasicAnalysis(task.ideaId).timeout(
        const Duration(seconds: AppConstants.taskTimeoutSeconds),
        onTimeout: () {
          throw TimeoutException(
            '任务执行超时',
            const Duration(seconds: AppConstants.taskTimeoutSeconds),
          );
        },
      );

      await _taskRepository.updateStatus(task.id, TaskStatus.completed);
      await _ideaRepository.updateAIStatus(task.ideaId, AIStatus.completed);

      _logger.info('AI任务完成: taskId=${task.id}, ideaId=${task.ideaId}');
    } on TimeoutException catch (e) {
      _logger.error('AI任务超时: taskId=${task.id}, 超时时间=${e.duration}');
      await _handleFailure(task, '任务执行超时: ${e.duration?.inSeconds ?? AppConstants.taskTimeoutSeconds}秒');
    } on AIException catch (e, st) {
      _logger.error('AI任务失败(AI异常): taskId=${task.id}', e, st);
      await _handleFailure(task, 'AI错误: ${e.message}');
    } catch (e, st) {
      _logger.error('AI任务失败: taskId=${task.id}', e, st);
      await _handleFailure(task, e.toString());
    } finally {
      _isProcessing = false;
      unawaited(_processNext());
    }
  }

  Future<void> _runBasicAnalysis(int ideaId) async {
    final idea = await _ideaRepository.getById(ideaId);
    if (idea == null) {
      throw Exception('灵感不存在: $ideaId');
    }

    final understandingResult = await _understandingService.analyze(idea.content);
    if (understandingResult.isError) {
      throw Exception(understandingResult.errorOrNull);
    }
    final understanding = understandingResult.dataOrNull!;

    final embeddingResult = await _embeddingService.generateEmbedding(idea.content);
    if (embeddingResult.isError) {
      throw Exception(embeddingResult.errorOrNull);
    }
    final embedding = embeddingResult.dataOrNull!;

    int? categoryId;
    final categories = await _categoryRepository.getAll();
    final categoryName = understanding.categoryName;
    
    for (final category in categories) {
      if (category.name == categoryName) {
        categoryId = category.id;
        break;
      }
    }
    
    if (categoryId == null && categoryName != null && categoryName.isNotEmpty) {
      for (final category in categories) {
        if (category.name.contains(categoryName) ||
            categoryName.contains(category.name)) {
          categoryId = category.id;
          _logger.info('分类模糊匹配: $categoryName -> ${category.name}');
          break;
        }
      }
    }
    
    if (categoryId == null && categoryName != null && categoryName.isNotEmpty) {
      final newCategory = CategoryEntity(
        id: 0,
        name: categoryName,
        icon: 'folder',
        sortOrder: categories.length,
        createdAt: DateTime.now(),
      );
      final savedCategory = await _categoryRepository.save(newCategory);
      categoryId = savedCategory.id;
      _logger.info('创建新分类: $categoryName (id=$categoryId)');
    }

    final tagIds = <int>[];
    for (final tagName in understanding.tags) {
      final tag = await _tagRepository.saveIfNotExists(tagName);
      tagIds.add(tag.id);
    }

    await _ideaRepository.updateEmbedding(ideaId, embedding);
    
    // 同时更新categoryId和tagIds到Idea表
    final updatedIdea = idea.copyWith(
      categoryId: categoryId,
      tagIds: tagIds,
    );
    await _ideaRepository.update(updatedIdea);
    _logger.info('更新Idea: categoryId=$categoryId, tagIds=$tagIds');

    List<AssociationEntity> savedAssociations = [];
    List<IdeaEntity> relatedIdeas = [];

    final searchResult = await _embeddingService.searchSimilar(
      embedding,
      topN: 5,
      threshold: 0.3,
    );

    if (searchResult.isSuccess && searchResult.dataOrNull!.isNotEmpty) {
      final candidates = searchResult.dataOrNull!
          .where((s) => s.idea.id != ideaId)
          .map((s) => s.idea)
          .toList();

      if (candidates.isNotEmpty) {
        final relationResult = await _relationService.judgeRelations(
          currentIdea: idea,
          candidates: candidates,
        );

        if (relationResult.isSuccess) {
          for (final association in relationResult.dataOrNull!) {
            await _associationRepository.save(association);
            savedAssociations.add(association);
            _logger.info('保存关联: ${association.sourceIdeaId} -> ${association.targetIdeaId}');
          }

          final candidateIds = savedAssociations.map((a) => a.targetIdeaId).toSet();
          relatedIdeas = candidates.where((c) => candidateIds.contains(c.id)).toList();
        }
      }
    }

    List<String> commonPoints = [];
    List<String> differences = [];
    String? mergedIdea;

    if (savedAssociations.isNotEmpty && relatedIdeas.isNotEmpty) {
      final synthesisResult = await _synthesisService.generateSynthesis(
        currentIdea: idea,
        associations: savedAssociations,
        relatedIdeas: relatedIdeas,
      );

      if (synthesisResult.isSuccess) {
        final output = synthesisResult.dataOrNull!;
        commonPoints = output.commonPoints;
        differences = output.differences;
        mergedIdea = output.mergedIdea.isEmpty ? null : output.mergedIdea;
        _logger.info('综合分析完成: 共同点=${commonPoints.length}, 差异点=${differences.length}');
      }
    }

    final analysis = AIAnalysisEntity(
      id: 0,
      ideaId: ideaId,
      categoryResult: categoryId,
      tagResults: tagIds,
      summary: understanding.summary,
      aiHint: understanding.aiHint,
      status: AnalysisStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      commonPoints: commonPoints,
      differences: differences,
      mergedIdea: mergedIdea,
    );
    await _analysisRepository.save(analysis);
  }

  Future<void> _handleFailure(AITaskEntity task, String errorMessage) async {
    await _taskRepository.incrementRetryCount(task.id);

    final updatedTask = await _taskRepository.getById(task.id);
    if (updatedTask == null) return;

    if (updatedTask.retryCount < AppConstants.maxRetryCount) {
      await _taskRepository.updateStatus(updatedTask.id, TaskStatus.pending, errorMessage: errorMessage);
      _queue.add(updatedTask.copyWith(status: TaskStatus.pending));
      _logger.info('AI任务将重试: taskId=${task.id}, retryCount=${updatedTask.retryCount}');
    } else {
      await _taskRepository.updateStatus(updatedTask.id, TaskStatus.failed, errorMessage: errorMessage);
      await _ideaRepository.updateAIStatus(task.ideaId, AIStatus.failed);
      _logger.warning('AI任务最终失败: taskId=${task.id}, retryCount=${updatedTask.retryCount}');
    }
  }

  Future<void> resumePendingTasks() async {
    _logger.info('恢复未完成的AI任务');

    final pendingTasks = await _taskRepository.getPendingTasks();
    final processingTasks = await _taskRepository.getProcessingTasks();

    for (final task in [...processingTasks, ...pendingTasks]) {
      _queue.add(task.copyWith(status: TaskStatus.pending));
    }

    unawaited(_processNext());
  }

  int get queueLength => _queue.length;

  bool get isProcessing => _isProcessing;

  Future<void> clearCompletedTasks() async {
    await _taskRepository.deleteCompletedTasks();
    _logger.info('已清理完成的AI任务');
  }
}
