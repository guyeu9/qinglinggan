import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/domain/entities/category.dart';

void main() {
  group('CategoryEntity', () {
    test('should create category with required fields', () {
      final category = CategoryEntity(
        id: 1,
        name: '社交 / 旅行 / 惊喜类',
        icon: '✈️',
        sortOrder: 0,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(category.id, 1);
      expect(category.name, '社交 / 旅行 / 惊喜类');
      expect(category.icon, '✈️');
      expect(category.sortOrder, 0);
    });

    test('should create category with different values', () {
      final category = CategoryEntity(
        id: 2,
        name: '工作 / 创意策划类',
        icon: '💼',
        sortOrder: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(category.id, 2);
      expect(category.name, '工作 / 创意策划类');
      expect(category.icon, '💼');
      expect(category.sortOrder, 1);
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final category = CategoryEntity(
          id: 1,
          name: '摄影爱好类',
          icon: '📷',
          sortOrder: 2,
          createdAt: DateTime(2024, 1, 1),
        );

        final copied = category.copyWith(name: 'Updated Name');

        expect(copied.id, 1);
        expect(copied.name, 'Updated Name');
        expect(copied.icon, '📷');
        expect(copied.sortOrder, 2);
      });

      test('should keep original values when not provided', () {
        final category = CategoryEntity(
          id: 1,
          name: 'Test Category',
          icon: '📝',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        final copied = category.copyWith();

        expect(copied.id, category.id);
        expect(copied.name, category.name);
        expect(copied.icon, category.icon);
      });
    });

    group('equality', () {
      test('should be equal when ids are same', () {
        final category1 = CategoryEntity(
          id: 1,
          name: 'Category 1',
          icon: '📝',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        final category2 = CategoryEntity(
          id: 1,
          name: 'Category 2',
          icon: '📋',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 2),
        );

        expect(category1, equals(category2));
      });

      test('should not be equal when ids are different', () {
        final category1 = CategoryEntity(
          id: 1,
          name: 'Category',
          icon: '📝',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        final category2 = CategoryEntity(
          id: 2,
          name: 'Category',
          icon: '📝',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(category1, isNot(equals(category2)));
      });
    });

    group('toString', () {
      test('should contain id, name and icon', () {
        final category = CategoryEntity(
          id: 1,
          name: 'Test Category',
          icon: '📝',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(category.toString(), contains('id: 1'));
        expect(category.toString(), contains('Test Category'));
        expect(category.toString(), contains('📝'));
      });
    });

    group('hashCode', () {
      test('should have consistent hashCode for same id', () {
        final category1 = CategoryEntity(
          id: 1,
          name: 'Category 1',
          icon: '📝',
          sortOrder: 0,
          createdAt: DateTime(2024, 1, 1),
        );

        final category2 = CategoryEntity(
          id: 1,
          name: 'Category 2',
          icon: '📋',
          sortOrder: 1,
          createdAt: DateTime(2024, 1, 2),
        );

        expect(category1.hashCode, equals(category2.hashCode));
      });
    });
  });
}
