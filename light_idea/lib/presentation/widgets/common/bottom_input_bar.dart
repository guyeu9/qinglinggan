import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// 底部输入栏组件
/// 
/// 固定在底部的输入区域，包含图片、语音按钮、输入框和发送按钮
class BottomInputBar extends StatefulWidget {
  /// 图片按钮点击回调
  final VoidCallback? onImageTap;
  
  /// 语音按钮点击回调
  final VoidCallback? onVoiceTap;
  
  /// 发送回调
  final ValueChanged<String>? onSend;
  
  /// 输入控制器
  final TextEditingController? controller;
  
  /// 提示文本
  final String? hintText;
  
  /// 是否启用输入
  final bool enabled;
  
  /// 最大行数
  final int maxLines;
  
  /// 最小行数
  final int minLines;
  
  /// 是否显示图片按钮
  final bool showImageButton;
  
  /// 是否显示语音按钮
  final bool showVoiceButton;

  const BottomInputBar({
    super.key,
    this.onImageTap,
    this.onVoiceTap,
    this.onSend,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.maxLines = 4,
    this.minLines = 1,
    this.showImageButton = true,
    this.showVoiceButton = true,
  });

  @override
  State<BottomInputBar> createState() => _BottomInputBarState();
}

class _BottomInputBarState extends State<BottomInputBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(BottomInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.enabled) {
      widget.onSend?.call(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              if (widget.showImageButton)
                _ActionButton(
                  icon: Symbols.image,
                  onTap: widget.enabled ? widget.onImageTap : null,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              
              // 语音按钮
              if (widget.showVoiceButton)
                _ActionButton(
                  icon: Symbols.mic,
                  onTap: widget.enabled ? widget.onVoiceTap : null,
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
                    controller: _controller,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    minLines: widget.minLines,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? '记录你的灵感...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.textDisabled : AppColors.textDisabled,
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
                onTap: _hasText && widget.enabled ? _handleSend : null,
                isActive: _hasText && widget.enabled,
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
