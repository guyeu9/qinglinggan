import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:light_idea/core/theme/app_colors.dart';
import 'package:light_idea/core/router/route_names.dart';
import 'package:light_idea/presentation/widgets/common/app_bar.dart';
import 'package:light_idea/presentation/widgets/common/bottom_input_bar.dart';
import 'package:light_idea/presentation/widgets/common/category_tabs.dart';
import 'package:light_idea/presentation/widgets/common/inspiration_card.dart';
import 'package:light_idea/presentation/widgets/common/search_bar.dart';
import 'package:light_idea/presentation/widgets/common/side_drawer.dart';
import 'package:light_idea/application/providers/home_provider.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/entities/category.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(int index) {
    ref.read(homeProvider.notifier).selectCategory(index);
    HapticFeedback.selectionClick();
  }

  void _onIdeaTap(int id) {
    context.goNamed(RouteNames.ideaDetail, pathParameters: {'id': id.toString()});
  }

  Future<void> _onSendTap() async {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _inputController.clear();
      HapticFeedback.mediumImpact();
      
      final success = await ref.read(homeProvider.notifier).saveIdea(text);
      if (success && mounted) {
        _showSaveSuccessSnackBar();
      }
    }
  }

  void _showSaveSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('灵感已保存'),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _goToAiHub() {
    context.goNamed(RouteNames.aiHub);
  }

  void _goToSettings() {
    context.goNamed(RouteNames.settings);
  }

  void _goToAiSettings() {
    context.goNamed(RouteNames.aiSettings);
  }

  void _goToDataManagement() {
    context.goNamed(RouteNames.dataManagement);
  }

  void _onSearch(String query) {
    ref.read(homeProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      drawer: SideDrawer(
        totalNotes: homeState.ideas.length,
        categoryCounts: _buildCategoryCounts(homeState.categories, homeState.ideas),
        aiAnalysisProgress: _calculateAIProgress(homeState.ideas),
        onSettingsTap: () {
          Navigator.pop(context);
          _goToSettings();
        },
        onAiManagementTap: () {
          Navigator.pop(context);
          _goToAiSettings();
        },
        onBackupTap: () {
          Navigator.pop(context);
          _goToDataManagement();
        },
        onHelpTap: () {
          Navigator.pop(context);
          context.goNamed(RouteNames.help);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            StickyTopNav(
              onMenuTap: _openDrawer,
              onAICenterTap: _goToAiHub,
              onAddTap: () {
                // TODO: 打开详细输入弹窗
              },
            ),
            
            SearchInputBar(
              controller: _searchController,
              onChanged: _onSearch,
            ),
            
            CategoryTabs(
              selectedIndex: homeState.selectedCategoryIndex,
              onTabChanged: _onCategoryChanged,
            ),
            
            Expanded(
              child: _buildIdeaList(homeState, isDark),
            ),
            
            BottomInputBar(
              controller: _inputController,
              onImageTap: () {
                // TODO: 选择图片
              },
              onVoiceTap: () {
                // TODO: 语音输入
              },
              onSend: (text) => _onSendTap(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaList(HomeState homeState, bool isDark) {
    if (homeState.error != null) {
      return _buildErrorState(homeState.error!, isDark);
    }

    if (homeState.ideas.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).loadIdeas(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: homeState.ideas.length + (homeState.isAnalyzing ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == homeState.ideas.length && homeState.isAnalyzing) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: InspirationCardShimmer(),
            );
          }

          final idea = homeState.ideas[index];
          final category = homeState.categories.where((c) => c.id == idea.categoryId).firstOrNull;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InspirationCard(
              content: idea.content,
              category: category?.name ?? '未分类',
              timestamp: idea.createdAt,
              onTap: () => _onIdeaTap(idea.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: isDark 
                ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                : AppColors.textSecondaryLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有灵感',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '在下方输入你的第一个灵感吧',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(homeProvider.notifier).loadIdeas(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Map<String, int> _buildCategoryCounts(List<CategoryEntity> categories, List<IdeaEntity> ideas) {
    final counts = <String, int>{};
    for (final category in categories) {
      final count = ideas.where((idea) => idea.categoryId == category.id).length;
      counts[category.name] = count;
    }
    return counts;
  }

  double _calculateAIProgress(List<IdeaEntity> ideas) {
    if (ideas.isEmpty) return 0;
    final completed = ideas.where((idea) => idea.aiStatus == AIStatus.completed).length;
    return completed / ideas.length;
  }
}
