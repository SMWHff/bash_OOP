#!/bin/bash

# 核心基类定义

Object() {
    : # 基类
}

# 创建实例
Object.create() {
    local class=$1 instance=$2
    echo "创建实例: $instance (类: $class)"
    OBJECT_PROPS["${instance}__class"]="$class"
    OBJECT_PROPS["${instance}__created"]="$(date '+%Y-%m-%d %H:%M:%S')"
    OBJECT_PROPS["${instance}__id"]="obj_$(date +%s)_$RANDOM"
}

# 属性访问器
Object.attr() {
    local instance=$1 attr=$2
    local key="${instance}__${attr}"
    
    # 检查对象是否已销毁
    if [ -n "${OBJECT_PROPS[${instance}__destroyed]}" ]; then
        echo "错误: 对象 $instance 已被销毁" >&2
        return 1
    fi
    
    if [ $# -eq 3 ]; then
        OBJECT_PROPS["$key"]="$3"
    else
        echo "${OBJECT_PROPS[$key]}"
    fi
}

# 私有属性
Object.private() {
    local instance=$1 attr=$2
    local key="${instance}__private__${attr}"
    
    if [ $# -eq 3 ]; then
        OBJECT_PRIVATE["$key"]="$3"
    else
        echo "${OBJECT_PRIVATE[$key]}"
    fi
}

# 方法定义
Object.method() {
    local class=$1 method=$2
    shift 2
    local body="$*"
    
    eval "
        ${class}.${method}() {
            local this=\"\$1\"
            shift
            $body
        }
    "
}

# 类方法（静态方法）
Object.static() {
    local class=$1 method=$2
    shift 2
    local body="$*"
    
    eval "
        ${class}::${method}() {
            $body
        }
    "
}

# 获取对象信息
Object.method "Object" "getInfo" '
    local class=$(Object.attr "$this" "class")
    local created=$(Object.attr "$this" "created")
    local id=$(Object.attr "$this" "id")
    echo "对象信息: 类=$class, ID=$id, 创建时间=$created"
'

# 检查对象是否存在
Object.static "Object" "exists" '
    local instance="$1"
    if [ -n "${OBJECT_PROPS[${instance}__class]}" ] && [ -z "${OBJECT_PROPS[${instance}__destroyed]}" ]; then
        return 0
    else
        return 1
    fi
'