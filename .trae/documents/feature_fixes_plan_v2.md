# 功能修复计划 - 第二批

## 概述

本文档详细描述了四个功能修复方案：
1. 任务队列超时机制
2. 向量搜索分页优化
3. 日志脱敏处理
4. Presentation 层连接 Provider

---

## 问题一：任务队列超时机制

### Context（背景）

**当前状态**：
- `AITaskQueue._processNext()` 没有超时处理
- 如果 AI API 调用时间过长或网络问题，任务会无限等待
- 可能导致整个队列阻塞
- 用户无法得知任务卡住的原因

**风险**：
- 单个任务阻塞会影响后续所有任务
- 用户体验差，无法得知任务状态
- 资源无法及时释放

### Scope（涉及文件）

| 文件 | 操作 |
|------|------|
| `lib/core/constants/app_constants.dart` | 添加超时常量 |
| `lib/application/task_queue/ai_task_queue.dart` | 添加超时处理逻辑 |

### Behavior（行为规范）

#### 超时规则

| 场景 | 超时时间 | 行为 |
|------|----------|------|
| 单个任务执行 | 120秒 | 标记为失败，触发重试机制 |
| API 调用 | 60秒 | 抛出超时异常 |

#### 实现方案

```dart
// app_constants.dart
class AppConstants {
  // ... 现有常量
  static const int taskTimeoutSeconds = 120;
  static const int apiTimeoutSeconds = 60;
}

// ai_task_queue.dart
Future<void> _processNext() async {
  if (_isProcessing || _queue.isEmpty) return;

  _isProcessing = true;
  final task = _queue.removeFirst();

  try {
    await _taskRepository.updateStatus(task.id, TaskStatus.processing);
    await _ideaRepository.updateAIStatus(task.ideaId, AIStatus.processing);

    // 添加超时处理
    await _runBasicAnalysis(task.ideaId)
        .timeout(
          Duration(seconds: AppConstants.taskTimeoutSeconds),
          onTimeout: () {
            throw TimeoutException(
              '任务执行超时',
              Duration(seconds: AppConstants.taskTimeoutSeconds),
            );
          },
        );

    await _taskRepository.updateStatus(task.id, TaskStatus.completed);
    await _ideaRepository.updateAIStatus(task.ideaId, AIStatus.completed);

    _logger.info('AI任务完成: taskId=${task.id}, ideaId=${task.ideaId}');
  } on TimeoutException catch (e, st) {
    _logger.error('AI任务超时: taskId=${task.id}', e, st);
    await _handleFailure(task, '任务执行超时: ${e.message}');
  } on AIException catch (e, st) {
    // ... 现有处理
  } catch (e, st) {
    // ... 现有处理
  } finally {
    _isProcessing = false;
    unawaited(_processNext());
  }
}
```

### Risks（风险分析）

1. **任务中断**：超时可能导致正在进行的操作被中断
2. **数据一致性**：需要确保超时后的状态正确

---

## 问题二：向量搜索分页优化

### Context（背景）

**当前状态**：
```dart
Future<Result<List<SimilarIdea>>> searchSimilar(...) async {
  // 一次性加载所有数据！
  final allIdeas = await _ideaRepository.getAll(includeDeleted: false);
  
  // 内存中过滤和排序
  final candidates = allIdeas.where(...).toList();
  // ...
}
```

**问题**：
- 一次性加载所有灵感数据到内存
- 当数据量大时，内存占用高
- 性能随数据量增长而下降
- 无法利用数据库索引优化

### Scope（涉及文件）

| 文件 | 操作 |
|------|------|
| `lib/domain/repositories/idea_repository.dart` | 添加分页查询方法 |
| `lib/data/repositories/idea_repository_impl.dart` | 实现分页查询 |
| `lib/application/ai/ai_embedding_service.dart` | 使用分页查询 |

### Behavior（行为规范）

#### 分页策略

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `pageSize` | 100 | 每页加载数量 |
| `maxResults` | 1000 | 最大处理数量 |

#### 实现方案

