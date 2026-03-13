import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/idea.dart';
import 'app_providers.dart';

/// 侧边栏状态
class SidebarState {
  final int totalNotes;
  final Map<String, int> categoryCounts;
  final double aiAnalysisProgress;
  final bool isLoading;
  final String? error;

  const SidebarState({
    this.totalNotes = 0,
    this.categoryCounts = const {},
    this.aiAnalysisProgress = 0.0,
    this.isLoading = false,
    this.error,
  });

  SidebarState copyWith({
    int? totalNotes,
    Map<String, int>? categoryCounts,
    double? aiAnalysisProgress,
    bool? isLoading,
    String? error,
  }) {
    return SidebarState(
      totalNotes: totalNotes ?? this.totalNotes,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      aiAnalysisProgress: aiAnalysisProgress ?? this.aiAnalysisProgress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 侧边栏状态管理器
class SidebarNotifier extends StateNotifier<SidebarState> {
  final Ref _ref;

  SidebarNotifier(this._ref) : super(const SidebarState()) {
    loadStats();
  }

  /// 加载统计数据
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final categoryRepo = _ref.read(categoryRepositoryProvider);

      // 获取所有笔记（不包括已删除的）
      final ideas = await ideaRepo.getAll(includeDeleted: false);
      final categories = await categoryRepo.getAll();

      // 计算分类统计
      final categoryCounts = <String, int>{};
      for (final category in categories) {
        final count = ideas.where((idea) => idea.categoryId == category.id).length;
        categoryCounts[category.name] = count;
      }

      // 计算AI分析进度
      double progress = 0.0;
      if (ideas.isNotEmpty) {
        final completed = ideas.where((idea) => idea.aiStatus == AIStatus.completed).length;
        progress = completed / ideas.length;
      }

      state = state.copyWith(
        totalNotes: ideas.length,
        categoryCounts: categoryCounts,
        aiAnalysisProgress: progress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载统计数据失败: $e',
      );
    }
  }

  /// 运行AI分析
  Future<void> runAnalysis() async {
    try {
      final taskQueue = _ref.read(aiTaskQueueProvider);
      final ideaRepo = _ref.read(ideaRepositoryProvider);

      // 获取所有待分析的笔记
      final ideas = await ideaRepo.getAll(includeDeleted: false);
      final pendingIdeas = ideas.where((idea) => 
        idea.aiStatus == AIStatus.pending || idea.aiStatus == AIStatus.failed
      ).toList();

      // 为每个待分析的笔记创建任务
      for (final idea in pendingIdeas.take(5)) {
        await taskQueue.enqueue(idea.id);
      }

      // 重新加载统计
      await loadStats();
    } catch (e) {
      state = state.copyWith(error: '运行分析失败: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 侧边栏Provider
final sidebarProvider = StateNotifierProvider<SidebarNotifier, SidebarState>((ref) {
  return SidebarNotifier(ref);
});
