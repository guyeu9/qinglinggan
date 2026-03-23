import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/ai_config.dart';
import '../../core/services/log_service.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/entities/category.dart';
import 'app_providers.dart';

class HomeState {
  final List<IdeaEntity> ideas;
  final List<CategoryEntity> categories;
  final int selectedCategoryIndex;
  final String searchQuery;
  final int? lastSavedIdeaId;
  final AIAnalysisEntity? lastAnalysis;
  final bool isSaving;
  final bool isAnalyzing;
  final String? error;
  final Map<int, List<String>> ideaTags;

  const HomeState({
    this.ideas = const [],
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.searchQuery = '',
    this.lastSavedIdeaId,
    this.lastAnalysis,
    this.isSaving = false,
    this.isAnalyzing = false,
    this.error,
    this.ideaTags = const {},
  });

  HomeState copyWith({
    List<IdeaEntity>? ideas,
    List<CategoryEntity>? categories,
    int? selectedCategoryIndex,
    String? searchQuery,
    int? lastSavedIdeaId,
    AIAnalysisEntity? lastAnalysis,
    bool? isSaving,
    bool? isAnalyzing,
    String? error,
    bool clearLastSaved = false,
    bool clearLastAnalysis = false,
    bool clearError = false,
    Map<int, List<String>>? ideaTags,
  }) {
    return HomeState(
      ideas: ideas ?? this.ideas,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      lastSavedIdeaId: clearLastSaved ? null : (lastSavedIdeaId ?? this.lastSavedIdeaId),
      lastAnalysis: clearLastAnalysis ? null : (lastAnalysis ?? this.lastAnalysis),
      isSaving: isSaving ?? this.isSaving,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: clearError ? null : (error ?? this.error),
      ideaTags: ideaTags ?? this.ideaTags,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  final Map<int, Timer> _pollingTimers = {};  // 改为Map存储，支持多个并发轮询
  final Set<int> _pollingIdeaIds = HashSet<int>();

  HomeNotifier(this._ref) : super(const HomeState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadCategories();
    await loadIdeas();
  }

  @override
  void dispose() {
    // 取消所有轮询
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();
    super.dispose();
  }

  Future<void> loadCategories() async {
    try {
      final categoryRepo = _ref.read(categoryRepositoryProvider);
      final categories = await categoryRepo.getAll();
      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(error: '加载分类失败: $e');
    }
  }

  Future<void> loadIdeas() async {
    logService.i('HomeProvider', '========== loadIdeas() 开始 ==========');
    logService.d('HomeProvider', 'selectedCategoryIndex: ${state.selectedCategoryIndex}');
    logService.d('HomeProvider', 'searchQuery: "${state.searchQuery}"');
    
    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      
      List<IdeaEntity> ideas;

      if (state.selectedCategoryIndex == 0) {
        // 时间轴 - 获取所有未删除的灵感
        logService.d('HomeProvider', '加载所有灵感 (时间轴)');
        ideas = await ideaRepo.getAll(includeDeleted: false);
      } else if (state.selectedCategoryIndex <= state.categories.length) {
        // 特定分类
        final category = state.categories[state.selectedCategoryIndex - 1];
        logService.d('HomeProvider', '加载分类 ${category.name} 的灵感');
        ideas = await ideaRepo.getByCategory(category.id);
      } else {
        ideas = [];
      }

      logService.i('HomeProvider', '从数据库获取到 ${ideas.length} 条灵感');

      // 搜索过滤
      if (state.searchQuery.isNotEmpty) {
        ideas = ideas.where((idea) {
          return idea.content.toLowerCase().contains(state.searchQuery.toLowerCase());
        }).toList();
        logService.d('HomeProvider', '搜索过滤后剩余 ${ideas.length} 条');
      }

      // 按创建时间倒序排序（最新的在前面）
      ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      logService.i('HomeProvider', '排序后共 ${ideas.length} 条');
      logService.i('HomeProvider', '========== loadIdeas() 完成 ==========');
      
      state = state.copyWith(ideas: ideas, ideaTags: {});
    } catch (e, stackTrace) {
      logService.e('HomeProvider', '加载灵感失败: $e', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '加载灵感失败: $e');
    }
  }

  Future<bool> saveIdea(String content, {List<String>? imagePaths}) async {
    if (content.trim().isEmpty && (imagePaths == null || imagePaths.isEmpty)) {
      state = state.copyWith(error: '内容不能为空');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    logService.i('HomeProvider', '开始保存灵感: content=$content');

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final taskQueue = _ref.read(aiTaskQueueProvider);

      final idea = IdeaEntity(
        id: 0,
        content: content.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        aiStatus: AIStatus.pending,
        tagIds: const [],
        imagePaths: imagePaths ?? const [],
      );

      logService.d('HomeProvider', '正在保存到数据库...');
      final savedIdea = await ideaRepo.save(idea);
      logService.i('HomeProvider', '灵感已保存: id=${savedIdea.id}');

      // 更新状态，不显示分析中状态（后台静默分析）
      state = state.copyWith(
        isSaving: false,
        lastSavedIdeaId: savedIdea.id,
        clearLastAnalysis: true,
      );

      // 立即加载列表，确保新数据被加载
      logService.d('HomeProvider', '正在重新加载列表...');
      await loadIdeas();
      logService.i('HomeProvider', '列表加载完成，当前共 ${state.ideas.length} 条');

      // 提交AI分析任务（后台静默执行）
      final enableAI = await AIConfig.getEnableAI();
      if (enableAI) {
        logService.d('HomeProvider', '提交AI分析任务（后台静默执行）');
        final enqueueResult = await taskQueue.enqueue(savedIdea.id);
        logService.d('HomeProvider', 'AI任务入队结果: wasSkipped=${enqueueResult.wasSkipped}');

        if (enqueueResult.wasEnqueued) {
          // 后台轮询分析结果，完成后自动刷新列表
          _pollAnalysisResultSilent(savedIdea.id);
        } else {
          logService.i('HomeProvider', 'AI任务未入队，跳过轮询: ideaId=${savedIdea.id}, reason=${enqueueResult.reason}');
        }
      } else {
        logService.i('HomeProvider', 'AI功能已禁用，跳过AI任务入队: ideaId=${savedIdea.id}');
      }

      return true;
    } catch (e, stackTrace) {
      logService.e('HomeProvider', '保存失败: $e', error: e, stackTrace: stackTrace);
      state = state.copyWith(isSaving: false, error: '保存失败: $e');
      return false;
    }
  }

  /// 后台静默轮询AI分析结果（不显示加载状态）
  /// 支持多个并发轮询，每个灵感有独立的轮询Timer
  void _pollAnalysisResultSilent(int ideaId) {
    if (_pollingIdeaIds.contains(ideaId)) {
      logService.d('HomeProvider', '轮询已存在，跳过重复启动: ideaId=$ideaId');
      return;
    }

    // 取消该ideaId的旧轮询（如果存在）
    _pollingTimers[ideaId]?.cancel();
    _pollingIdeaIds.add(ideaId);

    logService.d('HomeProvider', '开始后台静默轮询AI分析结果: ideaId=$ideaId, 当前轮询数=${_pollingTimers.length}');

    int attemptCount = 0;
    const maxAttempts = 120; // 2分钟超时

    _pollingTimers[ideaId] = Timer.periodic(const Duration(seconds: 2), (timer) async {
      attemptCount++;

      // 超时处理
      if (attemptCount > maxAttempts) {
        logService.w('HomeProvider', '后台轮询超时，停止轮询: ideaId=$ideaId');
        timer.cancel();
        _pollingTimers.remove(ideaId);
        _pollingIdeaIds.remove(ideaId);
        return;
      }

      try {
        final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
        final analysis = await analysisRepo.getByIdeaId(ideaId);

        if (analysis != null) {
          // 分析完成
          if (analysis.status == AnalysisStatus.completed) {
            logService.i('HomeProvider', '后台分析已完成，自动刷新列表: ideaId=$ideaId');
            timer.cancel();
            _pollingTimers.remove(ideaId);
            _pollingIdeaIds.remove(ideaId);
            // 静默刷新列表，显示更新后的标签
            // 使用 try-catch 防止组件销毁后调用异常
            try {
              await loadIdeas();
              logService.i('HomeProvider', '列表已自动刷新，显示最新标签');
            } catch (e) {
              // 组件可能已销毁，忽略此错误
              logService.d('HomeProvider', '刷新列表时组件可能已销毁: $e');
            }
            return;
          }
          // 分析失败
          else if (analysis.status == AnalysisStatus.failed) {
            logService.w('HomeProvider', '后台分析失败，停止轮询: ideaId=$ideaId');
            timer.cancel();
            _pollingTimers.remove(ideaId);
            _pollingIdeaIds.remove(ideaId);
            return;
          }
          // 分析中，继续轮询（静默，不显示任何UI）
          logService.d('HomeProvider', '轮询中: ideaId=$ideaId, attempt=$attemptCount, status=${analysis.status}');
        }
      } catch (e, stackTrace) {
        logService.e('HomeProvider', '后台轮询出错: ideaId=$ideaId, error=$e', error: e, stackTrace: stackTrace);
        timer.cancel();
        _pollingTimers.remove(ideaId);
        _pollingIdeaIds.remove(ideaId);
      }
    });
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
    loadIdeas();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    loadIdeas();
  }

  void clearLastAnalysis() {
    state = state.copyWith(clearLastAnalysis: true, clearLastSaved: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  
  Future<int?> createEmptyIdea() async {
    logService.d('HomeProvider', 'createEmptyIdea() 开始');
    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      
      final idea = IdeaEntity(
        id: 0,
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        aiStatus: AIStatus.pending,
        tagIds: const [],
        imagePaths: const [],
      );

      logService.d('HomeProvider', '正在保存空灵感...');
      final savedIdea = await ideaRepo.save(idea);
      logService.i('HomeProvider', '空灵感已保存: id=${savedIdea.id}');
      
      // 刷新列表显示新创建的灵感
      logService.d('HomeProvider', '刷新列表...');
      await loadIdeas();
      logService.i('HomeProvider', '列表刷新完成，当前共 ${state.ideas.length} 条');
      
      return savedIdea.id;
    } catch (e, stackTrace) {
      logService.e('HomeProvider', '创建灵感失败: $e', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '创建灵感失败: $e');
      return null;
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
