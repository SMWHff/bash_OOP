#!/bin/bash

# Bash 面向对象系统演示脚本

# 导入主系统
source "$(dirname "$0")/../main.sh"

echo "=== Bash 面向对象系统演示 ==="

# 初始化系统
Object::init

echo -e "\n=== 创建对象演示 ==="
Object.create "Person" "person1"
Person.constructor "person1" "张三" "25"
Person.getInfo "person1"

echo -e "\n=== 员工对象演示 ==="
Object.create "Employee" "emp1"
Employee.constructor "emp1" "李四" "28" "科技公司"
Employee.work "emp1"
Employee.getInfo "emp1"

echo -e "\n=== 经理对象演示 ==="
Object.create "Manager" "mgr1"
Manager.constructor "mgr1" "王经理" "35" "科技公司" "10"
Manager.getInfo "mgr1"
Manager.manageTeam "mgr1"

echo -e "\n=== 事件系统演示 ==="
work_event_handler() {
    local instance="$1" event="$2" name="$3" company="$4"
    echo "事件处理: $name 在 $company 工作事件被触发"
}
Object.on "emp1" "work" "work_event_handler"
Employee.work "emp1"

echo -e "\n=== 验证器演示 ==="
Object.addValidator "emp1" "age" "validate_age"
Object.setAttrWithValidation "emp1" "age" "30"
Object.setAttrWithValidation "emp1" "age" "16"

echo -e "\n=== 权限系统演示 ==="
Object.checkPermission "emp1" "employee" "work"
Object.checkPermission "emp1" "manager" "approve"

echo -e "\n=== 事务支持演示 ==="
Object.beginTransaction "emp1"
Object.attr "emp1" "salary" "50000"
Object.rollbackTransaction "emp1"
Employee.getInfo "emp1"

echo -e "\n=== 缓存系统演示 ==="
Object::cacheSet "user_profile" '{"name":"test","age":30}' 10
Object::cacheGet "user_profile"

echo -e "\n=== 配置管理演示 ==="
cat > demo.conf << 'EOF'
app.name=BashOOP演示
app.version=1.0.0
database.host=localhost
database.port=5432
EOF

Object::loadConfig "demo.conf"
echo "应用名称: $(Object::getConfig "app.name")"

echo -e "\n=== 数据库持久化演示 ==="
Object::saveToDB "emp1"
Object::listDBObjects "Employee"

echo -e "\n=== 性能监控演示 ==="
Object::profile "Employee.work" "emp1"

echo -e "\n=== 系统信息 ==="
Object::systemInfo

echo -e "\n=== 演示完成 ==="

# 清理
rm -f demo.conf
Object::cleanup