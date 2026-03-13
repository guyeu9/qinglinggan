import 'package:isar/isar.dart';
import '../../domain/entities/association.dart';
import '../../domain/repositories/association_repository.dart';
import '../models/association_model.dart';

class AssociationRepositoryImpl implements AssociationRepository {
  final Isar _isar;

  AssociationRepositoryImpl(this._isar);

  @override
  Future<AssociationEntity> save(AssociationEntity association) async {
    return await _isar.writeTxn(() async {
      final model = AssociationModel.fromEntity(association);
      final id = await _isar.associationModels.put(model);
      return association.copyWith(id: id);
    });
  }

  @override
  Future<List<AssociationEntity>> getBySourceIdeaId(int ideaId) async {
    final models = await _isar.associationModels
        .where()
        .sourceIdeaIdEqualTo(ideaId)
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<AssociationEntity>> getByTargetIdeaId(int ideaId) async {
    final models = await _isar.associationModels
        .where()
        .targetIdeaIdEqualTo(ideaId)
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<AssociationEntity>> getByIdeaId(int ideaId) async {
    final sourceModels = await _isar.associationModels
        .where()
        .sourceIdeaIdEqualTo(ideaId)
        .findAll();
    final targetModels = await _isar.associationModels
        .where()
        .targetIdeaIdEqualTo(ideaId)
        .findAll();

    final allModels = <AssociationModel>[...sourceModels, ...targetModels];
    final seenIds = <int>{};
    final uniqueModels = allModels.where((m) => seenIds.add(m.id)).toList();

    return uniqueModels.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AssociationEntity?> getById(int id) async {
    final model = await _isar.associationModels.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> deleteBySourceIdeaId(int ideaId) async {
    await _isar.writeTxn(() async {
      await _isar.associationModels
          .where()
          .sourceIdeaIdEqualTo(ideaId)
          .deleteAll();
    });
  }

  @override
  Future<void> deleteByIdeaId(int ideaId) async {
    await _isar.writeTxn(() async {
      await _isar.associationModels
          .where()
          .sourceIdeaIdEqualTo(ideaId)
          .deleteAll();
      await _isar.associationModels
          .where()
          .targetIdeaIdEqualTo(ideaId)
          .deleteAll();
    });
  }

  @override
  Future<void> deleteAll() async {
    await _isar.writeTxn(() async {
      await _isar.associationModels.clear();
    });
  }

  @override
  Future<int> countByIdeaId(int ideaId) async {
    final sourceCount = await _isar.associationModels
        .where()
        .sourceIdeaIdEqualTo(ideaId)
        .count();
    final targetCount = await _isar.associationModels
        .where()
        .targetIdeaIdEqualTo(ideaId)
        .count();
    return sourceCount + targetCount;
  }
}
