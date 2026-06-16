# 🫧 解压泡泡龙 - Relaxing Bubble Game

<div align="center">

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-6.0.2-blue)
![ArkTS](https://img.shields.io/badge/ArkTS-1.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Multi-Platform](https://img.shields.io/badge/Multi--Platform-5%20Devices-purple)

**一款基于鸿蒙系统的休闲解压小游戏 - 支持一次开发多端部署**

[功能特性](#功能特性) • [快速开始](#快速开始) • [多端部署](#-多端部署) • [游戏玩法](#游戏玩法) • [项目结构](#项目结构)

</div>

---

## 📖 项目简介

解压泡泡龙是一款专为鸿蒙系统开发的休闲解压游戏。玩家通过点击消除屏幕上的彩色泡泡来获得积分，游戏包含闯关模式、积分系统、商店系统等丰富功能，帮助玩家在忙碌的生活中放松心情。

## 📱 应用预览

<div align="center">

### 应用图标

![应用前景图标](https://raw.githubusercontent.com/OSSD-Course-SYSU-2/click_bubble-25307227/master/AppScope/resources/base/media/foreground.png)

**解压泡泡龙应用图标**

### 应用启动图标

![应用启动图标](https://raw.githubusercontent.com/OSSD-Course-SYSU-2/click_bubble-25307227/master/entry/src/main/resources/base/media/startIcon.png)

**解压泡泡龙启动图标**

</div>

### 🎮 游戏功能展示

#### 核心游戏玩法
- **动态泡泡运动**：泡泡会在游戏区域内持续移动和浮动
- **碰撞反弹**：泡泡碰到边界会自动反弹，保持运动状态
- **点击消除**：点击泡泡获得积分，触发爆炸粒子效果
- **实时反馈**：积分、时间、关卡信息实时更新显示

#### 游戏界面元素
| 界面元素 | 功能说明 |
|---------|---------|
| 🫧 **泡泡区域** | 350x500像素的游戏画布，泡泡在其中自由移动 |
| 📊 **信息栏** | 显示当前关卡、目标分数、实时得分、剩余时间 |
| ⏱️ **倒计时** | 60秒倒计时，时间不足10秒时红色警告 |
| 🎯 **目标分数** | 达到目标分数即可通关，显示"结算"按钮 |
| 💫 **粒子效果** | 点击泡泡时产生爆炸粒子动画 |
| 🛠️ **道具栏** | 游戏进行时显示可用道具，点击即可使用 |

#### 泡泡运动特性
- **移动速度**：每个泡泡有独立的移动速度（3-7像素/帧）
- **随机方向**：泡泡以随机角度开始移动
- **边界反弹**：碰到游戏区域边界自动反弹
- **浮动效果**：在移动基础上叠加正弦波动效果
- **持续运动**：泡泡在游戏开始前就开始运动，点击开始后继续运动

### 功能界面展示

| 功能模块 | 说明 |
|---------|------|
| 🏠 **主界面** | 显示游戏标题、玩家信息（积分、金币）、开始游戏、关卡选择、商店入口 |
| 🎮 **游戏界面** | 泡泡游戏区域、实时积分显示、倒计时、当前关卡信息、暂停按钮 |
| 🎯 **关卡选择** | 50个关卡网格布局、显示通关状态、星级评价、目标分数 |
| 🛒 **道具商店** | 10种道具展示（双倍积分、时间延长、磁铁、炸弹、护盾、三倍积分、超级时间延长、超级磁铁、冰冻、幸运星）、价格和效果说明 |
| ⚔️ **装备升级** | 10种装备升级选项、当前等级、升级费用、效果预览 |
| 🏆 **游戏结果** | 通关/失败提示、获得积分和金币、星级评价、重玩/返回按钮 |

> 💡 **提示**：完整的功能截图请参考 [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md) 文档说明。如需添加实际截图，请将图片放入 `docs/screenshots/` 目录。

## ✨ 功能特性

### 🌐 一次开发，多端部署
本项目实现了真正的"一次开发，多端部署"能力，支持以下5种设备类型：

| 平台 | 设备类型 | 屏幕适配 | 输入方式 | 特殊优化 |
|------|---------|---------|---------|---------|
| 📱 **Phone** | 智能手机 | 标准尺寸 | 触摸屏 | 标准布局，适合单手操作 |
| 📟 **Tablet** | 平板电脑 | 大屏适配 | 触摸屏 | 16列布局，更多泡泡显示，支持屏幕旋转和多窗口 |
| 📺 **TV** | 智能电视 | 超大屏 | 遥控器 | 大字体，遥控器导航优化 |
| ⌚ **Wearable** | 智能手表 | 小屏简化 | 触摸屏 | 精简UI，快速游戏模式 |
| 💻 **2in1** | 二合一设备 | 中等尺寸 | 键盘+触摸 | 支持键盘快捷键 |

**核心优势：**
- ✅ **单一代码库**：一套代码适配所有设备，无需维护多个项目
- ✅ **自动适配**：PlatformAdapter自动检测设备类型并应用最佳配置
- ✅ **响应式布局**：根据屏幕尺寸自动调整UI元素大小和布局
- ✅ **输入适配**：智能识别触摸、键盘、遥控器等不同输入方式
- ✅ **性能优化**：针对不同设备性能调整动画速度和粒子数量

**华为MatePad Pro 11 专属优化：**
- ✅ 泡泡大小：80（更大更易点击）
- ✅ 字体大小：22（更清晰可读）
- ✅ 内边距：25（更舒适的间距）
- ✅ 列数：16（竖屏）/ 20（横屏）
- ✅ 最大泡泡数：80（更丰富的场面）
- ✅ UI缩放：1.4（竖屏）/ 1.5（横屏）
- ✅ 屏幕旋转：支持横竖屏自由切换
- ✅ 多窗口模式：支持全屏、分屏、悬浮窗

**技术实现：**
- 平台适配器：`entry/src/main/ets/utils/PlatformAdapter.ets`
- 多端配置：`platforms/` 目录下的各平台配置文件
- 自动构建：`scripts/` 目录下的多端构建脚本
- 屏幕旋转管理：`entry/src/main/ets/utils/ScreenRotationManager.ets`

### 🔄 屏幕自由旋转
支持设备屏幕自由旋转，提供最佳游戏体验：

- **横屏模式**：更宽阔的游戏视野，适合平板和手机横屏
- **竖屏模式**：标准游戏模式，适合手机竖屏和手表
- **自动适配**：游戏区域和UI布局随屏幕方向自动调整
- **锁定支持**：可选择锁定屏幕方向，防止游戏过程中意外旋转

**支持的方向：**
- portrait (竖屏)
- landscape (横屏)
- portrait_inverted (反向竖屏)
- landscape_inverted (反向横屏)
- unspecified (跟随系统)

**使用方法：**
```typescript
import { ScreenRotationManager } from '../utils/ScreenRotationManager';

// 获取旋转管理器
const rotationManager = ScreenRotationManager.getInstance();

// 切换横竖屏
await rotationManager.toggleOrientation();

// 锁定当前方向
await rotationManager.lockOrientation();

// 解锁方向
await rotationManager.unlockOrientation();

// 监听方向变化
rotationManager.onOrientationChange((orientation) => {
  console.log('屏幕方向变化:', orientation);
});
```

📖 **详细文档**: [屏幕旋转功能指南](docs/SCREEN_ROTATION.md)

### 🎯 陷阱系统（新增）
游戏包含三种陷阱类型，从第6关开始出现，增加游戏挑战性：

| 陷阱类型 | 外观 | 扣分 | 出现关卡 | 特点 |
|----------|------|------|----------|------|
| 🔺 **尖刺** | 红色三角形 | 20-60 | 6关+ | 基础陷阱，旋转动画 |
| 💣 **炸弹** | 橙色圆形带引信 | 30-60 | 15关+ | 引信闪烁火花效果 |
| 🔥 **火焰** | 红橙色火焰形状 | 40-60 | 30关+ | 火焰脉冲动画 |

**陷阱特性：**
- 🎲 **随机生成**：从第6关开始，每秒有概率生成新陷阱
- 🔄 **持续移动**：陷阱在游戏区域内持续移动，碰到边界反弹
- ❄️ **冰冻影响**：使用冰冻道具会暂停陷阱移动
- 🛡️ **护盾保护**：使用护盾道具后点击陷阱不扣分
- 📊 **难度递增**：陷阱数量、扣分值、生成概率随关卡增加

**关卡分布：**
- 1-5关：无陷阱（新手期）
- 6-14关：1个陷阱，扣分20-30分
- 15-29关：1-2个陷阱（尖刺+炸弹），扣分30-40分
- 30-50关：3-5个陷阱（尖刺+炸弹+火焰），扣分40-60分

### 🎮 核心玩法
- **点击消除**：点击彩色泡泡获得积分
- **避开陷阱**：小心点击陷阱会扣分
- **动态生成**：泡泡和陷阱会持续生成，保持游戏节奏
- **时间挑战**：在限定时间内达成目标分数

### 🏆 闯关系统
- **50个关卡**：难度递增的关卡设计
- **目标分数**：每关有不同的目标分数要求
- **时间限制**：关卡越高，时间越紧张
- **通关奖励**：成功通关获得金币奖励

### 💰 积分与金币系统
- **积分统计**：记录总积分和最高分
- **金币获取**：消除泡泡获得金币，通关获得额外奖励
- **数据持久化**：游戏进度自动保存

### 🛒 商店系统
#### 道具商店
| 道具 | 效果 | 价格 |
|------|------|------|
| ⚡ 双倍积分卡 | 30秒内获得双倍积分 | 100金币 |
| ⏰ 时间延长 | 增加15秒游戏时间 | 80金币 |
| 🧲 磁铁 | 自动吸引附近泡泡 | 150金币 |
| 💣 炸弹 | 消除屏幕上所有泡泡 | 200金币 |
| 🛡️ 护盾 | 保护一次失误 | 120金币 |
| 🌟 三倍积分卡 | 20秒内获得三倍积分 | 250金币 |
| ⏱️ 超级时间延长 | 增加30秒游戏时间 | 180金币 |
| 🧲 超级磁铁 | 强力吸引所有泡泡到中心 | 300金币 |
| ❄️ 冰冻 | 冻结所有泡泡10秒 | 220金币 |
| 🍀 幸运星 | 下次点击获得5倍积分 | 160金币 |

#### 装备升级
| 装备 | 效果 | 基础价格 |
|------|------|----------|
| 📊 积分加成 | 提升基础积分获取 | 200金币 |
| 💰 金币加成 | 提升金币获取量 | 180金币 |
| 🔍 泡泡大小 | 增加泡泡显示大小 | 150金币 |
| ⏱️ 时间延长 | 增加关卡时间限制 | 250金币 |
| 🔥 连击加成 | 提升连击积分倍率 | 300金币 |
| 🐢 泡泡速度 | 降低泡泡移动速度，更容易点击 | 280金币 |
| 💥 爆炸范围 | 点击泡泡时影响周围泡泡 | 350金币 |
| 🍀 幸运加成 | 增加高分泡泡出现概率 | 320金币 |
| ⏰ 时间奖励 | 通关时额外奖励时间 | 260金币 |
| ⚡ 超级连击 | 大幅提升连击效果 | 400金币 |

## 🚀 快速开始

### 环境要求
- DevEco Studio 4.0 或更高版本
- HarmonyOS SDK 6.0.2(22) 或更高版本
- Node.js 14.x 或更高版本

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/yourusername/relaxing-bubble-game.git
cd relaxing-bubble-game
```

2. **打开项目**
- 启动 DevEco Studio
- 选择 "Open Project"
- 选择项目根目录

3. **同步依赖**
```bash
ohpm install
```

4. **运行项目**
- 连接鸿蒙设备或启动模拟器
- 点击运行按钮或使用快捷键运行

### 构建HAP
```bash
# Debug版本
hvigorw assembleHap --mode module -p product=default

# Release版本
hvigorw assembleHap --mode module -p product=default -p buildMode=release
```

## 🌐 多端部署

本项目支持**一次开发，多端部署**，可运行在以下设备：

| 平台 | 设备类型 | 特性适配 |
|------|---------|---------|
| 📱 Phone | 手机 | 标准布局，触摸操作，屏幕旋转 |
| 📟 Tablet | 平板 | 大屏布局，更多泡泡，屏幕旋转，多窗口 |
| 📺 TV | 电视 | 超大屏，遥控器操作 |
| ⌚ Wearable | 手表 | 简化UI，快速游戏 |
| 💻 2in1 | 二合一设备 | 平板模式，键盘+触摸 |

### 多端部署配置

**构建配置文件：**
- `build-profile.multi.json5` - 多端构建配置
- `platforms/tablet/module.json5` - 平台模块配置
- `entry/src/main/module.json5` - 主模块配置

**平台适配器：**
- `entry/src/main/ets/utils/PlatformAdapter.ets` - 自动检测设备类型并应用最佳配置
- `entry/src/main/ets/utils/ScreenRotationManager.ets` - 屏幕旋转管理器

### 快速构建多端

**使用DevEco Studio：**
1. 打开项目
2. 在工具栏选择设备类型：`phone` / `tablet` / `tv` / `wearable` / `2in1`
3. 点击运行按钮

**使用命令行：**
```bash
# 构建平板版本
hvigorw assembleHap --mode module -p product=tablet -p module=entry@default

# 构建所有设备版本
hvigorw assembleHap --mode module -p product=phone -p module=entry@default
hvigorw assembleHap --mode module -p product=tablet -p module=entry@default
hvigorw assembleHap --mode module -p product=tv -p module=entry@default
hvigorw assembleHap --mode module -p product=wearable -p module=entry@default
hvigorw assembleHap --mode module -p product=2in1 -p module=entry@default
```

**使用部署脚本：**
```powershell
# 运行平板部署脚本
.\deploy_tablet.ps1
```

### 平台适配器使用

```typescript
import { PlatformAdapter } from '../utils/PlatformAdapter';

// 获取平台配置
const platform = PlatformAdapter.getInstance();

// 响应式尺寸
const bubbleSize = platform.getBubbleSize();
const fontSize = platform.getFontSize();
const columns = platform.getColumns();

// 平台判断
if (platform.isLargeScreen()) {
  // 大屏设备逻辑
}
if (platform.isLandscape()) {
  // 横屏逻辑
}
```

📖 **详细文档**:
- [多端部署指南](MULTI_DEVICE_DEPLOYMENT.md)
- [SDK版本修复指南](SDK_VERSION_FIX.md)
- [屏幕旋转测试脚本](test_rotation.ps1)
- [平板部署脚本](deploy_tablet.ps1)

### 华为MatePad Pro 11 适配详情

**设备规格：**
- 屏幕尺寸：11英寸
- 分辨率：2560×1600像素
- 屏幕比例：16:10
- 像素密度：~2.0 (320 PPI)
- HarmonyOS：4.0及以上

**适配参数：**
| 参数 | 竖屏模式 | 横屏模式 |
|------|----------|----------|
| 游戏区域宽度 | 屏幕宽度 × 55% | 屏幕宽度 × 70% |
| 游戏区域高度 | 屏幕高度 × 50% | 屏幕高度 × 80% |
| UI缩放比例 | 1.4 | 1.5 |
| 列数 | 16 | 20 |

**支持功能：**
- ✅ 屏幕自由旋转（横竖屏切换）
- ✅ 多窗口模式（全屏、分屏、悬浮窗）
- ✅ 50个关卡全部可用
- ✅ 10种道具系统
- ✅ 10种装备升级系统
- ✅ 陷阱系统（移动+随机生成）
- ✅ 游戏数据自动保存

## 🎯 游戏玩法

### 基本操作
1. 点击"开始游戏"进入游戏
2. 在游戏区域内点击彩色泡泡获得积分
3. **避开陷阱**：小心点击陷阱会扣分，护盾可保护一次
4. 在时间结束前达到目标分数即可通关
5. 点击"退出"按钮可提前结束游戏

### 进阶技巧
- **优先点击高分泡泡**：泡泡上显示的数字越大，积分越多
- **合理使用道具**：在关键时刻使用道具可以事半功倍
- **升级装备**：长期投资装备升级可以获得更高收益
- **挑战高关卡**：高关卡虽然难度大，但奖励也更丰厚
- **注意陷阱位置**：陷阱会移动，需要预判和快速反应

### 关卡说明
- **关卡1-5**：新手关卡，熟悉游戏操作，无陷阱
- **关卡6-10**：进阶关卡，开始出现尖刺陷阱
- **关卡11-15**：挑战关卡，出现炸弹陷阱
- **关卡16-25**：高手挑战，陷阱数量增加
- **关卡26-35**：大师关卡，陷阱和泡泡同时生成
- **关卡36-45**：极限挑战，三种陷阱全部出现
- **关卡46-50**：终极挑战，最多5个陷阱，最高扣分

## 📁 项目结构

```
entry/src/main/ets/
├── common/              # 公共资源
├── components/          # 组件
│   ├── GameCanvas.ets   # 游戏画布组件（包含退出按钮）
│   ├── BubbleComponent.ets # 泡泡组件
│   ├── TrapComponent.ets # 陷阱组件（含移动和动画）
│   └── ParticleComponent.ets # 粒子组件
├── models/              # 数据模型
│   └── GameModels.ets   # 游戏数据模型定义（包含Trap类）
├── pages/               # 页面
│   ├── Index.ets        # 主入口
│   ├── GamePage.ets     # 游戏主页面（移除自定义顶部栏）
│   ├── LevelSelectPage.ets  # 关卡选择页面
│   └── ShopPage.ets     # 商店页面
└── utils/               # 工具类
    ├── GameDataManager.ets  # 游戏数据管理器（50关卡，陷阱配置）
    ├── PlatformAdapter.ets  # 平台适配器（多端部署，平板优化）
    └── ScreenRotationManager.ets  # 屏幕旋转管理器

platforms/               # 多端平台配置
├── phone/               # 手机配置
├── tablet/              # 平板配置（支持屏幕旋转和多窗口）
├── tv/                  # 电视配置
├── wearable/            # 手表配置
└── 2in1/                # 二合一设备配置

docs/                    # 文档
├── MULTI_DEVICE_DEPLOYMENT.md  # 多端部署完整指南
├── SDK_VERSION_FIX.md  # SDK版本修复指南
├── TRAP_FEATURE.md  # 陷阱功能说明
└── LEVEL_DESIGN.md  # 关卡设计文档

scripts/                 # 构建脚本
├── deploy_tablet.ps1  # 平板部署脚本
├── test_rotation.ps1  # 屏幕旋转测试脚本
└── fix_sdk_version.ps1  # SDK版本自动修复脚本
```

## 🛠️ 技术栈

- **开发语言**：ArkTS (TypeScript扩展)
- **UI框架**：ArkUI 声明式UI
- **状态管理**：@State、@Prop 装饰器
- **数据持久化**：@ohos.data.preferences
- **窗口管理**：@ohos.window
- **显示信息**：@ohos.display
- **构建工具**：Hvigor
- **SDK版本**：HarmonyOS SDK 6.0.2(22)

## 🎨 设计理念

### 视觉设计
- 采用柔和的渐变色彩，营造轻松氛围
- 泡泡使用高饱和度颜色，视觉冲击力强
- 圆角和阴影设计，增强立体感
- 陷阱使用警示色彩（红色、橙色），易于识别

### 交互设计
- 简洁的操作方式，降低学习成本
- 即时反馈机制，点击泡泡立即消失
- 流畅的页面切换动画
- 陷阱移动增加挑战性和动态感

### 游戏平衡
- 关卡难度曲线平滑递增
- 金币获取与消耗平衡
- 装备升级成本指数增长，避免过早满级
- 陷阱出现时机和数量经过精心设计

## 📊 性能优化

- **按需渲染**：使用ForEach优化列表渲染
- **状态最小化**：精确控制状态变量范围
- **内存管理**：及时清理定时器和事件监听
- **资源优化**：使用矢量图标替代图片资源
- **多端适配**：根据设备性能调整泡泡数量和动画速度

## 🔧 扩展开发

### 添加新道具
在 `GameDataManager.ets` 的 `initItems()` 方法中添加：
```typescript
new Item(11, '新道具', '道具描述', 100, 'new_effect', 20)
```

### 添加新装备
在 `GameDataManager.ets` 的 `initEquipments()` 方法中添加：
```typescript
new Equipment(11, '新装备', '装备描述', 200, 0.15)
```

### 添加新陷阱类型
在 `GameModels.ets` 的 `Trap` 类构造函数中添加新的陷阱类型：
```typescript
switch (type) {
  case 'ice':
    this.color = '#3498DB';
    this.radius = 32;
    break;
  // ...
}
```

### 添加新关卡
修改 `GameDataManager.ets` 的 `initLevels()` 方法中的关卡生成逻辑

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 📝 开发日志

### v1.2.0 (2026-06-16)
- ✅ 扩展关卡数量从20关到50关
- ✅ 实现陷阱系统（尖刺、炸弹、火焰三种类型）
- ✅ 陷阱支持移动和随机生成
- ✅ 优化平板端适配（华为MatePad Pro 11）
- ✅ 修复平板端退出按钮显示问题
- ✅ 添加屏幕旋转支持到平板端
- ✅ 完善多端部署文档和脚本

### v1.1.0 (2026-06-02)
- ✅ 实现一次开发多端部署功能
- ✅ 支持5个平台：Phone、Tablet、TV、Wearable、2in1
- ✅ 添加PlatformAdapter平台适配层
- ✅ 创建自动化多端构建脚本
- ✅ 实现屏幕自由旋转功能
- ✅ 添加ScreenRotationManager旋转管理器
- ✅ 创建RotationControl旋转控制组件
- ✅ 支持横屏/竖屏自动适配
- ✅ 完善多端部署和旋转功能文档

### v1.0.0 (2024-01-XX)
- ✅ 完成基础游戏功能
- ✅ 实现20个关卡系统
- ✅ 完成商店和装备系统
- ✅ 添加数据持久化功能

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- 感谢华为鸿蒙团队提供的优秀开发框架
- 感谢所有贡献者的支持

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐ Star 支持一下！**

Made with ❤️ by HarmonyOS Developer

</div>
