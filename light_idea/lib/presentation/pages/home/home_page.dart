import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/router/route_names.dart';
import '../../../../application/providers/home_provider.dart';
import '../../../../application/providers/app_providers.dart';
import '../../widgets/common/side_drawer.dart';

/// 首页
/// 
/// 严格按照原型图实现：
/// - 顶部导航栏：白色半透明背景、模糊效果
/// - 搜索栏：浅绿色背景、圆角
/// - 分类标签：下划线选中样式
/// - 灵感卡片：白色背景、圆角、阴影
/// - 底部输入区：圆角输入框、发送按钮
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
  final List<File> _selectedImages = [];

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
    context.pushNamed(RouteNames.ideaDetail, pathParameters: {'id': id.toString()});
  }

  Future<void> _openNewIdeaDetail() async {
    final ideaId = await ref.read(homeProvider.notifier).createEmptyIdea();
    if (ideaId != null && mounted) {
      context.pushNamed(RouteNames.ideaDetail, pathParameters: {'id': ideaId.toString()});
    }
  }

  Future<void> _onImageTap() async {
    final imagePickerService = ref.read(imagePickerServiceProvider);
    final result = await imagePickerService.showImageSourceDialog(context);

    if (result.isSuccess && result.dataOrNull!.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(result.dataOrNull!.images);
      });
      HapticFeedback.mediumImpact();
      _showImageSelectedSnackBar(result.dataOrNull!.length);
    } else if (result.isError) {
      _showErrorSnackBar(result.errorOrNull ?? '选择图片失败');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  void _showImageSelectedSnackBar(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已选择 $count 张图片'),
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFef4444),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _onSendTap() async {
    final text = _inputController.text.trim();
    final hasContent = text.isNotEmpty || _selectedImages.isNotEmpty;

    if (hasContent) {
      _inputController.clear();
      HapticFeedback.mediumImpact();

      final imagePaths = _selectedImages.map((f) => f.path).toList();
      final success = await ref.read(homeProvider.notifier).saveIdea(
        text,
        imagePaths: imagePaths,
      );

      if (success && mounted) {
        setState(() {
          _selectedImages.clear();
        });
        _showSaveSuccessSnackBar();
      }
    }
  }

  void _showSaveSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('灵感已保存'),
        backgroundColor: const Color(0xFF065F46),
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
    context.pushNamed(RouteNames.aiHub);
  }

  void _goToSettings() {
    context.pushNamed(RouteNames.settings);
  }

  void _goToAiSettings() {
    context.pushNamed(RouteNames.aiSettings);
  }

  void _goToDataManagement() {
    context.pushNamed(RouteNames.dataManagement);
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
      backgroundColor: isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4),
      drawer: SideDrawer(
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
          context.pushNamed(RouteNames.help);
        },
      ),
      body: Column(
        children: [
          // 顶部导航栏
          _buildTopNav(isDark),
          
          // 搜索栏
          _buildSearchBar(isDark),
          
          // 分类标签
          _buildCategoryTabs(isDark, homeState.selectedCategoryIndex),
          
          // 内容列表
          Expanded(
            child: _buildContentList(homeState, isDark),
          ),
          
          // 底部输入区
          _buildBottomInput(isDark),
        ],
      ),
    );
  }

  /// 顶部导航栏
  /// 
  /// 原型图代码：
  /// ```html
  /// <nav class="sticky top-0 z-50 grid grid-cols-3 items-center px-4 py-3 bg-white/80 dark:bg-emerald-950/80 backdrop-blur-md border-b border-emerald-100 dark:border-emerald-900">
  /// ```
  Widget _buildTopNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF022c22).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? const Color(0xFF065F46).withValues(alpha: 0.3)
                : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 左侧 - 菜单按钮
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildIconButton(
                        icon: Symbols.notes,
                        onTap: _openDrawer,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ),
                  
                  // 中间 - 标题
                  const Text(
                    '轻灵感',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  
                  // 右侧 - AI中心和添加按钮
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIconButton(
                            icon: Symbols.auto_awesome,
                            onTap: _goToAiHub,
                            color: const Color(0xFF065F46),
                          ),
                          _buildIconButton(
                            icon: Symbols.add,
                            onTap: _openNewIdeaDetail,
                            color: const Color(0xFF065F46),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 图标按钮
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
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

  /// 搜索栏
  /// 
  /// 原型图代码：
  /// ```html
  /// <div class="px-4 py-3 bg-white dark:bg-emerald-950 shadow-sm">
  ///   <div class="relative flex items-center w-full">
  ///     <span class="material-symbols-outlined absolute left-3 text-slate-400">search</span>
  ///     <input class="w-full h-11 pl-10 pr-4 bg-emerald-50/50 dark:bg-emerald-900/50 border border-emerald-100 dark:border-emerald-800 rounded-xl focus:ring-2 focus:ring-primary/50 text-sm placeholder:text-emerald-800/40 text-primary-dark dark:text-emerald-50 transition-all" placeholder="搜索灵感" type="text"/>
  ///   </div>
  /// </div>
  /// ```
  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF022c22) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF065F46).withValues(alpha: 0.3)
              : const Color(0xFF6EE7B7).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF065F46).withValues(alpha: 0.3)
                : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              Symbols.search,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFF065F46).withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF065F46),
                ),
                decoration: InputDecoration(
                  hintText: '搜索灵感',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : const Color(0xFF065F46).withValues(alpha: 0.4),
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

  /// 分类标签
  /// 
  /// 原型图代码：
  /// ```html
  /// <div class="bg-white dark:bg-emerald-950 border-b border-emerald-100 dark:border-emerald-800">
  ///   <div class="flex px-2 overflow-x-auto hide-scrollbar">
  ///     <button class="flex-none px-3 py-3 text-xs font-bold border-b-2 border-primary text-primary-dark dark:text-primary tab-transition">时间轴</button>
  ///     ...
  ///   </div>
  /// </div>
  /// ```
  Widget _buildCategoryTabs(bool isDark, int selectedIndex) {
    final tabs = const ['时间轴', '社交/旅行/惊喜', '工作/创意', '摄影爱好'];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF022c22) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF065F46).withValues(alpha: 0.3)
                : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () => _onCategoryChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6EE7B7)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
                        : (isDark
                            ? const Color(0xFF6EE7B7).withValues(alpha: 0.6)
                            : const Color(0xFF065F46).withValues(alpha: 0.6)),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// 内容列表
  Widget _buildContentList(HomeState homeState, bool isDark) {
    if (homeState.error != null) {
      return _buildErrorState(homeState.error!, isDark);
    }

    // 如果列表为空，显示空状态
    if (homeState.ideas.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).loadIdeas(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16).copyWith(bottom: 160),
        itemCount: homeState.ideas.length,
        itemBuilder: (context, index) {
          final idea = homeState.ideas[index];
          final category = homeState.categories.where((c) => c.id == idea.categoryId).firstOrNull;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InspirationCard(
              content: idea.content,
              category: category?.name ?? '未分类',
              timestamp: idea.createdAt,
              onTap: () => _onIdeaTap(idea.id),
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: isDark 
                ? const Color(0xFF6EE7B7).withValues(alpha: 0.5)
                : const Color(0xFF065F46).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '还没有灵感',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '在下方输入你的第一个灵感吧',
            style: TextStyle(
              fontSize: 14,
              color: isDark 
                  ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
                  : const Color(0xFF065F46).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 错误状态
  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.red.shade300 : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: isDark 
                  ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
                  : const Color(0xFF065F46).withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(homeProvider.notifier).loadIdeas(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6EE7B7),
              foregroundColor: const Color(0xFF065F46),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 底部输入区
  /// 
  /// 原型图代码：
  /// ```html
  /// <div class="fixed bottom-0 left-0 right-0 bg-white/90 dark:bg-emerald-950/90 backdrop-blur-md border-t border-emerald-100 dark:border-emerald-800 px-4 pt-3 pb-8">
  ///   <div class="flex items-center gap-3 bg-emerald-50/50 dark:bg-emerald-900/30 border border-emerald-100 dark:border-emerald-800 rounded-2xl p-2 mb-3 shadow-sm">
  ///     <textarea class="flex-1 px-3 py-2 bg-transparent border-none focus:ring-0 resize-none text-sm placeholder:text-emerald-800/40 text-primary-dark dark:text-emerald-50 min-h-[44px]" placeholder="记录下当下的灵感..." rows="1"></textarea>
  ///     <button class="flex items-center justify-center w-10 h-10 bg-primary text-primary-dark rounded-xl shadow-lg shadow-primary/20 active:scale-95 transition-all btn-pulse">
  ///       <span class="material-symbols-outlined text-xl">send</span>
  ///     </button>
  ///   </div>
  ///   <div class="flex items-center gap-6 px-2">
  ///     <button class="text-emerald-800/40 hover:text-primary transition-colors btn-pulse">
  ///       <span class="material-symbols-outlined">image</span>
  ///     </button>
  ///     <button class="text-emerald-800/40 hover:text-primary transition-colors btn-pulse">
  ///       <span class="material-symbols-outlined">mic</span>
  ///     </button>
  ///   </div>
  /// </div>
  /// ```
  Widget _buildBottomInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF022c22).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF065F46).withValues(alpha: 0.3)
                : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 输入框区域
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF065F46).withValues(alpha: 0.2)
                          : const Color(0xFF6EE7B7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF065F46).withValues(alpha: 0.3)
                            : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _onSendTap(),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF065F46),
                            ),
                            decoration: InputDecoration(
                              hintText: '记录下当下的灵感...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? const Color(0xFF6EE7B7).withValues(alpha: 0.4)
                                    : const Color(0xFF065F46).withValues(alpha: 0.4),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: const Color(0xFF6EE7B7),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: _onSendTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: const Icon(
                                Symbols.send,
                                color: Color(0xFF065F46),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // 已选图片预览
                  if (_selectedImages.isNotEmpty)
                    _buildSelectedImagesPreview(isDark),

                  const SizedBox(height: 12),

                  // 快捷操作按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        _buildQuickActionButton(
                          icon: Symbols.image,
                          onTap: _onImageTap,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 已选图片预览
  Widget _buildSelectedImagesPreview(bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
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
            color: isDark
                ? const Color(0xFF6EE7B7).withValues(alpha: 0.4)
                : const Color(0xFF065F46).withValues(alpha: 0.4),
            size: 24,
          ),
        ),
      ),
    );
  }

}

