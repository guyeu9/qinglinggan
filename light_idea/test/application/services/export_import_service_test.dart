import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/services/export_service.dart';
import 'package:light_idea/application/services/import_service.dart';
import 'package:light_idea/core/utils/result.dart';

void main() {
  group('ExportFilter', () {
    test('should create filter with all parameters', () {
      final filter = ExportFilter(
        categoryId: 1,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      );

      expect(filter.categoryId, 1);
      expect(filter.startDate, DateTime(2026, 1, 1));
      expect(filter.endDate, DateTime(2026, 12, 31));
    });

    test('should create filter with no parameters', () {
      final filter = const ExportFilter();

      expect(filter.categoryId, isNull);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
    });

    test('should create filter with only categoryId', () {
      final filter = const ExportFilter(categoryId: 2);

      expect(filter.categoryId, 2);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
    });
  });

  group('ConflictStrategy', () {
    test('should have three strategies', () {
      expect(ConflictStrategy.values.length, 3);
      expect(ConflictStrategy.values, contains(ConflictStrategy.overwrite));
      expect(ConflictStrategy.values, contains(ConflictStrategy.skip));
      expect(ConflictStrategy.values, contains(ConflictStrategy.merge));
    });
  });

  group('ImportResult', () {
    test('should create result with all parameters', () {
      const result = ImportResult(
        successCount: 10,
        skipCount: 2,
        errorCount: 1,
        errors: ['error1', 'error2'],
      );

      expect(result.successCount, 10);
      expect(result.skipCount, 2);
      expect(result.errorCount, 1);
      expect(result.errors.length, 2);
    });

    test('should calculate totalProcessed correctly', () {
      const result = ImportResult(
        successCount: 10,
        skipCount: 5,
        errorCount: 3,
        errors: [],
      );

      expect(result.totalProcessed, 18);
    });

    test('should copyWith correctly', () {
      const original = ImportResult(
        successCount: 5,
        skipCount: 2,
        errorCount: 1,
        errors: ['error1'],
      );

      final copied = original.copyWith(successCount: 10);

      expect(copied.successCount, 10);
      expect(copied.skipCount, 2);
      expect(copied.errorCount, 1);
      expect(copied.errors.length, 1);
    });

    test('should have correct toString', () {
      const result = ImportResult(
        successCount: 10,
        skipCount: 2,
        errorCount: 1,
        errors: [],
      );

      expect(result.toString(), 'ImportResult(success: 10, skip: 2, error: 1)');
    });
  });
}
