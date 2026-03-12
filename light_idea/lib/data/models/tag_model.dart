import 'package:isar/isar.dart';
import '../../domain/entities/tag.dart' show TagEntity;

part 'tag_model.g.dart';

@collection
class TagModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  DateTime createdAt = DateTime.now();

  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }

  static TagModel fromEntity(TagEntity entity) {
    return TagModel()
      ..id = entity.id
      ..name = entity.name
      ..createdAt = entity.createdAt;
  }
}
