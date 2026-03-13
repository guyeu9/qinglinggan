import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../core/logger/app_logger.dart';
import '../../data/api/openai_client.dart';
import '../../data/database/isar_database.dart';
import '../../domain/repositories/idea_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/ai_task_repository.dart';
import '../../domain/repositories/ai_analysis_repository.dart';
import '../../data/repositories/idea_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/tag_repository_impl.dart';
import '../../data/repositories/ai_task_repository_impl.dart';
import '../../data/repositories/ai_analysis_repository_impl.dart';
import '../ai/ai_understanding_service.dart';
import '../ai/ai_embedding_service.dart';
import '../ai/ai_chat_service.dart';
import '../task_queue/ai_task_queue.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';
import 'ai_chat_provider.dart';

final loggerProvider = Provider<AppLogger>((ref) {
  return AppLogger.instance;
});

final openAIClientProvider = Provider<OpenAIClient>((ref) {
  return OpenAIClient();
});

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized before use');
});

final ideaRepositoryProvider = Provider<IdeaRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return IdeaRepositoryImpl(isar);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CategoryRepositoryImpl(isar);
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TagRepositoryImpl(isar);
});

final aiTaskRepositoryProvider = Provider<AITaskRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return AITaskRepositoryImpl(isar);
});

final aiAnalysisRepositoryProvider = Provider<AIAnalysisRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return AIAnalysisRepositoryImpl(isar);
});

final aiUnderstandingServiceProvider = Provider<AIUnderstandingService>((ref) {
  final client = ref.watch(openAIClientProvider);
  final logger = ref.watch(loggerProvider);
  return AIUnderstandingService(client, logger);
});

final aiEmbeddingServiceProvider = Provider<AIEmbeddingService>((ref) {
  final client = ref.watch(openAIClientProvider);
  final ideaRepo = ref.watch(ideaRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  return AIEmbeddingService(client, ideaRepo, logger);
});

final aiTaskQueueProvider = Provider<AITaskQueue>((ref) {
  return AITaskQueue(
    understandingService: ref.watch(aiUnderstandingServiceProvider),
    embeddingService: ref.watch(aiEmbeddingServiceProvider),
    taskRepository: ref.watch(aiTaskRepositoryProvider),
    ideaRepository: ref.watch(ideaRepositoryProvider),
    analysisRepository: ref.watch(aiAnalysisRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    logger: ref.watch(loggerProvider),
  );
});

class IsarNotifier extends StateNotifier<AsyncValue<Isar>> {
  IsarNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isar = await IsarDatabase.initialize();
      state = AsyncValue.data(isar);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final isarNotifierProvider = StateNotifierProvider<IsarNotifier, AsyncValue<Isar>>((ref) {
  return IsarNotifier();
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    ref.watch(ideaRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
    ref.watch(tagRepositoryProvider),
    ref.watch(loggerProvider),
  );
});

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService(
    ideaRepository: ref.watch(ideaRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    aiTaskQueue: ref.watch(aiTaskQueueProvider),
    logger: ref.watch(loggerProvider),
  );
});

final aiChatServiceProvider = Provider<AIChatService>((ref) {
  return AIChatService(
    ref.watch(openAIClientProvider),
    ref.watch(ideaRepositoryProvider),
    ref.watch(aiEmbeddingServiceProvider),
    ref.watch(loggerProvider),
  );
});

final aiChatProvider = StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier(
    ref.watch(aiChatServiceProvider),
  );
});
