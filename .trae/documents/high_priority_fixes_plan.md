# 高优先级问题修复计划

## 概述

本文档详细描述了三个高优先级问题的修复方案：
1. API 密钥安全存储
2. AI 解析失败异常处理
3. 任务队列去重机制

---

## 问题一：API 密钥安全存储

### Context（背景）

**当前状态**：
- API 密钥存储在内存中的静态变量 `static String? _apiKey`
- 应用重启后密钥丢失，用户需要重新输入
- 密钥可被内存转储获取，存在安全隐患
- 没有使用任何加密存储机制

**风险**：
- 密钥泄露风险：内存中的明文密钥可被恶意程序读取
- 用户体验差：每次启动应用都需要重新输入密钥
- 不符合安全最佳实践

### Scope（涉及文件）

| 文件 | 操作 |
|------|------|
| `pubspec.yaml` | 添加 `flutter_secure_storage` 依赖 |
| `lib/config/ai_config.dart` | 重构为异步安全存储模式 |
| `lib/application/ai/ai_understanding_service.dart` | 适配异步 API 密钥获取 |
| `lib/application/ai/ai_embedding_service.dart` | 适配异步 API 密钥获取 |
| `lib/presentation/pages/settings_page.dart` | 适配异步密钥设置/获取 |

### Behavior（行为规范）

#### 输入/输出行为

```dart
// 初始化时加载密钥
Future<void> initialize() async;

// 安全存储密钥
Future<void> setApiKey(String key) async;

// 安全获取密钥
Future<String?> getApiKey() async;

// 清除密钥
Future<void> clearApiKey() async;

// 检查是否已设置密钥
Future<bool> hasApiKey() async;
```

#### 存储机制

| 平台 | 存储方式 |
|------|----------|
| Android | EncryptedSharedPreferences (AES加密) |
| iOS | Keychain Services |
| Windows | Windows Credential Manager |
| macOS | Keychain Services |
| Linux | libsecret |

### Risks（风险分析）

1. **破坏性变更**：API 从同步变为异步，需要修改所有调用点
2. **平台兼容性**：某些平台可能需要额外配置
3. **迁移问题**：现有用户可能需要重新输入密钥

### 实施方案

```dart
// lib/config/ai_config.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AIConfig {
  AIConfig._();

  static const String defaultChatModel = 'gpt-4o-mini';
  static const String defaultEmbeddingModel = 'text-embedding-3-small';
  static const int embeddingDimension = 1536;
  static const int defaultMaxTokens = 1000;
  static const double defaultTemperature = 0.3;
  static const int defaultTimeoutSeconds = 60;
  static const int maxRetryCount = 3;
  static const int retryDelaySeconds = 2;
  static const String apiBaseUrl = 'https://api.openai.com/v1';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _apiKeyKey = 'openai_api_key';

  static String? _cachedApiKey;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _cachedApiKey = await _storage.read(key: _apiKeyKey);
    _initialized = true;
  }

  static Future<void> setApiKey(String key) async {
    await _storage.write(key: _apiKeyKey, value: key);
    _cachedApiKey = key;
  }

  static Future<String?> getApiKey() async {
    if (!_initialized) {
      await initialize();
    }
    return _cachedApiKey;
  }

  static Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeyKey);
    _cachedApiKey = null;
  }

  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  // 同步访问（仅用于已初始化后的快速访问）
  static String? get cachedApiKey => _cachedApiKey;
}
```

---

## 问题二：AI 解析失败异常处理

### Context（背景）

**当前状态**：
```dart
static AIAnalysisResult parseFromJsonString(String jsonString) {
  try {
    // ... 解析逻辑
  } catch (e) {
    return const AIAnalysisResult();  // 静默失败！
  }
}
```

**问题**：
- 解析失败时返回空对象，调用者无法区分"解析成功但结果为空"和"解析失败"
- 错误被吞没，无法追踪和调试
- 用户无法得知 AI 返回的数据格式有问题

### Scope（涉及文件）

| 文件 | 操作 |
|------|------|
| `lib/core/exceptions/ai_exceptions.dart` | 新建 - 定义 AI 相关异常 |
| `lib/data/api/api_models.dart` | 修改解析方法，抛出异常 |
| `lib/application/ai/ai_understanding_service.dart` | 捕获并处理异常 |
| `lib/application/task_queue/ai_task_queue.dart` | 处理解析异常 |

### Behavior（行为规范）

#### 异常定义

