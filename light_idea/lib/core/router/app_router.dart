import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/idea_detail/idea_detail_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/data_management/data_management_page.dart';
import '../../presentation/pages/ai_hub/ai_hub_page.dart';
import '../../presentation/pages/ai_settings/ai_settings_page.dart';
import '../../presentation/pages/recycle_bin/recycle_bin_page.dart';

/// 全局路由实例
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,
  routes: [
    // 首页
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
    // 灵感详情页
    GoRoute(
      path: RoutePaths.ideaDetail,
      name: RouteNames.ideaDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return IdeaDetailPage(ideaId: id);
      },
    ),
    // 回收站
    GoRoute(
      path: RoutePaths.recycleBin,
      name: RouteNames.recycleBin,
      builder: (context, state) => const RecycleBinPage(),
    ),
    // 数据管理
    GoRoute(
      path: RoutePaths.dataManagement,
      name: RouteNames.dataManagement,
      builder: (context, state) => const DataManagementPage(),
    ),
    // 设置
    GoRoute(
      path: RoutePaths.settings,
      name: RouteNames.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    // AI灵感中心
    GoRoute(
      path: RoutePaths.aiHub,
      name: RouteNames.aiHub,
      builder: (context, state) => const AIHubPage(),
    ),
    // AI设置
    GoRoute(
      path: RoutePaths.aiSettings,
      name: RouteNames.aiSettings,
      builder: (context, state) => const AiSettingsPage(),
    ),
    // 帮助
    GoRoute(
      path: RoutePaths.help,
      name: RouteNames.help,
      builder: (context, state) => const PlaceholderPage(
        title: '帮助',
        icon: Icons.help_outline,
      ),
    ),
  ],
);

/// 占位符页面
///
/// 临时用于展示各路由页面，后续会被实际页面替换
class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
            const SizedBox(height: 32),
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '页面开发中...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 导航测试按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildNavButton(context, '首页', RoutePaths.home),
                _buildNavButton(context, '回收站', RoutePaths.recycleBin),
                _buildNavButton(context, '设置', RoutePaths.settings),
                _buildNavButton(context, 'AI中心', RoutePaths.aiHub),
                _buildNavButton(context, '帮助', RoutePaths.help),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String path) {
    return ElevatedButton(
      onPressed: () => context.go(path),
      child: Text(label),
    );
  }
}

/// 路由导航扩展方法
extension GoRouterExtension on BuildContext {
  /// 跳转到灵感详情页
  void goToIdeaDetail(String id) {
    go(RoutePaths.ideaDetailPath(id));
  }

  /// 跳转到首页
  void goToHome() {
    go(RoutePaths.home);
  }

  /// 跳转到回收站
  void goToRecycleBin() {
    go(RoutePaths.recycleBin);
  }

  /// 跳转到数据管理
  void goToDataManagement() {
    go(RoutePaths.dataManagement);
  }

  /// 跳转到设置
  void goToSettings() {
    go(RoutePaths.settings);
  }

  /// 跳转到AI灵感中心
  void goToAiHub() {
    go(RoutePaths.aiHub);
  }

  /// 跳转到AI设置
  void goToAiSettings() {
    go(RoutePaths.aiSettings);
  }

  /// 跳转到帮助
  void goToHelp() {
    go(RoutePaths.help);
  }
}
