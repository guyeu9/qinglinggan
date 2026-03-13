import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 首页顶部导航栏
/// 
/// 固定在顶部的导航栏，白色半透明背景，包含菜单按钮、标题、AI中心和添加按钮
/// 严格按照原型图设计：
/// - 白色/半透明背景，模糊效果
/// - 标题"轻灵感"
/// - 菜单图标：notes（三个横线）
/// - AI图标：auto_awesome
/// - 添加图标：add
class StickyTopNav extends StatelessWidget implements PreferredSizeWidget {
  /// 菜单按钮点击回调
  final VoidCallback? onMenuTap;
  
  /// AI中心点击回调
  final VoidCallback? onAICenterTap;
  
  /// 添加按钮点击回调
  final VoidCallback? onAddTap;

  const StickyTopNav({
    super.key,
    this.onMenuTap,
    this.onAICenterTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.backgroundDark.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? AppColors.primaryDark.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: SafeArea(
            child: SizedBox(
              height: preferredSize.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // 菜单按钮 - 使用 notes 图标（三个横线）
                    _IconButton(
                      icon: Symbols.notes,
                      onTap: onMenuTap,
                      color: AppColors.primaryDark,
                    ),
                    
                    // 标题 - "轻灵感"
                    const Expanded(
                      child: Text(
                        '轻灵感',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // AI中心按钮 - auto_awesome
                    _IconButton(
                      icon: Symbols.auto_awesome,
                      onTap: onAICenterTap,
                      color: AppColors.primaryDark,
                    ),
                    
                    // 添加按钮 - add
                    _IconButton(
                      icon: Symbols.add,
                      onTap: onAddTap,
                      color: AppColors.primaryDark,
                    ),
                  ],
                ),
              ),
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
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onMoreTap;
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showMoreButton;
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
        ? AppColors.backgroundDark.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8));
    final foregroundColor = AppColors.primaryDark;
    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? AppColors.primaryDark.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: SafeArea(
            child: SizedBox(
              height: preferredSize.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (showBackButton)
                      _IconButton(
                        icon: Symbols.arrow_back,
                        onTap: onBackTap ?? () => Navigator.of(context).pop(),
                        color: foregroundColor,
                      )
                    else
                      const SizedBox(width: 48),
                    
                    const SizedBox(width: 8),
                    
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    if (actions != null) ...actions!,
                    
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
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
