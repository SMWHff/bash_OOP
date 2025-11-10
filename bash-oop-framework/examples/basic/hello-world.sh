#!/bin/bash

# Bash OOP Framework Hello World 示例

# 加载框架
source "../../src/framework.sh"

# 初始化框架
framework_init

# 创建 Person 类
Object.create "Person" "person1"

# 定义构造函数
Object.method "Person" "constructor" '
    local name="$1" age="$2"
    echo "Creating person: $name, $age years old"
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "age" "$age"
'

# 定义问候方法
Object.method "Person" "greet" '
    local name=$(Object.attr "$this" "name")
    local age=$(Object.attr "$this" "age")
    echo "Hello, I am $name, $age years old!"
'

# 使用 Person 类
Person.constructor "person1" "张三" 25
Person.greet "person1"

echo "🎉 Hello World 示例完成！"
