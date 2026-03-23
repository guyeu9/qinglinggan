import 'package:isar/isar.dart';
import '../../domain/entities/idea.dart' show IdeaEntity, AIStatus;

part 'idea_model.g.dart';

@collection
class IdeaModel {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String content;

  @Index()
  late String contentHash;

  @Index()
  int? categoryId;

  @Index()
  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  DateTime? deletedAt;

  @Index()
  bool isDeleted = false;

  @Index()
  @Enumerated(EnumType.name)
  AIStatus aiStatus = AIStatus.pending;

  List<double>? embedding;

  List<int> tagIds = [];

  List<String> imagePaths = [];

  IdeaEntity toEntity() {
    return IdeaEntity(
      id: id,
      content: content,
      contentHash: contentHash,
      categoryId: categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      isDeleted: isDeleted,
      aiStatus: aiStatus,
      tagIds: tagIds,
      embedding: embedding,
      imagePaths: imagePaths,
    );
  }

  static IdeaModel fromEntity(IdeaEntity entity) {
    final model = IdeaModel()
      ..content = entity.content
      ..contentHash = entity.contentHash
      ..categoryId = entity.categoryId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..deletedAt = entity.deletedAt
      ..isDeleted = entity.isDeleted
      ..aiStatus = entity.aiStatus
      ..tagIds = entity.tagIds
      ..embedding = entity.embedding
      ..imagePaths = entity.imagePaths;

    // 只有当id > 0时才设置id，否则让Isar自动生成新ID
    if (entity.id > 0) {
      model.id = entity.id;
    }

    return model;
  }
}
