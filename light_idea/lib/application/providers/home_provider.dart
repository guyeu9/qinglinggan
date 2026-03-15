import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/tag.dart';
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
    developer.log('开始加载灵感列表...', name: 'HomeProvider');
    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
      final tagRepo = _ref.read(tagRepositoryProvider);
      
      List<IdeaEntity> ideas;

      if (state.selectedCategoryIndex == 0) {
        // 时间轴 - 获取所有未删除的灵感
        developer.log('加载所有灵感 (时间轴)', name: 'HomeProvider');
        ideas = await ideaRepo.getAll(includeDeleted: false);
      } else if (state.selectedCategoryIndex <= state.categories.length) {
        // 特定分类
        final category = state.categories[state.selectedCategoryIndex - 1];
        developer.log('加载分类 ${category.name} 的灵感', name: 'HomeProvider');
        ideas = await ideaRepo.getByCategory(category.id);
      } else {
        ideas = [];
      }

      developer.log('从数据库获取到 ${ideas.length} 条灵感', name: 'HomeProvider');

      // 搜索过滤
      if (state.searchQuery.isNotEmpty) {
        ideas = ideas.where((idea) {
          return idea.content.toLowerCase().contains(state.searchQuery.toLowerCase());
        }).toList();
        developer.log('搜索过滤后剩余 ${ideas.length} 条', name: 'HomeProvider');
      }

      // 按创建时间倒序排序（最新的在前面）
      ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // 加载每个灵感的标签
      final Map<int, List<String>> ideaTagsMap = {};
      for (final idea in ideas) {
        // 首先检查Idea本身的tagIds
        if (idea.tagIds.isNotEmpty) {
          final tags = <String>[];
          for (final tagId in idea.tagIds) {
            final tag = await tagRepo.getById(tagId);
            if (tag != null) {
              tags.add(tag.name);
            }
          }
          if (tags.isNotEmpty) {
            ideaTagsMap[idea.id] = tags;
            developer.log('Idea ${idea.id} 有标签: $tags');
          }
        }
        
        // 如果Idea本身没有标签，尝试从分析结果获取
        if (!ideaTagsMap.containsKey(idea.id)) {
          final analysis = await analysisRepo.getByIdeaId(idea.id);
          if (analysis != null && analysis.tagResults.isNotEmpty) {
            final tags = <String>[];
            for (final tagId in analysis.tagResults) {
              final tag = await tagRepo.getById(tagId);
              if (tag != null) {
                tags.add(tag.name);
              }
            }
            if (tags.isNotEmpty) {
              ideaTagsMap[idea.id] = tags;
              developer.log('Idea ${idea.id} 从分析结果获取标签: $tags');
            }
          }
        }
      }
      
      developer.log('标签加载完成，共 ${ideaTagsMap.length} 条有标签', name: 'HomeProvider');
      developer.log('排序完成，更新状态: ${ideas.length} 条', name: 'HomeProvider');
      state = state.copyWith(ideas: ideas, ideaTags: ideaTagsMap);
    } catch (e, stackTrace) {
      developer.log('加载灵感失败: $e', name: 'HomeProvider', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: '加载灵感失败: $e');
    }
  }

  Future<bool> saveIdea(String content, {List<String>? imagePaths}) async {
    if (content.trim().isEmpty && (imagePaths == null || imagePaths.isEmpty)) {
      state = state.copyWith(error: '内容不能为空');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    developer.log('开始保存灵感: content=$content', name: 'HomeProvider');

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

      developer.log('正在保存到数据库...', name: 'HomeProvider');
      final savedIdea = await ideaRepo.save(idea);
      developer.log('灵感已保存: id=${savedIdea.id}', name: 'HomeProvider');

      // 更新状态，不显示分析中状态（后台静默分析）
      state = state.copyWith(
        isSaving: false,
        lastSavedIdeaId: savedIdea.id,
        clearLastAnalysis: true,
      );

      // 立即加载列表，确保新数据被加载
      developer.log('正在重新加载列表...', name: 'HomeProvider');
      await loadIdeas();
      developer.log('列表加载完成，当前共 ${state.ideas.length} 条', name: 'HomeProvider');

      // 提交AI分析任务（后台静默执行）
      developer.log('提交AI分析任务（后台静默执行）', name: 'HomeProvider');
      unawaited(taskQueue.enqueue(savedIdea.id).then((result) {
        developer.log('AI任务入队结果: wasSkipped=${result.wasSkipped}', name: 'HomeProvider');
        if (result.wasSkipped) {
          // 任务被跳过，可能已在队列中或已完成
        }
      }));

      // 后台轮询分析结果，完成后自动刷新列表
      _pollAnalysisResultSilent(savedIdea.id);

      return true;
    } catch (e, stackTrace) {
      developer.log('保存失败: $e', name: 'HomeProvider', error: e, stackTrace: stackTrace);
      state = state.copyWith(isSaving: false, error: '保存失败: $e');
      return false;
    }
  }

  /// 后台静默轮询AI分析结果（不显示加载状态）
  /// 支持多个并发轮询，每个灵感有独立的轮询Timer
  void _pollAnalysisResultSilent(int ideaId) {
    // 取消该ideaId的旧轮询（如果存在）
    _pollingTimers[ideaId]?.cancel();
    
    developer.log('开始后台静默轮询AI分析结果: ideaId=$ideaId, 当前轮询数=${_pollingTimers.length}', name: 'HomeProvider');

    int attemptCount = 0;
    const maxAttempts = 120; // 2分钟超时

    _pollingTimers[ideaId] = Timer.periodic(const Duration(seconds: 2), (timer) async {
      attemptCount++;

      // 超时处理
      if (attemptCount > maxAttempts) {
        developer.log('后台轮询超时，停止轮询: ideaId=$ideaId', name: 'HomeProvider');
        timer.cancel();
        _pollingTimers.remove(ideaId);
        return;
      }

      try {
        final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
        final analysis = await analysisRepo.getByIdeaId(ideaId);

        if (analysis != null) {
          // 分析完成
          if (analysis.status == AnalysisStatus.completed) {
            developer.log('后台分析已完成，自动刷新列表: ideaId=$ideaId', name: 'HomeProvider');
            timer.cancel();
            _pollingTimers.remove(ideaId);
            if (mounted) {
              // 静默刷新列表，显示更新后的标签
              await loadIdeas();
              developer.log('列表已自动刷新，显示最新标签', name: 'HomeProvider');
            }
            return;
          }
          // 分析失败
          else if (analysis.status == AnalysisStatus.failed) {
            developer.log('后台分析失败，停止轮询: ideaId=$ideaId', name: 'HomeProvider');
            timer.cancel();
            _pollingTimers.remove(ideaId);
            return;
          }
          // 分析中，继续轮询（静默，不显示任何UI）
          developer.log('轮询中: ideaId=$ideaId, attempt=$attemptCount, status=${analysis.status}', name: 'HomeProvider');
        }
      } catch (e, stackTrace) {
        developer.log('后台轮询出错: ideaId=$ideaId, error=$e', name: 'HomeProvider', error: e, stackTrace: stackTrace);
        timer.cancel();
        _pollingTimers.remove(ideaId);
      }
    });
  }

  /// 前台轮询AI分析结果（带加载状态，保留用于需要显示加载场景）
  void _pollAnalysisResult(int ideaId) {
    _pollAnalysisResultSilent(ideaId);
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

      final savedIdea = await ideaRepo.save(idea);
      return savedIdea.id;
    } catch (e) {
      state = state.copyWith(error: '创建灵感失败: $e');
      return null;
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});
