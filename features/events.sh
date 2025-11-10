#!/bin/bash

# 事件系统

Object.method "Object" "on" '
    local event="$1" handler="$2"
    local key="${this}__events__${event}"
    OBJECT_EVENTS["$key"]="${OBJECT_EVENTS[$key]} $handler"
    echo "注册事件处理器: $this -> $event"
'

Object.method "Object" "emit" '
    local event="$1"
    shift
    local key="${this}__events__${event}"
    local handlers="${OBJECT_EVENTS[$key]}"
    
    echo "触发事件: $event, 参数: $@"
    for handler in $handlers; do
        if type "$handler" &>/dev/null; then
            $handler "$this" "$event" "$@"
        fi
    done
'

Object.method "Object" "off" '
    local event="$1" handler="$2"
    local key="${this}__events__${event}"
    
    if [ -z "$handler" ]; then
        # 移除所有该事件的处理器
        unset OBJECT_EVENTS["$key"]
        echo "移除所有 $event 事件的处理器"
    else
        # 移除特定处理器
        local new_handlers=""
        for h in ${OBJECT_EVENTS[$key]}; do
            if [ "$h" != "$handler" ]; then
                new_handlers="$new_handlers $h"
            fi
        done
        OBJECT_EVENTS["$key"]="$new_handlers"
        echo "移除事件处理器: $event -> $handler"
    fi
'