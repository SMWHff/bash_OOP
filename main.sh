#!/bin/bash

# 面向对象系统 - 高级扩展版
declare -A OBJECT_PROPS
declare -A OBJECT_PRIVATE  # 私有属性存储
declare -A CLASS_METHODS   # 类方法存储

Object() {
    : # 基类
}

# 创建实例
Object.create() {
    local class=$1 instance=$2
    echo "创建实例: $instance (类: $class)"
    OBJECT_PROPS["${instance}__class"]="$class"
    OBJECT_PROPS["${instance}__created"]="$(date '+%Y-%m-%d %H:%M:%S')"
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

# 私有属性（命名约定）
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

# 接口定义（模拟）
Object.interface() {
    local interface=$1
    shift
    CLASS_METHODS["${interface}__methods"]="$@"
}

# 检查是否实现接口
Object.implements() {
    local instance=$1 interface=$2
    local class=$(Object.attr "$instance" "class")
    local required_methods=${CLASS_METHODS["${interface}__methods"]}
    
    for method in $required_methods; do
        if ! type "${class}.${method}" &>/dev/null; then
            echo "错误: 类 $class 没有实现接口 $interface 的方法 $method"
            return 1
        fi
    done
    echo "实例 $instance 实现了接口 $interface"
    return 0
}

# 定义 Person 类的方法
Object.method "Person" "constructor" '
    local name="$1"
    local age="$2"
    echo "构造函数: name=\"$name\", age=\"$age\""
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "age" "$age"
    Object.private "$this" "secret" "$(uuidgen 2>/dev/null || echo "secret-$(date +%s)")"
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

Object.method "Person" "getSecret" '
    local secret=$(Object.private "$this" "secret")
    echo "我的秘密ID: $secret"
'

# Person 类方法（静态方法）
Object.static "Person" "getSpecies" '
    echo "人类 (Homo sapiens)"
'

Object.static "Person" "createAdult" '
    local name="$1"
    local instance="${name}_adult"
    Object.create "Person" "$instance"
    Person.constructor "$instance" "$name" "18"
    echo "创建成年实例: $instance"
'

# 定义接口
Object.interface "Workable" "work takeBreak"
Object.interface "Learnable" "study takeExam"

# Employee 类实现接口
Object.method "Employee" "constructor" '
    local name="$1" age="$2" company="$3"
    Person.constructor "$this" "$name" "$age"
    Object.attr "$this" "company" "$company"
    Object.attr "$this" "salary" "0"
    echo "员工构造函数: company=\"$company\""
'

Object.method "Employee" "work" '
    local name=$(Object.attr "$this" "name")
    local company=$(Object.attr "$this" "company")
    echo "$name 正在 $company 工作..."
'

Object.method "Employee" "takeBreak" '
    local name=$(Object.attr "$this" "name")
    echo "$name 正在休息..."
'

Object.method "Employee" "setSalary" '
    local salary="$1"
    Object.attr "$this" "salary" "$salary"
    echo "工资设置为: $salary"
'

Object.method "Employee" "getInfo" '
    local name=$(Object.attr "$this" "name")
    local company=$(Object.attr "$this" "company")
    local salary=$(Object.attr "$this" "salary")
    echo "员工信息: 姓名=$name, 公司=$company, 工资=$salary"
'

# 手动继承Person的方法
Object.method "Employee" "greet" 'Person.greet "$this"'
Object.method "Employee" "birthday" 'Person.birthday "$this"'
Object.method "Employee" "introduce" 'Person.introduce "$this"'

## 使用示例
echo "=== 面向对象系统高级演示 ==="

echo -e "\n=== 类方法演示 ==="
Person::getSpecies
Person::createAdult "Tom"

echo -e "\n=== 接口实现演示 ==="
Object.create "Employee" "emp1"
Employee.constructor "emp1" "张工" "28" "科技公司"
Object.implements "emp1" "Workable"

echo -e "\n=== 接口方法调用 ==="
Employee.work "emp1"
Employee.takeBreak "emp1"

echo -e "\n=== 私有属性演示 ==="
Person.getSecret "person1"
Employee.getSecret "emp1"

echo -e "\n=== 员工功能演示 ==="
Employee.setSalary "emp1" "15000"
Employee.getInfo "emp1"
Employee.greet "emp1"
Employee.birthday "emp1"
Employee.getInfo "emp1"

echo -e "\n=== 多态和组合演示 ==="

# 创建部门类
Object.method "Department" "constructor" '
    local name="$1"
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "employees" ""
    echo "部门创建: $name"
'

Object.method "Department" "addEmployee" '
    local employee="$1"
    local current_employees=$(Object.attr "$this" "employees")
    Object.attr "$this" "employees" "$current_employees $employee"
    echo "员工 $employee 加入部门 $(Object.attr "$this" "name")"
'

Object.method "Department" "listEmployees" '
    local employees=$(Object.attr "$this" "employees")
    echo "部门 $(Object.attr "$this" "name") 的员工:"
    for emp in $employees; do
        local name=$(Object.attr "$emp" "name" 2>/dev/null || echo "未知")
        echo "  - $emp ($name)"
    done
'

Object.method "Department" "workAll" '
    local employees=$(Object.attr "$this" "employees")
    echo "部门 $(Object.attr "$this" "name") 开始工作:"
    for emp in $employees; do
        if type "Employee.work" &>/dev/null; then
            Employee.work "$emp"
        fi
    done
'

echo -e "\n=== 部门管理演示 ==="
Object.create "Department" "dev_dept"
Department.constructor "dev_dept" "开发部"

# 创建更多员工
Object.create "Employee" "emp2"
Employee.constructor "emp2" "李工" "25" "科技公司"
Employee.setSalary "emp2" "12000"

Object.create "Employee" "emp3"  
Employee.constructor "emp3" "王工" "30" "科技公司"
Employee.setSalary "emp3" "18000"

# 添加员工到部门
Department.addEmployee "dev_dept" "emp1"
Department.addEmployee "dev_dept" "emp2"
Department.addEmployee "dev_dept" "emp3"

Department.listEmployees "dev_dept"
Department.workAll "dev_dept"

echo -e "\n=== 反射功能演示 ==="

Object.method "Object" "listMethods" '
    local class=$(Object.attr "$this" "class")
    echo "实例 $this 的方法:"
    declare -F | grep "declare -f ${class}\." | sed "s/declare -f //"
'

Object.method "Object" "listProperties" '
    echo "实例 $this 的属性:"
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            local prop_name="${key#${this}__}"
            if [[ "$prop_name" != private__* ]]; then
                echo "  - $prop_name: ${OBJECT_PROPS[$key]}"
            fi
        fi
    done
'

echo -e "\n=== emp1 的反射信息 ==="
Object.listMethods "emp1"
Object.listProperties "emp1"

echo -e "\n=== 序列化演示 ==="

Object.method "Object" "serialize" '
    local file="${1:-${this}.data}"
    echo "序列化对象 $this 到文件 $file"
    {
        echo "# 对象序列化数据: $this"
        for key in "${!OBJECT_PROPS[@]}"; do
            if [[ "$key" == ${this}__* ]]; then
                echo "PROP:${key}=${OBJECT_PROPS[$key]}"
            fi
        done
        for key in "${!OBJECT_PRIVATE[@]}"; do
            if [[ "$key" == ${this}__* ]]; then
                echo "PRIVATE:${key}=${OBJECT_PRIVATE[$key]}"
            fi
        done
    } > "$file"
    echo "序列化完成"
'

Object.method "Object" "deserialize" '
    local file="${1:-${this}.data}"
    if [ ! -f "$file" ]; then
        echo "文件不存在: $file"
        return 1
    fi
    echo "从文件 $file 反序列化对象 $this"
    while IFS= read -r line; do
        if [[ "$line" == PROP:* ]]; then
            local key_value="${line#PROP:}"
            local key="${key_value%%=*}"
            local value="${key_value#*=}"
            OBJECT_PROPS["$key"]="$value"
        elif [[ "$line" == PRIVATE:* ]]; then
            local key_value="${line#PRIVATE:}"
            local key="${key_value%%=*}"
            local value="${key_value#*=}"
            OBJECT_PRIVATE["$key"]="$value"
        fi
    done < "$file"
    echo "反序列化完成"
'

# 序列化测试
Object.serialize "emp1" "emp1_backup.data"
Object.create "Employee" "emp1_restore"
Object.deserialize "emp1_restore" "emp1_backup.data"
Employee.getInfo "emp1_restore"

echo -e "\n=== 系统统计 ==="
echo "总对象数量: $(($(echo "${!OBJECT_PROPS[@]}" | tr ' ' '\n' | grep -c "__class") / 1))"
echo "总属性数量: ${#OBJECT_PROPS[@]}"
echo "总私有属性数量: ${#OBJECT_PRIVATE[@]}"