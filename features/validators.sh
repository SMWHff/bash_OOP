#!/bin/bash

# 验证器系统

Object.method "Object" "addValidator" '
    local attr="$1" validator="$2"
    local key="${this}__validators__${attr}"
    OBJECT_VALIDATORS["$key"]="$validator"
    echo "添加验证器: $this.$attr -> $validator"
'

Object.method "Object" "validate" '
    local attr="$1" value="$2"
    local key="${this}__validators__${attr}"
    local validator="${OBJECT_VALIDATORS[$key]}"
    
    if [ -n "$validator" ]; then
        if $validator "$value"; then
            echo "验证通过: $attr = $value"
            return 0
        else
            echo "验证失败: $attr = $value"
            return 1
        fi
    else
        return 0
    fi
'

Object.method "Object" "setAttrWithValidation" '
    local attr="$1" value="$2"
    if Object.validate "$this" "$attr" "$value"; then
        Object.attr "$this" "$attr" "$value"
        Object.emit "$this" "attrChanged" "$attr" "$value"
        return 0
    else
        return 1
    fi
'

# 常用验证器函数
validate_age() {
    local age="$1"
    if [[ "$age" =~ ^[0-9]+$ ]] && [ "$age" -ge 18 ] && [ "$age" -le 65 ]; then
        return 0
    else
        echo "年龄必须在18-65之间"
        return 1
    fi
}

validate_salary() {
    local salary="$1"
    if [[ "$salary" =~ ^[0-9]+$ ]] && [ "$salary" -ge 0 ]; then
        return 0
    else
        echo "工资必须是非负整数"
        return 1
    fi
}

validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        echo "邮箱格式无效"
        return 1
    fi
}