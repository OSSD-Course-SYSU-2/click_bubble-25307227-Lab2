/**
 * 云同步管理器 - 实现多端游戏数据同步
 * 基于 HarmonyOS 分布式数据同步能力，实现跨设备游戏数据自由轮转
 *
 * 同步策略：
 * 1. 使用分布式数据管理 (@ohos.data.distributedDataObject) 实现实时同步
 * 2. 使用关系型数据库 (@ohos.data.relationalStore) 作为本地缓存
 * 3. 冲突解决：采用"最新时间戳优先"策略
 * 4. 支持离线模式，网络恢复后自动同步
 */

import distributedDataObject from '@ohos.data.distributedDataObject';
import common from '@ohos.app.ability.common';
import { SaveData, EquipmentData } from './GameDataManager';
import { PlatformAdapter, DeviceType } from './PlatformAdapter';

/**
 * 同步状态枚举
 */
export enum SyncStatus {
  IDLE = 'idle',               // 空闲
  SYNCING = 'syncing',         // 同步中
  SUCCESS = 'success',         // 同步成功
  FAILED = 'failed',           // 同步失败
  CONFLICT = 'conflict',       // 数据冲突
  OFFLINE = 'offline'          // 离线模式
}

/**
 * 同步配置接口
 */
export interface SyncConfig {
  /** 是否启用云同步 */
  enabled: boolean;
  /** 自动同步间隔（毫秒），0表示不自动同步 */
  autoSyncInterval: number;
  /** 是否在应用启动时自动同步 */
  syncOnStart: boolean;
  /** 是否在数据变更时自动同步 */
  syncOnChange: boolean;
  /** 冲突解决策略：'latest' 最新优先 | 'local' 本地优先 | 'remote' 远程优先 */
  conflictStrategy: string;
  /** 同步会话ID（同一用户多设备使用相同sessionId） */
  sessionId: string;
}

/**
 * 带时间戳的同步数据
 */
export interface SyncData extends SaveData {
  /** 最后修改时间戳 */
  lastModified: number;
  /** 修改设备标识 */
  deviceId: string;
  /** 数据版本号 */
  version: number;
}

/**
 * 同步状态变更回调
 */
export type SyncStatusCallback = (status: SyncStatus, message: string) => void;

/**
 * 分布式对象数据接口
 */
interface DistributedObjectData {
  totalScore: number;
  currentLevel: number;
  coins: number;
  highestScore: number;
  itemsJson: string;
  equipmentsJson: string;
  lastModified: number;
  deviceId: string;
  version: number;
}

/**
 * 云同步管理器
 */
export class CloudSyncManager {
  private static instance: CloudSyncManager;
  private context: common.UIAbilityContext | null = null;
  private dataObjectRef: distributedDataObject.DataObject | null = null;
  private distributedData: DistributedObjectData | null = null;
  private syncConfig: SyncConfig;
  private currentStatus: SyncStatus = SyncStatus.IDLE;
  private statusCallbacks: SyncStatusCallback[] = [];
  private lastSyncTime: number = 0;
  private localDeviceId: string = '';
  private autoSyncTimer: number = -1;
  private syncVersion: number = 0;

  /** 分布式对象Session ID */
  private readonly SESSION_ID_PREFIX = 'bubble_game_sync_';

  private constructor() {
    this.syncConfig = this.getDefaultSyncConfig();
  }

  static getInstance(): CloudSyncManager {
    if (!CloudSyncManager.instance) {
      CloudSyncManager.instance = new CloudSyncManager();
    }
    return CloudSyncManager.instance;
  }

  /**
   * 获取默认同步配置
   */
  private getDefaultSyncConfig(): SyncConfig {
    return {
      enabled: true,
      autoSyncInterval: 30000,     // 30秒自动同步一次
      syncOnStart: true,           // 启动时自动同步
      syncOnChange: true,          // 数据变更时自动同步
      conflictStrategy: 'latest',  // 最新时间戳优先
      sessionId: 'default_session' // 默认会话ID
    };
  }

