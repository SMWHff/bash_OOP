#!/bin/bash

# Bash OOP Framework 测试运行器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 测试统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 打印结果
print_result() {
    local test_name=$1
    local status=$2
    local message=$3
    
    case $status in
        "PASS")
            echo -e "${GREEN}✓ PASS${NC} $test_name"
            ((PASSED_TESTS++))
            ;;
        "FAIL")
            echo -e "${RED}✗ FAIL${NC} $test_name: $message"
            ((FAILED_TESTS++))
            ;;
        "SKIP")
            echo -e "${YELLOW}⚠ SKIP${NC} $test_name"
            ;;
    esac
    ((TOTAL_TESTS++))
}

# 断言函数
assert_equal() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [ "$expected" = "$actual" ]; then
        print_result "$test_name" "PASS"
    else
        print_result "$test_name" "FAIL" "Expected: '$expected', Got: '$actual'"
    fi
}

# 运行核心测试
run_basic_tests() {
    echo "运行基础功能测试..."
    
    # 测试框架加载
    if source "../src/framework.sh"; then
        print_result "框架加载" "PASS"
    else
        print_result "框架加载" "FAIL" "无法加载框架"
        return 1
    fi
    
    # 测试框架初始化
    if framework_init; then
        print_result "框架初始化" "PASS"
    else
        print_result "框架初始化" "FAIL" "初始化失败"
    fi
}

# 运行所有测试
run_all_tests() {
    echo "🚀 运行 Bash OOP Framework 测试套件"
    echo "======================================"
    
    run_basic_tests
    
    # 显示结果
    echo
    echo "======================================"
    echo "测试完成:"
    echo -e "${GREEN}通过: $PASSED_TESTS${NC}"
    echo -e "${RED}失败: $FAILED_TESTS${NC}"
    echo -e "总计: $TOTAL_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 所有测试通过！${NC}"
        return 0
    else
        echo -e "${RED}❌ 有测试失败！${NC}"
        return 1
    fi
}

# 主执行
main() {
    # 创建测试报告目录
    mkdir -p test-reports
    
    # 运行测试
    if run_all_tests; then
        exit 0
    else
        exit 1
    fi
}

# 如果直接执行，运行测试
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
