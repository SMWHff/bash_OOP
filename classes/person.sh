#!/bin/bash

# Person 类定义

Object.method "Person" "constructor" '
    local name="$1" age="$2"
    echo "构造函数: name=\"$name\", age=\"$age\""
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "age" "$age"
    Object.private "$this" "secret" "$(date +%s | md5sum | head -c 8 2>/dev/null || echo "secret")"
'

Object.method "Person" "getInfo" '
    local name=$(Object.attr "$this" "name")
    local age=$(Object.attr "$this" "age")
    echo "人员信息: 姓名=$name, 年龄=$age"
'

Object.method "Person" "setName" '
    local new_name="$1"
    Object.attr "$this" "name" "$new_name"
    echo "姓名已更新为: $new_name"
'

Object.method "Person" "setAge" '
    local new_age="$1"
    if [[ "$new_age" =~ ^[0-9]+$ ]] && [ "$new_age" -ge 0 ]; then
        Object.attr "$this" "age" "$new_age"
        echo "年龄已更新为: $new_age"
    else
        echo "错误: 年龄必须是正整数"
    fi
'

Object.method "Person" "birthday" '
    local current_age=$(Object.attr "$this" "age")
    local new_age=$((current_age + 1))
    Object.attr "$this" "age" "$new_age"
    echo "$(Object.attr "$this" "name") 过生日了！现在 $new_age 岁"
    Object.emit "$this" "birthday" "$new_age"
'