  /**
   * 初始化云同步管理器
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;

    try {
      // 获取本地设备ID
      this.localDeviceId = await this.getLocalDeviceId();

      // 加载同步配置
      await this.loadSyncConfig();

      if (!this.syncConfig.enabled) {
        console.info('[CloudSync] Sync is disabled');
        this.updateStatus(SyncStatus.OFFLINE, '同步已禁用');
        return;
      }

      // 初始化分布式数据对象
      await this.initDistributedObject();

      // 启动时自动同步
      if (this.syncConfig.syncOnStart) {
        await this.syncFromCloud();
      }

      // 启动自动同步定时器
      if (this.syncConfig.autoSyncInterval > 0) {
        this.startAutoSync();
      }

      console.info('[CloudSync] CloudSyncManager initialized successfully');
    } catch (e) {
      console.error('[CloudSync] Failed to initialize:', e);
      this.updateStatus(SyncStatus.FAILED, '初始化同步失败');
    }
  }

  /**
   * 获取本地设备ID
   */
  private async getLocalDeviceId(): Promise<string> {
    try {
      const deviceInfo = PlatformAdapter.getInstance().getDeviceType();
      const timestamp = Date.now();
      // 使用设备类型 + 时间戳后6位作为设备标识
      return `${deviceInfo}_${timestamp % 1000000}`;
    } catch (e) {
      return `unknown_${Date.now() % 1000000}`;
    }
  }

  /**
   * 加载同步配置
   */
  private async loadSyncConfig(): Promise<void> {
    try {
      // 从应用配置中读取同步设置
      // 这里使用默认配置，实际项目中可从Preferences中读取用户设置
      const savedConfig = this.loadConfigFromPreferences();
      if (savedConfig) {
        const defaultConfig = this.getDefaultSyncConfig();
        this.syncConfig = {
          enabled: savedConfig.enabled ?? defaultConfig.enabled,
          autoSyncInterval: savedConfig.autoSyncInterval ?? defaultConfig.autoSyncInterval,
          syncOnStart: savedConfig.syncOnStart ?? defaultConfig.syncOnStart,
          syncOnChange: savedConfig.syncOnChange ?? defaultConfig.syncOnChange,
          conflictStrategy: savedConfig.conflictStrategy ?? defaultConfig.conflictStrategy,
          sessionId: savedConfig.sessionId ?? defaultConfig.sessionId
        };
      }
    } catch (e) {
      console.warn('[CloudSync] Failed to load sync config, using defaults:', e);
    }
  }

  /**
   * 从Preferences加载配置
   */
  private loadConfigFromPreferences(): SyncConfig | null {
    // 预留：从本地存储读取用户自定义的同步配置
    // 当前使用默认配置
    return null;
  }

  /**
   * 初始化分布式数据对象
   */
  private async initDistributedObject(): Promise<void> {
    try {
      const sessionId = this.SESSION_ID_PREFIX + this.syncConfig.sessionId;

      // 初始化分布式数据
      this.distributedData = {
        totalScore: 0,
        currentLevel: 1,
        coins: 100,
        highestScore: 0,
        itemsJson: '',
        equipmentsJson: '',
        lastModified: 0,
        deviceId: this.localDeviceId,
        version: 0
      };

      // 创建分布式数据对象
      this.dataObjectRef = distributedDataObject.create(this.context, this.distributedData);

      // 设置会话ID
      this.dataObjectRef.setSessionId(sessionId);

      // 监听远端数据变更
      this.dataObjectRef.on('change', (sessionId: string, fields: string[]) => {
        console.info(`[CloudSync] Remote data changed, sessionId: ${sessionId}, fields: ${fields.join(',')}`);
        this.onRemoteDataChange(fields);
      });

      // 监听状态变更
      this.dataObjectRef.on('status', (sessionId: string, networkId: string, status: string) => {
        console.info(`[CloudSync] Status changed: ${status}, networkId: ${networkId}`);
        if (status === 'online') {
          this.updateStatus(SyncStatus.IDLE, '设备已上线');
        } else if (status === 'offline') {
          this.updateStatus(SyncStatus.OFFLINE, '设备已离线');
        }
      });

      console.info('[CloudSync] Distributed object initialized with sessionId: ' + sessionId);
    } catch (e) {
      console.error('[CloudSync] Failed to init distributed object:', e);
      // 降级为离线模式
      this.updateStatus(SyncStatus.OFFLINE, '分布式服务不可用，进入离线模式');
    }
  }

