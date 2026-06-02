/**
 * 屏幕旋转控制组件
 * 提供可视化的旋转控制按钮
 */

import { ScreenRotationManager, Orientation } from '../utils/ScreenRotationManager';

@Component
export struct RotationControl {
  @State private isLandscape: boolean = false;
  @State private isLocked: boolean = false;
  private rotationManager: ScreenRotationManager = ScreenRotationManager.getInstance();

  aboutToAppear() {
    // 初始化状态
    this.isLandscape = this.rotationManager.isLandscape();
    this.isLocked = this.rotationManager.isOrientationLocked();

    // 监听方向变化
    this.rotationManager.onOrientationChange((orientation: Orientation) => {
      this.isLandscape = orientation === Orientation.LANDSCAPE ||
                         orientation === Orientation.LANDSCAPE_INVERTED;
    });
  }

  aboutToDisappear() {
    // 清理监听器
    // 注意：实际使用时应该移除特定的回调
  }

  build() {
    Row() {
      // 旋转按钮
      Button({ type: ButtonType.Circle }) {
        Text(this.isLandscape ? '竖' : '横')
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(44)
      .height(44)
      .backgroundColor('#4CAF50')
      .enabled(!this.isLocked)
      .opacity(this.isLocked ? 0.5 : 1.0)
      .onClick(async () => {
        await this.rotationManager.toggleOrientation();
      })

      // 锁定按钮
      Button({ type: ButtonType.Circle }) {
        Text(this.isLocked ? '🔒' : '🔓')
          .fontSize(18)
      }
      .width(44)
      .height(44)
      .backgroundColor(this.isLocked ? '#FF5722' : '#2196F3')
      .margin({ left: 8 })
      .onClick(async () => {
        if (this.isLocked) {
          await this.rotationManager.unlockOrientation();
          this.isLocked = false;
        } else {
          await this.rotationManager.lockOrientation();
          this.isLocked = true;
        }
      })
    }
    .padding(8)
  }
}

/**
 * 简化版旋转按钮组件
 */
@Component
export struct SimpleRotationButton {
  @State private isLandscape: boolean = false;
  private rotationManager: ScreenRotationManager = ScreenRotationManager.getInstance();

  aboutToAppear() {
    this.isLandscape = this.rotationManager.isLandscape();
    this.rotationManager.onOrientationChange((orientation: Orientation) => {
      this.isLandscape = orientation === Orientation.LANDSCAPE ||
                         orientation === Orientation.LANDSCAPE_INVERTED;
    });
  }

  build() {
    Button({ type: ButtonType.Circle }) {
      Text(this.isLandscape ? '竖' : '横')
        .fontSize(14)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
    }
    .width(40)
    .height(40)
    .backgroundColor('#4CAF50')
    .onClick(async () => {
      await this.rotationManager.toggleOrientation();
    })
  }
}
