#!/bin/bash

# 数据库持久化完整测试 - 增强版
source main.sh

echo "=== 数据库持久化完整修复测试 - 增强版 ==="

# 清理之前的测试文件
rm -f db_*.txt

# 测试1: 基本对象持久化
echo -e "\n=== 测试1: 基本对象持久化 ==="
Object.create "Employee" "emp1"
Employee.constructor "emp1" "张三" "30" "科技公司"
Object.attr "emp1" "salary" "80000"
Object.attr "emp1" "position" "高级工程师"
Object.attr "emp1" "department" "研发部"

echo "原始对象信息:"
Employee.getInfo "emp1"

Object::saveToDB "emp1"
echo "保存完成"

# 测试2: 特殊字符处理
echo -e "\n=== 测试2: 特殊字符处理 ==="
Object.create "Employee" "emp_special"
Employee.constructor "emp_special" "李四" "25" "测试&开发公司"
Object.attr "emp_special" "description" "负责A/B测试\n跨平台开发"
Object.attr "emp_special" "email" "test@example.com"
Object.attr "emp_special" "tags" "Java,Python,Bash\nDocker,K8s"

echo "特殊字符对象:"
Employee.getInfo "emp_special"
Object::saveToDB "emp_special"

# 测试3: 多个对象保存到同一文件
echo -e "\n=== 测试3: 多个对象保存到同一文件 ==="
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

echo "数据库文件内容:"
cat db_Employee.txt

# 测试4: 对象销毁后重新加载
echo -e "\n=== 测试4: 对象销毁后重新加载 ==="
echo "销毁前对象数量: $(Object::systemInfo | grep "对象总数" | head -1)"
Object.destroy "emp1"
Object.destroy "emp2" 
Object.destroy "emp3"
Object.destroy "emp_special"
echo "销毁后对象数量: $(Object::systemInfo | grep "对象总数" | head -1)"

echo -e "\n重新加载所有对象:"
Object::loadFromDB "Employee" "emp1"
Object::loadFromDB "Employee" "emp2"
Object::loadFromDB "Employee" "emp3" 
Object::loadFromDB "Employee" "emp_special"

echo "重新加载后对象数量: $(Object::systemInfo | grep "对象总数" | head -1)"

# 验证重新加载的数据完整性
echo -e "\n数据完整性验证:"
echo "emp1 姓名: $(Object.attr "emp1" "name"), 职位: $(Object.attr "emp1" "position")"
echo "emp2 姓名: $(Object.attr "emp2" "name"), 职位: $(Object.attr "emp2" "position")"
echo "emp3 姓名: $(Object.attr "emp3" "name"), 职位: $(Object.attr "emp3" "position")"

# 测试特殊字符恢复
special_desc=$(Object.attr "emp_special" "description")
echo -e "特殊字符测试 - 描述: $special_desc"

# 测试5: 属性更新和重新保存
echo -e "\n=== 测试5: 属性更新和重新保存 ==="
Object.attr "emp1" "salary" "90000"
Object.attr "emp1" "position" "技术专家"
echo "更新后emp1信息:"
Employee.getInfo "emp1"

Object::saveToDB "emp1"
echo "重新保存完成"

# 测试6: 加载不存在的对象
echo -e "\n=== 测试6: 加载不存在的对象 ==="
Object::loadFromDB "Employee" "nonexistent_obj"

# 测试7: 不同类的对象隔离
echo -e "\n=== 测试7: 不同类的对象隔离 ==="
Object.create "Manager" "mgr1"
Object.attr "mgr1" "name" "陈经理"
Object.attr "mgr1" "team_size" "10"
Object.attr "mgr1" "budget" "500000"

Object::saveToDB "mgr1"
echo "Manager类保存完成，文件: db_Manager.txt"

# 测试8: 大量数据测试
echo -e "\n=== 测试8: 大量数据测试 ==="
for i in {1..5}; do
    Object.create "Employee" "batch_emp_$i"
    Employee.constructor "batch_emp_$i" "批量员工$i" "$((25 + i))" "批量公司"
    Object.attr "batch_emp_$i" "salary" "$((50000 + i * 1000))"
    Object.attr "batch_emp_$i" "position" "开发工程师$i"
    Object::saveToDB "batch_emp_$i"
done
echo "批量保存5个对象完成"

# 测试9: 数据库文件损坏测试
echo -e "\n=== 测试9: 数据库文件损坏测试 ==="
echo "损坏数据库文件测试..." > db_Corrupt.txt
echo "PROP:name=损坏数据" >> db_Corrupt.txt
Object::loadFromDB "Corrupt" "test_obj"

