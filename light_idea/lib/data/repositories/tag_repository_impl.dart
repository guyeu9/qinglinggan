import 'package:isar/isar.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final Isar _isar;

  TagRepositoryImpl(this._isar);

  @override
  Future<TagEntity?> getById(int id) async {
    final model = await _isar.tagModels.get(id);
    return model?.toEntity();
  }

  @override
  Future<TagEntity?> getByName(String name) async {
    final model = await _isar.tagModels.filter().nameEqualTo(name).findFirst();
    return model?.toEntity();
  }

  @override
  Future<List<TagEntity>> getAll() async {
    final models = await _isar.tagModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TagEntity>> getByIds(List<int> ids) async {
    final models = await _isar.tagModels.getAll(ids);
    return models.whereType<TagModel>().map((m) => m.toEntity()).toList();
  }

  @override
  Future<TagEntity> save(TagEntity tag) async {
    final model = TagModel.fromEntity(tag);
    final id = await _isar.writeTxn(() => _isar.tagModels.put(model));
    return tag.copyWith(id: id);
  }

  @override
  Future<List<TagEntity>> saveAll(List<String> names) async {
    final tags = <TagEntity>[];
    await _isar.writeTxn(() async {
      for (final name in names) {
        final existing = await _isar.tagModels.filter().nameEqualTo(name).findFirst();
        if (existing != null) {
          tags.add(existing.toEntity());
        } else {
          final model = TagModel()
            ..name = name
            ..createdAt = DateTime.now();
          await _isar.tagModels.put(model);
          tags.add(model.toEntity());
        }
      }
    });
    return tags;
  }

  @override
  Future<TagEntity> saveIfNotExists(String name) async {
    final existing = await getByName(name);
    if (existing != null) return existing;

    return save(TagEntity(
      id: 0,
      name: name,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<int> count() async {
    return _isar.tagModels.count();
  }
}
