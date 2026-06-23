# 华为MatePad Pro 11 平板部署脚本
# 用于构建和部署泡泡消除游戏到平板设备

Write-Host "=== 泡泡消除游戏 - 平板部署脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查是否在项目根目录
if (-not (Test-Path "build-profile.multi.json5")) {
    Write-Host "❌ 错误: 请在项目根目录下运行此脚本" -ForegroundColor Red
    exit 1
}

Write-Host "📱 华为MatePad Pro 11 部署向导" -ForegroundColor Green
Write-Host ""

# 显示设备信息
Write-Host "【目标设备规格】" -ForegroundColor Yellow
Write-Host "  设备型号: 华为MatePad Pro 11" -ForegroundColor Cyan
Write-Host "  屏幕尺寸: 11英寸" -ForegroundColor Cyan
Write-Host "  分辨率: 2560×1600像素" -ForegroundColor Cyan
Write-Host "  屏幕比例: 16:10" -ForegroundColor Cyan
Write-Host "  像素密度: ~2.0 (320 PPI)" -ForegroundColor Cyan
Write-Host "  HarmonyOS: 4.0及以上" -ForegroundColor Cyan
Write-Host ""

# 显示平板专属优化
Write-Host "【平板专属优化】" -ForegroundColor Yellow
Write-Host "  ✓ 泡泡大小: 80 (更大更易点击)" -ForegroundColor Green
Write-Host "  ✓ 字体大小: 22 (更清晰可读)" -ForegroundColor Cyan
Write-Host "  ✓ 内边距: 25 (更舒适的间距)" -ForegroundColor Green
Write-Host "  ✓ 列数: 16 (竖屏) / 20 (横屏)" -ForegroundColor Cyan
Write-Host "  ✓ 最大泡泡数: 80 (更丰富的场面)" -ForegroundColor Green
Write-Host "  ✓ 动画速度: 1.1 (流畅的视觉效果)" -ForegroundColor Green
Write-Host "  ✓ UI缩放: 1.4 (竖屏) / 1.5 (横屏)" -ForegroundColor Cyan
Write-Host ""

# 显示支持的功能
Write-Host "【支持的功能】" -ForegroundColor Yellow
Write-Host "  ✓ 屏幕自由旋转 (横竖屏切换)" -ForegroundColor Green
Write-Host "  ✓ 多窗口模式 (全屏/分屏/悬浮窗)" -ForegroundColor Green
Write-Host "  ✓ 50个精心设计的关卡" -ForegroundColor Green
Write-Host "  ✓ 10种道具系统" -ForegroundColor Green
Write-Host "  ✓ 10种装备升级系统" -ForegroundColor Green
Write-Host "  ✓ 游戏进度自动保存" -ForegroundColor Green
Write-Host "  ✓ 连击系统和粒子特效" -ForegroundColor Green
Write-Host ""

# 检查hvigorw是否存在
$hvigorw = "hvigorw.bat"
if (-not (Test-Path $hvigorw)) {
    Write-Host "❌ 错误: 未找到 hvigorw.bat 构建工具" -ForegroundColor Red
    Write-Host "   请确保在HarmonyOS项目中运行此脚本" -ForegroundColor Red
    exit 1
}

