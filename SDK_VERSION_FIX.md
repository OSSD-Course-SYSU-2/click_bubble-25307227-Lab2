# SDK版本不匹配问题解决方案

## 错误信息
```
compatibleSdkVersion and releaseType of the app do not match the apiVersion and releaseType on the device.
```

## 问题分析

这个错误表示应用的SDK版本与设备的API版本不匹配。当前项目配置：
- **targetSdkVersion**: 6.0.2(22)
- **compatibleSdkVersion**: 6.0.2(22)

## 解决方案

### 方案1：检查设备系统版本（推荐）

首先确认您的华为MatePad Pro 11的系统版本：

```bash
hdc shell param get const.product.software.version
```

或者：
```bash
hdc shell getprop hw_sc.build.platform.version
```

**可能的设备版本**：
- HarmonyOS 4.0 (API 10)
- HarmonyOS 5.0 (API 11)
- HarmonyOS 5.0.1 (API 12)

### 方案2：调整SDK版本以匹配设备

根据您的设备版本，修改以下文件：

#### 如果设备是 HarmonyOS 4.0 (API 10)：

修改 `build-profile.json5` 和 `build-profile.multi.json5`：

```json5
{
  "targetSdkVersion": "5.0.0(12)",
  "compatibleSdkVersion": "5.0.0(12)"
}
```

#### 如果设备是 HarmonyOS 5.0 (API 11)：

```json5
{
  "targetSdkVersion": "5.0.1(13)",
  "compatibleSdkVersion": "5.0.1(13)"
}
```

#### 如果设备是 HarmonyOS 5.0.1 (API 12)：

```json5
{
  "targetSdkVersion": "6.0.2(22)",
  "compatibleSdkVersion": "6.0.2(22)"
}
```

### 方案3：使用DevEco Studio自动匹配

1. 打开DevEco Studio
2. 进入 `File > Project Structure`
3. 选择 `Project` 标签页
4. 在 `SDK Version` 部分：
   - 点击 `Compatible SDK` 下拉框
   - 选择与设备匹配的版本
   - 点击 `Apply` 和 `OK`

### 方案4：检查oh-package.json5配置

查看 `oh-package.json5` 文件中的SDK版本：

```json5
{
  "dependencies": {
    "@ohos/hypium": "1.0.16"
  },
  "devDependencies": {},
  "dynamicDependencies": {},
  "overrides": {
    "@ohos/hypium": "1.0.18"
  }
}
```

### 方案5：更新SDK和工具链

1. 打开DevEco Studio
2. 进入 `File > Settings`
3. 选择 `HarmonyOS SDK`
4. 点击 `Edit` 或 `Update` 更新SDK到最新版本

## 详细修改步骤

### 步骤1：备份当前配置

```bash
cp build-profile.json5 build-profile.json5.backup
cp build-profile.multi.json5 build-profile.multi.json5.backup
```

### 步骤2：修改单端构建配置

编辑 `build-profile.json5`：

```json5
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "targetSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "compatibleSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "runtimeOS": "HarmonyOS",
        "buildOption": {
          "strictMode": {
            "caseSensitiveCheck": true,
            "useNormalizedOHMUrl": true
          }
        }
      }
    ],
    "buildModeSet": [
      {
        "name": "debug"
      },
      {
        "name": "release"
      }
    ]
  },
  "modules": [
    {
      "name": "entry",
      "srcPath": "./entry",
      "targets": [
        {
          "name": "default",
          "applyToProducts": [
            "default"
          ]
        }
      ]
    }
  ]
}
```

### 步骤3：修改多端构建配置

编辑 `build-profile.multi.json5`，将所有产品的SDK版本统一修改：

