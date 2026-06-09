
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
   * 难度设计：前期简单，中期适中，后期困难
   * 难度维度：目标分数、时间限制、泡泡速度、泡泡大小、分值范围、生成频率
   */
  private initLevels(): void {
    for (let i = 1; i <= 20; i++) {
      // 目标分数：指数增长，后期难度大幅提升
      const targetScore = Math.floor(80 * Math.pow(1.15, i - 1));

      // 泡泡数量：前期少，后期多
      const bubbleCount = 8 + Math.floor((i - 1) * 3);

      // 时间限制：前期充足，后期紧张，最低20秒
      const timeLimit = Math.max(20, 70 - Math.floor((i - 1) * 2.8));

      // 奖励：随难度增加
      const reward = 80 + (i - 1) * 30;

      // 泡泡移动速度倍率：1.0 → 2.0，越高越难点
      const speedMultiplier = 1.0 + (i - 1) * 0.05;

      // 泡泡半径范围：随关卡缩小，越小越难点
      const minBubbleRadius = Math.max(12, 22 - Math.floor((i - 1) * 0.6));
      const maxBubbleRadius = Math.max(20, 40 - Math.floor((i - 1) * 1.0));

      // 泡泡分值范围：随关卡降低，每个泡泡给分更少
      const minPoints = Math.max(3, 8 - Math.floor((i - 1) * 0.3));
      const maxPoints = Math.max(10, 33 - Math.floor((i - 1) * 1.2));

      // 泡泡生成概率：随关卡提高，刷新更频繁
      const spawnProbability = Math.min(0.85, 0.6 + (i - 1) * 0.013);

      // 场上最大泡泡数量：随关卡提高
      const maxBubbles = Math.min(80, 60 + Math.floor((i - 1) * 1.0));

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
  passLevel(score: number): void {
    const level = this.getCurrentLevel();
    this.player.addScore(score);
    this.player.addCoins(level.reward);
    this.player.currentLevel++;
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
