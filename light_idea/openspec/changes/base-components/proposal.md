# 基础组件库创建提案

## Context

为 Light Idea 应用创建一套完整的基础 UI 组件库，用于构建灵感记录应用的用户界面。这些组件需要支持深色/浅色主题切换，使用 Material 3 设计语言，并遵循已定义的 AppColors 和 AppTheme 规范。

## Scope

### 涉及文件

1. `lib/presentation/widgets/common/app_bar.dart` - 导航栏组件
2. `lib/presentation/widgets/common/bottom_input_bar.dart` - 底部输入栏
3. `lib/presentation/widgets/common/inspiration_card.dart` - 灵感卡片
4. `lib/presentation/widgets/common/category_tabs.dart` - 分类 Tab 栏
5. `lib/presentation/widgets/common/search_bar.dart` - 搜索栏
6. `lib/presentation/widgets/common/side_drawer.dart` - 侧边抽屉
7. `lib/presentation/widgets/common/loading_shimmer.dart` - 加载占位效果

### 依赖文件

- `lib/core/theme/app_colors.dart` - 颜色定义
- `lib/core/theme/app_theme.dart` - 主题配置
- `pubspec.yaml` - 需要添加 material_symbols_icons 依赖

## Behavior

### 1. StickyTopNav (首页顶部导航栏)

**Props:**
- `VoidCallback? onMenuTap` - 菜单按钮点击回调
- `VoidCallback? onAICenterTap` - AI 中心点击回调
- `VoidCallback? onAddTap` - 添加按钮点击回调
- `String title` - 标题文本，默认 "Light Idea"

**视觉规范:**
- 背景色：AppColors.primaryDark (浅色主题) / AppColors.backgroundDark (深色主题)
- 高度：56dp
- 左侧：菜单图标按钮 (MaterialSymbolsOutlined.menu)
- 中间：应用标题
- 右侧：AI 中心图标 + 添加图标按钮

### 2. DetailAppBar (详情页导航栏)

**Props:**
- `VoidCallback? onBackTap` - 返回按钮点击回调
- `VoidCallback? onMoreTap` - 更多操作点击回调
- `String title` - 标题文本
- `List<Widget>? actions` - 自定义操作按钮列表

**视觉规范:**
- 背景色跟随主题
- 左侧：返回箭头图标
- 中间：页面标题
- 右侧：可选操作按钮

### 3. BottomInputBar (底部输入区)

**Props:**
- `VoidCallback? onImageTap` - 图片按钮点击
- `VoidCallback? onVoiceTap` - 语音按钮点击
- `ValueChanged<String>? onSend` - 发送回调
- `TextEditingController? controller` - 输入控制器
- `String? hintText` - 提示文本

**视觉规范:**
- 高度：约 64dp
- 背景色：卡片背景色
- 左侧：图片图标 + 语音图标
- 中间：圆角输入框
- 右侧：发送按钮

### 4. InspirationCard (灵感卡片)

**Props:**
- `String content` - 内容文本
- `String category` - 分类标签
- `DateTime timestamp` - 时间戳
- `String? imageUrl` - 可选图片 URL
- `VoidCallback? onTap` - 点击回调
- `VoidCallback? onLongPress` - 长按回调

**视觉规范:**
- 圆角：AppTheme.radiusMedium (12dp)
- 背景色：卡片背景色
- 顶部：分类标签 (Chip) + 时间戳
- 中部：内容文本
- 底部：可选图片

### 5. CategoryTabs (分类 Tab 栏)

**Props:**
- `List<String> categories` - 分类列表
- `int selectedIndex` - 当前选中索引
- `ValueChanged<int>? onCategorySelected` - 选择回调

**视觉规范:**
- 横向滚动的 Tab 栏
- 选中状态：主色背景 + 深色文字
- 未选中：透明背景 + 次要文字色
- Tab 项：时间轴、社交/旅行、工作/创意、摄影

### 6. SearchInputBar (搜索栏)

**Props:**
- `TextEditingController? controller`
- `ValueChanged<String>? onChanged`
- `ValueChanged<String>? onSubmitted`
- `VoidCallback? onClear`
- `String? hintText`

**视觉规范:**
- 圆角搜索框
- 左侧搜索图标
- 右侧清除按钮 (有内容时显示)
- 背景色：输入框背景色

### 7. SideDrawer (侧边栏抽屉)

**Props:**
- `String userName` - 用户名
- `String? userAvatar` - 用户头像 URL
- `List<DrawerItem> items` - 菜单项列表
- `VoidCallback? onSettingsTap` - 设置点击
- `VoidCallback? onLogoutTap` - 退出登录点击

**视觉规范:**
- 宽度：屏幕宽度的 70-80%
- 顶部：用户信息区
- 中部：菜单列表
- 底部：设置和退出

### 8. LoadingShimmer (加载占位效果)

**Props:**
- `double width` - 宽度
- `double height` - 高度
- `ShapeBorder? shape` - 形状

**视觉规范:**
- 渐变 shimmer 效果
- 支持卡片、列表项、文本行等多种形状

## Risks

1. **依赖风险**: 需要添加 material_symbols_icons 包，可能影响构建
2. **主题一致性**: 需要确保所有组件在深色/浅色主题下表现一致
3. **性能风险**: Shimmer 效果需要合理控制避免过度绘制
4. **可访问性**: 需要确保足够的对比度和触摸目标大小

## 验收标准

- [ ] 所有组件支持深色/浅色主题
- [ ] 使用 MaterialSymbolsOutlined 图标
- [ ] 组件参数可配置
- [ ] 代码通过 Dart 分析器检查
- [ ] 组件可在预览中正常显示
