
import { Bubble, Level, Item, Equipment, Player } from '../models/GameModels';
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
   * 前期(1-5): 目标=25%-37%可得分（简单）
   * 中期(6-12): 目标=39%-55%可得分（适中）
   * 后期(13-20): 目标=57%-71%可得分（困难但可通关）
   */
  private initLevels(): void {
    for (let i = 1; i <= 20; i++) {
      // 泡泡数量：前期少，后期多
      const bubbleCount = 8 + Math.floor((i - 1) * 3);

      // 时间限制：前期充足，后期紧张，最低25秒
      const timeLimit = Math.max(25, 70 - Math.floor((i - 1) * 2.5));

      // 泡泡移动速度倍率：1.0 → 1.6，越高越难点
      const speedMultiplier = 1.0 + (i - 1) * 0.032;

      // 泡泡半径范围：随关卡缩小，越小越难点，最小15保证可点击
      const minBubbleRadius = Math.max(15, 22 - Math.floor((i - 1) * 0.4));
      const maxBubbleRadius = Math.max(22, 40 - Math.floor((i - 1) * 0.8));

      // 泡泡分值范围：随关卡降低，最小5，最大不低于15
      const minPoints = Math.max(5, 8 - Math.floor((i - 1) * 0.2));
      const maxPoints = Math.max(15, 33 - Math.floor((i - 1) * 0.8));

      // 泡泡生成概率：随关卡提高，最高0.8
      const spawnProbability = Math.min(0.8, 0.6 + (i - 1) * 0.01);

      // 场上最大泡泡数量：随关卡提高，最高70
      const maxBubbles = Math.min(70, 60 + Math.floor((i - 1) * 1.0));

      // 基于实际可得分计算目标分数
      const avgPoints = (minPoints + maxPoints) / 2;
      const totalBubbles = bubbleCount + spawnProbability * timeLimit;
      const maxPossible = totalBubbles * avgPoints;
      const realistic = maxPossible * 0.6; // 60%命中率估算

      // 难度比例：平滑递增
      let ratio: number;
      if (i <= 5) {
        ratio = 0.25 + (i - 1) * 0.03;
      } else if (i <= 12) {
        ratio = 0.37 + (i - 5) * 0.025;
      } else {
        ratio = 0.55 + (i - 12) * 0.02;
      }

      const targetScore = Math.max(50, Math.floor(realistic * ratio));

      // 奖励：随难度增加
      const reward = 80 + (i - 1) * 30;

      this.levels.push(new Level(i, targetScore, bubbleCount, timeLimit, reward,
        speedMultiplier, minBubbleRadius, maxBubbleRadius,
        minPoints, maxPoints, spawnProbability, maxBubbles));
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
