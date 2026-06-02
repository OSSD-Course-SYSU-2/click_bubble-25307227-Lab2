# 多端部署指南

## 概述

本项目已实现一次开发、多端部署的能力，支持以下平台：

- **Phone（手机）** - 标准手机设备
- **Tablet（平板）** - 大屏平板设备
- **TV（电视）** - 智能电视设备
- **Wearable（手表）** - 智能手表设备
- **2in1（二合一设备）** - 平板电脑模式

## 架构设计

### 1. 平台适配层（PlatformAdapter）

核心适配器位于：`entry/src/main/ets/utils/PlatformAdapter.ets`

**主要功能：**
- 自动检测设备类型
- 提供平台相关的配置参数
- 响应式UI尺寸计算
- 输入方式适配（触摸/键盘/遥控器）

**使用示例：**

```typescript
import { PlatformAdapter, DeviceType } from '../utils/PlatformAdapter';

// 获取平台适配器实例
const platform = PlatformAdapter.getInstance();

// 获取当前设备类型
const deviceType = platform.getDeviceType();
console.log('当前设备:', deviceType);

// 获取平台配置
const config = platform.getConfig();
console.log('泡泡大小:', config.bubbleSize);
console.log('字体大小:', config.fontSize);

// 响应式布局
if (platform.isLargeScreen()) {
    // 大屏设备逻辑
}

// 获取UI缩放比例
const scale = platform.getUIScale();
```

### 2. 平台配置文件

各平台配置文件位于 `platforms/` 目录：

```
platforms/
├── phone/
│   └── module.json5       # 手机配置
├── tablet/
│   └── module.json5       # 平板配置
├── tv/
│   └── module.json5       # 电视配置
├── wearable/
│   └── module.json5       # 手表配置
└── 2in1/
    └── module.json5       # 二合一设备配置
```

### 3. 构建配置

多端构建配置文件：`build-profile.multi.json5`

包含所有平台的产品配置，支持独立构建每个平台。

## 使用方法

### 方式一：使用构建脚本（推荐）

#### Windows PowerShell

```powershell
# 构建所有平台（debug模式）
.\scripts\build-multi-platform.ps1

# 构建指定平台
.\scripts\build-multi-platform.ps1 -Platform phone

# 构建release版本
.\scripts\build-multi-platform.ps1 -BuildMode release

# 清理后构建
.\scripts\build-multi-platform.ps1 -Clean

# 组合使用
.\scripts\build-multi-platform.ps1 -Platform tablet -BuildMode release -Clean
```

#### Linux/macOS Bash

```bash
# 添加执行权限
chmod +x scripts/build-multi-platform.sh

# 构建所有平台
./scripts/build-multi-platform.sh

# 构建指定平台
./scripts/build-multi-platform.sh -p phone

# 构建release版本
./scripts/build-multi-platform.sh -m release

# 清理后构建
./scripts/build-multi-platform.sh -c

# 组合使用
./scripts/build-multi-platform.sh -p tablet -m release -c
```

### 方式二：手动构建

```bash
# 1. 复制目标平台配置
cp platforms/phone/module.json5 entry/src/main/module.json5

# 2. 执行构建命令
hvigorw assembleHap --mode module -p product=phone

# 3. 构建release版本
hvigorw assembleHap --mode module -p product=phone -p buildMode=release
```

## 平台特性适配

### Phone（手机）

- **屏幕尺寸**：标准手机尺寸（1080x2340等）
- **泡泡大小**：50px
- **字体大小**：16px
- **列数**：8列
- **最大泡泡数**：30个
- **输入方式**：触摸屏

### Tablet（平板）

- **屏幕尺寸**：大屏尺寸（>1200x900）
- **泡泡大小**：70px
- **字体大小**：20px
- **列数**：12列
- **最大泡泡数**：50个
- **输入方式**：触摸屏
- **布局**：使用70%宽度居中显示

### TV（电视）

- **屏幕尺寸**：超大屏（>1920x1080）
- **泡泡大小**：80px
- **字体大小**：24px
- **列数**：10列
- **最大泡泡数**：40个
- **输入方式**：遥控器
- **动画速度**：0.8x（更流畅）
- **布局**：使用70%宽度居中显示

### Wearable（手表）

- **屏幕尺寸**：小屏（<200dp）
- **泡泡大小**：30px
- **字体大小**：12px
- **列数**：4列
- **最大泡泡数**：15个
- **输入方式**：触摸屏
- **动画速度**：1.2x（更快）
- **布局**：全屏显示，游戏区域占60%
- **特殊**：圆形屏幕适配

### 2in1（二合一设备）

- **屏幕尺寸**：中等尺寸（>1000dp）
- **泡泡大小**：65px
- **字体大小**：18px
- **列数**：10列
- **最大泡泡数**：45个
- **输入方式**：触摸屏 + 键盘
- **布局**：使用70%宽度居中显示

