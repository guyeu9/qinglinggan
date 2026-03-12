import '../entities/ai_task.dart';

abstract class AITaskRepository {
  Future<AITaskEntity> save(AITaskEntity task);

  Future<AITaskEntity?> getById(int id);

  Future<AITaskEntity?> getByIdeaId(int ideaId);

  Future<List<AITaskEntity>> getPendingTasks();

  Future<List<AITaskEntity>> getProcessingTasks();

  Future<void> update(AITaskEntity task);

  Future<void> updateStatus(int id, TaskStatus status, {String? errorMessage});

  Future<void> incrementRetryCount(int id);

  Future<void> delete(int id);

  Future<void> deleteByIdeaId(int ideaId);

  Future<void> deleteCompletedTasks();

  Future<AITaskEntity?> getActiveTaskByIdeaId(int ideaId);

  Future<AITaskEntity?> getLatestTaskByIdeaId(int ideaId);
}
