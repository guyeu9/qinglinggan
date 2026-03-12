import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/core/utils/text_helper.dart';

void main() {
  group('TextHelper', () {
    group('truncate', () {
      test('should return original text when shorter than maxLength', () {
        expect(TextHelper.truncate('hello', 10), 'hello');
      });

      test('should truncate text when longer than maxLength', () {
        expect(TextHelper.truncate('hello world', 5), 'hello...');
      });

      test('should handle empty string', () {
        expect(TextHelper.truncate('', 10), '');
      });

      test('should use custom suffix', () {
        expect(TextHelper.truncate('hello world', 5, suffix: '…'), 'hello…');
      });
    });

    group('truncateByChars', () {
      test('should return original text when shorter than maxChars', () {
        expect(TextHelper.truncateByChars('你好世界', 10), '你好世界');
      });

      test('should truncate text when longer than maxChars', () {
        expect(TextHelper.truncateByChars('你好世界测试', 4), '你好世界...');
      });
    });

    group('isValidContent', () {
      test('should return true for valid content', () {
        expect(TextHelper.isValidContent('hello world'), true);
      });

      test('should return false for null content', () {
        expect(TextHelper.isValidContent(null), false);
      });

      test('should return false for empty content', () {
        expect(TextHelper.isValidContent(''), false);
      });

      test('should return false for whitespace only', () {
        expect(TextHelper.isValidContent('   '), false);
      });

      test('should return false for content exceeding max length', () {
        final longContent = 'a' * 10001;
        expect(TextHelper.isValidContent(longContent), false);
      });
    });

    group('normalizeWhitespace', () {
      test('should normalize multiple spaces to single space', () {
        expect(TextHelper.normalizeWhitespace('hello   world'), 'hello world');
      });

      test('should trim leading and trailing whitespace', () {
        expect(TextHelper.normalizeWhitespace('  hello world  '), 'hello world');
      });

      test('should handle newlines and tabs', () {
        expect(TextHelper.normalizeWhitespace('hello\n\tworld'), 'hello world');
      });
    });

    group('countChineseChars', () {
      test('should count Chinese characters correctly', () {
        expect(TextHelper.countChineseChars('你好世界'), 4);
      });

      test('should handle mixed content', () {
        expect(TextHelper.countChineseChars('hello你好world'), 2);
      });

      test('should return 0 for non-Chinese content', () {
        expect(TextHelper.countChineseChars('hello world'), 0);
      });
    });

    group('calculateReadingTime', () {
      test('should calculate reading time for Chinese content', () {
        final content = '你好世界' * 100;
        expect(TextHelper.calculateReadingTime(content), greaterThan(0));
      });

      test('should return 0 for empty content', () {
        expect(TextHelper.calculateReadingTime(''), 0);
      });

      test('should return 1 for short content', () {
        expect(TextHelper.calculateReadingTime('hello'), 1);
      });
    });
  });
}
