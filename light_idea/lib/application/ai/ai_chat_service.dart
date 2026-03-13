import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../data/api/api_models.dart';
import '../../data/api/openai_client.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import 'ai_embedding_service.dart';

class ChatResponse {
  final String content;
  final List<IdeaEntity> referencedIdeas;

  const ChatResponse({
    required this.content,
    this.referencedIdeas = const [],
  });
}

class AIChatService {
  final OpenAIClient _client;
  final IdeaRepository _ideaRepository;
  final AIEmbeddingService _embeddingService;
  final AppLogger _logger;

  AIChatService(
    this._client,
    this._ideaRepository,
    this._embeddingService,
    this._logger,
  );

  static const String _systemPrompt = '''你是一个专业的灵感管理助手。你的任务是帮助用户管理和分析他们的灵感记录。

你可以：
1. 搜索和查找相关的灵感
2. 总结和分析用户的灵感趋势
3. 提供创意建议和灵感关联
4. 回答关于灵感内容的问题

请用简洁、友好的语气回复。如果引用了用户的灵感记录，请在回复中提及。''';

  Future<Result<List<IdeaEntity>>> searchByNaturalLanguage(String query) async {
    if (query.trim().isEmpty) {
      _logger.warning('自然语言搜索失败: 查询为空');
      return Result.error('查询内容不能为空');
    }

    try {
      _logger.info('开始自然语言搜索: $query');

      final embeddingResult = await _embeddingService.generateEmbedding(query);
      if (embeddingResult.isError) {
        return Result.error(embeddingResult.errorOrNull ?? '生成查询向量失败');
      }

      final queryEmbedding = embeddingResult.dataOrNull!;

      final searchResult = await _embeddingService.searchSimilar(
        queryEmbedding,
        topN: 10,
        threshold: 0.25,
      );

      if (searchResult.isError) {
        return Result.error(searchResult.errorOrNull ?? '搜索失败');
      }

      final similarIdeas = searchResult.dataOrNull!;
      final ideas = similarIdeas.map((s) => s.idea).toList();

      _logger.info('自然语言搜索完成: 找到 ${ideas.length} 条相关灵感');
      return Result.success(ideas);
    } catch (e, st) {
      _logger.error('自然语言搜索失败', e, st);
      return Result.error('搜索失败: $e', e);
    }
  }

  Future<Result<String>> reviewRecentIdeas({int days = 15}) async {
    try {
      _logger.info('开始回顾最近 $days 天的灵感');

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final allIdeas = await _ideaRepository.getAll(includeDeleted: false);

      final recentIdeas = allIdeas
          .where((idea) => idea.createdAt.isAfter(cutoffDate))
          .toList();

      if (recentIdeas.isEmpty) {
        _logger.info('最近 $days 天没有灵感记录');
        return Result.success('最近 $days 天内没有灵感记录。继续记录你的想法吧！');
      }

      recentIdeas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final ideasSummary = recentIdeas
          .take(20)
          .map((idea) => '- ${idea.content}')
          .join('\n');

      final prompt = '''请总结以下用户最近 $days 天的灵感记录，分析趋势和主题：

$ideasSummary

请提供：
1. 主要主题和趋势
2. 灵感数量统计
3. 建议和洞察''';

      final response = await _client.chatCompletion([
        const ChatMessage(role: 'system', content: _systemPrompt),
        ChatMessage(role: 'user', content: prompt),
      ]);

      final content = response.choices.firstOrNull?.message.content ?? '无法生成总结';

      _logger.info('灵感回顾完成');
      return Result.success(content);
    } catch (e, st) {
      _logger.error('灵感回顾失败', e, st);
      return Result.error('回顾失败: $e', e);
    }
  }

  Future<Result<String>> analyzeByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      _logger.info('开始分析时间范围内的灵感: $start - $end');

      final allIdeas = await _ideaRepository.getAll(includeDeleted: false);

      final filteredIdeas = allIdeas
          .where((idea) =>
              idea.createdAt.isAfter(start) && idea.createdAt.isBefore(end))
          .toList();

      if (filteredIdeas.isEmpty) {
        _logger.info('指定时间范围内没有灵感记录');
        return Result.success('该时间范围内没有灵感记录。');
      }

      filteredIdeas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final ideasSummary = filteredIdeas
          .take(30)
          .map((idea) => '- ${idea.content}')
          .join('\n');

      final prompt = '''请分析以下用户在指定时间范围内的灵感记录：

时间范围：${start.toString().substring(0, 10)} 至 ${end.toString().substring(0, 10)}
灵感数量：${filteredIdeas.length} 条

灵感内容：
$ideasSummary

请提供详细的分析和洞察。''';

      final response = await _client.chatCompletion([
        const ChatMessage(role: 'system', content: _systemPrompt),
        ChatMessage(role: 'user', content: prompt),
      ]);

      final content = response.choices.firstOrNull?.message.content ?? '无法生成分析';

      _logger.info('时间范围分析完成');
      return Result.success(content);
    } catch (e, st) {
      _logger.error('时间范围分析失败', e, st);
      return Result.error('分析失败: $e', e);
    }
  }

  Future<Result<ChatResponse>> chat(
    String userMessage, {
    List<int>? contextIdeaIds,
  }) async {
    if (userMessage.trim().isEmpty) {
      _logger.warning('AI对话失败: 消息为空');
      return Result.error('消息不能为空');
    }

    try {
      _logger.info('开始AI对话: ${userMessage.length} 字符');

      final contextIdeas = <IdeaEntity>[];

      if (contextIdeaIds != null && contextIdeaIds.isNotEmpty) {
        for (final id in contextIdeaIds) {
          final idea = await _ideaRepository.getById(id);
          if (idea != null) {
            contextIdeas.add(idea);
          }
        }
      }

      final embeddingResult = await _embeddingService.generateEmbedding(userMessage);
      if (embeddingResult.isSuccess) {
        final queryEmbedding = embeddingResult.dataOrNull!;
        final searchResult = await _embeddingService.searchSimilar(
          queryEmbedding,
          topN: 5,
          threshold: 0.3,
        );

        if (searchResult.isSuccess) {
          for (final similar in searchResult.dataOrNull!) {
            if (!contextIdeas.any((i) => i.id == similar.idea.id)) {
              contextIdeas.add(similar.idea);
            }
          }
        }
      }

      String contextPrompt = '';
      if (contextIdeas.isNotEmpty) {
        contextPrompt = '\n\n用户的相关灵感记录：\n';
        for (final idea in contextIdeas.take(5)) {
          contextPrompt += '- ${idea.content}\n';
        }
      }

      final messages = [
        const ChatMessage(role: 'system', content: _systemPrompt),
        ChatMessage(
          role: 'user',
          content: userMessage + contextPrompt,
        ),
      ];

      final response = await _client.chatCompletion(messages);

      final content = response.choices.firstOrNull?.message.content ?? '抱歉，我无法理解你的问题。';

      _logger.info('AI对话完成');

      return Result.success(ChatResponse(
        content: content,
        referencedIdeas: contextIdeas,
      ));
    } catch (e, st) {
      _logger.error('AI对话失败', e, st);
      return Result.error('对话失败: $e', e);
    }
  }
}
