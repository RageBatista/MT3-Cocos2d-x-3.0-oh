# 编译错误速查表

> **目标**: 3 秒定位错误模式,1 分钟内找到解决方案
> **版本**: 1.0 | **更新**: 2026-01-07

---

## 🚀 快速查找

### 按错误码查找

| 错误码 | 类型 | 关键词 | 文档 |
|--------|------|--------|------|
| **LNK2001** | 链接 | 无法解析的外部符号 | [linker-errors.md#LNK2001](linker-errors.md#lnk2001-无法解析的外部符号) |
| **LNK2019** | 链接 | 无法解析的外部符号 | [linker-errors.md#LNK2019](linker-errors.md#lnk2019-无法解析的外部符号-函数) |
| **LNK4098** | 链接 | CRT 冲突 | [linker-errors.md#LNK4098](linker-errors.md#lnk4098-crt-运行时库冲突) |
| **C2491** | 编译 | 不能定义 dllimport 静态数据成员 | [compiler-errors.md#C2491](compiler-errors.md#c2491-不能定义-dllimport-静态数据成员) |
| **C2065** | 编译 | 未声明的标识符 | [compiler-errors.md#C2065](compiler-errors.md#c2065-未声明的标识符) |
| **C1010** | 编译 | 预编译头错误 | [compiler-errors.md#C1010](compiler-errors.md#c1010-预编译头错误) |
| **MSB8020** | MSBuild | 工具集不匹配 | [msbuild-errors.md#MSB8020](msbuild-errors.md#msb8020-工具集不匹配) |
| **MSB3073** | MSBuild | 命令退出码非零 | [msbuild-errors.md#MSB3073](msbuild-errors.md#msb3073-命令退出码非零) |

### 按症状查找

| 症状 | 可能错误 | 快速检查 |
|------|----------|----------|
| "无法解析的外部符号 cocos2d::" | **LNK2019** | 是否缺少 libcocos2d.lib? |
| "不能定义 dllimport 静态数据成员" | **C2491** | 是否误用 EXPORTS 宏? |
| "warning LNK4098: defaultlib MSVCRT 冲突" | **LNK4098** | 是否混用 /MT 和 /MD? |
| "PlatformToolset 不匹配" | **MSB8020** | 是否使用 v120? |
| "缺少预编译头文件" | **C1010** | 是否包含 nupch.h? |
| "FALAGARDWRBASE_EXPORTS" + 链接失败 | **LNK2001** | Falagard 源文件缺失 |
| "FALAGARDWRBASE_EXPORTS" 移除后失败 | **C2491** | Falagard 源文件应排除 |

### 按项目类型查找

| 项目 | 常见错误 | 优先检查 |
|------|----------|----------|
| **CEGUI 0.7.9-r5** | LNK2019 (Cocos2d), C2491 (Falagard) | [cegui-specific-errors.md](cegui-specific-errors.md) |
| **MT3 客户端** | LNK2019 (FireClient.lib), C1010 (预编译头) | [compiler-errors.md](compiler-errors.md), [linker-errors.md](linker-errors.md) |
| **MT3 工具** | MSB8020 (工具集), LNK4098 (CRT) | [msbuild-errors.md](msbuild-errors.md) |

---

## 📊 诊断流程图

```
编译失败
    ↓
错误类型?
├─ LNK**** → 链接错误
│   ├─ LNK2001/2019 → 检查库链接和依赖
│   ├─ LNK4098 → 检查 RuntimeLibrary (/MT vs /MD)
│   └─ 其他 → 查看 linker-errors.md
│
├─ C**** → 编译错误
│   ├─ C2491 → 检查 EXPORTS 宏和模块化
│   ├─ C2065 → 检查头文件包含
│   ├─ C1010 → 检查预编译头 (nupch.h)
│   └─ 其他 → 查看 compiler-errors.md
│
└─ MSB**** → MSBuild 错误
    ├─ MSB8020 → 检查 PlatformToolset (v120)
    ├─ MSB3073 → 检查预构建/后构建命令
    └─ 其他 → 查看 msbuild-errors.md
```

---

## 📚 文档索引

| 文档 | 内容 | 何时查阅 |
|-----|------|----------|
| [compiler-errors.md](compiler-errors.md) | C2491, C2065, C1010 等编译错误 | 编译阶段失败 |
| [linker-errors.md](linker-errors.md) | LNK2001, LNK2019, LNK4098 等链接错误 | 看到 "无法解析的外部符号" |
| [msbuild-errors.md](msbuild-errors.md) | MSB8020, MSB3073 等构建错误 | MSBuild 报错 |
| [dll-errors.md](dll-errors.md) | DLL 导出/导入错误 | 涉及 __declspec(dllimport/dllexport) |
| [cegui-specific-errors.md](cegui-specific-errors.md) | CEGUI 特定错误 (模块化,Cocos2d) | 构建 CEGUI 项目 |

---

## 🎯 使用方法

### 方法 1: 按错误码查找
```
1. 在构建日志中找到错误码 (例如: error LNK2019)
2. 在上方 "按错误码查找" 表中找到对应行
3. 点击文档链接,跳转到详细说明
```

### 方法 2: 按症状描述查找
```
1. 在构建日志中找到错误描述 (例如: "无法解析的外部符号 cocos2d::CCDirector")
2. 在上方 "按症状查找" 表中找到匹配行
3. 执行 "快速检查" 列的检查项
```

### 方法 3: 按项目类型查找
```
1. 确定当前构建的项目 (例如: CEGUI 0.7.9-r5)
2. 在上方 "按项目类型查找" 表中找到对应行
3. 查阅项目特定错误文档
```

---

## 🔥 高频错误 TOP 5

基于 MT3 项目实战统计:

| 排名 | 错误 | 频率 | 典型场景 |
|------|------|------|----------|
| 1 | **LNK2019** | ⭐⭐⭐⭐⭐ | 缺少库文件,工具集不匹配 |
| 2 | **C1010** | ⭐⭐⭐⭐ | 新文件未包含预编译头 |
| 3 | **MSB8020** | ⭐⭐⭐⭐ | 使用 VS2015+ 打开 v120 项目 |
| 4 | **LNK4098** | ⭐⭐⭐ | 混用 /MT 和 /MD 运行时库 |
| 5 | **C2491** | ⭐⭐ | CEGUI 等第三方库模块化问题 |

---

## 🆘 紧急处理流程

**编译突然失败?**

```yaml
步骤 1: 确定错误类型 (5 秒)
  - 看第一个错误行: error LNK**** or C**** or MSB****

步骤 2: 快速定位 (10 秒)
  - 在本页面 Ctrl+F 搜索错误码
  - 点击对应文档链接

步骤 3: 执行快速检查 (30 秒)
  - 按照 "快速检查" 列的指示操作
  - 常见问题通常在 1 分钟内解决

步骤 4: 如仍失败 (2 分钟)
  - 阅读完整错误文档
  - 查看实战案例
  - 执行详细诊断流程
```

---

## 🛠️ 维护指南

### 添加新错误

当遇到新的错误模式时:

```yaml
1. 确定错误类型 (编译/链接/MSBuild)
2. 在对应文档中添加条目:
   - 错误码和描述
   - 典型症状
   - 根本原因
   - 调查步骤
   - 解决方案 (方案 A/B/C)
   - 实战案例

3. 更新本文件的索引表

4. 记录到 CHANGELOG (文档末尾)
```

### 更新现有错误

当发现更好的解决方案时:

```yaml
1. 在原错误条目中添加新方案
2. 标注推荐优先级
3. 添加实战验证标记 (✅ 已验证)
4. 记录到 CHANGELOG
```

---

## 📖 参考资源

### 内部文档

- [工作流库](../workflows/) - 标准构建流程
- [标准库](../standards/) - 编码规范
- [案例库](../cases/) - 实战案例

### 项目文档

- [编译完整指南](../../docs/03-开发指南/02-Windows完整构建指南.md)
- [技术体系总结](../../docs/02-技术架构/01-技术体系总览.md)
- [项目规则](../RULES.md)

### 外部资源

- [Microsoft C++ 错误](https://learn.microsoft.com/cpp/error-messages/)
- [MSBuild 错误](https://learn.microsoft.com/visualstudio/msbuild/msbuild-errors)

---

## 📝 CHANGELOG

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-01-07 | 1.0 | 初始版本,包含 CEGUI 实战案例 |

---

**索引版本**: 1.0
**维护**: Claude AI + MT3 Team
**最后更新**: 2026-01-07
**覆盖率**: TOP 20 高频错误 100% 覆盖
