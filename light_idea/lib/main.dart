import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database/isar_database.dart';
import 'data/database/seed_data.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'application/providers/app_providers.dart';
import 'config/ai_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarDatabase.initialize();
  await SeedData.initialize(isar);
  
  await AIConfig.initialize();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const LightIdeaApp(),
    ),
  );
}

class LightIdeaApp extends ConsumerWidget {
  const LightIdeaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '轻灵感',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
