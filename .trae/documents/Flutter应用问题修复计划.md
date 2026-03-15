# Flutter应用问题修复计划

## Context
用户反馈实际手机上的Flutter应用存在以下问题：
1. 发送完成后，结果识别卡会一直转（AI分析加载状态不消失）
2. 新消息会把上面的信息抵掉（UI显示问题）
3. 实际上新建了好多信息，但只会保存最新的一条（数据存储问题）

## Problem Analysis

### 问题1: AI分析加载状态一直转
**原因分析**:
- `home_provider.dart` 中的 `_pollAnalysisResult` 方法使用定时轮询检查AI分析结果
- 如果AI任务队列中的任务执行失败或返回错误状态，轮询可能无法正常结束
- `isAnalyzing` 状态没有被正确设置为false

**代码位置**: `lib/application/providers/home_provider.dart` 第162-193行

### 问题2: 新消息抵掉上面的信息
**原因分析**:
- 用户截图显示有一个骨架屏卡片显示在列表中
- `_buildContentList` 方法在 `isAnalyzing` 为true时会在列表末尾添加一个骨架屏
- 但骨架屏显示的位置和方式可能导致视觉上的"抵掉"效果

**代码位置**: `lib/presentation/pages/home/home_page.dart` 第482-489行

### 问题3: 只保存最新一条信息
**原因分析**:
- `saveIdea` 方法在保存后会调用 `loadIdeas()` 重新加载列表
- 但可能存在状态更新问题，导致列表没有正确显示所有数据
- 或者数据库查询有问题，只返回最新的一条

**代码位置**: `lib/application/providers/home_provider.dart` 第115-159行

## Scope
涉及文件：
1. `lib/application/providers/home_provider.dart` - 核心状态管理修复
2. `lib/presentation/pages/home/home_page.dart` - UI显示修复

## Implementation Steps

### 步骤1: 修复AI分析轮询逻辑
**修改 `home_provider.dart`**:
1. 添加轮询超时处理，确保 `isAnalyzing` 一定会被设置为false
2. 添加错误处理，当AI分析失败时正确更新状态
3. 添加最大轮询次数限制，防止无限轮询

### 步骤2: 修复数据加载逻辑
**修改 `home_provider.dart`**:
1. 确保 `loadIdeas()` 正确获取所有数据
2. 检查数据库查询是否有问题
3. 添加日志输出便于调试

### 步骤3: 修复UI显示问题
**修改 `home_page.dart`**:
1. 优化骨架屏显示逻辑
2. 确保新添加的灵感正确显示在列表顶部
3. 修复列表刷新时的视觉问题

### 步骤4: 添加调试日志
**添加日志输出**:
1. 在关键位置添加日志，便于排查问题
2. 记录保存、加载、分析等操作的执行情况

## Verification
- [ ] 发送灵感后AI分析状态正确消失
- [ ] 可以保存多条灵感，列表正确显示所有数据
- [ ] 新保存的灵感显示在列表顶部
- [ ] 骨架屏显示正常，不会"抵掉"其他内容
