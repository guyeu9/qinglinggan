import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// AI 设置详情页
///
/// 根据原型图 8侧边栏-ai管理详情页 实现
/// 包含：分析API设置、向量API设置、状态提示、保存功能
class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  // 分析API设置
  bool _analysisEnabled = true;
  final TextEditingController _apiUrlController = TextEditingController(
    text: 'https://api.openai.com/v1',
  );
  final TextEditingController _apiKeyController = TextEditingController();
  bool _apiKeyVisible = false;
  String _selectedModel = 'GPT-4o';

  // 向量API设置
  final TextEditingController _embeddingUrlController = TextEditingController(
    text: 'https://api.openai.com/v1/embeddings',
  );
  final TextEditingController _vectorApiKeyController = TextEditingController();
  bool _vectorApiKeyVisible = false;
  final TextEditingController _vectorDimensionController =
      TextEditingController(text: '1536');

  // 连接状态
  bool _isTestingConnection = false;
  String? _connectionStatus;

  final List<String> _models = [
    'GPT-4o',
    'GPT-4o-mini',
    'GPT-4',
    'GPT-3.5-Turbo',
    'Claude-3-Opus',
    'Claude-3-Sonnet',
    'Claude-3-Haiku',
  ];

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _embeddingUrlController.dispose();
    _vectorApiKeyController.dispose();
    _vectorDimensionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI 设置'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分析API设置区
                    _buildSectionTitle('分析API设置', textSecondary),
                    _buildSettingsCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      children: [
                        // 启用开关
                        _buildSwitchTile(
                          title: '启用AI分析',
                          subtitle: '开启后将对灵感内容进行智能分析',
                          value: _analysisEnabled,
                          onChanged: (value) {
                            setState(() {
                              _analysisEnabled = value;
                            });
                          },
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildDivider(isDark),
                        // API地址
                        _buildTextFieldTile(
                          label: 'API地址',
                          hint: '请输入API地址',
                          controller: _apiUrlController,
                          icon: Icons.link,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          enabled: _analysisEnabled,
                        ),
                        _buildDivider(isDark),
                        // API密钥
                        _buildPasswordFieldTile(
                          label: 'API密钥',
                          hint: '请输入API密钥',
                          controller: _apiKeyController,
                          visible: _apiKeyVisible,
                          onVisibilityChanged: (visible) {
                            setState(() {
                              _apiKeyVisible = visible;
                            });
                          },
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          enabled: _analysisEnabled,
                        ),
                        _buildDivider(isDark),
                        // 模型选择
                        _buildDropdownTile(
                          label: '模型选择',
                          value: _selectedModel,
                          items: _models,
                          onChanged: _analysisEnabled
                              ? (value) {
                                  setState(() {
                                    _selectedModel = value!;
                                  });
                                }
                              : null,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          enabled: _analysisEnabled,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // 向量API设置区
                    _buildSectionTitle('向量API设置', textSecondary),
                    _buildSettingsCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      children: [
                        // 测试连接按钮
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isTestingConnection
                                      ? null
                                      : _testConnection,
                                  icon: _isTestingConnection
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.network_check),
                                  label: Text(
                                    _isTestingConnection ? '测试中...' : '测试连接',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppTheme.spacingSm,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildDivider(isDark),
                        // 嵌入接口地址
                        _buildTextFieldTile(
                          label: '嵌入接口地址',
                          hint: '请输入嵌入接口地址',
                          controller: _embeddingUrlController,
                          icon: Icons.integration_instructions,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildDivider(isDark),
                        // 向量API密钥
                        _buildPasswordFieldTile(
                          label: '向量API密钥',
                          hint: '请输入向量API密钥',
                          controller: _vectorApiKeyController,
                          visible: _vectorApiKeyVisible,
                          onVisibilityChanged: (visible) {
                            setState(() {
                              _vectorApiKeyVisible = visible;
                            });
                          },
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildDivider(isDark),
                        // 向量维度
                        _buildTextFieldTile(
                          label: '向量维度',
                          hint: '请输入向量维度',
                          controller: _vectorDimensionController,
                          icon: Icons.straighten,
                          keyboardType: TextInputType.number,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // 状态提示卡片
                    if (_connectionStatus != null)
                      _buildStatusCard(isDark: isDark),

                    const SizedBox(height: AppTheme.spacingXl),
                  ],
                ),
              ),
            ),
            // 底部保存按钮
            _buildSaveButton(isDark: isDark),
          ],
        ),
      ),
    );
  }

  /// 构建设置区域标题
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

  /// 构建设置卡片容器
  Widget _buildSettingsCard({
    required bool isDark,
    required Color cardColor,
    required List<Widget> children,
  }) {
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
        children: children,
      ),
    );
  }

  /// 构建开关设置项
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// 构建文本输入设置项
  Widget _buildTextFieldTile({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color textPrimary,
    required Color textSecondary,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled ? textPrimary : textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(
              color: enabled ? textPrimary : textSecondary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: enabled ? textSecondary : textSecondary.withValues(alpha: 0.5),
                size: 20,
              ),
              filled: true,
              fillColor: enabled
                  ? null
                  : textSecondary.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建密码输入设置项
  Widget _buildPasswordFieldTile({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool visible,
    required ValueChanged<bool> onVisibilityChanged,
    required Color textPrimary,
    required Color textSecondary,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled ? textPrimary : textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          TextField(
            controller: controller,
            obscureText: !visible,
            enabled: enabled,
            style: TextStyle(
              color: enabled ? textPrimary : textSecondary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                Icons.key,
                color: enabled ? textSecondary : textSecondary.withValues(alpha: 0.5),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  visible ? Icons.visibility_off : Icons.visibility,
                  color: enabled
                      ? textSecondary
                      : textSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: enabled ? () => onVisibilityChanged(!visible) : null,
              ),
              filled: true,
              fillColor: enabled
                  ? null
                  : textSecondary.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                borderSide: BorderSide(
                  color: textSecondary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建下拉选择设置项
  Widget _buildDropdownTile({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    required Color textPrimary,
    required Color textSecondary,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled ? textPrimary : textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: enabled
                    ? textSecondary.withValues(alpha: 0.2)
                    : textSecondary.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              color: enabled ? null : textSecondary.withValues(alpha: 0.05),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: enabled
                      ? textSecondary
                      : textSecondary.withValues(alpha: 0.5),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: enabled ? textPrimary : textSecondary,
                ),
                dropdownColor: enabled
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.cardDark
                        : AppColors.cardLight)
                    : null,
                onChanged: onChanged,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ),
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
      indent: AppTheme.spacingMd,
      endIndent: AppTheme.spacingMd,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  /// 构建状态提示卡片
  Widget _buildStatusCard({required bool isDark}) {
    final isSuccess = _connectionStatus == '连接成功';
    final statusColor = isSuccess ? AppColors.success : AppColors.error;
    final statusIcon = isSuccess ? Icons.check_circle : Icons.error;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSuccess ? '连接成功' : '连接失败',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _connectionStatus!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部保存按钮
  Widget _buildSaveButton({required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              '保存设置',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  /// 测试连接
  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
    });

    // 模拟连接测试
    await Future<void>.delayed(const Duration(seconds: 2));

    setState(() {
      _isTestingConnection = false;
      // 模拟随机结果
      _connectionStatus = DateTime.now().millisecond % 2 == 0
          ? '连接成功'
          : '无法连接到服务器，请检查网络或API配置';
    });
  }

  /// 保存设置
  void _saveSettings() {
    // TODO: 实现保存逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置已保存'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