Write-Host "【构建选项】" -ForegroundColor Yellow
Write-Host "  1. 构建平板版本 (Debug)" -ForegroundColor Cyan
Write-Host "  2. 构建平板版本 (Release)" -ForegroundColor Cyan
Write-Host "  3. 构建所有设备版本" -ForegroundColor Cyan
Write-Host "  4. 仅查看配置信息" -ForegroundColor Cyan
Write-Host "  5. 退出" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "请选择操作 (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🔨 正在构建平板版本 (Debug)..." -ForegroundColor Yellow
        Write-Host ""

        $buildCmd = "$hvigorw assembleHap --no-daemon --mode module -p product=tablet -p module=entry@default"
        Write-Host "执行命令: $buildCmd" -ForegroundColor Gray
        Write-Host ""

        Invoke-Expression $buildCmd

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ 构建成功!" -ForegroundColor Green
            Write-Host ""
            Write-Host "【输出文件】" -ForegroundColor Yellow
            Write-Host "  entry/build/default/outputs/default/entry-default-signed.hap" -ForegroundColor Cyan
            Write-Host ""

            Write-Host "【安装到设备】" -ForegroundColor Yellow
            Write-Host "  方式1: 使用DevEco Studio连接设备并点击运行" -ForegroundColor Cyan
            Write-Host "  方式2: 使用命令行安装" -ForegroundColor Cyan
            Write-Host "    hdc install entry/build/default/outputs/default/entry-default-signed.hap" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "❌ 构建失败!" -ForegroundColor Red
            Write-Host "   请检查错误信息并重试" -ForegroundColor Red
            Write-Host ""
        }
    }

    "2" {
        Write-Host ""
        Write-Host "🔨 正在构建平板版本 (Release)..." -ForegroundColor Yellow
        Write-Host ""

        $buildCmd = "$hvigorw assembleHap --no-daemon --mode module -p product=tablet -p module=entry@default -p buildMode=release"
        Write-Host "执行命令: $buildCmd" -ForegroundColor Gray
        Write-Host ""

        Invoke-Expression $buildCmd

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ 构建成功!" -ForegroundColor Green
            Write-Host ""
            Write-Host "【输出文件】" -ForegroundColor Yellow
            Write-Host "  entry/build/default/outputs/default/entry-default-unsigned.hap" -ForegroundColor Cyan
            Write-Host ""

            Write-Host "【签名】" -ForegroundColor Yellow
            Write-Host "  Release版本需要签名后才能安装" -ForegroundColor Cyan
            Write-Host "  请在DevEco Studio中进行签名配置" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "❌ 构建失败!" -ForegroundColor Red
            Write-Host "   请检查错误信息并重试" -ForegroundColor Red
            Write-Host ""
        }
    }

    "3" {
        Write-Host ""
        Write-Host "🔨 正在构建所有设备版本..." -ForegroundColor Yellow
        Write-Host ""

        $devices = @("phone", "tablet", "tv", "wearable", "2in1")
        $successCount = 0

        foreach ($device in $devices) {
            Write-Host "正在构建 $device 版本..." -ForegroundColor Cyan
            $buildCmd = "$hvigorw assembleHap --no-daemon --mode module -p product=$device -p module=entry@default"
            Invoke-Expression $buildCmd

            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ $device 构建成功" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "  ✗ $device 构建失败" -ForegroundColor Red
            }
            Write-Host ""
        }

        Write-Host "【构建结果】" -ForegroundColor Yellow
        Write-Host "  成功: $successCount / 5" -ForegroundColor $(if ($successCount -eq 5) { "Green" } else { "Yellow" })
        Write-Host ""
    }

    "4" {
        Write-Host ""
        Write-Host "【多端部署配置】" -ForegroundColor Yellow
        Write-Host ""

        Write-Host "支持的设备类型:" -ForegroundColor Cyan
        Write-Host "  1. Phone (手机)" -ForegroundColor White
        Write-Host "     - 泡泡大小: 50, 字体: 16, 列数: 8, 最大泡泡: 30" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  2. Tablet (平板) - 华为MatePad Pro 11" -ForegroundColor White
        Write-Host "     - 泡泡大小: 80, 字体: 22, 列数: 16, 最大泡泡: 80" -ForegroundColor Gray
        Write-Host "     - 支持屏幕旋转和多窗口模式" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  3. TV (电视)" -ForegroundColor White
        Write-Host "     - 泡泡大小: 80, 字体: 24, 列数: 10, 最大泡泡: 40" -ForegroundColor Gray
        Write-Host "     - 支持遥控器操作" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  4. Wearable (智能手表)" -ForegroundColor White
        Write-Host "     - 泡泡大小: 30, 字体: 12, 列数: 4, 最大泡泡: 15" -ForegroundColor Gray
        Write-Host "     - 圆形屏幕适配" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  5. 2in1 (二合一设备)" -ForegroundColor White
        Write-Host "     - 泡泡大小: 65, 字体: 18, 列数: 10, 最大泡泡: 45" -ForegroundColor Gray
        Write-Host "     - 支持键盘和触摸" -ForegroundColor Gray
        Write-Host ""

        Write-Host "【配置文件】" -ForegroundColor Yellow
        Write-Host "  - build-profile.multi.json5 (多端构建配置)" -ForegroundColor Cyan
        Write-Host "  - platforms/tablet/module.json5 (平板模块配置)" -ForegroundColor Cyan
        Write-Host "  - entry/src/main/ets/utils/PlatformAdapter.ets (平台适配器)" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "【文档】" -ForegroundColor Yellow
        Write-Host "  - MULTI_DEVICE_DEPLOYMENT.md (多端部署指南)" -ForegroundColor Cyan
        Write-Host "  - LEVEL_DESIGN.md (关卡设计文档)" -ForegroundColor Cyan
        Write-Host ""
    }

    "5" {
        Write-Host ""
        Write-Host "👋 退出部署脚本" -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }

    default {
        Write-Host ""
        Write-Host "❌ 无效的选择" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "【后续步骤】" -ForegroundColor Yellow
Write-Host "  1. 连接华为MatePad Pro 11到电脑" -ForegroundColor Cyan
Write-Host "  2. 在设备上启用USB调试" -ForegroundColor Cyan
Write-Host "  3. 使用DevEco Studio或命令行安装应用" -ForegroundColor Cyan
Write-Host "  4. 在平板上测试游戏功能" -ForegroundColor Cyan
Write-Host ""

Write-Host "【测试清单】" -ForegroundColor Yellow
Write-Host "  □ 竖屏模式游戏正常运行" -ForegroundColor Cyan
Write-Host "  □ 横屏模式游戏正常运行" -ForegroundColor Cyan
Write-Host "  □ 屏幕旋转时界面自适应" -ForegroundColor Cyan
Write-Host "  □ 分屏模式下游戏正常" -ForegroundColor Cyan
Write-Host "  □ 悬浮窗模式下游戏正常" -ForegroundColor Cyan
Write-Host "  □ 50个关卡均可正常游玩" -ForegroundColor Cyan
Write-Host "  □ 道具和装备系统正常" -ForegroundColor Cyan
Write-Host "  □ 游戏数据正常保存和加载" -ForegroundColor Cyan
Write-Host ""

Write-Host "🎯 部署完成！祝您在华为MatePad Pro 11上享受游戏！" -ForegroundColor Green
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
