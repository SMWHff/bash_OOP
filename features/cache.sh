#!/bin/bash

# 缓存系统

Object.static "Object" "cacheSet" '
    local key="$1" value="$2" ttl="${3:-300}"
    local expire_time=$(( $(date +%s) + ttl ))
    OBJECT_CACHE["${key}__value"]="$value"
    OBJECT_CACHE["${key}__expire"]="$expire_time"
    echo "缓存设置: $key -> $value (TTL: ${ttl}s)"
'

Object.static "Object" "cacheGet" '
    local key="$1"
    local value="${OBJECT_CACHE[${key}__value]}"
    local expire="${OBJECT_CACHE[${key}__expire]}"
    local current_time=$(date +%s)
    
    if [ -n "$value" ] && [ "$current_time" -lt "$expire" ]; then
        echo "缓存命中: $key -> $value"
        echo "$value"
        return 0
    else
        echo "缓存未命中: $key"
        return 1
    fi
'

Object.static "Object" "cacheDelete" '
    local key="$1"
    unset OBJECT_CACHE["${key}__value"]
    unset OBJECT_CACHE["${key}__expire"]
    echo "缓存删除: $key"
'

Object.static "Object" "cacheClear" '
    OBJECT_CACHE=()
    echo "缓存已清空"
'