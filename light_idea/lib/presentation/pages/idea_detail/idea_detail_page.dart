import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../application/providers/idea_detail_provider.dart';
import '../../../../application/ai/ai_embedding_service.dart';

/// 灵感详情页
/// 
/// 严格按照原型图 HTML 代码实现：
/// - 顶部导航栏: bg-background-light/80 dark:bg-background-dark/80 backdrop-blur-md
/// - 原始记录区: p-4 rounded-xl border border-primary/20 bg-white
/// - AI解析区: bg-accent/20 border border-accent/30
/// - 关联灵感轴: 相似/互补/演进三种类型
/// - 智能优化建议: 共同点/差异点/综合优化版本
class IdeaDetailPage extends ConsumerStatefulWidget {
  final String ideaId;

  const IdeaDetailPage({
    super.key,
    required this.ideaId,
  });

  @override
  ConsumerState<IdeaDetailPage> createState() => _IdeaDetailPageState();
}

class _IdeaDetailPageState extends ConsumerState<IdeaDetailPage> {
  late TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    // 加载真实数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ideaDetailProvider.notifier).loadIdea(int.parse(widget.ideaId));
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // 保存编辑
        _saveContent();
      } else {
        // 进入编辑模式
        final state = ref.read(ideaDetailProvider);
        if (state.idea != null) {
          _contentController.text = state.idea!.content;
        }
      }
      _isEditing = !_isEditing;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _saveContent() async {
    final text = _contentController.text.trim();
    if (text.isNotEmpty) {
      final success = await ref.read(ideaDetailProvider.notifier).updateContent(text);
      if (success && mounted) {
        _showSnackBar('已保存修改');
      }
    }
  }

  void _deleteIdea() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除灵感'),
        content: const Text('确定要删除这条灵感吗？删除后可以在回收站中恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(ideaDetailProvider.notifier).deleteIdea();
              if (success && mounted) {
                context.pop();
                _showSnackBar('已移至回收站');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _shareIdea() {
    _showSnackBar('分享功能开发中...');
  }

  void _showMoreOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.archive),
              title: const Text('归档'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('已归档');
              },
            ),
            ListTile(
              leading: const Icon(Symbols.folder_copy),
              title: const Text('移动到分类'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryPicker();
              },
            ),
            ListTile(
              leading: const Icon(Symbols.label),
              title: const Text('管理标签'),
              onTap: () {
                Navigator.pop(context);
                _showTagManager();
              },
            ),
            ListTile(
              leading: const Icon(Symbols.delete, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteIdea();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    _showSnackBar('分类选择功能开发中...');
  }

  void _showTagManager() {
    _showSnackBar('标签管理功能开发中...');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(ideaDetailProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.idea == null
              ? _buildErrorState(isDark)
              : CustomScrollView(
                  slivers: [
                    // 顶部导航栏
                    _buildAppBar(isDark),
                    
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 原始记录区
                            _buildOriginalRecordSection(isDark, state),
                            
                            const SizedBox(height: 24),
                            
                            // AI解析区
                            if (state.analysis != null)
                              _buildAIAnalysisSection(isDark, state),

                            const SizedBox(height: 24),

                            // 综合分析区
                            if (state.analysis != null && 
                                (state.analysis!.commonPoints.isNotEmpty || 
                                 state.analysis!.differences.isNotEmpty || 
                                 (state.analysis!.mergedIdea ?? '').isNotEmpty))
                              _buildSynthesisSection(isDark, state),

                            const SizedBox(height: 24),

                            // 关联灵感轴
                            if (state.relatedIdeas.isNotEmpty)
                              _buildRelatedIdeasSection(isDark, state),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  /// 顶部导航栏
  /// 
  /// 原型图代码：
  /// ```html
  /// <nav class="sticky top-0 z-50 bg-background-light/80 dark:bg-background-dark/80 backdrop-blur-md border-b border-secondary/20">
  /// ```
  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark 
          ? const Color(0xFF022c22).withValues(alpha: 0.8)
          : const Color(0xFFF0FDF4).withValues(alpha: 0.8),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          '灵感详情',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF065F46),
          ),
        ),
        centerTitle: true,
      ),
      leading: IconButton(
        icon: const Icon(Symbols.arrow_back, color: Color(0xFF065F46)),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Symbols.share, color: Color(0xFF065F46)),
          onPressed: _shareIdea,
        ),
        IconButton(
          icon: const Icon(Symbols.more_vert, color: Color(0xFF065F46)),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  /// 原始记录区
  /// 
  /// 原型图代码：
  /// ```html
  /// <div class="p-4 rounded-xl border border-primary/20 bg-white dark:bg-background-dark/50 shadow-sm hover-lift">
  /// ```
  Widget _buildOriginalRecordSection(bool isDark, IdeaDetailState state) {
    final idea = state.idea!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和操作按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '原始记录',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF065F46),
                letterSpacing: 1,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isEditing ? Symbols.check : Symbols.edit,
                    size: 20,
                    color: const Color(0xFF065F46),
                  ),
                  onPressed: _toggleEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Symbols.delete,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: _deleteIdea,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 内容卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF022c22).withValues(alpha: 0.5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF065F46).withValues(alpha: 0.2),
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
              // 内容
              if (_isEditing)
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入灵感内容...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF065F46).withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              else
                Text(
                  idea.content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF065F46),
                    height: 1.5,
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // 时间和地点
              Row(
                children: [
                  Icon(
                    Symbols.schedule,
                    size: 14,
                    color: const Color(0xFF065F46).withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(idea.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF065F46).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// AI解析区
  /// 
  /// 原型图代码：
  /// ```html
  /// <div class="p-4 rounded-xl bg-accent/20 border border-accent/30 space-y-3 hover-lift">
  /// ```
  Widget _buildAIAnalysisSection(bool isDark, IdeaDetailState state) {
    final analysis = state.analysis!;
    final tags = state.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 解析',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF065F46),
            letterSpacing: 1,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFBAE6FD).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFBAE6FD).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标签
              if (tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6EE7B7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#${tag.name}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // AI分析内容
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Symbols.auto_awesome,
                    size: 20,
                    color: Color(0xFF065F46),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      analysis.summary,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : const Color(0xFF065F46).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 综合分析区
  /// 
  /// 展示共同点、差异点和综合优化版本
  Widget _buildSynthesisSection(bool isDark, IdeaDetailState state) {
    final analysis = state.analysis!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '智能优化建议',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF065F46),
            letterSpacing: 1,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFA78BFA).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 共同点
              if (analysis.commonPoints.isNotEmpty) ...[
                _buildSynthesisItem(
                  icon: Symbols.link,
                  label: '共同点',
                  items: analysis.commonPoints,
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
              ],
              
              // 差异点
              if (analysis.differences.isNotEmpty) ...[
                _buildSynthesisItem(
                  icon: Symbols.compare_arrows,
                  label: '差异点',
                  items: analysis.differences,
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
              ],
              
              // 综合优化版本
              if ((analysis.mergedIdea ?? '').isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Symbols.auto_awesome,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '综合优化版本',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF065F46).withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            analysis.mergedIdea!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark ? Colors.white70 : const Color(0xFF065F46).withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSynthesisItem({
    required IconData icon,
    required String label,
    required List<String> items,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46).withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 6),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.white70 : const Color(0xFF065F46).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  /// 关联灵感轴
  /// 
  /// 原型图代码：
  /// ```html
  /// <div class="flex flex-col gap-3">
  ///   <!-- Similar -->
  ///   <div class="space-y-2">
  ///     <div class="flex items-center gap-2 px-1">
  ///       <span class="size-2 rounded-full bg-blue-500"></span>
  ///       <span class="text-xs font-bold text-slate-500">相似</span>
  ///     </div>
  /// ```
  Widget _buildRelatedIdeasSection(bool isDark, IdeaDetailState state) {
    final relatedIdeas = state.relatedIdeas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '关联灵感轴',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF065F46),
              letterSpacing: 1,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...relatedIdeas.map((SimilarIdea related) => _buildRelatedIdeaItem(related, isDark)),
      ],
    );
  }

  Widget _buildRelatedIdeaItem(SimilarIdea related, bool isDark) {
    final typeColor = Colors.blue;
    const typeLabel = '相似';
    final similarityPercent = (related.similarity * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类型标签
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                typeLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46).withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Text(
                '$similarityPercent% 相似',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF065F46).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 内容卡片
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF022c22).withValues(alpha: 0.4) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF065F46).withValues(alpha: 0.1),
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
                  child: Text(
                    related.idea.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF065F46),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
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
          ElevatedButton(
            onPressed: () {
              ref.read(ideaDetailProvider.notifier).loadIdea(int.parse(widget.ideaId));
            },
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(time.year, time.month, time.day);

    if (date == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} 捕捉于';
    } else if (date == yesterday) {
      return '昨天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
