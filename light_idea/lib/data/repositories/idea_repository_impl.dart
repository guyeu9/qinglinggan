import 'package:isar/isar.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import '../models/idea_model.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  final Isar _isar;

  IdeaRepositoryImpl(this._isar);

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async {
    final model = IdeaModel.fromEntity(idea);
    final id = await _isar.writeTxn(() => _isar.ideaModels.put(model));
    return idea.copyWith(id: id);
  }

  @override
  Future<IdeaEntity?> getById(int id) async {
    final model = await _isar.ideaModels.get(id);
    return model?.toEntity();
  }

  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async {
    final models = includeDeleted
        ? await _isar.ideaModels.where().sortByCreatedAtDesc().findAll()
        : await _isar.ideaModels.filter().isDeletedEqualTo(false).sortByCreatedAtDesc().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<IdeaEntity>> getByCategory(int categoryId) async {
    final models = await _isar.ideaModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<IdeaEntity>> getByPage(int offset, int limit) async {
    final models = await _isar.ideaModels
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> count({bool includeDeleted = false}) async {
    if (includeDeleted) {
      return _isar.ideaModels.count();
    }
    return _isar.ideaModels.filter().isDeletedEqualTo(false).count();
  }

  @override
  Future<void> update(IdeaEntity idea) async {
    final model = IdeaModel.fromEntity(idea)..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.ideaModels.put(model));
  }

  @override
  Future<void> updateAIStatus(int id, AIStatus status) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.aiStatus = status;
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }

  @override
  Future<void> updateEmbedding(int id, List<double> embedding) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.embedding = embedding;
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }

  @override
  Future<void> softDelete(int id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.isDeleted = true;
        model.deletedAt = DateTime.now();
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }

  @override
  Future<void> restore(int id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.isDeleted = false;
        model.deletedAt = null;
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }

  @override
  Future<void> permanentDelete(int id) async {
    await _isar.writeTxn(() => _isar.ideaModels.delete(id));
  }

  @override
  Future<List<IdeaEntity>> searchByContent(String keyword) async {
    final models = await _isar.ideaModels
        .filter()
        .isDeletedEqualTo(false)
        .contentContains(keyword)
        .sortByCreatedAtDesc()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<IdeaEntity>> getDeleted() async {
    final models = await _isar.ideaModels
        .filter()
        .isDeletedEqualTo(true)
        .sortByDeletedAtDesc()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> clearDeleted() async {
    await _isar.writeTxn(() async {
      await _isar.ideaModels.filter().isDeletedEqualTo(true).deleteAll();
    });
  }
}