  /**
   * 远端数据变更回调
   */
  private onRemoteDataChange(fields: string[]): void {
    if (!this.distributedData) {
      return;
    }

    try {
      const remoteData: SyncData = {
        totalScore: this.distributedData.totalScore,
        currentLevel: this.distributedData.currentLevel,
        coins: this.distributedData.coins,
        highestScore: this.distributedData.highestScore,
        items: [],
        equipments: [],
        lastModified: this.distributedData.lastModified,
        deviceId: this.distributedData.deviceId,
        version: this.distributedData.version
      };

      // 解析JSON字段
      const itemsJson = this.distributedData.itemsJson;
      const equipmentsJson = this.distributedData.equipmentsJson;
      if (itemsJson) {
        remoteData.items = JSON.parse(itemsJson);
      }
      if (equipmentsJson) {
        remoteData.equipments = JSON.parse(equipmentsJson);
      }

      // 检查是否是自己的数据变更（忽略自己发出的更新）
      if (remoteData.deviceId === this.localDeviceId) {
        return;
      }

      // 通知数据管理器处理远端数据
      this.handleRemoteData(remoteData);
    } catch (e) {
      console.error('[CloudSync] Failed to handle remote data change:', e);
    }
  }

  /**
   * 处理远端数据
   */
  private handleRemoteData(remoteData: SyncData): void {
    // 导入 GameDataManager 会造成循环依赖，通过回调方式通知
    if (this.dataChangeCallback) {
      this.dataChangeCallback(remoteData);
    }
  }

  private dataChangeCallback: ((data: SyncData) => void) | null = null;

  /**
   * 注册数据变更回调
   */
  onDataChange(callback: (data: SyncData) => void): void {
    this.dataChangeCallback = callback;
  }

  /**
   * 将本地数据同步到云端（分布式对象）
   */
  async syncToCloud(saveData: SaveData): Promise<boolean> {
    if (!this.syncConfig.enabled || !this.distributedData) {
      console.info('[CloudSync] Sync disabled or distributed object not available');
      return false;
    }

    try {
      this.updateStatus(SyncStatus.SYNCING, '正在同步数据到云端...');

      const syncData: SyncData = {
        totalScore: saveData.totalScore,
        currentLevel: saveData.currentLevel,
        coins: saveData.coins,
        highestScore: saveData.highestScore,
        items: saveData.items,
        equipments: saveData.equipments,
        lastModified: Date.now(),
        deviceId: this.localDeviceId,
        version: ++this.syncVersion
      };

      // 更新分布式数据对象
      this.distributedData.totalScore = syncData.totalScore;
      this.distributedData.currentLevel = syncData.currentLevel;
      this.distributedData.coins = syncData.coins;
      this.distributedData.highestScore = syncData.highestScore;
      this.distributedData.itemsJson = JSON.stringify(syncData.items);
      this.distributedData.equipmentsJson = JSON.stringify(syncData.equipments);
      this.distributedData.lastModified = syncData.lastModified;
      this.distributedData.deviceId = syncData.deviceId;
      this.distributedData.version = syncData.version;

      // 保存同步记录到本地
      this.lastSyncTime = Date.now();

      this.updateStatus(SyncStatus.SUCCESS, '数据同步成功');
      console.info('[CloudSync] Data synced to cloud successfully');
      return true;
    } catch (e) {
      console.error('[CloudSync] Failed to sync to cloud:', e);
      this.updateStatus(SyncStatus.FAILED, '同步到云端失败');
      return false;
    }
  }

