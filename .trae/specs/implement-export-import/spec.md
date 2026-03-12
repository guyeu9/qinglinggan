# 数据导出/导入服务 Spec

## Why
产品设计说明书明确要求"数据永久保存"、"支持完整导出和导入"，这是数据安全的基础保障。用户需要能够备份和迁移灵感数据。

## What Changes
- 新增导出服务，支持 Excel 和 JSON 格式导出
- 新增导入服务，支持 Excel 和 JSON 格式导入
- 新增导出/导入用例
- 更新数据管理页面，连接导出/导入服务

## Impact
- Affected specs: 数据管理功能
- Affected code: 
  - `lib/application/services/` (新增)
  - `lib/application/usecases/` (新增)
  - `lib/presentation/pages/data_management/` (修改)

## ADDED Requirements

### Requirement: 数据导出服务
系统应提供数据导出服务，支持用户将灵感数据导出为外部格式。

#### Scenario: Excel 格式导出
- **WHEN** 用户选择导出为 Excel 格式
- **THEN** 系统生成包含 ID、内容、分类、标签、创建时间、更新时间的 Excel 文件

#### Scenario: JSON 格式导出
- **WHEN** 用户选择导出为 JSON 格式
- **THEN** 系统生成完整数据库备份的 JSON 文件

#### Scenario: 筛选导出
- **WHEN** 用户选择按分类或时间范围筛选后导出
- **THEN** 系统仅导出符合筛选条件的数据

### Requirement: 数据导入服务
系统应提供数据导入服务，支持用户从外部文件导入灵感数据。

#### Scenario: Excel 格式导入
- **WHEN** 用户选择导入 Excel 文件
- **THEN** 系统解析文件内容并创建灵感记录

#### Scenario: JSON 格式导入
- **WHEN** 用户选择导入 JSON 文件
- **THEN** 系统解析文件内容并恢复数据

#### Scenario: 导入时触发 AI 分析
- **WHEN** 用户选择导入时自动触发 AI 分析
- **THEN** 系统在导入完成后自动为每条灵感创建 AI 分析任务

#### Scenario: 冲突处理
- **WHEN** 导入数据与现有数据存在 ID 冲突
- **THEN** 系统根据用户选择的策略（覆盖/跳过/合并）处理冲突

### Requirement: 数据管理页面集成
数据管理页面应提供导出和导入功能的操作入口。

#### Scenario: 导出操作
- **WHEN** 用户在数据管理页面点击导出按钮
- **THEN** 系统显示导出选项（格式、筛选条件），用户确认后执行导出

#### Scenario: 导入操作
- **WHEN** 用户在数据管理页面点击导入按钮
- **THEN** 系统显示文件选择器，用户选择文件后显示导入选项（冲突策略、是否触发 AI 分析）

## MODIFIED Requirements
无

## REMOVED Requirements
无
