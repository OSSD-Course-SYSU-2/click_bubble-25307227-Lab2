/**
 * 屏幕旋转管理器
 * 支持屏幕自由旋转、方向锁定、布局自适应
 */

import window from '@ohos.window';
import common from '@ohos.app.ability.common';

export enum Orientation {
  PORTRAIT = 'portrait',           // 竖屏
  LANDSCAPE = 'landscape',         // 横屏
  PORTRAIT_INVERTED = 'portrait_inverted',   // 反向竖屏
  LANDSCAPE_INVERTED = 'landscape_inverted', // 反向横屏
  UNSPECIFIED = 'unspecified'      // 未指定，跟随系统
}

export interface ScreenInfo {
  width: number;
  height: number;
  orientation: Orientation;
  isLandscape: boolean;
  isPortrait: boolean;
  density: number;
}

export interface GameAreaSize {
  width: number;
  height: number;
}

export class ScreenRotationManager {
  private static instance: ScreenRotationManager;
  private mainWindow: window.Window | null = null;
  private context: common.UIAbilityContext | null = null;
  private currentOrientation: Orientation = Orientation.PORTRAIT;
  private isLocked: boolean = false;
  private screenInfo: ScreenInfo;
  private orientationChangeCallbacks: Array<(orientation: Orientation) => void> = [];

  private constructor() {
    this.screenInfo = this.getDefaultScreenInfo();
  }

  static getInstance(): ScreenRotationManager {
    if (!ScreenRotationManager.instance) {
      ScreenRotationManager.instance = new ScreenRotationManager();
    }
    return ScreenRotationManager.instance;
  }

  /**
   * 初始化窗口管理
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    try {
      this.mainWindow = await window.getLastWindow(context);
      await this.updateScreenInfo();
      this.registerOrientationChangeListener();
      console.log('ScreenRotationManager initialized successfully');
    } catch (error) {
      console.error('Failed to initialize ScreenRotationManager:', error);
    }
  }

  /**
   * 获取默认屏幕信息
   */
  private getDefaultScreenInfo(): ScreenInfo {
    return {
      width: 1080,
      height: 2340,
      orientation: Orientation.PORTRAIT,
      isLandscape: false,
      isPortrait: true,
      density: 3.0
    };
  }

  /**
   * 更新屏幕信息
   */
  private async updateScreenInfo(): Promise<void> {
    if (!this.mainWindow) {
      return;
    }

    try {
      const properties = this.mainWindow.getWindowProperties();
      const width = properties.windowRect.width;
      const height = properties.windowRect.height;

      // 判断方向
      const isLandscape = width > height;
      this.currentOrientation = this.detectOrientation(width, height);

      this.screenInfo = {
        width: width,
        height: height,
        orientation: this.currentOrientation,
        isLandscape: isLandscape,
        isPortrait: !isLandscape,
        density: 3.0 // 默认密度，实际应从display API获取
      };

      console.log(`Screen info updated: ${width}x${height}, orientation: ${this.currentOrientation}`);
    } catch (error) {
      console.error('Failed to update screen info:', error);
    }
  }

  /**
   * 检测屏幕方向
   */
  private detectOrientation(width: number, height: number): Orientation {
    if (width > height) {
      return Orientation.LANDSCAPE;
    } else if (height > width) {
      return Orientation.PORTRAIT;
    } else {
      return Orientation.UNSPECIFIED;
    }
  }

  /**
   * 注册方向变化监听器
   */
  private registerOrientationChangeListener(): void {
    if (!this.mainWindow) {
      return;
    }

    try {
      this.mainWindow.on('windowSizeChange', async (size: window.Size) => {
        console.log(`Window size changed: ${size.width}x${size.height}`);
        await this.updateScreenInfo();
        this.notifyOrientationChange();
      });
    } catch (error) {
      console.error('Failed to register orientation change listener:', error);
    }
  }

  /**
   * 通知方向变化
   */
  private notifyOrientationChange(): void {
    this.orientationChangeCallbacks.forEach(callback => {
      callback(this.currentOrientation);
    });
  }

