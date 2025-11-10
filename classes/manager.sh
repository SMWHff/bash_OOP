#!/bin/bash

# Manager 类定义

Object.method "Manager" "constructor" '
    local name="$1" age="$2" company="$3" team_size="$4"
    Employee.constructor "$this" "$name" "$age" "$company"
    Object.attr "$this" "team_size" "$team_size"
    Object.attr "$this" "position" "经理"
    echo "经理构造函数: team_size=\"$team_size\""
    
    # 添加管理员权限
    Object.addPermission "$this" "manager" "read"
    Object.addPermission "$this" "manager" "write"
    Object.addPermission "$this" "manager" "approve"
'

Object.method "Manager" "getInfo" '
    local name=$(Object.attr "$this" "name")
    local company=$(Object.attr "$this" "company")
    local team_size=$(Object.attr "$this" "team_size")
    local position=$(Object.attr "$this" "position")
    echo "经理信息: 姓名=$name, 职位=$position, 公司=$company, 团队规模=$team_size"
'

Object.method "Manager" "manageTeam" '
    local name=$(Object.attr "$this" "name")
    local team_size=$(Object.attr "$this" "team_size")
    echo "$name 正在管理 $team_size 人的团队..."
'

Object.method "Manager" "approveRequest" '
    local request="$1"
    echo "经理 $(Object.attr "$this" "name") 批准了请求: $request"
'

Object.method "Manager" "conductMeeting" '
    local topic="$1"
    echo "经理 $(Object.attr "$this" "name") 正在主持关于 '$topic' 的会议"
    Object.emit "$this" "meeting" "$topic"
'