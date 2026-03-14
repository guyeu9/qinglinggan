import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../application/providers/app_providers.dart';
import '../../../../application/providers/ai_chat_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/entities/idea.dart';

/// AI灵感中心页面
///
/// 严格按照原型图实现:
/// d:\trae\qinglinggan\前端原型图\7 ai灵感中心\code.html
///
/// 颜色定义:
/// - primary: #6EE7B7
/// - primary-dark: #065F46
/// - background-light: #F0FDF4
/// - secondary-accent: #BAE6FD
class AIHubPage extends ConsumerStatefulWidget {
  const AIHubPage({super.key});

  @override
  ConsumerState<AIHubPage> createState() => _AIHubPageState();
}

class _AIHubPageState extends ConsumerState<AIHubPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goBack() {
    context.pop();
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      ref.read(aiChatProvider.notifier).sendMessage(text);
      _inputController.clear();
      HapticFeedback.mediumImpact();
      _scrollToBottom();
    }
  }

  void _handleQuickPrompt(String prompt) {
    if (prompt.contains('总结') || prompt.contains('分析')) {
      ref.read(aiChatProvider.notifier).reviewHistory(days: 15);
    } else if (prompt.contains('搜索') || prompt.contains('相关')) {
      ref.read(aiChatProvider.notifier).searchIdeas('最近的灵感');
    } else {
      ref.read(aiChatProvider.notifier).sendMessage(prompt);
    }
    HapticFeedback.mediumImpact();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatState = ref.watch(aiChatProvider);

    // 严格使用原型图颜色
    final backgroundColor = isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4);
    final textColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark, textColor),

            // Content
            Expanded(
              child: chatState.messages.isEmpty
                  ? _buildEmptyState(isDark, textColor)
                  : _buildMessageList(chatState, isDark),
            ),

            // Quick Prompts
            _buildQuickPrompts(isDark, textColor),

            // Input Area
            _buildInputArea(isDark, textColor),
          ],
        ),
      ),
    );
  }

  /// Header
  ///
  /// 原型图代码:
  /// ```html
  /// <header class="sticky top-0 z-50 bg-background-light/80 backdrop-blur-md border-b border-primary/20">
  ///   <div class="flex items-center p-4 justify-between max-w-2xl mx-auto w-full">
  ///     <div class="text-primary-dark flex size-10 shrink-0 items-center justify-center rounded-full hover:bg-primary/20 cursor-pointer transition-all">
  ///       <span class="material-symbols-outlined">arrow_back</span>
  ///     </div>
  ///     <h2 class="text-primary-dark text-lg font-bold leading-tight tracking-tight flex-1 text-center">AI 灵感中心</h2>
  ///     <div class="flex size-10 items-center justify-end">
  ///       <button class="flex items-center justify-center rounded-full size-10 bg-primary/20 text-primary-dark hover:bg-primary/40 transition-all">
  ///         <span class="material-symbols-outlined">auto_awesome</span>
  ///       </button>
  ///     </div>
  ///   </div>
  /// </header>
  /// ```
  Widget _buildHeader(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF022c22).withValues(alpha: 0.8)
            : const Color(0xFFF0FDF4).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
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
                  color: textColor,
                  size: 24,
                ),
              ),
            ),
          ),

          // 标题
          Expanded(
            child: Text(
              'AI 灵感中心',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // AI图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Symbols.auto_awesome,
              color: textColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6EE7B7).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Symbols.smart_toy,
              color: textColor.withValues(alpha: 0.5),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '开始与AI助手对话',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '我可以帮你分析、总结和搜索灵感',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 消息列表
  Widget _buildMessageList(AIChatState chatState, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: message.isUser
              ? _buildUserMessage(message, isDark)
              : _buildAIMessage(message, isDark),
        );
      },
    );
  }

  /// 用户消息
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="flex items-start gap-3 justify-end pl-12 animate-fade-in opacity-0 animate-delay-1">
  ///   <div class="flex flex-col gap-1 items-end">
  ///     <p class="text-primary-dark/50 text-[11px] font-medium uppercase tracking-wider px-1">用户</p>
  ///     <div class="rounded-2xl rounded-tr-none px-4 py-3 bg-primary text-primary-dark shadow-sm">
  ///       <p class="text-sm font-normal leading-relaxed">帮我分析下最近关于"霓虹赛博"审美摄影的想法。</p>
  ///     </div>
  ///   </div>
  ///   <div class="bg-primary/20 rounded-full w-8 h-8 flex items-center justify-center shrink-0">
  ///     <span class="material-symbols-outlined text-primary-dark text-sm">person</span>
  ///   </div>
  /// </div>
  /// ```
  Widget _buildUserMessage(ChatMessage message, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 消息内容
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 标签
              Text(
                '用户',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF065F46).withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              // 消息气泡
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE7B7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 用户头像
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Symbols.person,
            color: Color(0xFF065F46),
            size: 18,
          ),
        ),
      ],
    );
  }

  /// AI消息
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="flex items-start gap-3 pr-12 animate-fade-in opacity-0 animate-delay-2">
  ///   <div class="bg-primary-dark rounded-full w-8 h-8 flex items-center justify-center shrink-0 shadow-lg shadow-primary-dark/20">
  ///     <span class="material-symbols-outlined text-white text-sm">smart_toy</span>
  ///   </div>
  ///   <div class="flex flex-col gap-3 items-start w-full">
  ///     <p class="text-primary-dark/50 text-[11px] font-medium uppercase tracking-wider px-1">AI 助手</p>
  ///     <div class="rounded-2xl rounded-tl-none px-4 py-3 bg-secondary-accent/10 border border-secondary-accent/30 shadow-sm w-full">
  ///       ...
  ///     </div>
  ///   </div>
  /// </div>
  /// ```
  Widget _buildAIMessage(ChatMessage message, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI头像
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF065F46),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF065F46).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Symbols.smart_toy,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        // 消息内容
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标签
              Text(
                'AI 助手',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF065F46).withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              // 消息气泡
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBAE6FD).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: const Color(0xFFBAE6FD).withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                  ),
                ),
              ),
              // 引用的灵感卡片
              if (message.referencedIdeas != null && message.referencedIdeas!.isNotEmpty)
                ...message.referencedIdeas!.take(2).map((IdeaEntity idea) => _buildReferencedIdeaCard(idea, isDark)),
            ],
          ),
        ),
      ],
    );
  }

  /// 引用的灵感卡片
  Widget _buildReferencedIdeaCard(IdeaEntity idea, bool isDark) {
    return GestureDetector(
      onTap: () => context.pushToIdeaDetail(idea.id.toString()),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                idea.content,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark
                      ? const Color(0xFF6EE7B7).withValues(alpha: 0.8)
                      : const Color(0xFF065F46).withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Symbols.chevron_right,
              color: isDark
                  ? const Color(0xFF6EE7B7).withValues(alpha: 0.4)
                  : const Color(0xFF065F46).withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 快捷提示
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="flex gap-2 overflow-x-auto pb-3 px-4 no-scrollbar -mx-4 pt-4">
  ///   <button class="whitespace-nowrap rounded-full px-4 py-1.5 border border-primary/30 bg-white text-xs font-medium text-primary-dark hover:bg-primary/20 hover:border-primary transition-all">分析最近半个月的想法</button>
  ///   ...
  /// </div>
  /// ```
  Widget _buildQuickPrompts(bool isDark, Color textColor) {
    final prompts = [
      '分析最近半个月的想法',
      '找出与摄影相关的灵感',
      '总结我的工作创意',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: prompts.map((prompt) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleQuickPrompt(prompt),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.3) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor,
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

  /// 输入区域
  ///
  /// 原型图代码:
  /// ```html
  /// <div class="max-w-2xl mx-auto px-4 pt-2 pb-2">
  ///   <div class="relative flex items-center">
  ///     <input class="w-full bg-white border border-primary/30 rounded-full py-3 pl-5 pr-12 text-sm focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all text-primary-dark placeholder:text-primary-dark/40" placeholder="向 AI 提问你的灵感..." type="text"/>
  ///     <button class="absolute right-2 p-1.5 bg-primary-dark text-white rounded-full hover:brightness-125 active:scale-90 transition-all">
  ///       <span class="material-symbols-outlined text-xl">send</span>
  ///     </button>
  ///   </div>
  /// </div>
  /// ```
  Widget _buildInputArea(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF022c22) : const Color(0xFFF0FDF4),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF065F46).withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF6EE7B7).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: '向 AI 提问你的灵感...',
                        hintStyle: TextStyle(
                          color: textColor.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: TextStyle(
                        color: textColor,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 发送按钮
          Material(
            color: const Color(0xFF065F46),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _handleSend,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Symbols.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
