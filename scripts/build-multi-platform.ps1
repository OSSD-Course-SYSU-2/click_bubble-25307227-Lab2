# 多端构建脚本 - PowerShell版本
# 支持构建Phone、Tablet、TV、Wearable、2in1等多个平台

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("phone", "tablet", "tv", "wearable", "2in1", "all")]
    [string]$Platform = "all",

    [Parameter(Mandatory=$false)]
    [ValidateSet("debug", "release")]
    [string]$BuildMode = "debug",

    [Parameter(Mandatory=$false)]
    [switch]$Clean
)

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 打印横幅
function Print-Banner {
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "  多端构建脚本 - 解压泡泡龙游戏" "Cyan"
    Write-ColorOutput "========================================" "Cyan"
    Write-Host ""
}

# 构建指定平台
function Build-Platform {
    param(
        [string]$TargetPlatform,
        [string]$Mode
    )

    Write-ColorOutput "[$TargetPlatform] 开始构建..." "Yellow"

    # 复制对应平台的module.json5
    $platformConfig = "platforms\$TargetPlatform\module.json5"
    $targetConfig = "entry\src\main\module.json5"

    if (Test-Path $platformConfig) {
        Copy-Item $platformConfig $targetConfig -Force
        Write-ColorOutput "[$TargetPlatform] 已应用平台配置" "Green"
    } else {
        Write-ColorOutput "[$TargetPlatform] 警告: 未找到平台配置文件，使用默认配置" "Red"
    }

    # 执行构建命令
    $buildCmd = "hvigorw assembleHap --mode module -p product=$TargetPlatform"
    if ($Mode -eq "release") {
        $buildCmd += " -p buildMode=release"
    }

    Write-ColorOutput "[$TargetPlatform] 执行: $buildCmd" "Gray"

    try {
        Invoke-Expression $buildCmd
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "[$TargetPlatform] 构建成功!" "Green"

            # 创建输出目录
            $outputDir = "build\outputs\$TargetPlatform"
            if (-not (Test-Path $outputDir)) {
                New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
            }

            # 复制构建产物
            $hapFile = Get-ChildItem "entry\build\default\outputs\default\*.hap" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($hapFile) {
                Copy-Item $hapFile.FullName $outputDir -Force
                Write-ColorOutput "[$TargetPlatform] HAP文件已复制到: $outputDir" "Green"
            }
        } else {
            Write-ColorOutput "[$TargetPlatform] 构建失败!" "Red"
            return $false
        }
    } catch {
        Write-ColorOutput "[$TargetPlatform] 构建异常: $_" "Red"
        return $false
    }

    return $true
}

# 清理构建产物
function Clean-Build {
    Write-ColorOutput "清理构建产物..." "Yellow"

    $dirsToClean = @("entry\build", "build\outputs")
    foreach ($dir in $dirsToClean) {
        if (Test-Path $dir) {
            Remove-Item $dir -Recurse -Force
            Write-ColorOutput "已删除: $dir" "Gray"
        }
    }

    Write-ColorOutput "清理完成!" "Green"
}

# 主函数
function Main {
    Print-Banner

    # 切换到项目根目录
    $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
    Set-Location $scriptDir

    Write-ColorOutput "项目目录: $(Get-Location)" "Gray"
    Write-ColorOutput "目标平台: $Platform" "Gray"
    Write-ColorOutput "构建模式: $BuildMode" "Gray"
    Write-Host ""

    # 清理
    if ($Clean) {
        Clean-Build
        Write-Host ""
    }

    # 创建输出目录
    if (-not (Test-Path "build\outputs")) {
        New-Item -ItemType Directory -Force -Path "build\outputs" | Out-Null
    }

    # 构建平台列表
    $platforms = @()
    if ($Platform -eq "all") {
        $platforms = @("phone", "tablet", "tv", "wearable", "2in1")
    } else {
        $platforms = @($Platform)
    }

    # 执行构建
    $success = $true
    $results = @{}

    foreach ($p in $platforms) {
        Write-Host ""
        $result = Build-Platform -TargetPlatform $p -Mode $BuildMode
        $results[$p] = $result
        if (-not $result) {
            $success = $false
        }
    }

    # 打印构建摘要
    Write-Host ""
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "  构建摘要" "Cyan"
    Write-ColorOutput "========================================" "Cyan"

    foreach ($key in $results.Keys) {
        $status = if ($results[$key]) { "成功" } else { "失败" }
        $color = if ($results[$key]) { "Green" } else { "Red" }
        Write-ColorOutput "  $key : $status" $color
    }

    Write-ColorOutput "========================================" "Cyan"

    if ($success) {
        Write-ColorOutput "`n所有平台构建完成!" "Green"
        exit 0
    } else {
        Write-ColorOutput "`n部分平台构建失败，请检查错误信息。" "Red"
        exit 1
    }
}

# 执行主函数
Main
