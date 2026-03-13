import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../application/providers/sidebar_provider.dart';

/// 侧边栏抽屉
///
/// 严格按照原型图实现:
/// d:\trae\qinglinggan\前端原型图\3灵感首页左上角点击三个横展开的侧边栏\code.html
///
/// 颜色定义:
/// - primary: #6EE7B7
/// - forest-core: #065F46
/// - background-light: #F0FDF4
/// - background-dark: #064E3B
/// - secondary-accent: #BAE6FD
class SideDrawer extends ConsumerWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAiManagementTap;
  final VoidCallback? onBackupTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onLogoutTap;

  const SideDrawer({
    super.key,
    this.onSettingsTap,
    this.onAiManagementTap,
    this.onBackupTap,
    this.onHelpTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarState = ref.watch(sidebarProvider);

    // 严格使用原型图颜色
    final backgroundColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4);
    final textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
    final secondaryTextColor = isDark
        ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
        : const Color(0xFF065F46).withValues(alpha: 0.7);
    final mutedTextColor = isDark
        ? const Color(0xFF6EE7B7).withValues(alpha: 0.5)
        : const Color(0xFF065F46).withValues(alpha: 0.5);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.83,
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header Section - Logo和标题
            _buildHeader(isDark, textColor, secondaryTextColor),

            // 可滚动内容区
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 笔记统计
                    _buildSectionTitle('笔记统计', mutedTextColor),
                    const SizedBox(height: 12),
                    _buildStatsCard(isDark, textColor, secondaryTextColor, sidebarState),
                    const SizedBox(height: 24),

                    // AI分析进度
                    _buildAiProgressCard(isDark, textColor, mutedTextColor, sidebarState, ref),
                    const SizedBox(height: 24),

                    // 系统管理
                    _buildSectionTitle('系统管理', mutedTextColor),
                    const SizedBox(height: 12),
                    _buildMenuItems(isDark, textColor, secondaryTextColor),
                  ],
                ),
              ),
            ),

            // User Footer - 用户信息
            _buildUserFooter(isDark, textColor, secondaryTextColor),
          ],
        ),
      ),
    );
  }

  /// Header Section - Logo和标题
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="flex items-center gap-4 px-6 py-8">
  ///   <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-forest-core text-white shadow-lg">
  ///     <span class="material-symbols-outlined text-3xl">lightbulb</span>
  ///   </div>
  ///   <div>
  ///     <h1 class="text-xl font-bold text-forest-core dark:text-primary">轻灵感</h1>
  ///     <p class="text-sm text-forest-core/70 dark:text-primary/70">激发你的每一丝创意</p>
  ///   </div>
  /// </div>
  /// ```
  Widget _buildHeader(bool isDark, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Logo图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF065F46),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF065F46).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Symbols.lightbulb,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // 标题和副标题
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '轻灵感',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '激发你的每一丝创意',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 区域标题
  ///
  /// 原型图代码:
  /// ```html
  /// <h3 class="mb-4 px-2 text-xs font-bold uppercase tracking-wider text-forest-core/50 dark:text-primary/50">笔记统计</h3>
  /// ```
  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// 笔记统计卡片
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="grid grid-cols-1 gap-3">
  ///   <div class="flex items-center justify-between rounded-xl bg-white dark:bg-slate-800/50 p-4 shadow-sm border border-forest-core/5">
  ///     <span class="text-forest-core dark:text-primary font-medium">总计笔记</span>
  ///     <span class="text-2xl font-bold text-forest-core">54</span>
  ///   </div>
  ///   <div class="space-y-2 rounded-xl bg-secondary-accent/30 p-4 dark:bg-secondary-accent/10">
  ///     ...
  ///   </div>
  /// </div>
  /// ```
  Widget _buildStatsCard(bool isDark, Color textColor, Color secondaryTextColor, SidebarState state) {
    // 获取前3个分类的统计
    final sortedEntries = state.categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedEntries.take(3).toList();

    return Column(
      children: [
        // 总计笔记卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.3) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF065F46).withValues(alpha: 0.05),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '总计笔记',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              Text(
                '${state.totalNotes}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 分类统计
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFBAE6FD).withValues(alpha: isDark ? 0.1 : 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: topCategories.isEmpty
                ? [
                    Text(
                      '暂无分类数据',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ]
                : topCategories.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  /// AI分析进度卡片
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="mb-8 rounded-xl bg-white dark:bg-slate-800/50 p-4 shadow-sm border border-forest-core/5">
  ///   <div class="mb-3 flex items-center justify-between">
  ///     <h3 class="text-xs font-bold uppercase tracking-wider text-forest-core/50 dark:text-primary/50">AI 分析进度</h3>
  ///     <span class="text-xs font-bold text-forest-core">已完成 85%</span>
  ///   </div>
  ///   <div class="mb-4 h-2 w-full overflow-hidden rounded-full bg-forest-core/10 dark:bg-slate-700">
  ///     <div class="h-full bg-primary" style="width: 85%"></div>
  ///   </div>
  ///   <button class="flex w-full items-center justify-center gap-2 rounded-lg bg-primary py-2.5 text-sm font-bold text-forest-core shadow-lg shadow-primary/20 transition-transform active:scale-95">
  ///     <span class="material-symbols-outlined text-lg">smart_toy</span>
  ///     运行分析
  ///   </button>
  /// </div>
  /// ```
  Widget _buildAiProgressCard(
    bool isDark,
    Color textColor,
    Color mutedTextColor,
    SidebarState state,
    WidgetRef ref,
  ) {
    final progressPercent = (state.aiAnalysisProgress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF065F46).withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和百分比
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI 分析进度',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: mutedTextColor,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '已完成 $progressPercent%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.aiAnalysisProgress,
              backgroundColor: const Color(0xFF065F46).withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6EE7B7)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          // 运行分析按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => ref.read(sidebarProvider.notifier).runAnalysis(),
              icon: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF065F46)),
                      ),
                    )
                  : const Icon(Symbols.smart_toy, size: 18),
              label: Text(state.isLoading ? '分析中...' : '运行分析'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EE7B7),
                foregroundColor: const Color(0xFF065F46),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 菜单项列表
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="space-y-1">
  ///   <a class="flex h-12 items-center gap-4 rounded-xl px-4 text-forest-core dark:text-primary/80 hover:bg-primary/20 transition-colors" href="#">
  ///     <span class="material-symbols-outlined">settings</span>
  ///     <span class="text-sm font-semibold">设置</span>
  ///   </a>
  ///   ...
  /// </div>
  /// ```
  Widget _buildMenuItems(bool isDark, Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Symbols.settings,
          title: '设置',
          isDark: isDark,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          onTap: onSettingsTap,
        ),
        _buildMenuItem(
          icon: Symbols.psychology,
          title: 'AI 管理',
          isDark: isDark,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          isSelected: true,
          onTap: onAiManagementTap,
        ),
        _buildMenuItem(
          icon: Symbols.cloud_download,
          title: '备份导出',
          isDark: isDark,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          onTap: onBackupTap,
        ),
        _buildMenuItem(
          icon: Symbols.contact_support,
          title: '帮助与反馈',
          isDark: isDark,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
          onTap: onHelpTap,
        ),
      ],
    );
  }

  /// 单个菜单项
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6EE7B7).withValues(alpha: 0.2) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF065F46)
                    : secondaryTextColor,
                size: 24,
                fill: isSelected ? 1 : 0,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF065F46) : textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 用户底部信息
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="border-t border-forest-core/10 dark:border-forest-core/20 p-4">
  ///   <div class="flex items-center gap-3 rounded-xl p-2">
  ///     <div class="h-10 w-10 rounded-full bg-forest-core/10 dark:bg-slate-700 overflow-hidden">
  ///       <img class="h-full w-full object-cover" ... />
  ///     </div>
  ///     ...
  ///   </div>
  /// </div>
  /// ```
  Widget _buildUserFooter(bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF065F46).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // 用户头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF065F46).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Symbols.person,
              color: textColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '灵感家 Alex',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'alex@inspiration.app',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 退出按钮
          IconButton(
            onPressed: onLogoutTap,
            icon: Icon(
              Symbols.logout,
              color: textColor.withValues(alpha: 0.4),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
