import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:light_idea/core/theme/app_colors.dart';
import 'package:light_idea/core/theme/app_theme.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// AI灵感中心页面
///
/// 原型图: 7 AI灵感中心
/// 功能: AI对话、灵感总结、智能分析
class AIHubPage extends StatefulWidget {
  const AIHubPage({super.key});

  @override
  State<AIHubPage> createState() => _AIHubPageState();
}

class _AIHubPageState extends State<AIHubPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  // 模拟对话消息数据
  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'ai',
      'content': '你好！我是你的AI灵感助手。基于你近15天的记录，我发现你在"工作/创意"分类下有较多关于UI设计的想法。需要我帮你整理一下吗？',
      'time': '10:30 AM',
      'referencedIdea': {
        'category': '工作/创意',
        'content': '尝试用极简主义风格重新设计个人主页，采用大量留白和柔和的绿色调，让内容本身成为焦点。',
      },
    },
    {
      'type': 'user',
      'content': '是的，请帮我总结一下最近的创意灵感',
      'time': '10:31 AM',
    },
    {
      'type': 'ai',
      'content': '根据你的记录，最近15天你有以下创意趋势：\n\n1. 极简主义设计风格（出现3次）\n2. 自然元素与科技结合（出现2次）\n3. 交互体验优化（出现4次）\n\n建议你可以尝试将这些方向整合到一个项目中。',
      'time': '10:32 AM',
    },
  ];

  // 快捷提示标签
  final List<String> _quickPrompts = [
    '总结最近的工作灵感',
    '帮我分析创意趋势',
    '生成项目大纲',
    '寻找灵感关联',
  ];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _inputController.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({
          'type': 'user',
          'content': text,
          'time': _getCurrentTime(),
        });
      });
      _inputController.clear();
      HapticFeedback.mediumImpact();
      _scrollToBottom();

      // 模拟AI回复
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'type': 'ai',
              'content': '收到你的问题，我正在分析你的灵感记录...',
              'time': _getCurrentTime(),
            });
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _handleQuickPrompt(String prompt) {
    setState(() {
      _messages.add({
        'type': 'user',
        'content': prompt,
        'time': _getCurrentTime(),
      });
    });
    HapticFeedback.mediumImpact();
    _scrollToBottom();

    // 模拟AI回复
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'type': 'ai',
            'content': '我来帮你$prompt。根据你的记录分析...',
            'time': _getCurrentTime(),
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(isDark),

            // 总结报告卡片
            _buildSummaryCard(isDark),

            // 对话消息区
            Expanded(
              child: _buildMessageList(isDark),
            ),

            // 快捷提示标签
            _buildQuickPrompts(isDark),

            // 底部输入区
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  Widget _buildAppBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.primaryDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
            child: Row(
              children: [
                // 返回按钮
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Icon(
                        Symbols.arrow_back,
                        color: isDark ? AppColors.textPrimaryDark : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppTheme.spacingSm),

                // 标题
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.smart_toy,
                        color: isDark ? AppColors.primary : Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI灵感中心',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建总结报告卡片
  Widget _buildSummaryCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primaryDark.withValues(alpha: 0.8),
                  AppColors.cardDark.withValues(alpha: 0.9),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.accent.withValues(alpha: 0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.auto_awesome,
                color: isDark ? AppColors.primary : AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '近15天灵感总结',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                ),
                child: Text(
                  '12条记录',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            '你在"工作/创意"分类下记录了8条灵感，主要围绕UI设计和用户体验优化。其中极简主义风格被多次提及，建议可以整理成设计规范文档。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              _buildTag('工作/创意', AppColors.info, isDark),
              const SizedBox(width: 8),
              _buildTag('极简主义', AppColors.success, isDark),
              const SizedBox(width: 8),
              _buildTag('UI设计', AppColors.warning, isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建标签
  Widget _buildTag(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建消息列表
  Widget _buildMessageList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['type'] == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: isUser
              ? _buildUserMessage(message, isDark)
              : _buildAIMessage(message, isDark),
        );
      },
    );
  }

  /// 构建用户消息气泡
  Widget _buildUserMessage(Map<String, dynamic> message, bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm + 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['content'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['time'] as String,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primaryDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建AI消息气泡
  Widget _buildAIMessage(Map<String, dynamic> message, bool isDark) {
    final referencedIdea = message['referencedIdea'] as Map<String, dynamic>?;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI头像
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                Symbols.smart_toy,
                color: isDark ? AppColors.primary : AppColors.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm + 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['time'] as String,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 引用灵感卡片
                  if (referencedIdea != null) ...[
                    const SizedBox(height: 8),
                    _buildReferencedIdeaCard(referencedIdea, isDark),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建引用的灵感卡片
  Widget _buildReferencedIdeaCard(Map<String, dynamic> idea, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm + 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: isDark ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            ),
            child: Text(
              idea['category'] as String,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            idea['content'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 构建快捷提示标签
  Widget _buildQuickPrompts(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _quickPrompts.map((prompt) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleQuickPrompt(prompt),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark.withValues(alpha: 0.8)
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      prompt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建底部输入栏
  Widget _buildInputBar(bool isDark) {
    final backgroundColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: AppTheme.spacingSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 图片按钮
              _ActionButton(
                icon: Symbols.image,
                onTap: () {
                  // TODO: 选择图片
                },
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),

              // 语音按钮
              _ActionButton(
                icon: Symbols.mic,
                onTap: () {
                  // TODO: 语音输入
                },
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),

              const SizedBox(width: AppTheme.spacingSm),

              // 输入框
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _inputController,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: '向AI助手提问...',
                      hintStyle: TextStyle(
                        color: AppColors.textDisabled,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm + 4,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppTheme.spacingSm),

              // 发送按钮
              _SendButton(
                onTap: _hasText ? _handleSend : null,
                isActive: _hasText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 操作按钮组件
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onTap != null ? color : color.withValues(alpha: 0.3),
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// 发送按钮组件
class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;

  const _SendButton({
    this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isActive
          ? AppColors.primary
          : (isDark ? AppColors.borderDark : AppColors.borderLight),
      borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            Symbols.send,
            color: isActive
                ? AppColors.primaryDark
                : (isDark ? AppColors.textSecondaryDark : AppColors.textDisabled),
            size: 22,
          ),
        ),
      ),
    );
  }
}
