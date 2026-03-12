import 'package:flutter/material.dart';
import 'package:light_idea/core/theme/app_colors.dart';

/// 搜索栏
/// 
/// 原型图: 首页 - 搜索栏
/// 包含: 搜索图标、输入框
class SearchInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String hintText;

  const SearchInputBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.hintText = '搜索灵感',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppColors.backgroundDark : Colors.white,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primaryDark.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.primaryDark.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              Icons.search,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : AppColors.primaryDark.withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onTap: onTap,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.primaryDark.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
