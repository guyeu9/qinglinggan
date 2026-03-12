# Tasks

## 阶段 1：创建导出服务

- [x] Task 1: 创建导出服务基础结构
  - [x] SubTask 1.1: 创建 `lib/application/services/export_service.dart` 导出服务类
  - [x] SubTask 1.2: 实现 Excel 格式导出方法（使用 excel 包）
  - [x] SubTask 1.3: 实现 JSON 格式导出方法
  - [x] SubTask 1.4: 实现筛选导出功能（按分类、按时间范围）

- [x] Task 2: 创建导出用例
  - [x] SubTask 2.1: 创建 `lib/application/usecases/export_ideas.dart` 导出用例
  - [x] SubTask 2.2: 实现导出结果封装（返回文件路径或字节数据）

## 阶段 2：创建导入服务

- [x] Task 3: 创建导入服务基础结构
  - [x] SubTask 3.1: 创建 `lib/application/services/import_service.dart` 导入服务类
  - [x] SubTask 3.2: 实现 Excel 格式导入方法
  - [x] SubTask 3.3: 实现 JSON 格式导入方法
  - [x] SubTask 3.4: 实现冲突处理策略（覆盖/跳过/合并）

- [x] Task 4: 创建导入用例
  - [x] SubTask 4.1: 创建 `lib/application/usecases/import_ideas.dart` 导入用例
  - [x] SubTask 4.2: 实现导入时触发 AI 分析选项

## 阶段 3：连接数据管理页面

- [ ] Task 5: 更新数据管理页面
  - [ ] SubTask 5.1: 在 `data_management_page.dart` 添加导出按钮和导出选项对话框
  - [ ] SubTask 5.2: 在 `data_management_page.dart` 添加导入按钮和文件选择器
  - [ ] SubTask 5.3: 实现导出进度提示
  - [ ] SubTask 5.4: 实现导入进度提示和结果反馈

## 阶段 4：Provider 集成

- [ ] Task 6: 创建导出/导入 Provider
  - [ ] SubTask 6.1: 在 `app_providers.dart` 添加导出/导入服务 Provider
  - [ ] SubTask 6.2: 确保依赖注入正确

## 阶段 5：验证

- [ ] Task 7: 运行验证
  - [ ] SubTask 7.1: 执行 `flutter analyze` 确保无错误
  - [ ] SubTask 7.2: 执行 `flutter test` 确保所有测试通过
  - [ ] SubTask 7.3: 手动测试导出/导入功能

# Task Dependencies

- Task 2 依赖 Task 1（导出用例依赖导出服务）
- Task 4 依赖 Task 3（导入用例依赖导入服务）
- Task 5 依赖 Task 2 和 Task 4（页面依赖用例）
- Task 6 依赖 Task 1 和 Task 3（Provider 依赖服务）
- Task 7 依赖所有前置任务