```dart
// idea_repository.dart
abstract class IdeaRepository {
  // ... 现有方法
  
  /// 获取有向量的灵感（分页）
  Future<List<IdeaEntity>> getIdeasWithEmbedding({
    int limit = 100,
    int offset = 0,
  });
  
  /// 获取有向量的灵感总数
  Future<int> countIdeasWithEmbedding();
}

// ai_embedding_service.dart
Future<Result<List<SimilarIdea>>> searchSimilar(
  List<double> queryEmbedding, {
  int topN = 10,
  double threshold = 0.3,
  int? excludeId,
}) async {
  if (queryEmbedding.isEmpty) {
    return Result.error('查询向量不能为空');
  }

  try {
    _logger.info('开始搜索相似灵感: topN=$topN, threshold=$threshold');

    final results = <SimilarIdea>[];
    const pageSize = 100;
    var offset = 0;
    const maxPages = 10; // 最多处理1000条

    for (var page = 0; page < maxPages; page++) {
      final candidates = await _ideaRepository.getIdeasWithEmbedding(
        limit: pageSize,
        offset: offset,
      );

      if (candidates.isEmpty) break;

      for (final idea in candidates) {
        if (excludeId != null && idea.id == excludeId) continue;
        if (idea.embedding == null || idea.embedding!.isEmpty) continue;

        final similarity = VectorMath.cosineSimilarity(
          queryEmbedding,
          idea.embedding!,
        );
        if (similarity >= threshold) {
          results.add(SimilarIdea(idea: idea, similarity: similarity));
        }
      }

      // 如果已经找到足够多的结果，可以提前退出
      if (results.length >= topN * 3) break;

      offset += pageSize;
    }

    results.sort((a, b) => b.similarity.compareTo(a.similarity));
    final topResults = results.take(topN).toList();

    _logger.info('搜索完成: 找到${results.length}个相似灵感, 返回前${topResults.length}个');

    return Result.success(topResults);
  } catch (e, st) {
    _logger.error('搜索相似灵感失败', e, st);
    return Result.error('搜索相似灵感失败: $e', e);
  }
}
```

### Risks（风险分析）

1. **精度影响**：分页可能导致部分相似结果被遗漏
2. **查询次数**：多次查询可能增加数据库负载

---

## 问题三：日志脱敏处理

### Context（背景）

**当前状态**：
```dart
class AppLogger {
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }
}
```

**问题**：
- 日志直接输出原始内容
- API 密钥、用户内容等敏感信息可能被记录
- 日志文件可能被未授权访问

### Scope（涉及文件）

| 文件 | 操作 |
|------|------|
| `lib/core/utils/sensitive_data_masker.dart` | 新建 - 脱敏工具类 |
| `lib/core/logger/app_logger.dart` | 添加脱敏处理 |

### Behavior（行为规范）

#### 脱敏规则

| 数据类型 | 脱敏方式 | 示例 |
|----------|----------|------|
| API Key | 显示前4位和后4位 | `sk-abc...xyz` |
| 手机号 | 显示前3后4 | `138****5678` |
| 邮箱 | 显示前3和域名 | `abc***@example.com` |
| 用户内容 | 截断并标记 | `[内容已脱敏, 100字]` |
| 密码 | 完全隐藏 | `******` |

#### 实现方案

```dart
// sensitive_data_masker.dart
class SensitiveDataMasker {
  SensitiveDataMasker._();

  static final _apiKeyPattern = RegExp(r'sk-[a-zA-Z0-9]{20,}');
  static final _emailPattern = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
  static final _phonePattern = RegExp(r'1[3-9]\d{9}');

  static String mask(String content) {
    var result = content;

    // 脱敏 API Key
    result = result.replaceAllMapped(_apiKeyPattern, (match) {
      final key = match.group(0)!;
      if (key.length > 12) {
        return '${key.substring(0, 6)}...${key.substring(key.length - 4)}';
      }
      return '***';
    });

    // 脱敏邮箱
    result = result.replaceAllMapped(_emailPattern, (match) {
      final email = match.group(0)!;
      final parts = email.split('@');
      if (parts.length == 2) {
        final name = parts[0];
        final domain = parts[1];
        final maskedName = name.length > 3 
            ? '${name.substring(0, 3)}***' 
            : '***';
        return '$maskedName@$domain';
      }
      return '***@***';
    });

    // 脱敏手机号
    result = result.replaceAllMapped(_phonePattern, (match) {
      final phone = match.group(0)!;
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    });

    return result;
  }

  static String maskContent(String content, {int maxLength = 50}) {
    if (content.length <= maxLength) {
      return '[内容: ${content.length}字]';
    }
    return '[内容已脱敏, ${content.length}字]';
  }
}

// app_logger.dart
class AppLogger {
  // ... 现有代码

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    final maskedMessage = SensitiveDataMasker.mask(message);
    _logger.i(maskedMessage, error: error, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    final maskedMessage = SensitiveDataMasker.mask(message);
    _logger.e(maskedMessage, error: error, stackTrace: stackTrace);
  }

  // ... 其他方法类似处理
}
```

### Risks（风险分析）

