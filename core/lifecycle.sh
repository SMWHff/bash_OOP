#!/bin/bash

# 对象生命周期管理

Object.method "Object" "destroy" '
    echo "销毁对象: $this"
    
    # 标记对象为已销毁
    OBJECT_PROPS["${this}__destroyed"]="true"
    
    # 删除对象的所有属性
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            unset OBJECT_PROPS["$key"]
        fi
    done
    
    # 删除对象的私有属性
    for key in "${!OBJECT_PRIVATE[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            unset OBJECT_PRIVATE["$key"]
        fi
    done
    
    # 删除对象的关系
    for key in "${!OBJECT_RELATIONS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            unset OBJECT_RELATIONS["$key"]
        fi
    done
    
    # 删除对象的事件
    for key in "${!OBJECT_EVENTS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            unset OBJECT_EVENTS["$key"]
        fi
    done
    
    # 删除对象的验证器
    for key in "${!OBJECT_VALIDATORS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            unset OBJECT_VALIDATORS["$key"]
        fi
    done
    
    echo "对象 $this 已完全销毁"
'

# 系统级清理方法
Object.static "Object" "cleanup" '
    echo "=== 系统清理 ==="
    local object_count=0
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == *"__class" ]]; then
            local instance="${key%__class}"
            echo "清理对象: $instance"
            Object.destroy "$instance"
            ((object_count++))
        fi
    done
    
    # 清理缓存
    OBJECT_CACHE=()
    echo "缓存已清空"
    echo "系统清理完成: 共清理 $object_count 个对象"
'

Object.static "Object" "systemInfo" '
    echo "=== 企业级系统信息 ==="
    local object_count=0
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == *"__class" ]]; then
            ((object_count++))
        fi
    done
    echo "对象总数: $object_count"
    echo "属性总数: ${#OBJECT_PROPS[@]}"
    echo "私有属性数: ${#OBJECT_PRIVATE[@]}"
    echo "关系数量: ${#OBJECT_RELATIONS[@]}"
    echo "事件数量: ${#OBJECT_EVENTS[@]}"
    echo "验证器数量: ${#OBJECT_VALIDATORS[@]}"
    echo "缓存条目: ${#OBJECT_CACHE[@]}"
    echo "定义的类: Object Person Employee Manager"
    echo "总方法数: $(declare -F | wc -l)"
'