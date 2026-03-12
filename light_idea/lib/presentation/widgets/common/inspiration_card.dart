import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';

/// 灵感卡片组件
/// 
/// 用于展示单个灵感记录，包含分类标签、时间戳、内容和可选图片
class InspirationCard extends StatelessWidget {
  /// 内容文本
  final String content;
  
  /// 分类标签
  final String category;
  
  /// 时间戳
  final DateTime timestamp;
  
  /// 可选图片 URL
  final String? imageUrl;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 长按回调
  final VoidCallback? onLongPress;
  
  /// 分类标签颜色
  final Color? categoryColor;
  
  /// 最大内容行数
  final int maxContentLines;
  
  /// 是否显示分类标签
  final bool showCategory;
  
  /// 是否显示时间戳
  final bool showTimestamp;

  const InspirationCard({
    super.key,
    required this.content,
    required this.category,
    required this.timestamp,
    this.imageUrl,
    this.onTap,
    this.onLongPress,
    this.categoryColor,
    this.maxContentLines = 4,
    this.showCategory = true,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部：分类标签和时间戳
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                AppTheme.spacingMd,
                AppTheme.spacingSm,
              ),
              child: Row(
                children: [
                  // 分类标签
                  if (showCategory)
                    _CategoryChip(
                      label: category,
                      color: categoryColor ?? _getCategoryColor(category),
                    ),
                  
                  const Spacer(),
                  
                  // 时间戳
                  if (showTimestamp)
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
                          DateFormatter.formatRelative(timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // 内容文本
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
              ),
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  height: 1.5,
                ),
                maxLines: maxContentLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // 图片
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: _buildImage(),
                ),
              ),
            
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 180,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: double.infinity,
          height: 180,
          color: AppColors.borderLight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 180,
          color: AppColors.borderLight,
          child: const Center(
            child: Icon(
              Symbols.broken_image,
              size: 48,
              color: AppColors.textDisabled,
            ),
          ),
        );
      },
    );
  }

  /// 根据分类名称获取颜色
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

/// 分类标签 Chip 组件
class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
}

/// 灵感卡片列表加载占位组件
class InspirationCardShimmer extends StatelessWidget {
  const InspirationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部占位
            Row(
              children: [
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // 内容占位
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 16,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
