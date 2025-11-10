#!/bin/bash

# 面向对象系统 - 装饰器修复版
declare -A OBJECT_PROPS
declare -A OBJECT_PRIVATE
declare -A CLASS_METHODS
declare -A OBJECT_RELATIONS

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

# 属性管理
Object.attr() {
    local instance=$1 attr=$2
    local key="${instance}__${attr}"
    
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

# 类方法
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

# 单例模式实现
Object.singleton() {
    local class=$1 instance=$2
    local singleton_key="${class}__singleton"
    
    if [ -z "${OBJECT_PROPS[$singleton_key]}" ]; then
        Object.create "$class" "$instance"
        OBJECT_PROPS["$singleton_key"]="$instance"
        echo "创建单例: $instance (类: $class)"
    else
        echo "返回已存在的单例: ${OBJECT_PROPS[$singleton_key]}"
    fi
    echo "${OBJECT_PROPS[$singleton_key]}"
}

# 观察者模式实现
Object.method "Object" "addObserver" '
    local observer="$1"
    local event="$2"
    local key="${this}__observers__${event}"
    OBJECT_PROPS["$key"]="${OBJECT_PROPS[$key]} $observer"
    echo "添加观察者 $observer 监听事件 $event"
'

Object.method "Object" "notifyObservers" '
    local event="$1"
    local data="$2"
    local key="${this}__observers__${event}"
    local observers="${OBJECT_PROPS[$key]}"
    
    echo "通知事件: $event, 数据: $data"
    for observer in $observers; do
        if type "Object.onEvent" &>/dev/null; then
            Object.onEvent "$observer" "$this" "$event" "$data"
        fi
    done
'

Object.method "Object" "onEvent" '
    local source="$1"
    local event="$2"
    local data="$3"
    echo "观察者 $this 收到来自 $source 的事件: $event, 数据: $data"
'

# 对象关系管理
Object.method "Object" "addRelation" '
    local relation="$1"
    local target="$2"
    local key="${this}__relations__${relation}"
    OBJECT_RELATIONS["$key"]="${OBJECT_RELATIONS[$key]} $target"
    echo "添加关系: $this -[$relation]-> $target"
'

Object.method "Object" "getRelated" '
    local relation="$1"
    local key="${this}__relations__${relation}"
    echo "${OBJECT_RELATIONS[$key]}"
'

# 定义基础类
Object.method "Person" "constructor" '
    local name="$1" age="$2"
    echo "构造函数: name=\"$name\", age=\"$age\""
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "age" "$age"
    Object.private "$this" "secret" "$(date +%s | md5sum | head -c 8 2>/dev/null || echo "secret")"
'

Object.method "Person" "greet" '
    local name=$(Object.attr "$this" "name")
    local age=$(Object.attr "$this" "age")
    echo "Hello, I am $name, $age years old!"
'

# Employee 类
Object.method "Employee" "constructor" '
    local name="$1" age="$2" company="$3"
    Person.constructor "$this" "$name" "$age"
    Object.attr "$this" "company" "$company"
    Object.attr "$this" "salary" "0"
    Object.attr "$this" "position" "员工"
    echo "员工构造函数: company=\"$company\""
'

# 保存原始的work方法
Object.method "Employee" "_originalWork" '
    local name=$(Object.attr "$this" "name")
    local company=$(Object.attr "$this" "company")
    local position=$(Object.attr "$this" "position")
    echo "$name ($position) 正在 $company 工作..."
    Object.notifyObservers "$this" "work" "$name 开始工作"
'

# work方法调用原始方法
Object.method "Employee" "work" '
    Employee._originalWork "$this"
'

Object.method "Employee" "promote" '
    local new_position="$1"
    local old_position=$(Object.attr "$this" "position")
    Object.attr "$this" "position" "$new_position"
    echo "$(Object.attr "$this" "name") 晋升: $old_position -> $new_position"
    Object.notifyObservers "$this" "promotion" "$new_position"
'

Object.method "Employee" "getInfo" '
    local name=$(Object.attr "$this" "name")
    local company=$(Object.attr "$this" "company")
    local salary=$(Object.attr "$this" "salary")
    local position=$(Object.attr "$this" "position")
    echo "员工信息: 姓名=$name, 职位=$position, 公司=$company, 工资=$salary"
'

# 继承Person的方法
Object.method "Employee" "greet" 'Person.greet "$this"'
Object.method "Employee" "birthday" 'Person.birthday "$this"'

# 经理类 - 继承Employee
Object.method "Manager" "constructor" '
    local name="$1" age="$2" company="$3" department="$4"
    Employee.constructor "$this" "$name" "$age" "$company"
    Object.attr "$this" "department" "$department"
    Object.attr "$this" "position" "经理"
    Object.attr "$this" "team" ""
    echo "经理构造函数: department=\"$department\""
'

Object.method "Manager" "addToTeam" '
    local employee="$1"
    local current_team=$(Object.attr "$this" "team")
    Object.attr "$this" "team" "$current_team $employee"
    Object.addRelation "$this" "manages" "$employee"
    Object.addRelation "$employee" "managed_by" "$this"
    echo "经理 $(Object.attr "$this" "name") 添加 $employee 到团队"
'

Object.method "Manager" "manageTeam" '
    local name=$(Object.attr "$this" "name")
    local department=$(Object.attr "$this" "department")
    local team=$(Object.attr "$this" "team")
    echo "经理 $name 正在管理 $department 部门:"
    for member in $team; do
        local member_name=$(Object.attr "$member" "name")
        echo "  - 管理: $member ($member_name)"
    done
'

# 继承Employee的方法
Object.method "Manager" "work" 'Employee.work "$this"'
Object.method "Manager" "getInfo" 'Employee.getInfo "$this"'

# 日志观察者
Object.method "Logger" "constructor" '
    Object.attr "$this" "name" "$1"
    echo "日志器创建: $1"
'

Object.method "Logger" "onEvent" '
    local source="$1" event="$2" data="$3"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local source_name=$(Object.attr "$source" "name" 2>/dev/null || echo "$source")
    echo "[$timestamp] LOG: 来源=$source_name, 事件=$event, 数据=$data"
'

## 修复的工厂模式
Object.static "Employee" "createDeveloper" '
    local name="$1" age="$2" company="$3"
    local instance="dev_${name}_$(date +%s)"
    Object.create "Employee" "$instance"
    Employee.constructor "$instance" "$name" "$age" "$company"
    Object.attr "$instance" "position" "开发工程师"
    Object.attr "$instance" "skills" "编程,调试,设计"
    echo "创建开发人员: $instance"
    echo "$instance"
'

Object.static "Employee" "createManager" '
    local name="$1" age="$2" company="$3" department="$4"
    local instance="mgr_${name}_$(date +%s)"
    Object.create "Manager" "$instance"
    Manager.constructor "$instance" "$name" "$age" "$company" "$department"
    echo "创建经理: $instance"
    echo "$instance"
'

## 修复装饰器模式 - 正确实现
Object.method "Employee" "addBonus" '
    local bonus_rate="$1"
    local instance="$this"
    
    # 为特定实例创建装饰后的work方法
    eval "
        Employee.work_${instance}() {
            local name=\$(Object.attr \"$instance\" \"name\")
            local bonus_percent=\$(echo \"$bonus_rate * 100\" | bc 2>/dev/null || echo \"10\")
            echo \"\$name 获得 \${bonus_percent}% 绩效奖金!\"
            Employee._originalWork \"$instance\"
        }
    "
    
    # 重写该实例的work方法
    eval "
        Employee.work() {
            if [ \"\$1\" = \"$instance\" ]; then
                Employee.work_${instance} \"\$@\"
            else
                Employee._originalWork \"\$@\"
            fi
        }
    "
    
    echo "为 $this 添加奖金装饰器 (费率: $bonus_rate)"
'

## 修复策略模式
SalaryCalculator::calculate() {
    local strategy="$1" employee="$2"
    local base_salary=$(Object.attr "$employee" "salary")
    
    case $strategy in
        "developer")
            echo $(($base_salary * 12 / 10))  # 增加20%
            ;;
        "manager")  
            echo $(($base_salary * 15 / 10))  # 增加50%
            ;;
        "ceo")
            echo $(($base_salary * 2))  # 增加100%
            ;;
        *)
            echo "$base_salary"
            ;;
    esac
}

