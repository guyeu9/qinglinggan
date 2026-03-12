import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/ai_analysis.dart';
import '../../domain/entities/tag.dart';
import '../ai/ai_embedding_service.dart';
import 'app_providers.dart';

class IdeaDetailState {
  final IdeaEntity? idea;
  final AIAnalysisEntity? analysis;
  final List<TagEntity> tags;
  final List<SimilarIdea> relatedIdeas;
  final bool isLoading;
  final bool isAnalyzing;
  final String? error;

  const IdeaDetailState({
    this.idea,
    this.analysis,
    this.tags = const [],
    this.relatedIdeas = const [],
    this.isLoading = false,
    this.isAnalyzing = false,
    this.error,
  });

  IdeaDetailState copyWith({
    IdeaEntity? idea,
    AIAnalysisEntity? analysis,
    List<TagEntity>? tags,
    List<SimilarIdea>? relatedIdeas,
    bool? isLoading,
    bool? isAnalyzing,
    String? error,
  }) {
    return IdeaDetailState(
      idea: idea ?? this.idea,
      analysis: analysis ?? this.analysis,
      tags: tags ?? this.tags,
      relatedIdeas: relatedIdeas ?? this.relatedIdeas,
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final analysisRepo = _ref.read(aiAnalysisRepositoryProvider);
      final tagRepo = _ref.read(tagRepositoryProvider);
      final embeddingService = _ref.read(aiEmbeddingServiceProvider);

      final idea = await ideaRepo.getById(id);
      if (idea == null) {
        state = state.copyWith(isLoading: false, error: '灵感不存在');
        return;
      }

      final analysis = await analysisRepo.getByIdeaId(id);

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

      state = state.copyWith(
        idea: idea,
        analysis: analysis,
        tags: tags,
        relatedIdeas: relatedIdeas,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshAnalysis() async {
    if (state.idea == null) return;

    state = state.copyWith(isAnalyzing: true);

    try {
      final taskQueue = _ref.read(aiTaskQueueProvider);
      final result = await taskQueue.enqueue(state.idea!.id);

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
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      final updatedIdea = state.idea!.copyWith(
        content: content,
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

  Future<bool> deleteIdea() async {
    if (state.idea == null) return false;

    try {
      final ideaRepo = _ref.read(ideaRepositoryProvider);
      await ideaRepo.softDelete(state.idea!.id);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final ideaDetailProvider =
    StateNotifierProvider.autoDispose<IdeaDetailNotifier, IdeaDetailState>((ref) {
  return IdeaDetailNotifier(ref);
});
