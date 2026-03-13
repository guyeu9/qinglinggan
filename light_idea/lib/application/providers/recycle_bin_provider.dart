import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

/// 回收站项目
class RecycleBinItem {
  final int id;
  final String content;
  final String? categoryName;
  final DateTime deletedAt;
  final int daysRemaining;

  const RecycleBinItem({
    required this.id,
    required this.content,
    this.categoryName,
    required this.deletedAt,
    required this.daysRemaining,
  });
}

/// 回收站状态
class RecycleBinState {
  final List<RecycleBinItem> items;
  final bool isLoading;
  final String? error;

  const RecycleBinState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  RecycleBinState copyWith({
    List<RecycleBinItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return RecycleBinState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 回收站状态管理器
class RecycleBinNotifier extends StateNotifier<RecycleBinState> {
  final Ref _ref;
  static const int _retentionDays = 30;

  RecycleBinNotifier(this._ref) : super(const RecycleBinState()) {
    loadDeletedItems();
  }

  /// 加载已删除的项目
  Future<void> loadDeletedItems() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final categoryRepo = _ref.read(categoryRepositoryProvider);

      // 获取所有已删除的笔记
      final deletedIdeas = await ideaRepo.getDeleted();
      final categories = await categoryRepo.getAll();

      final now = DateTime.now();
      final items = deletedIdeas.map((idea) {
        final category = categories.where((c) => c.id == idea.categoryId).firstOrNull;
        final daysSinceDeleted = now.difference(idea.deletedAt!).inDays;
        final daysRemaining = _retentionDays - daysSinceDeleted;

        return RecycleBinItem(
          id: idea.id,
          content: idea.content,
          categoryName: category?.name,
          deletedAt: idea.deletedAt!,
          daysRemaining: daysRemaining.clamp(0, _retentionDays),
        );
      }).toList();

      // 按删除时间排序（最新的在前）
      items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));

      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载回收站失败: $e',
      );
    }
  }

  /// 恢复项目
  Future<bool> restoreItem(int id) async {
    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      await ideaRepo.restore(id);

      // 重新加载列表
      await loadDeletedItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: '恢复失败: $e');
      return false;
    }
  }

  /// 彻底删除项目
  Future<bool> permanentDelete(int id) async {
    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      await ideaRepo.permanentDelete(id);

      // 重新加载列表
      await loadDeletedItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: '删除失败: $e');
      return false;
    }
  }

  /// 清空回收站
  Future<bool> clearAll() async {
    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      await ideaRepo.clearDeleted();

      // 重新加载列表
      await loadDeletedItems();
      return true;
    } catch (e) {
      state = state.copyWith(error: '清空失败: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 回收站Provider
final recycleBinProvider = StateNotifierProvider<RecycleBinNotifier, RecycleBinState>((ref) {
  return RecycleBinNotifier(ref);
});
