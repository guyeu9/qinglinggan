# AI分析逻辑链路梳理与数据操作处理计划

**创建日期**: 2026-03-15
**版本**: V1.0
**状态**: 待用户确认

---

## 一、AI分析完整逻辑链路

### 1.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AITaskQueue (任务队列)                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      _runBasicAnalysis() 执行流程                       │  │
│  │                                                                        │  │
│  │  1. AIUnderstandingService.analyze()                                   │  │
│  │     → 分类、标签、摘要、AI提示语                                          │  │
│  │                                                                        │  │
│  │  2. AIEmbeddingService.generateEmbedding()                             │  │
│  │     → 向量嵌入 (1536维)                                                 │  │
│  │                                                                        │  │
│  │  3. AIEmbeddingService.searchSimilar()                                 │  │
│  │     → 相似灵感检索 (top 5, 阈值 0.3)                                     │  │
│  │                                                                        │  │
│  │  4. AIRelationService.judgeRelations()                                 │  │
│  │     → 关系判断 (相似/互补/演化)                                          │  │
│  │                                                                        │  │
│  │  5. AISynthesisService.generateSynthesis()                             │  │
│  │     → 综合分析 (共同点/差异点/优化版本)                                   │  │
│  │                                                                        │  │
│  │  6. 保存 AIAnalysisEntity                                              │  │
│  │                                                                        │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 任务入队逻辑