```dart
// lib/core/exceptions/ai_exceptions.dart

abstract class AIException implements Exception {
  final String message;
  final String? rawContent;
  final Object? cause;

  const AIException(this.message, {this.rawContent, this.cause});

  @override
  String toString() => 'AIException: $message';
}

class AIResponseParseException extends AIException {
  const AIResponseParseException(
    String message, {
    String? rawContent,
    Object? cause,
  }) : super(message, rawContent: rawContent, cause: cause);

  @override
  String toString() => 'AIResponseParseException: $message';
}

class AIEmptyResponseException extends AIException {
  const AIEmptyResponseException([String? rawContent])
      : super('AI 返回空响应', rawContent: rawContent);
}
```

#### 解析方法行为

```dart
static AIAnalysisResult parseFromJsonString(String jsonString) {
  if (jsonString.trim().isEmpty) {
    throw const AIEmptyResponseException();
  }

  try {
    final cleaned = jsonString
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();
    
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    return AIAnalysisResult.fromJson(json);
  } on FormatException catch (e) {
    throw AIResponseParseException(
      'JSON 格式解析失败',
      rawContent: jsonString,
      cause: e,
    );
  } on TypeError catch (e) {
    throw AIResponseParseException(
      'JSON 结构不符合预期',
      rawContent: jsonString,
      cause: e,
    );
  }
}
```

### Risks（风险分析）

1. **破坏性变更**：现有调用代码需要处理异常
2. **错误传播**：需要确保异常被正确处理，避免应用崩溃

### 实施方案

修改调用链：

```dart
// ai_understanding_service.dart
Future<Result<AIAnalysisResult>> analyze(String content) async {
  try {
    final response = await _openAIClient.chatCompletion(...);
    final result = AIAnalysisResult.parseFromJsonString(response);
    return Result.success(result);
  } on AIException catch (e) {
    _logger.error('AI 解析失败', e);
    return Result.failure(e.message);
  }
}
```

---

## 问题三：任务队列去重机制

### Context（背景）

**当前状态**：
```dart
Future<void> enqueue(int ideaId, {TaskType taskType = TaskType.basicAnalysis}) async {
  // 没有检查是否已存在相同任务！
  final task = AITaskEntity(...);
  final savedTask = await _taskRepository.save(task);
  _queue.add(savedTask);
}
```

**问题**：
- 同一灵感可能被多次入队
- 浪费 API 调用配额
- 可能产生重复的分析结果
- 用户多次点击"分析"按钮会创建多个任务

### Scope（涉及文件）

| 文件 | 操作 |
|------|------|
| `lib/domain/repositories/ai_task_repository.dart` | 添加查询方法 |
| `lib/data/repositories/ai_task_repository_impl.dart` | 实现查询方法 |
| `lib/application/task_queue/ai_task_queue.dart` | 添加去重逻辑 |

### Behavior（行为规范）

#### 去重规则

| 条件 | 行为 |
|------|------|
| 已存在 pending 状态的同 ideaId 任务 | 跳过入队，返回现有任务 |
| 已存在 processing 状态的同 ideaId 任务 | 跳过入队，返回现有任务 |
| 已存在 completed 状态的同 ideaId 任务（24小时内） | 跳过入队，提示用户 |
| 已存在 failed 状态的同 ideaId 任务 | 允许重新入队 |

#### 接口定义

```dart
// ai_task_repository.dart
abstract class AITaskRepository {
  // ... 现有方法

  /// 获取指定灵感的活跃任务（pending 或 processing）
  Future<AITaskEntity?> getActiveTaskByIdeaId(int ideaId);

  /// 获取指定灵感的最近任务
  Future<AITaskEntity?> getLatestTaskByIdeaId(int ideaId);
}
```

#### 入队逻辑

