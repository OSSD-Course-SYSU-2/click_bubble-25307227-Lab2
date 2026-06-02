#!/bin/bash

# 多端构建脚本 - Bash版本
# 支持构建Phone、Tablet、TV、Wearable、2in1等多个平台

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# 默认参数
PLATFORM="all"
BUILD_MODE="debug"
CLEAN=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -m|--mode)
            BUILD_MODE="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            echo "使用方法: $0 [选项]"
            echo "选项:"
            echo "  -p, --platform <platform>  目标平台 (phone|tablet|tv|wearable|2in1|all)"
            echo "  -m, --mode <mode>          构建模式 (debug|release)"
            echo "  -c, --clean                构建前清理"
            echo "  -h, --help                 显示帮助信息"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac
done

# 打印横幅
print_banner() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  多端构建脚本 - 解压泡泡龙游戏${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# 构建指定平台
build_platform() {
    local target_platform=$1
    local mode=$2

    echo -e "${YELLOW}[$target_platform] 开始构建...${NC}"

    # 复制对应平台的module.json5
    local platform_config="platforms/$target_platform/module.json5"
    local target_config="entry/src/main/module.json5"

    if [ -f "$platform_config" ]; then
        cp "$platform_config" "$target_config"
        echo -e "${GREEN}[$target_platform] 已应用平台配置${NC}"
    else
        echo -e "${RED}[$target_platform] 警告: 未找到平台配置文件，使用默认配置${NC}"
    fi

    # 执行构建命令
    local build_cmd="hvigorw assembleHap --mode module -p product=$target_platform"
    if [ "$mode" = "release" ]; then
        build_cmd="$build_cmd -p buildMode=release"
    fi

    echo -e "${GRAY}[$target_platform] 执行: $build_cmd${NC}"

    # 执行构建
    eval $build_cmd

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[$target_platform] 构建成功!${NC}"

        # 创建输出目录
        local output_dir="build/outputs/$target_platform"
        mkdir -p "$output_dir"

        # 复制构建产物
        local hap_file=$(find entry/build/default/outputs/default -name "*.hap" -type f | head -n 1)
        if [ -n "$hap_file" ]; then
            cp "$hap_file" "$output_dir/"
            echo -e "${GREEN}[$target_platform] HAP文件已复制到: $output_dir${NC}"
        fi
        return 0
    else
        echo -e "${RED}[$target_platform] 构建失败!${NC}"
        return 1
    fi
}

# 清理构建产物
clean_build() {
    echo -e "${YELLOW}清理构建产物...${NC}"

    local dirs=("entry/build" "build/outputs")
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            echo -e "${GRAY}已删除: $dir${NC}"
        fi
    done

    echo -e "${GREEN}清理完成!${NC}"
}

# 主函数
main() {
    print_banner

    # 切换到脚本所在目录
    cd "$(dirname "$0")/.."

    echo -e "${GRAY}项目目录: $(pwd)${NC}"
    echo -e "${GRAY}目标平台: $PLATFORM${NC}"
    echo -e "${GRAY}构建模式: $BUILD_MODE${NC}"
    echo ""

    # 清理
    if [ "$CLEAN" = true ]; then
        clean_build
        echo ""
    fi

    # 创建输出目录
    mkdir -p "build/outputs"

    # 构建平台列表
    local platforms=()
    if [ "$PLATFORM" = "all" ]; then
        platforms=("phone" "tablet" "tv" "wearable" "2in1")
    else
        platforms=("$PLATFORM")
    fi

    # 执行构建
    local success=true
    declare -A results

    for p in "${platforms[@]}"; do
        echo ""
        if build_platform "$p" "$BUILD_MODE"; then
            results[$p]=true
        else
            results[$p]=false
            success=false
        fi
    done

    # 打印构建摘要
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  构建摘要${NC}"
    echo -e "${CYAN}========================================${NC}"

    for key in "${!results[@]}"; do
        if [ "${results[$key]}" = true ]; then
            echo -e "  $key : ${GREEN}成功${NC}"
        else
            echo -e "  $key : ${RED}失败${NC}"
        fi
    done

    echo -e "${CYAN}========================================${NC}"

    if [ "$success" = true ]; then
        echo -e "\n${GREEN}所有平台构建完成!${NC}"
        exit 0
    else
        echo -e "\n${RED}部分平台构建失败，请检查错误信息。${NC}"
        exit 1
    fi
}

# 执行主函数
main
