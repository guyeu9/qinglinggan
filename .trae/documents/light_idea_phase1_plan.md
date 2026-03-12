# 《轻灵感》第一阶段开发计划：基础架构搭建与记录功能实现

## 一、任务概述

根据 `轻灵感开发设计文档_新方案版.md` 的架构设计，实施第一阶段开发任务：

* 基础架构构建

* 数据库初始化（Isar + 三大分类）

* 记录功能核心业务逻辑

**注意**：本次任务不包含前端页面开发，仅专注于后端基础架构实现。

***

## 二、实施步骤

### 阶段 1：项目初始化与基础架构（预计 2-3 小时）

#### 1.1 创建 Flutter 项目

* 使用 `flutter create` 创建项目

* 项目名称：`light_idea`

* 配置 Dart SDK 版本约束（>=3.4.0 <4.0.0）

#### 1.2 配置 pubspec.yaml 依赖

```yaml
# 核心依赖
- flutter_riverpod: ^2.5.1      # 状态管理
- isar: ^3.1.0+1                # 本地数据库
- isar_flutter_libs: ^3.1.0+1   # Isar 运行时库
- uuid: ^4.4.0                  # UUID 生成
- path_provider: ^2.1.3         # 文件路径
- logger: ^2.3.0                # 日志
- intl: ^0.19.0                 # 日期格式化

# 开发依赖
- build_runner: ^2.4.9          # 代码生成
- isar_generator: ^3.1.0+1      # Isar 代码生成
- flutter_lints: ^3.0.2         # Lint 规则
```

#### 1.3 建立目录结构

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   └── text_helper.dart
│   └── logger/
│       └── app_logger.dart
├── domain/
│   ├── entities/
│   │   ├── idea.dart
│   │   ├── category.dart
│   │   └── tag.dart
│   └── repositories/
│       ├── idea_repository.dart
│       ├── category_repository.dart
│       └── tag_repository.dart
├── data/
│   ├── database/
│   │   ├── isar_database.dart
│   │   └── seed_data.dart
│   ├── models/
│   │   ├── idea_model.dart
│   │   ├── category_model.dart
│   │   └── tag_model.dart
│   └── repositories/
│       ├── idea_repository_impl.dart
│       ├── category_repository_impl.dart
│       └── tag_repository_impl.dart
└── application/
    └── usecases/
        └── create_idea.dart
```

***

### 阶段 2：Domain 层实现（预计 2 小时）

#### 2.1 创建业务实体（Entities）

**IdeaEntity（灵感实体）**

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
  // 构造函数、copyWith、equals/hashCode
}

enum AIStatus { pending, processing, completed, failed }
```

**CategoryEntity（分类实体）**

```dart
// lib/domain/entities/category.dart
class CategoryEntity {
  final int id;
  final String name;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;
}
```

**TagEntity（标签实体）**

```dart
// lib/domain/entities/tag.dart
class TagEntity {
  final int id;
  final String name;
  final DateTime createdAt;
}
```

#### 2.2 创建仓库接口（Repository Interfaces）

**IdeaRepository**

```dart
// lib/domain/repositories/idea_repository.dart
abstract class IdeaRepository {
  Future<IdeaEntity> save(IdeaEntity idea);
  Future<IdeaEntity?> getById(int id);
  Future<List<IdeaEntity>> getAll({bool includeDeleted = false});
  Future<List<IdeaEntity>> getByCategory(int categoryId);
  Future<void> update(IdeaEntity idea);
  Future<void> softDelete(int id);
  Future<void> restore(int id);
  Future<void> permanentDelete(int id);
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
}
```

**TagRepository**

```dart
// lib/domain/repositories/tag_repository.dart
abstract class TagRepository {
  Future<TagEntity?> getById(int id);
  Future<TagEntity?> getByName(String name);
  Future<List<TagEntity>> getAll();
  Future<TagEntity> save(TagEntity tag);
  Future<List<TagEntity>> saveAll(List<String> names);
}
```

***

### 阶段 3：Data 层实现（预计 3-4 小时）

#### 3.1 Isar 数据模型

**IdeaModel**

```dart
// lib/data/models/idea_model.dart
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
  
  // toEntity() 和 fromEntity() 方法
}
```

**CategoryModel**

```dart
// lib/data/models/category_model.dart
@collection
class CategoryModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String name;
  
  late String icon;
  late int sortOrder;
  DateTime createdAt = DateTime.now();
  
  // toEntity() 和 fromEntity() 方法
}
```

**TagModel**

```dart
// lib/data/models/tag_model.dart
@collection
class TagModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String name;
  
  DateTime createdAt = DateTime.now();
  
  // toEntity() 和 fromEntity() 方法
}
```

#### 3.2 Isar 数据库初始化

**isar\_database.dart**