**文件**: [ai_task_queue.dart](file:///d:/trae/qinglinggan/light_idea/lib/application/task_queue/ai_task_queue.dart)

```
enqueue(ideaId) 流程:
  │
  ├── 1. 检查是否已有活跃任务 → 如有则跳过
  │
  ├── 2. 检查是否24小时内完成过 → 如有则跳过
  │
  ├── 3. 创建 AITaskEntity (status: pending)
  │
  ├── 4. 加入内存队列
  │
  └── 5. 触发 _processNext()
```

### 1.3 任务处理流程

```
_processNext() 流程:
  │
  ├── 1. 更新状态: TaskStatus.processing, AIStatus.processing
  │
  ├── 2. 执行分析 (带超时 60秒)
  │     └── _runBasicAnalysis(ideaId)
  │
  ├── 3. 成功 → 更新状态: completed
  │
  └── 4. 失败 → 重试机制 (最多3次)
        └── 最终失败 → AIStatus.failed
```

---

## 二、AI提示词完整内容

### 2.1 内容理解服务提示词

**文件**: [ai_understanding_service.dart](file:///d:/trae/qinglinggan/light_idea/lib/application/ai/ai_understanding_service.dart)

**系统提示词**:
```
你是一个专业的内容分析助手。你的任务是分析用户输入的灵感内容，并返回结构化的分析结果。

请根据内容的性质，将其归类到以下三个分类之一：
1. 社交 / 旅行 / 惊喜类 - 社交活动、旅行计划、惊喜创意
2. 工作 / 创意策划类 - 工作任务、创意策划、项目规划
3. 摄影爱好类 - 摄影技巧、爱好记录、影像创作

请生成以下内容：
1. 分类：从上述三个分类中选择最合适的一个
2. 标签：生成3-5个相关标签
3. 摘要：用一句话概括内容核心（不超过50字）
4. AI提示语：基于内容生成一个引导性的问题或建议，帮助用户深入思考

返回JSON格式：
{
  "categoryName": "分类名称",
  "tags": ["标签1", "标签2", "标签3"],
  "summary": "内容摘要",
  "aiHint": "AI提示语"
}
```

**⚠️ 问题发现**: 分类名称硬编码在提示词中，无法动态适应分类变更！

### 2.2 关系判断服务提示词

**文件**: [ai_relation_service.dart](file:///d:/trae/qinglinggan/light_idea/lib/application/ai/ai_relation_service.dart)

**系统提示词**:
```
你是一个灵感关联分析专家。你的任务是分析当前灵感与候选灵感之间的关系。

关系类型说明：
1. similar（相似）：内容相似、主题相近、表达方式类似
2. complementary（互补）：内容互补、可以组合形成更完整的方案
3. evolutionary（演化）：当前灵感是候选灵感的演化、升级或细化版本

返回JSON格式：
{
  "relations": [
    {
      "targetIdeaId": 灵感ID,
      "type": "关系类型",
      "reason": "判断原因",
      "confidence": 置信度(0.0-1.0)
    }
  ]
}
```

### 2.3 综合分析服务提示词

**文件**: [ai_synthesis_service.dart](file:///d:/trae/qinglinggan/light_idea/lib/application/ai/ai_synthesis_service.dart)

**系统提示词**:
```
你是一个灵感综合分析专家。你的任务是基于当前灵感和其关联灵感，生成综合分析结果。

分析要求：
1. 共同点：找出当前灵感与关联灵感之间的共同主题、相似元素或共同目标
2. 差异点：分析当前灵感与关联灵感之间的不同之处、互补特性或独特价值
3. 综合优化版本：基于所有灵感的内容，生成一个融合各方优点的优化版本

返回JSON格式：
{
  "commonPoints": ["共同点1", "共同点2", ...],
  "differences": ["差异点1", "差异点2", ...],
  "mergedIdea": "综合优化版本的灵感内容"
}
```

---

## 三、分类系统分析

### 3.1 当前分类数据

| ID | 分类名称 | 图标 |
|----|----------|------|
| 1 | 社交 / 旅行 / 惊喜类 | 🎉 |
| 2 | 工作 / 创意策划类 | 💼 |
| 3 | 摄影爱好类 | 📷 |

### 3.2 分类匹配逻辑

**文件**: [ai_task_queue.dart](file:///d:/trae/qinglinggan/light_idea/lib/application/task_queue/ai_task_queue.dart) 第172-179行

```dart
int? categoryId;
final categories = await _categoryRepository.getAll();
for (final category in categories) {
  if (category.name == understanding.categoryName) {
    categoryId = category.id;
    break;
  }
}
```

### 3.3 问题分析

**问题1**: 分类名称硬编码在AI提示词中

- 提示词中写死了三个分类名称
- 如果用户添加/修改分类，AI不知道新分类

**问题2**: 分类匹配使用精确字符串匹配

- AI返回的分类名称必须与数据库完全一致
- 名称格式不一致会导致匹配失败

**问题3**: 没有分类管理界面

- 用户无法在设置中管理分类
- 导入时可以自动创建分类，但无法手动管理

---

## 四、数据操作流程分析

### 4.1 新增数据流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              新增灵感流程                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  用户输入内容                                                                 │
│       │                                                                     │
│       ▼                                                                     │
│  home_page.dart: _onSendTap()                                               │
│       │                                                                     │
│       ▼                                                                     │
│  home_provider.dart: saveIdea()                                             │
│       │                                                                     │
│       ├── 1. 创建 IdeaEntity (aiStatus: pending)                            │
│       ├── 2. IdeaRepository.save() → 保存到数据库                            │
│       ├── 3. 更新状态: isAnalyzing = true                                    │
│       ├── 4. 刷新灵感列表                                                    │
│       └── 5. AITaskQueue.enqueue(ideaId)                                    │
│              │                                                              │
│              ▼                                                              │
│       AI分析流程 (见1.1架构图)                                                │
│              │                                                              │
│              ▼                                                              │
│       保存 AIAnalysisEntity                                                 │
│              │                                                              │
│              ▼                                                              │
│       home_provider.dart: _pollAnalysisResult()                             │
│              │                                                              │
│              └── 轮询获取结果，更新 lastAnalysis                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 删除数据流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              删除灵感流程                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  用户点击删除                                                                 │
│       │                                                                     │
│       ▼                                                                     │
│  idea_detail_page.dart: _deleteIdea()                                       │
│       │                                                                     │
│       ▼                                                                     │
│  idea_detail_provider.dart: deleteIdea()                                    │
│       │                                                                     │
│       ▼                                                                     │
│  IdeaRepository.softDelete(id)                                              │
│       │                                                                     │
│       └── 设置 isDeleted = true, deletedAt = now                            │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  ❌ 问题：未清理关联数据                                               │    │
│  │                                                                      │    │
│  │  以下数据会残留：                                                      │    │
│  │  - AssociationEntity (关联数据)                                       │    │
│  │  - AIAnalysisEntity (AI分析结果)                                      │    │
│  │  - AITaskEntity (AI任务)                                              │    │
│  │  - TagEntity (标签，如果仅被此灵感使用)                                 │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  永久删除流程:                                                               │
│       │                                                                     │
│       ▼                                                                     │
│  IdeaRepository.permanentDelete(id)                                         │
│       │                                                                     │
│       └── 从数据库彻底删除                                                   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  ❌ 同样问题：未清理关联数据                                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 导入数据流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              导入数据流程                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  选择文件 (.xlsx / .json)                                                    │
│       │                                                                     │
│       ▼                                                                     │
│  import_service.dart: importFromExcel() / importFromJson()                  │
│       │                                                                     │
│       ▼                                                                     │
│  _processImportData()                                                       │
│       │                                                                     │
│       ├── 1. 验证内容 (非空检查)                                             │
│       │                                                                     │
│       ├── 2. 检查冲突 (ID是否存在)                                           │
│       │       │                                                             │
│       │       ├── skip → 跳过                                               │
│       │       ├── overwrite → 覆盖                                          │
│       │       └── merge → 合并                                              │
│       │                                                                     │
│       ├── 3. 处理分类                                                        │
│       │       │                                                             │
│       │       └── _getOrCreateCategoryId(categoryName)                      │
│       │              │                                                      │
│       │              ├── 分类存在 → 返回ID                                   │
│       │              └── 分类不存在 → 创建新分类                              │
│       │                                                                     │
│       ├── 4. 处理标签                                                        │
│       │       │                                                             │
│       │       └── TagRepository.saveIfNotExists(tagName)                    │
│       │              │                                                      │
│       │              └── 标签不存在则创建                                    │
│       │                                                                     │
│       ├── 5. 创建 IdeaEntity (aiStatus: pending)                            │
│       │                                                                     │
│       ├── 6. IdeaRepository.save()                                          │
│       │                                                                     │
│       └── 7. AITaskQueue.enqueue() (如果 triggerAIAnalysis = true)          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 五、发现的问题清单

### 5.1 严重问题

| 序号 | 问题 | 影响 | 优先级 |
|------|------|------|--------|
| 1 | 删除灵感时未清理关联数据 | 数据残留，占用存储空间 | P0 |
| 2 | 分类名称硬编码在提示词中 | 无法动态添加/修改分类 | P0 |
| 3 | 分类匹配使用精确字符串 | 格式不一致导致匹配失败 | P1 |

### 5.2 中等问题

| 序号 | 问题 | 影响 | 优先级 |
|------|------|------|--------|
| 4 | 没有分类管理界面 | 用户无法管理分类 | P1 |
| 5 | AI提示词无法动态更新 | 分类变更后AI不知道 | P1 |
| 6 | 标签未清理 | 孤立标签累积 | P2 |

### 5.3 低优先级问题

| 序号 | 问题 | 影响 | 优先级 |
|------|------|------|--------|
| 7 | 任务队列无持久化 | 应用重启后任务丢失 | P2 |
| 8 | 无AI分析重试入口 | 失败后无法手动重试 | P2 |

---

## 六、修复方案

### 6.1 P0-1: 删除灵感时清理关联数据

**修改文件**: `lib/application/usecases/delete_idea.dart`

```dart
Future<Result<void>> execute(int id, {bool permanent = false}) async {
  final existingIdea = await _ideaRepository.getById(id);
  if (existingIdea == null) {
    return Result.error('灵感不存在');
  }

  // 清理关联数据
  await _associationRepository.deleteByIdeaId(id);
  await _analysisRepository.deleteByIdeaId(id);
  await _taskRepository.deleteByIdeaId(id);

  if (permanent) {
    await _ideaRepository.permanentDelete(id);
  } else {
    await _ideaRepository.softDelete(id);
  }

  return Result.success(null);
}
```

### 6.2 P0-2: 动态分类提示词

**修改文件**: `lib/application/ai/ai_understanding_service.dart`

```dart
Future<Result<UnderstandingOutput>> analyze(String content) async {
  // 动态获取分类列表
  final categories = await _categoryRepository.getAll();
  final categoryNames = categories.map((c) => c.name).toList();
  
  final systemPrompt = _buildSystemPrompt(categoryNames);
  // ...
}

String _buildSystemPrompt(List<String> categoryNames) {
  final categoryList = categoryNames.asMap().entries.map((e) {
    return '${e.key + 1}. ${e.value}';
  }).join('\n');
  
  return '''你是一个专业的内容分析助手。你的任务是分析用户输入的灵感内容，并返回结构化的分析结果。

请根据内容的性质，将其归类到以下分类之一：
$categoryList

请生成以下内容：
1. 分类：从上述分类中选择最合适的一个（返回完整的分类名称）
2. 标签：生成3-5个相关标签
3. 摘要：用一句话概括内容核心（不超过50字）
4. AI提示语：基于内容生成一个引导性的问题或建议，帮助用户深入思考

返回JSON格式：
{
  "categoryName": "分类名称",
  "tags": ["标签1", "标签2", "标签3"],
  "summary": "内容摘要",
  "aiHint": "AI提示语"
}''';
}
```

### 6.3 P1-1: 分类管理界面

**新增文件**: `lib/presentation/pages/settings/category_management_page.dart`

功能：
- 显示所有分类列表
- 添加新分类
- 编辑分类名称和图标
- 删除分类（检查是否有关联灵感）

### 6.4 P1-2: 分类匹配优化

**修改文件**: `lib/application/task_queue/ai_task_queue.dart`

```dart
int? categoryId;
final categories = await _categoryRepository.getAll();

// 模糊匹配
for (final category in categories) {
  if (category.name == understanding.categoryName) {
    categoryId = category.id;
    break;
  }
  // 包含匹配
  if (category.name.contains(understanding.categoryName) ||
      understanding.categoryName.contains(category.name)) {
    categoryId = category.id;
    break;
  }
}

// 如果没有匹配，使用默认分类或创建新分类
if (categoryId == null && understanding.categoryName.isNotEmpty) {
  final newCategory = await _categoryRepository.save(
    CategoryEntity(
      id: 0,
      name: understanding.categoryName,
      icon: 'folder',
      sortOrder: categories.length,
      createdAt: DateTime.now(),
    ),
  );
  categoryId = newCategory.id;
}
```

---

## 七、验证方案

### 7.1 功能验证

| 验证项 | 验证方法 |
|--------|----------|
| 删除清理关联数据 | 删除灵感后检查数据库无残留 |
| 动态分类提示词 | 添加新分类后AI能识别 |
| 分类匹配优化 | AI返回不完全匹配的分类名也能关联 |
| 分类管理界面 | 能添加/编辑/删除分类 |

### 7.2 代码质量验证

| 验证项 | 命令 |
|--------|------|
| 代码分析 | `flutter analyze` 无错误 |
| 单元测试 | `flutter test` 全部通过 |

---

## 八、执行顺序

### 第一批（P0 严重问题）

1. 修改 `DeleteIdeaUseCase` 添加关联数据清理
2. 修改 `AIUnderstandingService` 动态生成提示词
3. 运行测试验证

### 第二批（P1 中等问题）

4. 优化分类匹配逻辑
5. 创建分类管理界面
6. 运行测试验证

---

## 九、数据流完整图示

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              新增灵感流程（修复后）                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  用户输入 → CreateIdeaUseCase → IdeaRepository.save()                        │
│          → HomeProvider.saveIdea() → AITaskQueue.enqueue()                   │
│          → AIUnderstandingService.analyze() [动态分类提示词]                   │
│          → 分类匹配 [模糊匹配+自动创建]                                        │
│          → AIEmbeddingService → AIRelationService → AISynthesisService       │
│          → AIAnalysisRepository.save()                                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              删除灵感流程（修复后）                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  用户操作 → DeleteIdeaUseCase.execute(id)                                    │
│          → AssociationRepository.deleteByIdeaId(id) ✅                       │
│          → AIAnalysisRepository.deleteByIdeaId(id) ✅                        │
│          → AITaskRepository.deleteByIdeaId(id) ✅                            │
│          → IdeaRepository.softDelete() / permanentDelete()                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              导入数据流程（修复后）                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  选择文件 → ImportService.import()                                            │
│          → _processImportData()                                              │
│          → 分类处理: _getOrCreateCategoryId() [支持新分类]                    │
│          → 标签处理: saveIfNotExists()                                        │
│          → IdeaRepository.save()                                             │
│          → AITaskQueue.enqueue() [动态分类提示词]                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

**文档版本**: V1.0
**创建时间**: 2026-03-15
**状态**: 待用户确认
