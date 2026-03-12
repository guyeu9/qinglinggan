enum AnalysisStatus { pending, processing, completed, failed }

class AIAnalysisEntity {
  final int id;
  final int ideaId;
  final int? categoryResult;
  final List<int> tagResults;
  final String summary;
  final String aiHint;
  final AnalysisStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIAnalysisEntity({
    required this.id,
    required this.ideaId,
    this.categoryResult,
    this.tagResults = const [],
    this.summary = '',
    this.aiHint = '',
    this.status = AnalysisStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  AIAnalysisEntity copyWith({
    int? id,
    int? ideaId,
    int? categoryResult,
    List<int>? tagResults,
    String? summary,
    String? aiHint,
    AnalysisStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIAnalysisEntity(
      id: id ?? this.id,
      ideaId: ideaId ?? this.ideaId,
      categoryResult: categoryResult ?? this.categoryResult,
      tagResults: tagResults ?? this.tagResults,
      summary: summary ?? this.summary,
      aiHint: aiHint ?? this.aiHint,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIAnalysisEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AIAnalysisEntity(id: $id, ideaId: $ideaId, status: $status)';
  }
}
