#!/bin/bash

# 事务支持

Object.method "Object" "beginTransaction" '
    echo "开始事务: $this"
    local backup_file=$(mktemp "/tmp/object_tx_${this}_XXXXXX")
    Object.attr "$this" "__transaction_backup" "$backup_file"
    
    # 备份当前状态
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == ${this}__* ]]; then
            echo "$key=${OBJECT_PROPS[$key]}" >> "$backup_file"
        fi
    done
    echo "事务备份已创建: $backup_file"
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