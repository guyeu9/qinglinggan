import 'package:isar/isar.dart';
import '../../domain/entities/association.dart' show AssociationEntity, RelationType;

part 'association_model.g.dart';

@collection
class AssociationModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int sourceIdeaId;

  @Index()
  late int targetIdeaId;

  @Index()
  @Enumerated(EnumType.name)
  late RelationType type;

  late String reason;

  late double confidence;

  late DateTime createdAt;

  AssociationEntity toEntity() {
    return AssociationEntity(
      id: id,
      sourceIdeaId: sourceIdeaId,
      targetIdeaId: targetIdeaId,
      type: type,
      reason: reason,
      confidence: confidence,
      createdAt: createdAt,
    );
  }

  static AssociationModel fromEntity(AssociationEntity entity) {
    return AssociationModel()
      ..id = entity.id
      ..sourceIdeaId = entity.sourceIdeaId
      ..targetIdeaId = entity.targetIdeaId
      ..type = entity.type
      ..reason = entity.reason
      ..confidence = entity.confidence
      ..createdAt = entity.createdAt;
  }
}