## 修复系统监控
Object.static "Object" "systemInfo" '
    echo "=== 系统信息 ==="
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
    
    echo -n "定义的类: "
    declare -F | grep -oE "[a-zA-Z_][a-zA-Z0-9_]*\." | sort -u | tr -d '.' | tr '\n' ' '
    echo ""
    echo "总方法数: $(declare -F | wc -l)"
'

## 高级特性演示
echo "=== 面向对象系统 - 装饰器修复演示 ==="

echo -e "\n=== 基础对象创建 ==="
Object.create "Employee" "emp1"
Employee.constructor "emp1" "程序员A" "28" "科技公司"

echo -e "\n=== 装饰器模式演示 ==="
echo "应用装饰器前:"
Employee.work "emp1"

echo -e "\n应用装饰器:"
Employee.addBonus "emp1" "0.15"

echo -e "\n应用装饰器后:"
Employee.work "emp1"

echo -e "\n=== 验证其他对象不受影响 ==="
Object.create "Employee" "emp2"
Employee.constructor "emp2" "程序员B" "26" "科技公司"
echo "emp2 (未装饰):"
Employee.work "emp2"

echo -e "\n=== 再次验证emp1 ==="
Employee.work "emp1"

echo -e "\n=== 性能测试 ==="
Object.static "Object" "performanceTest" '
    echo "性能测试 - 创建多个对象:"
    local start_time=$(date +%s%N)
    
    for i in {1..5}; do
        Object.create "Person" "perf_test_$i"
        Person.constructor "perf_test_$i" "PerfTest$i" "$((20 + i))"
    done
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    echo "创建5个对象耗时: ${duration}ms"
'

Object::performanceTest

echo -e "\n=== 系统信息 ==="
Object::systemInfo

echo -e "\n=== 演示完成 ==="