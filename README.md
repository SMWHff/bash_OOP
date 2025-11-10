# Bash OOP 系统

这是一个在 Bash Shell 环境中实现完整面向对象编程范式的系统。该系统提供了类、对象、继承、多态、封装等面向对象编程的核心概念，以及多种设计模式的实现。

## 系统概述

这个 Bash OOP 系统通过巧妙地使用 Bash 的关联数组、函数和 eval 命令，在 Shell 环境中模拟了面向对象编程的主要特性。系统设计简洁而强大，可以用于构建结构复杂、模块化的 Shell 脚本应用程序。

## 核心特性

### 1. 面向对象基础
- **类定义**：支持创建自定义类和继承关系
- **对象实例化**：创建和管理对象实例
- **属性管理**：公共属性和私有属性的存储与访问
- **方法定义**：实例方法和静态方法的定义与调用
- **继承机制**：子类继承父类的属性和方法
- **多态实现**：方法重写和方法调用的动态绑定

### 2. 设计模式实现
- **单例模式**：确保一个类只有一个实例
- **观察者模式**：实现对象间一对多的依赖关系
- **装饰器模式**：动态地向对象添加额外的职责
- **工厂模式**：创建对象而不指定具体的类
- **策略模式**：定义一系列算法并使它们可以互相替换

### 3. 高级功能
- **对象关系管理**：维护对象间的关联关系
- **事件系统**：对象间的事件通知机制
- **系统监控**：跟踪和监控对象创建与系统状态
- **内存管理**：对象清理和资源释放
- **错误处理**：健壮的异常处理机制

## 系统架构

### 核心数据结构
- `OBJECT_PROPS`：存储对象的公共属性
- `OBJECT_PRIVATE`：存储对象的私有属性
- `OBJECT_METHODS`：存储类的方法定义
- `OBJECT_RELATIONS`：存储对象之间的关系

### 基类系统
- `Object`：所有类的基类，提供基础方法
- 支持类的继承和方法重写
- 提供属性和方法的管理机制

## 使用示例

### 创建和使用类

```bash
# 定义类方法
Object.method "Person" "constructor" '  
    local name="$1" age="$2"
    Object.attr "$this" "name" "$name"
    Object.attr "$this" "age" "$age"
'

Object.method "Person" "greet" '  
    local name=$(Object.attr "$this" "name")
    echo "Hello, I am $name!"
'

# 创建实例
Object.create "Person" "person1"
Person.constructor "person1" "张三" "25"

# 调用方法
Person.greet "person1"
```

### 使用设计模式

```bash
# 单例模式
logger_instance=$(Object.singleton "Logger" "global_logger")

# 观察者模式
Object.addObserver "target_object" "observer" "event_name"
Object.notifyObservers "target_object" "event_name" "event_data"

# 装饰器模式
Employee.addBonus "employee" "0.2"

# 工厂模式
developer=$(Employee::createDeveloper "李四" "30" "科技公司")

# 策略模式
salary=$(SalaryCalculator::calculate "developer" "employee")
```

## 运行演示

执行主脚本以查看系统的完整功能演示：

```bash
chmod +x main.sh
./main.sh
```

演示内容包括：
- 设计模式的实际应用
- 类的继承和多态
- 对象关系管理
- 系统监控和内存管理

## 适用场景

- **复杂脚本开发**：构建大型、模块化的 Shell 脚本
- **自动化工具**：创建可维护的自动化脚本框架
- **学习目的**：理解面向对象编程概念在不同环境中的实现
- **原型开发**：快速构建功能原型

## 技术亮点

1. **纯 Bash 实现**：不依赖外部工具，完全使用 Bash 内置功能
2. **内存管理**：提供对象清理机制，避免内存泄漏
3. **错误处理**：健壮的异常处理和错误提示
4. **扩展性**：易于扩展和定制新的功能
5. **性能优化**：针对 Bash 环境进行了性能优化

## 注意事项

- 确保使用支持关联数组的 Bash 版本（Bash 4.0+）
- 在 Windows 环境中，建议使用 WSL 或 Git Bash 运行
- 对于复杂场景，注意避免过度使用 eval 可能带来的安全风险

## 贡献

欢迎提交 Issues 和 Pull Requests 来改进这个项目。

## 许可证

GNU GPL v3 许可证。该许可证确保软件的自由使用、修改和分发，但限制商业闭源使用。详情请参阅 LICENSE 文件。

---

这个 Bash OOP 系统展示了在 Shell 环境中实现完整面向对象编程的可能性，为 Shell 脚本开发者提供了一种新的编程范式选择。