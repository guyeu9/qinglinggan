import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/idea.dart';
import '../../../../domain/entities/ai_analysis.dart';
import '../../../../domain/entities/tag.dart';

/// 灵感详情页
///
/// 原型图: 2灵感详情页
/// 功能: 展示灵感详情、AI解析、关联灵感、智能优化建议
class IdeaDetailPage extends StatefulWidget {
  /// 灵感ID
  final String ideaId;

  const IdeaDetailPage({
    super.key,
    required this.ideaId,
  });

  @override
  State<IdeaDetailPage> createState() => _IdeaDetailPageState();
}

class _IdeaDetailPageState extends State<IdeaDetailPage> {
  bool _isLoading = true;
  bool _isEditing = false;
  late TextEditingController _contentController;

  // 模拟数据
  late IdeaEntity _idea;
  AIAnalysisEntity? _aiAnalysis;
  List<TagEntity> _tags = [];
  List<Map<String, dynamic>> _relatedIdeas = [];
  Map<String, dynamic>? _optimizationSuggestion;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // 模拟加载数据
    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() {
      // 模拟灵感数据
      _idea = IdeaEntity(
        id: int.parse(widget.ideaId),
        content: '尝试用极简主义风格重新设计个人主页，采用大量留白和柔和的绿色调，让内容本身成为焦点。可以考虑加入微交互动画，让页面更有生命力。',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        categoryId: 1,
        aiStatus: AIStatus.completed,
        tagIds: [1, 2, 3],
      );

      _contentController.text = _idea.content;

      // 模拟AI分析数据
      _aiAnalysis = AIAnalysisEntity(
        id: 1,
        ideaId: _idea.id,
        categoryResult: 1,
        tagResults: [1, 2, 3],
        summary: '这是一个关于极简主义网页设计的创意想法，强调留白和绿色调的使用，同时考虑加入微交互动画提升用户体验。',
        aiHint: '建议参考Apple官网的设计风格，同时可以研究一下Material Design 3中的动效规范。',
        status: AnalysisStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      // 模拟标签数据
      _tags = [
        TagEntity(id: 1, name: '设计', createdAt: DateTime.now()),
        TagEntity(id: 2, name: '极简主义', createdAt: DateTime.now()),
        TagEntity(id: 3, name: '网页开发', createdAt: DateTime.now()),
        TagEntity(id: 4, name: 'UI/UX', createdAt: DateTime.now()),
      ];

      // 模拟关联灵感数据
      _relatedIdeas = [
        {
          'id': '2',
          'type': 'similar',
          'title': '相似灵感',
          'content': '使用单色调配色方案打造个人作品集网站，强调排版和字体的表现力。',
          'similarity': 0.85,
        },
        {
          'id': '3',
          'type': 'complementary',
          'title': '互补灵感',
          'content': '响应式设计中如何处理不同屏幕尺寸下的留白比例问题。',
          'similarity': 0.72,
        },
        {
          'id': '4',
          'type': 'evolution',
          'title': '演进灵感',
          'content': '从极简主义到 brutalism 设计风格的演变思考。',
          'similarity': 0.68,
        },
      ];

      // 模拟智能优化建议
      _optimizationSuggestion = {
        'commonPoints': [
          '都强调视觉简洁性',
          '都关注用户体验',
          '都使用现代设计语言',
        ],
        'differences': [
          '配色方案选择不同',
          '动效复杂程度有差异',
          '目标受众定位不同',
        ],
        'optimizedVersion': '基于极简主义理念，采用柔和绿色为主色调，配合精心设计的微交互动画。参考 Apple 的简洁美学与 Material Design 的动效规范，创建一个既美观又实用的个人主页。重点关注响应式设计，确保在各种设备上都能保持良好的留白比例和视觉层次。',
      };

      _isLoading = false;
    });
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // 保存编辑
        _idea = _idea.copyWith(
          content: _contentController.text,
          updatedAt: DateTime.now(),
        );
        _showSnackBar('已保存修改');
      }
      _isEditing = !_isEditing;
    });
    HapticFeedback.mediumImpact();
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
            onPressed: () {
              Navigator.pop(context);
              context.pop();
              _showSnackBar('已移至回收站');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
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
              leading: const Icon(Symbols.delete, color: AppColors.error),
              title: const Text('删除', style: TextStyle(color: AppColors.error)),
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // 顶部导航栏
                _buildAppBar(isDark),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 原始记录区
                        _buildOriginalRecordSection(isDark),
                        
                        const SizedBox(height: AppTheme.spacingLg),
                        
                        // AI解析区
                        if (_aiAnalysis != null)
                          _buildAIAnalysisSection(isDark),
                        
                        const SizedBox(height: AppTheme.spacingLg),
                        
                        // 关联灵感轴
                        if (_relatedIdeas.isNotEmpty)
                          _buildRelatedIdeasSection(isDark),
                        
                        const SizedBox(height: AppTheme.spacingLg),
                        
                        // 智能优化建议
                        if (_optimizationSuggestion != null)
                          _buildOptimizationSection(isDark),
                        
                        const SizedBox(height: AppTheme.spacingXl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '灵感详情',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.backgroundDark, AppColors.cardDark]
                  : [AppColors.primaryDark, AppColors.primary],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Symbols.share),
          onPressed: _shareIdea,
        ),
        IconButton(
          icon: const Icon(Symbols.more_vert),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  /// 构建原始记录区
  Widget _buildOriginalRecordSection(bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和操作按钮
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    Symbols.edit_document,
                    size: 20,
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '原始记录',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // 编辑按钮
                IconButton(
                  icon: Icon(
                    _isEditing ? Symbols.check : Symbols.edit,
                    size: 20,
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                  ),
                  onPressed: _toggleEdit,
                  tooltip: _isEditing ? '保存' : '编辑',
                ),
                // 删除按钮
                IconButton(
                  icon: const Icon(
                    Symbols.delete,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onPressed: _deleteIdea,
                  tooltip: '删除',
                ),
              ],
            ),
            
            const Divider(height: AppTheme.spacingLg),
            
            // 内容区域
            if (_isEditing)
              TextField(
                controller: _contentController,
                maxLines: null,
                style: TextStyle(
                  color: textColor,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: '输入灵感内容...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
              )
            else
              Text(
                _idea.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  height: 1.6,
                ),
              ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // 时间和地点信息
            Row(
              children: [
                Icon(
                  Symbols.schedule,
                  size: 16,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatFull(_idea.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Icon(
                  Symbols.location_on,
                  size: 16,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '北京市朝阳区',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            
            // 更新时间
            if (_idea.updatedAt != _idea.createdAt)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '更新于 ${DateFormatter.formatRelative(_idea.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建AI解析区
  Widget _buildAIAnalysisSection(bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    Symbols.auto_awesome,
                    size: 20,
                    color: isDark ? AppColors.accent : AppColors.accentDark,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'AI 智能解析',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_aiAnalysis!.status == AnalysisStatus.processing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            
            const Divider(height: AppTheme.spacingLg),
            
            // 标签列表
            if (_tags.isNotEmpty) ...[
              Text(
                '智能标签',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Wrap(
                spacing: AppTheme.spacingSm,
                runSpacing: AppTheme.spacingSm,
                children: _tags.map((tag) => _buildTagChip(tag, isDark)).toList(),
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            
            // AI摘要
            if (_aiAnalysis!.summary.isNotEmpty) ...[
              Text(
                '内容摘要',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  _aiAnalysis!.summary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
            
            // AI提示
            if (_aiAnalysis!.aiHint.isNotEmpty) ...[
              Text(
                'AI 建议',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Symbols.lightbulb,
                      size: 18,
                      color: isDark ? AppColors.accent : AppColors.accentDark,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        _aiAnalysis!.aiHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建标签Chip
  Widget _buildTagChip(TagEntity tag, bool isDark) {
    return Chip(
      label: Text(tag.name),
      backgroundColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  /// 构建关联灵感轴
  Widget _buildRelatedIdeasSection(bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    Symbols.hub,
                    size: 20,
                    color: isDark ? AppColors.warning : AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '关联灵感轴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const Divider(height: AppTheme.spacingLg),
            
            // 关联灵感列表
            ..._relatedIdeas.asMap().entries.map((entry) {
              final index = entry.key;
              final idea = entry.value;
              return _buildRelatedIdeaCard(idea, isDark, isLast: index == _relatedIdeas.length - 1);
            }),
          ],
        ),
      ),
    );
  }

  /// 构建关联灵感卡片
  Widget _buildRelatedIdeaCard(Map<String, dynamic> idea, bool isDark, {required bool isLast}) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    
    final type = idea['type'] as String;
    final title = idea['title'] as String;
    final content = idea['content'] as String;
    final similarity = idea['similarity'] as double;
    
    Color typeColor;
    IconData typeIcon;
    
    switch (type) {
      case 'similar':
        typeColor = AppColors.info;
        typeIcon = Icons.compare_arrows;
        break;
      case 'complementary':
        typeColor = AppColors.success;
        typeIcon = Symbols.add_circle;
        break;
      case 'evolution':
        typeColor = AppColors.warning;
        typeIcon = Symbols.trending_up;
        break;
      default:
        typeColor = AppColors.primary;
        typeIcon = Symbols.lightbulb;
    }

    return InkWell(
      onTap: () {
        // 跳转到关联灵感详情
        _showSnackBar('查看关联灵感: ${idea['id']}');
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        margin: EdgeInsets.only(bottom: isLast ? 0 : AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: typeColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(typeIcon, size: 16, color: typeColor),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                  ),
                  child: Text(
                    '${(similarity * 100).toInt()}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建智能优化建议区
  Widget _buildOptimizationSection(bool isDark) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final commonPoints = _optimizationSuggestion!['commonPoints'] as List<String>;
    final differences = _optimizationSuggestion!['differences'] as List<String>;
    final optimizedVersion = _optimizationSuggestion!['optimizedVersion'] as String;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    Symbols.psychology,
                    size: 20,
                    color: isDark ? AppColors.success : AppColors.success,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  '智能优化建议',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const Divider(height: AppTheme.spacingLg),
            
            // 共同点
            Text(
              '共同点',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ...commonPoints.map((point) => _buildPointItem(point, AppColors.success, isDark)),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // 差异点
            Text(
              '差异点',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ...differences.map((point) => _buildPointItem(point, AppColors.warning, isDark)),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // 综合优化版本
            Text(
              '综合优化版本',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    optimizedVersion,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _showSnackBar('已复制优化版本');
                        },
                        icon: const Icon(Symbols.content_copy, size: 18),
                        label: const Text('复制'),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      FilledButton.icon(
                        onPressed: () {
                          _showSnackBar('已应用优化版本');
                        },
                        icon: const Icon(Symbols.check, size: 18),
                        label: const Text('应用'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建要点项
  Widget _buildPointItem(String point, Color color, bool isDark) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.check_circle,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              point,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
