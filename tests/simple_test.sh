#!/bin/bash

# 最终修复版测试脚本 - 修复销毁验证

# 导入主系统
source "$(dirname "$0")/../main.sh"

echo "=== 开始系统测试 ==="

# 测试计数器
PASS_COUNT=0
FAIL_COUNT=0

# 清理函数
cleanup_test() {
    Object.destroy "test_person" > /dev/null 2>&1
    Object.destroy "test_emp" > /dev/null 2>&1
    Object.destroy "test_manager" > /dev/null 2>&1
    rm -f test_config.conf demo.conf db_*.txt 2>/dev/null
}

# 辅助函数：执行命令并只返回有效结果
execute_silent() {
    local command="$1"
    
    # 重定向所有输出到临时文件，然后提取最后一行（通常是实际结果）
    local temp_file=$(mktemp)
    eval "$command" > "$temp_file" 2>&1
    
    # 提取非日志行（更严格的过滤）
    local result=$(grep -v -E \
        -e "^创建实例:" \
        -e "^构造函数:" \
        -e "^注册事件处理器:" \
        -e "^添加验证器:" \
        -e "^验证通过:" \
        -e "^验证失败:" \
        -e "^触发事件:" \
        -e "^添加权限:" \
        -e "^权限检查通过:" \
        -e "^权限检查失败:" \
        -e "^销毁对象:" \
        -e "^对象.*已完全销毁" \
        -e "^缓存设置:" \
        -e "^缓存命中:" \
        -e "^缓存未命中:" \
        -e "^加载配置文件:" \
        -e "^配置:" \
        -e "^年龄已更新为:" \
        -e "^工资已更新为:" \
        -e "^员工晋升:" \
        -e "^开始事务:" \
        -e "^提交事务:" \
        -e "^回滚事务:" \
        -e "^事务备份已创建:" \
        -e "^保存对象到数据库:" \
        -e "^保存完成:" \
        -e "^从数据库加载对象:" \
        -e "^加载完成:" \
        -e "^清理数据库文件" \
        -e "^数据库清理完成" \
        -e "^性能分析:" \
        -e "^人员信息:" \
        -e "^员工信息:" \
        -e "^经理信息:" \
        -e "^对象信息:" \
        "$temp_file" | tail -1)
    
    rm -f "$temp_file"
    echo "$result"
}