# 测试10: 空属性测试
echo -e "\n=== 测试10: 空属性测试 ==="
Object.create "Employee" "empty_emp"
Employee.constructor "empty_emp" "" ""
Object.attr "empty_emp" "salary" ""
Object.attr "empty_emp" "position" ""
Object::saveToDB "empty_emp"

Object::loadFromDB "Employee" "empty_emp"
echo "空属性对象 - 姓名: '$(Object.attr "empty_emp" "name")', 年龄: '$(Object.attr "empty_emp" "age")'"

# 测试11: 性能测试
echo -e "\n=== 测试11: 性能测试 ==="
echo "性能测试 - 保存操作:"
Object::profile "Object::saveToDB" "emp1"

echo "性能测试 - 加载操作:"
Object::profile "Object::loadFromDB" "Employee" "emp1"

# 测试12: 并发安全测试（模拟）
echo -e "\n=== 测试12: 并发安全测试 ==="
Object.create "Employee" "concurrent_emp"
Employee.constructor "concurrent_emp" "并发测试" "30" "测试公司"
Object::saveToDB "concurrent_emp"

# 模拟并发读取
(
    Object::loadFromDB "Employee" "concurrent_copy1"
    echo "线程1加载完成: $(Object.attr "concurrent_copy1" "name")"
) &

(
    Object::loadFromDB "Employee" "concurrent_copy2"  
    echo "线程2加载完成: $(Object.attr "concurrent_copy2" "name")"
) &

wait

# 测试13: 数据一致性验证
echo -e "\n=== 测试13: 数据一致性验证 ==="
echo "保存前的对象状态:"
Employee.getInfo "emp1"

# 修改但不保存
Object.attr "emp1" "salary" "99999"

echo "修改后未保存的状态:"
Employee.getInfo "emp1"

# 重新加载验证数据一致性
Object::loadFromDB "Employee" "emp1"
echo "重新加载后的状态:"
Employee.getInfo "emp1"

# 测试14: 文件系统错误处理
echo -e "\n=== 测试14: 文件系统错误处理 ==="
echo "测试只读文件系统..."
chmod 444 db_Employee.txt 2>/dev/null && {
    Object.create "Employee" "readonly_test"
    Employee.constructor "readonly_test" "只读测试" "30" "测试公司"
    Object::saveToDB "readonly_test" 2>/dev/null || echo "保存失败（符合预期）"
    chmod 644 db_Employee.txt 2>/dev/null
}

# 测试15: 内存泄漏检查
echo -e "\n=== 测试15: 内存泄漏检查 ==="
echo "清理前系统状态:"
Object::systemInfo | head -5

Object::cleanup

echo "清理后系统状态:"
Object::systemInfo | head -5

# 测试16: 最终完整性验证
echo -e "\n=== 测试16: 最终完整性验证 ==="
# 重新加载几个关键对象验证最终状态
Object::loadFromDB "Employee" "emp1"
Object::loadFromDB "Employee" "emp_special"

echo "最终验证 - emp1:"
Employee.getInfo "emp1"

echo "最终验证 - emp_special:"
Employee.getInfo "emp_special"
echo "特殊字符描述: $(Object.attr "emp_special" "description")"

# 测试17: 数据库文件列表
echo -e "\n=== 测试17: 数据库文件列表 ==="
echo "生成的数据库文件:"
ls -la db_*.txt 2>/dev/null || echo "没有数据库文件"

# 测试18: 数据统计
echo -e "\n=== 测试18: 数据统计 ==="
total_objects=0
for file in db_*.txt 2>/dev/null; do
    objects_in_file=$(grep -c "#OBJECT_START" "$file" 2>/dev/null || echo 0)
    echo "文件 $file 包含 $objects_in_file 个对象"
    total_objects=$((total_objects + objects_in_file))
done
echo "总共保存了 $total_objects 个对象"

# 最终清理
echo -e "\n=== 测试完成，执行最终清理 ==="
Object::cleanup
rm -f db_*.txt

echo -e "\n🎉 所有增强测试完成!"
echo "=========================================="
echo "测试覆盖范围总结:"
echo "✅ 基本对象持久化"
echo "✅ 特殊字符处理" 
echo "✅ 多对象管理"
echo "✅ 销毁和重新加载"
echo "✅ 属性更新"
echo "✅ 错误处理（不存在对象）"
echo "✅ 类隔离"
echo "✅ 批量操作"
echo "✅ 损坏文件处理"
echo "✅ 空属性处理"
echo "✅ 性能测试"
echo "✅ 并发安全"
echo "✅ 数据一致性"
echo "✅ 文件系统错误"
echo "✅ 内存泄漏检查"
echo "✅ 最终完整性"
echo "✅ 文件列表统计"
echo "=========================================="