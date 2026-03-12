# Tasks

## 阶段 1：AI 配置与 API 模型

- [x] Task 1: 创建 AI 配置模块
  - [x] SubTask 1.1: 创建 `lib/config/ai_config.dart` AI 配置类（API Key、模型名称、超时配置）
  - [x] SubTask 1.2: 创建 `lib/core/utils/vector_math.dart` 向量计算工具（余弦相似度）

- [x] Task 2: 创建 API 模型定义
  - [x] SubTask 2.1: 创建 `lib/data/api/api_models.dart` API 请求/响应模型

## 阶段 2：OpenAI API 客户端

- [x] Task 3: 创建 OpenAI 客户端
  - [x] SubTask 3.1: 创建 `lib/data/api/openai_client.dart` OpenAI 客户端封装
  - [x] SubTask 3.2: 实现 chat completion 调用（GPT-4o-mini）
  - [x] SubTask 3.3: 实现 embedding 调用（text-embedding-3-small）
  - [x] SubTask 3.4: 实现错误处理和重试机制

## 阶段 3：扩展数据模型

- [x] Task 4: 创建 AI 相关实体
  - [x] SubTask 4.1: 创建 `lib/domain/entities/ai_analysis.dart` AI 分析实体
  - [x] SubTask 4.2: 创建 `lib/domain/entities/ai_task.dart` AI 任务实体

- [x] Task 5: 创建 AI 相关数据模型
  - [x] SubTask 5.1: 创建 `lib/data/models/ai_analysis_model.dart` AI 分析数据模型
  - [x] SubTask 5.2: 创建 `lib/data/models/ai_task_model.dart` AI 任务数据模型
  - [x] SubTask 5.3: 执行 `flutter pub run build_runner build` 生成 Isar 代码

- [x] Task 6: 创建 AI 相关仓库接口
  - [x] SubTask 6.1: 创建 `lib/domain/repositories/ai_analysis_repository.dart` AI 分析仓库接口
  - [x] SubTask 6.2: 创建 `lib/domain/repositories/ai_task_repository.dart` AI 任务仓库接口

- [x] Task 7: 创建 AI 相关仓库实现
  - [x] SubTask 7.1: 创建 `lib/data/repositories/ai_analysis_repository_impl.dart` AI 分析仓库实现
  - [x] SubTask 7.2: 创建 `lib/data/repositories/ai_task_repository_impl.dart` AI 任务仓库实现

## 阶段 4：AI 服务模块

- [x] Task 8: 创建 AI 内容理解服务
  - [x] SubTask 8.1: 创建 `lib/application/ai/ai_understanding_service.dart` 内容理解服务
  - [x] SubTask 8.2: 实现 Prompt 模板设计
  - [x] SubTask 8.3: 实现响应解析逻辑

- [x] Task 9: 创建 AI Embedding 服务
  - [x] SubTask 9.1: 创建 `lib/application/ai/ai_embedding_service.dart` Embedding 服务
  - [x] SubTask 9.2: 实现 generateEmbedding 方法
  - [x] SubTask 9.3: 实现 cosineSimilarity 方法
  - [x] SubTask 9.4: 实现 searchSimilar 方法

## 阶段 5：数据库更新

- [x] Task 10: 更新数据库初始化
  - [x] SubTask 10.1: 更新 `lib/data/database/isar_database.dart` 添加新模型 Schema
  - [x] SubTask 10.2: 验证数据库迁移

## 阶段 6：单元测试

- [ ] Task 11: 编写测试
  - [ ] SubTask 11.1: 创建 `test/core/utils/vector_math_test.dart` 向量计算测试
  - [ ] SubTask 11.2: 创建 `test/data/api/openai_client_test.dart` OpenAI 客户端测试
  - [ ] SubTask 11.3: 创建 `test/application/ai/ai_understanding_service_test.dart` 内容理解服务测试
  - [ ] SubTask 11.4: 创建 `test/application/ai/ai_embedding_service_test.dart` Embedding 服务测试

## 阶段 7：验证

- [x] Task 12: 运行验证
  - [x] SubTask 12.1: 执行 `flutter analyze` 确保无错误
  - [ ] SubTask 12.2: 执行 `flutter test` 确保所有测试通过

# Task Dependencies

- Task 2 依赖 Task 1（API 模型依赖配置）
- Task 3 依赖 Task 1 和 Task 2（客户端依赖配置和模型）
- Task 4 独立（可并行）
- Task 5 依赖 Task 4（数据模型依赖实体）
- Task 6 依赖 Task 4（仓库接口依赖实体）
- Task 7 依赖 Task 5 和 Task 6（仓库实现依赖模型和接口）
- Task 8 依赖 Task 3（内容理解服务依赖 OpenAI 客户端）
- Task 9 依赖 Task 3（Embedding 服务依赖 OpenAI 客户端）
- Task 10 依赖 Task 5（数据库更新依赖新模型）
- Task 11 依赖所有前置任务
- Task 12 依赖所有前置任务
