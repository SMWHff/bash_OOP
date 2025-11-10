#!/bin/bash

# 辅助函数库

Object.static "Object" "generateId" '
    local prefix="$1"
    echo "${prefix}_$(date +%s)_${RANDOM}"
'

Object.static "Object" "timestamp" '
    date "+%Y-%m-%d %H:%M:%S"
'

Object.static "Object" "log" '
    local level="$1" message="$2"
    local timestamp=$(Object::timestamp)
    echo "[$timestamp] [$level] $message"
'

Object.static "Object" "isDestroyed" '
    local instance="$1"
    if [ -n "${OBJECT_PROPS[${instance}__destroyed]}" ]; then
        return 0
    else
        return 1
    fi
'

# 检查对象是否存在
Object.static "Object" "exists" '
    local instance="$1"
    if [ -n "${OBJECT_PROPS[${instance}__class]}" ]; then
        return 0
    else
        return 1
    fi
'

# 获取对象类名
Object.static "Object" "getClass" '
    local instance="$1"
    echo "${OBJECT_PROPS[${instance}__class]}"
'

# 序列化对象为字符串
Object.method "Object" "serialize" '
    local result=""
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            local prop_name="${key#${this}__}"
            local value="${OBJECT_PROPS[$key]}"
            result="${result}${prop_name}=${value}&"
        fi
    done
    echo "${result%&}"  # 移除最后一个&
'

# 从字符串反序列化对象
Object.method "Object" "deserialize" '
    local data="$1"
    IFS='\&' read -ra pairs <<< "$data"
    for pair in "${pairs[@]}"; do
        IFS='=' read -r key value <<< "$pair"
        Object.attr "$this" "$key" "$value"
    done
'

# 对象比较
Object.static "Object" "equals" '
    local obj1="$1" obj2="$2"
    
    # 检查是否是同一个对象
    if [ "$obj1" = "$obj2" ]; then
        return 0
    fi
    
    # 比较类名
    local class1=$(Object::getClass "$obj1")
    local class2=$(Object::getClass "$obj2")
    
    if [ "$class1" != "$class2" ]; then
        return 1
    fi
    
    # 比较属性数量（简化实现）
    local count1=0 count2=0
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == ${obj1}__* ]]; then
            ((count1++))
        fi
        if [[ "$key" == ${obj2}__* ]]; then
            ((count2++))
        fi
    done
    
    if [ "$count1" -ne "$count2" ]; then
        return 1
    fi
    
    return 0
'