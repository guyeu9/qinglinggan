import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/usecases/create_idea.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/repositories/idea_repository.dart';

import 'package:light_idea/core/logger/app_logger.dart';

void main() {
  late CreateIdeaUseCase useCase;
  late _MockIdeaRepository mockRepository;
  late _MockLogger mockLogger;

  setUp(() {
    mockRepository = _MockIdeaRepository();
    mockLogger = _MockLogger();
    useCase = CreateIdeaUseCase(mockRepository, mockLogger);
  });

  group('CreateIdeaUseCase', () {
    group('execute', () {
      test('should create idea with valid content', () async {
        const content = 'Test idea content';

        final result = await useCase.execute(content);

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.content, content);
      });

      test('should trim content before saving', () async {
        const content = '  Test idea content  ';

        final result = await useCase.execute(content);

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.content, 'Test idea content');
      });

      test('should fail with empty content', () async {
        const content = '';

        final result = await useCase.execute(content);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('空'));
      });

      test('should fail with whitespace only content', () async {
        const content = '   ';

        final result = await useCase.execute(content);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('空'));
      });

      test('should fail with content exceeding max length', () async {
        final content = 'a' * 10001;

        final result = await useCase.execute(content);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('超过'));
      });

      test('should set aiStatus to pending', () async {
        const content = 'Test idea';

        final result = await useCase.execute(content);

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.aiStatus, AIStatus.pending);
      });

      test('should set createdAt and updatedAt', () async {
        const content = 'Test idea';
        final beforeCreate = DateTime.now();

        final result = await useCase.execute(content);

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.createdAt, isNotNull);
        expect(result.dataOrNull?.updatedAt, isNotNull);
        expect(result.dataOrNull?.createdAt.isAfter(beforeCreate.subtract(const Duration(seconds: 1))), true);
      });

      test('should log success message', () async {
        const content = 'Test idea';

        await useCase.execute(content);

        expect(mockLogger.infoCalled, true);
      });

      test('should handle repository exception', () async {
        mockRepository.shouldThrow = true;
        const content = 'Test idea';

        final result = await useCase.execute(content);

        expect(result.isError, true);
        expect(result.errorOrNull, contains('失败'));
      });
    });
  });
}

class _MockIdeaRepository implements IdeaRepository {
  bool shouldThrow = false;
  int _nextId = 1;

  @override
  Future<IdeaEntity> save(IdeaEntity idea) async {
    if (shouldThrow) {
      throw Exception('Database error');
    }
    return idea.copyWith(id: _nextId++);
  }

  @override
  Future<IdeaEntity?> getById(int id) async => null;

  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async => [];

  @override
  Future<List<IdeaEntity>> getByCategory(int categoryId) async => [];

  @override
  Future<List<IdeaEntity>> getByPage(int offset, int limit) async => [];

  @override
  Future<int> count({bool includeDeleted = false}) async => 0;

  @override
  Future<void> update(IdeaEntity idea) async {}

  @override
  Future<void> updateAIStatus(int id, AIStatus status) async {}

  @override
  Future<void> updateEmbedding(int id, List<double> embedding) async {}

  @override
  Future<void> softDelete(int id) async {}

  @override
  Future<void> restore(int id) async {}

  @override
  Future<void> permanentDelete(int id) async {}

  @override
  Future<List<IdeaEntity>> searchByContent(String keyword) async => [];

  @override
  Future<List<IdeaEntity>> getDeleted() async => [];

  @override
  Future<void> clearDeleted() async {}

  @override
  Future<List<IdeaEntity>> getIdeasWithEmbedding({int limit = 100, int offset = 0}) async => [];

  @override
  Future<int> countIdeasWithEmbedding() async => 0;
}

class _MockLogger implements AppLogger {
  bool infoCalled = false;
  bool errorCalled = false;

  @override
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void debug(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    infoCalled = true;
  }

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    errorCalled = true;
  }

  @override
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {}
}
