import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/idea_repository.dart';
import '../../domain/repositories/tag_repository.dart';

/// 导出筛选参数
class ExportFilter {
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportFilter({
    this.categoryId,
    this.startDate,
    this.endDate,
  });
}

/// 导出服务
/// 提供灵感数据的导出功能，支持 Excel 和 JSON 格式
class ExportService {
  final IdeaRepository _ideaRepository;
  final CategoryRepository _categoryRepository;
  final TagRepository _tagRepository;
  final AppLogger _logger;

  ExportService(
    this._ideaRepository,
    this._categoryRepository,
    this._tagRepository,
    this._logger,
  );

  /// 导出为 Excel 文件
  /// 包含列：ID、内容、分类、标签、创建时间、更新时间
  Future<Result<String>> exportToExcel({
    ExportFilter? filter,
    String? fileName,
  }) async {
    try {
      _logger.info('开始导出 Excel 文件');

      // 获取数据
      final ideas = await _getFilteredIdeas(filter);
      if (ideas.isEmpty) {
        _logger.warning('导出 Excel 失败: 没有数据');
        return Result.error('没有可导出的数据');
      }

      // 获取分类和标签映射
      final categoryMap = await _getCategoryMap();
      final tagMap = await _getTagMap();

      // 创建 Excel
      final excel = Excel.createExcel();
      const sheetName = '灵感列表';
      excel.rename('Sheet1', sheetName);
      final sheet = excel[sheetName];

      // 设置表头
      const headers = ['ID', '内容', '分类', '标签', '创建时间', '更新时间'];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet
            .cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}1'));
        cell.value = TextCellValue(headers[i]);
        // 设置表头样式
        cell.cellStyle = CellStyle(
          bold: true,
        );
      }

      // 设置列宽（使用列索引）
      sheet.setColumnWidth(0, 8); // ID
      sheet.setColumnWidth(1, 50); // 内容
      sheet.setColumnWidth(2, 15); // 分类
      sheet.setColumnWidth(3, 30); // 标签
      sheet.setColumnWidth(4, 20); // 创建时间
      sheet.setColumnWidth(5, 20); // 更新时间

      // 填充数据
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      for (var i = 0; i < ideas.length; i++) {
        final idea = ideas[i];
        final rowIndex = i + 2; // 从第2行开始（第1行是表头）

        // ID
        sheet
            .cell(CellIndex.indexByString('A$rowIndex'))
            .value = IntCellValue(idea.id);

        // 内容
        sheet
            .cell(CellIndex.indexByString('B$rowIndex'))
            .value = TextCellValue(idea.content);

        // 分类
        final categoryName = idea.categoryId != null
            ? (categoryMap[idea.categoryId]?.name ?? '未知分类')
            : '无分类';
        sheet
            .cell(CellIndex.indexByString('C$rowIndex'))
            .value = TextCellValue(categoryName);

        // 标签
        final tagNames = idea.tagIds
            .map((id) => tagMap[id]?.name ?? '未知标签')
            .join(', ');
        sheet
            .cell(CellIndex.indexByString('D$rowIndex'))
            .value = TextCellValue(tagNames.isEmpty ? '无标签' : tagNames);

        // 创建时间
        sheet
            .cell(CellIndex.indexByString('E$rowIndex'))
            .value = TextCellValue(dateFormat.format(idea.createdAt));

        // 更新时间
        sheet
            .cell(CellIndex.indexByString('F$rowIndex'))
            .value = TextCellValue(dateFormat.format(idea.updatedAt));
      }

      // 生成文件名
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final actualFileName = fileName ?? '灵感导出_$timestamp.xlsx';

      // 保存文件
      final filePath = await _saveExcelFile(excel, actualFileName);

