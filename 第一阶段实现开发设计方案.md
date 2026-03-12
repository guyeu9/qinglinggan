# 《轻灵感》第一阶段开发计划：基础架构搭建与记录功能实现

**版本：V1.1（优化版）**  
**基于：轻灵感开发设计文档_新方案版.md**

---

## 一、任务概述

根据 `轻灵感开发设计文档_新方案版.md` 的架构设计，实施第一阶段开发任务：
- 基础架构构建
- 数据库初始化（Isar + 三大分类）
- 记录功能核心业务逻辑

**注意**：本次任务不包含前端页面开发，仅专注于后端基础架构实现。

---

## 二、技术选型核对与优化

### 2.1 核心技术栈确认

| 层级 | 技术 | 版本要求 | 备注 |
|------|------|----------|------|
| 框架 | Flutter | 3.22+ | 跨平台UI |
| 语言 | Dart | 3.4+ | 应用开发 |
| 状态管理 | Riverpod | 2.5+ | 响应式状态 |
| 本地数据库 | Isar | 3.1.0+1 | 结构化存储 |
| 网络请求 | Dio | 5.4+ | HTTP请求 |
| 路由 | go_router | 14.0+ | 声明式路由 |
| 工具 | uuid, path_provider, intl | 最新稳定版 | 辅助工具 |

### 2.2 依赖版本优化（兼容性问题）

```yaml
# pubspec.yaml - 最终版本
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # 本地数据库（重要：Isar 3.1.x 系列）
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  
  # 网络请求
  dio: ^5.4.3+1
  
  # 路由
  go_router: ^14.2.0
  
  # 工具
  uuid: ^4.4.0
  path_provider: ^2.1.3
  intl: ^0.19.0
  logger: ^2.3.0
  
  # 文件操作
  file_picker: ^8.0.3
  
  # Excel 导入导出
  excel: ^4.0.3
  syncfusion_flutter_xlsio: ^25.2.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2
  build_runner: ^2.4.9
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.0
  json_serializable: ^6.8.0
  mockito: ^5.4.4
```

### 2.3 架构设计核对

根据设计文档，采用**四层架构**，层间单向依赖：

```
Presentation Layer (UI + Riverpod Providers)
        ↓
Application Layer (UseCases + Services + AI Task Queue)
        ↓
Domain Layer (Entities + Repository 接口)
        ↓
Data Layer (Isar Models + Repository 实现)
```

---

## 三、实施步骤（详细版）

### 阶段 1：项目初始化与基础架构

#### 1.1 创建 Flutter 项目

```bash
flutter create light_idea --org com.lightidea
# 项目名称：light_idea
# 组织标识：com.lightidea
```

#### 1.2 配置 pubspec.yaml

将上述优化后的依赖配置添加到 `pubspec.yaml`

#### 1.3 建立目录结构（完全匹配设计文档）

```
lib/
├── main.dart                              # 应用入口
├── app.dart                               # MaterialApp 配置
│
├── core/                                  # 核心工具
│   ├── constants/
│   │   └── app_constants.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── text_helper.dart
│   │   └── vector_math.dart               # 向量计算工具
│   ├── logger/
│   │   └── app_logger.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── extensions/
│       └── context_extensions.dart
│
├── config/                                # 全局配置
│   ├── routes.dart                        # 路由定义
│   └── ai_config.dart                    # AI 配置
│
├── domain/                                # 领域层（纯业务逻辑）
│   ├── entities/                          # 业务实体（不依赖框架）
│   │   ├── idea.dart
│   │   ├── category.dart
│   │   ├── tag.dart
│   │   ├── ai_analysis.dart
│   │   ├── association.dart
│   │   └── ai_task.dart
│   │
│   └── repositories/                      # 仓库接口（抽象）
│       ├── idea_repository.dart
│       ├── category_repository.dart
│       ├── tag_repository.dart
│       ├── ai_analysis_repository.dart
│       ├── association_repository.dart
│       └── ai_task_repository.dart
│
├── data/                                  # 数据层（具体实现）
│   ├── database/
│   │   ├── isar_database.dart             # Isar 初始化
│   │   └── seed_data.dart                 # 初始数据
│   │
│   ├── models/                            # Isar Schema（数据模型）
│   │   ├── idea_model.dart
│   │   ├── category_model.dart
│   │   ├── tag_model.dart
│   │   ├── ai_analysis_model.dart
│   │   ├── association_model.dart
│   │   └── ai_task_model.dart
│   │
│   ├── repositories/                      # 仓库实现
│   │   ├── idea_repository_impl.dart
│   │   ├── category_repository_impl.dart
│   │   ├── tag_repository_impl.dart
│   │   ├── ai_analysis_repository_impl.dart
│   │   ├── association_repository_impl.dart
│   │   └── ai_task_repository_impl.dart
│   │
│   └── api/                               # 外部 API
│       ├── openai_client.dart
│       └── api_models.dart
│
├── application/                           # 应用层（业务编排）
│   ├── usecases/                          # 用例（单一职责）
│   │   ├── create_idea.dart
│   │   ├── update_idea.dart
│   │   ├── delete_idea.dart
│   │   ├── restore_idea.dart
│   │   ├── reanalyze_idea.dart
│   │   ├── export_ideas.dart
│   │   └── import_ideas.dart
│   │
│   ├── services/                          # 业务服务
│   │   ├── idea_service.dart
│   │   ├── category_service.dart
│   │   ├── export_service.dart
│   │   └── import_service.dart
│   │
│   ├── ai/                                # AI 服务模块
│   │   ├── ai_understanding_service.dart
│   │   ├── ai_embedding_service.dart
│   │   ├── ai_relation_service.dart
│   │   ├── ai_analysis_service.dart
│   │   └── ai_chat_service.dart
│   │
│   └── task_queue/                        # 本地任务队列
│       ├── ai_task_queue.dart
│       ├── ai_task_processor.dart
│       └── task_status.dart
│
└── presentation/                          # 展示层（本阶段暂不实现）
    ├── providers/
    ├── pages/
    └── widgets/
```

