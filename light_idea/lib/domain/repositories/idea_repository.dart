import '../entities/idea.dart';

abstract class IdeaRepository {
  Future<IdeaEntity> save(IdeaEntity idea);

  Future<IdeaEntity?> getById(int id);

  Future<List<IdeaEntity>> getAll({bool includeDeleted = false});

  Future<List<IdeaEntity>> getByCategory(int categoryId);

  Future<List<IdeaEntity>> getByPage(int offset, int limit);

  Future<int> count({bool includeDeleted = false});

  Future<void> update(IdeaEntity idea);

  Future<void> updateAIStatus(int id, AIStatus status);

  Future<void> updateEmbedding(int id, List<double> embedding);

  Future<void> softDelete(int id);

  Future<void> restore(int id);

  Future<void> permanentDelete(int id);

  Future<List<IdeaEntity>> searchByContent(String keyword);

  Future<List<IdeaEntity>> getDeleted();

  Future<void> clearDeleted();

  Future<List<IdeaEntity>> getIdeasWithEmbedding({
    int limit = 100,
    int offset = 0,
  });

  Future<int> countIdeasWithEmbedding();
}
