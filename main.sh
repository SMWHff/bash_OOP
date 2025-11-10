#!/bin/bash

# 面向对象系统 - 最终修复版
declare -A OBJECT_PROPS

Object() {
    : # 基类
}

Object.create() {
    local class=$1 instance=$2
    echo "创建实例: $instance (类: $class)"
    OBJECT_PROPS["${instance}__class"]="$class"
}

Object.attr() {
    local instance=$1 attr=$2
    local key="${instance}__${attr}"
    
    if [ $# -eq 3 ]; then
        OBJECT_PROPS["$key"]="$3"
    else
        echo "${OBJECT_PROPS[$key]}"
    fi
}

Object.method() {
    local class=$1 method=$2
    shift 2
    local body="$*"
    
    # 创建方法函数
    eval "
        ${class}.${method}() {
            local this=\"\$1\"
            shift
            $body
        }
    "
}

# 定义 Person 类的方法 - 使用正确的语法
Object.method "Person" "constructor" '
    local name="$1"
    local age="$2"
    echo "构造函数: name=\"$name\", age=\"$age\""
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "age" "$age"
'

Object.method "Person" "greet" '
    local name=$(Object.attr "$this" "name")
    local age=$(Object.attr "$this" "age")
    echo "Hello, I am $name, $age years old!"
'

Object.method "Person" "birthday" '
    local current_age=$(Object.attr "$this" "age")
    local new_age=$((current_age + 1))
    Object.attr "$this" "age" "$new_age"
    echo "Happy birthday! Now I am $new_age years old"
'

Object.method "Person" "introduce" '
    local name=$(Object.attr "$this" "name")
    local age=$(Object.attr "$this" "age")
    local job=$(Object.attr "$this" "job")
    if [ -z "$job" ]; then
        job="未设置"
    fi
    echo "我叫$name，今年$age岁，职业是$job"
'

Object.method "Person" "setJob" '
    local job="$1"
    Object.attr "$this" "job" "$job"
    echo "职业设置为: $job"
'

## 使用示例
echo "=== 面向对象系统演示 ==="

echo -e "\n=== 创建对象 ==="
Object.create "Person" "person1"
Object.create "Person" "person2"

echo -e "\n=== 初始化对象 ==="
Person.constructor "person1" "Alice" "25"
Person.constructor "person2" "Bob" "30"

echo -e "\n=== 方法调用 ==="
Person.greet "person1"
Person.greet "person2"

echo -e "\n=== 状态改变 ==="
Person.birthday "person1"
Person.greet "person1"

echo -e "\n=== 属性验证 ==="
echo "person1.name = $(Object.attr "person1" "name")"
echo "person1.age = $(Object.attr "person1" "age")"
echo "person2.name = $(Object.attr "person2" "name")"
echo "person2.age = $(Object.attr "person2" "age")"

echo -e "\n=== 系统信息 ==="
echo "实例数量: 2"
echo "类: Person"

# 使用新方法
echo -e "\n=== 扩展功能 ==="
Person.setJob "person1" "工程师"
Person.setJob "person2" "设计师"
Person.introduce "person1"
Person.introduce "person2"

echo -e "\n=== 继承演示 ==="
# 创建 Student 类继承 Person
Object.method "Student" "constructor" '
    local name="$1"
    local age="$2"
    local student_id="$3"
    # 调用父类构造函数
    Person.constructor "$this" "$name" "$age"
    Object.attr "$this" "student_id" "$student_id"
    echo "学生构造函数: name=\"$name\", student_id=\"$student_id\""
'

Object.method "Student" "study" '
    local name=$(Object.attr "$this" "name")
    echo "$name 正在学习..."
'

# 创建学生实例
Object.create "Student" "student1"
Student.constructor "student1" "Charlie" "20" "S12345"
Student.greet "student1"  # 继承自Person的方法
Student.study "student1"

echo -e "\n=== 多态演示 ==="
Object.method "Student" "greet" '
    local name=$(Object.attr "$this" "name")
    local age=$(Object.attr "$this" "age")
    local student_id=$(Object.attr "$this" "student_id")
    echo "Hello, I am student $name, $age years old, ID: $student_id"
'

echo "重写greet方法后:"
Student.greet "student1"

echo -e "\n=== 内存管理演示 ==="
Object.method "Person" "destroy" '
    # 删除对象的所有属性
    local prefix="${this}__"
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == ${prefix}* ]]; then
            unset OBJECT_PROPS["$key"]
        fi
    done
    echo "对象 $this 已被销毁"
'

Person.destroy "person2"
echo "person2销毁后属性:"
Object.attr "person2" "name" 2>/dev/null || echo "属性不存在"