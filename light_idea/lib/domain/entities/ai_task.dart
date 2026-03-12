enum TaskType { basicAnalysis, relationAnalysis, fullAnalysis }

enum TaskStatus { pending, processing, completed, failed }

class AITaskEntity {
  final int id;
  final int ideaId;
  final TaskType taskType;
  final TaskStatus status;
  final int retryCount;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const AITaskEntity({
    required this.id,
    required this.ideaId,
    required this.taskType,
    this.status = TaskStatus.pending,
    this.retryCount = 0,
    this.errorMessage,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  AITaskEntity copyWith({
    int? id,
    int? ideaId,
    TaskType? taskType,
    TaskStatus? status,
    int? retryCount,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return AITaskEntity(
      id: id ?? this.id,
      ideaId: ideaId ?? this.ideaId,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AITaskEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AITaskEntity(id: $id, ideaId: $ideaId, type: $taskType, status: $status)';
  }
}
