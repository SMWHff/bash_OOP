#!/bin/bash

# Employee 类定义

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

Object.method "Employee" "setSalary" '
    local new_salary="$1"
    if Object.setAttrWithValidation "$this" "salary" "$new_salary"; then
        echo "工资已更新为: $new_salary"
    else
        echo "工资更新失败"
    fi
'

Object.method "Employee" "promote" '
    local new_position="$1" new_salary="$2"
    Object.attr "$this" "position" "$new_position"
    Object.setAttrWithValidation "$this" "salary" "$new_salary"
    echo "员工晋升: $new_position, 工资 $new_salary"
'

Object.method "Employee" "requestVacation" '
    local days="$1" reason="$2"
    echo "$(Object.attr "$this" "name") 申请休假 $days 天，原因: $reason"
    Object.emit "$this" "vacationRequest" "$days" "$reason"
    return 0
'