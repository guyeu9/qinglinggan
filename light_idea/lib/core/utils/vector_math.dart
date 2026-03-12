import 'dart:math';

class VectorMath {
  VectorMath._();

  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same dimension');
    }
    
    if (a.isEmpty) {
      throw ArgumentError('Vectors cannot be empty');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    final denominator = sqrt(normA * normB);
    if (denominator == 0) {
      return 0.0;
    }

    return dotProduct / denominator;
  }

  static List<double> normalize(List<double> vector) {
    if (vector.isEmpty) {
      throw ArgumentError('Vector cannot be empty');
    }

    double norm = 0.0;
    for (final v in vector) {
      norm += v * v;
    }
    norm = sqrt(norm);

    if (norm == 0) {
      return List<double>.filled(vector.length, 0.0);
    }

    return vector.map((v) => v / norm).toList();
  }

  static double dotProduct(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same dimension');
    }

    double result = 0.0;
    for (int i = 0; i < a.length; i++) {
      result += a[i] * b[i];
    }
    return result;
  }

  static double euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have the same dimension');
    }

    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  static List<SimilarityResult> topNSimilar(
    List<double> query,
    List<List<double>> candidates,
    int topN,
  ) {
    if (query.isEmpty || candidates.isEmpty) {
      return [];
    }

    final results = <SimilarityResult>[];
    for (int i = 0; i < candidates.length; i++) {
      if (candidates[i].length != query.length) {
        continue;
      }
      final similarity = cosineSimilarity(query, candidates[i]);
      results.add(SimilarityResult(index: i, similarity: similarity));
    }

    results.sort((a, b) => b.similarity.compareTo(a.similarity));
    return results.take(topN).toList();
  }
}

class SimilarityResult {
  final int index;
  final double similarity;

  const SimilarityResult({
    required this.index,
    required this.similarity,
  });

  @override
  String toString() => 'SimilarityResult(index: $index, similarity: $similarity)';
}
