import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/idea_model.dart';
import '../models/category_model.dart';
import '../models/tag_model.dart';
import '../models/ai_analysis_model.dart';
import '../models/ai_task_model.dart';
import '../models/association_model.dart';

class IsarDatabase {
  IsarDatabase._();

  static Isar? _instance;

  static Future<Isar> initialize() async {
    if (_instance != null && _instance!.isOpen) {
      return _instance!;
    }

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        IdeaModelSchema,
        CategoryModelSchema,
        TagModelSchema,
        AIAnalysisModelSchema,
        AITaskModelSchema,
        AssociationModelSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
      name: 'light_idea_db',
    );

    return _instance!;
  }

  static Isar get instance {
    if (_instance == null || !_instance!.isOpen) {
      throw StateError('Isar not initialized. Call IsarDatabase.initialize() first.');
    }
    return _instance!;
  }

  static Future<void> close() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
    }
  }

  static Future<void> clear() async {
    await instance.writeTxn(() async {
      await instance.clear();
    });
  }

  static bool get isInitialized => _instance != null && _instance!.isOpen;
}
