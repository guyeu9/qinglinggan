# Tasks

## 阶段 1：项目初始化

- [x] Task 1: 创建 Flutter 项目并配置依赖
  - [x] SubTask 1.1: 执行 `flutter create light_idea --org com.lightidea`
  - [x] SubTask 1.2: 配置 pubspec.yaml 添加所有必需依赖
  - [x] SubTask 1.3: 配置 analysis_options.yaml 代码分析规则
  - [x] SubTask 1.4: 创建目录结构（core, domain, data, application）
  - [x] SubTask 1.5: 执行 `flutter pub get` 安装依赖

## 阶段 2：Core 层实现

- [x] Task 2: 实现核心工具类
  - [x] SubTask 2.1: 创建 `lib/core/constants/app_constants.dart` 常量定义
  - [x] SubTask 2.2: 创建 `lib/core/utils/result.dart` 结果封装类
  - [x] SubTask 2.3: 创建 `lib/core/logger/app_logger.dart` 日志工具
  - [x] SubTask 2.4: 创建 `lib/core/utils/date_formatter.dart` 日期格式化工具
  - [x] SubTask 2.5: 创建 `lib/core/utils/text_helper.dart` 文本工具类

## 阶段 3：Domain 层实现

- [x] Task 3: 实现业务实体
  - [x] SubTask 3.1: 创建 `lib/domain/entities/idea.dart` 灵感实体（包含 AIStatus 枚举）
  - [x] SubTask 3.2: 创建 `lib/domain/entities/category.dart` 分类实体
  - [x] SubTask 3.3: 创建 `lib/domain/entities/tag.dart` 标签实体

- [x] Task 4: 实现仓库接口
  - [x] SubTask 4.1: 创建 `lib/domain/repositories/idea_repository.dart` 灵感仓库接口
  - [x] SubTask 4.2: 创建 `lib/domain/repositories/category_repository.dart` 分类仓库接口
  - [x] SubTask 4.3: 创建 `lib/domain/repositories/tag_repository.dart` 标签仓库接口

## 阶段 4：Data 层实现

- [x] Task 5: 实现 Isar 数据模型
  - [x] SubTask 5.1: 创建 `lib/data/models/idea_model.dart` 灵感数据模型（含 toEntity/fromEntity）
  - [x] SubTask 5.2: 创建 `lib/data/models/category_model.dart` 分类数据模型
  - [x] SubTask 5.3: 创建 `lib/data/models/tag_model.dart` 标签数据模型
  - [x] SubTask 5.4: 执行 `flutter pub run build_runner build --delete-conflicting-outputs` 生成 Isar 代码

- [x] Task 6: 实现数据库初始化
  - [x] SubTask 6.1: 创建 `lib/data/database/isar_database.dart` Isar 初始化类
  - [x] SubTask 6.2: 创建 `lib/data/database/seed_data.dart` 种子数据（三大分类）

- [x] Task 7: 实现仓库
  - [x] SubTask 7.1: 创建 `lib/data/repositories/idea_repository_impl.dart` 灵感仓库实现（完整 CRUD）
  - [x] SubTask 7.2: 创建 `lib/data/repositories/category_repository_impl.dart` 分类仓库实现
  - [x] SubTask 7.3: 创建 `lib/data/repositories/tag_repository_impl.dart` 标签仓库实现

## 阶段 5：Application 层实现

- [x] Task 8: 实现业务用例
  - [x] SubTask 8.1: 创建 `lib/application/usecases/create_idea.dart` 创建灵感用例（含数据验证）
  - [x] SubTask 8.2: 创建 `lib/application/usecases/update_idea.dart` 更新灵感用例
  - [x] SubTask 8.3: 创建 `lib/application/usecases/delete_idea.dart` 删除灵感用例（支持软删除和永久删除）
  - [x] SubTask 8.4: 创建 `lib/application/usecases/restore_idea.dart` 恢复灵感用例

## 阶段 6：单元测试

- [x] Task 9: 编写 Core 层测试
  - [x] SubTask 9.1: 创建 `test/core/utils/text_helper_test.dart` 文本工具测试
  - [x] SubTask 9.2: 创建 `test/core/utils/date_formatter_test.dart` 日期格式化测试
  - [x] SubTask 9.3: 创建 `test/core/utils/result_test.dart` 结果封装测试

- [x] Task 10: 编写 Domain 层测试
  - [x] SubTask 10.1: 创建 `test/domain/entities/idea_entity_test.dart` 灵感实体测试
  - [x] SubTask 10.2: 创建 `test/domain/entities/category_entity_test.dart` 分类实体测试

- [x] Task 11: 编写 Data 层测试
  - [x] SubTask 11.1: 创建 `test/data/repositories/idea_repository_test.dart` 灵感仓库测试（使用内存 Isar）

- [x] Task 12: 编写 Application 层测试
  - [x] SubTask 12.1: 创建 `test/application/usecases/create_idea_test.dart` 创建灵感用例测试
  - [x] SubTask 12.2: 创建 `test/application/usecases/update_idea_test.dart` 更新灵感用例测试
  - [x] SubTask 12.3: 创建 `test/application/usecases/delete_idea_test.dart` 删除灵感用例测试

## 阶段 7：验证与清理

- [x] Task 13: 运行验证
  - [x] SubTask 13.1: 执行 `flutter analyze` 确保无警告
  - [x] SubTask 13.2: 执行 `flutter test` 确保所有测试通过
  - [x] SubTask 13.3: 创建 `lib/main.dart` 简单入口验证数据库初始化

# Task Dependencies

- Task 2 依赖 Task 1（需要项目结构）
- Task 3 依赖 Task 2（实体可能使用工具类）
- Task 4 依赖 Task 3（仓库接口依赖实体）
- Task 5 依赖 Task 3（数据模型依赖实体定义）
- Task 6 依赖 Task 5（数据库初始化依赖模型）
- Task 7 依赖 Task 4 和 Task 5（仓库实现依赖接口和模型）
- Task 8 依赖 Task 4 和 Task 2（用例依赖仓库接口和工具类）
- Task 9 依赖 Task 2（测试依赖工具类）
- Task 10 依赖 Task 3（测试依赖实体）
- Task 11 依赖 Task 7（测试依赖仓库实现）
- Task 12 依赖 Task 8（测试依赖用例）
- Task 13 依赖所有前置任务
