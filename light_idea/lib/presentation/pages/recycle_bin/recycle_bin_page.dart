import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';

/// 回收站页面
///
/// 原型图: 4回收站
/// 功能: 展示已删除的灵感记录，支持恢复和彻底删除
class RecycleBinPage extends StatefulWidget {
  const RecycleBinPage({super.key});

  @override
  State<RecycleBinPage> createState() => _RecycleBinPageState();
}

/// 回收站项目数据模型
class _RecycleBinItem {
  final String id;
  final String content;
  final String category;
  final DateTime deletedAt;
  final int daysRemaining;

  const _RecycleBinItem({
    required this.id,
    required this.content,
    required this.category,
    required this.deletedAt,
    required this.daysRemaining,
  });
}

class _RecycleBinPageState extends State<RecycleBinPage> {
  // 模拟数据
  final List<_RecycleBinItem> _mockItems = [
    _RecycleBinItem(
      id: '1',
      content: '尝试用极简主义风格重新设计个人主页，采用大量留白和柔和的绿色调，让内容本身成为焦点。可以参考一些日本设计师的作品，学习他们对空间的运用。',
      category: '工作/创意',
      deletedAt: DateTime.now().subtract(const Duration(days: 2)),
      daysRemaining: 28,
    ),
    _RecycleBinItem(
      id: '2',
      content: '在京都的小巷里发现一家隐藏的茶室，木质结构和庭院设计让人瞬间安静下来。下次带相机来拍一组照片，记录这种宁静的氛围。',
      category: '社交/旅行',
      deletedAt: DateTime.now().subtract(const Duration(days: 5)),
      daysRemaining: 25,
    ),
    _RecycleBinItem(
      id: '3',
      content: '雨天拍摄城市夜景的绝佳时机，湿润的地面反射霓虹灯光，创造出梦幻般的色彩层次。记得带上三脚架和广角镜头。',
      category: '摄影爱好',
      deletedAt: DateTime.now().subtract(const Duration(days: 10)),
      daysRemaining: 20,
    ),
    _RecycleBinItem(
      id: '4',
      content: '关于AI辅助创作的思考：工具应该增强人的创造力，而不是取代它。关键在于找到合适的协作方式，让AI成为创意的催化剂。',
      category: '工作/创意',
      deletedAt: DateTime.now().subtract(const Duration(days: 15)),
      daysRemaining: 15,
    ),
    _RecycleBinItem(
      id: '5',
      content: '和朋友讨论周末去海边露营的计划，需要准备帐篷、便携炉具和足够的咖啡豆。还要查一下天气预报，选一个晴朗的周末。',
      category: '社交/旅行',
      deletedAt: DateTime.now().subtract(const Duration(days: 20)),
      daysRemaining: 10,
    ),
  ];

  void _goBack() {
    context.pop();
  }

  void _showClearAllDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text(
          '清空回收站',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '确定要清空回收站吗？此操作将永久删除所有内容，无法恢复。',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _mockItems.clear();
    });
    HapticFeedback.mediumImpact();
    _showSnackBar('回收站已清空');
  }

  void _showDeleteConfirmDialog(_RecycleBinItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text(
          '彻底删除',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '确定要彻底删除这条灵感吗？此操作不可恢复。',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentlyDelete(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _permanentlyDelete(_RecycleBinItem item) {
    setState(() {
      _mockItems.removeWhere((i) => i.id == item.id);
    });
    HapticFeedback.mediumImpact();
    _showSnackBar('已彻底删除');
  }

  void _restoreItem(_RecycleBinItem item) {
    setState(() {
      _mockItems.removeWhere((i) => i.id == item.id);
    });
    HapticFeedback.mediumImpact();
    _showSnackBar('灵感已恢复');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(isDark),

            // 提示信息栏
            _buildInfoBanner(isDark),

            // 灵感列表
            Expanded(
              child: _mockItems.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      itemCount: _mockItems.length,
                      itemBuilder: (context, index) {
                        final item = _mockItems[index];
                        return _RecycleBinCard(
                          item: item,
                          onRestore: () => _restoreItem(item),
                          onDelete: () => _showDeleteConfirmDialog(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            onPressed: _goBack,
            icon: Icon(
              Symbols.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            tooltip: '返回',
          ),

          const Spacer(),

          // 标题
          Text(
            '回收站',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // 清空按钮
          TextButton.icon(
            onPressed: _mockItems.isEmpty ? null : _showClearAllDialog,
            icon: const Icon(Symbols.delete_forever, size: 20),
            label: const Text('清空'),
            style: TextButton.styleFrom(
              foregroundColor: _mockItems.isEmpty
                  ? AppColors.textDisabled
                  : AppColors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        0,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: isDark
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.info,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              '内容将在30天后自动彻底删除',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.delete_outline,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                : AppColors.textSecondaryLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            '回收站是空的',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            '删除的灵感会在这里显示',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 回收站卡片组件
class _RecycleBinCard extends StatelessWidget {
  final _RecycleBinItem item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _RecycleBinCard({
    required this.item,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：标签和剩余天数
            Row(
              children: [
                // 分类标签
                _CategoryChip(label: item.category),

                const Spacer(),

                // 剩余天数
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.timer,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '剩${item.daysRemaining}天',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // 内容预览
            Text(
              item.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // 底部：删除时间和操作按钮
            Row(
              children: [
                // 删除时间
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.schedule,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '删除于 ${DateFormatter.formatRelative(item.deletedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 操作按钮
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 彻底删除按钮
                    _ActionButton(
                      icon: Symbols.delete_forever,
                      label: '彻底删除',
                      color: AppColors.error,
                      onTap: onDelete,
                    ),

                    const SizedBox(width: AppTheme.spacingSm),

                    // 恢复按钮
                    _ActionButton(
                      icon: Symbols.restore,
                      label: '恢复',
                      color: AppColors.success,
                      onTap: onRestore,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 分类标签 Chip 组件
class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getCategoryColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('工作') || lowerCategory.contains('work')) {
      return AppColors.info;
    } else if (lowerCategory.contains('社交') || lowerCategory.contains('social')) {
      return AppColors.accent;
    } else if (lowerCategory.contains('旅行') || lowerCategory.contains('travel')) {
      return AppColors.warning;
    } else if (lowerCategory.contains('摄影') || lowerCategory.contains('photo')) {
      return AppColors.success;
    } else if (lowerCategory.contains('创意') || lowerCategory.contains('creative')) {
      return AppColors.primary;
    }
    return AppColors.primary;
  }
}

/// 操作按钮组件
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
