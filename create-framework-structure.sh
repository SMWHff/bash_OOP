#!/bin/bash

# Bash OOP Framework 目录结构生成器
# 用法: ./create-framework-structure.sh [项目名称] [目标目录]

set -e  # 遇到错误退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 参数处理
PROJECT_NAME="${1:-bash-oop-framework}"
TARGET_DIR="${2:-./${PROJECT_NAME}}"

# 框架版本
FRAMEWORK_VERSION="1.0.0"
CURRENT_YEAR=$(date +%Y)

# 打印彩色输出
log_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

log_success() {
    echo -e "${GREEN}✓ ${NC}$1"
}

log_warning() {
    echo -e "${YELLOW}⚠ ${NC}$1"
}

log_error() {
    echo -e "${RED}✗ ${NC}$1"
}

log_step() {
    echo -e "${PURPLE}→${NC} $1"
}

# 检查创建脚本依赖
check_creation_dependencies() {
    log_step "检查系统依赖..."
    
    local deps=("bash" "mkdir" "cat" "date" "chmod")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_error "缺少依赖: $dep"
            return 1
        fi
    done
    
    # 检查 Bash 版本
    local bash_version
    bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    if [ "$(printf '%s\n' "4.0.0" "$bash_version" | sort -V | head -n1)" = "4.0.0" ]; then
        log_success "Bash 版本: $bash_version"
    else
        log_error "需要 Bash 4.0 或更高版本，当前版本: $bash_version"
        return 1
    fi
    
    return 0
}

