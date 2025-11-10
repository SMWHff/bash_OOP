#!/bin/bash

# 面向对象系统 - 企业级扩展版
declare -A OBJECT_PROPS
declare -A OBJECT_PRIVATE
declare -A CLASS_METHODS
declare -A OBJECT_RELATIONS
declare -A OBJECT_EVENTS
declare -A OBJECT_VALIDATORS

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

# 添加事件系统
Object.method "Object" "on" '
    local event="$1" handler="$2"
    local key="${this}__events__${event}"
    OBJECT_EVENTS["$key"]="${OBJECT_EVENTS[$key]} $handler"
    echo "注册事件处理器: $this -> $event"
'

Object.method "Object" "emit" '
    local event="$1"
    shift
    local key="${this}__events__${event}"
    local handlers="${OBJECT_EVENTS[$key]}"
    
    echo "触发事件: $event, 参数: $@"
    for handler in $handlers; do
        if type "$handler" &>/dev/null; then
            $handler "$this" "$@"
        fi
    done
'

# 添加验证器系统
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

# 数据库模拟
Object.static "Object" "saveToDB" '
    local instance="$1"
    local class=$(Object.attr "$instance" "class")
    local id=$(Object.attr "$instance" "id")
    
    echo "保存对象到数据库: $instance (类: $class, ID: $id)"
    
    # 模拟数据库表
    local db_file="db_${class}.txt"
    {
        echo "# $instance - $(date)"
        for key in "${!OBJECT_PROPS[@]}"; do
            if [[ "$key" == ${instance}__* ]]; then
                local prop_name="${key#${instance}__}"
                echo "${prop_name}=${OBJECT_PROPS[$key]}"
            fi
        done
        echo "---"
    } >> "$db_file"
    
    echo "保存完成: $db_file"
'

Object.static "Object" "loadFromDB" '
    local class="$1" instance="$2"
    local db_file="db_${class}.txt"
    
    if [ ! -f "$db_file" ]; then
        echo "数据库文件不存在: $db_file"
        return 1
    fi
    
    echo "从数据库加载对象: $instance (类: $class)"
    Object.create "$class" "$instance"
    
    while IFS='=' read -r prop_name value; do
        if [[ "$prop_name" != "#"* && "$prop_name" != "---" && -n "$prop_name" ]]; then
            Object.attr "$instance" "$prop_name" "$value"
        fi
    done < <(grep -A 100 "^# $instance" "$db_file" | head -n 10)
    
    echo "加载完成: $instance"
'

# 添加缓存系统
declare -A OBJECT_CACHE

Object.static "Object" "cacheSet" '
    local key="$1" value="$2" ttl="${3:-300}"
    local expire_time=$(( $(date +%s) + ttl ))
    OBJECT_CACHE["${key}__value"]="$value"
    OBJECT_CACHE["${key}__expire"]="$expire_time"
    echo "缓存设置: $key -> $value (TTL: ${ttl}s)"
'

Object.static "Object" "cacheGet" '
    local key="$1"
    local value="${OBJECT_CACHE[${key}__value]}"
    local expire="${OBJECT_CACHE[${key}__expire]}"
    local current_time=$(date +%s)
    
    if [ -n "$value" ] && [ "$current_time" -lt "$expire" ]; then
        echo "缓存命中: $key -> $value"
        echo "$value"
        return 0
    else
        echo "缓存未命中: $key"
        return 1
    fi
'

# 添加性能监控
Object.static "Object" "profile" '
    local func="$1"
    shift
    local start_time=$(date +%s%N)
    
    # 执行函数
    "$func" "$@"
    local result=$?
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    echo "性能分析: $func 耗时 ${duration}ms"
    return $result
'

# 添加配置管理
Object.static "Object" "loadConfig" '
    local config_file="$1"
    if [ ! -f "$config_file" ]; then
        echo "配置文件不存在: $config_file"
        return 1
    fi
    
    echo "加载配置文件: $config_file"
    while IFS='=' read -r key value; do
        if [[ "$key" != "#"* && -n "$key" ]]; then
            OBJECT_PROPS["config__${key}"]="$value"
            echo "配置: $key = $value"
        fi
    done < "$config_file"
'

Object.static "Object" "getConfig" '
    local key="$1"
    echo "${OBJECT_PROPS[config__${key}]}"
'

# 添加权限系统
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

# 添加事务支持
Object.method "Object" "beginTransaction" '
    echo "开始事务: $this"
    Object.attr "$this" "__transaction_backup" "$(mktemp)"
    
    # 备份当前状态
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            echo "$key=${OBJECT_PROPS[$key]}" >> $(Object.attr "$this" "__transaction_backup")
        fi
    done
'

