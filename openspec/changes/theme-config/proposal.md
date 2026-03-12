# 主题配置文件创建提案

## Context

轻灵感应用需要一个完整的主题配置系统，以支持：
- 统一的视觉设计规范
- 浅色/深色模式切换
- Material 3 设计语言
- 一致的组件样式

## Scope

### 涉及文件
1. **新建** `lib/core/theme/app_colors.dart` - 颜色常量定义
2. **新建** `lib/core/theme/app_theme.dart` - 主题配置类
3. **修改** `pubspec.yaml` - 添加 google_fonts 依赖

### 颜色规范
| 颜色名称 | 色值 | 用途 |
|---------|------|------|
| primary | #6EE7B7 | 主色调，按钮、激活状态 |
| primaryDark | #065F46 | 深色主色，AppBar、强调 |
| backgroundLight | #F0FDF4 | 浅色背景 |
| backgroundDark | #022c22 | 深色背景 |
| accent | #BAE6FD | 强调色，高亮、提示 |

## Behavior

### AppColors 类
- 定义所有颜色常量为静态 Color 属性
- 支持 Material Color swatch

### AppTheme 类
- `lightTheme`: ThemeData 实例，使用 Material 3
- `darkTheme`: ThemeData 实例，使用 Material 3
- 字体：Public Sans (通过 Google Fonts)
- 组件主题配置：
  - AppBarTheme
  - CardTheme
  - InputDecorationTheme
  - ElevatedButtonTheme
  - TextButtonTheme
  - FloatingActionButtonTheme
  - ChipTheme

## Risks

1. **依赖风险**: 需要添加 google_fonts 包，可能增加包体积
2. **兼容性风险**: Material 3 在某些 Flutter 版本上可能需要适配
3. **性能风险**: 网络字体加载可能影响首次渲染

## 验证标准

1. 颜色值与规范完全一致
2. 浅色/深色主题都能正确渲染
3. 所有组件主题配置生效
4. 应用能正常编译运行
