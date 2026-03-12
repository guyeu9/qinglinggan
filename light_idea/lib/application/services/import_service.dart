import 'dart:convert';
import 'package:excel/excel.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/idea_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../task_queue/ai_task_queue.dart';
import '../../core/utils/result.dart';
import '../../core/logger/app_logger.dart';

/// 冲突处理策略
enum ConflictStrategy {
  /// 覆盖已存在的记录
  overwrite,
  /// 跳过已存在的记录
  skip,
  /// 合并记录（保留原有数据，补充新数据）
  merge,
}

/// 导入结果
class ImportResult {
  final int successCount;
  final int skipCount;
  final int errorCount;
  final List<String> errors;

  const ImportResult({
    required this.successCount,
    required this.skipCount,
    required this.errorCount,
    required this.errors,
  });

  ImportResult copyWith({
    int? successCount,
    int? skipCount,
    int? errorCount,
    List<String>? errors,
  }) {
    return ImportResult(
      successCount: successCount ?? this.successCount,
      skipCount: skipCount ?? this.skipCount,
      errorCount: errorCount ?? this.errorCount,
      errors: errors ?? this.errors,
    );
  }

  /// 总处理数量
  int get totalProcessed => successCount + skipCount + errorCount;

  @override
  String toString() {
    return 'ImportResult(success: $successCount, skip: $skipCount, error: $errorCount)';
  }
}

/// 导入服务
class ImportService {
  final IdeaRepository _ideaRepository;
  final CategoryRepository _categoryRepository;
  final TagRepository _tagRepository;
  final AITaskQueue _aiTaskQueue;
  final AppLogger _logger;

  ImportService({
    required IdeaRepository ideaRepository,
    required CategoryRepository categoryRepository,
    required TagRepository tagRepository,
    required AITaskQueue aiTaskQueue,
    required AppLogger logger,
  })  : _ideaRepository = ideaRepository,
        _categoryRepository = categoryRepository,
        _tagRepository = tagRepository,
        _aiTaskQueue = aiTaskQueue,
        _logger = logger;

  /// 从 Excel 字节数据导入
  /// 
  /// [bytes] Excel 文件的字节数据
  /// [strategy] 冲突处理策略
  /// [triggerAIAnalysis] 是否触发 AI 分析
  /// [idColumn] ID 列名，默认为 'id'
  /// [contentColumn] 内容列名，默认为 'content'
  /// [categoryColumn] 分类列名，默认为 'category'
  /// [tagsColumn] 标签列名，默认为 'tags'，多个标签用逗号分隔
  /// [createdAtColumn] 创建时间列名，默认为 'createdAt'
  Future<Result<ImportResult>> importFromExcel(
    List<int> bytes, {
    ConflictStrategy strategy = ConflictStrategy.skip,
    bool triggerAIAnalysis = false,
    String idColumn = 'id',
    String contentColumn = 'content',
    String categoryColumn = 'category',
    String tagsColumn = 'tags',
    String createdAtColumn = 'createdAt',
  }) async {
    try {
      _logger.info('开始从 Excel 导入数据');

      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.values.first;

      // 解析表头
      final headers = <String, int>{};
      final maxCols = sheet.columns.length;
      for (var col = 0; col < maxCols; col++) {
        final cell = sheet.cell(CellIndex.indexByString('${_colIndexToLetter(col)}1'));
        if (cell.value != null) {
          headers[cell.value.toString().trim().toLowerCase()] = col;
        }
      }

      // 验证必要列
      if (!headers.containsKey(contentColumn.toLowerCase())) {
        return Result.error('Excel 文件缺少必要的列: $contentColumn');
      }

      final contentColIndex = headers[contentColumn.toLowerCase()]!;
      final idColIndex = headers[idColumn.toLowerCase()];
      final categoryColIndex = headers[categoryColumn.toLowerCase()];
      final tagsColIndex = headers[tagsColumn.toLowerCase()];
      final createdAtColIndex = headers[createdAtColumn.toLowerCase()];

      // 解析数据行
      final rows = <Map<String, dynamic>>[];
      for (var row = 2; row <= sheet.maxRows; row++) {
        final rowData = <String, dynamic>{};

        // 获取内容
        final contentCell = sheet.cell(CellIndex.indexByString('${_colIndexToLetter(contentColIndex)}$row'));
        if (contentCell.value == null || contentCell.value.toString().trim().isEmpty) {
          continue; // 跳过空内容行
        }
        rowData['content'] = contentCell.value.toString().trim();

        // 获取 ID
        if (idColIndex != null) {
          final idCell = sheet.cell(CellIndex.indexByString('${_colIndexToLetter(idColIndex)}$row'));
          if (idCell.value != null) {
            final idStr = idCell.value.toString().trim();
            final id = int.tryParse(idStr);
            if (id != null) {
              rowData['id'] = id;
            }
          }
        }

        // 获取分类
        if (categoryColIndex != null) {
          final categoryCell = sheet.cell(CellIndex.indexByString('${_colIndexToLetter(categoryColIndex)}$row'));
          if (categoryCell.value != null) {
            rowData['category'] = categoryCell.value.toString().trim();
          }
        }

        // 获取标签
        if (tagsColIndex != null) {
          final tagsCell = sheet.cell(CellIndex.indexByString('${_colIndexToLetter(tagsColIndex)}$row'));
          if (tagsCell.value != null) {
            rowData['tags'] = tagsCell.value.toString().trim();
          }
        }

        // 获取创建时间
        if (createdAtColIndex != null) {
          final createdAtCell = sheet.cell(CellIndex.indexByString('${_colIndexToLetter(createdAtColIndex)}$row'));
          if (createdAtCell.value != null) {
            final dateValue = createdAtCell.value;
            if (dateValue is DateTime) {
              rowData['createdAt'] = dateValue;
            } else {
              final parsed = DateTime.tryParse(dateValue.toString());
              if (parsed != null) {
                rowData['createdAt'] = parsed;
              }
            }
          }
        }

        rows.add(rowData);
      }

      _logger.info('解析到 ${rows.length} 条数据');

      return _processImportData(
        rows,
        strategy: strategy,
        triggerAIAnalysis: triggerAIAnalysis,
      );
    } catch (e, st) {
      _logger.error('Excel 导入失败', e, st);
      return Result.error('Excel 导入失败: $e', e);
    }
  }

