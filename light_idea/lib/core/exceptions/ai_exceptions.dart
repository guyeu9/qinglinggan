abstract class AIException implements Exception {
  final String message;
  final String? rawContent;
  final Object? cause;

  const AIException(this.message, {this.rawContent, this.cause});

  @override
  String toString() => 'AIException: $message';
}

class AIResponseParseException extends AIException {
  const AIResponseParseException(
    super.message, {
    super.rawContent,
    super.cause,
  });

  @override
  String toString() => 'AIResponseParseException: $message';
}

class AIEmptyResponseException extends AIException {
  const AIEmptyResponseException([String? rawContent])
      : super('AI 返回空响应', rawContent: rawContent);
}

class AIInvalidResponseStructureException extends AIException {
  const AIInvalidResponseStructureException(
    super.message, {
    super.rawContent,
    super.cause,
  });

  @override
  String toString() => 'AIInvalidResponseStructureException: $message';
}
