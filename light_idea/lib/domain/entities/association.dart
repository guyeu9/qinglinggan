enum RelationType { similar, complementary, evolutionary }

class AssociationEntity {
  final int id;
  final int sourceIdeaId;
  final int targetIdeaId;
  final RelationType type;
  final String reason;
  final double confidence;
  final DateTime createdAt;

  const AssociationEntity({
    required this.id,
    required this.sourceIdeaId,
    required this.targetIdeaId,
    required this.type,
    required this.reason,
    required this.confidence,
    required this.createdAt,
  });

  AssociationEntity copyWith({
    int? id,
    int? sourceIdeaId,
    int? targetIdeaId,
    RelationType? type,
    String? reason,
    double? confidence,
    DateTime? createdAt,
  }) {
    return AssociationEntity(
      id: id ?? this.id,
      sourceIdeaId: sourceIdeaId ?? this.sourceIdeaId,
      targetIdeaId: targetIdeaId ?? this.targetIdeaId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssociationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sourceIdeaId == other.sourceIdeaId &&
          targetIdeaId == other.targetIdeaId;

  @override
  int get hashCode => id.hashCode ^ sourceIdeaId.hashCode ^ targetIdeaId.hashCode;

  @override
  String toString() {
    return 'AssociationEntity(id: $id, sourceIdeaId: $sourceIdeaId, targetIdeaId: $targetIdeaId, type: $type, confidence: $confidence)';
  }
}