---

### 阶段 2：Domain 层实现

#### 2.1 业务实体定义（完全匹配设计文档）

**IdeaEntity**
```dart
// lib/domain/entities/idea.dart
class IdeaEntity {
  final int id;
  final String content;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final AIStatus aiStatus;
  final List<int> tagIds;
  final List<double>? embedding;
  
  const IdeaEntity({
    required this.id,
    required this.content,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isDeleted = false,
    this.aiStatus = AIStatus.pending,
    this.tagIds = const [],
    this.embedding,
  });
  
  IdeaEntity copyWith({
    int? id,
    String? content,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDeleted,
    AIStatus? aiStatus,
    List<int>? tagIds,
    List<double>? embedding,
  }) {
    return IdeaEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      aiStatus: aiStatus ?? this.aiStatus,
      tagIds: tagIds ?? this.tagIds,
      embedding: embedding ?? this.embedding,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdeaEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content;
  
  @override
  int get hashCode => id.hashCode ^ content.hashCode;
}

enum AIStatus { pending, processing, completed, failed }
```

**CategoryEntity**
```dart
// lib/domain/entities/category.dart
class CategoryEntity {
  final int id;
  final String name;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;
  
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.sortOrder,
    required this.createdAt,
  });
  
  CategoryEntity copyWith({
    int? id,
    String? name,
    String? icon,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

**TagEntity**
```dart
// lib/domain/entities/tag.dart
class TagEntity {
  final int id;
  final String name;
  final DateTime createdAt;
  