```json5
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "phone",
        "signingConfig": "default",
        "targetSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "compatibleSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "runtimeOS": "HarmonyOS",
        "buildOption": {
          "strictMode": {
            "caseSensitiveCheck": true,
            "useNormalizedOHMUrl": true
          }
        }
      },
      {
        "name": "tablet",
        "signingConfig": "default",
        "targetSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "compatibleSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "runtimeOS": "HarmonyOS",
        "buildOption": {
          "strictMode": {
            "caseSensitiveCheck": true,
            "useNormalizedOHMUrl": true
          }
        }
      },
      {
        "name": "tv",
        "signingConfig": "default",
        "targetSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "compatibleSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "runtimeOS": "HarmonyOS",
        "buildOption": {
          "strictMode": {
            "caseSensitiveCheck": true,
            "useNormalizedOHMUrl": true
          }
        }
      },
      {
        "name": "wearable",
        "signingConfig": "default",
        "targetSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "compatibleSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "runtimeOS": "HarmonyOS",
        "buildOption": {
          "strictMode": {
            "caseSensitiveCheck": true,
            "useNormalizedOHMUrl": true
          }
        }
      },
      {
        "name": "2in1",
        "signingConfig": "default",
        "targetSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "compatibleSdkVersion": "5.0.0(12)",  // 修改为匹配设备的版本
        "runtimeOS": "HarmonyOS",
        "buildOption": {
          "strictMode": {
            "caseSensitiveCheck": true,
            "useNormalizedOHMUrl": true
          }
        }
      }
    ],
    "buildModeSet": [
      {
        "name": "debug"
      },
      {
        "name": "release"
      }
    ]
  },
  "modules": [
    {
      "name": "entry",
      "srcPath": "./entry",
      "targets": [
        {
          "name": "default",
          "applyToProducts": [
            "phone",
            "tablet",
            "tv",
            "wearable",
            "2in1"
          ]
        }
      ]
    }
  ]
}
```

### 步骤4：清理构建缓存

```bash
hvigorw clean
```

### 步骤5：重新构建

```bash
# 构建平板版本
hvigorw assembleHap --mode module -p product=tablet -p module=entry@default
```

## SDK版本对照表

| HarmonyOS版本 | API版本 | targetSdkVersion | compatibleSdkVersion |
|---------------|---------|------------------|---------------------|
| HarmonyOS 4.0 | API 10 | 5.0.0(12) | 5.0.0(12) |
| HarmonyOS 5.0 | API 11 | 5.0.1(13) | 5.0.1(13) |
| HarmonyOS 5.0.1 | API 12 | 6.0.2(22) | 6.0.2(22) |

## 华为MatePad Pro 11常见版本

华为MatePad Pro 11可能运行的系统版本：

1. **出厂版本**: HarmonyOS 3.0 (API 9)
2. **升级版本**: HarmonyOS 4.0 (API 10)
3. **最新版本**: HarmonyOS 5.0/5.0.1 (API 11/12)

## 验证修复

### 方法1：使用hdc命令

```bash
# 检查设备连接
hdc list targets

# 获取设备版本
hdc shell getprop hw_sc.build.platform.version

# 安装应用
hdc install entry/build/default/outputs/default/entry-default-signed.hap
```

### 方法2：使用DevEco Studio

1. 连接设备
2. 点击运行按钮
3. 查看控制台输出

## 常见问题

### Q1: 修改后仍然报错？
**A**: 请确保：
- 修改了所有相关的配置文件（build-profile.json5 和 build-profile.multi.json5）
- 清理了构建缓存（`hvigorw clean`）
- 重新构建了应用

### Q2: 如何确定设备的API版本？
**A**: 使用以下命令：
```bash
hdc shell getprop hw_sc.build.platform.version
```

### Q3: targetSdkVersion和compatibleSdkVersion有什么区别？
**A**:
- **targetSdkVersion**: 应用目标SDK版本，指定应用使用的API级别
- **compatibleSdkVersion**: 应用兼容的最低SDK版本，确保应用可以在该版本及以上运行

