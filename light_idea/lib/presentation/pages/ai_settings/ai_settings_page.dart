import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// AI模型管理页面
///
/// 严格按照原型图实现:
/// d:\trae\qinglinggan\前端原型图\8侧边栏-ai管理详情页\code.html
///
/// 功能特性:
/// - 标签栏切换: [对话服务] [Embedding服务]
/// - 多服务商支持
/// - 服务商卡片: 名称、类型、模型、API Key脱敏
/// - 设置默认服务商
/// - 快速模板: DeepSeek、通义千问、Claude、Gemini、OpenAI
/// - 云端加载模型
/// - 浮动添加按钮
class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  int _currentTab = 0; // 0: 对话服务, 1: Embedding服务
  List<AIProvider> _providers = [];
  AIProvider? _editingProvider;
  bool _showModal = false;
  bool _showDeleteModal = false;
  String? _deleteTargetId;

  final _nameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelNameController = TextEditingController();
  String _apiType = 'openai-compatible';
  bool _apiKeyVisible = false;
  List<String> _availableModels = [];
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  void _loadProviders() {
    setState(() {
      _providers = [
        AIProvider(
          id: '1',
          name: '免费grok',
          type: 'OPENAI',
          apiType: 'openai-compatible',
          baseUrl: 'https://api.x.ai/v1',
          apiKey: 'sk-xxxxCGrV',
          model: 'grok-4.20-beta',
          isDefault: false,
          serviceType: 'chat',
        ),
        AIProvider(
          id: '2',
          name: '默认',
          type: 'OPENAI',
          apiType: 'openai-compatible',
          baseUrl: 'https://api.openai.com/v1',
          apiKey: 'sk-xxxxp5oj',
          model: 'gemini-3.1-flash-lite',
          isDefault: true,
          serviceType: 'chat',
        ),
      ];
    });
  }

  List<AIProvider> get _filteredProviders {
    return _providers.where((p) => p.serviceType == (_currentTab == 0 ? 'chat' : 'embedding')).toList();
  }

  void _switchTab(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  void _openModal([AIProvider? provider]) {
    setState(() {
      _editingProvider = provider;
      if (provider != null) {
        _nameController.text = provider.name;
        _apiType = provider.apiType;
        _baseUrlController.text = provider.baseUrl;
        _apiKeyController.text = provider.apiKey;
        _modelNameController.text = provider.model;
      } else {
        _nameController.clear();
        _apiType = 'openai-compatible';
        _baseUrlController.clear();
        _apiKeyController.clear();
        _modelNameController.clear();
      }
      _availableModels = [];
      _showModal = true;
    });
  }

  void _closeModal() {
    setState(() {
      _showModal = false;
      _editingProvider = null;
    });
  }

  void _applyTemplate(String templateKey) {
    final templates = {
      'deepseek': {
        'name': 'DeepSeek',
        'apiType': 'openai-compatible',
        'baseUrl': 'https://api.deepseek.com/v1',
        'model': 'deepseek-chat',
      },
      'qwen': {
        'name': '通义千问',
        'apiType': 'openai-compatible',
        'baseUrl': 'https://dashscope.aliyuncs.com/compatible-mode/v1',
        'model': 'qwen-turbo',
      },
      'claude': {
        'name': 'Claude',
        'apiType': 'anthropic',
        'baseUrl': 'https://api.anthropic.com/v1',
        'model': 'claude-3-sonnet-20240229',
      },
      'gemini': {
        'name': 'Gemini',
        'apiType': 'google',
        'baseUrl': 'https://generativelanguage.googleapis.com/v1beta',
        'model': 'gemini-pro',
      },
      'openai': {
        'name': 'OpenAI',
        'apiType': 'openai-compatible',
        'baseUrl': 'https://api.openai.com/v1',
        'model': 'gpt-4o',
      },
    };

    final template = templates[templateKey];
    if (template != null) {
      setState(() {
        _nameController.text = template['name'] as String;
        _apiType = template['apiType'] as String;
        _baseUrlController.text = template['baseUrl'] as String;
        _modelNameController.text = template['model'] as String;
      });
    }
  }

  Future<void> _loadModels() async {
    if (_baseUrlController.text.isEmpty || _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写 Base URL 和 API Key')),
      );
      return;
    }

    setState(() {
      _isLoadingModels = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _availableModels = [
        'gpt-4o',
        'gpt-4-turbo',
        'gpt-3.5-turbo',
        'claude-3-opus',
        'claude-3-sonnet',
        'deepseek-chat',
        'deepseek-coder',
      ];
      _isLoadingModels = false;
    });
  }

  void _saveProvider() {
    if (_nameController.text.isEmpty ||
        _baseUrlController.text.isEmpty ||
        _apiKeyController.text.isEmpty ||
        _modelNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填项')),
      );
      return;
    }

    final typeMap = {
      'openai-compatible': 'OPENAI',
      'anthropic': 'ANTHROPIC',
      'google': 'GOOGLE',
      'azure': 'AZURE',
    };

    if (_editingProvider != null) {
      setState(() {
        final index = _providers.indexWhere((p) => p.id == _editingProvider!.id);
        if (index != -1) {
          _providers[index] = AIProvider(
            id: _editingProvider!.id,
            name: _nameController.text,
            type: typeMap[_apiType] ?? 'OPENAI',
            apiType: _apiType,
            baseUrl: _baseUrlController.text,
            apiKey: _apiKeyController.text,
            model: _modelNameController.text,
            isDefault: _editingProvider!.isDefault,
            serviceType: _editingProvider!.serviceType,
          );
        }
      });
    } else {
      final newProvider = AIProvider(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: typeMap[_apiType] ?? 'OPENAI',
        apiType: _apiType,
        baseUrl: _baseUrlController.text,
        apiKey: _apiKeyController.text,
        model: _modelNameController.text,
        isDefault: _filteredProviders.isEmpty,
        serviceType: _currentTab == 0 ? 'chat' : 'embedding',
      );
      setState(() {
        _providers.add(newProvider);
      });
    }

    _closeModal();
  }

  void _setDefault(String id) {
    setState(() {
      for (var i = 0; i < _providers.length; i++) {
        if (_providers[i].serviceType == (_currentTab == 0 ? 'chat' : 'embedding')) {
          _providers[i] = _providers[i].copyWith(isDefault: _providers[i].id == id);
        }
      }
    });
  }

  void _showDeleteConfirmation(String id) {
    setState(() {
      _deleteTargetId = id;
      _showDeleteModal = true;
    });
  }

  void _closeDeleteModal() {
    setState(() {
      _showDeleteModal = false;
      _deleteTargetId = null;
    });
  }

  void _confirmDelete() {
    if (_deleteTargetId != null) {
      setState(() {
        _providers.removeWhere((p) => p.id == _deleteTargetId);
      });
    }
    _closeDeleteModal();
  }

  String _maskApiKey(String key) {
    if (key.length < 8) return key;
    return '${key.substring(0, 5)}****${key.substring(key.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF122017) : const Color(0xFFF0FDF4);
    final cardColor = Colors.white;
    final textColor = const Color(0xFF065F46);
    final mutedTextColor = const Color(0xFF065F46).withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark, textColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTabSwitcher(isDark, textColor),
                        const SizedBox(height: 24),
                        _buildProviderList(cardColor, textColor, mutedTextColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildFloatingButton(textColor),
          if (_showModal) _buildModalOverlay(),
          if (_showModal) _buildProviderModal(cardColor, textColor, mutedTextColor),
          if (_showDeleteModal) _buildDeleteModal(cardColor, textColor),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF122017) : Colors.white,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(Symbols.arrow_back, color: textColor, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'AI 模型管理',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(Symbols.help_outline, color: textColor, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('对话服务', 0, textColor),
          ),
          Expanded(
            child: _buildTabButton('Embedding 服务', 1, textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, Color textColor) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6EE7B7) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: isSelected ? textColor : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderList(Color cardColor, Color textColor, Color mutedTextColor) {
    final providers = _filteredProviders;

    if (providers.isEmpty) {
      return _buildEmptyState(textColor);
    }

    return Column(
      children: providers.map((provider) => _buildProviderCard(provider, cardColor, textColor, mutedTextColor)).toList(),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF6EE7B7).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Symbols.smart_toy, color: textColor, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          '暂无服务商配置',
          style: TextStyle(
            fontSize: 14,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '点击右下角按钮添加',
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(AIProvider provider, Color cardColor, Color textColor, Color mutedTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: provider.isDefault
            ? Border.all(color: const Color(0xFF6EE7B7), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _setDefault(provider.id),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: provider.isDefault ? const Color(0xFF6EE7B7) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: provider.isDefault ? const Color(0xFF6EE7B7) : null,
              ),
              child: provider.isDefault
                  ? const Center(
                      child: SizedBox(
                        width: 8,
                        height: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      provider.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        provider.type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.model,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _maskApiKey(provider.apiKey),
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _openModal(provider),
                icon: Icon(Symbols.edit, color: textColor.withValues(alpha: 0.4), size: 20),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(provider.id),
                icon: Icon(Symbols.delete_outline, color: Colors.red.withValues(alpha: 0.6), size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(Color textColor) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton.extended(
        onPressed: () => _openModal(),
        backgroundColor: const Color(0xFF6EE7B7),
        icon: Icon(Symbols.add, color: textColor),
        label: Text(
          '添加服务商',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildModalOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeModal,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildProviderModal(Color cardColor, Color textColor, Color mutedTextColor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModalHeader(textColor),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickTemplates(),
                    const SizedBox(height: 24),
                    _buildForm(textColor, mutedTextColor),
                  ],
                ),
              ),
            ),
            _buildSaveButton(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader(Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFF065F46).withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Text(
            _editingProvider != null ? '编辑对话服务商' : '添加对话服务商',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _closeModal,
            icon: Icon(Symbols.close, color: textColor.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速选择模板',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF065F46).withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTemplateButton('DeepSeek', Symbols.psychology, const Color(0xFF3B82F6), 'deepseek'),
              _buildTemplateButton('通义千问', Symbols.cloud, const Color(0xFF8B5CF6), 'qwen'),
              _buildTemplateButton('Claude', Symbols.emoji_objects, const Color(0xFFF97316), 'claude'),
              _buildTemplateButton('Gemini', Symbols.auto_awesome, const Color(0xFF6366F1), 'gemini'),
              _buildTemplateButton('OpenAI', Symbols.chat, const Color(0xFF22C55E), 'openai'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateButton(String label, IconData icon, Color iconColor, String templateKey) {
    return GestureDetector(
      onTap: () => _applyTemplate(templateKey),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Color textColor, Color mutedTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('服务商名称', _nameController, '例如：免费grok'),
        const SizedBox(height: 16),
        _buildDropdownField('API 类型'),
        const SizedBox(height: 16),
        _buildTextField('Base URL', _baseUrlController, 'https://api.openai.com/v1'),
        const SizedBox(height: 16),
        _buildPasswordField('API Key', _apiKeyController, 'sk-xxxxxxxxxxxxxxxx'),
        const SizedBox(height: 16),
        _buildModelField(textColor, mutedTextColor),
        if (_availableModels.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildModelDropdown(textColor),
        ],
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6EE7B7)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _apiType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'openai-compatible', child: Text('OpenAI 兼容')),
                DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                DropdownMenuItem(value: 'google', child: Text('Google AI')),
                DropdownMenuItem(value: 'azure', child: Text('Azure OpenAI')),
              ],
              onChanged: (value) {
                setState(() {
                  _apiType = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !_apiKeyVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6EE7B7)),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _apiKeyVisible = !_apiKeyVisible;
                });
              },
              icon: Icon(
                _apiKeyVisible ? Symbols.visibility_off : Symbols.visibility,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModelField(Color textColor, Color mutedTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '模型名称',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _modelNameController,
                decoration: InputDecoration(
                  hintText: '输入模型名称或点击加载',
                  hintStyle: TextStyle(color: const Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6EE7B7)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _isLoadingModels ? null : _loadModels,
              icon: _isLoadingModels
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Symbols.cloud_download, size: 18, color: textColor),
              label: Text(
                _isLoadingModels ? '加载中...' : '加载',
                style: TextStyle(color: textColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6EE7B7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '填写 Base URL 和 API Key 后点击加载获取可用模型',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildModelDropdown(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择模型',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: null,
              isExpanded: true,
              hint: const Text('请选择模型'),
              items: _availableModels.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _modelNameController.text = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFF065F46).withValues(alpha: 0.1)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveProvider,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EE7B7),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            '保存',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteModal(Color cardColor, Color textColor) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Symbols.delete_outline, color: Colors.red, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  '确认删除？',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '删除后将无法恢复，是否继续？',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _closeDeleteModal,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('删除', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AIProvider {
  final String id;
  final String name;
  final String type;
  final String apiType;
  final String baseUrl;
  final String apiKey;
  final String model;
  final bool isDefault;
  final String serviceType;

  AIProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.apiType,
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    required this.isDefault,
    required this.serviceType,
  });

  AIProvider copyWith({
    String? id,
    String? name,
    String? type,
    String? apiType,
    String? baseUrl,
    String? apiKey,
    String? model,
    bool? isDefault,
    String? serviceType,
  }) {
    return AIProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      apiType: apiType ?? this.apiType,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      isDefault: isDefault ?? this.isDefault,
      serviceType: serviceType ?? this.serviceType,
    );
  }
}