# 创建目录结构
create_directory_structure() {
    log_step "创建项目目录结构..."

    # 根目录
    mkdir -p "$TARGET_DIR"

    # 主要目录
    local dirs=(
        ".github/workflows"
        ".github/ISSUE_TEMPLATE"
        "docs/images"
        "src/core"
        "src/patterns"
        "src/enterprise"
        "examples/basic"
        "examples/patterns"
        "examples/enterprise"
        "examples/real-world"
        "tests/unit"
        "tests/integration"
        "tests/performance"
        "benchmarks"
        "scripts"
        "templates"
        "dist"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$TARGET_DIR/$dir"
        log_success "创建目录: $dir"
    done
}

# 创建许可证文件
create_license() {
    log_step "创建许可证文件..."
    
    cat > "$TARGET_DIR/LICENSE" << LICENSE_EOF
MIT License

Copyright (c) $CURRENT_YEAR $PROJECT_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE_EOF
    log_success "创建 LICENSE"
}

# 创建 README 文件
create_readme() {
    log_step "创建 README.md..."
    
    cat > "$TARGET_DIR/README.md" << README_EOF
# $PROJECT_NAME

[![Build Status](https://github.com/your-username/$PROJECT_NAME/workflows/Tests/badge.svg)](https://github.com/your-username/$PROJECT_NAME/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-$FRAMEWORK_VERSION-green.svg)](src/framework.sh)

一个功能完整的 Bash 面向对象编程框架，提供企业级开发能力。

## ✨ 特性

- 🏗️ 完整的面向对象支持（类、对象、继承、多态）
- 🎯 多种设计模式实现（单例、观察者、工厂等）
- 🏢 企业级功能（事件系统、权限控制、事务支持）
- 📊 性能监控和内存管理
- 💾 数据持久化和缓存系统
- 🔧 模块化架构，易于扩展

## 🚀 快速开始

### 安装

\`\`\`bash
# 使用安装脚本
curl -fsSL https://raw.githubusercontent.com/your-username/$PROJECT_NAME/main/scripts/install.sh | bash

# 或手动安装
git clone https://github.com/your-username/$PROJECT_NAME.git
cd $PROJECT_NAME
./scripts/install.sh
\`\`\`

### 基础用法

\`\`\`bash
#!/bin/bash

# 加载框架
source "$PROJECT_NAME/src/framework.sh"

# 创建类
Object.create "Person" "person1"
Person.constructor "person1" "张三" 25
Person.greet "person1"
\`\`\`

## 📖 文档

- [快速开始](docs/getting-started.md)
- [API 参考](docs/api-reference.md)
- [设计模式](docs/design-patterns.md)
- [最佳实践](docs/best-practices.md)

## 🛠️ 开发

### 运行测试

\`\`\`bash
./tests/test-runner.sh
\`\`\`

### 构建项目

\`\`\`bash
./scripts/build.sh
\`\`\`

## 🤝 贡献

欢迎贡献！请阅读 [贡献指南](CONTRIBUTING.md) 开始。

## 📄 许可证

本项目基于 [MIT 许可证](LICENSE) 开源。

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！
README_EOF
    log_success "创建 README.md"
}

# 创建贡献指南
create_contributing() {
    log_step "创建贡献指南..."
    
    cat > "$TARGET_DIR/CONTRIBUTING.md" << CONTRIBUTING_EOF
# 贡献指南

感谢您考虑为 $PROJECT_NAME 做出贡献！

## 如何贡献

### 报告 Bug

1. 在 [GitHub Issues](https://github.com/your-username/$PROJECT_NAME/issues) 搜索是否已有相关 issue
2. 如果没有，创建新的 issue，包含：
   - 清晰的描述
   - 复现步骤
   - 期望行为 vs 实际行为
   - 环境信息

### 提交功能请求

1. 在 Issues 中搜索是否已有相关请求
2. 创建新的 issue，描述：
   - 解决的问题
   - 建议的解决方案
   - 替代方案考虑

### 代码贡献

1. Fork 项目
2. 创建功能分支 (\`git checkout -b feature/amazing-feature\`)
3. 提交更改 (\`git commit -m 'Add amazing feature'\`)
4. 推送到分支 (\`git push origin feature/amazing-feature\`)
5. 创建 Pull Request

## 开发环境设置

\`\`\`bash
# 克隆项目
git clone https://github.com/your-username/$PROJECT_NAME.git
cd $PROJECT_NAME

# 运行测试确保环境正常
./tests/test-runner.sh
\`\`\`

## 代码规范

- 使用 4 空格缩进
- 函数名使用 PascalCase（类）和 camelCase（方法）
- 变量名使用 snake_case
- 添加适当的注释
- 编写单元测试

## 提交信息规范

使用约定式提交：

- feat: 新功能
- fix: 修复 bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 代码重构
- test: 测试相关
- chore: 构建过程或辅助工具变动

## 测试要求

所有代码更改必须包含相应的测试：

\`\`\`bash
# 运行所有测试
./tests/test-runner.sh

# 运行特定测试
./tests/unit/test_core.sh
\`\`\`

## Pull Request 流程

1. 确保所有测试通过
2. 更新相关文档
3. 添加更改日志条目
4. 获取代码审查
5. 合并到主分支
CONTRIBUTING_EOF
    log_success "创建 CONTRIBUTING.md"
}

# 创建行为准则
create_code_of_conduct() {
    log_step "创建行为准则..."
    
    cat > "$TARGET_DIR/CODE_OF_CONDUCT.md" << COC_EOF
# 贡献者公约行为准则

## 我们的承诺

为了营造一个开放和受欢迎的环境，我们作为贡献者和维护者承诺：无论年龄、体型、身体健全与否、民族、性征、性别认同与表达、经验水平、教育程度、社会地位、国籍、相貌、种族、宗教信仰、性取向，我们参与项目和社区的每个人皆免于骚扰。

## 我们的标准

有助于创造积极环境的行为包括但不限于：

* 使用欢迎和包容的语言
* 尊重不同的观点和经验
* 耐心接受建设性批评
* 关注对社区最有利的事情
* 对其他社区成员友善

参与者不可接受的行为包括但不限于：

* 使用与性有关的言语或是图像，以及不受欢迎的性关注
* 捣乱/煽动/贬损的评论，人身攻击及政治攻击
* 公开或私下的骚扰
* 未经许可公布他人的资料，如住址、电子邮箱等
* 其他有理由认定为违反职业操守的不当行为

## 我们的责任

项目维护者有责任为「可接受的行为」标准做出诠释，并对已发生的不当行为采取恰当且公平的纠正措施。

项目维护者有权利及责任去删除、编辑、拒绝与本行为准则不相符的评论、提交、代码、wiki 编辑、问题等贡献。项目维护者可暂时或永久性的封禁任何他们认为行为不当、威胁、冒犯、有害的参与者。

## 适用范围

本行为准则适用于所有项目空间，以及个人在公共空间代表项目或社区时。代表项目或社区的情形包括但不限于：使用项目官方电子邮件地址、通过官方社交媒体账号发言、作为指定代表参与在线或线下活动。

## 贯彻落实

可以致信 [项目邮箱] 向项目团队举报滥用、骚扰及不当行为。

维护团队将审议并调查所有投诉，并以其认为恰当的方式予以回应。项目团队有义务保密举报者资料。具体执行方针更多细节可能会单独发布。

## 来源

本行为准则改编自[贡献者公约][homepage] 1.4 版，可在此查看：
https://www.contributor-covenant.org/zh-cn/version/1/4/code-of-conduct.html

[homepage]: https://www.contributor-covenant.org
COC_EOF
    log_success "创建 CODE_OF_CONDUCT.md"
}

# 创建变更日志
create_changelog() {
    log_step "创建变更日志..."
    
    cat > "$TARGET_DIR/CHANGELOG.md" << CHANGELOG_EOF
# 变更日志

所有对 $PROJECT_NAME 的显著更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/spec/v2.0.0.html)。

## [未发布]

### Added
- 项目初始结构和基础功能

## [$FRAMEWORK_VERSION] - $(date +%Y-%m-%d)

### Added
- 完整的面向对象系统
- 多种设计模式实现
- 企业级功能模块
- 完整的文档和示例
CHANGELOG_EOF
    log_success "创建 CHANGELOG.md"
}

# 创建 GitHub 工作流
create_github_workflows() {
    log_step "创建 GitHub 工作流..."
    
    # 测试工作流
    cat > "$TARGET_DIR/.github/workflows/tests.yml" << TESTS_WORKFLOW_EOF
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run tests
      run: |
        chmod +x tests/test-runner.sh
        ./tests/test-runner.sh
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: test-reports/
  
  lint:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: ShellCheck
      uses: ludeeus/action-shellcheck@master
      with:
        check_together: 'true'
TESTS_WORKFLOW_EOF

    # 发布工作流
    cat > "$TARGET_DIR/.github/workflows/release.yml" << RELEASE_WORKFLOW_EOF
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build project
      run: |
        chmod +x scripts/build.sh
        ./scripts/build.sh
    
    - name: Create Release
      uses: softprops/action-gh-release@v1
      with:
        files: dist/*
        generate_release_notes: true
      env:
        GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
RELEASE_WORKFLOW_EOF
    log_success "创建 GitHub 工作流"
}

# 创建 Issue 模板
create_issue_templates() {
    log_step "创建 Issue 模板..."
    
    # Bug 报告模板
    cat > "$TARGET_DIR/.github/ISSUE_TEMPLATE/bug_report.md" << BUG_REPORT_EOF
---
name: Bug 报告
about: 报告框架中的 bug
title: '[BUG] '
labels: bug
assignees: ''

---

**Bug 描述**
清晰简洁地描述 bug 是什么。

**复现步骤**
复现行为的步骤：
1. 设置环境 '...'
2. 执行命令 '....'
3. 看到错误 '....'

**期望行为**
清晰简洁地描述你期望发生什么。

**截图**
如果适用，添加截图以帮助解释您的问题。

**环境信息:**
 - OS: [例如 Ubuntu 20.04, macOS 11.0]
 - Bash 版本: [例如 5.0.17]
 - 框架版本: [例如 $FRAMEWORK_VERSION]

**附加信息**
添加有关问题的任何其他上下文。
BUG_REPORT_EOF

    # 功能请求模板
    cat > "$TARGET_DIR/.github/ISSUE_TEMPLATE/feature_request.md" << FEATURE_REQUEST_EOF
---
name: 功能请求
about: 为这个项目提出一个想法
title: '[FEATURE] '
labels: enhancement
assignees: ''

---

**您的功能请求是否与问题相关？请描述。**
清晰简洁地描述问题是什么。例如：当 [...] 时，我总是感到沮丧

**描述您想要的解决方案**
清晰简洁地描述您想要发生什么。

**描述您考虑过的替代方案**
清晰简洁地描述任何替代解决方案或功能您已经考虑过。

**附加信息**
添加有关功能请求的任何其他上下文或截图。
FEATURE_REQUEST_EOF
    log_success "创建 Issue 模板"
}

# 创建源代码文件
create_source_code() {
    log_step "创建源代码框架..."
    
    # 框架主入口
    cat > "$TARGET_DIR/src/framework.sh" << 'FRAMEWORK_MAIN_EOF'
#!/bin/bash

# Bash OOP Framework 主入口文件
# 版本: 1.0.0

set -e

# 框架配置
FRAMEWORK_NAME="Bash OOP Framework"
FRAMEWORK_VERSION="1.0.0"
FRAMEWORK_AUTHOR="Bash OOP Framework Team"

# 框架根目录
if [ -z "$BASH_OOP_ROOT" ]; then
    export BASH_OOP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_debug() {
    if [ "${BASH_OOP_DEBUG:-false}" = "true" ]; then
        echo -e "${BLUE}🔍 [DEBUG]${NC} $1" >&2
    fi
}

log_info() {
    echo -e "${BLUE}ℹ [INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠ [WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1" >&2
}

# 检查依赖
check_dependency() {
    local cmd=$1
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Missing dependency: $cmd"
        return 1
    fi
    log_debug "Dependency check passed: $cmd"
    return 0
}

# 验证类名
validate_class_name() {
    local class_name=$1
    if [[ ! "$class_name" =~ ^[A-Z][a-zA-Z0-9_]*$ ]]; then
        log_error "Invalid class name: $class_name (must start with uppercase letter)"
        return 1
    fi
    return 0
}

# 验证实例名
validate_instance_name() {
    local instance_name=$1
    if [[ ! "$instance_name" =~ ^[a-z][a-zA-Z0-9_]*$ ]]; then
        log_error "Invalid instance name: $instance_name (must start with lowercase letter)"
        return 1
    fi
    return 0
}

# 全局存储
declare -gA OBJECT_PROPS
declare -gA OBJECT_PRIVATE
declare -gA CLASS_METHODS

# Object 基类
Object() {
    : # 基类定义
}

# 创建实例
Object.create() {
    local class="$1" instance="$2"
    
    if ! validate_class_name "$class"; then
        return 1
    fi
    
    if ! validate_instance_name "$instance"; then
        return 1
    fi
    
    log_debug "Creating instance: $instance (class: $class)"
    
    # 设置实例属性
    OBJECT_PROPS["${instance}__class"]="$class"
    OBJECT_PROPS["${instance}__created"]="$(date '+%Y-%m-%d %H:%M:%S')"
    OBJECT_PROPS["${instance}__id"]="obj_$(date +%s)_$RANDOM"
    
    log_success "Created instance: $instance (class: $class)"
}

# 属性管理
Object.attr() {
    local instance="$1" attr="$2"
    
    if [ $# -eq 3 ]; then
        # 设置属性
        OBJECT_PROPS["${instance}__${attr}"]="$3"
        log_debug "Set attribute: $instance.$attr = $3"
    else
        # 获取属性
        echo "${OBJECT_PROPS[${instance}__${attr}]}"
    fi
}

# 方法定义
Object.method() {
    local class="$1" method="$2"
    shift 2
    local body="$*"
    
    if ! validate_class_name "$class"; then
        return 1
    fi
    
    log_debug "Defining method: $class.$method"
    
    eval "
        ${class}.${method}() {
            local this=\"\$1\"
            shift
            $body
        }
    "
    
    log_success "Defined method: $class.$method"
}

# 框架初始化
framework_init() {
    log_info "Initializing $FRAMEWORK_NAME v$FRAMEWORK_VERSION"
    
    # 检查基本依赖
    local deps=("bash" "date")
    for dep in "${deps[@]}"; do
        check_dependency "$dep" || return 1
    done
    
    log_success "Framework initialized successfully"
}

# 框架信息
framework_info() {
    echo "$FRAMEWORK_NAME v$FRAMEWORK_VERSION"
    echo "Root: $BASH_OOP_ROOT"
    echo "Author: $FRAMEWORK_AUTHOR"
}

# 如果直接执行此脚本，显示框架信息
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    framework_info
fi
FRAMEWORK_MAIN_EOF

    log_success "创建源代码框架"
}

# 创建示例文件
create_examples() {
    log_step "创建示例文件..."
    
    # Hello World 示例
    cat > "$TARGET_DIR/examples/basic/hello-world.sh" << HELLO_WORLD_EOF
#!/bin/bash

# Bash OOP Framework Hello World 示例

# 加载框架
source "../../src/framework.sh"

# 初始化框架
framework_init

# 创建 Person 类
Object.create "Person" "person1"

# 定义构造函数
Object.method "Person" "constructor" '
    local name="\$1" age="\$2"
    echo "Creating person: \$name, \$age years old"
    Object.attr "\$this" "name" "\$name"
    Object.attr "\$this" "age" "\$age"
'

# 定义问候方法
Object.method "Person" "greet" '
    local name=\$(Object.attr "\$this" "name")
    local age=\$(Object.attr "\$this" "age")
    echo "Hello, I am \$name, \$age years old!"
'

# 使用 Person 类
Person.constructor "person1" "张三" 25
Person.greet "person1"

echo "🎉 Hello World 示例完成！"
HELLO_WORLD_EOF

    chmod +x "$TARGET_DIR/examples/basic/hello-world.sh"
    log_success "创建示例文件"
}

# 创建测试文件
create_tests() {
    log_step "创建测试文件..."
    
    # 测试运行器
    cat > "$TARGET_DIR/tests/test-runner.sh" << TEST_RUNNER_EOF
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
    local test_name=\$1
    local status=\$2
    local message=\$3
    
    case \$status in
        "PASS")
            echo -e "\${GREEN}✓ PASS\${NC} \$test_name"
            ((PASSED_TESTS++))
            ;;
        "FAIL")
            echo -e "\${RED}✗ FAIL\${NC} \$test_name: \$message"
            ((FAILED_TESTS++))
            ;;
        "SKIP")
            echo -e "\${YELLOW}⚠ SKIP\${NC} \$test_name"
            ;;
    esac
    ((TOTAL_TESTS++))
}

# 断言函数
assert_equal() {
    local expected="\$1"
    local actual="\$2"
    local test_name="\$3"
    
    if [ "\$expected" = "\$actual" ]; then
        print_result "\$test_name" "PASS"
    else
        print_result "\$test_name" "FAIL" "Expected: '\$expected', Got: '\$actual'"
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
    echo -e "\${GREEN}通过: \$PASSED_TESTS\${NC}"
    echo -e "\${RED}失败: \$FAILED_TESTS\${NC}"
    echo -e "总计: \$TOTAL_TESTS"
    
    if [ \$FAILED_TESTS -eq 0 ]; then
        echo -e "\${GREEN}🎉 所有测试通过！\${NC}"
        return 0
    else
        echo -e "\${RED}❌ 有测试失败！\${NC}"
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
if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
    main "\$@"
fi
TEST_RUNNER_EOF

    chmod +x "$TARGET_DIR/tests/test-runner.sh"
    log_success "创建测试文件"
}

# 创建脚本文件
create_scripts() {
    log_step "创建工具脚本..."
    
    # 安装脚本
    cat > "$TARGET_DIR/scripts/install.sh" << INSTALL_SCRIPT_EOF
#!/bin/bash

# Bash OOP Framework 安装脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 默认安装目录
DEFAULT_INSTALL_DIR="/usr/local/lib/bash-oop-framework"

# 打印彩色消息
log_info() {
    echo -e "\${YELLOW}ℹ \${NC}\$1"
}

log_success() {
    echo -e "\${GREEN}✓ \${NC}\$1"
}

log_error() {
    echo -e "\${RED}✗ \${NC}\$1"
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    local deps=("bash")
    for dep in "\${deps[@]}"; do
        if command -v "\$dep" &>/dev/null; then
            log_success "找到: \$dep"
        else
            log_error "缺少依赖: \$dep"
            return 1
        fi
    done
    
    return 0
}

# 安装框架
install_framework() {
    local install_dir="\$1"
    
    log_info "安装框架到: \$install_dir"
    
    # 创建安装目录
    mkdir -p "\$install_dir"
    
    # 复制文件
    local script_dir="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
    
    log_info "复制框架文件..."
    cp -r "\$script_dir/src" "\$script_dir/examples" "\$script_dir/docs" "\$install_dir/"
    
    # 设置权限
    find "\$install_dir" -name "*.sh" -exec chmod +x {} \\;
    
    log_success "框架安装完成"
}

# 显示使用说明
show_usage() {
    cat << USAGE_EOF
用法: \$0 [选项]

选项:
    -d, --dir DIR       安装目录 (默认: \$DEFAULT_INSTALL_DIR)
    -h, --help          显示此帮助信息

示例:
    \$0                    # 使用默认目录安装
    \$0 -d ~/my-app/lib    # 安装到指定目录
USAGE_EOF
}

# 主函数
main() {
    local install_dir="\$DEFAULT_INSTALL_DIR"
    
    # 解析参数
    while [[ \$# -gt 0 ]]; do
        case \$1 in
            -d|--dir)
                install_dir="\$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "未知参数: \$1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_info "开始安装 Bash OOP Framework"
    
    # 检查依赖
    if ! check_dependencies; then
        log_error "依赖检查失败"
        exit 1
    fi
    
    # 安装框架
    install_framework "\$install_dir"
    
    # 显示完成信息
    cat << COMPLETE_EOF

🎉 安装完成！

框架已安装到: \$install_dir

使用方法:
  在脚本中包含框架:
      source "\$install_dir/src/framework.sh"

示例:
  查看 \$install_dir/examples/ 目录获取使用示例

文档:
  查看 \$install_dir/docs/ 目录获取详细文档
COMPLETE_EOF
    
    log_success "安装完成！"
}

# 运行主函数
main "\$@"
INSTALL_SCRIPT_EOF

    chmod +x "$TARGET_DIR/scripts/install.sh"
    
    # 构建脚本
    cat > "$TARGET_DIR/scripts/build.sh" << BUILD_SCRIPT_EOF
#!/bin/bash

# Bash OOP Framework 构建脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 构建配置
BUILD_DIR="dist"
VERSION="1.0.0"

# 打印消息
log_info() {
    echo -e "\${BLUE}ℹ \${NC}\$1"
}

log_success() {
    echo -e "\${GREEN}✓ \${NC}\$1"
}

# 清理构建目录
clean_build_dir() {
    log_info "清理构建目录..."
    rm -rf "\$BUILD_DIR"
    mkdir -p "\$BUILD_DIR"
}

# 创建完整版本
build_full_version() {
    log_info "构建完整版本..."
    
    local output_file="\$BUILD_DIR/bash-oop-full.sh"
    
    # 开始构建
    cat > "\$output_file" << 'BUILD_FULL_EOF'
#!/bin/bash

# Bash OOP Framework - Full Version
# 完整版本，包含所有功能

BUILD_FULL_EOF
    
    # 添加框架主文件
    cat "../src/framework.sh" >> "\$output_file"
    
    chmod +x "\$output_file"
    log_success "创建完整版本: \$output_file"
}

# 主构建函数
main() {
    log_info "开始构建 Bash OOP Framework v\$VERSION"
    
    clean_build_dir
    build_full_version
    
    log_success "构建完成！"
    echo
    echo "构建产物:"
    ls -la "\$BUILD_DIR"/
}

# 运行构建
main
BUILD_SCRIPT_EOF

    chmod +x "$TARGET_DIR/scripts/build.sh"
    log_success "创建工具脚本"
}

# 主执行函数
main() {
    echo -e "${CYAN}"
    cat << "BANNER_EOF"
╔══════════════════════════════════════════════════════════════╗
║               Bash OOP Framework Generator                   ║
║                标准开源框架目录结构生成器                   ║
╚══════════════════════════════════════════════════════════════╝
BANNER_EOF
    echo -e "${NC}"
    
    log_info "项目名称: $PROJECT_NAME"
    log_info "目标目录: $TARGET_DIR"
    echo
    
    # 检查依赖
    if ! check_creation_dependencies; then
        log_error "依赖检查失败"
        exit 1
    fi
    
    # 检查目标目录是否已存在
    if [ -d "$TARGET_DIR" ]; then
        log_warning "目标目录已存在: $TARGET_DIR"
        read -p "是否继续？这将覆盖现有文件 [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "操作已取消"
            exit 1
        fi
    fi
    
    # 执行创建过程
    create_directory_structure
    create_license
    create_readme
    create_contributing
    create_code_of_conduct
    create_changelog
    create_github_workflows
    create_issue_templates
    create_source_code
    create_examples
    create_tests
    create_scripts
    
    echo
    echo -e "${GREEN}🎉 框架目录结构生成完成！${NC}"
    echo
    echo -e "${CYAN}下一步操作：${NC}"
    echo -e "  ${BLUE}1.${NC} 进入项目目录: ${GREEN}cd $TARGET_DIR${NC}"
    echo -e "  ${BLUE}2.${NC} 初始化 Git 仓库: ${GREEN}git init${NC}"
    echo -e "  ${BLUE}3.${NC} 添加文件到 Git: ${GREEN}git add .${NC}"
    echo -e "  ${BLUE}4.${NC} 提交初始版本: ${GREEN}git commit -m 'Initial commit'${NC}"
    echo -e "  ${BLUE}5.${NC} 运行测试: ${GREEN}./tests/test-runner.sh${NC}"
    echo -e "  ${BLUE}6.${NC} 查看示例: ${GREEN}./examples/basic/hello-world.sh${NC}"
    echo
    echo -e "${YELLOW}💡 提示：记得更新 README.md 中的项目信息！${NC}"
}

# 运行主函数
main "$@"