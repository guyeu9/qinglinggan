import 'dart:async';
import 'dart:collection';
import '../../core/services/log_service.dart';
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
    logService.i('AITaskQueue', '========== enqueue() 开始 ==========');
    logService.i('AITaskQueue', '入队AI任务: ideaId=$ideaId, type=$taskType');
    _logger.info('入队AI任务: ideaId=$ideaId, type=$taskType');

    final activeTask = await _taskRepository.getActiveTaskByIdeaId(ideaId);
    if (activeTask != null) {
      logService.w('AITaskQueue', '任务已存在，跳过入队: ideaId=$ideaId, taskId=${activeTask.id}');
      _logger.info('任务已存在，跳过入队: ideaId=$ideaId, taskId=${activeTask.id}');
      return EnqueueResult.skipped('任务已在队列中', activeTask);
    }

    final latestTask = await _taskRepository.getLatestTaskByIdeaId(ideaId);
    if (latestTask != null &&
        latestTask.status == TaskStatus.completed &&
        latestTask.completedAt != null &&
        DateTime.now().difference(latestTask.completedAt!) < const Duration(hours: 24)) {
      logService.i('AITaskQueue', '任务最近已完成，跳过入队: ideaId=$ideaId');
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

    logService.i('AITaskQueue', '任务入队成功: ideaId=$ideaId, taskId=${savedTask.id}');
    logService.i('AITaskQueue', '当前队列长度: ${_queue.length}, isProcessing=$_isProcessing');
    _logger.info('任务入队成功: ideaId=$ideaId, taskId=${savedTask.id}');
    
    unawaited(_processNext());

    return EnqueueResult.enqueued(savedTask);
  }

  Future<void> _processNext() async {
    logService.d('AITaskQueue', '_processNext() 被调用: isProcessing=$_isProcessing, queue.length=${_queue.length}');
    
    if (_isProcessing) {
      logService.d('AITaskQueue', '已有任务在处理中，跳过');
      return;
    }
    if (_queue.isEmpty) {
      logService.d('AITaskQueue', '队列为空，跳过');
      return;
    }

    _isProcessing = true;
    final task = _queue.removeFirst();
    
    logService.i('AITaskQueue', '========== 开始处理任务 ==========');
    logService.i('AITaskQueue', '任务ID: ${task.id}, ideaId: ${task.ideaId}, type: ${task.taskType}');

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

      logService.i('AITaskQueue', 'AI任务完成: taskId=${task.id}, ideaId=${task.ideaId}');
      _logger.info('AI任务完成: taskId=${task.id}, ideaId=${task.ideaId}');
    } on TimeoutException catch (e) {
      logService.e('AITaskQueue', 'AI任务超时: taskId=${task.id}, 超时时间=${e.duration}');
      _logger.error('AI任务超时: taskId=${task.id}, 超时时间=${e.duration}');
      await _handleFailure(task, '任务执行超时: ${e.duration?.inSeconds ?? AppConstants.taskTimeoutSeconds}秒');
    } on AIException catch (e, st) {
      logService.e('AITaskQueue', 'AI任务失败(AI异常): taskId=${task.id}', error: e, stackTrace: st);
      _logger.error('AI任务失败(AI异常): taskId=${task.id}', e, st);
      await _handleFailure(task, 'AI错误: ${e.message}');
    } catch (e, st) {
      logService.e('AITaskQueue', 'AI任务失败: taskId=${task.id}', error: e, stackTrace: st);
      _logger.error('AI任务失败: taskId=${task.id}', e, st);
      await _handleFailure(task, e.toString());
    } finally {
      _isProcessing = false;
      logService.i('AITaskQueue', '========== 任务处理完成 ==========');
      unawaited(_processNext());
    }
  }

  Future<void> _processTask(AITaskEntity task) async {
    logService.i('AITaskQueue', '========== _processTask() 开始 ==========');
    logService.i('AITaskQueue', '处理任务: taskId=${task.id}, ideaId=${task.ideaId}');
    
    // 更新任务状态为处理中
    await _taskRepository.updateStatus(task.id, TaskStatus.processing);
    await _ideaRepository.updateAIStatus(task.ideaId, AIStatus.processing);
    logService.d('AITaskQueue', '任务状态已更新为processing');

    // 获取灵感内容
    final idea = await _ideaRepository.getById(task.ideaId);
    if (idea == null) {
      logService.e('AITaskQueue', '灵感不存在: ideaId=${task.ideaId}');
      throw Exception('灵感不存在: ${task.ideaId}');
    }
    logService.i('AITaskQueue', '获取到灵感: content="${idea.content.substring(0, idea.content.length > 50 ? 50 : idea.content.length)}..."');

    // 根据任务类型执行不同的分析
    logService.i('AITaskQueue', '开始执行${task.taskType}分析...');
    
    switch (task.taskType) {
      case TaskType.basicAnalysis:
        await _processBasicAnalysis(task, idea);
        break;
      case TaskType.relationAnalysis:
        await _processRelationAnalysis(task, idea);
        break;
      case TaskType.fullAnalysis:
        await _processBasicAnalysis(task, idea);
        await _processRelationAnalysis(task, idea);
        break;
    }
    
    logService.i('AITaskQueue', '========== _processTask() 完成 ==========');
  }

  Future<void> _processBasicAnalysis(AITaskEntity task, IdeaEntity idea) async {
    logService.i('AITaskQueue', '========== _processBasicAnalysis() 开始 ==========');
    logService.i('AITaskQueue', '开始基础分析: ideaId=${idea.id}, content="${idea.content.substring(0, idea.content.length > 30 ? 30 : idea.content.length)}..."');
    
    // 1. 理解分析
    logService.d('AITaskQueue', '步骤1: 调用AI理解服务...');
    final understandingResult = await _understandingService.analyze(idea.content);
    if (!understandingResult.isSuccess) {
      logService.e('AITaskQueue', 'AI理解失败');
      throw Exception('AI理解失败');
    }
    final understanding = understandingResult.dataOrNull!;
    logService.i('AITaskQueue', 'AI理解完成: summary="${understanding.summary}", tags=${understanding.tags}');

    // 2. 生成嵌入向量
    logService.d('AITaskQueue', '步骤2: 生成嵌入向量...');
    final embeddingResult = await _embeddingService.generateEmbedding(idea.content);
    if (!embeddingResult.isSuccess) {
      logService.e('AITaskQueue', '嵌入向量生成失败');
      throw Exception('嵌入向量生成失败');
    }
    final embedding = embeddingResult.dataOrNull!;
    logService.i('AITaskQueue', '嵌入向量生成完成: dimension=${embedding.length}');

    // 3. 保存分析结果
    logService.d('AITaskQueue', '步骤3: 保存分析结果...');
    final analysis = AIAnalysisEntity(
      id: 0,
      ideaId: idea.id,
      summary: understanding.summary,
      status: AnalysisStatus.processing,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final savedAnalysis = await _analysisRepository.save(analysis);
    logService.i('AITaskQueue', '分析结果已保存: analysisId=${savedAnalysis.id}');

    // 4. 处理标签
    logService.d('AITaskQueue', '步骤4: 处理标签...');
    final tagIds = <int>[];
    for (final tagName in understanding.tags) {
      final tag = await _tagRepository.saveIfNotExists(tagName);
      tagIds.add(tag.id);
      logService.d('AITaskQueue', '标签已保存/获取: $tagName (id=${tag.id})');
    }
    logService.i('AITaskQueue', '标签处理完成: 共${tagIds.length}个标签');

    // 5. 更新灵感
    logService.d('AITaskQueue', '步骤5: 更新灵感...');
    await _ideaRepository.updateEmbedding(idea.id, embedding);
    
    final latestIdea = await _ideaRepository.getById(idea.id);
    if (latestIdea != null) {
      final updatedIdea = latestIdea.copyWith(
        tagIds: tagIds,
      );
      await _ideaRepository.update(updatedIdea);
      logService.i('AITaskQueue', '灵感已更新: tagIds=$tagIds');
    } else {
      logService.w('AITaskQueue', '无法更新灵感: 灵感不存在 ideaId=${idea.id}');
    }

    // 6. 更新分析状态为完成
    logService.d('AITaskQueue', '步骤6: 更新分析状态为完成...');
    await _analysisRepository.updateStatus(savedAnalysis.id, AnalysisStatus.completed);
    logService.i('AITaskQueue', '========== _processBasicAnalysis() 完成 ==========');
  }

  Future<void> _processRelationAnalysis(AITaskEntity task, IdeaEntity idea) async {
    logService.i('AITaskQueue', '========== _processRelationAnalysis() 开始 ==========');
    logService.i('AITaskQueue', '开始关联分析: ideaId=${idea.id}');
    
    // TODO: 实现关联分析逻辑
    
    logService.i('AITaskQueue', '========== _processRelationAnalysis() 完成 ==========');
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
    
    // 更新前重新获取最新数据，避免覆盖用户修改
    final latestIdea = await _ideaRepository.getById(ideaId);
    if (latestIdea != null) {
      final updatedIdea = latestIdea.copyWith(
        categoryId: categoryId,
        tagIds: tagIds,
      );
      await _ideaRepository.update(updatedIdea);
      _logger.info('更新Idea: categoryId=$categoryId, tagIds=$tagIds');
    } else {
      _logger.warning('无法更新Idea: 灵感不存在 ideaId=$ideaId');
    }

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
