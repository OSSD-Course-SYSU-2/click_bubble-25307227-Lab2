# SDK版本自动修复脚本
# 用于解决 "compatibleSdkVersion and releaseType of the app do not match the apiVersion and releaseType on the device" 错误

Write-Host "=== SDK版本自动修复工具 ===" -ForegroundColor Cyan
Write-Host ""

# 检查是否在项目根目录
if (-not (Test-Path "build-profile.json5") -or -not (Test-Path "build-profile.multi.json5")) {
    Write-Host "❌ 错误: 请在项目根目录下运行此脚本" -ForegroundColor Red
    Write-Host "   未找到 build-profile.json5 或 build-profile.multi.json5 文件" -ForegroundColor Red
    exit 1
}

Write-Host "【当前配置】" -ForegroundColor Yellow
$currentProfile = Get-Content "build-profile.json5" | ConvertFrom-Json
Write-Host "  targetSdkVersion: $($currentProfile.app.products[0].targetSdkVersion)" -ForegroundColor Cyan
Write-Host "  compatibleSdkVersion: $($currentProfile.app.products[0].compatibleSdkVersion)" -ForegroundColor Cyan
Write-Host ""

Write-Host "【HarmonyOS版本对照表】" -ForegroundColor Yellow
Write-Host "  1. HarmonyOS 4.0 (API 10)  → 5.0.0(12)" -ForegroundColor Cyan
Write-Host "  2. HarmonyOS 5.0 (API 11)  → 5.0.1(13)" -ForegroundColor Cyan
Write-Host "  3. HarmonyOS 5.0.1 (API 12) → 6.0.2(22)" -ForegroundColor Cyan
Write-Host ""

Write-Host "【如何确定设备版本】" -ForegroundColor Yellow
Write-Host "  使用以下命令查询设备API版本:" -ForegroundColor Cyan
Write-Host "  hdc shell getprop hw_sc.build.platform.version" -ForegroundColor Gray
Write-Host ""

Write-Host "请选择您的设备系统版本:" -ForegroundColor Yellow
Write-Host "  1. HarmonyOS 4.0 (API 10)" -ForegroundColor White
Write-Host "  2. HarmonyOS 5.0 (API 11)" -ForegroundColor White
Write-Host "  3. HarmonyOS 5.0.1 (API 12)" -ForegroundColor White
Write-Host "  4. 向后兼容模式 (API 10-12)" -ForegroundColor White
Write-Host "  5. 退出" -ForegroundColor White
Write-Host ""

$choice = Read-Host "请选择 (1-5)"

$sdkVersion = switch ($choice) {
    "1" { "5.0.0(12)" }
    "2" { "5.0.1(13)" }
    "3" { "6.0.2(22)" }
    "4" {
        Write-Host ""
        Write-Host "向后兼容模式:" -ForegroundColor Yellow
        Write-Host "  targetSdkVersion: 6.0.2(22)" -ForegroundColor Cyan
        Write-Host "  compatibleSdkVersion: 5.0.0(12)" -ForegroundColor Cyan
        Write-Host "  此配置允许应用在API 10及以上版本运行" -ForegroundColor Gray
        Write-Host ""
        $confirm = Read-Host "确认使用向后兼容模式? (y/n)"
        if ($confirm -eq 'y' -or $confirm -eq 'Y') {
            @{ target = "6.0.2(22)"; compatible = "5.0.0(12)" }
        } else {
            exit 0
        }
    }
    "5" {
        Write-Host ""
        Write-Host "👋 退出修复工具" -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host ""
        Write-Host "❌ 无效的选择" -ForegroundColor Red
        exit 1
    }
}

if ($choice -eq "4") {
    $targetSdk = $sdkVersion.target
    $compatibleSdk = $sdkVersion.compatible
} else {
    $targetSdk = $sdkVersion
    $compatibleSdk = $sdkVersion
}

Write-Host ""
Write-Host "【即将应用的配置】" -ForegroundColor Yellow
Write-Host "  targetSdkVersion: $targetSdk" -ForegroundColor Green
Write-Host "  compatibleSdkVersion: $compatibleSdk" -ForegroundColor Green
Write-Host ""

$confirm = Read-Host "确认修改? (y/n)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host ""
    Write-Host "❌ 已取消修改" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🔧 正在修改配置文件..." -ForegroundColor Yellow

# 备份文件
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupSuffix = ".backup_$timestamp"

