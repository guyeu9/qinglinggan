import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/category.dart';
import '../../../application/providers/app_providers.dart';
import '../../../application/services/export_service.dart';
import '../../../application/services/import_service.dart';

/// 数据管理页面
///
/// 根据原型图 5数据管理 实现
/// 包含：数据导出区、数据导入区、数据安全提示栏
class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  bool _isDragging = false;
  bool _isExporting = false;
  bool _isImporting = false;
  List<CategoryEntity> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final categories = await categoryRepo.getAll();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('数据管理'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 数据导出区
              _buildSectionTitle('数据导出', textSecondary),
              _buildExportSection(isDark, cardColor, textPrimary, textSecondary),

              const SizedBox(height: AppTheme.spacingLg),

              // 数据导入区
              _buildSectionTitle('数据导入', textSecondary),
              _buildImportSection(isDark, cardColor, textPrimary, textSecondary),

              const SizedBox(height: AppTheme.spacingLg),

              // 数据安全提示栏
              _buildSecurityNotice(isDark, textPrimary, textSecondary),

              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建区域标题
  Widget _buildSectionTitle(String title, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingSm,
        bottom: AppTheme.spacingSm,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 构建数据导出区
  Widget _buildExportSection(
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 导出至Excel
          _buildExportTile(
            icon: Icons.table_chart_outlined,
            iconColor: AppColors.success,
            title: '导出至 Excel',
            subtitle: '导出为 .xlsx 格式文件',
            format: '.xlsx',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: _isExporting ? null : () => _exportToExcel(),
          ),
          _buildDivider(isDark),
          // 导出至数据库
          _buildExportTile(
            icon: Icons.storage_outlined,
            iconColor: AppColors.info,
            title: '导出至数据库',
            subtitle: '导出为 .json 备份文件',
            format: '.json',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: _isExporting ? null : () => _exportToDatabase(),
          ),
        ],
      ),
    );
  }

  /// 构建导出项
  Widget _buildExportTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String format,
    required Color textPrimary,
    required Color textSecondary,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // 文字内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onTap == null ? textSecondary : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 格式标签
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                format,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            // 箭头
            Icon(
              Icons.chevron_right,
              color: textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数据导入区
  Widget _buildImportSection(
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文件上传区域
            MouseRegion(
              onEnter: (_) => setState(() => _isDragging = true),
              onExit: (_) => setState(() => _isDragging = false),
              child: GestureDetector(
                onTap: _isImporting ? null : () => _pickFile(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingXl,
                  ),
                  decoration: BoxDecoration(
                    color: _isDragging
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _isDragging
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: _isDragging ? 2 : 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isImporting)
                        const CircularProgressIndicator()
                      else
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: _isDragging
                              ? AppColors.primary
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        _isImporting ? '正在导入...' : '点击或拖拽文件至此处',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        '支持 .xlsx, .json 备份文件',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // 支持的格式说明
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    '导入将合并数据，不会覆盖现有内容',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数据安全提示栏
  Widget _buildSecurityNotice(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.warning.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_outlined,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据安全提示',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '请妥善保管导出的数据文件，避免数据泄露。建议定期备份重要数据。',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 76,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  /// 导出至Excel
  Future<void> _exportToExcel() async {
    final result = await _showExportOptionsDialog('Excel');
    if (result == null || !mounted) return;

    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final exportResult = await exportService.exportToExcel(
        filter: result.filter,
      );

      if (!mounted) return;

      if (exportResult.isSuccess) {
        _showSuccessSnackBar('数据导出成功\n文件已保存到: ${exportResult.dataOrNull}');
      } else {
        _showErrorSnackBar(exportResult.errorOrNull ?? '导出失败');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// 导出至数据库（JSON格式）
  Future<void> _exportToDatabase() async {
    final result = await _showExportOptionsDialog('数据库');
    if (result == null || !mounted) return;

    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final exportResult = await exportService.exportToJson(
        filter: result.filter,
      );

      if (!mounted) return;

      if (exportResult.isSuccess) {
        _showSuccessSnackBar('数据导出成功\n文件已保存到: ${exportResult.dataOrNull}');
      } else {
        _showErrorSnackBar(exportResult.errorOrNull ?? '导出失败');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// 显示导出选项对话框
  Future<_ExportOptions?> _showExportOptionsDialog(String type) async {
    int? selectedCategoryId;
    DateTime? startDate;
    DateTime? endDate;

    return showDialog<_ExportOptions>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('导出至$type'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类筛选
                    Text(
                      '分类筛选',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: selectedCategoryId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('全部分类'),
                        ),
                        ..._categories.map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        )),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // 时间范围
                    Text(
                      '时间范围',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  startDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                hintText: '开始日期',
                              ),
                              child: Text(
                                startDate != null
                                    ? '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}'
                                    : '开始日期',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: startDate != null
                                      ? AppColors.textPrimaryLight
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  endDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                hintText: '结束日期',
                              ),
                              child: Text(
                                endDate != null
                                    ? '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
                                    : '结束日期',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: endDate != null
                                      ? AppColors.textPrimaryLight
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '导出文件将保存到应用文档目录',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _ExportOptions(
                      filter: ExportFilter(
                        categoryId: selectedCategoryId,
                        startDate: startDate,
                        endDate: endDate,
                      ),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('导出'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 选择文件并导入
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final extension = file.extension?.toLowerCase();

      if (extension != 'xlsx' && extension != 'json') {
        _showErrorSnackBar('不支持的文件格式，请选择 .xlsx 或 .json 文件');
        return;
      }

      // 显示导入选项对话框
      final importOptions = await _showImportOptionsDialog();
      if (importOptions == null || !mounted) return;

      setState(() => _isImporting = true);

      try {
        final importService = ref.read(importServiceProvider);
        Result<ImportResult> importResult;

        if (extension == 'xlsx') {
          importResult = await importService.importFromExcel(
            file.bytes!,
            strategy: importOptions.strategy,
            triggerAIAnalysis: importOptions.triggerAIAnalysis,
          );
        } else {
          final jsonString = String.fromCharCodes(file.bytes!);
          importResult = await importService.importFromJson(
            jsonString,
            strategy: importOptions.strategy,
            triggerAIAnalysis: importOptions.triggerAIAnalysis,
          );
        }

        if (!mounted) return;

        if (importResult.isSuccess) {
          final data = importResult.dataOrNull!;
          _showImportResultDialog(data);
        } else {
          _showErrorSnackBar(importResult.errorOrNull ?? '导入失败');
        }
      } finally {
        if (mounted) {
          setState(() => _isImporting = false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('文件选择失败: $e');
      }
    }
  }

  /// 显示导入选项对话框
  Future<_ImportOptions?> _showImportOptionsDialog() async {
    ConflictStrategy strategy = ConflictStrategy.skip;
    bool triggerAIAnalysis = false;

    return showDialog<_ImportOptions>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('导入选项'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 冲突处理策略
                  Text(
                    '冲突处理策略',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...[
                    (ConflictStrategy.skip, '跳过已存在的记录', '保留原有数据，跳过重复记录'),
                    (ConflictStrategy.overwrite, '覆盖已存在的记录', '用新数据替换原有数据'),
                    (ConflictStrategy.merge, '合并记录', '保留原有数据，补充新数据'),
                  ].map((item) {
                    final (value, title, subtitle) = item;
                    return RadioListTile<ConflictStrategy>(
                      title: Text(title),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                      value: value,
                      groupValue: strategy,
                      onChanged: (v) {
                        setDialogState(() {
                          strategy = v!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                  const SizedBox(height: 16),

                  // AI分析选项
                  CheckboxListTile(
                    title: const Text('触发 AI 分析'),
                    subtitle: Text(
                      '导入后自动对灵感进行 AI 分析',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    value: triggerAIAnalysis,
                    onChanged: (v) {
                      setDialogState(() {
                        triggerAIAnalysis = v ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _ImportOptions(
                      strategy: strategy,
                      triggerAIAnalysis: triggerAIAnalysis,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('导入'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 显示导入结果对话框
  void _showImportResultDialog(ImportResult result) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('导入完成'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow(Icons.check_circle, AppColors.success, '成功', result.successCount),
              const SizedBox(height: 8),
              _buildResultRow(Icons.skip_next, AppColors.warning, '跳过', result.skipCount),
              const SizedBox(height: 8),
              _buildResultRow(Icons.error, AppColors.error, '错误', result.errorCount),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '错误详情:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: result.errors.length > 10 ? 10 : result.errors.length,
                    itemBuilder: (context, index) {
                      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          result.errors[index],
          style: TextStyle(
            fontSize: 12,
            color: AppColors.error,
          ),
        ),
      );
    },
  ),
),
if (result.errors.length > 10)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      '还有 ${result.errors.length - 10} 条错误未显示...',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondaryLight,
      ),
    ),
  ),
],
],
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('确定'),
),
],
);
},
);
}

Widget _buildResultRow(IconData icon, Color color, String label, int count) {
return Row(
children: [
Icon(icon, color: color, size: 20),
const SizedBox(width: 8),
Text(
label,
style: TextStyle(
fontSize: 14,
color: AppColors.textPrimaryLight,
),
),
const Spacer(),
Text(
'$count 条',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: color,
),
),
],
);
}

/// 显示成功提示
void _showSuccessSnackBar(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Row(
children: [
const Icon(
Icons.check_circle_outline,
color: Colors.white,
),
const SizedBox(width: 8),
Expanded(child: Text(message)),
],
),
backgroundColor: AppColors.success,
behavior: SnackBarBehavior.floating,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
),
duration: const Duration(seconds: 4),
),
);
}

/// 显示错误提示
void _showErrorSnackBar(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Row(
children: [
const Icon(
Icons.error_outline,
color: Colors.white,
),
const SizedBox(width: 8),
Expanded(child: Text(message)),
],
),
backgroundColor: AppColors.error,
behavior: SnackBarBehavior.floating,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
),
duration: const Duration(seconds: 4),
),
);
}
}

/// 导出选项
class _ExportOptions {
final ExportFilter filter;

const _ExportOptions({required this.filter});
}

/// 导入选项
class _ImportOptions {
final ConflictStrategy strategy;
final bool triggerAIAnalysis;

const _ImportOptions({
required this.strategy,
required this.triggerAIAnalysis,
});
}
