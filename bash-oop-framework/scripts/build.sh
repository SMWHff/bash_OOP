#!/bin/bash

# Bash OOP Framework 构建脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 构建配置
BUILD_DIR="dist"
VERSION="1.0.0"

# 打印消息
log_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

# 清理构建目录
clean_build_dir() {
    log_info "清理构建目录..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
}

# 创建完整版本
build_full_version() {
    log_info "构建完整版本..."
    
    local output_file="$BUILD_DIR/bash-oop-full.sh"
    
    # 开始构建
    cat > "$output_file" << 'BUILD_FULL_EOF'
#!/bin/bash

# Bash OOP Framework - Full Version
# 完整版本，包含所有功能

BUILD_FULL_EOF
    
    # 添加框架主文件
    cat "../src/framework.sh" >> "$output_file"
    
    chmod +x "$output_file"
    log_success "创建完整版本: $output_file"
}

# 主构建函数
main() {
    log_info "开始构建 Bash OOP Framework v$VERSION"
    
    clean_build_dir
    build_full_version
    
    log_success "构建完成！"
    echo
    echo "构建产物:"
    ls -la "$BUILD_DIR"/
}

# 运行构建
main
