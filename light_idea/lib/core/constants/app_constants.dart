class AppConstants {
  AppConstants._();

  static const String appName = '轻灵感';
  static const String appVersion = '1.0.0';

  static const int maxContentLength = 10000;
  static const int minContentLength = 1;

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static const int embeddingDimension = 1536;
  static const int maxTagCount = 10;
  static const double similarityThreshold = 0.3;
  static const int maxCandidates = 10;

  static const int maxRetryCount = 3;
  static const int taskTimeoutSeconds = 120;
}
