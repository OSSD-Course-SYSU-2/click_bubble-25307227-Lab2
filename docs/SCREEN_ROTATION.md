# 屏幕旋转功能使用指南

## 概述

本项目已实现屏幕自由旋转功能，支持横屏和竖屏模式自动切换，提供最佳的游戏体验。

## 功能特性

### 1. 自动旋转
- 支持设备物理旋转时自动切换横竖屏
- 游戏区域和UI布局自动适配屏幕方向
- 无需手动干预，跟随设备方向

### 2. 方向锁定
- 可锁定当前屏幕方向，防止游戏过程中意外旋转
- 支持一键解锁，恢复自动旋转
- 锁定状态会保存，避免误操作

### 3. 手动切换
- 提供手动切换横竖屏的按钮
- 即使在锁定状态下也可通过按钮切换
- 切换过程平滑流畅

## 使用方法

### 方式一：使用旋转控制组件

在页面中添加旋转控制组件：

```typescript
import { RotationControl, SimpleRotationButton } from '../components/RotationControl';

@Component
struct GamePage {
  build() {
    Column() {
      // 完整版旋转控制（包含旋转和锁定按钮）
      RotationControl()

      // 或者使用简化版（只有旋转按钮）
      SimpleRotationButton()

      // 游戏内容
      // ...
    }
  }
}
```

### 方式二：直接使用ScreenRotationManager

```typescript
import { ScreenRotationManager, Orientation } from '../utils/ScreenRotationManager';

@Component
struct MyPage {
  private rotationManager: ScreenRotationManager = ScreenRotationManager.getInstance();

  build() {
    Column() {
      Button('切换横竖屏')
        .onClick(async () => {
          await this.rotationManager.toggleOrientation();
        })

      Button('锁定方向')
        .onClick(async () => {
          await this.rotationManager.lockOrientation();
        })

      Button('解锁方向')
        .onClick(async () => {
          await this.rotationManager.unlockOrientation();
        })

      Button('设置为横屏')
        .onClick(async () => {
          await this.rotationManager.setOrientation(Orientation.LANDSCAPE);
        })

      Button('设置为竖屏')
        .onClick(async () => {
          await this.rotationManager.setOrientation(Orientation.PORTRAIT);
        })
    }
  }
}
```

### 方式三：监听方向变化

```typescript
import { ScreenRotationManager, Orientation } from '../utils/ScreenRotationManager';

@Component
struct MyPage {
  @State private isLandscape: boolean = false;
  private rotationManager: ScreenRotationManager = ScreenRotationManager.getInstance();

  aboutToAppear() {
    // 注册方向变化监听
    this.rotationManager.onOrientationChange((orientation: Orientation) => {
      console.log('屏幕方向变化:', orientation);
      this.isLandscape = orientation === Orientation.LANDSCAPE ||
                         orientation === Orientation.LANDSCAPE_INVERTED;

      // 根据方向调整布局
      this.adjustLayout();
    });
  }

  aboutToDisappear() {
    // 移除监听器（实际使用时应该移除特定的回调）
  }

  adjustLayout() {
    // 根据方向调整布局逻辑
    if (this.isLandscape) {
      // 横屏布局
    } else {
      // 竖屏布局
    }
  }

  build() {
    // ...
  }
}
```

## API 参考

### ScreenRotationManager

#### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `getInstance()` | 无 | ScreenRotationManager | 获取单例实例 |
| `init(windowStage)` | WindowStage | Promise\<void\> | 初始化窗口管理 |
| `setOrientation(orientation)` | Orientation | Promise\<boolean\> | 设置屏幕方向 |
| `toggleOrientation()` | 无 | Promise\<boolean\> | 切换横竖屏 |
| `lockOrientation()` | 无 | Promise\<boolean\> | 锁定当前方向 |
| `unlockOrientation()` | 无 | Promise\<boolean\> | 解锁方向 |
| `getOrientation()` | 无 | Orientation | 获取当前方向 |
| `isLandscape()` | 无 | boolean | 是否为横屏 |
| `isPortrait()` | 无 | boolean | 是否为竖屏 |
| `isOrientationLocked()` | 无 | boolean | 是否已锁定 |
| `getScreenInfo()` | 无 | ScreenInfo | 获取屏幕信息 |
| `getGameAreaSize()` | 无 | {width, height} | 获取游戏区域尺寸 |
| `getUIScale()` | 无 | number | 获取UI缩放比例 |
| `getColumns()` | 无 | number | 获取列数 |
| `onOrientationChange(callback)` | Function | void | 注册方向变化回调 |

### Orientation 枚举

| 值 | 说明 |
|----|------|
| `PORTRAIT` | 竖屏 |
| `LANDSCAPE` | 横屏 |
| `PORTRAIT_INVERTED` | 反向竖屏 |
| `LANDSCAPE_INVERTED` | 反向横屏 |
| `UNSPECIFIED` | 未指定，跟随系统 |

### ScreenInfo 接口

```typescript
interface ScreenInfo {
  width: number;           // 屏幕宽度
  height: number;          // 屏幕高度
  orientation: Orientation; // 当前方向
  isLandscape: boolean;    // 是否横屏
  isPortrait: boolean;     // 是否竖屏
  density: number;         // 屏幕密度
}
```