```dart
// lib/data/database/isar_database.dart
class IsarDatabase {
  static Isar? _instance;
  
  static Future<Isar> initialize() async {
    if (_instance != null) return _instance!;
    
    final dir = await getApplicationDocumentsDirectory();
    
    _instance = await Isar.open(
      [IdeaModelSchema, CategoryModelSchema, TagModelSchema],
      directory: dir.path,
      inspector: kDebugMode,
    );
    
    return _instance!;
  }
  
  static Isar get instance {
    if (_instance == null) {
      throw StateError('Isar not initialized. Call initialize() first.');
    }
    return _instance!;
  }
}
```

#### 3.3 种子数据（三大分类）

**seed\_data.dart**

```dart
// lib/data/database/seed_data.dart
class SeedData {
  static Future<void> initializeDefaultCategories(Isar isar) async {
    final existingCount = await isar.categoryModels.count();
    if (existingCount > 0) return;
    
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
}
```

#### 3.4 仓库实现

**IdeaRepositoryImpl**

```dart
// lib/data/repositories/idea_repository_impl.dart
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
  
  // 其他 CRUD 方法实现...
}
```

**CategoryRepositoryImpl**

```dart
// lib/data/repositories/category_repository_impl.dart
class CategoryRepositoryImpl implements CategoryRepository {
  final Isar _isar;
  
  CategoryRepositoryImpl(this._isar);
  
  // 实现所有接口方法...
}
```

**TagRepositoryImpl**

```dart
// lib/data/repositories/tag_repository_impl.dart
class TagRepositoryImpl implements TagRepository {
  final Isar _isar;
  
  TagRepositoryImpl(this._isar);
  
  // 实现所有接口方法...
}
```

***

### 阶段 4：Application 层实现（预计 2 小时）

#### 4.1 创建灵感用例

**CreateIdeaUseCase**

```dart
// lib/application/usecases/create_idea.dart
class CreateIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;
  
  CreateIdeaUseCase(this._ideaRepository, this._logger);
  
  Future<Result<IdeaEntity>> execute(String content) async {
    // 1. 数据验证
    if (content.trim().isEmpty) {
      return Result.error('内容不能为空');
    }
    
    if (content.length > 10000) {
      return Result.error('内容长度不能超过10000字符');
    }
    
    try {
      // 2. 创建实体
      final idea = IdeaEntity(
        id: 0,
        content: content.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 3. 保存到数据库
      final savedIdea = await _ideaRepository.save(idea);
      
      _logger.info('灵感创建成功: ${savedIdea.id}');
      
      return Result.success(savedIdea);
    } catch (e) {
      _logger.error('创建灵感失败', error: e);
      return Result.error('保存失败: ${e.toString()}');
    }
  }
}
```

#### 4.2 其他用例（基础 CRUD）

**UpdateIdeaUseCase**

```dart
// lib/application/usecases/update_idea.dart
class UpdateIdeaUseCase {
  final IdeaRepository _ideaRepository;
  
  Future<Result<IdeaEntity>> execute(int id, String newContent) async {
    // 实现更新逻辑
  }
}
```

**DeleteIdeaUseCase**

```dart
// lib/application/usecases/delete_idea.dart
class DeleteIdeaUseCase {
  final IdeaRepository _ideaRepository;
  
  Future<Result<void>> execute(int id) async {
    // 实现软删除逻辑
  }
}
```

***

### 阶段 5：Core 层工具实现（预计 1 小时）

#### 5.1 常量定义

**app\_constants.dart**

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = '轻灵感';
  static const int maxContentLength = 10000;
  static const int defaultPageSize = 20;
}
```

#### 5.2 日志工具

**app\_logger.dart**

```dart
// lib/core/logger/app_logger.dart
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();
  
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
    ),
  );
  
  void info(String message) => _logger.i(message);
  void error(String message, {Object? error}) => _logger.e(message, error: error);
  void warning(String message) => _logger.w(message);
  void debug(String message) => _logger.d(message);
}
```

#### 5.3 日期格式化

**date\_formatter.dart**

```dart
// lib/core/utils/date_formatter.dart
class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
  
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
  
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    
    return formatDate(dateTime);
  }
}
```

#### 5.4 文本工具

**text\_helper.dart**

```dart
// lib/core/utils/text_helper.dart
class TextHelper {
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  static bool isValidContent(String? content) {
    if (content == null) return false;
    final trimmed = content.trim();
    return trimmed.isNotEmpty && trimmed.length <= 10000;
  }
}
```

***

### 阶段 6：单元测试（预计 2 小时）

#### 6.1 测试目录结构

```
test/
├── domain/
│   └── entities/
│       ├── idea_entity_test.dart
│       └── category_entity_test.dart
├── data/
│   └── repositories/
│       ├── idea_repository_test.dart
│       └── category_repository_test.dart
└── application/
    └── usecases/
        └── create_idea_test.dart
