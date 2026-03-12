import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/repositories/idea_repository.dart';

void main() {
  group('IdeaRepository Interface', () {
    test('should define save method', () {
      final repository = _MockIdeaRepository();
      expect(repository.save, isA<Function>());
    });

    test('should define getById method', () {
      final repository = _MockIdeaRepository();
      expect(repository.getById, isA<Function>());
    });

    test('should define getAll method', () {
      final repository = _MockIdeaRepository();
      expect(repository.getAll, isA<Function>());
    });

    test('should define update method', () {
      final repository = _MockIdeaRepository();
      expect(repository.update, isA<Function>());
    });

    test('should define softDelete method', () {
      final repository = _MockIdeaRepository();
      expect(repository.softDelete, isA<Function>());
    });

    test('should define restore method', () {
      final repository = _MockIdeaRepository();
      expect(repository.restore, isA<Function>());
    });

    test('should define permanentDelete method', () {
      final repository = _MockIdeaRepository();
      expect(repository.permanentDelete, isA<Function>());
    });

    test('should define searchByContent method', () {
      final repository = _MockIdeaRepository();
      expect(repository.searchByContent, isA<Function>());
    });

    test('should define getDeleted method', () {
      final repository = _MockIdeaRepository();
      expect(repository.getDeleted, isA<Function>());
    });

    test('should define updateAIStatus method', () {
      final repository = _MockIdeaRepository();
      expect(repository.updateAIStatus, isA<Function>());
    });

    test('should define updateEmbedding method', () {
      final repository = _MockIdeaRepository();
      expect(repository.updateEmbedding, isA<Function>());
    });

    test('should define getIdeasWithEmbedding method', () {
      final repository = _MockIdeaRepository();
      expect(repository.getIdeasWithEmbedding, isA<Function>());
    });

    test('should define countIdeasWithEmbedding method', () {
      final repository = _MockIdeaRepository();
      expect(repository.countIdeasWithEmbedding, isA<Function>());
    });
  });
}

class _MockIdeaRepository implements IdeaRepository {
  @override
  Future<IdeaEntity> save(IdeaEntity idea) async => idea;

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
