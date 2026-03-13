enum AIStatus { pending, processing, completed, failed }

class IdeaEntity {
  final int id;
  final String content;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final AIStatus aiStatus;
  final List<int> tagIds;
  final List<double>? embedding;
  final List<String> imagePaths;

  const IdeaEntity({
    required this.id,
    required this.content,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
    this.aiStatus = AIStatus.pending,
    this.tagIds = const [],
    this.embedding,
    this.imagePaths = const [],
  });

  IdeaEntity copyWith({
    int? id,
    String? content,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDeleted,
    AIStatus? aiStatus,
    List<int>? tagIds,
    List<double>? embedding,
    List<String>? imagePaths,
  }) {
    return IdeaEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      aiStatus: aiStatus ?? this.aiStatus,
      tagIds: tagIds ?? this.tagIds,
      embedding: embedding ?? this.embedding,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content;

  @override
  int get hashCode => id.hashCode ^ content.hashCode;

  @override
  String toString() {
    return 'IdeaEntity(id: $id, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, '
        'categoryId: $categoryId, isDeleted: $isDeleted, aiStatus: $aiStatus)';
  }
}