  const TagEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  
  TagEntity copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

#### 2.2 仓库接口定义

**IdeaRepository**
```dart
// lib/domain/repositories/idea_repository.dart
abstract class IdeaRepository {
  Future<IdeaEntity> save(IdeaEntity idea);
  Future<IdeaEntity?> getById(int id);
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false});
  Future<List<IdeaEntity>> getByCategory(int categoryId);
  Future<List<IdeaEntity>> getByPage(int offset, int limit);
  Future<int> count({bool includeDeleted = false});
  Future<void> update(IdeaEntity idea);
  Future<void> updateAIStatus(int id, AIStatus status);
  Future<void> updateEmbedding(int id, List<double> embedding);
  Future<void> softDelete(int id);
  Future<void> restore(int id);
  Future<void> permanentDelete(int id);
  Future<List<IdeaEntity>> searchByContent(String keyword);
}
```

**CategoryRepository**
```dart
// lib/domain/repositories/category_repository.dart
abstract class CategoryRepository {
  Future<CategoryEntity?> getById(int id);
  Future<CategoryEntity?> getByName(String name);
  Future<List<CategoryEntity>> getAll();
  Future<CategoryEntity> save(CategoryEntity category);
  Future<void> update(CategoryEntity category);
}
```

**TagRepository**
```dart
// lib/domain/repositories/tag_repository.dart
abstract class TagRepository {
  Future<TagEntity?> getById(int id);
  Future<TagEntity?> getByName(String name);
  Future<List<TagEntity>> getAll();
  Future<List<TagEntity>> getByIds(List<int> ids);
  Future<TagEntity> save(TagEntity tag);
  Future<List<TagEntity>> saveAll(List<String> names);
  Future<TagEntity> saveIfNotExists(String name);
}
```

---

### 阶段 3：Data 层实现

#### 3.1 Isar 数据模型（完全匹配设计文档）

**IdeaModel**
```dart
// lib/data/models/idea_model.dart
import 'package:isar/isar.dart';

part 'idea_model.g.dart';

@collection
class IdeaModel {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  late String content;
  
  @Index()
  int? categoryId;
  
  @Index()
  DateTime createdAt = DateTime.now();
  
  DateTime updatedAt = DateTime.now();
  
  DateTime? deletedAt;
  
  @Index()
  bool isDeleted = false;
  
  @Index()
  @Enumerated(EnumType.name)
  AIStatus aiStatus = AIStatus.pending;
  
  List<double>? embedding;
  
  List<int> tagIds = [];
  
  IdeaEntity toEntity() {
    return IdeaEntity(
      id: id,
      content: content,
      categoryId: categoryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      isDeleted: isDeleted,
      aiStatus: aiStatus,
      tagIds: tagIds,
      embedding: embedding,
    );
  }
  
  static IdeaModel fromEntity(IdeaEntity entity) {
    return IdeaModel()
      ..id = entity.id
      ..content = entity.content
      ..categoryId = entity.categoryId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..deletedAt = entity.deletedAt
      ..isDeleted = entity.isDeleted
      ..aiStatus = entity.aiStatus
      ..tagIds = entity.tagIds
      ..embedding = entity.embedding;
  }
}

enum AIStatus { pending, processing, completed, failed }
```

**CategoryModel**
```dart
// lib/data/models/category_model.dart
import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String name;
  
  late String icon;
  
  late int sortOrder;
  
  DateTime createdAt = DateTime.now();
  
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }
  
  static CategoryModel fromEntity(CategoryEntity entity) {
    return CategoryModel()
      ..id = entity.id
      ..name = entity.name
      ..icon = entity.icon
      ..sortOrder = entity.sortOrder
      ..createdAt = entity.createdAt;
  }
}
```

**TagModel**
```dart
// lib/data/models/tag_model.dart
import 'package:isar/isartag_model.g.dart.dart';

part '';

@collection
class TagModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String name;
  
  DateTime createdAt = DateTime.now();
  
  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }
  
  static TagModel fromEntity(TagEntity entity) {
    return TagModel()
      ..id = entity.id
      ..name = entity.name
      ..createdAt = entity.createdAt;
  }
}
```

#### 3.2 Isar 数据库初始化

**isar_database.dart**
```dart
// lib/data/database/isar_database.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/idea_model.dart';
import '../models/category_model.dart';
import '../models/tag_model.dart';

class IsarDatabase {
  static Isar? _instance;
  
  static Future<Isar> initialize() async {
    if (_instance != null && _instance!.isOpen) {
      return _instance!;
    }
    
    final dir = await getApplicationDocumentsDirectory();
    
    _instance = await Isar.open(
      [
        IdeaModelSchema,
        CategoryModelSchema,
        TagModelSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
      name: 'light_idea_db',
    );
    
    return _instance!;
  }
  
  static Isar get instance {
    if (_instance == null || !_instance!.isOpen) {
      throw StateError('Isar not initialized. Call IsarDatabase.initialize() first.');
    }
    return _instance!;
  }
  
  static Future<void> close() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
    }
  }
  
  static Future<void> clear() async {
    await instance.writeTxn(() async {
      await instance.clear();
    });
  }
}
```

#### 3.3 种子数据（三大分类）

**seed_data.dart**
```dart
// lib/data/database/seed_data.dart
import 'package:isar/isar.dart';
import '../models/category_model.dart';

class SeedData {
  static Future<void> initializeDefaultCategories(Isar isar) async {
    final existingCount = await isar.categoryModels.count();
    if (existingCount > 0) {
      return;
    }
    
    final categories = [
      CategoryModel()
        ..name = '灵感想法'
        ..icon = '💡'
        ..sortOrder = 0,
      CategoryModel()
        ..name = '待办事项'
        ..icon = '📋'
        ..sortOrder = 1,
      CategoryModel()
        ..name = '学习笔记'
        ..icon = '📚'
        ..sortOrder = 2,
    ];
    
    await isar.writeTxn(() async {
      await isar.categoryModels.putAll(categories);
    });
  }
  
  static Future<void> initialize(Isar isar) async {
    await initializeDefaultCategories(isar);
  }
}
```

#### 3.4 仓库实现

**IdeaRepositoryImpl**（完整CRUD实现）
```dart
// lib/data/repositories/idea_repository_impl.dart
import 'package:isar/isar.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import '../models/idea_model.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  final Isar _isar;
  
  IdeaRepositoryImpl(this._isar);
  
  @override
  Future<IdeaEntity> save(IdeaEntity idea) async {
    final model = IdeaModel.fromEntity(idea);
    final id = await _isar.writeTxn(() => _isar.ideaModels.put(model));
    return idea.copyWith(id: id);
  }
  
  @override
  Future<IdeaEntity?> getById(int id) async {
    final model = await _isar.ideaModels.get(id);
    return model?.toEntity();
  }
  
  @override
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false}) async {
    final query = includeDeleted
        ? _isar.ideaModels.where().sortByCreatedAtDesc()
        : _isar.ideaModels.filter().isDeletedEqualTo(false).sortByCreatedAtDesc();
    
    final models = await query.findAll();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<IdeaEntity>> getByCategory(int categoryId) async {
    final models = await _isar.ideaModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<IdeaEntity>> getByPage(int offset, int limit) async {
    final models = await _isar.ideaModels
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<int> count({bool includeDeleted = false}) async {
    if (includeDeleted) {
      return _isar.ideaModels.count();
    }
    return _isar.ideaModels.filter().isDeletedEqualTo(false).count();
  }
  
  @override
  Future<void> update(IdeaEntity idea) async {
    final model = IdeaModel.fromEntity(idea)..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.ideaModels.put(model));
  }
  
  @override
  Future<void> updateAIStatus(int id, AIStatus status) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.aiStatus = status;
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }
  
  @override
  Future<void> updateEmbedding(int id, List<double> embedding) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.embedding = embedding;
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }
  
  @override
  Future<void> softDelete(int id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.isDeleted = true;
        model.deletedAt = DateTime.now();
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }
  
  @override
  Future<void> restore(int id) async {
    await _isar.writeTxn(() async {
      final model = await _isar.ideaModels.get(id);
      if (model != null) {
        model.isDeleted = false;
        model.deletedAt = null;
        model.updatedAt = DateTime.now();
        await _isar.ideaModels.put(model);
      }
    });
  }
  
  @override
  Future<void> permanentDelete(int id) async {
    await _isar.writeTxn(() => _isar.ideaModels.delete(id));
  }
  
  @override
  Future<List<IdeaEntity>> searchByContent(String keyword) async {
    final models = await _isar.ideaModels
        .filter()
        .isDeletedEqualTo(false)
        .contentContains(keyword)
        .sortByCreatedAtDesc()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

**CategoryRepositoryImpl**
```dart
// lib/data/repositories/category_repository_impl.dart
import 'package:isar/isar.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final Isar _isar;
  
