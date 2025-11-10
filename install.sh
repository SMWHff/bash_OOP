#!/bin/bash

# Bash OOP 系统安装脚本

set -e

echo "开始安装 Bash 面向对象系统..."

# 检查是否在正确的目录
if [ ! -f "main.sh" ]; then
    echo "错误: 请在包含 main.sh 的目录中运行此脚本"
    exit 1
fi

# 创建必要的目录
mkdir -p core features utils classes examples

# 设置执行权限
chmod +x *.sh
chmod +x core/*.sh
chmod +x features/*.sh
chmod +x utils/*.sh
chmod +x classes/*.sh
chmod +x examples/*.sh

# 创建全局可访问的链接（可选）
if [ "$EUID" -eq 0 ]; then
    echo "安装到系统目录..."
    cp main.sh /usr/local/bin/bash-oop
    chmod +x /usr/local/bin/bash-oop
    echo "安装完成！现在可以使用 'bash-oop' 命令"
else
    echo "本地安装完成！"
    echo "使用方法: source main.sh"
    echo "演示: ./examples/demo.sh"
    echo "测试: ./tests/full_test.sh"
fi

echo ""
echo "📚 可用功能:"
echo "  - 完整的面向对象编程"
echo "  - 事件系统"
echo "  - 验证器系统" 
echo "  - 权限控制"
echo "  - 事务支持"
echo "  - 缓存系统"
echo "  - 数据库持久化"
echo "  - 配置管理"
echo "  - 性能监控"
echo ""
echo "🚀 开始使用: source main.sh && Object::init"