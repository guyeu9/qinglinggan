import 'dart:convert';
import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../data/api/api_models.dart';
import '../../data/api/openai_client.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/association.dart';

class AIRelationService {
  final OpenAIClient _client;
  final AppLogger _logger;

  AIRelationService(this._client, this._logger);

  static const String _systemPrompt = '''你是一个灵感关联分析专家。你的任务是分析当前灵感与候选灵感之间的关系。

关系类型说明：
1. similar（相似）：内容相似、主题相近、表达方式类似
2. complementary（互补）：内容互补、可以组合形成更完整的方案
3. evolutionary（演化）：当前灵感是候选灵感的演化、升级或细化版本

请根据内容的语义和逻辑关系，判断每条候选灵感与当前灵感的关系类型。

返回 JSON 格式：
{
  "relations": [
    {
      "targetIdeaId": 灵感ID,
      "type": "关系类型",
      "reason": "判断原因",
      "confidence": 置信度(0.0-1.0)
    }
  ]
}

注意：
- 只返回有明确关系的灵感
- 置信度低于 0.5 的关系不要返回
- 原因要简洁明了，不超过 50 字''';

  Future<Result<List<AssociationEntity>>> judgeRelations({
    required IdeaEntity currentIdea,
    required List<IdeaEntity> candidates,
  }) async {
    if (candidates.isEmpty) {
      _logger.info('没有候选灵感，跳过关系判断');
      return Result.success([]);
    }

    try {
      _logger.info('开始关系判断: 当前灵感=${currentIdea.id}, 候选数=${candidates.length}');

      final candidatesText = candidates
          .asMap()
          .entries
          .map((e) => 'ID: ${e.value.id}\n内容: ${e.value.content}')
          .join('\n\n');

      final userPrompt = '''当前灵感：
ID: ${currentIdea.id}
内容: ${currentIdea.content}

候选灵感：
$candidatesText

请分析当前灵感与每条候选灵感的关系。''';

      final response = await _client.chatCompletion([
        ChatMessage(role: 'system', content: _systemPrompt),
        ChatMessage(role: 'user', content: userPrompt),
      ]);

      final content = response.choices.firstOrNull?.message.content;
      if (content == null || content.isEmpty) {
        _logger.warning('AI 返回空内容');
        return Result.success([]);
      }

      final associations = _parseResponse(content, currentIdea.id);
      _logger.info('关系判断完成: 发现 ${associations.length} 条关联');

      return Result.success(associations);
    } catch (e, st) {
      _logger.error('关系判断失败', e, st);
      return Result.error('关系判断失败: $e', e);
    }
  }

  List<AssociationEntity> _parseResponse(String content, int sourceIdeaId) {
    try {
      final jsonStr = _extractJson(content);
      if (jsonStr == null) {
        _logger.warning('无法从响应中提取 JSON');
        return [];
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final relations = json['relations'] as List<dynamic>?;

      if (relations == null) {
        return [];
      }

      final associations = <AssociationEntity>[];

      for (final rel in relations) {
        final targetId = rel['targetIdeaId'] as int?;
        final typeStr = rel['type'] as String?;
        final reason = rel['reason'] as String?;
        final confidence = (rel['confidence'] as num?)?.toDouble();

        if (targetId == null || typeStr == null || reason == null || confidence == null) {
          continue;
        }

        if (confidence < 0.5) {
          continue;
        }

        final type = _parseRelationType(typeStr);
        if (type == null) continue;

        associations.add(AssociationEntity(
          id: 0,
          sourceIdeaId: sourceIdeaId,
          targetIdeaId: targetId,
          type: type,
          reason: reason,
          confidence: confidence,
          createdAt: DateTime.now(),
        ));
      }

      return associations;
    } catch (e, st) {
      _logger.error('解析关系判断结果失败', e, st);
      return [];
    }
  }

  String? _extractJson(String content) {
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    return jsonMatch?.group(0);
  }

  RelationType? _parseRelationType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'similar':
        return RelationType.similar;
      case 'complementary':
        return RelationType.complementary;
      case 'evolutionary':
        return RelationType.evolutionary;
      default:
        return null;
    }
  }
}
