# 路由导航系统任务列表

## 任务 1: 创建路由名称常量文件
**文件**: `lib/core/router/route_names.dart`

**验证方法**:
- 文件成功创建
- 包含所有8个路由名称常量
- 使用静态常量定义，便于 IDE 自动补全

---

## 任务 2: 创建 AppRouter 配置
**文件**: `lib/core/router/app_router.dart`

**验证方法**:
- 文件成功创建
- 配置包含所有8个路由
- `/idea/:id` 路由正确配置路径参数
- 所有页面使用 Placeholder 作为占位符
- 导出 router 实例供 main.dart 使用

---

## 任务 3: 更新 main.dart
**文件**: `lib/main.dart`

**验证方法**:
- 导入 app_router.dart
- 替换 MaterialApp 为 MaterialApp.router
- 配置 routerConfig 使用 appRouter
- 应用能正常启动无报错

---

## 任务 4: 更新记录
**文件**: `更新记录.md`

**验证方法**:
- 在根目录创建/更新记录文件
- 记录本次路由导航系统的所有变更
