/**
 * 泡泡数据模型
 */
export class Bubble {
  id: number = 0;
  x: number = 0;
  y: number = 0;
  radius: number = 30;
  color: string = '#FF6B6B';
  isAlive: boolean = true;
  points: number = 10;

  // 动画相关属性
  offsetX: number = 0;  // 水平偏移（用于浮动动画）
  offsetY: number = 0;  // 垂直偏移（用于浮动动画）
  speed: number = 1;    // 浮动速度
  direction: number = 0; // 移动方向（角度）
  phase: number = 0;    // 动画相位

  // 移动相关属性
  vx: number = 0;       // x方向移动速度
  vy: number = 0;       // y方向移动速度
  moveSpeed: number = 0; // 移动速度

  constructor(id: number, x: number, y: number, color: string, points: number = 10) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.color = color;
    this.points = points;
    // 初始化随机动画参数
    this.speed = 0.5 + Math.random() * 1.5;
    this.direction = Math.random() * Math.PI * 2;
    this.phase = Math.random() * Math.PI * 2;

    // 初始化随机移动参数
    this.moveSpeed = 3 + Math.random() * 4; // 移动速度范围：3-7（增加速度，使运动更明显）
    const moveAngle = Math.random() * Math.PI * 2; // 随机移动方向
    this.vx = Math.cos(moveAngle) * this.moveSpeed;
    this.vy = Math.sin(moveAngle) * this.moveSpeed;
    console.log(`Bubble ${this.id} created: vx=${this.vx.toFixed(2)}, vy=${this.vy.toFixed(2)}, speed=${this.moveSpeed.toFixed(2)}`);
  }
}

/**
 * 陷阱数据模型
 */
export class Trap {
  id: number = 0;
  x: number = 0;
  y: number = 0;
  radius: number = 25;
  type: string = 'spike'; // spike(尖刺), bomb(炸弹), fire(火焰)
  color: string = '#FF4444';
  penalty: number = 20; // 扣分值
  isAlive: boolean = true;
  rotation: number = 0; // 旋转角度

  // 动画相关属性
  pulsePhase: number = 0; // 脉冲相位
  pulseSpeed: number = 0.05; // 脉冲速度

  // 移动相关属性
  vx: number = 0;       // x方向移动速度
  vy: number = 0;       // y方向移动速度
  moveSpeed: number = 0; // 移动速度

  constructor(id: number, x: number, y: number, type: string = 'spike', penalty: number = 20) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.type = type;
    this.penalty = penalty;
    this.pulsePhase = Math.random() * Math.PI * 2;

    // 根据类型设置颜色和半径
    switch (type) {
      case 'spike':
        this.color = '#FF4444';
        this.radius = 25;
        break;
      case 'bomb':
        this.color = '#FF6600';
        this.radius = 28;
        break;
      case 'fire':
        this.color = '#FF3300';
        this.radius = 30;
        break;
      default:
        this.color = '#FF4444';
        this.radius = 25;
    }

    // 初始化随机移动参数（陷阱比泡泡慢）
    this.moveSpeed = 1.5 + Math.random() * 2; // 移动速度范围：1.5-3.5
    const moveAngle = Math.random() * Math.PI * 2; // 随机移动方向
    this.vx = Math.cos(moveAngle) * this.moveSpeed;
    this.vy = Math.sin(moveAngle) * this.moveSpeed;
  }
}

/**
 * 爆炸粒子数据模型
 */
export class ExplosionParticle {
  id: number = 0;
  x: number = 0;
  y: number = 0;
  vx: number = 0;  // x方向速度
  vy: number = 0;  // y方向速度
  radius: number = 5;
  color: string = '#FF6B6B';
  life: number = 1.0;  // 生命值（1.0到0.0）
  decay: number = 0.05; // 衰减速度

  constructor(id: number, x: number, y: number, color: string) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.color = color;
    // 随机方向和速度
    const angle = Math.random() * Math.PI * 2;
    const speed = 3 + Math.random() * 5;
    this.vx = Math.cos(angle) * speed;
    this.vy = Math.sin(angle) * speed;
    this.radius = 3 + Math.random() * 6;
    this.decay = 0.03 + Math.random() * 0.04;
  }
}

/**
 * 关卡数据模型
 */
