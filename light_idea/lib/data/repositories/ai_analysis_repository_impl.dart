import 'package:isar/isar.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/repositories/ai_analysis_repository.dart';
import '../models/ai_analysis_model.dart';

class AIAnalysisRepositoryImpl implements AIAnalysisRepository {
  final Isar _isar;

  AIAnalysisRepositoryImpl(this._isar);

  @override
  Future<AIAnalysisEntity> save(AIAnalysisEntity analysis) async {
    final model = AIAnalysisModel.fromEntity(analysis);
    final id = await _isar.writeTxn(() => _isar.aIAnalysisModels.put(model));
    return analysis.copyWith(id: id);
  }

  @override
  Future<AIAnalysisEntity?> getById(int id) async {
    final model = await _isar.aIAnalysisModels.get(id);
    return model?.toEntity();
  }

  @override
  Future<AIAnalysisEntity?> getByIdeaId(int ideaId) async {
    final models = await _isar.aIAnalysisModels
        .filter()
        .ideaIdEqualTo(ideaId)
        .sortByUpdatedAtDesc()
        .findAll();
    return models.firstOrNull?.toEntity();
  }

  @override
  Future<List<AIAnalysisEntity>> getAll() async {
    final models = await _isar.aIAnalysisModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> update(AIAnalysisEntity analysis) async {
    final model = AIAnalysisModel.fromEntity(analysis)..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.aIAnalysisModels.put(model));
  }

  @override
  Future<void> updateStatus(int id, AnalysisStatus status) async {
    await _isar.writeTxn(() async {
      final model = await _isar.aIAnalysisModels.get(id);
      if (model != null) {
        model.status = status;
        model.updatedAt = DateTime.now();
        await _isar.aIAnalysisModels.put(model);
      }
    });
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.aIAnalysisModels.delete(id));
  }

  @override
  Future<void> deleteByIdeaId(int ideaId) async {
    await _isar.writeTxn(() async {
      await _isar.aIAnalysisModels.filter().ideaIdEqualTo(ideaId).deleteAll();
    });
  }
}