  /// 从 JSON 字符串导入
  /// 
  /// [jsonString] JSON 字符串，支持数组格式或对象格式
  /// [strategy] 冲突处理策略
  /// [triggerAIAnalysis] 是否触发 AI 分析
  Future<Result<ImportResult>> importFromJson(
    String jsonString, {
    ConflictStrategy strategy = ConflictStrategy.skip,
    bool triggerAIAnalysis = false,
  }) async {
    try {
      _logger.info('开始从 JSON 导入数据');

      final dynamic jsonData = jsonDecode(jsonString);

      List<Map<String, dynamic>> dataList;
      if (jsonData is List) {
        dataList = jsonData.cast<Map<String, dynamic>>();
      } else if (jsonData is Map) {
        // 支持单个对象格式
        dataList = [jsonData.cast<String, dynamic>()];
      } else {
        return Result.error('JSON 格式无效，期望数组或对象');
      }

      _logger.info('解析到 ${dataList.length} 条数据');

      return _processImportData(
        dataList,
        strategy: strategy,
        triggerAIAnalysis: triggerAIAnalysis,
      );
    } catch (e, st) {
      _logger.error('JSON 导入失败', e, st);
      return Result.error('JSON 导入失败: $e', e);
    }
  }

  /// 处理导入数据
  Future<Result<ImportResult>> _processImportData(
    List<Map<String, dynamic>> dataList, {
    required ConflictStrategy strategy,
    required bool triggerAIAnalysis,
  }) async {
    int successCount = 0;
    int skipCount = 0;
    int errorCount = 0;
    final errors = <String>[];

    for (var i = 0; i < dataList.length; i++) {
      final data = dataList[i];
      final rowNum = i + 2; // 用于错误提示

      try {
        // 验证必要字段
        final content = data['content']?.toString().trim();
        if (content == null || content.isEmpty) {
          errors.add('第 $rowNum 行: 内容为空，已跳过');
          errorCount++;
          continue;
        }

        // 检查是否存在冲突
        final existingId = data['id'] as int?;
        IdeaEntity? existingIdea;
        if (existingId != null) {
          existingIdea = await _ideaRepository.getById(existingId);
        }

        // 处理冲突
        if (existingIdea != null) {
          switch (strategy) {
            case ConflictStrategy.skip:
              skipCount++;
              _logger.info('第 $rowNum 行: ID ${existingId} 已存在，跳过');
              continue;
            case ConflictStrategy.overwrite:
              // 继续处理，会覆盖
              break;
            case ConflictStrategy.merge:
              // 合并数据
              final mergedIdea = await _mergeIdea(existingIdea, data);
              await _ideaRepository.update(mergedIdea);
              successCount++;
              _logger.info('第 $rowNum 行: ID ${existingId} 已合并');
              if (triggerAIAnalysis) {
                _aiTaskQueue.enqueue(mergedIdea.id);
              }
              continue;
          }
        }

        // 处理分类
        int? categoryId;
        final categoryName = data['category']?.toString().trim();
        if (categoryName != null && categoryName.isNotEmpty) {
          categoryId = await _getOrCreateCategoryId(categoryName);
        }

        // 处理标签
        final tagIds = <int>[];
        final tagsStr = data['tags']?.toString().trim();
        if (tagsStr != null && tagsStr.isNotEmpty) {
          final tagNames = tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty);
          for (final tagName in tagNames) {
            final tag = await _tagRepository.saveIfNotExists(tagName);
            tagIds.add(tag.id);
          }
        }

        // 解析创建时间
        DateTime createdAt;
        if (data['createdAt'] is DateTime) {
          createdAt = data['createdAt'] as DateTime;
        } else if (data['createdAt'] != null) {
          createdAt = DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now();
        } else {
          createdAt = DateTime.now();
        }

        // 创建或更新灵感实体
        final idea = IdeaEntity(
          id: existingId ?? 0,
          content: content,
          categoryId: categoryId,
          createdAt: createdAt,
          updatedAt: DateTime.now(),
          tagIds: tagIds,
          aiStatus: AIStatus.pending,
        );

        final savedIdea = await _ideaRepository.save(idea);
        successCount++;

        // 触发 AI 分析
        if (triggerAIAnalysis) {
          _aiTaskQueue.enqueue(savedIdea.id);
        }
      } catch (e) {
        errors.add('第 $rowNum 行: 处理失败 - $e');
        errorCount++;
        _logger.error('第 $rowNum 行处理失败', e);
      }
    }

