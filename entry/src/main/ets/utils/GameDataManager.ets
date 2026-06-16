
import { Bubble, Level, Item, Equipment, Player, Trap } from '../models/GameModels';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export interface EquipmentData {
  id: number;
  currentLevel: number;
}

export interface SaveData {
  totalScore: number;
  currentLevel: number;
  coins: number;
  highestScore: number;
  items: [number, number][];
  equipments: EquipmentData[];
}

/**
 * 游戏数据管理器
 */
export class GameDataManager {
  private static instance: GameDataManager;
  public player: Player;
  public levels: Level[] = [];
  public items: Item[] = [];
  public equipments: Equipment[] = [];
  private preferencesStore: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'game_data';
  private context: common.UIAbilityContext | null = null;

  private constructor() {
    this.player = new Player();
    this.initLevels();
    this.initItems();
    this.initEquipments();
  }

  static getInstance(): GameDataManager {
    if (!GameDataManager.instance) {
      GameDataManager.instance = new GameDataManager();
    }
    return GameDataManager.instance;
  }

  /**
   * 初始化上下文和存储
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    await this.initPreferences();
  }

  /**
   * 初始化关卡数据
   * 难度设计：基于实际可得分反推目标分数，确保所有关卡可通关
   * 前期(1-10): 目标=25%-40%可得分（新手教学）
   * 中期(11-25): 目标=42%-60%可得分（进阶挑战）
   * 后期(26-40): 目标=62%-75%可得分（高手挑战）
   * 终极(41-50): 目标=77%-85%可得分（极限挑战）
   */
  private initLevels(): void {
    for (let i = 1; i <= 50; i++) {
      // 泡泡数量：渐进式增加，从8个到68个
      const bubbleCount = 8 + Math.floor((i - 1) * 1.2);

      // 时间限制：从70秒递减到20秒，保持挑战性
      const timeLimit = Math.max(20, 70 - Math.floor((i - 1) * 1.0));

      // 泡泡移动速度倍率：从1.0递增到2.5，后期速度明显加快
      const speedMultiplier = 1.0 + (i - 1) * 0.03;

      // 泡泡半径范围：随关卡缩小，最小12保证可点击
      const minBubbleRadius = Math.max(12, 22 - Math.floor((i - 1) * 0.2));
      const maxBubbleRadius = Math.max(18, 40 - Math.floor((i - 1) * 0.44));

      // 泡泡分值范围：随关卡降低，但后期通过增加泡泡数量补偿
      const minPoints = Math.max(3, 8 - Math.floor((i - 1) * 0.1));
      const maxPoints = Math.max(10, 33 - Math.floor((i - 1) * 0.46));

      // 泡泡生成概率：从0.6递增到0.95，后期生成更频繁
      const spawnProbability = Math.min(0.95, 0.6 + (i - 1) * 0.007);

      // 场上最大泡泡数量：从60递增到100，后期场面更混乱
      const maxBubbles = Math.min(100, 60 + Math.floor((i - 1) * 0.8));

      // 陷阱配置：从第6关开始出现，数量随关卡增加
      let trapCount = 0;
      let trapPenalty = 20;
      let trapTypes: string[] = ['spike'];
      let trapSpawnProbability = 0;
      let maxTraps = 5;

      if (i >= 6) {
        trapCount = Math.min(5, Math.floor((i - 5) / 5)); // 每5关增加1个陷阱，最多5个
        trapPenalty = 20 + Math.floor((i - 5) / 10) * 10; // 扣分值随关卡增加
        trapSpawnProbability = Math.min(0.15, 0.05 + (i - 5) * 0.005); // 陷阱生成概率随关卡增加，最高15%

        // 解锁更多陷阱类型
        if (i >= 15) {
          trapTypes.push('bomb');
        }
        if (i >= 30) {
          trapTypes.push('fire');
        }
      }

      // 基于实际可得分计算目标分数
      const avgPoints = (minPoints + maxPoints) / 2;
      const totalBubbles = bubbleCount + spawnProbability * timeLimit;
      const maxPossible = totalBubbles * avgPoints;
      const realistic = maxPossible * 0.55; // 55%命中率估算（后期更难）

      // 难度比例：分段平滑递增
      let ratio: number;
      if (i <= 10) {
        // 新手期：25%-40%
        ratio = 0.25 + (i - 1) * 0.015;
      } else if (i <= 25) {
        // 进阶期：42%-60%
        ratio = 0.40 + (i - 10) * 0.012;
      } else if (i <= 40) {
        // 高手期：62%-75%
        ratio = 0.58 + (i - 25) * 0.0087;
      } else {
        // 极限期：77%-85%
        ratio = 0.71 + (i - 40) * 0.0053;
      }

      const targetScore = Math.max(50, Math.floor(realistic * ratio));

      // 奖励：随难度大幅增加，后期奖励更丰厚
      const reward = 80 + (i - 1) * 40;

      this.levels.push(new Level(i, targetScore, bubbleCount, timeLimit, reward,
        speedMultiplier, minBubbleRadius, maxBubbleRadius,
        minPoints, maxPoints, spawnProbability, maxBubbles,
        trapCount, trapPenalty, trapTypes, trapSpawnProbability, maxTraps));
    }
  }