```dart
Future<EnqueueResult> enqueue(int ideaId, {TaskType taskType = TaskType.basicAnalysis}) async {
  // 检查是否有活跃任务
  final activeTask = await _taskRepository.getActiveTaskByIdeaId(ideaId);
  if (activeTask != null) {
    _logger.info('任务已存在，跳过入队: ideaId=$ideaId, taskId=${activeTask.id}');
    return EnqueueResult.skipped(activeTask, '任务已在队列中');
  }

  // 检查是否有最近完成的任务（可选，根据业务需求）
  final latestTask = await _taskRepository.getLatestTaskByIdeaId(ideaId);
  if (latestTask != null && 
      latestTask.status == TaskStatus.completed &&
      latestTask.completedAt != null &&
      DateTime.now().difference(latestTask.completedAt!) < const Duration(hours: 24)) {
    _logger.info('任务最近已完成，跳过入队: ideaId=$ideaId');
    return EnqueueResult.skipped(latestTask, '任务已在24小时内完成');
  }

  // 创建新任务
  final task = AITaskEntity(
    id: 0,
    ideaId: ideaId,
    taskType: taskType,
    status: TaskStatus.pending,
    createdAt: DateTime.now(),
  );

  final savedTask = await _taskRepository.save(task);
  _queue.add(savedTask);

  _logger.info('任务入队成功: ideaId=$ideaId, taskId=${savedTask.id}');
  unawaited(_processNext());

  return EnqueueResult.enqueued(savedTask);
}

enum EnqueueStatus { enqueued, skipped }

class EnqueueResult {
  final EnqueueStatus status;
  final AITaskEntity task;
  final String? reason;

  const EnqueueResult._(this.status, this.task, [this.reason]);

  factory EnqueueResult.enqueued(AITaskEntity task) =>
      EnqueueResult._(EnqueueStatus.enqueued, task);

  factory EnqueueResult.skipped(AITaskEntity task, String reason) =>
      EnqueueResult._(EnqueueStatus.skipped, task, reason);

  bool get wasEnqueued => status == EnqueueStatus.enqueued;
}
```

### Risks（风险分析）

1. **接口变更**：`enqueue` 返回值从 `void` 变为 `EnqueueResult`
2. **数据库查询**：增加查询操作，可能略微影响性能
3. **业务逻辑**：需要确定"最近完成"的时间窗口

### 实施方案

1. 扩展 `AITaskRepository` 接口
2. 在 `AITaskRepositoryImpl` 中实现新方法
3. 修改 `AITaskQueue.enqueue` 方法
4. 更新调用方处理新的返回值

---

## 任务分解

### 任务一：API 密钥安全存储

| 序号 | 任务 | 验证方法 |
|------|------|----------|
| 1.1 | 添加 flutter_secure_storage 依赖 | `flutter pub get` 成功 |
| 1.2 | 创建 AIConfig 异步版本 | 编译通过 |
| 1.3 | 修改 AI 服务适配异步密钥获取 | 编译通过 |
| 1.4 | 修改设置页面适配异步操作 | UI 可正常设置/清除密钥 |
| 1.5 | 添加应用启动时初始化逻辑 | 应用启动后密钥持久化 |

### 任务二：AI 解析失败异常处理

| 序号 | 任务 | 验证方法 |
|------|------|----------|
| 2.1 | 创建 AI 异常类 | 编译通过 |
| 2.2 | 修改 parseFromJsonString 抛出异常 | 单元测试通过 |
| 2.3 | 修改 AI 服务捕获异常 | 编译通过 |
| 2.4 | 修改任务队列处理异常 | 错误可正确传播 |

### 任务三：任务队列去重机制

| 序号 | 任务 | 验证方法 |
|------|------|----------|
| 3.1 | 扩展 AITaskRepository 接口 | 编译通过 |
| 3.2 | 实现查询方法 | 单元测试通过 |
| 3.3 | 创建 EnqueueResult 类型 | 编译通过 |
| 3.4 | 修改 enqueue 方法添加去重逻辑 | 重复入队被阻止 |
| 3.5 | 更新调用方代码 | 编译通过 |

---

## 执行顺序

建议按以下顺序执行：

1. **先执行任务二**（AI 解析异常处理）- 风险最低，影响范围最小
2. **再执行任务三**（任务队列去重）- 独立模块，不影响其他功能
3. **最后执行任务一**（API 密钥安全存储）- 影响范围最广，需要仔细测试

---

## 预估影响

| 问题 | 修改文件数 | 破坏性变更 | 测试复杂度 |
|------|-----------|-----------|-----------|
| API 密钥安全存储 | 5+ | 高 | 中 |
| AI 解析异常处理 | 4 | 中 | 低 |
| 任务队列去重 | 3 | 低 | 低 |

---

## 待确认事项

1. **API 密钥存储**：是否需要在设置页面显示密钥的掩码版本（如 `sk-****...****`）？
2. **任务去重**：已完成任务的时间窗口设置为 24 小时是否合适？
3. **异常处理**：是否需要将解析错误上报到日志系统？

---

*计划创建时间：2026-03-13*
*计划状态：待用户确认*
