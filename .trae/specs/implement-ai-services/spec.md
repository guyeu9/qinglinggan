# OpenAI API 客户端 + AI 服务模块规范

## Why

根据《轻灵感开发设计文档_新方案版.md》，需要实现 AI 核心服务模块，包括 OpenAI API 客户端封装、AI 内容理解服务和 AI Embedding 服务。这是 MVP 阶段 Week 2 的核心任务，为后续 AI 任务队列和前端页面提供基础能力。

## What Changes

- 创建 OpenAI API 客户端封装（支持 GPT-4o-mini 和 text-embedding-3-small）
- 创建 AI 配置文件（API Key 管理、模型配置）
- 创建 AI 内容理解服务（分类、标签、摘要、AI提示语）
- 创建 AI Embedding 服务（向量生成、相似度计算）
- 创建扩展数据模型（AI 分析结果、AI 任务）
- 创建相关仓库接口和实现

## Impact

- Affected specs: AI 服务模块、数据模型
- Affected code:
  - `lib/config/ai_config.dart` - AI 配置
  - `lib/data/api/openai_client.dart` - OpenAI 客户端
  - `lib/data/api/api_models.dart` - API 请求/响应模型
  - `lib/data/models/ai_analysis_model.dart` - AI 分析数据模型
  - `lib/data/models/ai_task_model.dart` - AI 任务数据模型
  - `lib/domain/entities/ai_analysis.dart` - AI 分析实体
  - `lib/domain/entities/ai_task.dart` - AI 任务实体
  - `lib/domain/repositories/ai_analysis_repository.dart` - AI 分析仓库接口
  - `lib/domain/repositories/ai_task_repository.dart` - AI 任务仓库接口
  - `lib/data/repositories/ai_analysis_repository_impl.dart` - AI 分析仓库实现
  - `lib/data/repositories/ai_task_repository_impl.dart` - AI 任务仓库实现
  - `lib/application/ai/ai_understanding_service.dart` - 内容理解服务
  - `lib/application/ai/ai_embedding_service.dart` - Embedding 服务
  - `lib/core/utils/vector_math.dart` - 向量计算工具

## ADDED Requirements

### Requirement: AI 配置管理

系统 SHALL 提供安全的 AI 配置管理。

#### Scenario: API Key 配置
- **WHEN** 应用启动
- **THEN** 从环境变量或安全存储加载 OpenAI API Key
- **AND** API Key 不被硬编码或明文存储

### Requirement: OpenAI API 客户端

系统 SHALL 提供统一的 OpenAI API 调用封装。

#### Scenario: GPT-4o-mini 调用成功
- **WHEN** 调用 chat completion API
- **THEN** 返回结构化的响应内容
- **AND** 正确处理错误和超时

#### Scenario: Embedding 调用成功
- **WHEN** 调用 text-embedding-3-small API
- **THEN** 返回 1536 维浮点向量
- **AND** 正确处理错误和超时

#### Scenario: API 限流处理
- **WHEN** API 返回 429 错误
- **THEN** 自动重试（最多3次）
- **AND** 使用指数退避策略

### Requirement: AI 内容理解服务

系统 SHALL 提供灵感内容理解能力。

#### Scenario: 内容分析成功
- **WHEN** 调用 analyze 方法分析灵感内容
- **THEN** 返回分类ID、标签列表、摘要、AI提示语
- **AND** 分类必须匹配三大分类之一

#### Scenario: 内容为空
- **WHEN** 传入空内容
- **THEN** 返回错误 "内容不能为空"

#### Scenario: 内容过长
- **WHEN** 内容超过 API 限制
- **THEN** 返回错误 "内容长度超过限制"

### Requirement: AI Embedding 服务

系统 SHALL 提供向量生成和相似度计算能力。

#### Scenario: 生成 Embedding 成功
- **WHEN** 调用 generateEmbedding 方法
- **THEN** 返回 1536 维浮点向量
- **AND** 向量已归一化

#### Scenario: 计算相似度
- **WHEN** 调用 cosineSimilarity 方法
- **THEN** 返回 -1 到 1 之间的相似度值

#### Scenario: 搜索相似灵感
- **WHEN** 调用 searchSimilar 方法
- **THEN** 返回按相似度排序的 TopN 灵感列表

### Requirement: AI 分析数据模型

系统 SHALL 提供完整的 AI 分析结果存储。

#### Scenario: AI 分析结果存储
- **WHEN** AI 分析完成
- **THEN** 结果保存到 Isar 数据库
- **AND** 包含分类结果、标签结果、摘要、AI提示语

### Requirement: AI 任务数据模型

系统 SHALL 提供异步任务管理能力。

#### Scenario: 任务创建
- **WHEN** 创建 AI 任务
- **THEN** 任务状态为 pending
- **AND** 记录创建时间和关联的灵感ID

#### Scenario: 任务状态更新
- **WHEN** 任务开始处理
- **THEN** 状态更新为 processing
- **WHEN** 任务完成
- **THEN** 状态更新为 completed

#### Scenario: 任务失败重试
- **WHEN** 任务失败
- **THEN** 重试计数增加
- **AND** 重试次数小于3次时状态重置为 pending

## MODIFIED Requirements

无修改的需求。

## REMOVED Requirements

无移除的需求。
