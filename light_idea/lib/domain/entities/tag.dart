class TagEntity {
  final int id;
  final String name;
  final DateTime createdAt;

  const TagEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  TagEntity copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TagEntity(id: $id, name: $name)';
  }
}
