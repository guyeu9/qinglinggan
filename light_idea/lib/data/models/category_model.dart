import 'package:isar/isar.dart';
import '../../domain/entities/category.dart' show CategoryEntity;

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late String icon;

  late int sortOrder;

  DateTime createdAt = DateTime.now();

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  static CategoryModel fromEntity(CategoryEntity entity) {
    return CategoryModel()
      ..id = entity.id
      ..name = entity.name
      ..icon = entity.icon
      ..sortOrder = entity.sortOrder
      ..createdAt = entity.createdAt;
  }
}
