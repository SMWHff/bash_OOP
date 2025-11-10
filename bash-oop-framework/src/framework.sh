#!/bin/bash

# Bash OOP Framework 主入口文件
# 版本: 1.0.0

set -e

# 框架配置
FRAMEWORK_NAME="Bash OOP Framework"
FRAMEWORK_VERSION="1.0.0"
FRAMEWORK_AUTHOR="Bash OOP Framework Team"

# 框架根目录
if [ -z "$BASH_OOP_ROOT" ]; then
    export BASH_OOP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_debug() {
    if [ "${BASH_OOP_DEBUG:-false}" = "true" ]; then
        echo -e "${BLUE}🔍 [DEBUG]${NC} $1" >&2
    fi
}

log_info() {
    echo -e "${BLUE}ℹ [INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠ [WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1" >&2
}

# 检查依赖
check_dependency() {
    local cmd=$1
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Missing dependency: $cmd"
        return 1
    fi
    log_debug "Dependency check passed: $cmd"
    return 0
}

# 验证类名
validate_class_name() {
    local class_name=$1
    if [[ ! "$class_name" =~ ^[A-Z][a-zA-Z0-9_]*$ ]]; then
        log_error "Invalid class name: $class_name (must start with uppercase letter)"
        return 1
    fi
    return 0
}

# 验证实例名
validate_instance_name() {
    local instance_name=$1
    if [[ ! "$instance_name" =~ ^[a-z][a-zA-Z0-9_]*$ ]]; then
        log_error "Invalid instance name: $instance_name (must start with lowercase letter)"
        return 1
    fi
    return 0
}

# 全局存储
declare -gA OBJECT_PROPS
declare -gA OBJECT_PRIVATE
declare -gA CLASS_METHODS

# Object 基类
Object() {
    : # 基类定义
}

# 创建实例
Object.create() {
    local class="$1" instance="$2"
    
    if ! validate_class_name "$class"; then
        return 1
    fi
    
    if ! validate_instance_name "$instance"; then
        return 1
    fi
    
    log_debug "Creating instance: $instance (class: $class)"
    
    # 设置实例属性
    OBJECT_PROPS["${instance}__class"]="$class"
    OBJECT_PROPS["${instance}__created"]="$(date '+%Y-%m-%d %H:%M:%S')"
    OBJECT_PROPS["${instance}__id"]="obj_$(date +%s)_$RANDOM"
    
    log_success "Created instance: $instance (class: $class)"
}

# 属性管理
Object.attr() {
    local instance="$1" attr="$2"
    
    if [ $# -eq 3 ]; then
        # 设置属性
        OBJECT_PROPS["${instance}__${attr}"]="$3"
        log_debug "Set attribute: $instance.$attr = $3"
    else
        # 获取属性
        echo "${OBJECT_PROPS[${instance}__${attr}]}"
    fi
}

# 方法定义
Object.method() {
    local class="$1" method="$2"
    shift 2
    local body="$*"
    
    if ! validate_class_name "$class"; then
        return 1
    fi
    
    log_debug "Defining method: $class.$method"
    
    eval "
        ${class}.${method}() {
            local this=\"\$1\"
            shift
            $body
        }
    "
    
    log_success "Defined method: $class.$method"
}

# 框架初始化
framework_init() {
    log_info "Initializing $FRAMEWORK_NAME v$FRAMEWORK_VERSION"
    
    # 检查基本依赖
    local deps=("bash" "date")
    for dep in "${deps[@]}"; do
        check_dependency "$dep" || return 1
    done
    
    log_success "Framework initialized successfully"
}

# 框架信息
framework_info() {
    echo "$FRAMEWORK_NAME v$FRAMEWORK_VERSION"
    echo "Root: $BASH_OOP_ROOT"
    echo "Author: $FRAMEWORK_AUTHOR"
}

# 如果直接执行此脚本，显示框架信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    framework_info
fi
