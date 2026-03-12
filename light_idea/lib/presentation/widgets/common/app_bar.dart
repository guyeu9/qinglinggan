import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// 首页顶部导航栏
/// 
/// 固定在顶部的导航栏，包含菜单按钮、标题、AI中心和添加按钮
class StickyTopNav extends StatelessWidget implements PreferredSizeWidget {
  /// 菜单按钮点击回调
  final VoidCallback? onMenuTap;
  
  /// AI中心点击回调
  final VoidCallback? onAICenterTap;
  
  /// 添加按钮点击回调
  final VoidCallback? onAddTap;
  
  /// 标题文本
  final String title;
  
  /// 是否显示AI中心按钮
  final bool showAICenter;
  
  /// 是否显示添加按钮
  final bool showAddButton;

  const StickyTopNav({
    super.key,
    this.onMenuTap,
    this.onAICenterTap,
    this.onAddTap,
    this.title = 'Light Idea',
    this.showAICenter = true,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? AppColors.backgroundDark 
        : AppColors.primaryDark;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            child: Row(
              children: [
                // 菜单按钮
                _IconButton(
                  icon: Symbols.menu,
                  onTap: onMenuTap,
                  color: Colors.white,
                ),
                
                const SizedBox(width: AppTheme.spacingSm),
                
                // 标题
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // AI中心按钮
                if (showAICenter)
                  _IconButton(
                    icon: Symbols.smart_toy,
                    onTap: onAICenterTap,
                    color: Colors.white,
                  ),
                
                // 添加按钮
                if (showAddButton)
                  _IconButton(
                    icon: Symbols.add,
                    onTap: onAddTap,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// 详情页导航栏
/// 
/// 用于详情页面的导航栏，包含返回按钮、标题和操作按钮
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 返回按钮点击回调
  final VoidCallback? onBackTap;
  
  /// 更多操作点击回调
  final VoidCallback? onMoreTap;
  
  /// 标题文本
  final String title;
  
  /// 自定义操作按钮列表
  final List<Widget>? actions;
  
  /// 是否显示返回按钮
  final bool showBackButton;
  
  /// 是否显示更多按钮
  final bool showMoreButton;
  
  /// 背景颜色（默认跟随主题）
  final Color? backgroundColor;

  const DetailAppBar({
    super.key,
    this.onBackTap,
    this.onMoreTap,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showMoreButton = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark 
        ? AppColors.backgroundDark 
        : AppColors.primaryDark);
    final foregroundColor = isDark && backgroundColor == null 
        ? AppColors.textPrimaryDark 
        : Colors.white;
    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            child: Row(
              children: [
                // 返回按钮
                if (showBackButton)
                  _IconButton(
                    icon: Symbols.arrow_back,
                    onTap: onBackTap ?? () => Navigator.of(context).pop(),
                    color: foregroundColor,
                  )
                else
                  const SizedBox(width: 48),
                
                const SizedBox(width: AppTheme.spacingSm),
                
                // 标题
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // 自定义操作按钮
                if (actions != null) ...actions!,
                
                // 更多按钮
                if (showMoreButton)
                  _IconButton(
                    icon: Symbols.more_vert,
                    onTap: onMoreTap,
                    color: foregroundColor,
                  )
                else if (actions == null)
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// 内部使用的图标按钮组件
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _IconButton({
    required this.icon,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onTap != null ? color : color.withValues(alpha: 0.5),
            size: 24,
          ),
        ),
      ),
    );
  }
}
