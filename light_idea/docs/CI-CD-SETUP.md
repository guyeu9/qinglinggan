# GitHub Actions CI/CD 配置说明

本文档说明如何配置 GitHub Actions 自动构建 Android 安装包。

## 一、工作流触发条件

| 触发方式 | 条件 | 构建类型 |
|---------|------|---------|
| Push 到 main/master | `main` 或 `master` 分支 | Release APK + AAB |
| Push 到 develop | `develop` 分支 | Release APK |
| 创建 Tag | `v*` 格式（如 v1.0.0） | Release APK + AAB + 自动发布 |
| Pull Request | 任意 PR | Debug APK |
| 手动触发 | workflow_dispatch | 可选 Release/Debug |

## 二、必需配置

### 2.1 配置 GitHub Secrets

进入 GitHub 仓库 → Settings → Secrets and variables → Actions → New repository secret

需要配置以下 Secrets：

| Secret 名称 | 说明 | 获取方式 |
|------------|------|---------|
| `ANDROID_KEYSTORE_BASE64` | 签名密钥库的 Base64 编码 | 见下方说明 |
| `ANDROID_KEY_ALIAS` | 密钥别名 | 创建密钥时指定 |
| `ANDROID_KEY_PASSWORD` | 密钥密码 | 创建密钥时指定 |
| `ANDROID_STORE_PASSWORD` | 密钥库密码 | 创建密钥时指定 |

### 2.2 创建签名密钥

#### 方法一：使用 Android Studio 创建

1. 打开 Android Studio
2. Build → Generate Signed Bundle/APK
3. 选择 APK → Next
4. 点击 "Create new..." 创建新密钥
5. 填写密钥信息并保存

#### 方法二：使用命令行创建

```bash
# 在项目 android/app 目录下执行
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias light-idea

# 按提示输入：
# - 密钥库密码
# - 密钥密码
# - 姓名、组织等信息
```

### 2.3 将密钥转换为 Base64

```bash
# macOS/Linux
base64 -i android/app/keystore.jks | pbcopy

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\keystore.jks")) | Set-Clipboard

# 或者直接输出到文件
base64 -i android/app/keystore.jks -o keystore_base64.txt
```

将输出的 Base64 字符串粘贴到 GitHub Secret `ANDROID_KEYSTORE_BASE64`。

## 三、工作流说明

### 3.1 构建流程

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions 工作流                      │
├─────────────────────────────────────────────────────────────┤
│  1. Checkout 代码                                            │
│       ↓                                                      │
│  2. 设置 Java 17 环境                                         │
│       ↓                                                      │
│  3. 设置 Flutter 环境                                         │
│       ↓                                                      │
│  4. 安装依赖 (flutter pub get)                               │
│       ↓                                                      │
│  5. 代码生成 (build_runner)                                   │
│       ↓                                                      │
│  6. 代码分析 (flutter analyze)                               │
│       ↓                                                      │
│  7. 运行测试 (flutter test)                                  │
│       ↓                                                      │
│  8. 配置签名密钥 (仅 Release)                                  │
│       ↓                                                      │
│  9. 构建 APK/AAB                                             │
│       ↓                                                      │
│  10. 上传构建产物                                             │
│       ↓                                                      │
│  11. 创建 Release (仅 Tag 触发)                               │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 构建产物

| 产物名称 | 说明 | 保留时间 |
|---------|------|---------|
| `light-idea-apk` | APK 安装包 | 30 天 |
| `light-idea-aab` | Android App Bundle | 30 天 |
| `coverage-report` | 测试覆盖率报告 | 7 天 |

## 四、发布流程

### 4.1 创建新版本发布

```bash
# 1. 更新版本号
# 编辑 pubspec.yaml 中的 version 字段

# 2. 提交更改
git add .
git commit -m "chore: bump version to 1.0.1"

# 3. 创建标签
git tag v1.0.1

# 4. 推送代码和标签
git push origin main --tags
```

### 4.2 自动发布

当推送 `v*` 格式的标签时，工作流会自动：

1. 构建 Release APK 和 AAB
2. 创建 GitHub Release
3. 上传构建产物到 Release

## 五、本地测试

### 5.1 本地构建 APK

```bash
# Debug 版本
flutter build apk --debug

# Release 版本
flutter build apk --release

# App Bundle (用于 Google Play)
flutter build appbundle --release
```

### 5.2 构建产物位置

```
build/app/outputs/
├── flutter-apk/
│   ├── app-debug.apk
│   └── app-release.apk
└── bundle/
    └── release/
        └── app-release.aab
```

## 六、故障排除

### 6.1 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 签名失败 | Secrets 未配置 | 检查 GitHub Secrets 是否正确设置 |
| 构建超时 | 依赖下载慢 | 检查网络连接，或使用缓存 |
| 测试失败 | 代码问题 | 查看工作流日志，修复测试用例 |
| 代码分析失败 | Lint 错误 | 运行 `flutter analyze` 查看详情 |

### 6.2 查看构建日志

1. 进入 GitHub 仓库
2. 点击 Actions 标签
3. 选择对应的工作流运行记录
4. 查看各步骤的详细日志

### 6.3 下载构建产物

1. 进入工作流运行记录
2. 滚动到页面底部的 "Artifacts" 区域
3. 点击下载对应的产物

## 七、安全注意事项

### 7.1 密钥安全

- ✅ **永远不要**将密钥文件提交到 Git
- ✅ 使用 GitHub Secrets 存储敏感信息
- ✅ 定期更换签名密钥
- ✅ 限制仓库的写入权限

### 7.2 已配置的忽略规则

以下文件已被 `.gitignore` 忽略：

```
android/key.properties
android/app/keystore.jks
*.jks
*.keystore
*.env
.env.*
secrets.json
```

## 八、进阶配置

### 8.1 自定义 Flutter 版本

编辑 `.github/workflows/android-build.yml`：

```yaml
env:
  FLUTTER_VERSION: '3.24.0'  # 修改为你需要的版本
```

### 8.2 添加构建缓存

工作流已配置 Flutter 缓存，可加速后续构建。

### 8.3 多渠道打包

如需多渠道打包，可在 `build.gradle.kts` 中配置 flavor：

```kotlin
android {
    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
        }
        create("prod") {
            dimension = "environment"
        }
    }
}
```

---

**文档更新时间：2026-03-13**
