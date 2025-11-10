#!/bin/bash

# 数据库持久化

Object.static "Object" "saveToDB" '
    local instance="$1"
    local class=$(Object.attr "$instance" "class")
    local id=$(Object.attr "$instance" "id")
    
    echo "保存对象到数据库: $instance (类: $class, ID: $id)"
    
    local db_file="db_${class}_${instance}.txt"
    
    # 保存对象数据
    {
        echo "#OBJECT_START $instance $(date "+%Y-%m-%d %H:%M:%S")"
        for key in "${!OBJECT_PROPS[@]}"; do
            if [[ "$key" == ${instance}__* ]]; then
                local prop_name="${key#${instance}__}"
                # 跳过系统属性
                if [[ "$prop_name" != "class" && "$prop_name" != "created" && "$prop_name" != "id" && "$prop_name" != "__transaction_backup" && "$prop_name" != "destroyed" ]]; then
                    local value="${OBJECT_PROPS[$key]}"
                    # 增强特殊字符编码
                    value="${value//$'\n'/\\\\n}"
                    value="${value//$'\r'/\\\\r}"
                    value="${value//$'='/\\\\=}"
                    value="${value//$'\&'/\\\\&}"
                    value="${value//$'\|'/\\\\|}"
                    echo "PROP:${prop_name}=${value}"
                fi
            fi
        done
        echo "#OBJECT_END $instance"
    } > "$db_file"
    
    echo "保存完成: $db_file"
'

Object.static "Object" "loadFromDB" '
    local class="$1" instance="$2"
    local db_file="db_${class}_${instance}.txt"
    
    if [ ! -f "$db_file" ]; then
        echo "错误: 数据库文件不存在: $db_file"
        return 1
    fi
    
    echo "从数据库加载对象: $instance (类: $class)"
    Object.create "$class" "$instance"
    
    local in_object=0
    local current_instance=""
    
    while IFS= read -r line; do
        # 检查对象开始标记
        if [[ "$line" == "#OBJECT_START $instance "* ]]; then
            in_object=1
            current_instance="$instance"
            continue
        fi
        
        # 检查对象结束标记
        if [[ "$line" == "#OBJECT_END $instance" ]]; then
            break
        fi
        
        # 处理属性行
        if [ "$in_object" -eq 1 ] && [[ "$line" == PROP:* ]]; then
            local prop_line="${line#PROP:}"
            local prop_name="${prop_line%%=*}"
            local value="${prop_line#*=}"
            # 解码特殊字符
            value="${value//\\n/$'\n'}"
            value="${value//\\r/$'\r'}"
            value="${value//\\=/$'='}"
            
            Object.attr "$instance" "$prop_name" "$value"
            echo "加载属性: $prop_name = $value"
        fi
    done < "$db_file"
    
    if [ "$in_object" -eq 0 ]; then
        echo "警告: 在数据库中未找到对象 $instance 的数据"
        return 1
    else
        echo "加载完成: $instance"
        return 0
    fi
'

Object.static "Object" "listDBObjects" '
    local class="$1"
    echo "=== 数据库中的 $class 对象 ==="
    for file in db_${class}_*.txt; do
        if [ -e "$file" ]; then
            local instance=$(basename "$file" .txt | sed "s/db_${class}_//")
            echo "对象: $instance, 文件: $file"
        fi
    done
'

Object.static "Object" "cleanupDB" '
    echo "清理数据库文件..."
    rm -f db_*.txt 2>/dev/null
    echo "数据库清理完成"
'