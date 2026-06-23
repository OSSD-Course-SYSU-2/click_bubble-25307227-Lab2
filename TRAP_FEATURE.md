# 泡泡消除游戏 - 陷阱功能说明

## 概述

陷阱功能为游戏增加了挑战性，玩家需要小心避开陷阱，否则会扣除积分。陷阱从第6关开始出现，随着关卡推进，陷阱数量和类型会逐渐增加。

## 陷阱类型

### 1. 尖刺陷阱 (Spike)
- **外观**: 红色三角形尖刺
- **扣分**: 20-40分（随关卡增加）
- **出现关卡**: 6关+
- **特点**: 基础陷阱，旋转动画

### 2. 炸弹陷阱 (Bomb)
- **外观**: 橙色圆形炸弹带引信
- **扣分**: 30-50分（随关卡增加）
- **出现关卡**: 15关+
- **特点**: 引信有闪烁火花效果

### 3. 火焰陷阱 (Fire)
- **外观**: 红橙色火焰形状
- **扣分**: 40-60分（随关卡增加）
- **出现关卡**: 30关+
- **特点**: 火焰脉冲动画，最具威胁

## 陷阱配置

### 关卡陷阱分布

| 关卡范围 | 陷阱数量 | 陷阱类型 | 扣分值 |
|----------|----------|----------|--------|
| 1-5关 | 0 | 无 | 0 |
| 6-10关 | 1 | spike | 20 |
| 11-14关 | 1 | spike | 30 |
| 15-19关 | 1-2 | spike, bomb | 30 |
| 20-24关 | 2 | spike, bomb | 40 |
| 25-29关 | 2-3 | spike, bomb | 40 |
| 30-34关 | 3 | spike, bomb, fire | 40 |
| 35-39关 | 3-4 | spike, bomb, fire | 50 |
| 40-44关 | 4 | spike, bomb, fire | 50 |
| 45-49关 | 4-5 | spike, bomb, fire | 60 |
| 50关 | 5 | spike, bomb, fire | 60 |

### 陷阱生成逻辑

```arkts
// GameDataManager.ets
if (i >= 6) {
  trapCount = Math.min(5, Math.floor((i - 5) / 5)); // 每5关增加1个陷阱
  trapPenalty = 20 + Math.floor((i - 5) / 10) * 10; // 扣分值随关卡增加

  // 解锁更多陷阱类型
  if (i >= 15) {
    trapTypes.push('bomb');
  }
  if (i >= 30) {
    trapTypes.push('fire');
  }
}
```

## 陷阱视觉效果

### 动画效果
1. **脉冲光晕**: 陷阱周围有呼吸式光晕效果
2. **旋转动画**: 陷阱缓慢旋转（不同方向）
3. **类型特效**:
   - 尖刺: 简洁的旋转
   - 炸弹: 引信火花闪烁
   - 火焰: 火焰脉冲动画

### 点击反馈
- 点击陷阱后触发红色爆炸效果
- 陷阱消失
- 分数扣除（带红色闪烁提示）

## 游戏机制

### 扣分规则
```arkts
hitTrap(trap: Trap): void {
  // 护盾保护
  if (this.shieldActive) {
    this.shieldActive = false;
    this.traps.splice(index, 1);
    return;
  }

  // 扣分（不低于0）
  this.score = Math.max(0, this.score - trap.penalty);

  // 创建爆炸效果
  this.createExplosion(trap.x, trap.y, trap.color, trap.radius);

  // 移除陷阱
  this.traps.splice(index, 1);
}
```

### 护盾保护
- 使用护盾道具后，点击陷阱不会扣分
- 护盾消耗后消失
- 陷阱仍然被移除

### 陷阱与泡泡的关系
- 陷阱和泡泡独立存在
- 点击泡泡：加分
- 点击陷阱：扣分
- 炸弹道具：消除所有泡泡，不影响陷阱

## 数据模型

### Trap 类

```arkts
export class Trap {
  id: number = 0;
  x: number = 0;
  y: number = 0;
  radius: number = 25;
  type: string = 'spike'; // spike, bomb, fire
  color: string = '#FF4444';
  penalty: number = 20;
  isAlive: boolean = true;
  rotation: number = 0;
  pulsePhase: number = 0;
  pulseSpeed: number = 0.05;
}
```

### Level 类扩展

```arkts
export class Level {
  // ... 原有属性

  // 陷阱相关属性
  trapCount: number = 0;
  trapPenalty: number = 20;
  trapTypes: string[] = ['spike'];
}
```

## UI 组件

### TrapComponent

