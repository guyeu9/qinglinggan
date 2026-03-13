import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../application/providers/app_providers.dart';
import '../../../../application/services/import_service.dart';
import '../../../../core/utils/result.dart';

/// 数据管理页面
///
/// 严格按照原型图实现:
/// d:\trae\qinglinggan\前端原型图\5数据管理\code.html
///
/// 颜色定义:
/// - primary: #6EE7B7
/// - primary-dark: #065F46
/// - background-light: #F0FDF4
/// - background-dark: #064e3b
class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  bool _isExporting = false;
  bool _isImporting = false;

  void _goBack() {
    context.pop();
  }

  /// 导出至Excel
  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final result = await exportService.exportToExcel();

      if (!mounted) return;

      if (result.isSuccess) {
        _showSuccessSnackBar('Excel导出成功');
      } else {
        _showErrorSnackBar(result.errorOrNull ?? '导出失败');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('导出失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// 导出至数据库
  Future<void> _exportToDatabase() async {
    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final result = await exportService.exportToJson();

      if (!mounted) return;

      if (result.isSuccess) {
        _showSuccessSnackBar('数据库备份成功');
      } else {
        _showErrorSnackBar(result.errorOrNull ?? '导出失败');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('导出失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
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

      setState(() => _isImporting = true);

      try {
        final importService = ref.read(importServiceProvider);
        Result<ImportResult> importResult;

        if (extension == 'xlsx') {
          importResult = await importService.importFromExcel(file.bytes!);
        } else {
          final jsonString = String.fromCharCodes(file.bytes!);
          importResult = await importService.importFromJson(jsonString);
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

  void _showImportResultDialog(ImportResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF064e3b) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            '导入完成',
            style: TextStyle(
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow(Icons.check_circle, const Color(0xFF39E079), '成功', result.successCount),
              const SizedBox(height: 8),
              _buildResultRow(Icons.skip_next, Colors.orange, '跳过', result.skipCount),
              const SizedBox(height: 8),
              _buildResultRow(Icons.error, const Color(0xFFef4444), '错误', result.errorCount),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '确定',
                style: TextStyle(
                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                ),
              ),
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
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF065F46),
          ),
        ),
        const Spacer(),
        Text(
          '$count 条',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showSuccessSnackBar(String message) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Symbols.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF065F46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Symbols.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFef4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 严格使用原型图颜色
    final backgroundColor = isDark ? const Color(0xFF064e3b) : const Color(0xFFF0FDF4);
    final textColor = isDark ? Colors.white : const Color(0xFF065F46);
    final secondaryTextColor = isDark
        ? const Color(0xFF6EE7B7).withValues(alpha: 0.7)
        : const Color(0xFF64748b);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark, textColor),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 数据导出区
                    _buildExportSection(isDark, textColor, secondaryTextColor),

                    const SizedBox(height: 32),

                    // 数据导入区
                    _buildImportSection(isDark, textColor, secondaryTextColor),

                    const SizedBox(height: 32),

                    // 数据安全提示栏
                    _buildSecurityNotice(isDark, textColor, secondaryTextColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header
  ///
  /// 原型图代码:
  /// ```html
  /// <header class="flex items-center justify-between p-4 bg-background-light dark:bg-background-dark sticky top-0 z-10 border-b border-primary/10">
  ///   <button class="text-primary-dark dark:text-primary flex items-center justify-center p-2 rounded-full hover:bg-primary/10 transition-colors">
  ///     <span class="material-symbols-outlined">arrow_back</span>
  ///   </button>
  ///   <h1 class="text-primary-dark dark:text-white text-lg font-bold flex-1 text-center pr-10">数据管理</h1>
  /// </header>
  /// ```
  Widget _buildHeader(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064e3b) : const Color(0xFFF0FDF4),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF6EE7B7).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _goBack,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  Symbols.arrow_back,
                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                  size: 24,
                ),
              ),
            ),
          ),

          // 标题
          Expanded(
            child: Text(
              '数据管理',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF065F46),
              ),
            ),
          ),

          // 占位
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// 数据导出区
  ///
  /// 原型图代码:
  /// ```html
  /// <section class="p-5">
  ///   <div class="mb-6">
  ///     <h2 class="text-primary-dark dark:text-primary text-2xl font-bold mb-2">数据导出</h2>
  ///     <p class="text-slate-600 dark:text-slate-300 text-sm leading-relaxed">将所有灵感导出为 Excel 或数据库格式以进行备份...</p>
  ///   </div>
  ///   <div class="grid grid-cols-2 gap-4">
  ///     <!-- Export to Excel Card -->
  ///     <button class="flex flex-col items-center justify-center p-6 bg-white dark:bg-slate-800 rounded-xl border border-primary/20 shadow-sm hover:shadow-md transition-all group">
  ///       ...
  ///     </button>
  ///     <!-- Export to DB Card -->
  ///     ...
  ///   </div>
  /// </section>
  /// ```
  Widget _buildExportSection(bool isDark, Color textColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和描述
        Text(
          '数据导出',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '将所有灵感导出为 Excel 或数据库格式以进行备份，确保您的创意永不丢失。',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 20),

        // 导出选项
        Row(
          children: [
            // Excel导出
            Expanded(
              child: _buildExportCard(
                icon: Symbols.table_view,
                title: '导出至 Excel',
                subtitle: '.xlsx 格式',
                isDark: isDark,
                secondaryTextColor: secondaryTextColor,
                onTap: _isExporting ? null : _exportToExcel,
              ),
            ),
            const SizedBox(width: 16),
            // 数据库导出
            Expanded(
              child: _buildExportCard(
                icon: Symbols.database,
                title: '导出至数据库',
                subtitle: '.db 格式',
                isDark: isDark,
                secondaryTextColor: secondaryTextColor,
                onTap: _isExporting ? null : _exportToDatabase,
              ),
            ),
          ],
        ),

        if (_isExporting) ...[
          const SizedBox(height: 16),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6EE7B7)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required Color secondaryTextColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.3) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 图标
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE7B7).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              // 标题
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 4),
              // 副标题
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 数据导入区
  ///
  /// 原型图代码:
  /// ```html
  /// <section class="p-5 mt-4">
  ///   <div class="mb-6">
  ///     <h2 class="text-primary-dark dark:text-primary text-2xl font-bold mb-2">数据导入</h2>
  ///     <p class="text-slate-600 dark:text-slate-300 text-sm leading-relaxed">从以前备份的数据文件中恢复您的灵感...</p>
  ///   </div>
  ///   <!-- Large Upload Area -->
  ///   <div class="relative group">
  ///     <input class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-20" type="file"/>
  ///     <div class="flex flex-col items-center justify-center p-10 bg-white dark:bg-slate-800 border-2 border-dashed border-primary/30 rounded-xl group-hover:border-primary transition-colors">
  ///       ...
  ///     </div>
  ///   </div>
  /// </section>
  /// ```
  Widget _buildImportSection(bool isDark, Color textColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和描述
        Text(
          '数据导入',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '从以前备份的数据文件中恢复您的灵感，支持多种格式导入。',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 20),

        // 上传区域
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isImporting ? null : _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.3) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isImporting)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6EE7B7)),
                    )
                  else
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EE7B7).withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Symbols.cloud_upload,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                        size: 32,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _isImporting ? '正在导入...' : '点击或拖拽文件到此处',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '支持 .xlsx, .db 备份文件',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 数据安全提示栏
  ///
  /// 原型图代码:
  /// ```html
  /// <section class="p-8 mt-4">
  ///   <div class="flex items-start gap-3 p-4 bg-primary/5 dark:bg-primary/10 rounded-lg">
  ///     <span class="material-symbols-outlined text-primary text-xl flex-shrink-0">shield_lock</span>
  ///     <div class="flex flex-col">
  ///       <h4 class="text-primary-dark dark:text-primary text-sm font-bold">数据安全提示</h4>
  ///       <p class="text-slate-500 dark:text-slate-400 text-xs mt-1 leading-relaxed">您的灵感数据存储在本地设备中...</p>
  ///     </div>
  ///   </div>
  /// </section>
  /// ```
  Widget _buildSecurityNotice(bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6EE7B7).withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.shield_lock,
            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据安全提示',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '您的灵感数据存储在本地设备中，导出文件仅包含您的个人创作内容。我们建议定期备份以防止意外丢失。',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
