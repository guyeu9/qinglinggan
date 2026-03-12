import 'package:flutter/material.dart';
import 'package:light_idea/core/theme/app_colors.dart';

/// 分类标签页
/// 
/// 原型图: 首页 - 分类Tab栏
/// 包含: 时间轴、社交/旅行/惊喜、工作/创意、摄影爱好
class CategoryTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const CategoryTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final List<String> _tabs = const [
    '时间轴',
    '社交/旅行/惊喜',
    '工作/创意',
    '摄影爱好',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.backgroundDark : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () => onTabChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : AppColors.primaryDark)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.primaryDark.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
