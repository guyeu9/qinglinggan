import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../application/providers/recycle_bin_provider.dart';

/// 回收站页面
///
/// 严格按照原型图实现:
/// d:\trae\qinglinggan\前端原型图\4回收站\code.html
///
/// 颜色定义:
/// - primary: #39E079 (与首页略有不同)
/// - text-core: #065F46
/// - background-light: #f6f8f7
/// - background-dark: #122017
/// - accent-sky: #BAE6FD
/// - warning: #ef4444
class RecycleBinPage extends ConsumerStatefulWidget {
  const RecycleBinPage({super.key});

  @override
  ConsumerState<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends ConsumerState<RecycleBinPage> {
  void _goBack() {
    context.pop();
  }

  void _showClearAllDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF122017) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '清空回收站',
          style: TextStyle(
            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '确定要清空回收站吗？此操作将永久删除所有内容，无法恢复。',
          style: TextStyle(
            color: isDark
                ? const Color(0xFF6EE7B7).withValues(alpha: 0.8)
                : const Color(0xFF065F46).withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
                    : const Color(0xFF065F46).withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAll() async {
    final success = await ref.read(recycleBinProvider.notifier).clearAll();
    if (success && mounted) {
      HapticFeedback.mediumImpact();
      _showSnackBar('回收站已清空');
    }
  }

  void _showDeleteConfirmDialog(RecycleBinItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF122017) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          '彻底删除',
          style: TextStyle(
            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '确定要彻底删除这条灵感吗？此操作不可恢复。',
          style: TextStyle(
            color: isDark
                ? const Color(0xFF6EE7B7).withValues(alpha: 0.8)
                : const Color(0xFF065F46).withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
                    : const Color(0xFF065F46).withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentlyDelete(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _permanentlyDelete(RecycleBinItem item) async {
    final success = await ref.read(recycleBinProvider.notifier).permanentDelete(item.id);
    if (success && mounted) {
      HapticFeedback.mediumImpact();
      _showSnackBar('已彻底删除');
    }
  }

  Future<void> _restoreItem(RecycleBinItem item) async {
    final success = await ref.read(recycleBinProvider.notifier).restoreItem(item.id);
    if (success && mounted) {
      HapticFeedback.mediumImpact();
      _showSnackBar('灵感已恢复');
    }
  }

  void _showSnackBar(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? const Color(0xFF065F46) : const Color(0xFF065F46),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recycleBinState = ref.watch(recycleBinProvider);

    // 严格使用原型图颜色
    final backgroundColor = isDark ? const Color(0xFF122017) : const Color(0xFFf6f8f7);
    final textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(isDark, textColor, recycleBinState.items.isNotEmpty),

            // 提示信息栏
            _buildInfoBanner(isDark, textColor),

            // 灵感列表
            Expanded(
              child: recycleBinState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recycleBinState.items.isEmpty
                      ? _buildEmptyState(isDark, textColor)
                      : _buildContentList(recycleBinState, isDark, textColor),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部导航栏
  ///
  /// 原型图代码:
  /// ```html
  /// <header class="sticky top-0 z-10 flex items-center bg-background-light/80 dark:bg-background-dark/80 backdrop-blur-md p-4 border-b border-primary/20 justify-between">
  ///   <button class="flex size-10 items-center justify-center rounded-full hover:bg-primary/10 transition-colors">
  ///     <span class="material-symbols-outlined text-text-core dark:text-emerald-300">arrow_back</span>
  ///   </button>
  ///   <h2 class="text-lg font-bold leading-tight tracking-tight flex-1 text-center text-text-core dark:text-emerald-50">回收站</h2>
  ///   <div class="flex w-10 items-center justify-end">
  ///     <button class="text-warning text-sm font-bold hover:opacity-80 transition-opacity">清空</button>
  ///   </div>
  /// </header>
  /// ```
  Widget _buildAppBar(bool isDark, Color textColor, bool canClear) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF122017).withValues(alpha: 0.8)
            : const Color(0xFFf6f8f7).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF39E079).withValues(alpha: 0.2),
          ),
        ),
      ),
      child: ClipRect(
        child: Row(
          children: [
            // 返回按钮
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goBack,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Icon(
                    Symbols.arrow_back,
                    color: textColor,
                    size: 24,
                  ),
                ),
              ),
            ),

            // 标题
            Expanded(
              child: Text(
                '回收站',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // 清空按钮
            SizedBox(
              width: 40,
              child: canClear
                  ? TextButton(
                      onPressed: _showClearAllDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '清空',
                        style: TextStyle(
                          color: Color(0xFFef4444),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 提示信息栏
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="px-4 py-3">
  ///   <div class="flex items-center gap-3 rounded-xl bg-primary/10 dark:bg-primary/20 p-4 border border-primary/20">
  ///     <span class="material-symbols-outlined text-text-core dark:text-primary text-xl">info</span>
  ///     <p class="text-sm font-medium text-text-core/80 dark:text-emerald-200">内容将在 30 天后自动彻底删除</p>
  ///   </div>
  /// </div>
  /// ```
  Widget _buildInfoBanner(bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF39E079).withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF39E079).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.info,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '内容将在 30 天后自动彻底删除',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF6EE7B7).withValues(alpha: 0.9)
                    : const Color(0xFF065F46).withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 内容列表
  Widget _buildContentList(RecycleBinState state, bool isDark, Color textColor) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _RecycleBinCard(
          item: item,
          isDark: isDark,
          onRestore: () => _restoreItem(item),
          onDelete: () => _showDeleteConfirmDialog(item),
        );
      },
    );
  }

  /// 空状态
  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.delete_outline,
            size: 64,
            color: textColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '回收站是空的',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '删除的灵感会在这里显示',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 回收站卡片组件
///
/// 原型图代码:
/// ```html
/// <div class="group flex flex-col gap-3 rounded-xl bg-white dark:bg-emerald-900/30 p-4 shadow-sm border border-emerald-100 dark:border-emerald-800/50">
///   <div class="flex justify-between items-start">
///     <span class="text-xs font-semibold text-text-core bg-accent-sky/40 dark:bg-accent-sky/20 px-2 py-1 rounded"># 设计灵感</span>
///     <span class="text-xs text-emerald-600/60 dark:text-emerald-400/60">23天后删除</span>
///   </div>
///   <p class="text-base font-medium leading-relaxed text-text-core dark:text-emerald-50">...</p>
///   <div class="h-[1px] w-full bg-emerald-50 dark:bg-emerald-800/50 my-1"></div>
///   <div class="flex items-center justify-between">
///     <p class="text-xs text-emerald-600/60 dark:text-emerald-400/60">删除于：2023-10-27 14:30</p>
///     <div class="flex gap-2">
///       <button class="flex h-8 items-center justify-center rounded-lg px-3 bg-emerald-50 dark:bg-emerald-800 text-warning text-xs font-bold hover:bg-emerald-100 dark:hover:bg-emerald-700 transition-colors">彻底删除</button>
///       <button class="flex h-8 items-center justify-center rounded-lg px-4 bg-primary text-text-core text-xs font-bold hover:opacity-90 transition-opacity">恢复</button>
///     </div>
///   </div>
/// </div>
/// ```
class _RecycleBinCard extends StatelessWidget {
  final RecycleBinItem item;
  final bool isDark;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _RecycleBinCard({
    required this.item,
    required this.isDark,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
    final secondaryTextColor = isDark
        ? const Color(0xFF6EE7B7).withValues(alpha: 0.6)
        : const Color(0xFF065F46).withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF065F46).withValues(alpha: 0.3)
              : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：分类标签和剩余天数
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 分类标签
              if (item.categoryName != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBAE6FD).withValues(alpha: isDark ? 0.2 : 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '# ${item.categoryName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                )
              else
                const SizedBox(),

              // 剩余天数
              Text(
                '${item.daysRemaining}天后删除',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 内容预览
          Text(
            item.content,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // 分割线
          Container(
            height: 1,
            color: isDark
                ? const Color(0xFF065F46).withValues(alpha: 0.3)
                : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
          ),

          const SizedBox(height: 12),

          // 底部：删除时间和操作按钮
          Row(
            children: [
              // 删除时间
              Text(
                '删除于：${_formatDateTime(item.deletedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),

              const Spacer(),

              // 操作按钮
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 彻底删除按钮
                  _buildActionButton(
                    label: '彻底删除',
                    color: const Color(0xFFef4444),
                    onTap: onDelete,
                  ),

                  const SizedBox(width: 8),

                  // 恢复按钮
                  _buildActionButton(
                    label: '恢复',
                    color: const Color(0xFF39E079),
                    isPrimary: true,
                    onTap: onRestore,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPrimary
                ? color
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPrimary ? const Color(0xFF065F46) : color,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
