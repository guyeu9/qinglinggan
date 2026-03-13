import 'package:flutter/material.dart';
import 'package:light_idea/core/theme/app_colors.dart';

/// 侧边栏抽屉
/// 
/// 原型图: 侧边栏
/// 包含: Logo、笔记统计、AI分析进度、系统管理菜单、用户信息
class SideDrawer extends StatelessWidget {
  final int totalNotes;
  final Map<String, int> categoryCounts;
  final double aiAnalysisProgress;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAiManagementTap;
  final VoidCallback? onBackupTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onRunAnalysisTap;

  const SideDrawer({
    super.key,
    this.totalNotes = 0,
    this.categoryCounts = const {},
    this.aiAnalysisProgress = 0.0,
    this.onSettingsTap,
    this.onAiManagementTap,
    this.onBackupTap,
    this.onHelpTap,
    this.onLogoutTap,
    this.onRunAnalysisTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.83,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header Logo
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '轻灵感',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        '激发你的每一丝创意',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.primaryDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 笔记统计
                    _buildSectionTitle('笔记统计', isDark),
                    const SizedBox(height: 12),
                    _buildStatsCard(isDark),
                    const SizedBox(height: 24),

                    // AI分析进度
                    _buildAiProgressCard(isDark),
                    const SizedBox(height: 24),

                    // 系统管理
                    _buildSectionTitle('系统管理', isDark),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: '设置',
                      isDark: isDark,
                      onTap: onSettingsTap,
                    ),
                    _buildMenuItem(
                      icon: Icons.psychology_outlined,
                      title: 'AI 管理',
                      isDark: isDark,
                      isSelected: true,
                      onTap: onAiManagementTap,
                    ),
                    _buildMenuItem(
                      icon: Icons.cloud_download_outlined,
                      title: '备份导出',
                      isDark: isDark,
                      onTap: onBackupTap,
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: '帮助与反馈',
                      isDark: isDark,
                      onTap: onHelpTap,
                    ),
                  ],
                ),
              ),
            ),

            // 用户信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.primaryDark.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.primaryDark.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '灵感家',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          'user@lightidea.app',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColors.primaryDark.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onLogoutTap,
                    icon: Icon(
                      Icons.logout,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.primaryDark.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : AppColors.primaryDark.withValues(alpha: 0.5),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primaryDark.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '总计笔记',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              Text(
                '$totalNotes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildCategoryRow('社交 / 旅行 / 惊喜', categoryCounts['社交'] ?? 0, isDark),
              const SizedBox(height: 8),
              _buildCategoryRow('工作 / 创意', categoryCounts['工作'] ?? 0, isDark),
              const SizedBox(height: 8),
              _buildCategoryRow('摄影爱好', categoryCounts['摄影'] ?? 0, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String label, int count, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.primaryDark.withValues(alpha: 0.8),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAiProgressCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primaryDark.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI 分析进度',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.primaryDark.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '已完成 ${(aiAnalysisProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: aiAnalysisProgress,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primaryDark.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRunAnalysisTap,
              icon: const Icon(Icons.smart_toy_outlined, size: 18),
              label: const Text('运行分析'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isDark,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppColors.primaryDark
            : (isDark
                ? Colors.white.withValues(alpha: 0.8)
                : AppColors.primaryDark.withValues(alpha: 0.8)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? AppColors.primaryDark
              : (isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppColors.primaryDark.withValues(alpha: 0.8)),
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.2) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: onTap,
    );
  }
}