/// 灵感卡片
/// 
/// 原型图代码：
/// ```html
/// <div class="bg-white dark:bg-emerald-950 rounded-xl p-4 shadow-sm border border-emerald-100 dark:border-emerald-800 animate-fade-in-up card-hover">
///   <div class="flex justify-between items-start mb-2">
///     <span class="px-2 py-0.5 bg-primary/20 text-primary-dark dark:text-primary text-[10px] font-bold rounded uppercase tracking-wider btn-pulse cursor-pointer transition-transform">工作/创意</span>
///     <span class="text-[10px] text-slate-400 font-medium">10:30 AM</span>
///   </div>
///   <p class="text-sm leading-relaxed text-primary-dark/90 dark:text-emerald-100">...</p>
///   <div class="mt-4 w-full aspect-video rounded-lg bg-cover bg-center bg-slate-200" ...></div>
/// </div>
/// ```
class _InspirationCard extends StatelessWidget {
  final String content;
  final String category;
  final DateTime timestamp;
  final VoidCallback? onTap;
  final bool isDark;

  const _InspirationCard({
    required this.content,
    required this.category,
    required this.timestamp,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF022c22) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF065F46).withValues(alpha: 0.3)
                  : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：分类标签和时间戳
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 分类标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6EE7B7).withValues(alpha: isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  // 时间戳
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? const Color(0xFF6EE7B7).withValues(alpha: 0.6)
                          : const Color(0xFF065F46).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 内容文本
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark 
                      ? const Color(0xFF6EE7B7).withValues(alpha: 0.9)
                      : const Color(0xFF065F46).withValues(alpha: 0.9),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              

            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(time.year, time.month, time.day);

    if (date == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (date == yesterday) {
      return '昨天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// 灵感卡片加载占位
class _InspirationCardShimmer extends StatelessWidget {
  const _InspirationCardShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF022c22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF065F46).withValues(alpha: 0.3)
              : const Color(0xFF6EE7B7).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部占位
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 内容占位
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 14,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
