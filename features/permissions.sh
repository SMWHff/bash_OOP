#!/bin/bash

# 权限系统

Object.method "Object" "addPermission" '
    local role="$1" permission="$2"
    local key="${this}__permissions__${role}"
    OBJECT_PROPS["$key"]="${OBJECT_PROPS[$key]} $permission"
    echo "添加权限: $role -> $permission"
'

Object.method "Object" "checkPermission" '
    local role="$1" permission="$2"
    local key="${this}__permissions__${role}"
    local permissions="${OBJECT_PROPS[$key]}"
    
    if [[ " $permissions " == *" $permission "* ]]; then
        echo "权限检查通过: $role 有 $permission 权限"
        return 0
    else
        echo "权限检查失败: $role 没有 $permission 权限"
        return 1
    fi
'

Object.method "Object" "removePermission" '
    local role="$1" permission="$2"
    local key="${this}__permissions__${role}"
    local new_permissions=""
    for p in ${OBJECT_PROPS[$key]}; do
        if [ "$p" != "$permission" ]; then
            new_permissions="$new_permissions $p"
        fi
    done
    OBJECT_PROPS["$key"]="$new_permissions"
    echo "移除权限: $role -> $permission"
'