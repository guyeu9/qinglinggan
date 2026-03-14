import 'package:isar/isar.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final Isar _isar;

  CategoryRepositoryImpl(this._isar);

  @override
  Future<CategoryEntity?> getById(int id) async {
    final model = await _isar.categoryModels.get(id);
    return model?.toEntity();
  }

  @override
  Future<CategoryEntity?> getByName(String name) async {
    final model = await _isar.categoryModels.filter().nameEqualTo(name).findFirst();
    return model?.toEntity();
  }

  @override
  Future<List<CategoryEntity>> getAll() async {
    final models = await _isar.categoryModels.where().sortBySortOrder().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CategoryEntity> save(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    final id = await _isar.writeTxn(() => _isar.categoryModels.put(model));
    return category.copyWith(id: id);
  }

  @override
  Future<void> update(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _isar.writeTxn(() => _isar.categoryModels.put(model));
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.categoryModels.delete(id));
  }

  @override
  Future<int> count() async {
    return _isar.categoryModels.count();
  }
}