  CategoryRepositoryImpl(this._isar);
  
  @override
  Future<CategoryEntity?> getById(int id) async {
    final model = await _isar.categoryModels.get(id);
    return model?.toEntity();
  }
  
  @override
  Future<CategoryEntity?> getByName(String name) async {
    final model = await _isar.categoryModels.filter().nameEqualTo(name).findFirst();
    return model?.toEntity();
  }
  
  @override
  Future<List<CategoryEntity>> getAll() async {
    final models = await _isar.categoryModels.where().sortBySortOrder().findAll();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<CategoryEntity> save(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    final id = await _isar.writeTxn(() => _isar.categoryModels.put(model));
    return category.copyWith(id: id);
  }
  
  @override
  Future<void> update(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _isar.writeTxn(() => _isar.categoryModels.put(model));
  }
}
```

**TagRepositoryImpl**
```dart
// lib/data/repositories/tag_repository_impl.dart
import 'package:isar/isar.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final Isar _isar;
  
  TagRepositoryImpl(this._isar);
  
  @override
  Future<TagEntity?> getById(int id) async {
    final model = await _isar.tagModels.get(id);
    return model?.toEntity();
  }
  
  @override
  Future<TagEntity?> getByName(String name) async {
    final model = await _isar.tagModels.filter().nameEqualTo(name).findFirst();
    return model?.toEntity();
  }
  
  @override
  Future<List<TagEntity>> getAll() async {
    final models = await _isar.tagModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<TagEntity>> getByIds(List<int> ids) async {
    final models = await _isar.tagModels.getAll(ids).cast<TagModel?>().whereType<TagModel>().toList();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<TagEntity> save(TagEntity tag) async {
    final model = TagModel.fromEntity(tag);
    final id = await _isar.writeTxn(() => _isar.tagModels.put(model));
    return tag.copyWith(id: id);
  }
  
  @override
  Future<List<TagEntity>> saveAll(List<String> names) async {
    final tags = <TagEntity>[];
    await _isar.writeTxn(() async {
      for (final name in names) {
        final existing = await _isar.tagModels.filter().nameEqualTo(name).findFirst();
        if (existing != null) {
          tags.add(existing.toEntity());
        } else {
          final model = TagModel()
            ..name = name
            ..createdAt = DateTime.now();
          final id = await _isar.tagModels.put(model);
          tags.add(model.toEntity());
        }
      }
    });
    return tags;
  }
  
  @override
  Future<TagEntity> saveIfNotExists(String name) async {
    final existing = await getByName(name);
    if (existing != null) return existing;
    
    return save(TagEntity(
      id: 0,
      name: name,
      createdAt: DateTime.now(),
    ));
  }
}
```

---

### 阶段 4：Application 层实现

#### 4.1 结果封装类

**result.dart**
```dart
// lib/core/utils/result.dart
sealed class Result<T> {
  const Result();
  
  factory Result.success(T data) = Success<T>;
  factory Result.error(String message, [Object? error]) = Error<T>;
  
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
  
  T? get data => this is Success<T> ? (this as Success<T>).data : null;
  String? get errorMessage => this is Error<T> ? (this as Error<T>).message : null;
  
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error) error,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Error<T>(:final message, :final error) => error(message, error),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final String message;
  final Object? error;
  const Error(this.message, [this.error]);
}
```

#### 4.2 创建灵感用例

**create_idea.dart**
```dart
// lib/application/usecases/create_idea.dart
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import '../../core/utils/result.dart';
import '../../core/logger/app_logger.dart';
import '../../core/constants/app_constants.dart';

class CreateIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;
  