## 响应式布局示例

### 示例1：根据方向调整游戏区域

```typescript
import { ScreenRotationManager } from '../utils/ScreenRotationManager';

@Component
struct GameCanvas {
  private rotationManager: ScreenRotationManager = ScreenRotationManager.getInstance();
  @State private gameWidth: number = 0;
  @State private gameHeight: number = 0;

  aboutToAppear() {
    this.updateGameSize();
    this.rotationManager.onOrientationChange(() => {
      this.updateGameSize();
    });
  }

  updateGameSize() {
    const size = this.rotationManager.getGameAreaSize();
    this.gameWidth = size.width;
    this.gameHeight = size.height;
  }

  build() {
    Stack() {
      // 游戏内容
    }
    .width(this.gameWidth)
    .height(this.gameHeight)
  }
}
```

### 示例2：根据方向调整列数

```typescript
import { ScreenRotationManager } from '../utils/ScreenRotationManager';

@Component
struct LevelGrid {
  private rotationManager: ScreenRotationManager = ScreenRotationManager.getInstance();
  @State private columns: number = 8;

  aboutToAppear() {
    this.columns = this.rotationManager.getColumns();
    this.rotationManager.onOrientationChange(() => {
      this.columns = this.rotationManager.getColumns();
    });
  }

  build() {
    Grid() {
      // ...
    }
    .columnsTemplate(`1fr `.repeat(this.columns).trim())
  }
}
```

### 示例3：根据方向显示不同布局

```typescript
import { ScreenRotationManager } from '../utils/ScreenRotationManager';

@Component
struct AdaptiveLayout {
  private rotationManager: ScreenRotationManager = ScreenRotationManager.getInstance();
  @State private isLandscape: boolean = false;

  aboutToAppear() {
    this.isLandscape = this.rotationManager.isLandscape();
    this.rotationManager.onOrientationChange((orientation) => {
      this.isLandscape = orientation === Orientation.LANDSCAPE ||
                         orientation === Orientation.LANDSCAPE_INVERTED;
    });
  }

  build() {
    if (this.isLandscape) {
      // 横屏布局
      Row() {
        this.LeftPanel()
        this.RightPanel()
      }
    } else {
      // 竖屏布局
      Column() {
        this.TopPanel()
        this.BottomPanel()
      }
    }
  }

  @Builder
  LeftPanel() {
    // ...
  }

  @Builder
  RightPanel() {
    // ...
  }

  @Builder
  TopPanel() {
    // ...
  }

  @Builder
  BottomPanel() {
    // ...
  }
}
```

## 配置说明

### module.json5 配置

在 `entry/src/main/module.json5` 中已配置：

```json5
{
  "module": {
    "abilities": [
      {
        "orientation": "unspecified",  // 支持所有方向
        "supportWindowMode": ["fullscreen", "split", "floating"]  // 支持多种窗口模式
      }
    ]
  }
}
```

### 支持的设备类型

- Phone（手机）
- Tablet（平板）
- 2in1（二合一设备）

注意：TV和Wearable设备通常不支持旋转，因此不在默认支持列表中。

## 最佳实践

### 1. 游戏中锁定方向

在游戏进行时建议锁定方向，避免意外旋转影响游戏体验：

```typescript
onPageShow() {
  // 游戏开始时锁定方向
  this.rotationManager.lockOrientation();
}

onPageHide() {
  // 离开页面时解锁
  this.rotationManager.unlockOrientation();
}
```

### 2. 平滑过渡

使用动画实现平滑的方向切换：

```typescript
@Component
struct SmoothTransition {
  @State private scale: number = 1.0;

  build() {
    Column() {
      // 内容
    }
    .scale({ x: this.scale, y: this.scale })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }
}
```

### 3. 保存用户偏好

记住用户的屏幕方向偏好：

```typescript
// 保存偏好
const preferences = await dataPreferences.getPreferences(context, 'game_settings');
await preferences.put('preferredOrientation', this.rotationManager.getOrientation());

// 读取偏好
const savedOrientation = await preferences.get('preferredOrientation', Orientation.UNSPECIFIED);
await this.rotationManager.setOrientation(savedOrientation);
```

## 注意事项

1. **性能考虑**：方向切换时会触发重新布局，注意优化性能
2. **状态保存**：方向切换时注意保存游戏状态
3. **动画流畅**：使用适当的动画过渡，避免突兀的切换
4. **用户习惯**：尊重用户的屏幕方向偏好
5. **设备限制**：某些设备可能不支持所有方向

## 调试技巧

打印屏幕信息：

```typescript
const rotationManager = ScreenRotationManager.getInstance();
rotationManager.printScreenInfo();
```

输出示例：
```
=== Screen Info ===
Size: 2340x1080
Orientation: landscape
Is Landscape: true
Is Portrait: false
Is Locked: false
===================
```

## 更新日志

### v1.1.0 (2026-06-02)
- 实现屏幕自由旋转功能
- 添加ScreenRotationManager管理器
- 创建RotationControl控制组件
- 支持方向锁定和手动切换
- 完善响应式布局支持
