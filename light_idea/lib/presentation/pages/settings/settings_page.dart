import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../data/database/isar_database.dart';
import '../../../../config/ai_config.dart';
import '../../../../application/providers/user_provider.dart';

/// 设置详情页
///
/// 严格按照原型图实现:
/// d:\trae\qinglinggan\前端原型图\6设置详情页\code.html
///
/// 结构:
/// - 账户与个人资料: 个人资料
/// - 内容管理: 标签分类管理
/// - 个性化: 主题外观、字体设置
/// - 隐私与通知: 通知管理、隐私与数据
/// - 支持与关于: 帮助中心、关于
/// - 退出登录按钮
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF122017) : const Color(0xFFF0FDF4);
    final cardColor = Colors.white;
    final textColor = const Color(0xFF065F46);
    final mutedTextColor = const Color(0xFF065F46).withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, textColor),
              
              const SizedBox(height: 16),
              
              _buildSectionTitle('账户与个人资料', textColor),
              _buildSettingsCard(
                cardColor: cardColor,
                children: [
                  _buildProfileTile(context, textColor, mutedTextColor, ref),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('内容管理', textColor),
              _buildSettingsCard(
                cardColor: cardColor,
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Symbols.label,
                    title: '标签分类管理',
                    textColor: textColor,
                    onTap: () => context.pushToCategoryManagement(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('个性化', textColor),
              _buildSettingsCard(
                cardColor: cardColor,
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Symbols.palette,
                    title: '主题外观',
                    subtitle: isDark ? '深色模式' : '浅色模式',
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    onTap: () => _showNotImplemented(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context: context,
                    icon: Symbols.text_fields,
                    title: '字体设置',
                    textColor: textColor,
                    onTap: () => _showNotImplemented(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('隐私与通知', textColor),
              _buildSettingsCard(
                cardColor: cardColor,
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Symbols.notifications_active,
                    title: '通知管理',
                    textColor: textColor,
                    onTap: () => _showNotImplemented(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context: context,
                    icon: Symbols.visibility_off,
                    title: '隐私与数据',
                    textColor: textColor,
                    onTap: () => _showNotImplemented(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('支持与关于', textColor),
              _buildSettingsCard(
                cardColor: cardColor,
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Symbols.help,
                    title: '帮助中心',
                    textColor: textColor,
                    onTap: () => context.pushNamed(RouteNames.help),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context: context,
                    icon: Symbols.info,
                    title: '关于 Light Inspiration',
                    subtitle: '版本 2.4.0',
                    textColor: textColor,
                    mutedTextColor: mutedTextColor,
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _buildLogoutButton(context),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Designed for mindful users',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.3),
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(Symbols.arrow_back, color: textColor, size: 24),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '设置',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 24),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor.withValues(alpha: 0.6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context,
    Color textColor,
    Color mutedTextColor,
    WidgetRef ref,
  ) {
    final userState = ref.watch(userProvider);

    return InkWell(
      onTap: () => _showUserNameDialog(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Symbols.person, color: textColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '个人资料',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  userState.userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: textColor.withValues(alpha: 0.1),
                ),
              ),
              child: ClipOval(
                child: Icon(Symbols.person, color: textColor.withValues(alpha: 0.5), size: 20),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Symbols.chevron_right,
              color: textColor.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color textColor,
    Color? mutedTextColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: textColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: subtitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedTextColor ?? textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
            ),
            Icon(
              Symbols.chevron_right,
              color: textColor.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: const Color(0xFF065F46).withValues(alpha: 0.05),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutConfirm(context),
          icon: Icon(Symbols.logout, color: Colors.red, size: 20),
          label: const Text(
            '退出登录',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFFEE2E2)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

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

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

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
              '版本: 2.4.0',
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