  /**
   * 从云端拉取数据
   */
  async syncFromCloud(): Promise<SyncData | null> {
    if (!this.syncConfig.enabled || !this.distributedData) {
      return null;
    }

    try {
      this.updateStatus(SyncStatus.SYNCING, '正在从云端拉取数据...');

      const remoteData: SyncData = {
        totalScore: this.distributedData.totalScore,
        currentLevel: this.distributedData.currentLevel,
        coins: this.distributedData.coins,
        highestScore: this.distributedData.highestScore,
        items: [],
        equipments: [],
        lastModified: this.distributedData.lastModified,
        deviceId: this.distributedData.deviceId,
        version: this.distributedData.version
      };

      const itemsJson = this.distributedData.itemsJson;
      const equipmentsJson = this.distributedData.equipmentsJson;
      if (itemsJson) {
        remoteData.items = JSON.parse(itemsJson);
      }
      if (equipmentsJson) {
        remoteData.equipments = JSON.parse(equipmentsJson);
      }

      this.lastSyncTime = Date.now();
      this.updateStatus(SyncStatus.SUCCESS, '数据拉取成功');
      return remoteData;
    } catch (e) {
      console.error('[CloudSync] Failed to sync from cloud:', e);
      this.updateStatus(SyncStatus.FAILED, '从云端拉取数据失败');
      return null;
    }
  }

  /**
   * 解决数据冲突
   * @param localData 本地数据
   * @param remoteData 远端数据
   * @returns 合并后的数据
   */
  resolveConflict(localData: SyncData, remoteData: SyncData): SyncData {
    switch (this.syncConfig.conflictStrategy) {
      case 'latest':
        // 最新时间戳优先
        return localData.lastModified >= remoteData.lastModified ? localData : remoteData;

      case 'local':
        // 本地优先
        return localData;

      case 'remote':
        // 远程优先
        return remoteData;

      default:
        // 默认：智能合并 - 取各字段的最大值/最优值
        return this.smartMerge(localData, remoteData);
    }
  }

  /**
   * 智能合并策略
   * 取各字段的最优值：分数取最大、关卡取最高、金币取最大等
   */
  private smartMerge(localData: SyncData, remoteData: SyncData): SyncData {
    // 合并道具：取数量最多的
    const mergedItems: [number, number][] = [];
    const itemMap = new Map<number, number>();

    localData.items.forEach((item: [number, number]) => {
      itemMap.set(item[0], Math.max(itemMap.get(item[0]) || 0, item[1]));
    });
    remoteData.items.forEach((item: [number, number]) => {
      itemMap.set(item[0], Math.max(itemMap.get(item[0]) || 0, item[1]));
    });
    itemMap.forEach((count, id) => {
      mergedItems.push([id, count]);
    });

    // 合并装备：取等级最高的
    const mergedEquipments: EquipmentData[] = [];
    const equipMap = new Map<number, number>();

    localData.equipments.forEach((eq: EquipmentData) => {
      equipMap.set(eq.id, Math.max(equipMap.get(eq.id) || 0, eq.currentLevel));
    });
    remoteData.equipments.forEach((eq: EquipmentData) => {
      equipMap.set(eq.id, Math.max(equipMap.get(eq.id) || 0, eq.currentLevel));
    });
    equipMap.forEach((level, id) => {
      mergedEquipments.push({ id, currentLevel: level });
    });

    return {
      totalScore: Math.max(localData.totalScore, remoteData.totalScore),
      currentLevel: Math.max(localData.currentLevel, remoteData.currentLevel),
      coins: Math.max(localData.coins, remoteData.coins),
      highestScore: Math.max(localData.highestScore, remoteData.highestScore),
      items: mergedItems,
      equipments: mergedEquipments,
      lastModified: Date.now(),
      deviceId: this.localDeviceId,
      version: Math.max(localData.version, remoteData.version) + 1
    };
  }

  /**
   * 启动自动同步
   */
  private startAutoSync(): void {
    if (this.autoSyncTimer !== -1) {
      clearInterval(this.autoSyncTimer);
    }

    this.autoSyncTimer = setInterval(() => {
      this.autoSync();
    }, this.syncConfig.autoSyncInterval);
  }

  /**
   * 停止自动同步
   */
  stopAutoSync(): void {
    if (this.autoSyncTimer !== -1) {
      clearInterval(this.autoSyncTimer);
      this.autoSyncTimer = -1;
    }
  }

