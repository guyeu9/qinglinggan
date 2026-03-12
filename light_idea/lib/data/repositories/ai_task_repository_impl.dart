import 'package:isar/isar.dart';
import '../../domain/entities/ai_task.dart';
import '../../domain/repositories/ai_task_repository.dart';
import '../models/ai_task_model.dart';

class AITaskRepositoryImpl implements AITaskRepository {
  final Isar _isar;

  AITaskRepositoryImpl(this._isar);

  @override
  Future<AITaskEntity> save(AITaskEntity task) async {
    final model = AITaskModel.fromEntity(task);
    final id = await _isar.writeTxn(() => _isar.aITaskModels.put(model));
    return task.copyWith(id: id);
  }

  @override
  Future<AITaskEntity?> getById(int id) async {
    final model = await _isar.aITaskModels.get(id);
    return model?.toEntity();
  }

  @override
  Future<AITaskEntity?> getByIdeaId(int ideaId) async {
    final model = await _isar.aITaskModels.filter().ideaIdEqualTo(ideaId).findFirst();
    return model?.toEntity();
  }

  @override
  Future<List<AITaskEntity>> getPendingTasks() async {
    final models = await _isar.aITaskModels
        .filter()
        .statusEqualTo(TaskStatus.pending)
        .sortByCreatedAt()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<AITaskEntity>> getProcessingTasks() async {
    final models = await _isar.aITaskModels
        .filter()
        .statusEqualTo(TaskStatus.processing)
        .sortByCreatedAt()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> update(AITaskEntity task) async {
    final model = AITaskModel.fromEntity(task);
    await _isar.writeTxn(() => _isar.aITaskModels.put(model));
  }

  @override
  Future<void> updateStatus(int id, TaskStatus status, {String? errorMessage}) async {
    await _isar.writeTxn(() async {
      final model = await _isar.aITaskModels.get(id);
      if (model != null) {
        model.status = status;
        if (errorMessage != null) {
          model.errorMessage = errorMessage;
        }
        if (status == TaskStatus.processing) {
          model.startedAt = DateTime.now();
        }
        if (status == TaskStatus.completed || status == TaskStatus.failed) {
          model.completedAt = DateTime.now();
        }
        await _isar.aITaskModels.put(model);
      }
    });
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.aITaskModels.get(id);
      if (model != null) {
        model.retryCount++;
        await _isar.aITaskModels.put(model);
      }
    });
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.aITaskModels.delete(id));
  }

  @override
  Future<void> deleteByIdeaId(int ideaId) async {
    await _isar.writeTxn(() async {
      await _isar.aITaskModels.filter().ideaIdEqualTo(ideaId).deleteAll();
    });
  }

  @override
  Future<void> deleteCompletedTasks() async {
    await _isar.writeTxn(() async {
      await _isar.aITaskModels.filter().statusEqualTo(TaskStatus.completed).deleteAll();
    });
  }

  @override
  Future<AITaskEntity?> getActiveTaskByIdeaId(int ideaId) async {
    final model = await _isar.aITaskModels
        .filter()
        .ideaIdEqualTo(ideaId)
        .and()
        .group((q) => q
            .statusEqualTo(TaskStatus.pending)
            .or()
            .statusEqualTo(TaskStatus.processing))
        .findFirst();
    return model?.toEntity();
  }

  @override
  Future<AITaskEntity?> getLatestTaskByIdeaId(int ideaId) async {
    final model = await _isar.aITaskModels
        .filter()
        .ideaIdEqualTo(ideaId)
        .sortByCreatedAtDesc()
        .findFirst();
    return model?.toEntity();
  }
}