```arkts
@Component
struct TrapComponent {
  @Prop trap: Trap = new Trap(0, 0, 0, 'spike', 20);
  @Prop animationTime: number = 0;
  onHit?: (trap: Trap) => void;

  build() {
    Stack() {
      // 脉冲光晕
      Circle()
        .width(this.trap.radius * 2.5 * (1 + Math.sin(this.animationTime * 3 + this.trap.pulsePhase) * 0.1))
        .fill(this.trap.color + '20')
        .blur(8)

      // 根据类型渲染不同图形
      if (this.trap.type === 'spike') {
        this.SpikeIcon()
      } else if (this.trap.type === 'bomb') {
        this.BombIcon()
      } else if (this.trap.type === 'fire') {
        this.FireIcon()
      }

      // 扣分提示
      Text(`-${this.trap.penalty}`)
        .fontSize(12)
        .fontColor(Color.White)
    }
    .rotate({
      angle: this.animationTime * 30 * (this.trap.id % 2 === 0 ? 1 : -1),
      centerX: '50%',
      centerY: '50%'
    })
    .onClick(() => {
      if (this.onHit) {
        this.onHit(this.trap);
      }
    })
  }
}
```

## 游戏策略

### 新手建议（1-5关）
- 无陷阱，专注于熟悉泡泡点击
- 练习连击技巧
- 了解道具使用时机

### 进阶策略（6-14关）
- 开始出现尖刺陷阱
- 仔细观察陷阱位置
- 优先点击高分泡泡
- 使用护盾道具保护

### 高手技巧（15-29关）
- 尖刺和炸弹陷阱
- 陷阱数量增加
- 快速识别陷阱类型
- 合理使用磁铁道具
- 炸弹道具清除泡泡时注意陷阱

### 极限挑战（30-50关）
- 三种陷阱全部出现
- 陷阱数量最多（5个）
- 扣分值最高（60分）
- 需要极高的专注力和反应速度
- 护盾道具至关重要

## 平衡性设计

### 为什么从第6关开始？
- 前5关让玩家熟悉基本操作
- 避免新手期挫败感
- 循序渐进引入新机制

### 陷阱数量限制
- 最多5个陷阱，避免过于混乱
- 陷阱占屏幕面积约15-20%
- 留有足够的泡泡点击空间

### 扣分值设计
- 最低20分，最高60分
- 相当于2-6个泡泡的分数
- 一次失误不会致命
- 但多次失误会影响通关

## 技术实现

### 文件修改列表

1. **GameModels.ets**
   - 新增 `Trap` 类
   - 扩展 `Level` 类添加陷阱属性

2. **GameDataManager.ets**
   - 导入 `Trap` 类
   - 更新 `initLevels()` 方法生成陷阱配置

3. **GameCanvas.ets**
   - 导入 `Trap` 类
   - 新增 `TrapComponent` 组件
   - 新增 `traps` 状态数组
   - 新增 `trapIdCounter` 计数器
   - 新增 `generateTraps()` 方法
   - 新增 `hitTrap()` 方法
   - 更新 `initGame()` 重置陷阱
   - 更新游戏区域渲染陷阱

## 测试清单

### 功能测试
- [ ] 第6关出现1个尖刺陷阱
- [ ] 第15关出现炸弹陷阱
- [ ] 第30关出现火焰陷阱
- [ ] 点击陷阱正确扣分
- [ ] 护盾保护陷阱点击不扣分
- [ ] 陷阱动画正常显示
- [ ] 陷阱爆炸效果正常

### 关卡测试
- [ ] 1-5关无陷阱
- [ ] 6-10关1个陷阱
- [ ] 15-19关1-2个陷阱
- [ ] 30-34关3个陷阱
- [ ] 50关5个陷阱

### 边界测试
- [ ] 分数为0时点击陷阱不小于0
- [ ] 陷阱不超出游戏区域
- [ ] 陷阱与泡泡不重叠（随机位置）
- [ ] 多个陷阱同时存在

### 视觉测试
- [ ] 尖刺陷阱显示正确
- [ ] 炸弹陷阱引信闪烁
- [ ] 火焰陷阱脉冲动画
- [ ] 陷阱旋转方向随机
- [ ] 陷阱光晕效果

## 已知问题

无

## 未来扩展

可能的陷阱类型扩展：
1. **冰冻陷阱**: 冻结玩家一段时间
2. **减速陷阱**: 降低泡泡移动速度
3. **反转陷阱**: 反转控制方向
4. **黑洞陷阱**: 吸引附近泡泡

可能的道具扩展：
1. **陷阱清除器**: 清除所有陷阱
2. **陷阱探测**: 高亮显示陷阱位置
3. **陷阱免疫**: 短时间内免疫陷阱

## 总结

陷阱功能为泡泡消除游戏增加了策略深度和挑战性：

✅ **渐进式难度**: 从第6关开始，逐步增加
✅ **多样化陷阱**: 3种类型，各有特色
✅ **视觉反馈**: 清晰的动画和效果
✅ **平衡设计**: 不会过于困难
✅ **策略性**: 需要玩家仔细观察和快速反应

玩家在享受消除泡泡乐趣的同时，也需要小心避开陷阱，这为游戏带来了更多的紧张感和成就感！🎮
