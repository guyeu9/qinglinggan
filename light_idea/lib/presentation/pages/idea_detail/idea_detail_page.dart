import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../application/providers/idea_detail_provider.dart';
import '../../../../application/providers/app_providers.dart';
import '../../../../application/ai/ai_embedding_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/entities/association.dart';
import '../../../../domain/entities/idea.dart';
import '../../../../domain/entities/tag.dart';

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
  bool _isReanalyzing = false;

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
    final idea = ref.read(ideaDetailProvider).idea;
    if (idea == null) return;
    
    final buffer = StringBuffer();
    buffer.writeln('【轻灵感分享】');
    buffer.writeln('');
    buffer.writeln(idea.content);
    buffer.writeln('');
    buffer.writeln('— 来自「轻灵感」App');
    
    Share.share(
      buffer.toString(),
      subject: '灵感分享',
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

  void _showCategoryPicker() async {
    final categories = await ref.read(categoryRepositoryProvider).getAll();
    
    if (!mounted) return;
    
    final currentIdea = ref.read(ideaDetailProvider).idea;
    if (currentIdea == null) return;
    
    final selectedCategoryId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分类'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat.id == currentIdea.categoryId;
              return RadioListTile<int>(
                title: Row(
                  children: [
                    Text(cat.icon),
                    const SizedBox(width: 8),
                    Text(cat.name),
                  ],
                ),
                value: cat.id,
                groupValue: currentIdea.categoryId,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
                secondary: isSelected ? const Icon(Icons.check, color: Color(0xFF6EE7B7)) : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    
    if (selectedCategoryId != null && selectedCategoryId != currentIdea.categoryId) {
      final success = await ref.read(ideaDetailProvider.notifier).updateCategory(selectedCategoryId);
      if (success && mounted) {
        _showSnackBar('分类已更新');
      }
    }
  }

  void _showTagManager() async {
    final allTags = await ref.read(tagRepositoryProvider).getAll();
    final currentIdea = ref.read(ideaDetailProvider).idea;
    
    if (!mounted || currentIdea == null) return;
    
    final currentTagIds = currentIdea.tagIds.toSet();
    final selectedTagIds = await showDialog<Set<int>>(
      context: context,
      builder: (context) => _TagsSelectionDialog(
        allTags: allTags,
        initialSelectedIds: currentTagIds,
      ),
    );
    
    if (selectedTagIds != null) {
      final success = await ref.read(ideaDetailProvider.notifier)
          .updateTags(selectedTagIds.toList());
      if (success && mounted) {
        _showSnackBar('标签已更新');
      }
    }
  }

  Future<void> _reanalyzeIdea() async {
    if (_isReanalyzing) return;
    
    setState(() => _isReanalyzing = true);
    
    try {
      await ref.read(ideaDetailProvider.notifier).refreshAnalysis();
      
      if (mounted) {
        _showSnackBar('已重新提交分析任务');
      }
    } finally {
      if (mounted) {
        setState(() => _isReanalyzing = false);
      }
    }
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
                            if (state.relatedIdeas.isNotEmpty || state.associations.isNotEmpty)
                              _buildRelatedIdeasSection(isDark, state),

                            // 查看全部关联按钮
                            if (state.associations.isNotEmpty)
                              _buildViewAllAssociationsButton(isDark, state),

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
          icon: _isReanalyzing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF065F46),
                  ),
                )
              : const Icon(Symbols.refresh, color: Color(0xFF065F46)),
          tooltip: '重新分析',
          onPressed: _isReanalyzing ? null : _reanalyzeIdea,
        ),
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
    final associations = state.associations;
    final relatedIdeas = state.relatedIdeas;

    if (associations.isEmpty && relatedIdeas.isEmpty) {
      return const SizedBox.shrink();
    }

    final similarAssociations = associations.where((a) => a.type == RelationType.similar).toList();
    final complementaryAssociations = associations.where((a) => a.type == RelationType.complementary).toList();
    final evolutionaryAssociations = associations.where((a) => a.type == RelationType.evolutionary).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Text(
                '关联灵感轴',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${associations.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        if (similarAssociations.isNotEmpty) ...[
          _buildAssociationTypeSection(
            '相似',
            const Color(0xFF3B82F6),
            similarAssociations,
            state.idea!,
            isDark,
          ),
          const SizedBox(height: 16),
        ],
        
        if (complementaryAssociations.isNotEmpty) ...[
          _buildAssociationTypeSection(
            '互补',
            const Color(0xFFF59E0B),
            complementaryAssociations,
            state.idea!,
            isDark,
          ),
          const SizedBox(height: 16),
        ],
        
        if (evolutionaryAssociations.isNotEmpty) ...[
          _buildAssociationTypeSection(
            '演化',
            const Color(0xFF8B5CF6),
            evolutionaryAssociations,
            state.idea!,
            isDark,
          ),
          const SizedBox(height: 16),
        ],
        
        if (relatedIdeas.isNotEmpty && associations.isEmpty) ...[
          ...relatedIdeas.map((SimilarIdea related) => _buildRelatedIdeaItem(related, isDark)),
        ],
      ],
    );
  }

  Widget _buildAssociationTypeSection(
    String label,
    Color color,
    List<AssociationEntity> associations,
    IdeaEntity currentIdea,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF065F46).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${associations.length}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...associations.map((assoc) => _buildAssociationItem(assoc, currentIdea, color, isDark)),
      ],
    );
  }

  Widget _buildAssociationItem(
    AssociationEntity association,
    IdeaEntity currentIdea,
    Color color,
    bool isDark,
  ) {
    final isSource = association.sourceIdeaId == currentIdea.id;
    final targetId = isSource ? association.targetIdeaId : association.sourceIdeaId;
    final confidencePercent = (association.confidence * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.pushToIdeaDetail(targetId.toString()),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF022c22).withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '灵感 #$targetId',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$confidencePercent%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              if (association.reason.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  association.reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF065F46).withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
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

  Widget _buildViewAllAssociationsButton(bool isDark, IdeaDetailState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: () => context.pushToAssociation(widget.ideaId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.3) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6EE7B7).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.link,
                size: 18,
                color: const Color(0xFF6EE7B7),
              ),
              const SizedBox(width: 8),
              Text(
                '查看全部关联 (${state.associations.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6EE7B7),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Symbols.arrow_forward,
                size: 18,
                color: const Color(0xFF6EE7B7),
              ),
            ],
          ),
        ),
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

class _TagsSelectionDialog extends StatefulWidget {
  final List<TagEntity> allTags;
  final Set<int> initialSelectedIds;

  const _TagsSelectionDialog({
    required this.allTags,
    required this.initialSelectedIds,
  });

  @override
  State<_TagsSelectionDialog> createState() => _TagsSelectionDialogState();
}

class _TagsSelectionDialogState extends State<_TagsSelectionDialog> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelectedIds.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('管理标签'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: widget.allTags.isEmpty
            ? const Center(
                child: Text('暂无标签'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allTags.length,
                itemBuilder: (context, index) {
                  final tag = widget.allTags[index];
                  final isSelected = _selectedIds.contains(tag.id);
                  
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${tag.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedIds.add(tag.id);
                        } else {
                          _selectedIds.remove(tag.id);
                        }
                      });
                    },
                    activeColor: const Color(0xFF6EE7B7),
                    checkColor: const Color(0xFF065F46),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedIds),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6EE7B7),
            foregroundColor: const Color(0xFF065F46),
          ),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
