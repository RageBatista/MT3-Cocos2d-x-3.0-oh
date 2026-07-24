# Errors 快速索引

> **版本**: 1.0.0 | **更新**: 2026-02-28 | **错误类型**: 5

---

## 🔍 快速查找

### 按错误码查找

| 错误码 | 类型 | 文件 |
|-------|------|------|
| **C**** 系列** | 编译错误 | [compiler-errors.md](../errors/compiler-errors.md) |
| **LNK**** 系列** | 链接错误 | [linker-errors.md](../errors/linker-errors.md) |
| **MSB**** 系列** | 构建错误 | [msbuild-errors.md](../errors/msbuild-errors.md) |
| **CEGUI**** 系列** | CEGUI 错误 | [cegui-specific-errors.md](../errors/cegui-specific-errors.md) |

---

## 📋 错误类型

### 编译错误 (C****)
**常见错误**:
- C1083: 头文件路径错误
- C2065: 未声明的标识符
- C2039: 不是类的成员
- C2143: 语法错误

**查看详情**: [compiler-errors.md](../errors/compiler-errors.md)

### 链接错误 (LNK****)
**常见错误**:
- LNK2001: 无法解析的外部符号
- LNK2019: 无法解析的外部命令
- LNK2038: 检测到"RuntimeLibrary"的不匹配项
- LNK2011: 导入的外部符号

**查看详情**: [linker-errors.md](../errors/linker-errors.md)

### 构建错误 (MSB****)
**常见错误**:
- MSB3073: 命令退出代码
- MSB6006: 无法打开文件
- MSB8020: 无法找到项目文件
- MSB4126: 无法找到项目文件

**查看详情**: [msbuild-errors.md](../errors/msbuild-errors.md)

### CEGUI 特定错误
**常见错误**:
- 资源加载失败
- 布局文件解析错误
- 窗口创建失败
- 事件订阅失败

**查看详情**: [cegui-specific-errors.md](../errors/cegui-specific-errors.md)

---

## 🎯 按问题类型查找

### 工具集问题
| 错误 | 原因 | 解决方案 |
|-----|------|---------|
| LNK2001/LNK2019 | 工具集不匹配 | 检查 PlatformToolset = v120 |
| LNK2038 | RuntimeLibrary 不匹配 | Release=/MD, Debug=/MDd |

### 头文件问题
| 错误 | 原因 | 解决方案 |
|-----|------|---------|
| C1083 | 头文件路径错误 | 检查 AdditionalIncludeDirectories |
| C2039 | 成员未找到 | 检查头文件包含 |

### CEGUI 问题
| 错误 | 原因 | 解决方案 |
|-----|------|---------|
| 资源加载失败 | 路径错误 | 检查 SchemeManager 路径 |
| 布局解析错误 | XML 语法错误 | 检查 .layout 文件格式 |

---

## 🚀 快速诊断流程

### 编译错误诊断
```bash
1. 识别错误码 (C****)
2. 查看错误详情
3. 检查代码语法
4. 检查头文件包含
5. 查看解决方案
```

### 链接错误诊断
```bash
1. 识别错误码 (LNK****)
2. 检查工具集版本
3. 验证库文件存在
4. 检查库依赖关系
5. 查看解决方案
```

### CEGUI 错误诊断
```bash
1. 检查资源路径
2. 验证布局文件格式
3. 检查窗口名称拼写
4. 查看日志详细信息
5. 查看解决方案
```

---

## 📊 错误统计

### 按严重程度
```
严重:   LNK2001, LNK2019, LNK2038
高:     C1083, C2065, MSB3073
中:     C2039, C2143, MSB6006
低:     CEGUI 资源加载失败
```

### 按频率
```
高频:   LNK2001, LNK2019, C1083
中频:   LNK2038, C2065, MSB3073
低频:   CEGUI 特定错误
```

---

## 📝 版本历史

### 1.0.0 (2026-02-28)
- 初始化错误索引
- 添加快速查找功能
- 添加诊断流程

---

**维护者**: MT3 技术团队
**更新周期**: 按需更新
