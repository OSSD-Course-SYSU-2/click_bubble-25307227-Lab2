
import { GameDataManager } from '../utils/GameDataManager';
import { GameCanvas } from '../components/GameCanvas';
import { Level, Item, Equipment } from '../models/GameModels';
import { PlatformAdapter } from '../utils/PlatformAdapter';
import router from '@ohos.router';

/**
 * 游戏主页面
 */
@Entry
@Component
export struct GamePage {
  @State currentView: string = 'home'; // home, game, levelSelect, shop
  @State playerCoins: number = 0;
  @State playerLevel: number = 1;
  @State highestScore: number = 0;
  @State showResult: boolean = false;
  @State gameResult: string = '';
  @State resultScore: number = 0;
  @State resultCoins: number = 0; // 本局获得的金币（含通关奖励）
  @State equipments: Equipment[] = []; // 装备列表状态
  @State itemCounts: Map<number, number> = new Map(); // 道具数量状态
  @State showTip: boolean = false; // 显示提示
  @State tipMessage: string = ''; // 提示消息内容

  private gameManager: GameDataManager = GameDataManager.getInstance();
  private platformAdapter: PlatformAdapter = PlatformAdapter.getInstance();

  aboutToAppear() {
    this.updatePlayerInfo();
  }

  /**
   * 更新玩家信息
   */
  updatePlayerInfo(): void {
    this.playerCoins = this.gameManager.player.coins;
    this.playerLevel = this.gameManager.player.currentLevel;
    this.highestScore = this.gameManager.player.highestScore;
    // 更新装备列表 - 创建新数组并深拷贝装备对象以触发状态更新
    this.equipments = this.gameManager.equipments.map(equip => {
      const newEquip = new Equipment(equip.id, equip.name, equip.description, equip.basePrice, equip.effectPerLevel);
      newEquip.currentLevel = equip.currentLevel;
      newEquip.maxLevel = equip.maxLevel;
      return newEquip;
    });
    // 更新道具数量 - 创建新的Map以触发状态更新
    this.itemCounts = new Map(this.gameManager.player.items);
  }

  /**
   * 游戏结束回调
   */
  onGameOver(score: number, passed: boolean, earnedCoins: number): void {
    this.resultScore = score;
    if (passed) {
      this.gameResult = '恭喜通关！';
      const level = this.gameManager.getCurrentLevel();
      this.resultCoins = earnedCoins + level.reward;
      this.gameManager.passLevel(score, earnedCoins);
    } else {
      this.gameResult = '挑战失败';
      this.resultCoins = earnedCoins;
      // 失败时也保存本局获得的金币和分数
      this.gameManager.failLevel(score, earnedCoins);
    }
    this.showResult = true;
    this.updatePlayerInfo();
  }

