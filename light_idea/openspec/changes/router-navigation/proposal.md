# 路由导航系统提案

## Context
当前项目使用基础的 MaterialApp 和静态 home 页面。为了支持多页面导航和更好的用户体验，需要引入 go_router 包来构建声明式路由系统。

## Scope

### 新建文件
1. `lib/core/router/route_names.dart` - 路由名称常量定义
2. `lib/core/router/app_router.dart` - go_router 配置

### 修改文件
1. `lib/main.dart` - 替换 MaterialApp 为 MaterialApp.router

## Behavior

### 路由配置

| 路径 | 名称 | 描述 | 参数 |
|------|------|------|------|
| `/` | home | 首页 | 无 |
| `/idea/:id` | ideaDetail | 灵感详情页 | id: String |
| `/recycle-bin` | recycleBin | 回收站 | 无 |
| `/data-management` | dataManagement | 数据管理 | 无 |
| `/settings` | settings | 设置 | 无 |
| `/ai-hub` | aiHub | AI灵感中心 | 无 |
| `/ai-settings` | aiSettings | AI设置 | 无 |
| `/help` | help | 帮助 | 无 |

### 页面占位符
所有页面暂时使用 `Placeholder` Widget，附带页面名称文本。

### 导航方式
- 使用 `context.go()` 进行导航
- 使用 `context.goNamed()` 进行命名路由导航
- 使用 `context.pop()` 返回上一页

## Risks
- 需要确保 go_router 包已在 pubspec.yaml 中声明（已确认存在）
- 需要更新 main.dart 中的导入和配置
- 所有现有页面引用需要后续替换为实际页面 Widget

## 依赖
- `go_router: ^14.2.0` (已在 pubspec.yaml 中)
