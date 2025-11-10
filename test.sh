#!/bin/bash

# 数据库持久化完整测试
source main.sh

echo "=== 数据库持久化完整修复测试 ==="

# 创建测试对象
Object.create "Employee" "test_emp"
Employee.constructor "test_emp" "测试员工" "28" "测试公司"
Object.attr "test_emp" "salary" "50000"
Object.attr "test_emp" "position" "测试工程师"

echo -e "\n原始对象信息:"
Employee.getInfo "test_emp"

echo -e "\n保存到数据库:"
Object::saveToDB "test_emp"

echo -e "\n查看数据库文件内容:"
cat db_Employee.txt

echo -e "\n销毁内存中的对象:"
Object.destroy "test_emp"

echo -e "\n从数据库重新加载:"
Object::loadFromDB "Employee" "test_emp"

echo -e "\n重新加载后的对象信息:"
Employee.getInfo "test_emp"

echo -e "\n验证数据完整性:"
echo "姓名: $(Object.attr "test_emp" "name")"
echo "年龄: $(Object.attr "test_emp" "age")"
echo "公司: $(Object.attr "test_emp" "company")"
echo "职位: $(Object.attr "test_emp" "position")"
echo "工资: $(Object.attr "test_emp" "salary")"

# 清理
Object::cleanup
echo -e "\n测试完成!"