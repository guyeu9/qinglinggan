import '../entities/association.dart';

abstract class AssociationRepository {
  Future<AssociationEntity> save(AssociationEntity association);

  Future<List<AssociationEntity>> getBySourceIdeaId(int ideaId);

  Future<List<AssociationEntity>> getByTargetIdeaId(int ideaId);

  Future<List<AssociationEntity>> getByIdeaId(int ideaId);

  Future<List<AssociationEntity>> getByIdeaIdAndType(int ideaId, RelationType type);

  Future<AssociationEntity?> getById(int id);

  Future<void> deleteBySourceIdeaId(int ideaId);

  Future<void> deleteByIdeaId(int ideaId);

  Future<void> deleteAll();

  Future<int> countByIdeaId(int ideaId);

  Future<int> countByIdeaIdAndType(int ideaId, RelationType type);
}
