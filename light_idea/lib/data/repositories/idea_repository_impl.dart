import 'dart:developer' as developer;
import 'package:isar/isar.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import '../models/idea_model.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  final Isar _isar;

  IdeaRepositoryImpl(this._isar);

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async {
    developer.log('save() 开始: idea.id=${idea.id}, content=${idea.content.substring(0, idea.content.length > 50 ? 50 : idea.content.length)}...', name: 'IdeaRepository');
    final model = IdeaModel.fromEntity(idea);
    developer.log('fromEntity完成: model.id=${model.id}', name: 'IdeaRepository');
    
    final id = await _isar.writeTxn(() async {
      final result = await _isar.ideaModels.put(model);
      developer.log('put()完成: result=$result', name: 'IdeaRepository');
      return result;
    });
    
    developer.log('save()完成: 新id=$id', name: 'IdeaRepository');
    
    // 验证保存结果
    final saved = await _isar.ideaModels.get(id);
    developer.log('验证保存: saved=${saved != null}, id=$id', name: 'IdeaRepository');
    
    // 检查总数
    final count = await _isar.ideaModels.count();
    developer.log('当前数据库总记录数: $count', name: 'IdeaRepository');
    
    return idea.copyWith(id: id);
  }

  @override
  Future<IdeaEntity?> getById(int id) async {
    developer.log('getById() 开始: id=$id', name: 'IdeaRepository');
    final model = await _isar.ideaModels.get(id);
    developer.log('getById() 结果: model=${model != null}', name: 'IdeaRepository');
    return model?.toEntity();
  }

  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async {
    developer.log('getAll() 开始: includeDeleted=$includeDeleted', name: 'IdeaRepository');
    
    final models = includeDeleted
        ? await _isar.ideaModels.where().sortByCreatedAtDesc().findAll()
        : await _isar.ideaModels.filter().isDeletedEqualTo(false).sortByCreatedAtDesc().findAll();
    
    developer.log('getAll() 查询到 ${models.length} 条记录', name: 'IdeaRepository');
    
    // 打印每条记录的id
    for (final m in models) {
      developer.log('  - id=${m.id}, content=${m.content.substring(0, m.content.length > 30 ? 30 : m.content.length)}, isDeleted=${m.isDeleted}', name: 'IdeaRepository');
    }
    
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

  @override
  Future<List<IdeaEntity>> getIdeasWithEmbedding({
    int limit = 100,
    int offset = 0,
  }) async {
    final models = await _isar.ideaModels
        .filter()
        .isDeletedEqualTo(false)
        .embeddingIsNotEmpty()
        .sortByCreatedAtDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> countIdeasWithEmbedding() async {
    return _isar.ideaModels
        .filter()
        .isDeletedEqualTo(false)
        .embeddingIsNotEmpty()
        .count();
  }
}