  /**
   * 设置屏幕方向
   */
  async setOrientation(orientation: Orientation): Promise<boolean> {
    if (!this.mainWindow || this.isLocked) {
      console.warn('Cannot set orientation: window not initialized or screen is locked');
      return false;
    }

    try {
      // 使用数字常量代替已废弃的枚举
      let preferredOrientation: number;

      switch (orientation) {
        case Orientation.PORTRAIT:
          preferredOrientation = 1; // PORTRAIT
          break;
        case Orientation.LANDSCAPE:
          preferredOrientation = 2; // LANDSCAPE
          break;
        case Orientation.PORTRAIT_INVERTED:
          preferredOrientation = 3; // PORTRAIT_INVERTED
          break;
        case Orientation.LANDSCAPE_INVERTED:
          preferredOrientation = 4; // LANDSCAPE_INVERTED
          break;
        case Orientation.UNSPECIFIED:
        default:
          preferredOrientation = 0; // UNSPECIFIED
          break;
      }

      await this.mainWindow.setPreferredOrientation(preferredOrientation);
      this.currentOrientation = orientation;
      console.log(`Orientation set to: ${orientation}`);
      return true;
    } catch (error) {
      console.error('Failed to set orientation:', error);
      return false;
    }
  }

  /**
   * 锁定当前方向
   */
  async lockOrientation(): Promise<boolean> {
    this.isLocked = true;
    console.log('Screen orientation locked');
    return true;
  }

  /**
   * 解锁方向
   */
  async unlockOrientation(): Promise<boolean> {
    this.isLocked = false;
    // 恢复跟随系统
    await this.setOrientation(Orientation.UNSPECIFIED);
    console.log('Screen orientation unlocked');
    return true;
  }

  /**
   * 切换横竖屏
   */
  async toggleOrientation(): Promise<boolean> {
    if (this.isLocked) {
      console.warn('Cannot toggle orientation: screen is locked');
      return false;
    }

    const newOrientation = this.screenInfo.isLandscape
      ? Orientation.PORTRAIT
      : Orientation.LANDSCAPE;

    return await this.setOrientation(newOrientation);
  }

  /**
   * 注册方向变化回调
   */
  onOrientationChange(callback: (orientation: Orientation) => void): void {
    this.orientationChangeCallbacks.push(callback);
  }

  /**
   * 移除方向变化回调
   */
  removeOrientationChange(callback: (orientation: Orientation) => void): void {
    const index = this.orientationChangeCallbacks.indexOf(callback);
    if (index > -1) {
      this.orientationChangeCallbacks.splice(index, 1);
    }
  }

  /**
   * 获取当前屏幕信息
   */
  getScreenInfo(): ScreenInfo {
    return this.screenInfo;
  }

  /**
   * 获取当前方向
   */
  getOrientation(): Orientation {
    return this.currentOrientation;
  }

  /**
   * 是否为横屏
   */
  isLandscape(): boolean {
    return this.screenInfo.isLandscape;
  }

  /**
   * 是否为竖屏
   */
  isPortrait(): boolean {
    return this.screenInfo.isPortrait;
  }

  /**
   * 是否已锁定
   */
  isOrientationLocked(): boolean {
    return this.isLocked;
  }

  /**
   * 获取游戏区域尺寸（根据方向自适应）
   */
  getGameAreaSize(): GameAreaSize {
    const screenWidth = this.screenInfo.width;
    const screenHeight = this.screenInfo.height;

    if (this.screenInfo.isLandscape) {
      // 横屏：游戏区域占屏幕的70%宽度，80%高度
      const gameArea: GameAreaSize = {
        width: screenWidth * 0.7,
        height: screenHeight * 0.8
      };
      return gameArea;
    } else {
      // 竖屏：游戏区域占屏幕的90%宽度，60%高度
      const gameArea: GameAreaSize = {
        width: screenWidth * 0.9,
        height: screenHeight * 0.6
      };
      return gameArea;
    }
  }

  /**
   * 获取UI缩放比例（根据方向调整）
   */
  getUIScale(): number {
    if (this.screenInfo.isLandscape) {
      return 1.1; // 横屏稍微放大
    } else {
      return 1.0; // 竖屏标准大小
    }
  }

  /**
   * 获取列数（根据方向调整）
   */
  getColumns(): number {
    if (this.screenInfo.isLandscape) {
      return 12; // 横屏更多列
    } else {
      return 8; // 竖屏标准列数
    }
  }

  /**
   * 打印屏幕信息（调试用）
   */
  printScreenInfo(): void {
    console.log('=== Screen Info ===');
    console.log(`Size: ${this.screenInfo.width}x${this.screenInfo.height}`);
    console.log(`Orientation: ${this.currentOrientation}`);
    console.log(`Is Landscape: ${this.screenInfo.isLandscape}`);
    console.log(`Is Portrait: ${this.screenInfo.isPortrait}`);
    console.log(`Is Locked: ${this.isLocked}`);
    console.log('===================');
  }
}
