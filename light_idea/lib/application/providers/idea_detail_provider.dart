import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/entities/ai_task.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/association.dart';
import '../ai/ai_embedding_service.dart';
import 'app_providers.dart';

class IdeaDetailState {
  final IdeaEntity? idea;
  final AIAnalysisEntity? analysis;
  final List<TagEntity> tags;
  final List<SimilarIdea> relatedIdeas;
  final List<AssociationEntity> associations;
  final bool isLoading;
  final bool isAnalyzing;
  final String? error;

  const IdeaDetailState({
    this.idea,
    this.analysis,
    this.tags = const [],
    this.relatedIdeas = const [],
    this.associations = const [],
    this.isLoading = false,
    this.isAnalyzing = false,
    this.error,
  });

  int get similarCount => associations.where((a) => a.type == RelationType.similar).length;
  int get complementaryCount => associations.where((a) => a.type == RelationType.complementary).length;
  int get evolutionaryCount => associations.where((a) => a.type == RelationType.evolutionary).length;

  IdeaDetailState copyWith({
    IdeaEntity? idea,
    AIAnalysisEntity? analysis,
    List<TagEntity>? tags,
    List<SimilarIdea>? relatedIdeas,
    List<AssociationEntity>? associations,
    bool? isLoading,
    bool? isAnalyzing,
    String? error,
  }) {
    return IdeaDetailState(
      idea: idea ?? this.idea,
      analysis: analysis ?? this.analysis,
      tags: tags ?? this.tags,
      relatedIdeas: relatedIdeas ?? this.relatedIdeas,
      associations: associations ?? this.associations,
      isLoading: isLoading ?? this.isLoading,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      error: error,
    );
  }
}

class IdeaDetailNotifier extends StateNotifier<IdeaDetailState> {
  final Ref _ref;

  IdeaDetailNotifier(this._ref) : super(const IdeaDetailState());

