import 'package:flutter/material.dart';

/// 应用颜色常量定义
/// 
/// 包含主色调、深色主题、背景色和强调色等所有颜色规范
class AppColors {
  AppColors._();

  // ==================== 主色调 ====================
  
  /// 主色 - 清新绿色
  /// 用于：按钮、激活状态、主要操作
  static const Color primary = Color(0xFF6EE7B7);
  
  /// 主色深色 - 深绿色
  /// 用于：AppBar、强调元素、深色主题的主要颜色
  static const Color primaryDark = Color(0xFF065F46);
  
  /// 主色浅色 - 浅绿色
  static const Color primaryLight = Color(0xFFA7F3D0);
  
  // ==================== 背景色 ====================
  
  /// 浅色背景 - 极淡绿色
  /// 用于：浅色主题背景
  static const Color backgroundLight = Color(0xFFF0FDF4);
  
  /// 深色背景 - 深墨绿色
  /// 用于：深色主题背景
  static const Color backgroundDark = Color(0xFF022c22);
  
  /// 卡片浅色背景
  static const Color cardLight = Color(0xFFFFFFFF);
  
  /// 卡片深色背景
  static const Color cardDark = Color(0xFF064E3B);
  
  // ==================== 强调色 ====================
  
  /// 强调色 - 淡蓝色
  /// 用于：高亮、提示、次要强调
  static const Color accent = Color(0xFFBAE6FD);
  
  /// 强调色深色
  static const Color accentDark = Color(0xFF0369A1);
  
  // ==================== 文字颜色 ====================
  
  /// 浅色主题主要文字颜色
  static const Color textPrimaryLight = Color(0xFF1F2937);
  
  /// 浅色主题次要文字颜色
  static const Color textSecondaryLight = Color(0xFF6B7280);
  
  /// 深色主题主要文字颜色
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  
  /// 深色主题次要文字颜色
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  
  /// 禁用状态文字颜色
  static const Color textDisabled = Color(0xFF9CA3AF);
  
  // ==================== 功能色 ====================
  
  /// 成功色
  static const Color success = Color(0xFF10B981);
  
  /// 警告色
  static const Color warning = Color(0xFFF59E0B);
  
  /// 错误色
  static const Color error = Color(0xFFEF4444);
  
  /// 信息色
  static const Color info = Color(0xFF3B82F6);
  
  // ==================== 边框和分割线 ====================
  
  /// 浅色边框
  static const Color borderLight = Color(0xFFE5E7EB);
  
  /// 深色边框
  static const Color borderDark = Color(0xFF374151);
  
  /// 分割线颜色
  static const Color divider = Color(0xFFE5E7EB);
  
  // ==================== Material Color Swatch ====================
  
  /// 主色 Material Swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF6EE7B7,
    <int, Color>{
      50: Color(0xFFECFDF5),
      100: Color(0xFFD1FAE5),
      200: Color(0xFFA7F3D0),
      300: Color(0xFF6EE7B7),
      400: Color(0xFF34D399),
      500: Color(0xFF10B981),
      600: Color(0xFF059669),
      700: Color(0xFF047857),
      800: Color(0xFF065F46),
      900: Color(0xFF064E3B),
    },
  );
  
  /// 强调色 Material Swatch
  static const MaterialColor accentSwatch = MaterialColor(
    0xFFBAE6FD,
    <int, Color>{
      50: Color(0xFFF0F9FF),
      100: Color(0xFFE0F2FE),
      200: Color(0xFFBAE6FD),
      300: Color(0xFF7DD3FC),
      400: Color(0xFF38BDF8),
      500: Color(0xFF0EA5E9),
      600: Color(0xFF0284C7),
      700: Color(0xFF0369A1),
      800: Color(0xFF075985),
      900: Color(0xFF0C4A6E),
    },
  );
}
