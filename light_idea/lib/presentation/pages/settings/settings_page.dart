import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/route_names.dart';
import '../../../../data/database/isar_database.dart';
import '../../../../config/ai_config.dart';
import '../../../../application/providers/user_provider.dart';

/// 设置详情页
///
/// 根据原型图 6设置详情页 实现
/// 包含：账户资料、内容管理、个性化、隐私通知、支持关于等区域
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('设置'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 账户与个人资料区
              _buildSectionTitle('账户与个人资料', textSecondary),
              _buildSettingsCard(
                isDark: isDark,
                cardColor: cardColor,
                children: [
                  _buildUserProfileTile(context, textPrimary, textSecondary, ref),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary,
                    title: '个人资料',
                    subtitle: '编辑个人信息和头像',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _showNotImplemented(context),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.sync_outlined,
                    iconColor: AppColors.info,
                    title: '账户同步',
                    subtitle: '管理云端同步设置',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _showNotImplemented(context),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // 内容管理区
              _buildSectionTitle('内容管理', textSecondary),
              _buildSettingsCard(
                isDark: isDark,
                cardColor: cardColor,
                children: [
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.label_outline,
                    iconColor: AppColors.warning,
                    title: '标签分类管理',
                    subtitle: '管理灵感标签和分类',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _showNotImplemented(context),
                  ),
                  _buildDivider(isDark),
                  // 回收站入口 - 新增
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.delete_outline,
                    iconColor: AppColors.error,
                    title: '回收站',
                    subtitle: '查看和恢复已删除的灵感',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => context.pushNamed(RouteNames.recycleBin),
                    showBadge: true,
                    badgeCount: 5,
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // 个性化区
              _buildSectionTitle('个性化', textSecondary),
              _buildSettingsCard(
                isDark: isDark,
                cardColor: cardColor,
                children: [
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.palette_outlined,
                    iconColor: AppColors.primary,
                    title: '主题外观',
                    subtitle: isDark ? '当前：深色模式' : '当前：浅色模式',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        // TODO: 切换主题
                        _showNotImplemented(context);
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                    onTap: () => _showNotImplemented(context),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.font_download_outlined,
                    iconColor: AppColors.accentDark,
                    title: '字体设置',
                    subtitle: '调整字体大小和样式',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _showNotImplemented(context),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // 隐私与通知区
              _buildSectionTitle('隐私与通知', textSecondary),
              _buildSettingsCard(
                isDark: isDark,
                cardColor: cardColor,
                children: [
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.info,
                    title: '通知管理',
                    subtitle: '设置推送和提醒',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _showNotImplemented(context),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.success,
                    title: '隐私与数据',
                    subtitle: '管理数据权限和隐私设置',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _showNotImplemented(context),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // 支持与关于区
              _buildSectionTitle('支持与关于', textSecondary),
              _buildSettingsCard(
                isDark: isDark,
                cardColor: cardColor,
                children: [
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.help_outline,
                    iconColor: AppColors.primary,
                    title: '帮助中心',
                    subtitle: '常见问题和使用指南',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => context.pushNamed(RouteNames.help),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.info_outline,
                    iconColor: AppColors.textSecondaryLight,
                    title: '关于',
                    subtitle: '版本 1.0.0',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // 退出登录按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirm(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    '退出登录',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建设置区域标题
  Widget _buildSectionTitle(String title, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingSm,
        bottom: AppTheme.spacingSm,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 构建设置卡片容器
  Widget _buildSettingsCard({
    required bool isDark,
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  /// 构建用户资料头部
  Widget _buildUserProfileTile(
    BuildContext context,
    Color textPrimary,
    Color textSecondary,
    WidgetRef ref,
  ) {
    final userState = ref.watch(userProvider);
    
    return InkWell(
      onTap: () => _showUserNameDialog(context, ref),
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // 头像
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userState.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userState.userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 箭头
            Icon(
              Icons.chevron_right,
              color: textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
    Widget? trailing,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // 文字内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      if (showBadge && badgeCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeCount.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 尾部组件或箭头
            trailing ?? Icon(
              Icons.chevron_right,
              color: textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 60,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  /// 显示用户名称编辑对话框
  void _showUserNameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(userProvider).userName);
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑用户名'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入用户名',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref.read(userProvider.notifier).setUserName(name);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('用户名已更新')),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示功能未实现提示
  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于灵感轻记'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '灵感轻记是一款专注于记录和管理灵感的应用，帮助您随时捕捉和整理想法。',
            ),
            const SizedBox(height: 16),
            Text(
              '版本: 1.0.0',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示退出登录确认对话框
  void _showLogoutConfirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？这将清除所有本地数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await IsarDatabase.clear();
                await AIConfig.clearAll();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已退出登录，数据已清除')),
                  );
                  context.go(RouteNames.home);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('退出失败: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