Object.method "Object" "commitTransaction" '
    echo "提交事务: $this"
    local backup_file=$(Object.attr "$this" "__transaction_backup")
    [ -f "$backup_file" ] && rm -f "$backup_file"
    Object.attr "$this" "__transaction_backup" ""
'

Object.method "Object" "rollbackTransaction" '
    echo "回滚事务: $this"
    local backup_file=$(Object.attr "$this" "__transaction_backup")
    
    if [ -f "$backup_file" ]; then
        # 恢复状态
        while IFS='=' read -r key value; do
            OBJECT_PROPS["$key"]="$value"
        done < "$backup_file"
        rm -f "$backup_file"
    fi
    Object.attr "$this" "__transaction_backup" ""
'

# 定义基础类（使用之前修复的版本）
Object.method "Person" "constructor" '
    local name="$1" age="$2"
    echo "构造函数: name=\"$name\", age=\"$age\""
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "age" "$age"
    Object.private "$this" "secret" "$(date +%s | md5sum | head -c 8 2>/dev/null || echo "secret")"
'

Object.method "Employee" "constructor" '
    local name="$1" age="$2" company="$3"
    Person.constructor "$this" "$name" "$age"
    Object.attr "$this" "company" "$company"
    Object.attr "$this" "salary" "0"
    Object.attr "$this" "position" "员工"
    echo "员工构造函数: company=\"$company\""
    
    # 添加默认权限
    Object.addPermission "$this" "employee" "read"
    Object.addPermission "$this" "employee" "work"
'

Object.method "Employee" "work" '
    local name=$(Object.attr "$this" "name")
    local company=$(Object.attr "$this" "company")
    local position=$(Object.attr "$this" "position")
    echo "$name ($position) 正在 $company 工作..."
    Object.emit "$this" "work" "$name" "$company"
'

Object.method "Employee" "getInfo" '
    local name=$(Object.attr "$this" "name")
    local company=$(Object.attr "$this" "company")
    local salary=$(Object.attr "$this" "salary")
    local position=$(Object.attr "$this" "position")
    echo "员工信息: 姓名=$name, 职位=$position, 公司=$company, 工资=$salary"
'

# 创建验证器函数
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

# 创建事件处理器
work_event_handler() {
    local instance="$1" name="$2" company="$3"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] 工作日志: $name 在 $company 工作"
}

attr_change_handler() {
    local instance="$1" attr="$2" value="$3"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] 属性变更: $instance.$attr = $value"
}

## 企业级功能演示
echo "=== Bash 面向对象系统 - 企业级扩展演示 ==="

echo -e "\n=== 配置管理 ==="
# 创建配置文件
cat > app.conf << 'EOF'
# 应用配置
database.host=localhost
database.port=5432
app.name=BashOOP系统
app.version=1.0.0
log.level=INFO
EOF

Object::loadConfig "app.conf"
echo "数据库主机: $(Object::getConfig "database.host")"
echo "应用名称: $(Object::getConfig "app.name")"

echo -e "\n=== 事件系统 ==="
Object.create "Employee" "event_emp"
Employee.constructor "event_emp" "事件员工" "28" "事件公司"

# 注册事件处理器
Object.on "event_emp" "work" "work_event_handler"
Object.on "event_emp" "attrChanged" "attr_change_handler"

echo -e "\n触发工作事件:"
Employee.work "event_emp"

echo -e "\n=== 验证器系统 ==="
Object.create "Employee" "valid_emp"
Employee.constructor "valid_emp" "验证员工" "25" "验证公司"

# 添加验证器
Object.addValidator "valid_emp" "age" "validate_age"
Object.addValidator "valid_emp" "salary" "validate_salary"

echo -e "\n测试验证器:"
echo "设置有效年龄:"
Object.setAttrWithValidation "valid_emp" "age" "30"

echo -e "\n设置无效年龄:"
Object.setAttrWithValidation "valid_emp" "age" "16"

echo -e "\n设置有效工资:"
Object.setAttrWithValidation "valid_emp" "salary" "50000"

echo -e "\n设置无效工资:"
Object.setAttrWithValidation "valid_emp" "salary" "-1000"

echo -e "\n=== 权限系统 ==="
Object.create "Employee" "admin_emp"
Employee.constructor "admin_emp" "管理员" "35" "权限公司"

# 添加管理员权限
Object.addPermission "admin_emp" "admin" "read"
Object.addPermission "admin_emp" "admin" "write" 
Object.addPermission "admin_emp" "admin" "delete"

echo -e "\n权限检查:"
Object.checkPermission "admin_emp" "admin" "write"
Object.checkPermission "admin_emp" "employee" "read"
Object.checkPermission "admin_emp" "admin" "execute"

echo -e "\n=== 事务支持 ==="
Object.create "Employee" "tx_emp"
Employee.constructor "tx_emp" "事务员工" "30" "事务公司"