  CreateIdeaUseCase(this._ideaRepository, this._logger);
  
  Future<Result<IdeaEntity>> execute(String content) async {
    // 1. 数据验证
    if (content.trim().isEmpty) {
      _logger.warning('创建灵感失败: 内容为空');
      return Result.error('内容不能为空');
    }
    
    if (content.length > AppConstants.maxContentLength) {
      _logger.warning('创建灵感失败: 内容超长 (${content.length} > ${AppConstants.maxContentLength})');
      return Result.error('内容长度不能超过${AppConstants.maxContentLength}字符');
    }
    
    try {
      // 2. 创建实体
      final now = DateTime.now();
      final idea = IdeaEntity(
        id: 0,
        content: content.trim(),
        createdAt: now,
        updatedAt: now,
        aiStatus: AIStatus.pending,
      );
      
      // 3. 保存到数据库
      final savedIdea = await _ideaRepository.save(idea);
      
      _logger.info('灵感创建成功: id=${savedIdea.id}');
      
      return Result.success(savedIdea);
    } catch (e, st) {
      _logger.error('创建灵感失败', error: e);
      return Result.error('保存失败: ${e.toString()}', e);
    }
  }
}
```

#### 4.3 更新灵感用例

**update_idea.dart**
```dart
// lib/application/usecases/update_idea.dart
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import '../../core/utils/result.dart';
import '../../core/logger/app_logger.dart';
import '../../core/constants/app_constants.dart';

class UpdateIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;
  
  UpdateIdeaUseCase(this._ideaRepository, this._logger);
  
  Future<Result<IdeaEntity>> execute(int id, String newContent) async {
    // 1. 数据验证
    if (newContent.trim().isEmpty) {
      return Result.error('内容不能为空');
    }
    
    if (newContent.length > AppConstants.maxContentLength) {
      return Result.error('内容长度不能超过${AppConstants.maxContentLength}字符');
    }
    
    try {
      // 2. 获取现有灵感
      final existingIdea = await _ideaRepository.getById(id);
      if (existingIdea == null) {
        return Result.error('灵感不存在');
      }
      
      if (existingIdea.isDeleted) {
        return Result.error('无法更新已删除的灵感');
      }
      
      // 3. 更新实体
      final updatedIdea = existingIdea.copyWith(
        content: newContent.trim(),
        updatedAt: DateTime.now(),
        aiStatus: AIStatus.pending, // 内容修改后需要重新AI分析
      );
      
      await _ideaRepository.update(updatedIdea);
      
      _logger.info('灵感更新成功: id=$id');
      
      return Result.success(updatedIdea);
    } catch (e) {
      _logger.error('更新灵感失败: id=$id', error: e);
      return Result.error('更新失败: ${e.toString()}', e);
    }
  }
}
```

#### 4.4 删除灵感用例

**delete_idea.dart**
```dart
// lib/application/usecases/delete_idea.dart
import '../../domain/repositories/idea_repository.dart';
import '../../core/utils/result.dart';
import '../../core/logger/app_logger.dart';

class DeleteIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;
  
  DeleteIdeaUseCase(this._ideaRepository, this._logger);
  
  Future<Result<void>> execute(int id, {bool permanent = false}) async {
    try {
      final existingIdea = await _ideaRepository.getById(id);
      if (existingIdea == null) {
        return Result.error('灵感不存在');
      }
      
      if (permanent) {
        await _ideaRepository.permanentDelete(id);
        _logger.info('灵感永久删除成功: id=$id');
      } else {
        await _ideaRepository.softDelete(id);
        _logger.info('灵感软删除成功: id=$id');
      }
      
      return Result.success(null);
    } catch (e) {
      _logger.error('删除灵感失败: id=$id', error: e);
      return Result.error('删除失败: ${e.toString()}', e);
    }
  }
}
```

#### 4.5 恢复灵感用例

**restore_idea.dart**
```dart
// lib/application/usecases/restore_idea.dart
import '../../domain/repositories/idea_repository.dart';
import '../../core/utils/result.dart';
import '../../core/logger/app_logger.dart';

class RestoreIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;
  
  RestoreIdeaUseCase(this._ideaRepository, this._logger);
  
  Future<Result<void>> execute(int id) async {
    try {
      final existingIdea = await _ideaRepository.getById(id);
      if (existingIdea == null) {
        return Result.error('灵感不存在');
      }
      
      if (!existingIdea.isDeleted) {
        return Result.error('灵感未被删除，无需恢复');
      }
      
      await _ideaRepository.restore(id);
      _logger.info('灵感恢复成功: id=$id');
      
      return Result.success(null);
    } catch (e) {
      _logger.error('恢复灵感失败: id=$id', error: e);
      return Result.error('恢复失败: ${e.toString()}', e);
    }
  }
}
```

---

### 阶段 5：Core 层工具实现

#### 5.1 常量定义

**app_constants.dart**
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();
  
  static const String appName = '轻灵感';
  static const String appVersion = '1.0.0';
  
  // 内容限制
  static const int maxContentLength = 10000;
  static const int minContentLength = 1;
  
  // 分页
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // AI 配置
  static const int embeddingDimension = 1536;
  static const int maxTagCount = 10;
  static const double similarityThreshold = 0.3;
  static const int maxCandidates = 10;
  
  // 任务队列
  static const int maxRetryCount = 3;
  static const int taskTimeoutSeconds = 120;
}
```

#### 5.2 日志工具

**app_logger.dart**
```dart
// lib/core/logger/app_logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();
  
  static final AppLogger _instance = AppLogger._internal();
  static AppLogger get instance => _instance;
  
  AppLogger._internal() {
    Logger.root.level = Level.verbose;
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );
  }
  
  late final Logger _logger;
  
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.v(message, error, stackTrace);
  }
  
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }
  
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error, stackTrace);
  }
  
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(message, error, stackTrace);
  }
  
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }
  
  void wtf(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.wtf(message, error, stackTrace);
  }
}
```

#### 5.3 日期格式化

**date_formatter.dart**
```dart
// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();
  
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }
  
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }
  
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }
  
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inSeconds < 60) {
      return '刚刚';
    }
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    }
    
    if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    }
    
    if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    }
    
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}周前';
    }
    
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '${months}个月前';
    }
    
    return formatDate(dateTime);
  }
  
  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (date == today) {
      return formatTime(dateTime);
    }
    
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == yesterday) {
      return '昨天 ${formatTime(dateTime)}';
    }
    
    return formatDateTime(dateTime);
  }
}
```

#### 5.4 文本工具

**text_helper.dart**
```dart
// lib/core/utils/text_helper.dart
class TextHelper {
  TextHelper._();
  
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }
  
  static String truncateByChars(String text, int maxChars, {String suffix = '...'}) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}$suffix';
  }
  
  static bool isValidContent(String? content) {
    if (content == null) return false;
    final trimmed = content.trim();
    return trimmed.isNotEmpty && trimmed.length <= 10000;
  }
  
  static String normalizeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
  
  static int countChineseChars(String text) {
    return RegExp(r'[\u4e00-\u9fa5]').allMatches(text).length;
  }
  
  static int calculateReadingTime(String text) {
    final wordsPerMinute = 200;
    final chineseChars = countChineseChars(text);
    final otherChars = text.length - chineseChars;
    final totalWords = chineseChars + (otherChars / 2).round();
    return (totalWords / wordsPerMinute).ceil();
  }
}
```

---

### 阶段 6：单元测试

#### 6.1 测试目录结构

```
test/
├── core/
│   └── utils/
│       ├── date_formatter_test.dart
│       ├── text_helper_test.dart
│       └── result_test.dart
├── domain/
│   └── entities/
│       ├── idea_entity_test.dart
│       └── category_entity_test.dart
├── data/
│   └── repositories/
│       ├── idea_repository_test.dart
│       ├── category_repository_test.dart
│       └── tag_repository_test.dart
└── application/
    └── usecases/
        ├── create_idea_test.dart
        ├── update_idea_test.dart
        ├── delete_idea_test.dart
        └── restore_idea_test.dart
```

#### 6.2 核心测试用例示例

**create_idea_test.dart**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/application/usecases/create_idea.dart';
import 'package:light_idea/domain/entities/idea.dart';
import 'package:light_idea/domain/repositories/idea_repository.dart';
import 'package:light_idea/core/utils/result.dart';
import 'package:light_idea/core/logger/app_logger.dart';

