import '../../data/api/openai_client.dart';
import '../../core/utils/result.dart';
import '../../core/utils/vector_math.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';

class SimilarIdea {
  final IdeaEntity idea;
  final double similarity;

  const SimilarIdea({
    required this.idea,
    required this.similarity,
  });

  @override
  String toString() => 'SimilarIdea(ideaId: ${idea.id}, similarity: $similarity)';
}

class AIEmbeddingService {
  final OpenAIClient _client;
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;

  AIEmbeddingService(this._client, this._ideaRepository, this._logger);

  Future<Result<List<double>>> generateEmbedding(String content) async {
    if (content.trim().isEmpty) {
      _logger.warning('生成Embedding失败: 内容为空');
      return Result.error('内容不能为空');
    }

    try {
      _logger.info('开始生成Embedding: ${content.length}字符');

      final embedding = await _client.generateEmbedding(content);

      if (embedding.isEmpty) {
        _logger.error('生成Embedding失败: 响应为空');
        return Result.error('生成Embedding失败: 响应为空');
      }

      final normalized = VectorMath.normalize(embedding);

      _logger.info('Embedding生成完成: ${normalized.length}维');

      return Result.success(normalized);
    } catch (e, st) {
      _logger.error('生成Embedding失败', e, st);
      return Result.error('生成Embedding失败: $e', e);
    }
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    return VectorMath.cosineSimilarity(a, b);
  }

  Future<Result<List<SimilarIdea>>> searchSimilar(
    List<double> queryEmbedding, {
    int topN = 10,
    double threshold = 0.3,
    int? excludeId,
  }) async {
    if (queryEmbedding.isEmpty) {
      _logger.warning('搜索相似灵感失败: 查询向量为空');
      return Result.error('查询向量不能为空');
    }

    try {
      _logger.info('开始搜索相似灵感: topN=$topN, threshold=$threshold');

      final allIdeas = await _ideaRepository.getAll(includeDeleted: false);

      final candidates = allIdeas.where((idea) {
        if (idea.embedding == null || idea.embedding!.isEmpty) {
          return false;
        }
        if (excludeId != null && idea.id == excludeId) {
          return false;
        }
        return true;
      }).toList();

      if (candidates.isEmpty) {
        _logger.info('没有可搜索的灵感');
        return Result.success([]);
      }

      final results = <SimilarIdea>[];
      for (final idea in candidates) {
        final similarity = VectorMath.cosineSimilarity(
          queryEmbedding,
          idea.embedding!,
        );
        if (similarity >= threshold) {
          results.add(SimilarIdea(idea: idea, similarity: similarity));
        }
      }

      results.sort((a, b) => b.similarity.compareTo(a.similarity));
      final topResults = results.take(topN).toList();

      _logger.info('搜索完成: 找到${results.length}个相似灵感, 返回前${topResults.length}个');

      return Result.success(topResults);
    } catch (e, st) {
      _logger.error('搜索相似灵感失败', e, st);
      return Result.error('搜索相似灵感失败: $e', e);
    }
  }

  Future<Result<List<SimilarIdea>>> findSimilarIdeas(
    int ideaId, {
    int topN = 10,
    double threshold = 0.3,
  }) async {
    try {
      final idea = await _ideaRepository.getById(ideaId);
      if (idea == null) {
        return Result.error('灵感不存在');
      }

      if (idea.embedding == null || idea.embedding!.isEmpty) {
        return Result.error('灵感尚未生成向量');
      }

      return searchSimilar(
        idea.embedding!,
        topN: topN,
        threshold: threshold,
        excludeId: ideaId,
      );
    } catch (e, st) {
      _logger.error('查找相似灵感失败', e, st);
      return Result.error('查找相似灵感失败: $e', e);
    }
  }

  List<double> normalizeVector(List<double> vector) {
    return VectorMath.normalize(vector);
  }

  double dotProduct(List<double> a, List<double> b) {
    return VectorMath.dotProduct(a, b);
  }

  double euclideanDistance(List<double> a, List<double> b) {
    return VectorMath.euclideanDistance(a, b);
  }
}