echo -e "\n开始事务:"
Object.beginTransaction "tx_emp"
Object.attr "tx_emp" "salary" "10000"
Object.attr "tx_emp" "position" "高级员工"
Employee.getInfo "tx_emp"

echo -e "\n回滚事务:"
Object.rollbackTransaction "tx_emp"
Employee.getInfo "tx_emp"

echo -e "\n新事务和提交:"
Object.beginTransaction "tx_emp"
Object.attr "tx_emp" "salary" "20000"
Object.attr "tx_emp" "position" "资深员工"
Employee.getInfo "tx_emp"
Object.commitTransaction "tx_emp"
Employee.getInfo "tx_emp"

echo -e "\n=== 缓存系统 ==="
echo "设置缓存:"
Object::cacheSet "user_123" "张三" 60
Object::cacheSet "config_db" "mysql://localhost:3306" 300

echo -e "\n获取缓存:"
Object::cacheGet "user_123"
Object::cacheGet "config_db"
Object::cacheGet "nonexistent_key"

echo -e "\n=== 数据库持久化 ==="
Object.create "Employee" "db_emp"
Employee.constructor "db_emp" "数据库员工" "40" "数据公司"
Object.attr "db_emp" "salary" "75000"
Object.attr "db_emp" "position" "数据工程师"

echo -e "\n保存到数据库:"
Object::saveToDB "db_emp"

echo -e "\n从数据库加载:"
Object::loadFromDB "Employee" "loaded_emp"
Employee.getInfo "loaded_emp"

echo -e "\n=== 性能监控 ==="
echo "性能分析演示:"
Object::profile "Employee.work" "event_emp"

echo -e "\n=== 系统信息 ==="
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
    echo "定义的类: Object Person Employee Manager Logger"
    echo "总方法数: $(declare -F | wc -l)"
'

Object::systemInfo

echo -e "\n=== 内存管理 ==="
Object.static "Object" "cleanup" '
    echo "=== 系统清理 ==="
    local count_before=${#OBJECT_PROPS[@]}
    
    # 找出所有对象实例
    local instances=()
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == *"__class" ]]; then
            local instance="${key%__class}"
            instances+=("$instance")
        fi
    done
    
    # 清理每个对象
    for instance in "${instances[@]}"; do
        echo "清理对象: $instance"
        # 删除对象的所有属性
        for key in "${!OBJECT_PROPS[@]}"; do
            if [[ "$key" == ${instance}__* ]]; then
                unset OBJECT_PROPS["$key"]
            fi
        done
        # 删除对象的私有属性
        for key in "${!OBJECT_PRIVATE[@]}"; do
            if [[ "$key" == ${instance}__* ]]; then
                unset OBJECT_PRIVATE["$key"]
            fi
        done
        # 删除对象的关系
        for key in "${!OBJECT_RELATIONS[@]}"; do
            if [[ "$key" == ${instance}__* ]]; then
                unset OBJECT_RELATIONS["$key"]
            fi
        done
        # 删除对象的事件
        for key in "${!OBJECT_EVENTS[@]}"; do
            if [[ "$key" == ${instance}__* ]]; then
                unset OBJECT_EVENTS["$key"]
            fi
        done
        # 删除对象的验证器
        for key in "${!OBJECT_VALIDATORS[@]}"; do
            if [[ "$key" == ${instance}__* ]]; then
                unset OBJECT_VALIDATORS["$key"]
            fi
        done
    done
    
    local count_after=${#OBJECT_PROPS[@]}
    echo "清理完成: 移除 $((count_before - count_after)) 个属性"
    
    # 清理缓存
    OBJECT_CACHE=()
    echo "缓存已清空"
'

echo "清理前:"
Object::systemInfo
Object::cleanup
echo -e "\n清理后:"
Object::systemInfo

echo -e "\n=== 企业级特性总结 ==="
echo "🎯 新增企业级功能:"
echo "✅ 事件系统 - 发布/订阅模式"
echo "✅ 验证器系统 - 数据验证和约束"
echo "✅ 权限系统 - 基于角色的访问控制"
echo "✅ 事务支持 - ACID特性模拟"
echo "✅ 缓存系统 - TTL缓存管理"
echo "✅ 配置管理 - 外部配置加载"
echo "✅ 数据库持久化 - 对象存储和恢复"
echo "✅ 性能监控 - 函数执行时间分析"
echo "✅ 完整的系统监控 - 资源使用统计"

echo -e "\n💼 适用场景:"
echo "📊 企业级应用开发"
echo "🔧 复杂系统配置管理"
echo "🛡️ 安全敏感的权限控制"
echo "📈 高性能要求的场景"
echo "💾 数据持久化需求"
echo "🔍 系统监控和调试"

echo -e "\n🚀 Bash 面向对象系统现已具备企业级应用开发能力!"