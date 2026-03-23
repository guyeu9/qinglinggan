enum AIStatus { pending, processing, completed, failed }

class IdeaEntity {
  final int id;
  final String content;
  final String contentHash;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final AIStatus aiStatus;
  final List<int> tagIds;
  final List<double>? embedding;
  final List<String> imagePaths;

  IdeaEntity({
    required this.id,
    required this.content,
    String? contentHash,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
    this.aiStatus = AIStatus.pending,
    this.tagIds = const [],
    this.embedding,
    this.imagePaths = const [],
  }) : contentHash = contentHash ?? computeContentHash(content);

  static String computeContentHash(String content) {
    final normalized = content.trim();
    return normalized.hashCode.toUnsigned(32).toRadixString(16).padLeft(8, '0');
  }

  IdeaEntity copyWith({
    int? id,
    String? content,
    String? contentHash,
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
    final nextContent = content ?? this.content;
    return IdeaEntity(
      id: id ?? this.id,
      content: nextContent,
      contentHash: contentHash ??
          (content != null ? computeContentHash(nextContent) : this.contentHash),
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

  bool hasSameContent(String otherContent) {
    return contentHash == computeContentHash(otherContent);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          contentHash == other.contentHash;

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ contentHash.hashCode;

  @override
  String toString() {
    return 'IdeaEntity(id: $id, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, '
        'contentHash: $contentHash, categoryId: $categoryId, isDeleted: $isDeleted, aiStatus: $aiStatus)';
  }
}
