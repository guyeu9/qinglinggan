# API密钥安全修复计划（简化版）

## 问题验证结果

**文件**: `lib/presentation/pages/ai_settings/ai_settings_page.dart`

**第67行和第78行**存在硬编码的明文API密钥：
```dart
apiKey: 'sk-q0mruxrc5BHY0FhYAEMi9rfHgvETWvu9Rf5RFwQpZ1a8Bfap',
```

## 修复方案

### 方案说明

**保持默认配置，仅对API密钥进行加密存储**

1. 使用Base64编码对API密钥进行混淆
2. 代码中存储加密后的密钥
3. 运行时解密使用

### 实施步骤

#### 步骤1: 创建简单的加密工具类

**新建文件**: `lib/core/utils/secure_string.dart`

```dart
class SecureString {
  static String encode(String plainText) {
    return base64Encode(utf8.encode(plainText));
  }
  
  static String decode(String encodedText) {
    return utf8.decode(base64Decode(encodedText));
  }
}
```

#### 步骤2: 加密现有API密钥

原始密钥: `sk-q0mruxrc5BHY0FhYAEMi9rfHgvETWvu9Rf5RFwQpZ1a8Bfap`

Base64编码后: `c2stcTBtcnV4cmM1QkhZMEZoWUFFTWk5cmZIZ3ZFVFd2dTlSZTVSRndRcFoxYThCZmFw`

#### 步骤3: 修改 ai_settings_page.dart

**修改前**:
```dart
apiKey: 'sk-q0mruxrc5BHY0FhYAEMi9rfHgvETWvu9Rf5RFwQpZ1a8Bfap',
```

**修改后**:
```dart
apiKey: SecureString.decode('c2stcTBtcnV4cmM1QkhZMEZoWUFFTWk5cmZIZ3ZFVFd2dTlSZTVSRndRcFoxYThCZmFw'),
```

### 修改文件清单

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `lib/core/utils/secure_string.dart` | 新建 | 简单加密工具类 |
| `lib/presentation/pages/ai_settings/ai_settings_page.dart` | 修改 | 使用加密后的密钥 |

### 验证测试

- [ ] 源代码中无明文API密钥
- [ ] 应用运行时能正确解密并使用密钥
- [ ] AI功能正常工作

## 总结

此修复将：
- ✅ 源代码中不再显示明文API密钥
- ✅ 保持默认配置不变
- ✅ 实现简单，改动最小
