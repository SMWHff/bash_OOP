#!/bin/bash

# Bash 面向对象系统 - 企业级扩展版
# 主入口文件

# 全局变量声明
declare -A OBJECT_PROPS
declare -A OBJECT_PRIVATE
declare -A CLASS_METHODS
declare -A OBJECT_RELATIONS
declare -A OBJECT_EVENTS
declare -A OBJECT_VALIDATORS
declare -A OBJECT_CACHE

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 导入核心模块
source "$SCRIPT_DIR/core/base.sh"
source "$SCRIPT_DIR/core/inheritance.sh"
source "$SCRIPT_DIR/core/lifecycle.sh"

# 导入功能模块
source "$SCRIPT_DIR/features/events.sh"
source "$SCRIPT_DIR/features/validators.sh"
source "$SCRIPT_DIR/features/permissions.sh"
source "$SCRIPT_DIR/features/transactions.sh"
source "$SCRIPT_DIR/features/cache.sh"
source "$SCRIPT_DIR/features/database.sh"

# 导入工具模块
source "$SCRIPT_DIR/utils/config.sh"
source "$SCRIPT_DIR/utils/profiling.sh"
source "$SCRIPT_DIR/utils/helpers.sh"

# 导入预定义类
source "$SCRIPT_DIR/classes/person.sh"
source "$SCRIPT_DIR/classes/employee.sh"
source "$SCRIPT_DIR/classes/manager.sh"

# 系统初始化函数
Object::init() {
    echo "Bash 面向对象系统初始化完成"
    echo "可用类: Object, Person, Employee, Manager"
    echo "功能模块: 事件系统, 验证器, 权限控制, 事务支持, 缓存, 数据库持久化"
}

# 如果直接运行此脚本，则执行初始化
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    Object::init
fi