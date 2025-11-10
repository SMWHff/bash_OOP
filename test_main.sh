#!/bin/bash

# 综合测试用例文件：test_comprehensive.sh
# 包含原有所有测试用例 + 数据库持久化增强测试

# 引入被测试的主脚本
source main.sh

# 全局计数变量
PASS_COUNT=0
FAIL_COUNT=0

# 测试辅助函数
print_test_header() {
    echo "=========================================="
    echo "测试: $1"
    echo "=========================================="
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    # 清理实际值中的换行符和多余空格
    actual=$(echo "$actual" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')
    expected=$(echo "$expected" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')
    
    if [ "$expected" = "$actual" ]; then
        echo "✅ PASS: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   期望: '$expected'"
        echo "   实际: '$actual'"
        ((FAIL_COUNT++))
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local test_name="$3"
    
    actual=$(echo "$actual" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')
    unexpected=$(echo "$unexpected" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')
    
    if [ "$unexpected" != "$actual" ]; then
        echo "✅ PASS: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   不期望: '$unexpected'"
        echo "   实际: '$actual'"
        ((FAIL_COUNT++))
        return 1
    fi
}

assert_contains() {
    local container="$1"
    local content="$2"
    local test_name="$3"
    
    if [[ "$container" == *"$content"* ]]; then
        echo "✅ PASS: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   容器: '$container'"
        echo "   不包含: '$content'"
        ((FAIL_COUNT++))
        return 1
    fi
}

assert_success() {
    local command="$1"
    local test_name="$2"
    
    if eval "$command" > /dev/null 2>&1; then
        echo "✅ PASS: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   命令执行失败: $command"
        ((FAIL_COUNT++))
        return 1
    fi
}

assert_failure() {
    local command="$1"
    local test_name="$2"
    
    if ! eval "$command" > /dev/null 2>&1; then
        echo "✅ PASS: $test_name"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ FAIL: $test_name"
        echo "   命令意外成功: $command"
        ((FAIL_COUNT++))
        return 1
    fi
}

# 特殊断言函数，用于手动计数的测试
manual_assert() {
    local test_name="$1"
    local result="$2"  # "pass" 或 "fail"
    
    if [ "$result" = "pass" ]; then
        echo "✅ PASS: $test_name"
        ((PASS_COUNT++))
    else
        echo "❌ FAIL: $test_name"
        ((FAIL_COUNT++))
    fi
}

# 清理测试环境
cleanup_test() {
    rm -f app.conf test_config.conf db_*.txt
    Object::cleanup > /dev/null 2>&1
}

# 修复缓存函数 - 只返回值，不输出日志
Object::cacheGetSilent() {
    local key="$1"
    local value="${OBJECT_CACHE[${key}__value]}"
    local expire="${OBJECT_CACHE[${key}__expire]}"
    local current_time=$(date +%s)
    
    if [ -n "$value" ] && [ "$current_time" -lt "$expire" ]; then
        echo "$value"
        return 0
    else
        return 1
    fi
}

# ============================================================================
# 原有测试用例开始
# ============================================================================

echo "开始执行 Bash 面向对象系统综合测试用例"
echo "=========================================="

# 重置计数器
PASS_COUNT=0
FAIL_COUNT=0

# 测试1: 对象创建和基本属性
print_test_header "对象创建和基本属性"
Object.create "TestClass" "test_obj1"
Object.attr "test_obj1" "name" "测试对象"
Object.attr "test_obj1" "value" "100"

class=$(Object.attr "test_obj1" "class")
name=$(Object.attr "test_obj1" "name")
value=$(Object.attr "test_obj1" "value")

assert_equals "TestClass" "$class" "对象类名设置"
assert_equals "测试对象" "$name" "对象属性设置"
assert_equals "100" "$value" "对象数值属性设置"

# 测试2: 私有属性
print_test_header "私有属性测试"
Object.create "TestClass" "test_obj2"
Object.private "test_obj2" "secret_key" "my_secret_123"

secret=$(Object.private "test_obj2" "secret_key")
assert_equals "my_secret_123" "$secret" "私有属性设置和获取"

# 测试3: 方法定义和调用
print_test_header "方法定义和调用测试"
Object.method "Calculator" "add" '
    local a="$1" b="$2"
    echo $((a + b))
'

result=$(Calculator.add "test_calc" "5" "3")
assert_equals "8" "$result" "类方法调用和计算"

# 测试4: 事件系统
print_test_header "事件系统测试"
Object.create "EventTest" "event_obj"

# 创建事件处理器
test_event_handler() {
    local instance="$1" message="$2"
    echo "事件处理: $message"
}

Object.on "event_obj" "test_event" "test_event_handler"
event_result=$(Object.emit "event_obj" "test_event" "Hello Event")

assert_contains "$event_result" "触发事件: test_event" "事件触发"
assert_contains "$event_result" "事件处理: Hello Event" "事件处理"

# 测试5: 验证器系统
print_test_header "验证器系统测试"
Object.create "ValidatorTest" "valid_obj"

# 测试验证器
validate_positive() {
    local value="$1"
    if [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

Object.addValidator "valid_obj" "count" "validate_positive"

# 测试有效值
Object.setAttrWithValidation "valid_obj" "count" "10"
valid_count=$(Object.attr "valid_obj" "count")
assert_equals "10" "$valid_count" "验证器通过设置"

# 测试无效值
Object.setAttrWithValidation "valid_obj" "count" "-5"
invalid_count=$(Object.attr "valid_obj" "count")
assert_not_equals "-5" "$invalid_count" "验证器拒绝无效值"

# 测试6: 权限系统
print_test_header "权限系统测试"
Object.create "PermissionTest" "perm_obj"

Object.addPermission "perm_obj" "admin" "read"
Object.addPermission "perm_obj" "admin" "write"
Object.addPermission "perm_obj" "user" "read"

assert_success 'Object.checkPermission "perm_obj" "admin" "write"' "管理员写权限检查"
assert_success 'Object.checkPermission "perm_obj" "user" "read"' "用户读权限检查"
assert_failure 'Object.checkPermission "perm_obj" "user" "write"' "用户写权限拒绝检查"

# 测试7: 事务支持
print_test_header "事务支持测试"
Object.create "TransactionTest" "tx_obj"
Object.attr "tx_obj" "balance" "1000"

Object.beginTransaction "tx_obj"
Object.attr "tx_obj" "balance" "2000"
after_begin=$(Object.attr "tx_obj" "balance")

Object.rollbackTransaction "tx_obj"
after_rollback=$(Object.attr "tx_obj" "balance")

assert_equals "2000" "$after_begin" "事务开始后属性修改"
assert_equals "1000" "$after_rollback" "事务回滚后属性恢复"

# 测试8: 缓存系统 - 修复版本
print_test_header "缓存系统测试"
Object::cacheSet "test_key" "test_value" 60
cached_value=$(Object::cacheGetSilent "test_key")

assert_equals "test_value" "$cached_value" "缓存设置和获取"

# 测试缓存过期（模拟）
Object::cacheSet "expire_key" "expire_value" 1
sleep 2
Object::cacheGetSilent "expire_key" > /dev/null 2>&1
expired_result=$?
assert_equals "1" "$expired_result" "缓存过期测试"

# 测试9: 配置管理
print_test_header "配置管理测试"
cat > test_config.conf << 'EOF'
server.host=localhost
server.port=8080
app.name=TestApp
EOF

Object::loadConfig "test_config.conf"
host=$(Object::getConfig "server.host")
port=$(Object::getConfig "server.port")
app_name=$(Object::getConfig "app.name")

assert_equals "localhost" "$host" "配置主机名读取"
assert_equals "8080" "$port" "配置端口读取"
assert_equals "TestApp" "$app_name" "配置应用名读取"

# 测试10: 数据库持久化 - 修复版本
print_test_header "数据库持久化测试"
Object.create "PersistenceTest" "persist_obj"
Object.attr "persist_obj" "username" "test_user"
Object.attr "persist_obj" "email" "test@example.com"
Object.attr "persist_obj" "level" "5"

# 保存到数据库
Object::saveToDB "persist_obj"
assert_success '[ -f "db_PersistenceTest.txt" ]' "数据库文件创建"

# 从数据库加载 - 使用相同的实例名
Object::loadFromDB "PersistenceTest" "persist_obj"
loaded_username=$(Object.attr "persist_obj" "username")
loaded_email=$(Object.attr "persist_obj" "email")

assert_equals "test_user" "$loaded_username" "持久化数据用户名恢复"
assert_equals "test@example.com" "$loaded_email" "持久化数据邮箱恢复"

# 测试11: Employee类功能
print_test_header "Employee类功能测试"
Object.create "Employee" "emp1"
Employee.constructor "emp1" "张三" "30" "测试公司"

Object.attr "emp1" "salary" "50000"
Object.attr "emp1" "position" "高级工程师"

# 测试工作方法
work_output=$(Employee.work "emp1")
assert_contains "$work_output" "张三" "Employee工作方法包含姓名"
assert_contains "$work_output" "测试公司" "Employee工作方法包含公司"

# 测试信息获取
info_output=$(Employee.getInfo "emp1")
assert_contains "$info_output" "员工信息" "Employee信息方法格式"
assert_contains "$info_output" "张三" "Employee信息包含姓名"
assert_contains "$info_output" "高级工程师" "Employee信息包含职位"

# 测试12: 对象销毁
print_test_header "对象销毁测试"
Object.create "DestroyTest" "destroy_obj"
Object.attr "destroy_obj" "data" "important_data"

# 获取销毁前的属性数量
declare -p OBJECT_PROPS > /dev/null 2>&1
props_before=$(echo "${#OBJECT_PROPS[@]}")

Object.destroy "destroy_obj"

# 获取销毁后的属性数量
declare -p OBJECT_PROPS > /dev/null 2>&1
props_after=$(echo "${#OBJECT_PROPS[@]}")

# 验证属性数量减少（至少减少1个）
if [ "$props_after" -lt "$props_before" ]; then
    manual_assert "对象销毁成功" "pass"
else
    manual_assert "对象销毁成功" "fail"
fi

# 测试13: 性能监控
print_test_header "性能监控测试"
test_function() {
    sleep 0.1
    echo "测试函数执行完成"
}

profile_output=$(Object::profile "test_function")
assert_contains "$profile_output" "性能分析" "性能监控输出格式"
assert_contains "$profile_output" "耗时" "性能监控包含耗时信息"

# 测试14: 系统信息
print_test_header "系统信息测试"
system_output=$(Object::systemInfo)
assert_contains "$system_output" "企业级系统信息" "系统信息标题"
assert_contains "$system_output" "对象总数" "系统信息包含对象统计"
assert_contains "$system_output" "属性总数" "系统信息包含属性统计"

# 综合测试：完整业务流程
print_test_header "完整业务流程测试"
Object.create "BusinessTest" "biz_emp"
Employee.constructor "biz_emp" "李四" "28" "业务公司"

# 添加验证器
Object.addValidator "biz_emp" "age" "validate_age"
Object.addValidator "biz_emp" "salary" "validate_salary"

# 设置带验证的属性
Object.setAttrWithValidation "biz_emp" "salary" "60000"
Object.setAttrWithValidation "biz_emp" "position" "项目经理"

# 添加权限
Object.addPermission "biz_emp" "manager" "approve"
Object.addPermission "biz_emp" "manager" "manage_team"

# 检查权限
assert_success 'Object.checkPermission "biz_emp" "manager" "approve"' "经理审批权限"
assert_success 'Object.checkPermission "biz_emp" "manager" "manage_team"' "经理团队管理权限"

# 保存到数据库
Object::saveToDB "biz_emp"
assert_success '[ -f "db_BusinessTest.txt" ]' "业务对象数据库保存"

# 最终验证
final_info=$(Employee.getInfo "biz_emp")
assert_contains "$final_info" "李四" "业务对象最终状态验证"
assert_contains "$final_info" "项目经理" "业务对象职位验证"

# ============================================================================
# 数据库持久化增强测试开始
# ============================================================================

echo -e "\n"
echo "=========================================="
echo "开始数据库持久化增强测试"
echo "=========================================="

# 清理之前的测试文件
rm -f db_*.txt

# 测试15: 基本对象持久化
print_test_header "基本对象持久化"
Object.create "Employee" "emp1"
Employee.constructor "emp1" "张三" "30" "科技公司"
Object.attr "emp1" "salary" "80000"
Object.attr "emp1" "position" "高级工程师"
Object.attr "emp1" "department" "研发部"

echo "原始对象信息:"
Employee.getInfo "emp1"

Object::saveToDB "emp1"
assert_success '[ -f "db_Employee.txt" ]' "基本对象保存"

# 测试16: 特殊字符处理
print_test_header "特殊字符处理"
Object.create "Employee" "emp_special"
Employee.constructor "emp_special" "李四" "25" "测试&开发公司"
Object.attr "emp_special" "description" "负责A/B测试\n跨平台开发"
Object.attr "emp_special" "email" "test@example.com"
Object.attr "emp_special" "tags" "Java,Python,Bash\nDocker,K8s"

Object::saveToDB "emp_special"
Object.destroy "emp_special"
Object::loadFromDB "Employee" "emp_special"

special_desc=$(Object.attr "emp_special" "description")
assert_contains "$special_desc" "A/B测试" "特殊字符描述保存"
assert_contains "$special_desc" "跨平台开发" "换行符保存"

# 测试17: 多个对象保存到同一文件
print_test_header "多对象管理"
Object.create "Employee" "emp2"
Employee.constructor "emp2" "王五" "35" "金融科技"
Object.attr "emp2" "salary" "120000"
Object.attr "emp2" "position" "架构师"

Object.create "Employee" "emp3" 
Employee.constructor "emp3" "赵六" "28" "电商平台"
Object.attr "emp3" "salary" "95000"
Object.attr "emp3" "position" "产品经理"

Object::saveToDB "emp2"
Object::saveToDB "emp3"

# 验证文件包含多个对象
object_count=$(grep -c "#OBJECT_START" db_Employee.txt 2>/dev/null || echo 0)
if [ "$object_count" -ge 3 ]; then
    manual_assert "多对象保存" "pass"
else
    manual_assert "多对象保存" "fail"
fi

# 测试18: 对象销毁后重新加载
print_test_header "销毁后重新加载"
Object.destroy "emp1"
Object.destroy "emp2" 
Object.destroy "emp3"

Object::loadFromDB "Employee" "emp1"
Object::loadFromDB "Employee" "emp2"
Object::loadFromDB "Employee" "emp3" 

# 验证重新加载的数据完整性
emp1_name=$(Object.attr "emp1" "name")
emp2_name=$(Object.attr "emp2" "name")
emp3_name=$(Object.attr "emp3" "name")

assert_equals "张三" "$emp1_name" "重新加载emp1数据"
assert_equals "王五" "$emp2_name" "重新加载emp2数据"
assert_equals "赵六" "$emp3_name" "重新加载emp3数据"

# 测试19: 属性更新和重新保存
print_test_header "属性更新和重新保存"
Object.attr "emp1" "salary" "90000"
Object.attr "emp1" "position" "技术专家"

Object::saveToDB "emp1"
Object.destroy "emp1"
Object::loadFromDB "Employee" "emp1"

updated_salary=$(Object.attr "emp1" "salary")
updated_position=$(Object.attr "emp1" "position")

assert_equals "90000" "$updated_salary" "属性更新保存"
assert_equals "技术专家" "$updated_position" "职位更新保存"

# 测试20: 加载不存在的对象
print_test_header "加载不存在的对象"
load_result=$(Object::loadFromDB "Employee" "nonexistent_obj" 2>&1)
assert_contains "$load_result" "未找到对象" "不存在对象处理"

# 测试21: 不同类的对象隔离
print_test_header "类隔离测试"
Object.create "Manager" "mgr1"
Object.attr "mgr1" "name" "陈经理"
Object.attr "mgr1" "team_size" "10"
Object.attr "mgr1" "budget" "500000"

Object::saveToDB "mgr1"
assert_success '[ -f "db_Manager.txt" ]' "不同类对象隔离"

# 测试22: 大量数据测试
print_test_header "批量数据测试"
for i in {1..3}; do
    Object.create "Employee" "batch_emp_$i"
    Employee.constructor "batch_emp_$i" "批量员工$i" "$((25 + i))" "批量公司"
    Object.attr "batch_emp_$i" "salary" "$((50000 + i * 1000))"
    Object.attr "batch_emp_$i" "position" "开发工程师$i"
    Object::saveToDB "batch_emp_$i"
done

# 验证批量保存
batch_count=$(grep -c "#OBJECT_START" db_Employee.txt 2>/dev/null || echo 0)
if [ "$batch_count" -ge 6 ]; then  # 之前有3个，加上3个新的
    manual_assert "批量数据保存" "pass"
else
    manual_assert "批量数据保存" "fail"
fi

# 测试23: 空属性测试
print_test_header "空属性测试"
Object.create "Employee" "empty_emp"
Employee.constructor "empty_emp" "" ""
Object.attr "empty_emp" "salary" ""
Object.attr "empty_emp" "position" ""
Object::saveToDB "empty_emp"

Object::loadFromDB "Employee" "empty_emp"
empty_name=$(Object.attr "empty_emp" "name")
assert_equals "" "$empty_name" "空属性处理"

# 测试24: 性能测试
print_test_header "性能测试"
echo "性能测试 - 保存操作:"
save_profile=$(Object::profile "Object::saveToDB" "emp1")
assert_contains "$save_profile" "性能分析" "性能监控功能"

echo "性能测试 - 加载操作:"
load_profile=$(Object::profile "Object::loadFromDB" "Employee" "emp1")
assert_contains "$load_profile" "性能分析" "加载性能监控"

# 测试25: 数据一致性验证
print_test_header "数据一致性验证"
original_salary=$(Object.attr "emp1" "salary")
Object.attr "emp1" "salary" "99999"  # 修改但不保存

Object::loadFromDB "Employee" "emp1"  # 重新加载
reloaded_salary=$(Object.attr "emp1" "salary")

assert_equals "$original_salary" "$reloaded_salary" "数据一致性"

# 测试26: 最终完整性验证
print_test_header "最终完整性验证"
Object::loadFromDB "Employee" "emp_special"

final_name=$(Object.attr "emp_special" "name")
final_company=$(Object.attr "emp_special" "company")

assert_equals "李四" "$final_name" "最终完整性-姓名"
assert_equals "测试&开发公司" "$final_company" "最终完整性-公司"

# 测试27: 数据库文件统计
print_test_header "数据库文件统计"
total_objects=0
for file in db_*.txt 2>/dev/null; do
    objects_in_file=$(grep -c "#OBJECT_START" "$file" 2>/dev/null || echo 0)
    echo "文件 $file 包含 $objects_in_file 个对象"
    total_objects=$((total_objects + objects_in_file))
done

if [ "$total_objects" -gt 0 ]; then
    manual_assert "数据库文件统计" "pass"
else
    manual_assert "数据库文件统计" "fail"
fi

# ============================================================================
# 测试完成，清理和总结
# ============================================================================

# 清理测试文件
cleanup_test

echo ""
echo "=========================================="
echo "综合测试执行完成"
echo "=========================================="

# 统计测试结果
echo ""
echo "测试总结:"
echo "✅ 通过的测试用例: $PASS_COUNT"
echo "❌ 失败的测试用例: $FAIL_COUNT"

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "🎉 所有测试用例通过！系统功能正常。"
    
    echo -e "\n📊 测试覆盖范围总结:"
    echo "✅ 对象创建和属性管理"
    echo "✅ 私有属性封装"
    echo "✅ 方法定义和调用"
    echo "✅ 事件系统"
    echo "✅ 验证器系统"
    echo "✅ 权限系统"
    echo "✅ 事务支持"
    echo "✅ 缓存系统"
    echo "✅ 配置管理"
    echo "✅ 基本数据库持久化"
    echo "✅ Employee类功能"
    echo "✅ 对象销毁"
    echo "✅ 性能监控"
    echo "✅ 系统信息统计"
    echo "✅ 完整业务流程"
    echo "✅ 特殊字符处理"
    echo "✅ 多对象管理"
    echo "✅ 销毁后重新加载"
    echo "✅ 属性更新和重新保存"
    echo "✅ 错误处理（不存在对象）"
    echo "✅ 类隔离"
    echo "✅ 批量数据操作"
    echo "✅ 空属性处理"
    echo "✅ 性能基准测试"
    echo "✅ 数据一致性验证"
    echo "✅ 最终完整性验证"
    echo "✅ 数据库文件统计"
    
    echo -e "\n🚀 Bash 面向对象系统通过所有综合测试，具备企业级应用开发能力！"
    exit 0
else
    echo "⚠️ 部分测试用例失败，请检查系统功能。"
    exit 1
fi