  /**
   * 初始化道具数据
   */
  private initItems(): void {
    this.items = [
      new Item(1, '双倍积分卡', '使用后30秒内获得双倍积分', 100, 'double_score', 30),
      new Item(2, '时间延长', '增加15秒游戏时间', 80, 'time_extend', 15),
      new Item(3, '磁铁', '自动吸引附近泡泡', 150, 'magnet', 20),
      new Item(4, '炸弹', '消除屏幕上所有泡泡', 200, 'bomb', 0),
      new Item(5, '护盾', '保护一次失误', 120, 'shield', 0),
      // 新增道具
      new Item(6, '三倍积分卡', '使用后20秒内获得三倍积分', 250, 'triple_score', 20),
      new Item(7, '超级时间延长', '增加30秒游戏时间', 180, 'super_time_extend', 30),
      new Item(8, '超级磁铁', '强力吸引所有泡泡到中心', 300, 'super_magnet', 15),
      new Item(9, '冰冻', '冻结所有泡泡10秒', 220, 'freeze', 10),
      new Item(10, '幸运星', '下次点击获得5倍积分', 160, 'lucky_star', 0)
    ];
  }

  /**
   * 初始化装备数据
   */
  private initEquipments(): void {
    this.equipments = [
      new Equipment(1, '积分加成', '提升基础积分获取', 200, 0.15),
      new Equipment(2, '金币加成', '提升金币获取量', 180, 0.12),
      new Equipment(3, '泡泡大小', '增加泡泡显示大小', 150, 0.08),
      new Equipment(4, '时间延长', '增加关卡时间限制', 250, 0.1),
      new Equipment(5, '连击加成', '提升连击积分倍率', 300, 0.2),
      // 新增装备
      new Equipment(6, '泡泡速度', '降低泡泡移动速度，更容易点击', 280, 0.15),
      new Equipment(7, '爆炸范围', '点击泡泡时影响周围泡泡', 350, 0.2),
      new Equipment(8, '幸运加成', '增加高分泡泡出现概率', 320, 0.18),
      new Equipment(9, '时间奖励', '通关时额外奖励时间', 260, 0.12),
      new Equipment(10, '超级连击', '大幅提升连击效果', 400, 0.25)
    ];

    // 初始化玩家装备
    this.equipments.forEach(eq => {
      this.player.equipments.set(eq.id, eq);
    });
  }

  /**
   * 获取当前关卡
   */
  getCurrentLevel(): Level {
    const levelIndex = Math.min(this.player.currentLevel - 1, this.levels.length - 1);
    return this.levels[levelIndex];
  }

  /**
   * 购买道具
   */
  buyItem(itemId: number): boolean {
    const item = this.items.find(i => i.id === itemId);
    if (item && this.player.spendCoins(item.price)) {
      const currentCount = this.player.items.get(itemId) || 0;
      this.player.items.set(itemId, currentCount + 1);
      // 自动保存数据
      this.saveGameData();
      return true;
    }
    return false;
  }