    final result = ImportResult(
      successCount: successCount,
      skipCount: skipCount,
      errorCount: errorCount,
      errors: errors,
    );

    _logger.info('导入完成: $result');
    return Result.success(result);
  }

  /// 合并灵感数据
  Future<IdeaEntity> _mergeIdea(IdeaEntity existing, Map<String, dynamic> newData) async {
    // 合并分类
    int? categoryId = existing.categoryId;
    final categoryName = newData['category']?.toString().trim();
    if (categoryName != null && categoryName.isNotEmpty) {
      categoryId = await _getOrCreateCategoryId(categoryName);
    }

    // 合并标签
    final tagIds = List<int>.from(existing.tagIds);
    final tagsStr = newData['tags']?.toString().trim();
    if (tagsStr != null && tagsStr.isNotEmpty) {
      final tagNames = tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty);
      for (final tagName in tagNames) {
        final tag = await _tagRepository.saveIfNotExists(tagName);
        if (!tagIds.contains(tag.id)) {
          tagIds.add(tag.id);
        }
      }
    }

    // 合并内容（如果新内容不为空则更新）
    String content = existing.content;
    final newContent = newData['content']?.toString().trim();
    if (newContent != null && newContent.isNotEmpty) {
      content = newContent;
    }

    return existing.copyWith(
      content: content,
      categoryId: categoryId,
      tagIds: tagIds,
      updatedAt: DateTime.now(),
    );
  }

  /// 获取或创建分类 ID
  Future<int?> _getOrCreateCategoryId(String categoryName) async {
    var category = await _categoryRepository.getByName(categoryName);
    if (category == null) {
      // 创建新分类
      final newCategory = CategoryEntity(
        id: 0,
        name: categoryName,
        icon: 'folder',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );
      category = await _categoryRepository.save(newCategory);
      _logger.info('创建新分类: ${category.name}');
    }
    return category.id;
  }

  /// 列索引转字母（如 0 -> A, 1 -> B, 26 -> AA）
  String _colIndexToLetter(int index) {
    final letters = <String>[];
    var temp = index;
    while (temp >= 0) {
      letters.insert(0, String.fromCharCode(65 + (temp % 26)));
      temp = (temp ~/ 26) - 1;
    }
    return letters.join();
  }
}
