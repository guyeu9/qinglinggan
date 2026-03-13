# P1 AI对话服务实现计划

**版本：V1.0**  
**优先级：P1**  
**预计时间：4-5 小时**  
**制定日期：2026-03-13**

---

## 一、任务概述

根据《轻灵感》第二阶段开发设计方案，实现 P1 优先级的 AI 对话服务功能。

### 1.1 目标

- 创建 AI 对话服务，支持自然语言搜索、历史回顾、AI 对话
- 创建 AI 对话 Provider，管理对话状态
- 重构 AI Hub 页面，实现完整对话功能

### 1.2 验收标准

| 功能 | 验收标准 |
|------|----------|
| 自然语言搜索 | 用户输入自然语言问题，返回相关灵感列表 |
| 历史回顾 | 可回顾近15天的灵感内容 |
| AI 对话 | 可基于全部数据进行对话 |
| UI 集成 | AI Hub 页面实现完整对话功能 |

---

## 二、实现步骤

### 步骤 1：创建 AI 对话服务

**文件**: `lib/application/ai/ai_chat_service.dart`

**功能设计**:

```dart
class AIChatService {
  /// 自然语言搜索灵感
  Future<Result<List<IdeaEntity>>> searchByNaturalLanguage(String query);
  
  /// 历史灵感回顾（近半个月）
  Future<Result<String>> reviewRecentIdeas({int days = 15});
  
  /// 指定时间范围分析
  Future<Result<String>> analyzeByDateRange(DateTime start, DateTime end);
  
  /// 基于全部数据的AI对话
  Future<Result<ChatResponse>> chat(String userMessage, {List<int>? contextIdeaIds});
}

class ChatResponse {
  final String content;           // AI 回复内容
  final List<IdeaEntity> referencedIdeas;  // 引用的灵感
}
```

**实现要点**:
1. 注入 OpenAIClient、IdeaRepository、AIEmbeddingService
2. 自然语言搜索：使用 Embedding 相似度匹配
3. 历史回顾：获取近 N 天的灵感，调用 AI 生成总结
4. AI 对话：构建包含灵感上下文的 prompt，调用 Chat Completion API

---

### 步骤 2：创建 AI 对话 Provider

**文件**: `lib/application/providers/ai_chat_provider.dart`

**状态设计**:

```dart
class AIChatState {
  final List<ChatMessage> messages;      // 对话历史
  final bool isLoading;                  // 加载状态
  final String? error;                   // 错误信息
  final List<IdeaEntity> referencedIdeas; // 引用的灵感
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<IdeaEntity>? referencedIdeas;
}

class AIChatNotifier extends StateNotifier<AIChatState> {
  /// 发送消息
  Future<void> sendMessage(String content);
  
  /// 清空对话
  void clearChat();
  
  /// 搜索灵感
  Future<void> searchIdeas(String query);
  
  /// 回顾历史
  Future<void> reviewHistory({int days = 15});
}
```

---

### 步骤 3：更新 Provider 配置

**文件**: `lib/application/providers/app_providers.dart`

**新增 Provider**:

```dart
final aiChatServiceProvider = Provider<AIChatService>((ref) {
  return AIChatService(
    ref.watch(openAIClientProvider),
    ref.watch(ideaRepositoryProvider),
    ref.watch(aiEmbeddingServiceProvider),
    ref.watch(loggerProvider),
  );
});

final aiChatProvider = StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier(
    ref.watch(aiChatServiceProvider),
    ref.watch(ideaRepositoryProvider),
  );
});
```

---

### 步骤 4：重构 AI Hub 页面

**文件**: `lib/presentation/pages/ai_hub/ai_hub_page.dart`

**主要变更**:

1. **StatefulWidget → ConsumerStatefulWidget**
   - 使用 Riverpod 状态管理
   - 通过 `ref.watch(aiChatProvider)` 监听状态

2. **移除模拟数据**
   - 删除硬编码的 `_messages` 列表
   - 使用 Provider 提供的真实数据

3. **实现真实对话功能**
   - `_handleSend()` 调用 `aiChatProvider.sendMessage()`
   - 显示加载状态
   - 显示错误信息

4. **展示引用的灵感**
   - 在 AI 回复下方展示引用的灵感卡片
   - 点击卡片跳转到灵感详情页

5. **快捷功能按钮**
   - "总结最近灵感" → 调用 `reviewHistory()`
   - "搜索灵感" → 调用 `searchIdeas()`

---

## 三、文件变更清单

### 3.1 新建文件（2 个）

| 文件路径 | 说明 |
|----------|------|
| `lib/application/ai/ai_chat_service.dart` | AI 对话服务 |
| `lib/application/providers/ai_chat_provider.dart` | AI 对话 Provider |

### 3.2 修改文件（2 个）

| 文件路径 | 修改内容 |
|----------|----------|
| `lib/application/providers/app_providers.dart` | 添加 AI 对话相关 Provider |
| `lib/presentation/pages/ai_hub/ai_hub_page.dart` | 重构为真实对话功能 |

---

## 四、依赖关系

```
AIChatService
├── OpenAIClient (Chat Completion API)
├── IdeaRepository (获取灵感数据)
├── AIEmbeddingService (向量搜索)
└── AppLogger (日志)

AIChatProvider
├── AIChatService
└── IdeaRepository
```

---

## 五、测试计划

### 5.1 单元测试

**文件**: `test/application/ai/ai_chat_service_test.dart`

| 测试用例 | 说明 |
|----------|------|
| searchByNaturalLanguage_emptyQuery | 空查询返回错误 |
| searchByNaturalLanguage_validQuery | 有效查询返回灵感列表 |
| reviewRecentIdeas_noIdeas | 无灵感时返回提示 |
| reviewRecentIdeas_withIdeas | 有灵感时返回总结 |
| chat_emptyMessage | 空消息返回错误 |
| chat_validMessage | 有效消息返回回复 |

### 5.2 验证命令

```bash
flutter analyze
flutter test
```

---

## 六、风险与注意事项

### 6.1 技术风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| AI API 响应慢 | 用户体验差 | 显示加载状态，支持取消请求 |
| Token 消耗大 | 成本上升 | 限制上下文长度，使用缓存 |
| 网络错误 | 功能不可用 | 显示错误提示，支持重试 |

### 6.2 开发注意事项

1. **遵循现有架构**: AIChatService 遵循四层架构
2. **错误处理**: 所有异步操作使用 Result 封装
3. **日志记录**: 关键操作记录日志
4. **代码风格**: 遵循 Flutter 官方规范

---

## 七、开发顺序

```
Step 1: 创建 ai_chat_service.dart
Step 2: 创建 ai_chat_provider.dart
Step 3: 更新 app_providers.dart
Step 4: 重构 ai_hub_page.dart
Step 5: 创建单元测试
Step 6: 运行验证
```

---

**文档版本：V1.0**  
**状态：待用户确认**