```

#### 6.2 核心测试用例

**IdeaRepository 测试**

* 测试保存灵感

* 测试获取灵感

* 测试更新灵感

* 测试软删除灵感

* 测试恢复灵感

**CreateIdeaUseCase 测试**

* 测试正常创建

* 测试空内容验证

* 测试超长内容验证

* 测试异常处理

***

## 三、验证标准

### 3.1 功能验证

* [ ] Isar 数据库成功初始化

* [ ] 三大分类数据正确创建

* [ ] 灵感可以正常保存、读取、更新、删除

* [ ] 数据验证机制正常工作

* [ ] 错误处理和日志记录正常

### 3.2 代码质量

* [ ] 代码结构符合设计文档规范

* [ ] 所有文件包含必要的注释

* [ ] 通过 `flutter analyze` 无警告

* [ ] 单元测试覆盖率 > 80%

### 3.3 测试命令

```bash
# 运行代码分析
flutter analyze

# 运行单元测试
flutter test

# 生成 Isar 代码
flutter pub run build_runner build
```

***

## 四、文件清单

### 需要创建的文件（共 25 个）

| 序号 | 文件路径                                                  | 说明       |
| -- | ----------------------------------------------------- | -------- |
| 1  | `lib/main.dart`                                       | 应用入口     |
| 2  | `lib/core/constants/app_constants.dart`               | 常量定义     |
| 3  | `lib/core/utils/date_formatter.dart`                  | 日期格式化    |
| 4  | `lib/core/utils/text_helper.dart`                     | 文本工具     |
| 5  | `lib/core/logger/app_logger.dart`                     | 日志工具     |
| 6  | `lib/domain/entities/idea.dart`                       | 灵感实体     |
| 7  | `lib/domain/entities/category.dart`                   | 分类实体     |
| 8  | `lib/domain/entities/tag.dart`                        | 标签实体     |
| 9  | `lib/domain/repositories/idea_repository.dart`        | 灵感仓库接口   |
| 10 | `lib/domain/repositories/category_repository.dart`    | 分类仓库接口   |
| 11 | `lib/domain/repositories/tag_repository.dart`         | 标签仓库接口   |
| 12 | `lib/data/database/isar_database.dart`                | Isar 初始化 |
| 13 | `lib/data/database/seed_data.dart`                    | 种子数据     |
| 14 | `lib/data/models/idea_model.dart`                     | 灵感数据模型   |
| 15 | `lib/data/models/category_model.dart`                 | 分类数据模型   |
| 16 | `lib/data/models/tag_model.dart`                      | 标签数据模型   |
| 17 | `lib/data/repositories/idea_repository_impl.dart`     | 灵感仓库实现   |
| 18 | `lib/data/repositories/category_repository_impl.dart` | 分类仓库实现   |
| 19 | `lib/data/repositories/tag_repository_impl.dart`      | 标签仓库实现   |
| 20 | `lib/application/usecases/create_idea.dart`           | 创建灵感用例   |
| 21 | `lib/application/usecases/update_idea.dart`           | 更新灵感用例   |
| 22 | `lib/application/usecases/delete_idea.dart`           | 删除灵感用例   |
| 23 | `lib/core/utils/result.dart`                          | 结果封装类    |
| 24 | `pubspec.yaml`                                        | 依赖配置（修改） |
| 25 | `analysis_options.yaml`                               | 分析配置     |

### 需要创建的测试文件（共 5 个）

| 序号 | 文件路径                                               | 说明       |
| -- | -------------------------------------------------- | -------- |
| 1  | `test/domain/entities/idea_entity_test.dart`       | 灵感实体测试   |
| 2  | `test/data/repositories/idea_repository_test.dart` | 灵感仓库测试   |
| 3  | `test/application/usecases/create_idea_test.dart`  | 创建灵感用例测试 |
| 4  | `test/application/usecases/update_idea_test.dart`  | 更新灵感用例测试 |
| 5  | `test/application/usecases/delete_idea_test.dart`  | 删除灵感用例测试 |

***

## 五、预计时间

| 阶段                  | 预计时间         |
| ------------------- | ------------ |
| 阶段1：项目初始化与基础架构      | 2-3 小时       |
| 阶段2：Domain 层实现      | 2 小时         |
| 阶段3：Data 层实现        | 3-4 小时       |
| 阶段4：Application 层实现 | 2 小时         |
| 阶段5：Core 层工具实现      | 1 小时         |
| 阶段6：单元测试            | 2 小时         |
| **总计**              | **12-14 小时** |

***

## 六、注意事项

1. **Isar 代码生成**：每次修改 Model 文件后需要运行 `flutter pub run build_runner build`
2. **测试环境**：单元测试需要使用 Isar 的内存模式
3. **错误处理**：所有数据库操作都需要 try-catch 包装
4. **日志记录**：关键操作需要记录日志，便于调试
5. **代码规范**：遵循 Flutter 官方代码风格和 lint 规则

