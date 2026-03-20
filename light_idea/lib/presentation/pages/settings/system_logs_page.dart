import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/services/log_service.dart';

/// 系统日志页面
/// 
/// 展示应用运行日志，用于排查问题
/// 支持搜索、过滤、复制等功能
class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({super.key});

  @override
  State<SystemLogsPage> createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  LogLevel? _minLevel;
  bool _autoScroll = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _autoScroll) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _copyAllLogs() async {
    final text = logService.getAllLogsText();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('所有日志已复制到剪贴板'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyLogEntry(LogEntry entry) async {
    await Clipboard.setData(ClipboardData(text: entry.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('日志已复制到剪贴板'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _clearLogs() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确定要清空所有日志吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              logService.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('日志已清空'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF064E3B) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF064E3B) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        title: Text(
          '系统日志',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // 自动滚动开关
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '自动滚动',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Switch(
                value: _autoScroll,
                onChanged: (value) {
                  setState(() {
                    _autoScroll = value;
                  });
                },
                activeThumbColor: const Color(0xFF6EE7B7),
              ),
            ],
          ),
          // 复制全部
          IconButton(
            onPressed: _copyAllLogs,
            icon: Icon(
              Symbols.content_copy,
              color: isDark ? Colors.white : Colors.black,
            ),
            tooltip: '复制全部日志',
          ),
          // 清空日志
          IconButton(
            onPressed: _clearLogs,
            icon: Icon(
              Symbols.delete_forever,
              color: isDark ? Colors.white : Colors.black,
            ),
            tooltip: '清空日志',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索和过滤栏
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? const Color(0xFF064E3B) : Colors.white,
            child: Column(
              children: [
                // 搜索框
                TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: '搜索日志...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    prefixIcon: Icon(
                      Symbols.search,
                      color: isDark ? Colors.white54 : Colors.black,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: Icon(
                              Symbols.close,
                              color: isDark ? Colors.white54 : Colors.black,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 日志级别过滤
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLevelFilterChip(null, '全部', isDark),
                      const SizedBox(width: 8),
                      _buildLevelFilterChip(LogLevel.debug, '调试', isDark),
                      const SizedBox(width: 8),
                      _buildLevelFilterChip(LogLevel.info, '信息', isDark),
                      const SizedBox(width: 8),
                      _buildLevelFilterChip(LogLevel.warning, '警告', isDark),
                      const SizedBox(width: 8),
                      _buildLevelFilterChip(LogLevel.error, '错误', isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 日志列表
          Expanded(
            child: ValueListenableBuilder<List<LogEntry>>(
              valueListenable: logService.logStream,
              builder: (context, logs, child) {
                final filteredLogs = logService.getFilteredLogs(
                  searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
                  minLevel: _minLevel,
                );

                // 自动滚动到底部
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.article,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无日志',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final entry = filteredLogs[index];
                    return _buildLogItem(entry, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilterChip(LogLevel? level, String label, bool isDark) {
    final isSelected = _minLevel == level;
    final color = level != null ? _getLevelColor(level) : (isDark ? Colors.grey : Colors.black);

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _minLevel = selected ? level : null;
        });
      },
      backgroundColor: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.grey[200],
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected
              ? color
              : (isDark ? Colors.white70 : Colors.black),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLogItem(LogEntry entry, bool isDark) {
    final levelColor = _getLevelColor(entry.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? const Color(0xFF065F46) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: levelColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _copyLogEntry(entry),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：时间和级别
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.levelString,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.formattedTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Symbols.content_copy,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 日志内容
              Text(
                entry.message,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black,
                  height: 1.4,
                ),
              ),
              // 错误信息
              if (entry.error != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Error: ${entry.error}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