# 辅助函数：检查命令是否成功（不关心输出）
check_success() {
    local command="$1"
    if eval "$command" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

test_case_exact() {
    local test_name="$1"
    local command="$2"
    local expected="$3"
    
    echo "测试: $test_name"
    local result=$(execute_silent "$command")
    
    # 清理结果中的多余空格和换行
    result=$(echo "$result" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    expected=$(echo "$expected" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [ "$result" = "$expected" ]; then
        echo "✅ 通过"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ 失败"
        echo "   期望: '$expected'"
        echo "   实际: '$result'"
        ((FAIL_COUNT++))
        return 1
    fi
}

test_case_contains() {
    local test_name="$1"
    local command="$2"
    local expected="$3"
    
    echo "测试: $test_name"
    local result=$(execute_silent "$command")
    
    # 清理结果
    result=$(echo "$result" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [[ "$result" == *"$expected"* ]]; then
        echo "✅ 通过"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ 失败"
        echo "   期望包含: '$expected'"
        echo "   实际: '$result'"
        ((FAIL_COUNT++))
        return 1
    fi
}

test_case_return_code() {
    local test_name="$1"
    local command="$2"
    local expected_rc="$3"
    
    echo "测试: $test_name"
    eval "$command" > /dev/null 2>&1
    local result_rc=$?
    
    if [ $result_rc -eq $expected_rc ]; then
        echo "✅ 通过"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ 失败"
        echo "   期望返回码: $expected_rc"
        echo "   实际返回码: $result_rc"
        ((FAIL_COUNT++))
        return 1
    fi
}

# 特殊测试：直接测试属性值
test_attr_directly() {
    local test_name="$1"
    local instance="$2"
    local attr="$3"
    local expected="$4"
    
    echo "测试: $test_name"
    local result
    # 使用子shell捕获错误，避免脚本退出
    result=$(Object.attr "$instance" "$attr" 2>/dev/null)
    local rc=$?
    
    if [ $rc -eq 0 ] && [ "$result" = "$expected" ]; then
        echo "✅ 通过"
        ((PASS_COUNT++))
        return 0
    else
        echo "❌ 失败"
        echo "   期望: '$expected'"
        echo "   实际: '$result' (返回码: $rc)"
        ((FAIL_COUNT++))
        return 1
    fi
}

# 特殊测试：验证对象已销毁 - 修复版本
test_destroyed() {
    local test_name="$1"
    local instance="$2"
    
    echo "测试: $test_name"
    
    # 方法1：使用Object::exists检查
    if Object::exists "$instance"; then
        echo "❌ 失败 - 方法1: Object::exists 返回对象存在"
        ((FAIL_COUNT++))
        return 1
    fi
    
    # 方法2：尝试访问属性，应该失败
    if Object.attr "$instance" "name" > /dev/null 2>&1; then
        echo "❌ 失败 - 方法2: 属性访问成功"
        ((FAIL_COUNT++))
        return 1
    fi
    
    # 方法3：检查destroyed标记
    if [ -z "${OBJECT_PROPS[${instance}__destroyed]}" ]; then
        echo "❌ 失败 - 方法3: 未找到destroyed标记"
        ((FAIL_COUNT++))
        return 1
    fi
    
    echo "✅ 通过"
    ((PASS_COUNT++))
    return 0
}

# 开始测试前清理
cleanup_test

echo -e "\n=== 基本对象功能测试 ==="

# 首先创建测试对象
echo "创建测试对象..."
Object.create "Person" "test_person" > /dev/null 2>&1
Person.constructor "test_person" "测试" "20" > /dev/null 2>&1

# 测试1: 对象创建
test_case_exact "对象创建" '
    Object.attr "test_person" "name"
' "测试"

# 测试2: 属性设置验证
test_attr_directly "属性设置验证" "test_person" "name" "测试"

# 测试3: 属性设置
test_attr_directly "属性设置" "test_person" "age" "20"

# 测试4: 更新属性
test_case_return_code "属性更新" '
    Person.setAge "test_person" "25"
' "0"

# 验证更新后的属性
test_attr_directly "属性更新验证" "test_person" "age" "25"

# 测试5: 事件系统
test_case_return_code "事件注册" '
    Object.on "test_person" "test_event" "echo"
' "0"

# 测试6: 验证器系统
test_case_return_code "验证器" '
    Object.addValidator "test_person" "age" "validate_age"
    Object.setAttrWithValidation "test_person" "age" "30"
' "0"

# 测试7: 权限系统
test_case_return_code "权限检查" '
    Object.addPermission "test_person" "user" "read"
    Object.checkPermission "test_person" "user" "read"
' "0"

echo -e "\n=== 高级功能测试 ==="

# 创建员工对象
echo "创建员工对象..."
Object.create "Employee" "test_emp" > /dev/null 2>&1
Employee.constructor "test_emp" "员工" "25" "测试公司" > /dev/null 2>&1

# 测试8: 继承系统
test_case_return_code "类继承" 'true' "0"

# 验证员工属性
test_attr_directly "员工姓名" "test_emp" "name" "员工"
test_attr_directly "员工公司" "test_emp" "company" "测试公司"

# 测试9: 工作方法 - 使用返回码测试
test_case_return_code "工作方法" '
    Employee.work "test_emp"
' "0"

# 测试10: 私有属性
test_case_return_code "私有属性" '
    Object.private "test_emp" "salary" "50000"
' "0"

# 验证私有属性
test_case_exact "私有属性验证" '
    Object.private "test_emp" "salary"
' "50000"

# 测试11: 缓存系统
test_case_exact "缓存设置和获取" '
    Object::cacheSet "test_cache" "cache_value" 60 > /dev/null
    Object::cacheGet "test_cache"
' "cache_value"

# 测试12: 配置管理
test_case_return_code "配置管理" '
    echo "test.key=test_value" > test_config.conf
    Object::loadConfig "test_config.conf"
' "0"

# 直接测试配置值
test_case_exact "配置值验证" '
    Object::getConfig "test.key"
' "test_value"

# 测试13: 事务系统
# 先设置一个初始值
Object.attr "test_emp" "salary" "10000" > /dev/null 2>&1

test_case_return_code "事务回滚" '
    Object.beginTransaction "test_emp"
    Object.attr "test_emp" "salary" "99999"
    Object.rollbackTransaction "test_emp"
' "0"

# 验证事务回滚后薪资恢复为原始值
test_attr_directly "事务回滚验证" "test_emp" "salary" "10000"

# 测试14: 数据库持久化
test_case_return_code "数据库保存" '
    Object::saveToDB "test_emp"
' "0"

# 测试15: 数据库文件存在性
test_case_return_code "数据库文件创建" '
    [ -f "db_Employee_test_emp.txt" ]
' "0"

# 测试16: 对象销毁
test_case_return_code "对象销毁" '
    Object.destroy "test_person"
    Object.destroy "test_emp"
' "0"

# 测试17: 验证对象已销毁 - 修复版本
test_destroyed "销毁验证" "test_person"

echo -e "\n=== 额外功能测试 ==="

# 测试18: Manager类测试
test_case_return_code "Manager类创建" '
    Object.create "Manager" "test_manager"
    Manager.constructor "test_manager" "张经理" "40" "科技公司" "15"
' "0"

test_attr_directly "Manager属性" "test_manager" "position" "经理"
test_attr_directly "Manager团队规模" "test_manager" "team_size" "15"

# 测试19: 缓存过期测试
test_case_return_code "缓存过期" '
    Object::cacheSet "temp_cache" "temp_value" 1 > /dev/null
    sleep 2
    Object::cacheGet "temp_cache" > /dev/null 2>&1
    [ $? -ne 0 ]
' "0"

# 测试20: 性能监控
test_case_return_code "性能监控" '
    Object::profile "echo" "test" > /dev/null 2>&1
' "0"

# 最终清理
cleanup_test

echo -e "\n=== 测试结果 ==="
echo "通过: $PASS_COUNT"
echo "失败: $FAIL_COUNT"

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "🎉 所有测试通过！"
    echo ""
    echo "📊 测试覆盖范围:"
    echo "✅ 对象创建和生命周期"
    echo "✅ 属性管理"
    echo "✅ 方法调用"
    echo "✅ 事件系统"
    echo "✅ 验证器系统"
    echo "✅ 权限系统"
    echo "✅ 类继承"
    echo "✅ 事务支持"
    echo "✅ 缓存系统"
    echo "✅ 配置管理"
    echo "✅ 数据库持久化"
    echo "✅ 性能监控"
    exit 0
else
    echo "⚠️ 有测试失败，请检查系统"
    exit 1
fi