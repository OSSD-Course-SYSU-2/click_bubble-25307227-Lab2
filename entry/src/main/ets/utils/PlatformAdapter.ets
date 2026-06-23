/**
 * 平台适配器 - 多端部署核心
 * 支持Phone、Tablet、TV、Wearable、2in1等设备类型
 */

import display from '@ohos.display';

export enum DeviceType {
  PHONE = 'phone',
  TABLET = 'tablet',
  TV = 'tv',
  WEARABLE = 'wearable',
  TWO_IN_ONE = '2in1',
  DEFAULT = 'default'
}

export interface PlatformConfig {
  deviceType: DeviceType;
  screenWidth: number;
  screenHeight: number;
  density: number;
  isLargeScreen: boolean;
  isRoundScreen: boolean;
  hasTouchScreen: boolean;
  hasKeyboard: boolean;
  hasRemoteControl: boolean;
  bubbleSize: number;
  fontSize: number;
  padding: number;
  columns: number;
  maxBubbles: number;
  animationSpeed: number;
}

export interface DisplayInfo {
  width: number;
  height: number;
  density: number;
}

export interface BaseConfig {
  bubbleSize: number;
  fontSize: number;
  padding: number;
  columns: number;
  maxBubbles: number;
  animationSpeed: number;
}

export class PlatformAdapter {
  private static instance: PlatformAdapter;
  private currentDevice: DeviceType = DeviceType.DEFAULT;
  private config: PlatformConfig;

  private constructor() {
    this.config = this.getDefaultConfig();
    this.detectDevice();
  }

  static getInstance(): PlatformAdapter {
    if (!PlatformAdapter.instance) {
      PlatformAdapter.instance = new PlatformAdapter();
    }
    return PlatformAdapter.instance;
  }

  /**
   * 检测当前设备类型
   */
  private detectDevice(): void {
    try {
      const displayInfo = this.getDisplayInfo();
      const screenWidth = displayInfo.width;
      const screenHeight = displayInfo.height;
      const density = displayInfo.density;

      // 根据屏幕物理尺寸判断设备类型（注意判断顺序：先判断特殊设备）
      const minDimension = Math.min(screenWidth, screenHeight);
      const maxDimension = Math.max(screenWidth, screenHeight);

      if (minDimension < 200) {
        // 小于200dp，认为是手表
        this.currentDevice = DeviceType.WEARABLE;
      } else if (maxDimension >= 1920 && minDimension >= 1080) {
        // 大屏设备（1920x1080及以上），优先判断TV
        this.currentDevice = DeviceType.TV;
      } else if (maxDimension >= 1200 && minDimension >= 900) {
        // 1200x900 ~ 1920x1080，认为是平板
        this.currentDevice = DeviceType.TABLET;
      } else if (maxDimension >= 1000 && minDimension >= 600) {
        // 中等尺寸（1000x600+），可能是2in1设备
        this.currentDevice = DeviceType.TWO_IN_ONE;
      } else {
        // 默认为手机
        this.currentDevice = DeviceType.PHONE;
      }

      this.config = this.createConfigForDevice(this.currentDevice, screenWidth, screenHeight, density);
    } catch (error) {
      console.error('Device detection failed:', error);
      this.currentDevice = DeviceType.PHONE;
      this.config = this.getDefaultConfig();
    }
  }

