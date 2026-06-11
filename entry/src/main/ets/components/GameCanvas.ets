import { Bubble, ExplosionParticle, Item, Level } from '../models/GameModels';
import { GameDataManager } from '../utils/GameDataManager';

/**
 * 爆炸粒子组件
 */
@Component
struct ParticleComponent {
  @Prop particle: ExplosionParticle = new ExplosionParticle(0, 0, 0, '#FF6B6B');

  build() {
    Circle()
      .width(this.particle.radius * 2 * this.particle.life)
      .height(this.particle.radius * 2 * this.particle.life)
      .fill(this.particle.color)
      .opacity(this.particle.life)
      .position({ x: this.particle.x - this.particle.radius, y: this.particle.y - this.particle.radius })
  }
}

/**
 * 泡泡组件
 */
@Component
export struct BubbleComponent {
  @Prop bubble: Bubble = new Bubble(0, 0, 0, '#FF6B6B');
  @Prop bubbleScale: number = 1;
  @Prop animationTime: number = 0;
  onPop?: (bubble: Bubble) => void;

  build() {
    Stack() {
      Circle()
        .width(this.bubble.radius * 2.3 * this.bubbleScale)
        .height(this.bubble.radius * 2.3 * this.bubbleScale)
        .fill(this.bubble.color + '30')
        .blur(5)

      Circle()
        .width(this.bubble.radius * 2 * this.bubbleScale)
        .height(this.bubble.radius * 2 * this.bubbleScale)
        .fill(this.bubble.color)
        .shadow({
          radius: 15,
          color: this.bubble.color + '80',
          offsetX: 3,
          offsetY: 3
        })

      Circle()
        .width(this.bubble.radius * 0.6 * this.bubbleScale)
        .height(this.bubble.radius * 0.6 * this.bubbleScale)
        .fill('#FFFFFF60')
        .position({
          x: -this.bubble.radius * 0.3 * this.bubbleScale,
          y: -this.bubble.radius * 0.3 * this.bubbleScale
        })

      Text(`${this.bubble.points}`)
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textShadow({ radius: 2, color: '#00000050', offsetX: 1, offsetY: 1 })
    }
    .width(this.bubble.radius * 2.5 * this.bubbleScale)
    .height(this.bubble.radius * 2.5 * this.bubbleScale)
    .position({
      x: this.bubble.x - this.bubble.radius * 1.25 + this.bubble.offsetX,
      y: this.bubble.y - this.bubble.radius * 1.25 + this.bubble.offsetY
    })
    .scale({ x: this.bubbleScale, y: this.bubbleScale })
    .onClick(() => {
      if (this.onPop) {
        this.onPop(this.bubble);
      }
    })
  }
}

/**
 * 游戏画布组件
 */
@Component
export struct GameCanvas {
  @State bubbles: Bubble[] = [];
  @State particles: ExplosionParticle[] = [];
  @State score: number = 0;
  @State timeLeft: number = 60;
  @State isPlaying: boolean = false;
  @State animationTime: number = 0;
  // 画布实际渲染尺寸，由 onAreaChange 动态获取
  @State canvasWidth: number = 350;
  @State canvasHeight: number = 500;
  @Prop levelNumber: number = 1;
  @Prop targetScore: number = 100;

  // 道具效果状态
  @State doubleScoreActive: boolean = false;
  @State doubleScoreTimeLeft: number = 0;
  @State magnetActive: boolean = false;
  @State magnetTimeLeft: number = 0;
  @State shieldActive: boolean = false;
  // 新增道具状态
  @State tripleScoreActive: boolean = false;
  @State tripleScoreTimeLeft: number = 0;
  @State superMagnetActive: boolean = false;
  @State superMagnetTimeLeft: number = 0;
  @State freezeActive: boolean = false;
  @State freezeTimeLeft: number = 0;
  @State luckyStarActive: boolean = false;
  @State itemCounts: Map<number, number> = new Map(); // 道具数量状态

  // 连击追踪
  private comboCount: number = 0;
  private lastPopTime: number = 0;
  private readonly COMBO_TIMEOUT: number = 2000; // 2秒内连击有效

  private gameManager: GameDataManager = GameDataManager.getInstance();
  private timer: number = -1;
  private animationTimer: number = -1;
  private bubbleIdCounter: number = 0;
  private particleIdCounter: number = 0;

