#!/bin/bash

# Bash OOP Framework 安装脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 默认安装目录
DEFAULT_INSTALL_DIR="/usr/local/lib/bash-oop-framework"

# 打印彩色消息
log_info() {
    echo -e "${YELLOW}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

log_error() {
    echo -e "${RED}✗ ${NC}$1"
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    local deps=("bash")
    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            log_success "找到: $dep"
        else
            log_error "缺少依赖: $dep"
            return 1
        fi
    done
    
    return 0
}

# 安装框架
install_framework() {
    local install_dir="$1"
    
    log_info "安装框架到: $install_dir"
    
    # 创建安装目录
    mkdir -p "$install_dir"
    
    # 复制文件
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    log_info "复制框架文件..."
    cp -r "$script_dir/src" "$script_dir/examples" "$script_dir/docs" "$install_dir/"
    
    # 设置权限
    find "$install_dir" -name "*.sh" -exec chmod +x {} \;
    
    log_success "框架安装完成"
}

# 显示使用说明
show_usage() {
    cat << USAGE_EOF
用法: $0 [选项]

选项:
    -d, --dir DIR       安装目录 (默认: $DEFAULT_INSTALL_DIR)
    -h, --help          显示此帮助信息

示例:
    $0                    # 使用默认目录安装
    $0 -d ~/my-app/lib    # 安装到指定目录
USAGE_EOF
}

# 主函数
main() {
    local install_dir="$DEFAULT_INSTALL_DIR"
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir)
                install_dir="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_info "开始安装 Bash OOP Framework"
    
    # 检查依赖
    if ! check_dependencies; then
        log_error "依赖检查失败"
        exit 1
    fi
    
    # 安装框架
    install_framework "$install_dir"
    
    # 显示完成信息
    cat << COMPLETE_EOF

🎉 安装完成！

框架已安装到: $install_dir

使用方法:
  在脚本中包含框架:
      source "$install_dir/src/framework.sh"

示例:
  查看 $install_dir/examples/ 目录获取使用示例

文档:
  查看 $install_dir/docs/ 目录获取详细文档
COMPLETE_EOF
    
    log_success "安装完成！"
}

# 运行主函数
main "$@"
