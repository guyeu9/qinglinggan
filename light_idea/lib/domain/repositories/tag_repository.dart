import '../entities/tag.dart';

abstract class TagRepository {
  Future<TagEntity?> getById(int id);

  Future<TagEntity?> getByName(String name);

  Future<List<TagEntity>> getAll();

  Future<List<TagEntity>> getByIds(List<int> ids);

  Future<TagEntity> save(TagEntity tag);

  Future<List<TagEntity>> saveAll(List<String> names);

  Future<TagEntity> saveIfNotExists(String name);

  Future<int> count();
}
