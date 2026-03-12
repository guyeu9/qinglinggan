import 'package:isar/isar.dart';
import '../models/category_model.dart';

class SeedData {
  SeedData._();

  static Future<void> initializeDefaultCategories(Isar isar) async {
    final existingCount = await isar.categoryModels.count();
    if (existingCount > 0) {
      return;
    }

    final categories = [
      CategoryModel()
        ..name = '社交 / 旅行 / 惊喜类'
        ..icon = '✈️'
        ..sortOrder = 0,
      CategoryModel()
        ..name = '工作 / 创意策划类'
        ..icon = '💼'
        ..sortOrder = 1,
      CategoryModel()
        ..name = '摄影爱好类'
        ..icon = '📷'
        ..sortOrder = 2,
    ];

    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(categories);
    });
  }

  static Future<void> initialize(Isar isar) async {
    await initializeDefaultCategories(isar);
  }
}
