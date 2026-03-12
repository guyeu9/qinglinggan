import 'package:isar/isar.dart';
import '../../domain/entities/ai_task.dart';

part 'ai_task_model.g.dart';

@collection
class AITaskModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int ideaId;

  @Index()
  @Enumerated(EnumType.name)
  TaskType taskType = TaskType.basicAnalysis;

  @Index()
  @Enumerated(EnumType.name)
  TaskStatus status = TaskStatus.pending;

  int retryCount = 0;

  String? errorMessage;

  DateTime createdAt = DateTime.now();

  DateTime? startedAt;

  DateTime? completedAt;

  AITaskEntity toEntity() {
    return AITaskEntity(
      id: id,
      ideaId: ideaId,
      taskType: taskType,
      status: status,
      retryCount: retryCount,
      errorMessage: errorMessage,
      createdAt: createdAt,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  static AITaskModel fromEntity(AITaskEntity entity) {
    return AITaskModel()
      ..id = entity.id
      ..ideaId = entity.ideaId
      ..taskType = entity.taskType
      ..status = entity.status
      ..retryCount = entity.retryCount
      ..errorMessage = entity.errorMessage
      ..createdAt = entity.createdAt
      ..startedAt = entity.startedAt
      ..completedAt = entity.completedAt;
  }
}