## 在代码中使用平台适配

### 示例1：响应式泡泡大小

```typescript
import { PlatformAdapter } from '../utils/PlatformAdapter';

@Component
struct GameCanvas {
    private platform = PlatformAdapter.getInstance();

    build() {
        Stack() {
            // 使用平台适配的泡泡大小
            ForEach(this.bubbles, (bubble: Bubble) => {
                Circle()
                    .width(this.platform.getBubbleSize())
                    .height(this.platform.getBubbleSize())
                    .fill(bubble.color)
            })
        }
    }
}
```

### 示例2：响应式字体大小

```typescript
import { PlatformAdapter } from '../utils/PlatformAdapter';

@Component
struct GameUI {
    private platform = PlatformAdapter.getInstance();

    build() {
        Column() {
            Text('解压泡泡龙')
                .fontSize(this.platform.getFontSize(1.5)) // 1.5倍字体大小
                .fontWeight(FontWeight.Bold)

            Text(`分数: ${this.score}`)
                .fontSize(this.platform.getFontSize()) // 标准字体大小
        }
    }
}
```

### 示例3：平台特定逻辑

```typescript
import { PlatformAdapter, DeviceType } from '../utils/PlatformAdapter';

@Component
struct GamePage {
    private platform = PlatformAdapter.getInstance();

    build() {
        Column() {
            // 根据平台显示不同的控制按钮
            if (this.platform.hasTouchScreen()) {
                Button('触摸操作')
                    .onClick(() => this.handleTouch())
            }

            if (this.platform.hasKeyboard()) {
                Button('键盘操作')
                    .onClick(() => this.handleKeyboard())
            }

            if (this.platform.hasRemoteControl()) {
                Button('遥控器操作')
                    .onClick(() => this.handleRemoteControl())
            }
        }
    }
}
```

### 示例4：响应式布局

```typescript
import { PlatformAdapter } from '../utils/PlatformAdapter';

@Component
struct ShopPage {
    private platform = PlatformAdapter.getInstance();

    build() {
        Column() {
            Grid() {
                ForEach(this.items, (item: Item) => {
                    GridItem() {
                        this.ItemCard(item)
                    }
                })
            }
            .columnsTemplate(this.getColumnsTemplate())
            .width(this.platform.getLayoutWidthPercent())
        }
    }

    private getColumnsTemplate(): string {
        const columns = this.platform.getColumns();
        return `1fr `.repeat(columns).trim();
    }
}
```

## 构建产物

构建完成后，HAP文件位于：

```
build/outputs/
├── phone/
│   └── entry-default-signed.hap
├── tablet/
│   └── entry-default-signed.hap
├── tv/
│   └── entry-default-signed.hap
├── wearable/
│   └── entry-default-signed.hap
└── 2in1/
    └── entry-default-signed.hap
```

## 最佳实践

### 1. 使用平台适配器

始终使用 `PlatformAdapter` 获取尺寸和配置，避免硬编码：

```typescript
// ❌ 不推荐
Circle().width(50).height(50)

// ✅ 推荐
Circle()
    .width(this.platform.getBubbleSize())
    .height(this.platform.getBubbleSize())
```

### 2. 响应式布局

使用百分比和自适应布局：

```typescript
// ❌ 不推荐
Column().width(400)

// ✅ 推荐
Column().width(this.platform.getLayoutWidthPercent())
```

### 3. 条件渲染

根据平台特性进行条件渲染：

```typescript
if (this.platform.isLargeScreen()) {
    // 大屏特有UI
} else {
    // 小屏UI
}
```

### 4. 性能优化

根据平台调整性能参数：

```typescript
// 手表上减少粒子数量
const particleCount = this.platform.getDeviceType() === DeviceType.WEARABLE
    ? 10
    : 30;
```

## 调试技巧

### 打印设备信息

```typescript
const platform = PlatformAdapter.getInstance();
platform.printDeviceInfo();
```

输出示例：
```
=== Platform Info ===
Device Type: phone
Screen: 1080x2340
Density: 3
Bubble Size: 50
Font Size: 16
Columns: 8
Max Bubbles: 30
Animation Speed: 1
=====================
```

## 注意事项

1. **测试覆盖**：建议在所有目标平台上进行测试
2. **性能差异**：不同平台性能差异较大，注意优化
3. **输入方式**：TV平台需要适配遥控器操作
4. **屏幕形状**：Wearable可能是圆形屏幕
5. **资源管理**：大屏设备可能需要更高清的资源

## 更新日志

### v1.0.0 (2026-06-02)
- 初始实现多端部署架构
- 支持5个平台：Phone、Tablet、TV、Wearable、2in1
- 实现PlatformAdapter平台适配层
- 添加自动化构建脚本
- 完善文档和使用示例
