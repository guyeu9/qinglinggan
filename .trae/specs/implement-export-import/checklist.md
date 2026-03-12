# Checklist

## 导出服务验证
- [ ] ExportService 类已创建，包含 Excel 和 JSON 导出方法
- [ ] Excel 导出包含 ID、内容、分类、标签、创建时间、更新时间字段
- [ ] JSON 导出包含完整数据库备份数据
- [ ] 筛选导出功能正常工作（按分类、按时间范围）

## 导入服务验证
- [ ] ImportService 类已创建，包含 Excel 和 JSON 导入方法
- [ ] Excel 导入能正确解析文件内容并创建灵感记录
- [ ] JSON 导入能正确恢复数据
- [ ] 冲突处理策略（覆盖/跳过/合并）已实现
- [ ] 导入时触发 AI 分析选项已实现

## 用例验证
- [ ] ExportIdeasUseCase 已创建并正确封装导出逻辑
- [ ] ImportIdeasUseCase 已创建并正确封装导入逻辑

## 页面集成验证
- [ ] 数据管理页面已添加导出按钮和导出选项对话框
- [ ] 数据管理页面已添加导入按钮和文件选择器
- [ ] 导出进度提示已实现
- [ ] 导入进度提示和结果反馈已实现

## Provider 集成验证
- [ ] 导出/导入服务 Provider 已添加到 app_providers.dart
- [ ] 依赖注入正确配置

## 代码质量验证
- [ ] `flutter analyze` 无错误
- [ ] `flutter test` 全部通过