  Future<void> loadIdea(int id) async {
    developer.log('========== loadIdea() 开始 ==========', name: 'IdeaDetailProvider');
    developer.log('加载灵感 id=$id', name: 'IdeaDetailProvider');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
      final tagRepo = _ref.read(tagRepositoryProvider);
      final embeddingService = _ref.read(aiEmbeddingServiceProvider);
      final associationRepo = _ref.read(associationRepositoryProvider);

      developer.log('正在查询灵感...', name: 'IdeaDetailProvider');
      final idea = await ideaRepo.getById(id);
      developer.log('查询结果: idea=${idea != null}', name: 'IdeaDetailProvider');

      if (idea == null) {
        developer.log('灵感不存在: id=$id', name: 'IdeaDetailProvider');
        state = state.copyWith(isLoading: false, error: '灵感不存在');
        return;
      }

      developer.log('灵感内容: "${idea.content}", createdAt=${idea.createdAt}', name: 'IdeaDetailProvider');

      final loadedAnalysis = await analysisRepo.getByIdeaId(id);
      final analysis = loadedAnalysis != null &&
              loadedAnalysis.matchesIdeaSnapshot(
                contentHash: idea.contentHash,
                updatedAt: idea.updatedAt,
              )
          ? loadedAnalysis
          : null;

      final tags = <TagEntity>[];
      if (analysis != null && analysis.tagResults.isNotEmpty) {
        for (final tagId in analysis.tagResults) {
          final tag = await tagRepo.getById(tagId);
          if (tag != null) tags.add(tag);
        }
      }

      List<SimilarIdea> relatedIdeas = [];
      if (idea.embedding != null && idea.embedding!.isNotEmpty) {
        final result = await embeddingService.findSimilarIdeas(id, topN: 5);
        if (result.isSuccess) {
          relatedIdeas = result.dataOrNull ?? [];
        }
      }

      final associations = await associationRepo.getByIdeaId(id);

      developer.log('加载完成: idea.content="${idea.content}"', name: 'IdeaDetailProvider');
      developer.log('========== loadIdea() 完成 ==========', name: 'IdeaDetailProvider');

      state = state.copyWith(
        idea: idea,
        analysis: analysis,
        tags: tags,
        relatedIdeas: relatedIdeas,
        associations: associations,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      developer.log('加载失败: $e', name: 'IdeaDetailProvider', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshAnalysis() async {
    if (state.idea == null) return;

    state = state.copyWith(isAnalyzing: true);

    try {
      final taskQueue = _ref.read(aiTaskQueueProvider);
      final result = await taskQueue.enqueue(
        state.idea!.id,
        taskType: TaskType.fullAnalysis,
        force: true,
      );

      if (result.wasSkipped) {
        state = state.copyWith(
          isAnalyzing: false,
          error: result.reason ?? '任务已存在',
        );
        return;
      }

      await Future<void>.delayed(const Duration(seconds: 1));
      await loadIdea(state.idea!.id);
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, error: e.toString());
    }
  }

  Future<bool> updateContent(String content) async {
    if (state.idea == null) return false;

    try {
      final trimmedContent = content.trim();
      final ideaRepo = _ref.read(ideaRepositoryProvider);

      if (state.idea!.hasSameContent(trimmedContent)) {
        final unchangedIdea = state.idea!.copyWith(content: trimmedContent);
        await ideaRepo.update(unchangedIdea);
        state = state.copyWith(
          idea: unchangedIdea,
          error: null,
        );
        return true;
      }

      final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
      final taskRepo = _ref.read(aiTaskRepositoryProvider);
      final taskQueue = _ref.read(aiTaskQueueProvider);
      final updatedIdea = state.idea!.copyWith(
        content: trimmedContent,
        updatedAt: DateTime.now(),
        aiStatus: AIStatus.pending,
      );
      await ideaRepo.update(updatedIdea);
      await ideaRepo.updateAIStatus(updatedIdea.id, AIStatus.pending);
      await analysisRepo.deleteByIdeaId(updatedIdea.id);
      await taskRepo.deleteByIdeaId(updatedIdea.id);
      await taskQueue.enqueue(
        updatedIdea.id,
        taskType: TaskType.fullAnalysis,
        force: true,
      );

      state = state.copyWith(
        idea: updatedIdea,
        analysis: null,
        tags: const [],
        relatedIdeas: const [],
        associations: const [],
        isAnalyzing: true,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteIdea() async {
    if (state.idea == null) return false;

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final associationRepo = _ref.read(associationRepositoryProvider);
      final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
      final taskRepo = _ref.read(aiTaskRepositoryProvider);

      await associationRepo.deleteByIdeaId(state.idea!.id);
      await analysisRepo.deleteByIdeaId(state.idea!.id);
      await taskRepo.deleteByIdeaId(state.idea!.id);
      await ideaRepo.softDelete(state.idea!.id);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCategory(int categoryId) async {
    if (state.idea == null) return false;

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final updatedIdea = state.idea!.copyWith(
        categoryId: categoryId,
        updatedAt: DateTime.now(),
      );
      await ideaRepo.update(updatedIdea);

      state = state.copyWith(idea: updatedIdea);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateTags(List<int> tagIds) async {
    if (state.idea == null) return false;

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final updatedIdea = state.idea!.copyWith(
        tagIds: tagIds,
        updatedAt: DateTime.now(),
      );
      await ideaRepo.update(updatedIdea);

      final tagRepo = _ref.read(tagRepositoryProvider);
      final tags = <TagEntity>[];
      for (final tagId in tagIds) {
        final tag = await tagRepo.getById(tagId);
        if (tag != null) tags.add(tag);
      }

      state = state.copyWith(idea: updatedIdea, tags: tags);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final ideaDetailProvider =
    StateNotifierProvider<IdeaDetailNotifier, IdeaDetailState>((ref) {
  return IdeaDetailNotifier(ref);
});
