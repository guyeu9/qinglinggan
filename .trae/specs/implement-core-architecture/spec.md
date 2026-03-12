# 《轻灵感》第一阶段开发规范

## Why

根据 `轻灵感开发设计文档_新方案版.md` 的架构设计，需要建立项目的核心基础架构，包括：
- Isar 本地数据库集成与初始化
- Domain/Data/Application 三层架构实现
- 灵感记录功能的核心业务逻辑（CRUD）

这是 MVP 阶段的基础，后续所有功能都将在此基础上构建。

## What Changes

- 创建 Flutter 项目并配置依赖
- 建立 Domain 层（Entities + Repository 接口）
- 建立 Data 层（Isar Models + Repository 实现）
- 建立 Application 层（UseCases）
- 建立 Core 层（工具类、常量、日志）
- 实现灵感记录的核心 CRUD 功能
- 实现三大分类的种子数据
- 编写单元测试验证核心功能

## Impact

- Affected specs: 核心数据模型、仓库接口、业务用例
- Affected code: 
  - `lib/domain/` - 业务实体和仓库接口
  - `lib/data/` - Isar 模型和仓库实现
  - `lib/application/` - 业务用例
  - `lib/core/` - 核心工具类

## ADDED Requirements

### Requirement: 项目初始化

系统 SHALL 提供正确配置的 Flutter 项目结构。

#### Scenario: 项目创建成功
- **WHEN** 执行 `flutter create light_idea`
- **THEN** 项目结构符合设计文档规范
- **AND** pubspec.yaml 包含所有必需依赖

### Requirement: Isar 数据库初始化

系统 SHALL 在应用启动时正确初始化 Isar 数据库。

#### Scenario: 数据库初始化成功
- **WHEN** 应用启动
- **THEN** Isar 数据库成功打开
- **AND** 三大分类（灵感想法、待办事项、学习笔记）自动创建

#### Scenario: 数据库重复初始化
- **WHEN** 数据库已初始化
- **THEN** 返回现有实例而不重新创建

### Requirement: 灵感实体定义

系统 SHALL 定义完整的灵感实体模型。

#### Scenario: 灵感实体包含所有必需字段
- **WHEN** 创建 IdeaEntity
- **THEN** 包含 id, content, categoryId, createdAt, updatedAt, deletedAt, isDeleted, aiStatus, tagIds, embedding 字段

### Requirement: 灵感仓库接口

系统 SHALL 定义灵感仓库的完整 CRUD 接口。

#### Scenario: 仓库接口定义完整
- **WHEN** 定义 IdeaRepository
- **THEN** 包含 save, getById, getAll, getByCategory, update, softDelete, restore, permanentDelete 方法

### Requirement: 灵感创建功能

系统 SHALL 允许用户创建新的灵感记录。

#### Scenario: 创建有效灵感
- **WHEN** 用户提交非空内容（长度 ≤ 10000）
- **THEN** 灵感成功保存到数据库
- **AND** 返回包含有效 id 的 IdeaEntity
- **AND** aiStatus 初始值为 pending

#### Scenario: 拒绝空内容
- **WHEN** 用户提交空内容
- **THEN** 返回错误 "内容不能为空"

#### Scenario: 拒绝超长内容
- **WHEN** 用户提交内容长度 > 10000
- **THEN** 返回错误 "内容长度不能超过10000字符"

### Requirement: 灵感更新功能

系统 SHALL 允许用户更新现有灵感内容。

#### Scenario: 更新成功
- **WHEN** 用户更新存在的灵感内容
- **THEN** 内容更新成功
- **AND** updatedAt 更新为当前时间
- **AND** aiStatus 重置为 pending

#### Scenario: 更新不存在的灵感
- **WHEN** 用户更新不存在的灵感 id
- **THEN** 返回错误 "灵感不存在"

### Requirement: 灵感删除功能

系统 SHALL 支持软删除灵感记录。

#### Scenario: 软删除成功
- **WHEN** 用户删除存在的灵感
- **THEN** isDeleted 设置为 true
- **AND** deletedAt 设置为当前时间

#### Scenario: 永久删除
- **WHEN** 用户请求永久删除
- **THEN** 记录从数据库中彻底移除

### Requirement: 灵感恢复功能

系统 SHALL 允许恢复已软删除的灵感。

#### Scenario: 恢复成功
- **WHEN** 用户恢复已删除的灵感
- **THEN** isDeleted 设置为 false
- **AND** deletedAt 设置为 null

### Requirement: 数据验证

系统 SHALL 验证所有输入数据。

#### Scenario: 内容自动 trim
- **WHEN** 用户输入包含首尾空格的内容
- **THEN** 保存前自动去除首尾空格

### Requirement: 日志记录

系统 SHALL 记录关键操作日志。

#### Scenario: 操作日志
- **WHEN** 执行创建、更新、删除操作
- **THEN** 记录操作类型和结果

### Requirement: 单元测试

系统 SHALL 提供核心功能的单元测试。

#### Scenario: 测试覆盖率
- **WHEN** 运行 `flutter test`
- **THEN** 所有测试通过
- **AND** 核心功能测试覆盖率 > 80%

## MODIFIED Requirements

无修改的需求。

## REMOVED Requirements

无移除的需求。
