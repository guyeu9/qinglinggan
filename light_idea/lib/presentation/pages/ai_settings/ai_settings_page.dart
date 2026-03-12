import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../config/ai_config.dart';
import '../../../../core/utils/sensitive_data_masker.dart';

class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  bool _analysisEnabled = true;
  final TextEditingController _apiUrlController = TextEditingController(
    text: 'https://api.openai.com/v1',
  );
  final TextEditingController _apiKeyController = TextEditingController();
  bool _apiKeyVisible = false;
  String _selectedModel = 'GPT-4o-mini';

  final TextEditingController _embeddingUrlController = TextEditingController(
    text: 'https://api.openai.com/v1/embeddings',
  );
  final TextEditingController _vectorApiKeyController = TextEditingController();
  bool _vectorApiKeyVisible = false;
  final TextEditingController _vectorDimensionController =
      TextEditingController(text: '1536');

  bool _isTestingConnection = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _connectionStatus;

  String? _maskedApiKey;

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
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _embeddingUrlController.dispose();
    _vectorApiKeyController.dispose();
    _vectorDimensionController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final hasKey = await AIConfig.hasApiKey();
      if (hasKey) {
        final key = await AIConfig.getApiKey();
        _maskedApiKey = SensitiveDataMasker.maskApiKey(key);
      }
    } catch (_) {
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.isEmpty) {
      setState(() {
        _connectionStatus = '请先输入API密钥';
      });
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
    });

    try {
      await AIConfig.setApiKey(_apiKeyController.text);
      final hasKey = await AIConfig.hasApiKey();
      
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = hasKey ? '连接成功' : '密钥保存失败';
        if (hasKey) {
          _maskedApiKey = SensitiveDataMasker.maskApiKey(_apiKeyController.text);
        }
      });
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = '连接失败: $e';
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_apiKeyController.text.isEmpty && _maskedApiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入API密钥')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_apiKeyController.text.isNotEmpty) {
        await AIConfig.setApiKey(_apiKeyController.text);
        _maskedApiKey = SensitiveDataMasker.maskApiKey(_apiKeyController.text);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置已保存')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _clearApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除密钥'),
        content: const Text('确定要清除已保存的API密钥吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AIConfig.clearApiKey();
      setState(() {
        _maskedApiKey = null;
        _apiKeyController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API密钥已清除')),
        );
      }
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('分析API设置', textSecondary),
                          _buildSettingsCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
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
                              _buildApiKeyField(
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                isDark: isDark,
                              ),
                              _buildDivider(isDark),
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

                          _buildSectionTitle('向量API设置', textSecondary),
                          _buildSettingsCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            children: [
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
                              _buildTextFieldTile(
                                label: '嵌入接口地址',
                                hint: '请输入嵌入接口地址',
                                controller: _embeddingUrlController,
                                icon: Icons.integration_instructions,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                              _buildDivider(isDark),
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

                          if (_connectionStatus != null)
                            _buildStatusCard(isDark: isDark),

                          const SizedBox(height: AppTheme.spacingXl),
                        ],
                      ),
                    ),
                  ),
                  _buildSaveButton(isDark: isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildApiKeyField({
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'API密钥',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _analysisEnabled ? textPrimary : textSecondary,
                ),
              ),
              if (_maskedApiKey != null)
                TextButton.icon(
                  onPressed: _clearApiKey,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('清除', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          if (_maskedApiKey != null && _apiKeyController.text.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: textSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.key, color: textSecondary, size: 20),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      _maskedApiKey!,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _maskedApiKey = null;
                      });
                    },
                    child: const Text('修改'),
                  ),
                ],
              ),
            )
          else
            TextField(
              controller: _apiKeyController,
              obscureText: !_apiKeyVisible,
              enabled: _analysisEnabled,
              style: TextStyle(
                color: _analysisEnabled ? textPrimary : textSecondary,
              ),
              decoration: InputDecoration(
                hintText: '请输入API密钥 (sk-...)',
                hintStyle: TextStyle(
                  color: textSecondary.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.key,
                  color: _analysisEnabled
                      ? textSecondary
                      : textSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _apiKeyVisible ? Icons.visibility_off : Icons.visibility,
                    color: _analysisEnabled
                        ? textSecondary
                        : textSecondary.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: _analysisEnabled
                      ? () => setState(() => _apiKeyVisible = !_apiKeyVisible)
                      : null,
                ),
                filled: true,
                fillColor: _analysisEnabled
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

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: AppTheme.spacingMd,
      endIndent: AppTheme.spacingMd,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

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
            child: Text(
              _connectionStatus!,
              style: TextStyle(
                fontSize: 14,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              _isSaving ? '保存中...' : '保存设置',
              style: const TextStyle(
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
}