      _logger.info('Excel 导出成功: $filePath, 共 ${ideas.length} 条记录');
      return Result.success(filePath);
    } catch (e, st) {
      _logger.error('导出 Excel 失败', e, st);
      return Result.error('导出失败: $e', e);
    }
  }

  /// 导出为 JSON 文件
  /// 包含完整的数据结构
  Future<Result<String>> exportToJson({
    ExportFilter? filter,
    String? fileName,
  }) async {
    try {
      _logger.info('开始导出 JSON 文件');

      // 获取数据
      final ideas = await _getFilteredIdeas(filter);
      if (ideas.isEmpty) {
        _logger.warning('导出 JSON 失败: 没有数据');
        return Result.error('没有可导出的数据');
      }

      // 获取分类和标签映射
      final categoryMap = await _getCategoryMap();
      final tagMap = await _getTagMap();

      // 构建导出数据结构
      final exportData = {
        'exportTime': DateTime.now().toIso8601String(),
        'totalCount': ideas.length,
        'filter': filter != null
            ? {
                'categoryId': filter.categoryId,
                'startDate': filter.startDate?.toIso8601String(),
                'endDate': filter.endDate?.toIso8601String(),
              }
            : null,
        'ideas': ideas.map((idea) {
          final category = idea.categoryId != null
              ? categoryMap[idea.categoryId]
              : null;
          final tags = idea.tagIds
              .map((id) => tagMap[id])
              .whereType<TagEntity>()
              .toList();

          return {
            'id': idea.id,
            'content': idea.content,
            'categoryId': idea.categoryId,
            'category': category != null
                ? {
                    'id': category.id,
                    'name': category.name,
                    'icon': category.icon,
                  }
                : null,
            'tags': tags
                .map((tag) => {
                      'id': tag.id,
                      'name': tag.name,
                    })
                .toList(),
            'createdAt': idea.createdAt.toIso8601String(),
            'updatedAt': idea.updatedAt.toIso8601String(),
            'deletedAt': idea.deletedAt?.toIso8601String(),
            'isDeleted': idea.isDeleted,
            'aiStatus': idea.aiStatus.name,
            'tagIds': idea.tagIds,
          };
        }).toList(),
      };

      // 生成文件名
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final actualFileName = fileName ?? '灵感导出_$timestamp.json';

      // 保存文件
      final filePath = await _saveJsonFile(exportData, actualFileName);

      _logger.info('JSON 导出成功: $filePath, 共 ${ideas.length} 条记录');
      return Result.success(filePath);
    } catch (e, st) {
      _logger.error('导出 JSON 失败', e, st);
      return Result.error('导出失败: $e', e);
    }
  }

  /// 根据筛选条件获取灵感列表
  Future<List<IdeaEntity>> _getFilteredIdeas(ExportFilter? filter) async {
    List<IdeaEntity> ideas;

    if (filter?.categoryId != null) {
      // 按分类获取
      ideas = await _ideaRepository.getByCategory(filter!.categoryId!);
    } else {
      // 获取所有（不包含已删除）
      ideas = await _ideaRepository.getAll(includeDeleted: false);
    }

    // 应用日期筛选
    if (filter?.startDate != null || filter?.endDate != null) {
      ideas = ideas.where((idea) {
        if (filter!.startDate != null &&
            idea.createdAt.isBefore(filter.startDate!)) {
          return false;
        }
        if (filter.endDate != null &&
            idea.createdAt.isAfter(filter.endDate!)) {
          return false;
        }
        return true;
      }).toList();
    }

    // 按创建时间倒序排列
    ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ideas;
  }

  /// 获取分类 ID -> 实体映射
  Future<Map<int, CategoryEntity>> _getCategoryMap() async {
    final categories = await _categoryRepository.getAll();
    return {for (var c in categories) c.id: c};
  }

  /// 获取标签 ID -> 实体映射
  Future<Map<int, TagEntity>> _getTagMap() async {
    final tags = await _tagRepository.getAll();
    return {for (var t in tags) t.id: t};
  }

  /// 保存 Excel 文件
  Future<String> _saveExcelFile(Excel excel, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    // 确保导出目录存在
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final filePath = '${exportDir.path}/$fileName';
    final file = File(filePath);

    // 将 Excel 写入文件
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Excel 编码失败');
    }
    await file.writeAsBytes(bytes);

    return filePath;
  }

  /// 保存 JSON 文件
  Future<String> _saveJsonFile(Map<String, dynamic> data, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    // 确保导出目录存在
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final filePath = '${exportDir.path}/$fileName';
    final file = File(filePath);

    // 将 JSON 写入文件（格式化输出）
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(data);
    await file.writeAsString(jsonString);

    return filePath;
  }
}
