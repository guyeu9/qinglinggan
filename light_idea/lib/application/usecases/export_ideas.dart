import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../services/export_service.dart';

/// 导出格式枚举
enum ExportFormat {
  excel,
  json,
}

/// 导出灵感用例
/// 封装导出服务的调用逻辑，提供统一的导出入口
class ExportIdeasUseCase {
  final ExportService _exportService;
  final AppLogger _logger;

  ExportIdeasUseCase(this._exportService, this._logger);

  /// 执行导出操作
  /// [format] 导出格式（Excel 或 JSON）
  /// [filter] 筛选条件（可选）
  /// [fileName] 自定义文件名（可选）
  /// 返回导出文件的完整路径
  Future<Result<String>> execute({
    required ExportFormat format,
    ExportFilter? filter,
    String? fileName,
  }) async {
    try {
      _logger.info('开始执行导出用例, 格式: ${format.name}');

      final result = switch (format) {
        ExportFormat.excel => await _exportService.exportToExcel(
            filter: filter,
            fileName: fileName,
          ),
        ExportFormat.json => await _exportService.exportToJson(
            filter: filter,
            fileName: fileName,
          ),
      };

      if (result.isSuccess) {
        _logger.info('导出用例执行成功: ${result.dataOrNull}');
      } else {
        _logger.warning('导出用例执行失败: ${result.errorOrNull}');
      }

      return result;
    } catch (e, st) {
      _logger.error('导出用例执行异常', e, st);
      return Result.error('导出失败: $e', e);
    }
  }

  /// 导出为 Excel 格式（便捷方法）
  Future<Result<String>> exportToExcel({
    ExportFilter? filter,
    String? fileName,
  }) {
    return execute(
      format: ExportFormat.excel,
      filter: filter,
      fileName: fileName,
    );
  }

  /// 导出为 JSON 格式（便捷方法）
  Future<Result<String>> exportToJson({
    ExportFilter? filter,
    String? fileName,
  }) {
    return execute(
      format: ExportFormat.json,
      filter: filter,
      fileName: fileName,
    );
  }
}
