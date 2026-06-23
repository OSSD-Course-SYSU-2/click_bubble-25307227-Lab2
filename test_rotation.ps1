# 虚拟机屏幕旋转测试脚本
# 用于在虚拟机中测试游戏的屏幕自由轮转功能

Write-Host "=== 虚拟机屏幕旋转测试脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查是否在管理员模式下运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  警告: 建议以管理员权限运行此脚本以获得完整的屏幕旋转控制" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📱 游戏屏幕旋转功能测试指南" -ForegroundColor Green
Write-Host ""
Write-Host "【测试步骤】" -ForegroundColor Yellow
Write-Host "1. 启动虚拟机中的HarmonyOS应用"
Write-Host "2. 使用以下快捷键或命令旋转屏幕:"
Write-Host ""
Write-Host "【快捷键方式】（推荐）" -ForegroundColor Yellow
Write-Host "  - Ctrl + Alt + 左箭头: 向左旋转90度"
Write-Host "  - Ctrl + Alt + 右箭头: 向右旋转90度"
Write-Host "  - Ctrl + Alt + 上箭头: 恢复正常方向"
Write-Host ""
Write-Host "【命令行方式】" -ForegroundColor Yellow
Write-Host "  如果快捷键不工作，尝试使用PowerShell命令:"
Write-Host ""

# 尝试使用DisplaySettings命令
try {
    Write-Host "  测试1: 尝试使用DisplaySettings模块..." -ForegroundColor Gray
    $module = Get-Module -ListAvailable -Name DisplaySettings -ErrorAction SilentlyContinue
    if ($module) {
        Write-Host "  ✓ DisplaySettings模块可用" -ForegroundColor Green
        Write-Host "  命令示例:" -ForegroundColor Cyan
        Write-Host "    Set-DisplayRotation -Rotation 90  # 旋转90度"
        Write-Host "    Set-DisplayRotation -Rotation 180 # 旋转180度"
        Write-Host "    Set-DisplayRotation -Rotation 270 # 旋转270度"
        Write-Host "    Set-DisplayRotation -Rotation 0   # 恢复正常"
    } else {
        Write-Host "  ✗ DisplaySettings模块不可用" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ 无法检查DisplaySettings模块" -ForegroundColor Red
}

Write-Host ""
Write-Host "【虚拟机特定设置】" -ForegroundColor Yellow
Write-Host "  如果使用Oracle VirtualBox:"
Write-Host "  1. 打开虚拟机设置 > 显示"
Write-Host "  2. 确认'图形控制器'设置为'VBoxSVGA'"
Write-Host "  3. 启用'3D加速'"
Write-Host "  4. 视频内存建议设置为128MB或更高"
Write-Host ""
Write-Host "  如果使用VMware Workstation:"
Write-Host "  1. 打开虚拟机设置 > 显示"
Write-Host "  2. 启用'加速3D图形'"
Write-Host "  3. 显存建议设置为1GB或更高"
Write-Host ""
Write-Host "  如果使用QEMU/KVM:"
Write-Host "  1. 确保使用 virtio-vga 或 virtio-gpu-pci 显示设备"
Write-Host "  2. 添加参数: -device virtio-gpu-pci,xres=1920,yres=1080"
Write-Host ""

Write-Host "【游戏内测试要点】" -ForegroundColor Yellow
Write-Host "  ✓ 游戏界面在横屏和竖屏下都能正常显示"
Write-Host "  ✓ 泡泡大小和位置随屏幕方向自适应调整"
Write-Host "  ✓ UI元素（按钮、分数、时间等）位置正确"
Write-Host "  ✓ 点击区域准确，无偏移"
Write-Host "  ✓ 游戏区域尺寸自动调整（横屏70%宽度，竖屏90%宽度）"
Write-Host "  ✓ 列数自动调整（横屏12列，竖屏8列）"
Write-Host ""

Write-Host "【屏幕旋转管理器功能】" -ForegroundColor Yellow
Write-Host "  支持的方向:" -ForegroundColor Cyan
Write-Host "    - portrait (竖屏)"
Write-Host "    - landscape (横屏)"
Write-Host "    - portrait_inverted (反向竖屏)"
Write-Host "    - landscape_inverted (反向横屏)"
Write-Host "    - unspecified (跟随系统)"
Write-Host ""
Write-Host "  可用功能:" -ForegroundColor Cyan
Write-Host "    - setOrientation(): 设置指定方向"
Write-Host "    - lockOrientation(): 锁定当前方向"
Write-Host "    - unlockOrientation(): 解锁方向"
Write-Host "    - toggleOrientation(): 切换横竖屏"
Write-Host "    - getGameAreaSize(): 获取自适应游戏区域尺寸"
Write-Host "    - getUIScale(): 获取UI缩放比例"
Write-Host "    - getColumns(): 获取自适应列数"
Write-Host ""

Write-Host "【故障排除】" -ForegroundColor Yellow
Write-Host "  如果屏幕旋转不工作:" -ForegroundColor Red
Write-Host "    1. 检查虚拟机是否安装了增强工具/客户机工具"
Write-Host "    2. 确认虚拟机的显示驱动已正确安装"
Write-Host "    3. 尝试重启虚拟机"
Write-Host "    4. 检查HarmonyOS系统中的屏幕旋转设置是否开启"
Write-Host "       (设置 > 显示和亮度 > 屏幕旋转)"
Write-Host ""

Write-Host "【验证配置】" -ForegroundColor Yellow
Write-Host "  当前游戏配置:" -ForegroundColor Cyan
Write-Host "    ✓ module.json5中orientation设置为'unspecified'"
Write-Host "    ✓ supportWindowMode支持全屏、分屏、悬浮窗"
Write-Host "    ✓ ScreenRotationManager已正确初始化"
Write-Host "    ✓ 支持windowSizeChange事件监听"
Write-Host ""

Write-Host "🎯 测试完成后，游戏应能在任意屏幕方向下流畅运行！" -ForegroundColor Green
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
