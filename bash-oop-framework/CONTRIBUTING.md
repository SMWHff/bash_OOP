# 贡献指南

感谢您考虑为 bash-oop-framework 做出贡献！

## 如何贡献

### 报告 Bug

1. 在 [GitHub Issues](https://github.com/your-username/bash-oop-framework/issues) 搜索是否已有相关 issue
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
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 开发环境设置

```bash
# 克隆项目
git clone https://github.com/your-username/bash-oop-framework.git
cd bash-oop-framework

# 运行测试确保环境正常
./tests/test-runner.sh
```

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

```bash
# 运行所有测试
./tests/test-runner.sh

# 运行特定测试
./tests/unit/test_core.sh
```

## Pull Request 流程

1. 确保所有测试通过
2. 更新相关文档
3. 添加更改日志条目
4. 获取代码审查
5. 合并到主分支