export class Level {
  levelNumber: number = 1;
  targetScore: number = 100;
  bubbleCount: number = 20;
  timeLimit: number = 60; // 秒
  bubbleColors: string[] = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8'];
  reward: number = 50; // 通关奖励金币

  // 难度相关属性
  speedMultiplier: number = 1.0;    // 泡泡移动速度倍率（越高越快，越难点）
  minBubbleRadius: number = 22;     // 泡泡最小半径（越小越难点）
  maxBubbleRadius: number = 40;     // 泡泡最大半径
  minPoints: number = 8;            // 泡泡最小分值
  maxPoints: number = 33;           // 泡泡最大分值
  spawnProbability: number = 0.6;   // 每秒生成新泡泡的概率
  maxBubbles: number = 60;          // 场上最大泡泡数量

  // 陷阱相关属性
  trapCount: number = 0;            // 陷阱数量
  trapPenalty: number = 20;         // 陷阱扣分值
  trapTypes: string[] = ['spike'];  // 陷阱类型
  trapSpawnProbability: number = 0; // 陷阱生成概率（每秒）
  maxTraps: number = 5;             // 场上最大陷阱数量

  constructor(level: number, target: number, bubbles: number, time: number, reward: number = 50,
    speedMultiplier: number = 1.0, minRadius: number = 22, maxRadius: number = 40,
    minPoints: number = 8, maxPoints: number = 33, spawnProb: number = 0.6, maxBubbles: number = 60,
    trapCount: number = 0, trapPenalty: number = 20, trapTypes: string[] = ['spike'],
    trapSpawnProbability: number = 0, maxTraps: number = 5) {
    this.levelNumber = level;
    this.targetScore = target;
    this.bubbleCount = bubbles;
    this.timeLimit = time;
    this.reward = reward;
    this.speedMultiplier = speedMultiplier;
    this.minBubbleRadius = minRadius;
    this.maxBubbleRadius = maxRadius;
    this.minPoints = minPoints;
    this.maxPoints = maxPoints;
    this.spawnProbability = spawnProb;
    this.maxBubbles = maxBubbles;
    this.trapCount = trapCount;
    this.trapPenalty = trapPenalty;
    this.trapTypes = trapTypes;
    this.trapSpawnProbability = trapSpawnProbability;
    this.maxTraps = maxTraps;
  }
}

/**
 * 道具数据模型
 */
export class Item {
  id: number = 0;
  name: string = '';
  description: string = '';
  price: number = 0;
  icon: string = '';
  effect: string = ''; // 'double_score', 'time_extend', 'magnet', 'bomb'
  duration: number = 0; // 持续时间（秒）
  purchased: boolean = false;

  constructor(id: number, name: string, desc: string, price: number, effect: string, duration: number = 0) {
    this.id = id;
    this.name = name;
    this.description = desc;
    this.price = price;
    this.effect = effect;
    this.duration = duration;
  }
}

/**
 * 装备数据模型
 */
export class Equipment {
  id: number = 0;
  name: string = '';
  description: string = '';
  basePrice: number = 0;
  currentLevel: number = 1;
  maxLevel: number = 10;
  effectPerLevel: number = 0.1; // 每级提升效果

  constructor(id: number, name: string, desc: string, price: number, effect: number = 0.1) {
    this.id = id;
    this.name = name;
    this.description = desc;
    this.basePrice = price;
    this.effectPerLevel = effect;
  }

  getUpgradePrice(): number {
    return Math.floor(this.basePrice * Math.pow(1.5, this.currentLevel - 1));
  }

  getEffect(): number {
    return 1 + (this.currentLevel - 1) * this.effectPerLevel;
  }
}

/**
 * 玩家数据模型
 */
export class Player {
  totalScore: number = 0;
  currentLevel: number = 1;
  coins: number = 100; // 初始金币
  highestScore: number = 0;
  items: Map<number, number> = new Map(); // 道具ID -> 数量
  equipments: Map<number, Equipment> = new Map(); // 装备ID -> 装备

  addScore(score: number): void {
    this.totalScore += score;
    if (this.totalScore > this.highestScore) {
      this.highestScore = this.totalScore;
    }
  }

  addCoins(coins: number): void {
    this.coins += coins;
  }

  spendCoins(coins: number): boolean {
    if (this.coins >= coins) {
      this.coins -= coins;
      return true;
    }
    return false;
  }
}
