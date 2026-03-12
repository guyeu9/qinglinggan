import '../../data/api/openai_client.dart';
import '../../data/api/api_models.dart';
import '../../core/utils/result.dart';
import '../../core/logger/app_logger.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/ai_exceptions.dart';

class AIUnderstandingService {
  final OpenAIClient _client;
  final AppLogger _logger;

  AIUnderstandingService(this._client, this._logger);

  static const String _systemPrompt = '''你是一个专业的内容分析助手。你的任务是分析用户输入的灵感内容，并返回结构化的分析结果。

请根据内容的性质，将其归类到以下三个分类之一：
1. 灵感想法 - 创意、想法、灵感闪现
2. 待办事项 - 需要执行的任务、计划
3. 学习笔记 - 知识、学习内容、笔记

请生成以下内容：
1. 分类：从上述三个分类中选择最合适的一个
2. 标签：生成3-5个相关标签
3. 摘要：用一句话概括内容核心（不超过50字）
4. AI提示语：基于内容生成一个引导性的问题或建议，帮助用户深入思考

请以JSON格式返回结果，格式如下：
```json
{
  "categoryName": "分类名称",
  "tags": ["标签1", "标签2", "标签3"],
  "summary": "内容摘要",
  "aiHint": "AI提示语"
}
```

注意：
- 标签要简洁、准确，避免重复
- 摘要要抓住核心要点
- AI提示语要有启发性，帮助用户延伸思考''';

  Future<Result<AIAnalysisResult>> analyze(String content) async {
    if (content.trim().isEmpty) {
      _logger.warning('AI分析失败: 内容为空');
      return Result.error('内容不能为空');
    }

    if (content.length > AppConstants.maxContentLength) {
      _logger.warning('AI分析失败: 内容过长 (${content.length})');
      return Result.error('内容长度超过限制');
    }

    try {
      _logger.info('开始AI内容分析: ${content.length}字符');

      final response = await _client.chat(_systemPrompt, content);

      if (response.isEmpty) {
        _logger.error('AI分析失败: 响应为空');
        return Result.error('AI分析失败: 响应为空');
      }

      final result = AIAnalysisResult.parseFromJsonString(response);

      _logger.info('AI内容分析完成: 分类=${result.categoryName}, 标签数=${result.tags.length}');

      return Result.success(result);
    } on AIEmptyResponseException catch (e) {
      _logger.error('AI分析失败: 响应为空', e);
      return Result.error('AI返回空响应，请重试');
    } on AIResponseParseException catch (e) {
      _logger.error('AI分析失败: JSON解析错误: ${e.message}');
      return Result.error('AI响应格式错误: ${e.message}');
    } on AIInvalidResponseStructureException catch (e) {
      _logger.error('AI分析失败: 响应结构不正确: ${e.message}');
      return Result.error('AI响应结构不正确: ${e.message}');
    } on AIException catch (e) {
      _logger.error('AI分析失败', e);
      return Result.error('AI分析失败: ${e.message}');
    } catch (e, st) {
      _logger.error('AI内容分析失败', e, st);
      return Result.error('AI分析失败: $e', e);
    }
  }

  Future<Result<String>> generateSummary(String content) async {
    if (content.trim().isEmpty) {
      return Result.error('内容不能为空');
    }

    try {
      final response = await _client.chat(
        '请用一句话概括以下内容的核心要点，不超过50字：',
        content,
      );
      return Result.success(response);
    } catch (e, st) {
      _logger.error('生成摘要失败', e, st);
      return Result.error('生成摘要失败: $e', e);
    }
  }

  Future<Result<List<String>>> generateTags(String content) async {
    if (content.trim().isEmpty) {
      return Result.error('内容不能为空');
    }

    try {
      final response = await _client.chat(
        '''请为以下内容生成3-5个相关标签。只返回标签列表，用逗号分隔，不要其他内容。
示例格式：创意,设计,产品''',
        content,
      );

      final tags = response
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .take(5)
          .toList();

      return Result.success(tags);
    } catch (e, st) {
      _logger.error('生成标签失败', e, st);
      return Result.error('生成标签失败: $e', e);
    }
  }

  Future<Result<String>> generateHint(String content) async {
    if (content.trim().isEmpty) {
      return Result.error('内容不能为空');
    }

    try {
      final response = await _client.chat(
        '''基于以下灵感内容，生成一个引导性的问题或建议，帮助用户深入思考。
要求：简洁有启发性，不超过100字。''',
        content,
      );
      return Result.success(response);
    } catch (e, st) {
      _logger.error('生成AI提示语失败', e, st);
      return Result.error('生成AI提示语失败: $e', e);
    }
  }
}