  /**
   * 获取显示信息
   */
  private getDisplayInfo(): DisplayInfo {
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      return {
        width: defaultDisplay.width,
        height: defaultDisplay.height,
        density: defaultDisplay.densityDPI / 160 // densityDPI是dpi值，除以160得到density
      };
    } catch (e) {
      console.warn('Failed to get display info, using defaults:', e);
      return {
        width: 1080,
        height: 2340,
        density: 3.0
      };
    }
  }

  /**
   * 为特定设备创建配置
   */
  private createConfigForDevice(
    deviceType: DeviceType,
    screenWidth: number,
    screenHeight: number,
    density: number
  ): PlatformConfig {
    const baseConfig = this.getBaseConfig(deviceType);

    return {
      deviceType: deviceType,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      density: density,
      isLargeScreen: screenWidth > 600 || screenHeight > 600,
      isRoundScreen: deviceType === DeviceType.WEARABLE,
      hasTouchScreen: deviceType !== DeviceType.TV,
      hasKeyboard: deviceType === DeviceType.TWO_IN_ONE,
      hasRemoteControl: deviceType === DeviceType.TV,
      bubbleSize: baseConfig.bubbleSize,
      fontSize: baseConfig.fontSize,
      padding: baseConfig.padding,
      columns: baseConfig.columns,
      maxBubbles: baseConfig.maxBubbles,
      animationSpeed: baseConfig.animationSpeed
    };
  }

  /**
   * 获取各设备的基础配置
   */
  private getBaseConfig(deviceType: DeviceType): BaseConfig {
    switch (deviceType) {
      case DeviceType.PHONE:
        return {
          bubbleSize: 50,
          fontSize: 16,
          padding: 10,
          columns: 8,
          maxBubbles: 30,
          animationSpeed: 1.0
        };

      case DeviceType.TABLET:
        return {
          bubbleSize: 80,
          fontSize: 22,
          padding: 25,
          columns: 16,
          maxBubbles: 80,
          animationSpeed: 1.1
        };

      case DeviceType.TV:
        return {
          bubbleSize: 80,
          fontSize: 24,
          padding: 30,
          columns: 10,
          maxBubbles: 40,
          animationSpeed: 0.8 // TV上动画稍慢，更流畅
        };

      case DeviceType.WEARABLE:
        return {
          bubbleSize: 30,
          fontSize: 12,
          padding: 5,
          columns: 4,
          maxBubbles: 15,
          animationSpeed: 1.2 // 手表上动画更快
        };

      case DeviceType.TWO_IN_ONE:
        return {
          bubbleSize: 65,
          fontSize: 18,
          padding: 15,
          columns: 10,
          maxBubbles: 45,
          animationSpeed: 1.0
        };

      default:
        return {
          bubbleSize: 50,
          fontSize: 16,
          padding: 10,
          columns: 8,
          maxBubbles: 30,
          animationSpeed: 1.0
        };
    }
  }

  /**
   * 获取默认配置
   */
  private getDefaultConfig(): PlatformConfig {
    return {
      deviceType: DeviceType.DEFAULT,
      screenWidth: 1080,
      screenHeight: 2340,
      density: 3.0,
      isLargeScreen: false,
      isRoundScreen: false,
      hasTouchScreen: true,
      hasKeyboard: false,
      hasRemoteControl: false,
      bubbleSize: 50,
      fontSize: 16,
      padding: 10,
      columns: 8,
      maxBubbles: 30,
      animationSpeed: 1.0
    };
  }

  /**
   * 获取当前设备类型
   */
  getDeviceType(): DeviceType {
    return this.currentDevice;
  }

  /**
   * 获取平台配置
   */
  getConfig(): PlatformConfig {
    return this.config;
  }

  /**
   * 获取泡泡大小
   */
  getBubbleSize(): number {
    return this.config.bubbleSize;
  }

  /**
   * 获取字体大小
   */
  getFontSize(scale: number = 1.0): number {
    return this.config.fontSize * scale;
  }

  /**
   * 获取内边距
   */
  getPadding(): number {
    return this.config.padding;
  }

  /**
   * 获取列数
   */
  getColumns(): number {
    return this.config.columns;
  }

  /**
   * 获取最大泡泡数
   */
  getMaxBubbles(): number {
    return this.config.maxBubbles;
  }

  /**
   * 获取动画速度
   */
  getAnimationSpeed(): number {
    return this.config.animationSpeed;
  }

  /**
   * 是否为大屏设备
   */
  isLargeScreen(): boolean {
    return this.config.isLargeScreen;
  }

  /**
   * 是否为圆形屏幕（手表）
   */
  isRoundScreen(): boolean {
    return this.config.isRoundScreen;
  }

  /**
   * 是否支持触摸
   */
  hasTouchScreen(): boolean {
    return this.config.hasTouchScreen;
  }

  /**
   * 是否支持键盘
   */
  hasKeyboard(): boolean {
    return this.config.hasKeyboard;
  }

  /**
   * 是否支持遥控器
   */
  hasRemoteControl(): boolean {
    return this.config.hasRemoteControl;
  }

  /**
   * 获取响应式布局宽度百分比
   */
  getLayoutWidthPercent(): string {
    if (this.config.isLargeScreen) {
      return '70%'; // 大屏设备使用70%宽度
    } else if (this.currentDevice === DeviceType.WEARABLE) {
      return '100%'; // 手表使用全宽
    } else {
      return '90%'; // 手机使用90%宽度
    }
  }

  /**
   * 获取游戏区域高度
   */
  getGameAreaHeight(): number {
    const screenHeight = this.config.screenHeight;
    switch (this.currentDevice) {
      case DeviceType.WEARABLE:
        return screenHeight * 0.6; // 手表游戏区域占60%
      case DeviceType.TV:
        return screenHeight * 0.7; // TV游戏区域占70%
      default:
        return screenHeight * 0.65; // 其他设备占65%
    }
  }

  /**
   * 获取游戏画布宽度（vp）
   * 将物理像素转换为vp，再按设备类型比例缩放
   */
  getCanvasWidth(): number {
    const widthVp = this.config.screenWidth / this.config.density;
    switch (this.currentDevice) {
      case DeviceType.WEARABLE:
        return Math.floor(widthVp * 0.9);
      case DeviceType.TV:
        return Math.floor(widthVp * 0.6);
      case DeviceType.TABLET:
        return Math.floor(widthVp * 0.55);
      case DeviceType.TWO_IN_ONE:
        return Math.floor(widthVp * 0.55);
      default:
        return Math.floor(widthVp * 0.9);
    }
  }

  /**
   * 获取游戏画布高度（vp）
   * 将物理像素转换为vp，再按设备类型比例缩放
   */
  getCanvasHeight(): number {
    const heightVp = this.config.screenHeight / this.config.density;
    switch (this.currentDevice) {
      case DeviceType.WEARABLE:
        return Math.floor(heightVp * 0.5);
      case DeviceType.TV:
        return Math.floor(heightVp * 0.55);
      case DeviceType.TABLET:
        return Math.floor(heightVp * 0.5);
      case DeviceType.TWO_IN_ONE:
        return Math.floor(heightVp * 0.5);
      default:
        return Math.floor(heightVp * 0.6);
    }
  }

  /**
   * 获取UI缩放比例
   */
  getUIScale(): number {
    switch (this.currentDevice) {
      case DeviceType.WEARABLE:
        return 0.6;
      case DeviceType.TABLET:
        return 1.4;
      case DeviceType.TV:
        return 1.5;
      case DeviceType.TWO_IN_ONE:
        return 1.2;
      default:
        return 1.0;
    }
  }

  /**
   * 打印当前设备信息（调试用）
   */
  printDeviceInfo(): void {
    console.log('=== Platform Info ===');
    console.log(`Device Type: ${this.currentDevice}`);
    console.log(`Screen: ${this.config.screenWidth}x${this.config.screenHeight}`);
    console.log(`Density: ${this.config.density}`);
    console.log(`Bubble Size: ${this.config.bubbleSize}`);
    console.log(`Font Size: ${this.config.fontSize}`);
    console.log(`Columns: ${this.config.columns}`);
    console.log(`Max Bubbles: ${this.config.maxBubbles}`);
    console.log(`Animation Speed: ${this.config.animationSpeed}`);
    console.log('=====================');
  }
}