  /**
   * 显示提示消息
   */
  showTipMessage(message: string): void {
    this.tipMessage = message;
    this.showTip = true;
    // 2秒后自动隐藏提示
    setTimeout(() => {
      this.showTip = false;
    }, 2000);
  }
  build() {
    Stack() {
      if (this.currentView === 'home') {
        this.HomeView()
      } else if (this.currentView === 'game') {
        this.GameView()
      } else if (this.currentView === 'levelSelect') {
        this.LevelSelectView()
      } else if (this.currentView === 'shop') {
        this.ShopView()
      }

      // 游戏结果弹窗
      if (this.showResult) {
        this.ResultDialog()
      }

      // 提示消息弹窗
      if (this.showTip) {
        this.TipDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HomeView() {
    Column() {
      // 游戏标题
      Column() {
        Text('🫧')
          .fontSize(80)
          .margin({ bottom: 20 })
        
        Text('解压泡泡龙')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4ECDC4')
        
        Text('Relaxing Bubble Game')
          .fontSize(16)
          .fontColor('#999')
          .margin({ top: 5 })
      }
      .margin({ top: 80 })
      
      // 玩家信息
      Column() {
        Row() {
          Text('💰 金币: ')
            .fontSize(18)
          Text(`${this.playerCoins}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
        }
        .margin({ bottom: 10 })
        
        Row() {
          Text('🏆 关卡: ')
            .fontSize(18)
          Text(`${this.playerLevel}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4ECDC4')
        }
        .margin({ bottom: 10 })
        
        Row() {
          Text('⭐ 最高分: ')
            .fontSize(18)
          Text(`${this.highestScore}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')
        }
      }
      .margin({ top: 40 })
      
      // 功能按钮
      Column() {
        Button('🎮 开始游戏')
          .width(200)
          .height(55)
          .fontSize(20)
          .backgroundColor('#4ECDC4')
          .borderRadius(30)
          .margin({ bottom: 15 })
          .onClick(() => {
            this.currentView = 'game';
          })
        
        Button('📋 选择关卡')
          .width(200)
          .height(55)
          .fontSize(20)
          .backgroundColor('#45B7D1')
          .borderRadius(30)
          .margin({ bottom: 15 })
          .onClick(() => {
            this.currentView = 'levelSelect';
          })
        
        Button('🛒 商店')
          .width(200)
          .height(55)
          .fontSize(20)
          .backgroundColor('#FFA07A')
          .borderRadius(30)
          .margin({ bottom: 15 })
          .onClick(() => {
            this.currentView = 'shop';
          })
      }
      .margin({ top: 50 })
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [['#E8F4F8', 0], ['#FFE4E1', 1]]
    })
  }

  @Builder
  GameView() {
    Column() {
      // 游戏画布（自适应填充剩余空间）
      GameCanvas({
        levelNumber: this.playerLevel,
        targetScore: this.gameManager.getCurrentLevel().targetScore,
        onGameOver: (score: number, passed: boolean, earnedCoins: number) => {
          this.onGameOver(score, passed, earnedCoins);
        }
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  LevelSelectView() {
    Column() {
      // 标题栏
      Row() {
        Button('← 返回')
          .width(80)
          .height(40)
          .fontSize(14)
          .backgroundColor('#999')
          .onClick(() => {
            this.currentView = 'home';
          })
        
        Blank()
        
        Text('选择关卡')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor('#F5F5F5')
      
      // 关卡列表
      this.LevelGrid()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  LevelGrid() {
    Grid() {
      ForEach(this.gameManager.levels, (level: Level, index: number) => {
        GridItem() {
          Column() {
            Text(`${level.levelNumber}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(level.levelNumber <= this.playerLevel ? '#4ECDC4' : '#CCC')
            
            Text(`目标: ${level.targetScore}`)
              .fontSize(12)
              .fontColor('#666')
              .margin({ top: 5 })
            
            Text(`奖励: ${level.reward}💰`)
              .fontSize(12)
              .fontColor('#FFD700')
              .margin({ top: 3 })
          }
          .width(65)
          .height(85)
          .justifyContent(FlexAlign.Center)
          .borderRadius(10)
          .backgroundColor(level.levelNumber <= this.playerLevel ? '#E8F4F8' : '#F0F0F0')
          .onClick(() => {
            if (level.levelNumber <= this.playerLevel) {
              this.playerLevel = level.levelNumber;
              this.currentView = 'game';
            }
          })
        }
      }, (level: Level) => level.levelNumber.toString())
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
    .rowsGap(10)
    .columnsGap(10)
    .width('100%')
    .height('85%')
    .padding(15)
  }

  @Builder
  ShopView() {
    Column() {
      // 标题栏
      Row() {
        Button('← 返回')
          .width(80)
          .height(40)
          .fontSize(14)
          .backgroundColor('#999')
          .onClick(() => {
            this.currentView = 'home';
            this.updatePlayerInfo();
          })
        
        Blank()
        
        Text('商店')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
        
        Blank()
        
        Row() {
          Text('💰')
            .fontSize(16)
          Text(`${this.playerCoins}`)
            .fontSize(16)
            .fontColor('#FFD700')
            .fontWeight(FontWeight.Bold)
        }
        .width(80)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor('#F5F5F5')
      
      // 商店内容
      this.ShopContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  ShopContent() {
    Tabs() {
      TabContent() {
        this.ItemsList()
      }.tabBar('道具')
      
      TabContent() {
        this.EquipmentsList()
      }.tabBar('装备')
    }
    .width('100%')
    .layoutWeight(1)
    .barMode(BarMode.Fixed)
    .onChange(() => {
      this.updatePlayerInfo();
    })
  }

  @Builder
  ItemsList() {
    List() {
      ForEach(this.gameManager.items, (item: Item) => {
        ListItem() {
          Row() {
            Column() {
              Text(this.getItemIcon(item.effect))
                .fontSize(40)
            }
            .width(60)
            .height(60)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#E8F4F8')
            .borderRadius(10)

            Column() {
              Text(item.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')

              Text(item.description)
                .fontSize(14)
                .fontColor('#666')
                .margin({ top: 5 })

              Row() {
                Text(`💰 ${item.price}`)
                  .fontSize(16)
                  .fontColor('#FFD700')

                Blank()

                Text(`拥有: ${this.itemCounts.get(item.id) || 0}`)
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .margin({ top: 5 })
            }
            .layoutWeight(1)
            .padding({ left: 15 })
            .alignItems(HorizontalAlign.Start)

            // 购买和使用按钮
            Column() {
              Button('购买')
                .width(60)
                .height(32)
                .fontSize(12)
                .backgroundColor('#4ECDC4')
                .onClick(() => {
                  if (this.playerCoins < item.price) {
                    this.showTipMessage('金币不足，无法购买！');
                  } else if (this.gameManager.buyItem(item.id)) {
                    this.updatePlayerInfo();
                    this.showTipMessage(`成功购买 ${item.name}！`);
                  }
                })

              Button('使用')
                .width(60)
                .height(32)
                .fontSize(12)
                .backgroundColor('#FF6B6B')
                .margin({ top: 5 })
                .opacity((this.itemCounts.get(item.id) || 0) > 0 ? 1 : 0.5)
                .enabled((this.itemCounts.get(item.id) || 0) > 0)
                .onClick(() => {
                  this.showTipMessage('请在游戏中使用道具！');
                })
            }
            .width(70)
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#FFF')
          .borderRadius(10)
          .shadow({
            radius: 5,
            color: '#10000000',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ bottom: 10 })
        }
      }, (item: Item) => item.id.toString())
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 15, right: 15, top: 10 })
  }

  @Builder
  EquipmentsList() {
    List() {
      ForEach(this.equipments, (equip: Equipment) => {
        ListItem() {
          Row() {
            Column() {
              Text(this.getEquipIcon(equip.id))
                .fontSize(40)
            }
            .width(60)
            .height(60)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('#FFE4E1')
            .borderRadius(10)
            
            Column() {
              Text(equip.name)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
              
              Text(equip.description)
                .fontSize(14)
                .fontColor('#666')
                .margin({ top: 5 })
              
              Row() {
                Text(`等级: ${equip.currentLevel}/${equip.maxLevel}`)
                  .fontSize(14)
                  .fontColor('#4ECDC4')
                
                Blank()
                
                Text(`效果: +${Math.round((equip.getEffect() - 1) * 100)}%`)
                  .fontSize(14)
                  .fontColor('#FF6B6B')
              }
              .width('100%')
              .margin({ top: 5 })
            }
            .layoutWeight(1)
            .padding({ left: 15 })
            .alignItems(HorizontalAlign.Start)
            
            Column() {
              if (equip.currentLevel < equip.maxLevel) {
                Button(`升级`)
                  .width(70)
                  .height(35)
                  .fontSize(12)
                  .backgroundColor('#FF6B6B')
                  .onClick(() => {
                    const price = equip.getUpgradePrice();
                    if (this.playerCoins < price) {
                      this.showTipMessage('金币不足，无法升级！');
                    } else if (this.gameManager.upgradeEquipment(equip.id)) {
                      this.updatePlayerInfo();
                      this.showTipMessage(`成功升级 ${equip.name}！`);
                    }
                  })

                Text(`💰${equip.getUpgradePrice()}`)
                  .fontSize(12)
                  .fontColor('#FFD700')
                  .margin({ top: 3 })
              } else {
                Text('已满级')
                  .fontSize(14)
                  .fontColor('#999')
              }
            }
            .width(80)
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#FFF')
          .borderRadius(10)
          .shadow({
            radius: 5,
            color: '#10000000',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ bottom: 10 })
        }
      }, (equip: Equipment) => `${equip.id}_${equip.currentLevel}`)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 15, right: 15, top: 10 })
  }

  @Builder
  ResultDialog() {
    Column() {
      Text(this.gameResult)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.gameResult === '恭喜通关！' ? '#4ECDC4' : '#FF6B6B')
        .margin({ bottom: 20 })
      
      Text(`得分: ${this.resultScore}`)
        .fontSize(24)
        .fontColor('#333')
        .margin({ bottom: 20 })
      
      Text(`获得 ${this.resultCoins} 💰`)
        .fontSize(18)
        .fontColor('#FFD700')
        .margin({ bottom: 20 })
      
      Row() {
        Button('返回主页')
          .width(120)
          .height(45)
          .fontSize(16)
          .backgroundColor('#999')
          .onClick(() => {
            this.showResult = false;
            this.currentView = 'home';
            this.updatePlayerInfo();
          })
        
        Button('继续游戏')
          .width(120)
          .height(45)
          .fontSize(16)
          .backgroundColor('#4ECDC4')
          .margin({ left: 20 })
          .onClick(() => {
            this.showResult = false;
            this.updatePlayerInfo();
          })
      }
    }
    .width(300)
    .padding(30)
    .backgroundColor('#FFF')
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: '#30000000',
      offsetX: 0,
      offsetY: 10
    })
  }

  @Builder
  TipDialog() {
    Column() {
      Text(this.tipMessage)
        .fontSize(18)
        .fontColor('#FFF')
        .fontWeight(FontWeight.Bold)
    }
    .width('80%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FF6B6B')
    .borderRadius(30)
    .shadow({
      radius: 10,
      color: '#40000000',
      offsetX: 0,
      offsetY: 5
    })
  }

  /**
   * 获取道具图标
   */
  getItemIcon(effect: string): string {
    const icons: Record<string, string> = {
      'double_score': '⚡',
      'time_extend': '⏰',
      'magnet': '🧲',
      'bomb': '💣',
      'shield': '🛡️'
    };
    return icons[effect] || '🎁';
  }

  /**
   * 获取装备图标
   */
  getEquipIcon(id: number): string {
    const icons: Record<number, string> = {
      1: '📊',
      2: '💰',
      3: '🔍',
      4: '⏱️',
      5: '🔥',
      // 新增装备图标
      6: '🐢',
      7: '💥',
      8: '🍀',
      9: '⏰',
      10: '⚡'
    };
    return icons[id] || '⚙️';
  }
}
