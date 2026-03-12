import '../entities/ai_analysis.dart';

abstract class AIAnalysisRepository {
  Future<AIAnalysisEntity> save(AIAnalysisEntity analysis);

  Future<AIAnalysisEntity?> getById(int id);

  Future<AIAnalysisEntity?> getByIdeaId(int ideaId);

  Future<List<AIAnalysisEntity>> getAll();

  Future<void> update(AIAnalysisEntity analysis);

  Future<void> updateStatus(int id, AnalysisStatus status);

  Future<void> delete(int id);

  Future<void> deleteByIdeaId(int ideaId);
}
