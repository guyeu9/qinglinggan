# P2 关联分析服务实现计划

**版本：V1.0**  
**优先级：P2**  
**预计时间：3-4 小时**  
**制定日期：2026-03-14**

---

## 一、任务概述

根据《轻灵感》第二阶段开发设计方案，实现 P2 优先级的关联分析服务功能。

### 1.1 目标

- 创建关联实体和数据模型，存储灵感之间的关联关系
- 创建关联仓库，提供关联数据的 CRUD 操作
- 创建 AI 关系判断服务，识别相似/互补/演化三种关系类型
- 集成到任务队列，在 AI 分析流程中自动生成关联关系

### 1.2 验收标准

| 功能 | 验收标准 |
|------|----------|
| 关联实体 | 支持存储 sourceIdeaId、targetIdeaId、type、reason、confidence |
| 关联仓库 | 支持保存、查询、删除关联关系 |
| AI 关系判断 | 能识别相似、互补、演化三种关系类型 |
| 任务队列集成 | AI 分析流程自动生成关联关系 |

---

## 二、实现步骤

### 步骤 1：创建关联实体

**文件**: `lib/domain/entities/association.dart`

**实体设计**:

```dart
enum RelationType { similar, complementary, evolutionary }

class AssociationEntity {
  final int id;
  final int sourceIdeaId;      // 源灵感ID
  final int targetIdeaId;      // 目标灵感ID
  final RelationType type;     // 关系类型
  final String reason;         // 关联原因
  final double confidence;     // 置信度 (0.0 - 1.0)
  final DateTime createdAt;
}
```

---

### 步骤 2：创建关联仓库接口

**文件**: `lib/domain/repositories/association_repository.dart`

**接口设计**:

```dart
abstract class AssociationRepository {
  Future<AssociationEntity> save(AssociationEntity association);
  Future<List<AssociationEntity>> getBySourceIdeaId(int ideaId);
  Future<List<AssociationEntity>> getByTargetIdeaId(int ideaId);
  Future<List<AssociationEntity>> getByIdeaId(int ideaId);  // 双向查询
  Future<void> deleteBySourceIdeaId(int ideaId);
  Future<void> deleteByIdeaId(int ideaId);  // 双向删除
  Future<void> deleteAll();
}
```

---

### 步骤 3：创建关联数据模型

**文件**: `lib/data/models/association_model.dart`

**模型设计**:

```dart
@collection
class AssociationModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int sourceIdeaId;
  
  @Index()
  late int targetIdeaId;
  
  @Enumerated(EnumType.name)
  late RelationType type;
  
  late String reason;
  late double confidence;
  late DateTime createdAt;
}
```

**注意**: 需要运行 `flutter pub run build_runner build` 生成 `.g.dart` 文件

---

### 步骤 4：创建关联仓库实现

**文件**: `lib/data/repositories/association_repository_impl.dart`

**实现要点**:
- 注入 Isar 实例
- 实现 CRUD 操作
- 支持双向查询（sourceIdeaId 和 targetIdeaId）

---

### 步骤 5：更新 Isar 数据库配置

**文件**: `lib/data/database/isar_database.dart`

**修改内容**:
- 添加 `AssociationModelSchema` 到 schemas 列表

---

### 步骤 6：创建 AI 关系判断服务

**文件**: `lib/application/ai/ai_relation_service.dart`

**服务设计**:

```dart
class AIRelationService {
  final OpenAIClient _client;
  final AppLogger _logger;
  
  Future<Result<List<AssociationEntity>>> judgeRelations({
    required IdeaEntity currentIdea,
    required List<IdeaEntity> candidates,
  });
}
```

**Prompt 设计**:

```
你是一个灵感关联分析专家。请分析当前灵感与候选灵感之间的关系。

当前灵感：{currentIdea.content}

候选灵感：
1. {candidate1.content}
2. {candidate2.content}
...

请判断每条候选灵感与当前灵感的关系类型：
- similar: 内容相似、主题相近
- complementary: 内容互补、可以组合
- evolutionary: 当前灵感是候选灵感的演化/升级版本

返回 JSON 格式：
{
  "relations": [
    {
      "targetIdeaId": 1,
      "type": "similar",
      "reason": "两条灵感都涉及...",
      "confidence": 0.85
    }
  ]
}
```

---

### 步骤 7：更新任务队列

**文件**: `lib/application/task_queue/ai_task_queue.dart`

**修改内容**:

1. 注入 `AIRelationService` 和 `AssociationRepository`
2. 在 `_runBasicAnalysis` 方法中添加关系分析步骤

**流程变更**:

```
当前流程：
内容理解 → Embedding生成 → 保存结果

新增步骤：
内容理解 → Embedding生成 → 相似检索 → 关系判断 → 保存关联 → 保存结果
```

