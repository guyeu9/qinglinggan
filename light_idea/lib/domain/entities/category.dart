class CategoryEntity {
  final int id;
  final String name;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.sortOrder,
    required this.createdAt,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? icon,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, icon: $icon)';
  }
}