  onGameOver?: (score: number, passed: boolean) => void;

  aboutToAppear() {
    this.initGame();
    // 启动动画，让泡泡立即开始移动（但游戏未开始，时间不会减少）
    this.startAnimation();
    // 初始化道具数量
    this.updateItemCounts();
  }

  /**
   * 组件复用时的生命周期方法
   * 当关卡改变时重新初始化游戏
   */
  aboutToReuse() {
    console.log(`GameCanvas aboutToReuse: level changed to ${this.levelNumber}`);
    this.initGame();
    // 重新启动动画
    this.startAnimation();
  }

  aboutToDisappear() {
    this.clearAllTimers();
  }

  clearAllTimers(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
      this.animationTimer = -1;
    }
  }

  /**
   * 更新道具数量状态
   */
  updateItemCounts(): void {
    this.itemCounts = new Map(this.gameManager.player.items);
  }

  initGame(): void {
    this.score = 0;
    this.bubbles = [];
    this.particles = [];
    this.bubbleIdCounter = 0;
    this.particleIdCounter = 0;
    this.animationTime = 0;
    this.doubleScoreActive = false;
    this.doubleScoreTimeLeft = 0;
    this.magnetActive = false;
    this.magnetTimeLeft = 0;
    this.shieldActive = false;
    // 重置新增道具状态
    this.tripleScoreActive = false;
    this.tripleScoreTimeLeft = 0;
    this.superMagnetActive = false;
    this.superMagnetTimeLeft = 0;
    this.freezeActive = false;
    this.freezeTimeLeft = 0;
    this.luckyStarActive = false;
    this.comboCount = 0;
    this.lastPopTime = 0;

    const level = this.gameManager.getCurrentLevel();
    // 应用时间延长装备效果
    const timeEquip = this.gameManager.player.equipments.get(4);
    const timeBonus = timeEquip ? timeEquip.getEffect() : 1;
    this.timeLeft = Math.floor(level.timeLimit * timeBonus);
    this.generateBubbles(level.bubbleCount);
  }

  generateBubbles(count: number): void {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F', '#BB8FCE'];
    const sizeEquip = this.gameManager.player.equipments.get(3);
    const sizeBonus = sizeEquip ? sizeEquip.getEffect() : 1;
    const level = this.gameManager.getCurrentLevel();

    console.log(`Generating ${count} bubbles...`);
    for (let i = 0; i < count; i++) {
      const radius = (level.minBubbleRadius + Math.random() * (level.maxBubbleRadius - level.minBubbleRadius)) * sizeBonus;
      const x = radius + Math.random() * (this.canvasWidth - radius * 2);
      const y = radius + Math.random() * (this.canvasHeight - radius * 2);
      const color = colors[Math.floor(Math.random() * colors.length)];
      const points = Math.floor(level.minPoints + Math.random() * (level.maxPoints - level.minPoints));
      const bubble = new Bubble(this.bubbleIdCounter++, x, y, color, points);
      // 根据关卡速度倍率调整泡泡移动速度
      bubble.vx *= level.speedMultiplier;
      bubble.vy *= level.speedMultiplier;
      bubble.moveSpeed *= level.speedMultiplier;
      this.bubbles.push(bubble);
      console.log(`Bubble ${bubble.id} generated at (${x.toFixed(1)}, ${y.toFixed(1)}) with vx=${bubble.vx.toFixed(2)}, vy=${bubble.vy.toFixed(2)}`);
    }
    console.log(`Total bubbles: ${this.bubbles.length}`);
  }

  startGame(): void {
    this.isPlaying = true;
    // 不需要重新初始化游戏，因为泡泡已经在 aboutToAppear 中生成
    // 只需要启动计时器
    this.startTimer();
    // 确保动画正在运行
    if (this.animationTimer === -1) {
      this.startAnimation();
    }
  }

  startTimer(): void {
    // 防止重复启动定时器
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
    
    this.timer = setInterval(() => {
      if (this.timeLeft > 0) {
        this.timeLeft--;

        // 更新道具效果时间
        if (this.doubleScoreActive) {
          this.doubleScoreTimeLeft--;
          if (this.doubleScoreTimeLeft <= 0) {
            this.doubleScoreActive = false;
          }
        }
        if (this.magnetActive) {
          this.magnetTimeLeft--;
          if (this.magnetTimeLeft <= 0) {
            this.magnetActive = false;
          }
        }
        // 更新新增道具效果时间
        if (this.tripleScoreActive) {
          this.tripleScoreTimeLeft--;
          if (this.tripleScoreTimeLeft <= 0) {
            this.tripleScoreActive = false;
          }
        }
        if (this.superMagnetActive) {
          this.superMagnetTimeLeft--;
          if (this.superMagnetTimeLeft <= 0) {
            this.superMagnetActive = false;
          }
        }
        if (this.freezeActive) {
          this.freezeTimeLeft--;
          if (this.freezeTimeLeft <= 0) {
            this.freezeActive = false;
          }
        }

        // 随机生成新泡泡（根据关卡难度调整生成概率和最大数量）
        const level = this.gameManager.getCurrentLevel();
        if (Math.random() < level.spawnProbability && this.bubbles.length < level.maxBubbles) {
          this.addRandomBubble();
        }
      } else {
        this.endGame();
      }
    }, 1000);
  }

  startAnimation(): void {
    // 防止重复启动动画定时器
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
    }
    
    this.animationTimer = setInterval(() => {
      this.animationTime += 0.05;

      // 每100帧打印一次泡泡总数
      if (Math.floor(this.animationTime * 20) % 100 === 0) {
        console.log(`Animation tick: ${this.bubbles.length} bubbles, time=${this.animationTime.toFixed(2)}`);
      }

      // 更新泡泡移动和浮动动画
      // 创建新数组以触发状态更新
      const updatedBubbles: Bubble[] = [];
      this.bubbles.forEach((bubble: Bubble, index: number) => {
        const oldX = bubble.x;
        const oldY = bubble.y;
        
        // 冰冻效果：暂停泡泡移动
        if (!this.freezeActive) {
          // 1. 更新泡泡位置（实际移动）
          bubble.x += bubble.vx;
          bubble.y += bubble.vy;

          // 2. 边界检测和反弹
          if (bubble.x - bubble.radius < 0) {
            bubble.x = bubble.radius;
            bubble.vx = Math.abs(bubble.vx); // 反弹
          } else if (bubble.x + bubble.radius > this.canvasWidth) {
            bubble.x = this.canvasWidth - bubble.radius;
            bubble.vx = -Math.abs(bubble.vx); // 反弹
          }

          if (bubble.y - bubble.radius < 0) {
            bubble.y = bubble.radius;
            bubble.vy = Math.abs(bubble.vy); // 反弹
          } else if (bubble.y + bubble.radius > this.canvasHeight) {
            bubble.y = this.canvasHeight - bubble.radius;
            bubble.vy = -Math.abs(bubble.vy); // 反弹
          }
        }

        // 3. 更新浮动动画（在移动基础上的浮动效果）
        const floatRange = 8;
        bubble.offsetX = Math.sin(this.animationTime * bubble.speed + bubble.phase) * floatRange;
        bubble.offsetY = Math.cos(this.animationTime * bubble.speed * 0.8 + bubble.phase + Math.PI / 4) * floatRange * 0.6;
        
        updatedBubbles.push(bubble);
        
        // 每100帧打印一次调试信息（只打印前3个泡泡）
        if (index < 3 && Math.floor(this.animationTime * 20) % 100 === 0) {
          console.log(`Animation: Bubble ${index} moved from (${oldX.toFixed(1)}, ${oldY.toFixed(1)}) to (${bubble.x.toFixed(1)}, ${bubble.y.toFixed(1)}), vx=${bubble.vx.toFixed(2)}, vy=${bubble.vy.toFixed(2)}`);
        }
      });
      
      // 强制触发状态更新
      this.bubbles = updatedBubbles;

      // 磁铁效果：吸引泡泡向中心移动
      if (this.magnetActive && this.bubbles.length > 0) {
        const centerX = this.canvasWidth / 2;
        const centerY = this.canvasHeight / 2;
        const magnetBubbles: Bubble[] = [];
        this.bubbles.forEach((bubble: Bubble) => {
          const dx = centerX - bubble.x;
          const dy = centerY - bubble.y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist > 50) {
            bubble.x += dx / dist * 2;
            bubble.y += dy / dist * 2;
          }
          magnetBubbles.push(bubble);
        });
        this.bubbles = magnetBubbles;
      }

      // 超级磁铁效果：强力吸引泡泡向中心移动
      if (this.superMagnetActive && this.bubbles.length > 0) {
        const centerX = this.canvasWidth / 2;
        const centerY = this.canvasHeight / 2;
        const superMagnetBubbles: Bubble[] = [];
        this.bubbles.forEach((bubble: Bubble) => {
          const dx = centerX - bubble.x;
          const dy = centerY - bubble.y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist > 30) {
            bubble.x += dx / dist * 5; // 更强的吸引力
            bubble.y += dy / dist * 5;
          }
          superMagnetBubbles.push(bubble);
        });
        this.bubbles = superMagnetBubbles;
      }

      this.updateParticles();
    }, 30); // 更新间隔改为30ms，使动画更流畅（约33fps）
  }

  updateParticles(): void {
    const newParticles: ExplosionParticle[] = [];
    this.particles.forEach((particle: ExplosionParticle) => {
      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.vy += 0.2;
      particle.life -= particle.decay;
      if (particle.life > 0) {
        newParticles.push(particle);
      }
    });
    this.particles = newParticles;
  }

  createExplosion(x: number, y: number, color: string, radius: number): void {
    const particleCount = 12 + Math.floor(radius / 5);
    for (let i = 0; i < particleCount; i++) {
      this.particles.push(new ExplosionParticle(this.particleIdCounter++, x, y, color));
    }
  }

  addRandomBubble(): void {
    const colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F', '#BB8FCE'];
    const level = this.gameManager.getCurrentLevel();
    const radius = level.minBubbleRadius + Math.random() * (level.maxBubbleRadius - level.minBubbleRadius);
    const x = radius + Math.random() * (this.canvasWidth - radius * 2);
    const y = radius + Math.random() * (this.canvasHeight - radius * 2);
    const color = colors[Math.floor(Math.random() * colors.length)];
    const points = Math.floor(level.minPoints + Math.random() * (level.maxPoints - level.minPoints));
    const bubble = new Bubble(this.bubbleIdCounter++, x, y, color, points);
    // 根据关卡速度倍率调整泡泡移动速度
    bubble.vx *= level.speedMultiplier;
    bubble.vy *= level.speedMultiplier;
    bubble.moveSpeed *= level.speedMultiplier;
    this.bubbles.push(bubble);
  }

  popBubble(bubble: Bubble): void {
    const index = this.bubbles.findIndex(b => b.id === bubble.id);
    if (index !== -1) {
      this.createExplosion(bubble.x + bubble.offsetX, bubble.y + bubble.offsetY, bubble.color, bubble.radius);
      this.bubbles.splice(index, 1);

      // 计算连击
      const currentTime = Date.now();
      if (currentTime - this.lastPopTime < this.COMBO_TIMEOUT) {
        this.comboCount++;
      } else {
        this.comboCount = 1;
      }
      this.lastPopTime = currentTime;

      // 计算积分
      const scoreEquip = this.gameManager.player.equipments.get(1);
      const scoreBonus = scoreEquip ? scoreEquip.getEffect() : 1;
      let earnedScore = Math.floor(bubble.points * scoreBonus);

      // 应用连击加成装备效果
      const comboEquip = this.gameManager.player.equipments.get(5);
      const comboBonus = comboEquip ? comboEquip.getEffect() : 1;
      if (this.comboCount > 1) {
        const comboMultiplier = 1 + (this.comboCount - 1) * 0.1 * comboBonus;
        earnedScore = Math.floor(earnedScore * comboMultiplier);
      }

      // 双倍积分道具效果
      if (this.doubleScoreActive) {
        earnedScore *= 2;
      }

      // 三倍积分道具效果
      if (this.tripleScoreActive) {
        earnedScore *= 3;
      }

      // 幸运星道具效果
      if (this.luckyStarActive) {
        earnedScore *= 5;
        this.luckyStarActive = false; // 使用后失效
      }

      this.score += earnedScore;

      // 添加金币
      const coinEquip = this.gameManager.player.equipments.get(2);
      const coinBonus = coinEquip ? coinEquip.getEffect() : 1;
      this.gameManager.player.addCoins(Math.floor(earnedScore * 0.1 * coinBonus));
    }
  }

  /**
   * 使用道具
   */
  useItem(itemId: number): boolean {
    const itemCount = this.gameManager.player.items.get(itemId) || 0;
    if (itemCount <= 0) {
      return false;
    }

    const item = this.gameManager.items.find(i => i.id === itemId);
    if (!item) {
      return false;
    }

    switch (item.effect) {
      case 'double_score':
        // 双倍积分
        this.doubleScoreActive = true;
        this.doubleScoreTimeLeft = item.duration;
        break;
      case 'time_extend':
        // 时间延长
        this.timeLeft += item.duration;
        break;
      case 'magnet':
        // 磁铁
        this.magnetActive = true;
        this.magnetTimeLeft = item.duration;
        break;
      case 'bomb':
        // 炸弹：消除所有泡泡
        this.bubbles.forEach((bubble: Bubble) => {
          this.createExplosion(bubble.x, bubble.y, bubble.color, bubble.radius);
          this.score += bubble.points;
        });
        this.bubbles = [];
        break;
      case 'shield':
        // 护盾
        this.shieldActive = true;
        break;
      // 新增道具效果
      case 'triple_score':
        // 三倍积分
        this.tripleScoreActive = true;
        this.tripleScoreTimeLeft = item.duration;
        break;
      case 'super_time_extend':
        // 超级时间延长
        this.timeLeft += item.duration;
        break;
      case 'super_magnet':
        // 超级磁铁
        this.superMagnetActive = true;
        this.superMagnetTimeLeft = item.duration;
        break;
      case 'freeze':
        // 冰冻：暂停泡泡移动
        this.freezeActive = true;
        this.freezeTimeLeft = item.duration;
        break;
      case 'lucky_star':
        // 幸运星
        this.luckyStarActive = true;
        break;
      default:
        return false;
    }

    // 消耗道具
    this.gameManager.useItem(itemId);
    // 更新道具数量状态
    this.updateItemCounts();
    return true;
  }

  endGame(): void {
    this.isPlaying = false;
    this.clearAllTimers();
    const passed = this.score >= this.targetScore;
    if (this.onGameOver) {
      this.onGameOver(this.score, passed);
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部信息栏
        Row() {
          Text(`关卡: ${this.levelNumber}`)
            .fontSize(14)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium)

          Blank()

          Text(`目标: ${this.targetScore}`)
            .fontSize(14)
            .fontColor('#333')

          Blank()

          Text(`得分: ${this.score}`)
            .fontSize(16)
            .fontColor(this.score >= this.targetScore ? '#4ECDC4' : '#FF6B6B')
            .fontWeight(FontWeight.Bold)

          Blank()

          Text(`时间: ${this.timeLeft}s`)
            .fontSize(14)
            .fontColor(this.timeLeft <= 10 ? '#FF0000' : '#333')
            .fontWeight(this.timeLeft <= 10 ? FontWeight.Bold : FontWeight.Medium)

          // 提前退出按钮（游戏进行中显示）
          if (this.isPlaying) {
            Button('退出')
              .width(50)
              .height(28)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#FF6B6B')
              .borderRadius(14)
              .margin({ left: 8 })
              .onClick(() => {
                this.endGame();
              })
          }
        }
        .width('100%')
        .padding(8)
        .backgroundColor('#F5F5F5')

        // 道具效果提示
        if (this.doubleScoreActive || this.magnetActive || this.shieldActive ||
            this.tripleScoreActive || this.superMagnetActive || this.freezeActive || this.luckyStarActive) {
          Row() {
            if (this.doubleScoreActive) {
              Text(`⚡双倍积分 ${this.doubleScoreTimeLeft}s`)
                .fontSize(12)
                .fontColor('#FFD700')
                .backgroundColor('#FFF3CD')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 5 })
            }
            if (this.tripleScoreActive) {
              Text(`🌟三倍积分 ${this.tripleScoreTimeLeft}s`)
                .fontSize(12)
                .fontColor('#FF6B6B')
                .backgroundColor('#FFE4E1')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 5 })
            }
            if (this.magnetActive) {
              Text(`🧲磁铁 ${this.magnetTimeLeft}s`)
                .fontSize(12)
                .fontColor('#4ECDC4')
                .backgroundColor('#D4EDDA')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 5 })
            }
            if (this.superMagnetActive) {
              Text(`🧲超级磁铁 ${this.superMagnetTimeLeft}s`)
                .fontSize(12)
                .fontColor('#9B59B6')
                .backgroundColor('#E8DAEF')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 5 })
            }
            if (this.freezeActive) {
              Text(`❄️冰冻 ${this.freezeTimeLeft}s`)
                .fontSize(12)
                .fontColor('#3498DB')
                .backgroundColor('#D6EAF8')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 5 })
            }
            if (this.luckyStarActive) {
              Text('🍀幸运星')
                .fontSize(12)
                .fontColor('#27AE60')
                .backgroundColor('#D5F4E6')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 5 })
            }
            if (this.shieldActive) {
              Text('🛡️护盾')
                .fontSize(12)
                .fontColor('#45B7D1')
                .backgroundColor('#D1ECF1')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
            }
          }
          .width('100%')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#FFF')
        }

        // 游戏区域（自适应填充剩余空间）
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .linearGradient({
              angle: 135,
              colors: [['#E8F4F8', 0], ['#F0F8FF', 0.5], ['#FFE4E1', 1]]
            })

          ForEach(this.bubbles, (bubble: Bubble) => {
            BubbleComponent({
              bubble: bubble,
              animationTime: this.animationTime,
              onPop: (b: Bubble) => {
                this.popBubble(b);
              }
            })
          }, (bubble: Bubble) => bubble.id.toString())

          ForEach(this.particles, (particle: ExplosionParticle) => {
            ParticleComponent({ particle: particle })
          }, (particle: ExplosionParticle) => particle.id.toString())
        }
        .layoutWeight(1)
        .borderRadius(12)
        .clip(true)
        .shadow({ radius: 8, color: '#30000000', offsetY: 4 })
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          // 动态获取游戏区域的实际渲染尺寸
          const newWidth = newValue.width as number;
          const newHeight = newValue.height as number;
          if (newWidth > 0 && newHeight > 0 &&
              (Math.abs(newWidth - this.canvasWidth) > 1 || Math.abs(newHeight - this.canvasHeight) > 1)) {
            console.log(`GameCanvas area changed: ${newWidth}x${newHeight}`);
            this.canvasWidth = newWidth;
            this.canvasHeight = newHeight;
          }
        })

        // 道具栏
        if (this.isPlaying) {
          this.ItemBar()
        }

        // 开始按钮
        if (!this.isPlaying) {
          Button('开始游戏')
            .width(160)
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#4ECDC4')
            .borderRadius(25)
            .shadow({ radius: 10, color: '#4ECDC450', offsetY: 4 })
            .onClick(() => {
              this.startGame();
            })
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  @Builder
  ItemBar() {
    Row() {
      ForEach(this.gameManager.items, (item: Item) => {
        Column() {
          Text(this.getItemIcon(item.effect))
            .fontSize(24)
          Text(`${this.itemCounts.get(item.id) || 0}`)
            .fontSize(10)
            .fontColor('#666')
        }
        .width(50)
        .height(50)
        .justifyContent(FlexAlign.Center)
        .backgroundColor((this.itemCounts.get(item.id) || 0) > 0 ? '#E8F4F8' : '#F0F0F0')
        .borderRadius(8)
        .opacity((this.itemCounts.get(item.id) || 0) > 0 ? 1 : 0.5)
        .onClick(() => {
          if (this.useItem(item.id)) {
            // 道具使用成功
          }
        })
      }, (item: Item) => item.id.toString())
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#FFF')
    .margin({ top: 5 })
  }

  getItemIcon(effect: string): string {
    const icons: Record<string, string> = {
      'double_score': '⚡',
      'time_extend': '⏰',
      'magnet': '🧲',
      'bomb': '💣',
      'shield': '🛡️',
      // 新增道具图标
      'triple_score': '🌟',
      'super_time_extend': '⏱️',
      'super_magnet': '🧲',
      'freeze': '❄️',
      'lucky_star': '🍀'
    };
    return icons[effect] || '🎁';
  }
}