  /**
   * 自动同步执行
   */
  private async autoSync(): Promise<void> {
    if (!this.syncConfig.enabled) {
      return;
    }

    try {
      const remoteData = await this.syncFromCloud();
      if (remoteData && remoteData.lastModified > this.lastSyncTime) {
        // 远端有更新，通知数据管理器
        this.handleRemoteData(remoteData);
      }
    } catch (e) {
      console.error('[CloudSync] Auto sync failed:', e);
    }
  }

  /**
   * 更新同步状态
   */
  private updateStatus(status: SyncStatus, message: string): void {
    this.currentStatus = status;
    console.info(`[CloudSync] Status: ${status}, Message: ${message}`);

    // 通知所有状态监听器
    this.statusCallbacks.forEach(callback => {
      try {
        callback(status, message);
      } catch (e) {
        console.error('[CloudSync] Status callback error:', e);
      }
    });
  }

  /**
   * 注册状态变更回调
   */
  onStatusChange(callback: SyncStatusCallback): void {
    this.statusCallbacks.push(callback);
  }

  /**
   * 移除状态变更回调
   */
  removeStatusChange(callback: SyncStatusCallback): void {
    const index = this.statusCallbacks.indexOf(callback);
    if (index > -1) {
      this.statusCallbacks.splice(index, 1);
    }
  }

  /**
   * 获取当前同步状态
   */
  getStatus(): SyncStatus {
    return this.currentStatus;
  }

  /**
   * 获取同步配置
   */
  getConfig(): SyncConfig {
    return {
      enabled: this.syncConfig.enabled,
      autoSyncInterval: this.syncConfig.autoSyncInterval,
      syncOnStart: this.syncConfig.syncOnStart,
      syncOnChange: this.syncConfig.syncOnChange,
      conflictStrategy: this.syncConfig.conflictStrategy,
      sessionId: this.syncConfig.sessionId
    };
  }

  /**
   * 更新同步配置
   */
  async updateConfig(config: Partial<SyncConfig>): Promise<void> {
    const oldInterval = this.syncConfig.autoSyncInterval;
    if (config.enabled !== undefined) {
      this.syncConfig.enabled = config.enabled;
    }
    if (config.autoSyncInterval !== undefined) {
      this.syncConfig.autoSyncInterval = config.autoSyncInterval;
    }
    if (config.syncOnStart !== undefined) {
      this.syncConfig.syncOnStart = config.syncOnStart;
    }
    if (config.syncOnChange !== undefined) {
      this.syncConfig.syncOnChange = config.syncOnChange;
    }
    if (config.conflictStrategy !== undefined) {
      this.syncConfig.conflictStrategy = config.conflictStrategy;
    }
    if (config.sessionId !== undefined) {
      this.syncConfig.sessionId = config.sessionId;
    }

    // 如果自动同步间隔变更，重启定时器
    if (config.autoSyncInterval !== undefined && config.autoSyncInterval !== oldInterval) {
      this.stopAutoSync();
      if (this.syncConfig.autoSyncInterval > 0 && this.syncConfig.enabled) {
        this.startAutoSync();
      }
    }

    // 如果sessionId变更，重新初始化分布式对象
    if (config.sessionId !== undefined && config.sessionId !== this.syncConfig.sessionId) {
      await this.initDistributedObject();
    }
  }

  /**
   * 获取上次同步时间
   */
  getLastSyncTime(): number {
    return this.lastSyncTime;
  }

  /**
   * 获取本地设备ID
   */
  getDeviceId(): string {
    return this.localDeviceId;
  }

  /**
   * 销毁同步管理器
   */
  destroy(): void {
    this.stopAutoSync();

    if (this.dataObjectRef) {
      try {
        this.dataObjectRef.off('change');
        this.dataObjectRef.off('status');
        this.dataObjectRef.setSessionId('');
      } catch (e) {
        console.error('[CloudSync] Failed to destroy distributed object:', e);
      }
      this.dataObjectRef = null;
    }

    this.distributedData = null;
    this.statusCallbacks = [];
    this.dataChangeCallback = null;
    this.updateStatus(SyncStatus.IDLE, '同步管理器已销毁');
  }
}
