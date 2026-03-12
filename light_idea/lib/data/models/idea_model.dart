import 'package:isar/isar.dart';
import '../../domain/entities/idea.dart' show IdeaEntity, AIStatus;

part 'idea_model.g.dart';

@collection
class IdeaModel {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String content;

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

  IdeaEntity toEntity() {
    return IdeaEntity(
      id: id,
      content: content,
      categoryId: categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      isDeleted: isDeleted,
      aiStatus: aiStatus,
      tagIds: tagIds,
      embedding: embedding,
    );
  }

  static IdeaModel fromEntity(IdeaEntity entity) {
    return IdeaModel()
      ..id = entity.id
      ..content = entity.content
      ..categoryId = entity.categoryId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..deletedAt = entity.deletedAt
      ..isDeleted = entity.isDeleted
      ..aiStatus = entity.aiStatus
      ..tagIds = entity.tagIds
      ..embedding = entity.embedding;
  }
}