class MockIdeaRepository implements IdeaRepository {
  IdeaEntity? savedIdea;
  
  @override
  Future<IdeaEntity> save(IdeaEntity idea) async {
    savedIdea = idea.copyWith(id: 1);
    return savedIdea!;
  }
  
  // 实现其他接口...
}

void main() {
  group('CreateIdeaUseCase', () {
    late CreateIdeaUseCase useCase;
    late MockIdeaRepository mockRepository;
    late AppLogger logger;
    
    setUp(() {
      mockRepository = MockIdeaRepository();
      logger = AppLogger.instance;
      useCase = CreateIdeaUseCase(mockRepository, logger);
    });
    
    test('应该成功创建有效内容的灵感', () async {
      const content = '这是一个测试灵感内容';
      
      final result = await useCase.execute(content);
      
      expect(result.isSuccess, true);
      expect(result.data?.content, content);
      expect(mockRepository.savedIdea, isNotNull);
    });
    
    test('应该拒绝空内容', () async {
      final result = await useCase.execute('   ');
      
      expect(result.isError, true);
      expect(result.errorMessage, contains('不能为空'));
    });
    
    test('应该拒绝超长内容', () async {
      final longContent = 'a' * 10001;
      
      final result = await useCase.execute(longContent);
      
      expect(result.isError, true);
      expect(result.errorMessage, contains('超过'));
    });
    
    test('应该自动trim内容', () async {
      const content = '  测试内容  ';
      
      final result = await useCase.execute(content);
      
      expect(result.isSuccess, true);
      expect(result.data?.content, '测试内容');
    });
  });
}
```

---

## 四、验证标准

### 4.1 功能验证

| 序号 | 验证项 | 验证方法 |
|------|--------|----------|
| 1 | Isar 数据库成功初始化 | 运行 `flutter run` 无错误 |
| 2 | 三大分类数据正确创建 | 启动后查询数据库 |
| 3 | 灵感可以正常保存 | 调用 CreateIdeaUseCase |
| 4 | 灵感可以正常读取 | 调用 IdeaRepository.getById |
| 5 | 灵感可以正常更新 | 调用 UpdateIdeaUseCase |
| 6 | 灵感可以软删除 | 调用 DeleteIdeaUseCase |
| 7 | 灵感可以恢复 | 调用 RestoreIdeaUseCase |
| 8 | 数据验证机制正常工作 | 测试边界条件 |
| 9 | 错误处理正常工作 | 测试异常情况 |
| 10 | 日志记录正常 | 查看日志输出 |

### 4.2 代码质量验证

| 序号 | 验证项 | 验证命令 |
|------|--------|----------|
| 1 | 通过 `flutter analyze` | `flutter analyze` 无错误 |
| 2 | 单元测试通过 | `flutter test` 全部通过 |
| 3 | 代码结构符合规范 | 人工审查 |

### 4.3 测试命令

```bash
# 安装依赖
flutter pub get

# 运行代码生成（Isar模型）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行代码分析
flutter analyze

# 运行单元测试
flutter test

# 运行特定测试
flutter test test/application/usecases/create_idea_test.dart

