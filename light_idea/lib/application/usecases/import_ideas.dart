import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../services/import_service.dart';

/// 导入格式
enum ImportFormat {
  /// Excel 格式
  excel,
  /// JSON 格式
  json,
}

/// 导入灵感用例
class ImportIdeasUseCase {
  final ImportService _importService;
  final AppLogger _logger;

  ImportIdeasUseCase(this._importService, this._logger);

  /// 执行导入
  ///
  /// [data] 导入数据（Excel 为字节数组，JSON 为字符串）
  /// [format] 导入格式
  /// [strategy] 冲突处理策略，默认跳过已存在的记录
  /// [triggerAIAnalysis] 是否触发 AI 分析，默认不触发
  /// [idColumn] Excel 中 ID 列名，仅 Excel 格式有效
  /// [contentColumn] Excel 中内容列名，仅 Excel 格式有效
  /// [categoryColumn] Excel 中分类列名，仅 Excel 格式有效
  /// [tagsColumn] Excel 中标签列名，仅 Excel 格式有效
  /// [createdAtColumn] Excel 中创建时间列名，仅 Excel 格式有效
  Future<Result<ImportResult>> execute(
    dynamic data, {
    required ImportFormat format,
    ConflictStrategy strategy = ConflictStrategy.skip,
    bool triggerAIAnalysis = false,
    String idColumn = 'id',
    String contentColumn = 'content',
    String categoryColumn = 'category',
    String tagsColumn = 'tags',
    String createdAtColumn = 'createdAt',
  }) async {
    try {
      _logger.info('开始导入灵感数据，格式: $format');

      // 验证数据
      if (data == null) {
        _logger.warning('导入失败: 数据为空');
        return Result.error('导入数据不能为空');
      }

      Result<ImportResult> result;

      switch (format) {
        case ImportFormat.excel:
          // Excel 格式需要字节数组
          if (data is! List<int>) {
            _logger.warning('导入失败: Excel 格式需要字节数组');
            return Result.error('Excel 格式需要字节数组数据');
          }
          result = await _importService.importFromExcel(
            data,
            strategy: strategy,
            triggerAIAnalysis: triggerAIAnalysis,
            idColumn: idColumn,
            contentColumn: contentColumn,
            categoryColumn: categoryColumn,
            tagsColumn: tagsColumn,
            createdAtColumn: createdAtColumn,
          );
          break;

        case ImportFormat.json:
          // JSON 格式需要字符串
          if (data is! String) {
            _logger.warning('导入失败: JSON 格式需要字符串');
            return Result.error('JSON 格式需要字符串数据');
          }
          if (data.toString().trim().isEmpty) {
            _logger.warning('导入失败: JSON 字符串为空');
            return Result.error('JSON 字符串不能为空');
          }
          result = await _importService.importFromJson(
            data,
            strategy: strategy,
            triggerAIAnalysis: triggerAIAnalysis,
          );
          break;
      }

      if (result.isSuccess) {
        _logger.info('导入完成: ${result.dataOrNull}');
      } else {
        _logger.warning('导入失败: ${result.errorOrNull}');
      }

      return result;
    } catch (e, st) {
      _logger.error('导入灵感失败', e, st);
      return Result.error('导入失败: $e', e);
    }
  }
}
