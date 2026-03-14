import '../entities/category.dart';

abstract class CategoryRepository {
  Future<CategoryEntity?> getById(int id);

  Future<CategoryEntity?> getByName(String name);

  Future<List<CategoryEntity>> getAll();

  Future<CategoryEntity> save(CategoryEntity category);

  Future<void> update(CategoryEntity category);

  Future<void> delete(int id);

  Future<int> count();
}