# 生成代码覆盖率报告
flutter test --coverage
```

---

## 五、文件清单

### 需要创建的文件（共 30 个）

| 序号 | 文件路径 | 说明 |
|------|----------|------|
| 1 | `pubspec.yaml` | 依赖配置 |
| 2 | `lib/main.dart` | 应用入口 |
| 3 | `lib/core/constants/app_constants.dart` | 常量定义 |
| 4 | `lib/core/utils/date_formatter.dart` | 日期格式化 |
| 5 | `lib/core/utils/text_helper.dart` | 文本工具 |
| 6 | `lib/core/utils/result.dart` | 结果封装类 |
| 7 | `lib/core/logger/app_logger.dart` | 日志工具 |
| 8 | `lib/domain/entities/idea.dart` | 灵感实体 |
| 9 | `lib/domain/entities/category.dart` | 分类实体 |
| 10 | `lib/domain/entities/tag.dart` | 标签实体 |
| 11 | `lib/domain/repositories/idea_repository.dart` | 灵感仓库接口 |
| 12 | `lib/domain/repositories/category_repository.dart` | 分类仓库接口 |
| 13 | `lib/domain/repositories/tag_repository.dart` | 标签仓库接口 |
| 14 | `lib/data/database/isar_database.dart` | Isar 初始化 |
| 15 | `lib/data/database/seed_data.dart` | 种子数据 |
| 16 | `lib/data/models/idea_model.dart` | 灵感数据模型 |
| 17 | `lib/data/models/category_model.dart` | 分类数据模型 |
| 18 | `lib/data/models/tag_model.dart` | 标签数据模型 |
| 19 | `lib/data/repositories/idea_repository_impl.dart` | 灵感仓库实现 |
| 20 | `lib/data/repositories/category_repository_impl.dart` | 分类仓库实现 |
| 21 | `lib/data/repositories/tag_repository_impl.dart` | 标签仓库实现 |
| 22 | `lib/application/usecases/create_idea.dart` | 创建灵感用例 |
| 23 | `lib/application/usecases/update_idea.dart` | 更新灵感用例 |
| 24 | `lib/application/usecases/delete_idea.dart` | 删除灵感用例 |
| 25 | `lib/application/usecases/restore_idea.dart` | 恢复灵感用例 |
| 26 | `analysis_options.yaml` | 分析配置 |
| 27 | `.gitignore` | Git忽略配置 |
| 28 | `README.md` | 项目说明 |

### 需要创建的测试文件（共 8 个）

| 序号 | 文件路径 | 说明 |
|------|----------|------|
| 1 | `test/core/utils/text_helper_test.dart` | 文本工具测试 |
| 2 | `test/core/utils/date_formatter_test.dart` | 日期格式化测试 |
| 3 | `test/domain/entities/idea_entity_test.dart` | 灵感实体测试 |
| 4 | `test/domain/entities/category_entity_test.dart` | 分类实体测试 |
| 5 | `test/data/repositories/idea_repository_test.dart` | 灵感仓库测试 |
| 6 | `test/application/usecases/create_idea_test.dart` | 创建灵感用例测试 |
| 7 | `test/application/usecases/update_idea_test.dart` | 更新灵感用例测试 |
| 8 | `test/application/usecases/delete_idea_test.dart` | 删除灵感用例测试 |

---

## 六、注意事项

### 6.1 Isar 特别注意事项

1. **代码生成**：每次修改 Model 文件后需要运行：
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **模型定义规范**：
   - 必须使用 `@collection` 注解
   - `Id` 字段必须使用 `Isar.autoIncrement`
   - 需要索引的字段使用 `@Index()` 注解
   - 枚举类型使用 `@Enumerated(EnumType.name)`

3. **数据库迁移**：Isar 目前不支持自动迁移，模型变更需要重建数据库

### 6.2 测试环境配置

1. **单元测试**：使用 Isar 内存模式
   ```dart
   await Isar.open(
     [IdeaModelSchema],
     directory: '', // 内存模式
   );
   ```

2. **测试隔离**：每个测试用例使用独立的数据库实例

### 6.3 开发规范

1. **错误处理**：所有数据库操作都需要 try-catch 包装
2. **日志记录**：关键操作需要记录日志
3. **代码规范**：遵循 Flutter 官方代码风格和 lint 规则
4. **注释规范**：公共API需要 DartDoc 注释

---

## 七、预计时间

| 阶段 | 任务 | 预计时间 |
|------|------|----------|
| 阶段1 | 项目初始化与基础架构 | 1-2 小时 |
| 阶段2 | Domain 层实现 | 1.5 小时 |
| 阶段3 | Data 层实现 | 2-3 小时 |
| 阶段4 | Application 层实现 | 1.5 小时 |
| 阶段5 | Core 层工具实现 | 1 小时 |
| 阶段6 | 单元测试 | 2-3 小时 |
| **总计** | | **9-13 小时** |

---

## 八、依赖关系图

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│                    (本阶段暂不实现)                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │CreateIdea   │  │UpdateIdea   │  │ DeleteIdea          │ │
│  │UseCase      │  │UseCase     │  │ UseCase             │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
└─────────┼────────────────┼─────────────────────┼─────────────┘
          │                │                     │
┌─────────▼────────────────▼─────────────────────▼─────────────┐
│                      Domain Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │IdeaEntity   │  │CategoryEnt  │  │ TagEntity           │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│         │                │                     │              │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────────▼──────────┐ │
│  │IdeaRepo     │  │CategoryRepo │  │ TagRepo            │ │
│  │Interface    │  │Interface    │  │ Interface          │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
└─────────┼────────────────┼─────────────────────┼─────────────┘
          │                │                     │
┌─────────▼────────────────▼─────────────────────▼─────────────┐
│                       Data Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │IdeaModel   │  │CategoryModel│  │ TagModel            │ │
│  │(Isar)      │  │(Isar)       │  │ (Isar)              │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│         │                │                     │              │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────────▼──────────┐ │
│  │IdeaRepoImpl │  │CategoryRepo │  │ TagRepoImpl         │ │
│  │             │  │Impl         │  │                     │ │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘ │
│         │                │                     │              │
│  ┌──────▼───────────────▼─────────────────────▼──────────┐  │
│  │                   Isar Database                         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

*文档版本：V1.1*  
*最后更新：2026-03-12*