1. **调试困难**：脱敏后可能影响问题排查
2. **性能影响**：正则匹配可能影响性能

---

## 问题四：Presentation 层连接 Provider

### Context（背景）

**当前状态**：
```dart
// home_page.dart 使用模拟数据
final List<Map<String, dynamic>> _mockIdeas = [
  {'id': '1', 'category': '工作/创意', ...},
  // ...
];
```

**问题**：
- UI 层使用模拟数据，未连接真实数据源
- Provider 已创建但未被使用
- 功能无法正常工作

### Scope（涉及文件）

| 文件 | 操作 |
|------|------|
| `lib/presentation/pages/home/home_page.dart` | 连接 `homeProvider` |
| `lib/presentation/pages/idea_detail/idea_detail_page.dart` | 连接 `ideaDetailProvider` |
| `lib/presentation/widgets/common/inspiration_card.dart` | 适配真实数据模型 |

### Behavior（行为规范）

#### 数据流

```
Provider (State) → Widget (UI) → Action → Provider (Method) → Repository → Database
```

#### 实现方案

```dart
// home_page.dart
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // ... 控制器

  @override
  Widget build(BuildContext context) {
    // 监听状态
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    return Scaffold(
      // ...
      body: Column(
        children: [
          // 分类Tab
          CategoryTabs(
            categories: ['全部', ...homeState.categories.map((c) => c.name)],
            selectedIndex: homeState.selectedCategoryIndex,
            onTabChanged: homeNotifier.selectCategory,
          ),
          
          // 灵感列表
          Expanded(
            child: homeState.ideas.isEmpty
                ? const EmptyStateWidget()
                : ListView.builder(
                    itemCount: homeState.ideas.length,
                    itemBuilder: (context, index) {
                      final idea = homeState.ideas[index];
                      return InspirationCard.fromEntity(
                        idea: idea,
                        onTap: () => _onIdeaTap(idea.id),
                      );
                    },
                  ),
          ),
          
          // 底部输入
          BottomInputBar(
            onSend: (text) async {
              final success = await homeNotifier.saveIdea(text);
              if (success) {
                _showSaveSuccessSnackBar();
              }
            },
          ),
        ],
      ),
    );
  }
}
```

### Risks（风险分析）

1. **状态管理**：需要正确处理加载、错误状态
2. **生命周期**：需要正确管理 Provider 的生命周期

---

## 任务分解

### 任务一：任务队列超时机制

| 序号 | 任务 | 验证方法 |
|------|------|----------|
| 1.1 | 添加超时常量到 AppConstants | 编译通过 |
| 1.2 | 修改 _processNext 添加超时处理 | 超时任务被正确标记为失败 |

### 任务二：向量搜索分页优化

| 序号 | 任务 | 验证方法 |
|------|------|----------|
| 2.1 | 扩展 IdeaRepository 接口 | 编译通过 |
| 2.2 | 实现分页查询方法 | 单元测试通过 |
| 2.3 | 修改 searchSimilar 使用分页 | 大数据量测试通过 |

### 任务三：日志脱敏处理

| 序号 | 任务 | 验证方法 |
|------|------|----------|
| 3.1 | 创建 SensitiveDataMasker 工具类 | 单元测试通过 |
| 3.2 | 修改 AppLogger 添加脱敏 | 日志中敏感信息被遮盖 |

### 任务四：Presentation 层连接 Provider

| 序号 | 任务 | 验证方法 |
|------|------|----------|
| 4.1 | 修改 HomePage 连接 homeProvider | UI 显示真实数据 |
| 4.2 | 修改 IdeaDetailPage 连接 ideaDetailProvider | 详情页显示真实数据 |
| 4.3 | 添加加载和错误状态处理 | 状态正确显示 |

---

## 执行顺序

建议按以下顺序执行：

1. **任务三**（日志脱敏处理）- 独立模块，无依赖
2. **任务一**（任务队列超时机制）- 独立模块，影响稳定性
3. **任务二**（向量搜索分页优化）- 性能优化
4. **任务四**（Presentation 层连接 Provider）- 影响范围最广，需要仔细测试

---

## 预估影响

| 问题 | 修改文件数 | 破坏性变更 | 测试复杂度 |
|------|-----------|-----------|-----------|
| 任务队列超时机制 | 2 | 低 | 低 |
| 向量搜索分页优化 | 3 | 中 | 中 |
| 日志脱敏处理 | 2 | 低 | 低 |
| Presentation 层连接 Provider | 3+ | 高 | 高 |

---

*计划创建时间：2026-03-13*
*计划状态：待用户确认*