Copy-Item "build-profile.json5" "build-profile.json5$backupSuffix" -Force
Copy-Item "build-profile.multi.json5" "build-profile.multi.json5$backupSuffix" -Force

Write-Host "✓ 已备份原文件 (后缀: $backupSuffix)" -ForegroundColor Green

# 修改 build-profile.json5
$content = Get-Content "build-profile.json5" -Raw
$content = $content -replace '"targetSdkVersion":\s*"[^"]+"', "`"targetSdkVersion`": `"$targetSdk`""
$content = $content -replace '"compatibleSdkVersion":\s*"[^"]+"', "`"compatibleSdkVersion`": `"$compatibleSdk`""
Set-Content "build-profile.json5" $content -NoNewline -Encoding UTF8

Write-Host "✓ 已修改 build-profile.json5" -ForegroundColor Green

# 修改 build-profile.multi.json5
$content = Get-Content "build-profile.multi.json5" -Raw
$content = $content -replace '"targetSdkVersion":\s*"[^"]+"', "`"targetSdkVersion`": `"$targetSdk`""
$content = $content -replace '"compatibleSdkVersion":\s*"[^"]+"', "`"compatibleSdkVersion`": `"$compatibleSdk`""
Set-Content "build-profile.multi.json5" $content -NoNewline -Encoding UTF8

Write-Host "✓ 已修改 build-profile.multi.json5" -ForegroundColor Green

Write-Host ""
Write-Host "✅ SDK版本修改完成!" -ForegroundColor Green
Write-Host ""

Write-Host "【修改摘要】" -ForegroundColor Yellow
Write-Host "  修改的文件:" -ForegroundColor Cyan
Write-Host "    - build-profile.json5" -ForegroundColor White
Write-Host "    - build-profile.multi.json5" -ForegroundColor White
Write-Host ""
Write-Host "  新的配置:" -ForegroundColor Cyan
Write-Host "    - targetSdkVersion: $targetSdk" -ForegroundColor White
Write-Host "    - compatibleSdkVersion: $compatibleSdk" -ForegroundColor White
Write-Host ""
Write-Host "  备份文件:" -ForegroundColor Cyan
Write-Host "    - build-profile.json5$backupSuffix" -ForegroundColor White
Write-Host "    - build-profile.multi.json5$backupSuffix" -ForegroundColor White
Write-Host ""

Write-Host "【下一步操作】" -ForegroundColor Yellow
Write-Host "  1. 清理构建缓存:" -ForegroundColor Cyan
Write-Host "     hvigorw clean" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. 重新构建应用:" -ForegroundColor Cyan
Write-Host "     hvigorw assembleHap --mode module -p product=tablet -p module=entry@default" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. 安装到设备:" -ForegroundColor Cyan
Write-Host "     hdc install entry/build/default/outputs/default/entry-default-signed.hap" -ForegroundColor Gray
Write-Host "     或使用DevEco Studio直接运行" -ForegroundColor Gray
Write-Host ""

Write-Host "【如果仍有问题】" -ForegroundColor Yellow
Write-Host "  1. 确认设备API版本:" -ForegroundColor Cyan
Write-Host "     hdc shell getprop hw_sc.build.platform.version" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. 恢复备份文件:" -ForegroundColor Cyan
Write-Host "     copy build-profile.json5$backupSuffix build-profile.json5" -ForegroundColor Gray
Write-Host "     copy build-profile.multi.json5$backupSuffix build-profile.multi.json5" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. 查看详细文档: SDK_VERSION_FIX.md" -ForegroundColor Cyan
Write-Host ""

Write-Host "【SDK版本对照表】" -ForegroundColor Yellow
Write-Host "  HarmonyOS版本  | API版本 | targetSdkVersion | compatibleSdkVersion" -ForegroundColor Cyan
Write-Host "  ---------------|---------|------------------|---------------------" -ForegroundColor Cyan
Write-Host "  HarmonyOS 4.0  | API 10  | 5.0.0(12)        | 5.0.0(12)" -ForegroundColor White
Write-Host "  HarmonyOS 5.0  | API 11  | 5.0.1(13)        | 5.0.1(13)" -ForegroundColor White
Write-Host "  HarmonyOS 5.0.1| API 12  | 6.0.2(22)        | 6.0.2(22)" -ForegroundColor White
Write-Host ""

Write-Host "🎯 修复完成！请按照上述步骤重新构建和安装应用。" -ForegroundColor Green
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