**代码修改**:

```dart
Future<void> _runBasicAnalysis(int ideaId) async {
  // ... 现有代码 ...
  
  // 新增：相似检索
  final searchResult = await _embeddingService.searchSimilar(embedding, topN: 5);
  
  // 新增：关系判断
  if (searchResult.isSuccess && searchResult.dataOrNull!.isNotEmpty) {
    final candidates = searchResult.dataOrNull!.map((s) => s.idea).toList();
    final relationResult = await _relationService.judgeRelations(
      currentIdea: idea,
      candidates: candidates,
    );
    
    if (relationResult.isSuccess) {
      for (final association in relationResult.dataOrNull!) {
        await _associationRepository.save(association);
      }
    }
  }
  
  // ... 现有保存代码 ...
}
```

---

### 步骤 8：更新 Provider 配置

**文件**: `lib/application/providers/app_providers.dart`

**新增 Provider**:

```dart
final associationRepositoryProvider = Provider<AssociationRepository>((ref) {
  return AssociationRepositoryImpl(ref.watch(isarProvider));
});

final aiRelationServiceProvider = Provider<AIRelationService>((ref) {
  return AIRelationService(
    ref.watch(openAIClientProvider),
    ref.watch(loggerProvider),
  );
});
```

---

## 三、文件变更清单

### 3.1 新建文件（5 个）

| 文件路径 | 说明 |
|----------|------|
| `lib/domain/entities/association.dart` | 关联实体 |
| `lib/domain/repositories/association_repository.dart` | 关联仓库接口 |
| `lib/data/models/association_model.dart` | 关联数据模型 |
| `lib/data/repositories/association_repository_impl.dart` | 关联仓库实现 |
| `lib/application/ai/ai_relation_service.dart` | AI 关系判断服务 |

### 3.2 修改文件（4 个）

| 文件路径 | 修改内容 |
|----------|----------|
| `lib/data/database/isar_database.dart` | 添加 AssociationModelSchema |
| `lib/application/task_queue/ai_task_queue.dart` | 添加关系分析步骤 |
| `lib/application/providers/app_providers.dart` | 添加关联相关 Provider |
| `pubspec.yaml` | 可能需要更新 isar 版本 |

---

## 四、依赖关系

```
AssociationEntity
└── AssociationModel (数据模型)
    └── AssociationRepository (仓库接口)
        └── AssociationRepositoryImpl (仓库实现)

AIRelationService
├── OpenAIClient (Chat Completion API)
└── AppLogger (日志)

AITaskQueue (修改)
├── AIRelationService (新增)
├── AssociationRepository (新增)
└── AIEmbeddingService (相似检索)
```

---

## 五、测试计划

### 5.1 单元测试

**文件**: `test/domain/entities/association_entity_test.dart`

| 测试用例 | 说明 |
|----------|------|
| should create association with all fields | 创建完整关联实体 |
| should copyWith correctly | copyWith 方法测试 |
| should have correct relation types | 关系类型枚举测试 |

**文件**: `test/data/repositories/association_repository_test.dart`

| 测试用例 | 说明 |
|----------|------|
| should save association | 保存关联 |
| should get by source idea id | 按源ID查询 |
| should get by target idea id | 按目标ID查询 |
| should get by idea id (bidirectional) | 双向查询 |
| should delete by idea id | 删除关联 |

### 5.2 验证命令

```bash
flutter pub run build_runner build  # 生成 Isar 代码
flutter analyze
flutter test
```

---

## 六、风险与注意事项

### 6.1 技术风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| Isar schema 变更需要迁移 | 数据丢失 | 使用 Isar 的 schema 版本管理 |
| AI API 调用增加 | 成本上升 | 仅对 TopN 候选进行关系判断 |
| 关系判断不准确 | 用户体验差 | 使用置信度过滤，低置信度不保存 |

### 6.2 开发注意事项

1. **数据库迁移**: 新增 AssociationModel 需要更新 Isar schema
2. **双向关联**: 查询时需要同时考虑 sourceIdeaId 和 targetIdeaId
3. **错误处理**: 关系判断失败不应影响主流程
4. **日志记录**: 关键操作记录日志

---

## 七、开发顺序

```
Step 1: 创建 association.dart 实体
Step 2: 创建 association_repository.dart 接口
Step 3: 创建 association_model.dart 数据模型
Step 4: 运行 build_runner 生成代码
Step 5: 创建 association_repository_impl.dart 实现
Step 6: 更新 isar_database.dart
Step 7: 创建 ai_relation_service.dart
Step 8: 更新 ai_task_queue.dart
Step 9: 更新 app_providers.dart
Step 10: 创建单元测试
Step 11: 运行验证
```

---

**文档版本：V1.0**  
**状态：待用户确认**
