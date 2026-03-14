import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref _ref;
  Timer? _pollingTimer;

  HomeNotifier(this._ref) : super(const HomeState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadCategories();
    await loadIdeas();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      List<IdeaEntity> ideas;

      if (state.selectedCategoryIndex == 0) {
        ideas = await ideaRepo.getAll(includeDeleted: false);
      } else if (state.selectedCategoryIndex <= state.categories.length) {
        final category = state.categories[state.selectedCategoryIndex - 1];
        ideas = await ideaRepo.getByCategory(category.id);
      } else {
        ideas = [];
      }

      if (state.searchQuery.isNotEmpty) {
        ideas = ideas.where((idea) {
          return idea.content.toLowerCase().contains(state.searchQuery.toLowerCase());
        }).toList();
      }

      ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(ideas: ideas);
    } catch (e) {
      state = state.copyWith(error: '加载灵感失败: $e');
    }
  }

  Future<bool> saveIdea(String content, {List<String>? imagePaths}) async {
    if (content.trim().isEmpty && (imagePaths == null || imagePaths.isEmpty)) {
      state = state.copyWith(error: '内容不能为空');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

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

      final savedIdea = await ideaRepo.save(idea);

      state = state.copyWith(
        isSaving: false,
        lastSavedIdeaId: savedIdea.id,
        isAnalyzing: true,
      );

      await loadIdeas();

      unawaited(taskQueue.enqueue(savedIdea.id).then((result) {
        if (result.wasSkipped) {
          // 任务被跳过，可能已在队列中或已完成
        }
      }));

      _pollAnalysisResult(savedIdea.id);

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '保存失败: $e');
      return false;
    }
  }

  void _pollAnalysisResult(int ideaId) {
    _pollingTimer?.cancel();

    int attemptCount = 0;
    const maxAttempts = 30;

    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      attemptCount++;

      if (attemptCount > maxAttempts) {
        timer.cancel();
        state = state.copyWith(isAnalyzing: false);
        return;
      }

      try {
        final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
        final analysis = await analysisRepo.getByIdeaId(ideaId);

        if (analysis != null && analysis.status == AnalysisStatus.completed) {
          timer.cancel();
          state = state.copyWith(
            lastAnalysis: analysis,
            isAnalyzing: false,
          );
        }
      } catch (e) {
        timer.cancel();
        state = state.copyWith(isAnalyzing: false);
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
