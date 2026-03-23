import 'package:isar/isar.dart';
import '../../domain/entities/ai_analysis.dart';

part 'ai_analysis_model.g.dart';

@collection
class AIAnalysisModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int ideaId;

  int? categoryResult;

  List<int> tagResults = [];

  String summary = '';

  String aiHint = '';

  @Index()
  @Enumerated(EnumType.name)
  AnalysisStatus status = AnalysisStatus.pending;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  @Index()
  late String sourceContentHash;

  @Index()
  late DateTime sourceIdeaUpdatedAt;

  List<String> commonPoints = [];

  List<String> differences = [];

  String? mergedIdea;

  AIAnalysisEntity toEntity() {
    return AIAnalysisEntity(
      id: id,
      ideaId: ideaId,
      categoryResult: categoryResult,
      tagResults: tagResults,
      summary: summary,
      aiHint: aiHint,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sourceContentHash: sourceContentHash,
      sourceIdeaUpdatedAt: sourceIdeaUpdatedAt,
      commonPoints: commonPoints,
      differences: differences,
      mergedIdea: mergedIdea,
    );
  }

  static AIAnalysisModel fromEntity(AIAnalysisEntity entity) {
    return AIAnalysisModel()
      ..id = entity.id
      ..ideaId = entity.ideaId
      ..categoryResult = entity.categoryResult
      ..tagResults = entity.tagResults
      ..summary = entity.summary
      ..aiHint = entity.aiHint
      ..status = entity.status
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..sourceContentHash = entity.sourceContentHash
      ..sourceIdeaUpdatedAt = entity.sourceIdeaUpdatedAt
      ..commonPoints = entity.commonPoints
      ..differences = entity.differences
      ..mergedIdea = entity.mergedIdea;
  }
}
