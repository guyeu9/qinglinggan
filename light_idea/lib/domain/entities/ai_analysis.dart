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
  final String sourceContentHash;
  final DateTime sourceIdeaUpdatedAt;
  final List<String> commonPoints;
  final List<String> differences;
  final String? mergedIdea;

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
    required this.sourceContentHash,
    required this.sourceIdeaUpdatedAt,
    this.commonPoints = const [],
    this.differences = const [],
    this.mergedIdea,
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
    String? sourceContentHash,
    DateTime? sourceIdeaUpdatedAt,
    List<String>? commonPoints,
    List<String>? differences,
    String? mergedIdea,
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
      sourceContentHash: sourceContentHash ?? this.sourceContentHash,
      sourceIdeaUpdatedAt: sourceIdeaUpdatedAt ?? this.sourceIdeaUpdatedAt,
      commonPoints: commonPoints ?? this.commonPoints,
      differences: differences ?? this.differences,
      mergedIdea: mergedIdea ?? this.mergedIdea,
    );
  }

  bool matchesIdeaSnapshot({
    required String contentHash,
    required DateTime updatedAt,
  }) {
    return sourceContentHash == contentHash &&
        sourceIdeaUpdatedAt.isAtSameMomentAs(updatedAt);
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
    return 'AIAnalysisEntity(id: $id, ideaId: $ideaId, status: $status, sourceContentHash: $sourceContentHash)';
  }
}
