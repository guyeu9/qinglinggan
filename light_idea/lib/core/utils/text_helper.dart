class TextHelper {
  TextHelper._();

  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  static String truncateByChars(String text, int maxChars, {String suffix = '...'}) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}$suffix';
  }

  static bool isValidContent(String? content) {
    if (content == null) return false;
    final trimmed = content.trim();
    return trimmed.isNotEmpty && trimmed.length <= 10000;
  }

  static String normalizeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static int countChineseChars(String text) {
    return RegExp(r'[\u4e00-\u9fa5]').allMatches(text).length;
  }

  static int calculateReadingTime(String text) {
    const wordsPerMinute = 200;
    final chineseChars = countChineseChars(text);
    final otherChars = text.length - chineseChars;
    final totalWords = chineseChars + (otherChars / 2).round();
    return (totalWords / wordsPerMinute).ceil();
  }
}