### Q4: 可以设置不同的targetSdkVersion和compatibleSdkVersion吗？
**A**: 可以，但需要注意：
- targetSdkVersion应该 >= compatibleSdkVersion
- compatibleSdkVersion应该 <= 设备的API版本

## 推荐配置

### 向后兼容配置（推荐）

如果不确定设备版本，可以使用较低的compatibleSdkVersion：

```json5
{
  "targetSdkVersion": "6.0.2(22)",
  "compatibleSdkVersion": "5.0.0(12)"
}
```

这样应用可以在API 10及以上版本运行。

### 最新特性配置

如果需要使用最新API特性：

```json5
{
  "targetSdkVersion": "6.0.2(22)",
  "compatibleSdkVersion": "6.0.2(22)"
}
```

## 获取帮助

如果问题仍未解决：

1. 查看DevEco Studio的详细错误日志
2. 访问HarmonyOS开发者文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-project-profile-0000001774281190
3. 在HarmonyOS开发者社区提问：https://developer.huawei.com/consumer/cn/forum/home

## 快速修复脚本

创建并运行以下PowerShell脚本自动修复：

```powershell
# fix_sdk_version.ps1
Write-Host "=== SDK版本修复工具 ===" -ForegroundColor Cyan

Write-Host "请选择您的设备系统版本:" -ForegroundColor Yellow
Write-Host "1. HarmonyOS 4.0 (API 10)" -ForegroundColor Cyan
Write-Host "2. HarmonyOS 5.0 (API 11)" -ForegroundColor Cyan
Write-Host "3. HarmonyOS 5.0.1 (API 12)" -ForegroundColor Cyan

$choice = Read-Host "请选择 (1-3)"

$sdkVersion = switch ($choice) {
    "1" { "5.0.0(12)" }
    "2" { "5.0.1(13)" }
    "3" { "6.0.2(22)" }
    default { "6.0.2(22)" }
}

Write-Host "正在将SDK版本修改为: $sdkVersion" -ForegroundColor Green

# 备份文件
Copy-Item "build-profile.json5" "build-profile.json5.backup" -Force
Copy-Item "build-profile.multi.json5" "build-profile.multi.json5.backup" -Force

# 修改文件
(Get-Content "build-profile.json5") -replace 'targetSdkVersion": ".*"', "targetSdkVersion"": ""$sdkVersion""" | Set-Content "build-profile.json5"
(Get-Content "build-profile.json5") -replace 'compatibleSdkVersion": ".*"', "compatibleSdkVersion"": ""$sdkVersion""" | Set-Content "build-profile.json5"

(Get-Content "build-profile.multi.json5") -replace 'targetSdkVersion": ".*"', "targetSdkVersion"": ""$sdkVersion""" | Set-Content "build-profile.multi.json5"
(Get-Content "build-profile.multi.json5") -replace 'compatibleSdkVersion": ".*"', "compatibleSdkVersion"": ""$sdkVersion""" | Set-Content "build-profile.multi.json5"

Write-Host "✅ SDK版本已修改完成!" -ForegroundColor Green
Write-Host "备份文件: build-profile.json5.backup, build-profile.multi.json5.backup" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "1. 运行: hvigorw clean" -ForegroundColor Cyan
Write-Host "2. 运行: hvigorw assembleHap --mode module -p product=tablet -p module=entry@default" -ForegroundColor Cyan
Write-Host "3. 安装到设备" -ForegroundColor Cyan
```

运行脚本：
```powershell
.\fix_sdk_version.ps1
```

## 总结

SDK版本不匹配是HarmonyOS开发中常见的问题，解决步骤：

1. ✅ 确定设备的API版本
2. ✅ 修改build-profile.json5和build-profile.multi.json5
3. ✅ 清理构建缓存
4. ✅ 重新构建应用
5. ✅ 安装到设备验证

按照以上步骤操作，应该可以解决SDK版本不匹配的问题。
