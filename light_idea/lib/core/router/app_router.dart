import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/idea_detail/idea_detail_page.dart';
import '../../presentation/pages/association/association_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/settings/category_management_page.dart';
import '../../presentation/pages/data_management/data_management_page.dart';
import '../../presentation/pages/ai_hub/ai_hub_page.dart';
import '../../presentation/pages/ai_settings/ai_settings_page.dart';
import '../../presentation/pages/recycle_bin/recycle_bin_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RoutePaths.ideaDetail,
      name: RouteNames.ideaDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return IdeaDetailPage(ideaId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.association,
      name: RouteNames.association,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AssociationPage(ideaId: int.tryParse(id) ?? 0);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => _SettingsShell(child: child),
      routes: [
        GoRoute(
          path: RoutePaths.settings,
          name: RouteNames.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: RoutePaths.recycleBin,
          name: RouteNames.recycleBin,
          builder: (context, state) => const RecycleBinPage(),
        ),
        GoRoute(
          path: RoutePaths.help,
          name: RouteNames.help,
          builder: (context, state) => const _HelpPage(),
        ),
        GoRoute(
          path: RoutePaths.categoryManagement,
          name: RouteNames.categoryManagement,
          builder: (context, state) => const CategoryManagementPage(),
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.dataManagement,
      name: RouteNames.dataManagement,
      builder: (context, state) => const DataManagementPage(),
    ),
    GoRoute(
      path: RoutePaths.aiHub,
      name: RouteNames.aiHub,
      builder: (context, state) => const AIHubPage(),
    ),
    GoRoute(
      path: RoutePaths.aiSettings,
      name: RouteNames.aiSettings,
      builder: (context, state) => const AiSettingsPage(),
    ),
  ],
  errorBuilder: (context, state) => _ErrorPage(error: state.error.toString()),
);

class _SettingsShell extends StatelessWidget {
  final Widget child;

  const _SettingsShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _HelpPage extends StatelessWidget {
  const _HelpPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF065F46)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '帮助中心',
          style: TextStyle(color: Color(0xFF065F46)),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4),
        elevation: 0,
      ),
      body: const Center(
        child: Text('帮助中心 - 开发中'),
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final String error;

  const _ErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('页面不存在', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

extension GoRouterExtension on BuildContext {
  void pushToIdeaDetail(String id) {
    pushNamed(RouteNames.ideaDetail, pathParameters: {'id': id});
  }

  void pushToAssociation(String id) {
    pushNamed(RouteNames.association, pathParameters: {'id': id});
  }

  void pushToHome() {
    push(RoutePaths.home);
  }

  void pushToRecycleBin() {
    pushNamed(RouteNames.recycleBin);
  }

  void pushToDataManagement() {
    pushNamed(RouteNames.dataManagement);
  }

  void pushToSettings() {
    pushNamed(RouteNames.settings);
  }

  void pushToAiHub() {
    pushNamed(RouteNames.aiHub);
  }

  void pushToAiSettings() {
    pushNamed(RouteNames.aiSettings);
  }

  void pushToHelp() {
    pushNamed(RouteNames.help);
  }

  void pushToCategoryManagement() {
    pushNamed(RouteNames.categoryManagement);
  }

  void goToHome() {
    go(RoutePaths.home);
  }

  void goToIdeaDetail(String id) {
    go(RoutePaths.ideaDetailPath(id));
  }
}
