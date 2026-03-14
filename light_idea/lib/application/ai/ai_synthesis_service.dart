import 'dart:convert';
import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../data/api/api_models.dart';
import '../../data/api/openai_client.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/association.dart';

class SynthesisOutput {
  final List<String> commonPoints;
  final List<String> differences;
  final String mergedIdea;

  const SynthesisOutput({
    required this.commonPoints,
    required this.differences,
    required this.mergedIdea,
  });
}

class AISynthesisService {
  final OpenAIClient _client;
  final AppLogger _logger;

  AISynthesisService(this._client, this._logger);

  static const String _systemPrompt = '''你是一个灵感综合分析专家。你的任务是基于当前灵感和其关联灵感，生成综合分析结果。

分析要求：
1. 共同点：找出当前灵感与关联灵感之间的共同主题、相似元素或共同目标
2. 差异点：分析当前灵感与关联灵感之间的不同之处、互补特性或独特价值
3. 综合优化版本：基于所有灵感的内容，生成一个融合各方优点的优化版本

返回 JSON 格式：
{
  "commonPoints": ["共同点1", "共同点2", ...],
  "differences": ["差异点1", "差异点2", ...],
  "mergedIdea": "综合优化版本的灵感内容"
}

注意：
- 共同点列出2-4条
- 差异点列出2-4条
- 综合优化版本要融合各灵感的优点，形成更完整、更有价值的方案
- 综合优化版本不超过200字
- 所有内容用中文表达''';

  Future<Result<SynthesisOutput>> generateSynthesis({
    required IdeaEntity currentIdea,
    required List<AssociationEntity> associations,
    required List<IdeaEntity> relatedIdeas,
  }) async {
    if (relatedIdeas.isEmpty) {
      _logger.info('没有关联灵感，跳过综合分析');
      return Result.success(const SynthesisOutput(
        commonPoints: [],
        differences: [],
        mergedIdea: '',
      ));
    }

    try {
      _logger.info('开始综合分析: 当前灵感=${currentIdea.id}, 关联数=${relatedIdeas.length}');

      final relatedIdeasText = relatedIdeas.asMap().entries.map((e) {
        final idea = e.value;
        final assoc = associations.where((a) => a.targetIdeaId == idea.id).firstOrNull;
        final relationType = assoc?.type.name ?? 'unknown';
        return '''ID: ${idea.id}
关系类型: $relationType
内容: ${idea.content}''';
      }).join('\n\n');

      final userPrompt = '''当前灵感：
ID: ${currentIdea.id}
内容: ${currentIdea.content}

关联灵感：
$relatedIdeasText

请分析当前灵感与关联灵感的关系，生成共同点、差异点和综合优化版本。''';

      final response = await _client.chatCompletion([
        const ChatMessage(role: 'system', content: _systemPrompt),
        ChatMessage(role: 'user', content: userPrompt),
      ]);

      final content = response.choices.firstOrNull?.message.content;
      if (content == null || content.isEmpty) {
        _logger.warning('AI 返回空内容');
        return Result.success(const SynthesisOutput(
          commonPoints: [],
          differences: [],
          mergedIdea: '',
        ));
      }

      final output = _parseResponse(content);
      _logger.info('综合分析完成: 共同点=${output.commonPoints.length}, 差异点=${output.differences.length}');

      return Result.success(output);
    } catch (e, st) {
      _logger.error('综合分析失败', e, st);
      return Result.error('综合分析失败: $e', e);
    }
  }

  SynthesisOutput _parseResponse(String content) {
    try {
      final jsonStr = _extractJson(content);
      if (jsonStr == null) {
        _logger.warning('无法从响应中提取 JSON');
        return const SynthesisOutput(commonPoints: [], differences: [], mergedIdea: '');
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final commonPoints = (json['commonPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final differences = (json['differences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final mergedIdea = json['mergedIdea'] as String? ?? '';

      return SynthesisOutput(
        commonPoints: commonPoints,
        differences: differences,
        mergedIdea: mergedIdea,
      );
    } catch (e, st) {
      _logger.error('解析综合分析结果失败', e, st);
      return const SynthesisOutput(commonPoints: [], differences: [], mergedIdea: '');
    }
  }

  String? _extractJson(String content) {
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    return jsonMatch?.group(0);
  }
}