  /**
   * 使用道具
   */
  useItem(itemId: number): boolean {
    const currentCount = this.player.items.get(itemId) || 0;
    if (currentCount > 0) {
      this.player.items.set(itemId, currentCount - 1);
      // 自动保存数据
      this.saveGameData();
      return true;
    }
    return false;
  }

  /**
   * 升级装备
   */
  upgradeEquipment(equipId: number): boolean {
    const equipment = this.player.equipments.get(equipId);
    if (equipment && equipment.currentLevel < equipment.maxLevel) {
      const price = equipment.getUpgradePrice();
      if (this.player.spendCoins(price)) {
        equipment.currentLevel++;
        // 自动保存数据
        this.saveGameData();
        return true;
      }
    }
    return false;
  }

  /**
   * 通关
   */
  passLevel(score: number, earnedCoins: number): void {
    const level = this.getCurrentLevel();
    // 累加总分
    this.player.totalScore += score;
    // 更新最高分（与本局得分比较）
    if (score > this.player.highestScore) {
      this.player.highestScore = score;
    }
    // 累加金币：本局获得 + 通关奖励
    this.player.addCoins(earnedCoins + level.reward);
    // 进入下一关
    this.player.currentLevel++;
    // 自动保存数据
    this.saveGameData();
  }

  /**
   * 失败
   */
  failLevel(score: number, earnedCoins: number): void {
    // 累加总分
    this.player.totalScore += score;
    // 更新最高分（与本局得分比较）
    if (score > this.player.highestScore) {
      this.player.highestScore = score;
    }
    // 累加金币：失败也保留本局获得的金币
    this.player.addCoins(earnedCoins);
    // 自动保存数据
    this.saveGameData();
  }

  /**
   * 初始化Preferences存储
   */
  private async initPreferences(): Promise<void> {
    if (!this.context) {
      console.error('Context not initialized');
      return;
    }

    try {
      this.preferencesStore = await preferences.getPreferences(this.context, this.STORE_NAME);
      await this.loadGameData();
    } catch (e) {
      console.error('Failed to init preferences:', e);
    }
  }

  /**
   * 保存游戏数据
   */
  async saveGameData(): Promise<void> {
    if (!this.preferencesStore) {
      console.error('Preferences not initialized');
      return;
    }

    try {
      const data: SaveData = {
        totalScore: this.player.totalScore,
        currentLevel: this.player.currentLevel,
        coins: this.player.coins,
        highestScore: this.player.highestScore,
        items: Array.from(this.player.items.entries()),
        equipments: Array.from(this.player.equipments.entries()).map((entry): EquipmentData => ({
          id: entry[0],
          currentLevel: entry[1].currentLevel
        }))
      };

      await this.preferencesStore.put('game_data', JSON.stringify(data));
      await this.preferencesStore.flush();
      console.info('Game data saved successfully');
    } catch (e) {
      console.error('Failed to save game data:', e);
    }
  }

  /**
   * 加载游戏数据
   */
  async loadGameData(): Promise<void> {
    if (!this.preferencesStore) {
      console.error('Preferences not initialized');
      return;
    }

    try {
      const jsonStr = await this.preferencesStore.get('game_data', '') as string;
      if (!jsonStr) {
        console.info('No saved data found, using default values');
        return;
      }

      const data: SaveData = JSON.parse(jsonStr);
      this.player.totalScore = data.totalScore || 0;
      this.player.currentLevel = data.currentLevel || 1;
      this.player.coins = data.coins || 100;
      this.player.highestScore = data.highestScore || 0;
      if (data.items) {
        data.items.forEach((item: [number, number]) => {
          this.player.items.set(item[0], item[1]);
        });
      }
      if (data.equipments) {
        data.equipments.forEach((item: EquipmentData) => {
          const eq = this.player.equipments.get(item.id);
          if (eq) {
            eq.currentLevel = item.currentLevel;
          }
        });
      }
      console.info('Game data loaded successfully');
    } catch (e) {
      console.error('Failed to load game data:', e);
    }
  }
}
