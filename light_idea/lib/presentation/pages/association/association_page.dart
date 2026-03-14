import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../application/providers/app_providers.dart';
import '../../../domain/entities/association.dart';
import '../../../domain/entities/idea.dart';
import '../../../domain/entities/tag.dart';

class AssociationPage extends ConsumerStatefulWidget {
  final int ideaId;

  const AssociationPage({super.key, required this.ideaId});

  @override
  ConsumerState<AssociationPage> createState() => _AssociationPageState();
}

class _AssociationPageState extends ConsumerState<AssociationPage> {
  List<AssociationEntity> _associations = [];
  Map<int, IdeaEntity> _relatedIdeas = {};
  Map<int, List<TagEntity>> _ideaTags = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final associationRepo = ref.read(associationRepositoryProvider);
      final ideaRepo = ref.read(ideaRepositoryProvider);
      final tagRepo = ref.read(tagRepositoryProvider);

      final associations = await associationRepo.getByIdeaId(widget.ideaId);

      final ideaIds = <int>{};
      for (final assoc in associations) {
        ideaIds.add(assoc.sourceIdeaId);
        ideaIds.add(assoc.targetIdeaId);
      }
      ideaIds.remove(widget.ideaId);

      final relatedIdeas = <int, IdeaEntity>{};
      final ideaTags = <int, List<TagEntity>>{};

      for (final ideaId in ideaIds) {
        final idea = await ideaRepo.getById(ideaId);
        if (idea != null) {
          relatedIdeas[ideaId] = idea;

          if (idea.categoryId != null) {
            final analysisRepo = ref.read(aiAnalysisRepositoryProvider);
            final analysis = await analysisRepo.getByIdeaId(ideaId);
            if (analysis != null && analysis.tagResults.isNotEmpty) {
              final tags = <TagEntity>[];
              for (final tagId in analysis.tagResults) {
                final tag = await tagRepo.getById(tagId);
                if (tag != null) tags.add(tag);
              }
              ideaTags[ideaId] = tags;
            }
          }
        }
      }

      setState(() {
        _associations = associations;
        _relatedIdeas = relatedIdeas;
        _ideaTags = ideaTags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Symbols.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF065F46),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '关联内容',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF065F46),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_associations.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final similarAssociations = _associations.where((a) => a.type == RelationType.similar).toList();
    final complementaryAssociations = _associations.where((a) => a.type == RelationType.complementary).toList();
    final evolutionaryAssociations = _associations.where((a) => a.type == RelationType.evolutionary).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsCard(isDark),
          const SizedBox(height: 24),
          if (similarAssociations.isNotEmpty) ...[
            _buildTypeSection(
              '相似关联',
              const Color(0xFF3B82F6),
              similarAssociations,
              isDark,
            ),
            const SizedBox(height: 20),
          ],
          if (complementaryAssociations.isNotEmpty) ...[
            _buildTypeSection(
              '互补关联',
              const Color(0xFFF59E0B),
              complementaryAssociations,
              isDark,
            ),
            const SizedBox(height: 20),
          ],
          if (evolutionaryAssociations.isNotEmpty) ...[
            _buildTypeSection(
              '演化关联',
              const Color(0xFF8B5CF6),
              evolutionaryAssociations,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.link_off,
            size: 64,
            color: isDark ? Colors.white30 : const Color(0xFF065F46).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无关联内容',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : const Color(0xFF065F46).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '当灵感被AI分析后，会自动建立关联',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white30 : const Color(0xFF065F46).withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(bool isDark) {
    final similarCount = _associations.where((a) => a.type == RelationType.similar).length;
    final complementaryCount = _associations.where((a) => a.type == RelationType.complementary).length;
    final evolutionaryCount = _associations.where((a) => a.type == RelationType.evolutionary).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '关联统计',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                '相似',
                similarCount,
                const Color(0xFF3B82F6),
                isDark,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                '互补',
                complementaryCount,
                const Color(0xFFF59E0B),
                isDark,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                '演化',
                evolutionaryCount,
                const Color(0xFF8B5CF6),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : const Color(0xFF065F46).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection(
    String title,
    Color color,
    List<AssociationEntity> associations,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF065F46),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${associations.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...associations.map((assoc) => _buildAssociationCard(assoc, color, isDark)),
      ],
    );
  }

  Widget _buildAssociationCard(
    AssociationEntity association,
    Color color,
    bool isDark,
  ) {
    final targetId = association.sourceIdeaId == widget.ideaId
        ? association.targetIdeaId
        : association.sourceIdeaId;
    final relatedIdea = _relatedIdeas[targetId];
    final tags = _ideaTags[targetId] ?? [];
    final confidencePercent = (association.confidence * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/idea/$targetId'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.2) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (relatedIdea != null) ...[
                          Text(
                            relatedIdea.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : const Color(0xFF065F46),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else ...[
                          Text(
                            '灵感 #$targetId',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$confidencePercent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.take(5).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#${tag.name}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  )).toList(),
                ),
              ],
              if (association.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Symbols.lightbulb,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          association.reason,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : const Color(0xFF065F46).withValues(alpha: 0.6),
                            height: 1.4,
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
      ),
    );
  }
}
