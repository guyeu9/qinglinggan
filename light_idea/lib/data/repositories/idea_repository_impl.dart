import 'package:isar/isar.dart';
import '../../core/services/log_service.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import '../models/idea_model.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  final Isar _isar;

  IdeaRepositoryImpl(this._isar);

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async {
    final logContent = idea.content.substring(0, idea.content.length > 50 ? 50 : idea.content.length);
    logService.i('IdeaRepository', 'save() 开始: idea.id=${idea.id}, content=$logContent...');
    
    final model = IdeaModel.fromEntity(idea);
    logService.d('IdeaRepository', 'fromEntity完成: model.id=${model.id}');
    
    final id = await _isar.writeTxn(() async {
      final result = await _isar.ideaModels.put(model);
      logService.d('IdeaRepository', 'put()完成: result=$result');
      return result;
    });
    
    logService.i('IdeaRepository', 'save()完成: 新id=$id');
    
    // 验证保存结果
    final saved = await _isar.ideaModels.get(id);
    logService.d('IdeaRepository', '验证保存: saved=${saved != null}, id=$id');
    
    // 检查总数
    final count = await _isar.ideaModels.count();
    logService.i('IdeaRepository', '当前数据库总记录数: $count');
    
    return idea.copyWith(id: id);
  }

  @override
  Future<IdeaEntity?> getById(int id) async {
    logService.d('IdeaRepository', 'getById() 开始: id=$id');
    final model = await _isar.ideaModels.get(id);
    logService.d('IdeaRepository', 'getById() 结果: model=${model != null}');
    return model?.toEntity();
  }

  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async {
    logService.i('IdeaRepository', 'getAll() 开始: includeDeleted=$includeDeleted');
    
    final models = includeDeleted
        ? await _isar.ideaModels.where().sortByCreatedAtDesc().findAll()
        : await _isar.ideaModels.filter().isDeletedEqualTo(false).sortByCreatedAtDesc().findAll();
    
    logService.i('IdeaRepository', 'getAll() 查询到 ${models.length} 条记录');
    
    // 打印每条记录的id
    for (final m in models) {
      final content = m.content.substring(0, m.content.length > 30 ? 30 : m.content.length);
      logService.d('IdeaRepository', '  - id=${m.id}, content=$content, isDeleted=${m.isDeleted}');
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
