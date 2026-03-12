class SensitiveDataMasker {
  SensitiveDataMasker._();

  static final _apiKeyPattern = RegExp(r'sk-[a-zA-Z0-9]{20,}');
  static final _emailPattern = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
  static final _phonePattern = RegExp(r'1[3-9]\d{9}');

  static String mask(String content) {
    if (content.isEmpty) return content;

    var result = content;

    result = result.replaceAllMapped(_apiKeyPattern, (match) {
      final key = match.group(0)!;
      if (key.length > 12) {
        return '${key.substring(0, 6)}...${key.substring(key.length - 4)}';
      }
      return '***';
    });

    result = result.replaceAllMapped(_emailPattern, (match) {
      final email = match.group(0)!;
      final parts = email.split('@');
      if (parts.length == 2) {
        final name = parts[0];
        final domain = parts[1];
        final maskedName = name.length > 3 ? '${name.substring(0, 3)}***' : '***';
        return '$maskedName@$domain';
      }
      return '***@***';
    });

    result = result.replaceAllMapped(_phonePattern, (match) {
      final phone = match.group(0)!;
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    });

    return result;
  }

  static String maskContent(String content, {int maxLength = 50}) {
    if (content.isEmpty) return '[空内容]';
    return '[内容: ${content.length}字]';
  }

  static String maskApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) return '[未设置]';
    if (apiKey.length > 12) {
      return '${apiKey.substring(0, 6)}...${apiKey.substring(apiKey.length - 4)}';
    }
    return '***';
  }
}
