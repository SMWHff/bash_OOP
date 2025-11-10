#!/bin/bash

# 配置管理系统

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

Object.static "Object" "setConfig" '
    local key="$1" value="$2"
    OBJECT_PROPS["config__${key}"]="$value"
    echo "设置配置: $key = $value"
'

Object.static "Object" "listConfig" '
    echo "=== 系统配置 ==="
    for key in "${!OBJECT_PROPS[@]}"; do
        if [[ "$key" == config__* ]]; then
            local config_key="${key#config__}"
            echo "$config_key = ${OBJECT_PROPS[$key]}"
        fi
    done
'

Object.static "Object" "exportConfig" '
    local config_file="$1"
    {
        echo "# 自动生成的配置文件"
        echo "# 导出时间: $(date)"
        for key in "${!OBJECT_PROPS[@]}"; do
            if [[ "$key" == config__* ]]; then
                local config_key="${key#config__}"
                echo "${config_key}=${OBJECT_PROPS[$key]}"
            fi
        done
    } > "$config_file"
    echo "配置已导出到: $config_file"
'