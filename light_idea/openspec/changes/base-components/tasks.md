# 基础组件库开发任务分解

## 任务列表

### 任务 1: 创建目录结构
**描述**: 创建 presentation/widgets/common 目录结构
**验证方法**: 目录存在且可访问
**文件**: `lib/presentation/widgets/common/`

---

### 任务 2: 检查并添加依赖
**描述**: 检查 pubspec.yaml，确保 material_symbols_icons 依赖已添加
**验证方法**: `flutter pub get` 执行成功
**文件**: `pubspec.yaml`

---

### 任务 3: 实现 app_bar.dart
**描述**: 创建 StickyTopNav 和 DetailAppBar 组件
**组件规范**:
- StickyTopNav: 首页顶部导航，包含菜单、标题、AI中心、添加按钮
- DetailAppBar: 详情页导航，包含返回、标题、操作按钮
**验证方法**:
- 组件可在预览中显示
- 支持深色/浅色主题
- 所有回调函数正常工作
**文件**: `lib/presentation/widgets/common/app_bar.dart`

---

### 任务 4: 实现 bottom_input_bar.dart
**描述**: 创建 BottomInputBar 组件
**组件规范**:
- 左侧：图片、语音按钮
- 中间：输入框
- 右侧：发送按钮
**验证方法**:
- 输入框可正常输入
- 所有按钮点击回调正常
- 适配键盘弹出
**文件**: `lib/presentation/widgets/common/bottom_input_bar.dart`

---

### 任务 5: 实现 inspiration_card.dart
**描述**: 创建 InspirationCard 组件
**组件规范**:
- 分类标签 Chip
- 时间戳显示
- 内容文本
- 可选图片
**验证方法**:
- 卡片显示正常
- 图片加载和占位符正常
- 点击和长按回调正常
**文件**: `lib/presentation/widgets/common/inspiration_card.dart`

---

### 任务 6: 实现 category_tabs.dart
**描述**: 创建 CategoryTabs 组件
**组件规范**:
- 横向滚动 Tab 栏
- 选中/未选中状态样式
- 支持自定义分类列表
**验证方法**:
- Tab 切换正常
- 选中状态样式正确
- 滚动流畅
**文件**: `lib/presentation/widgets/common/category_tabs.dart`

---

### 任务 7: 实现 search_bar.dart
**描述**: 创建 SearchInputBar 组件
**组件规范**:
- 圆角搜索框
- 搜索图标
- 清除按钮（有内容时显示）
**验证方法**:
- 输入和清除功能正常
- 提交回调正常
- 样式符合主题
**文件**: `lib/presentation/widgets/common/search_bar.dart`

---

### 任务 8: 实现 side_drawer.dart
**描述**: 创建 SideDrawer 组件
**组件规范**:
- 用户信息头部
- 菜单项列表
- 底部设置和退出
**验证方法**:
- 抽屉可正常打开关闭
- 菜单项点击正常
- 用户信息显示正确
**文件**: `lib/presentation/widgets/common/side_drawer.dart`

---

### 任务 9: 实现 loading_shimmer.dart
**描述**: 创建 LoadingShimmer 组件
**组件规范**:
- 渐变 shimmer 动画效果
- 支持多种形状（卡片、文本行等）
**验证方法**:
- 动画效果流畅
- 支持自定义尺寸
- 不造成过度绘制
**文件**: `lib/presentation/widgets/common/loading_shimmer.dart`

---

### 任务 10: 代码质量检查
**描述**: 运行 Dart 分析器检查所有组件代码
**验证方法**:
- `flutter analyze` 无错误
- 无警告（或仅接受警告）
**文件**: 所有组件文件

---

### 任务 11: 更新更新记录文档
**描述**: 在根目录创建/更新 UPDATE_LOG.md
**验证方法**: 文档包含所有变更内容
**文件**: `UPDATE_LOG.md`

---

## 执行顺序

```
任务 1 → 任务 2 → 任务 3-9 (可并行) → 任务 10 → 任务 11
```

## 依赖关系

- 任务 3-9 依赖于任务 1 和 任务 2
- 任务 10 依赖于任务 3-9 全部完成
- 任务 11 依赖于任务 10 完成
