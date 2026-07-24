# 00_文档索引_Documentation_Index

> **项目名称**: MT3 Dependencies Documentation
> **文档版本**: 1.0
> **更新日期**: 2026-04-22
> **文档类型**: 文档索引

---

## 文档列表

### 核心技术文档

| 编号 | 文档名称 | 文件名 | 状态 | 优先级 |
|------|----------|--------|------|--------|
| 01 | 项目架构总览 | [01_项目架构总览_Project_Architecture_Overview.md](01_项目架构总览_Project_Architecture_Overview.md) | ✅ 已完成 | ⭐⭐⭐ |
| 02 | API接口文档 | [02_API接口文档_API_Reference_Documentation.md](02_API接口文档_API_Reference_Documentation.md) | ✅ 已完成 | ⭐⭐⭐ |
| 03 | 环境配置文档 | [03_环境配置文档_Environment_Configuration.md](03_环境配置文档_Environment_Configuration.md) | ✅ 已完成 | ⭐⭐⭐ |
| 04 | 操作流程文档 | [04_操作流程文档_Operational_Procedures.md](04_操作流程文档_Operational_Procedures.md) | ✅ 已完成 | ⭐⭐⭐ |
| 05 | 文档审计报告 | [05_文档审计报告与优化总结_Documentation_Audit_Report.md](05_文档审计报告与优化总结_Documentation_Audit_Report.md) | ✅ 已完成 | ⭐⭐ |

### 子项目文档

| 编号 | 文档名称 | 位置 | 状态 | 优先级 |
|------|----------|------|------|--------|
| 10 | LJFilePack文档 | [LJFilePack/docs/](../LJFilePack/docs/) | ✅ 已存在 | ⭐⭐⭐ |
| 11 | SuperLJFilePackUnpack文档 | [SuperLJFilePackUnpack/docs/](../SuperLJFilePackUnpack/docs/) | ✅ 已存在 | ⭐⭐⭐ |
| 12 | BinLayoutConvert文档 | [BinLayoutConvert/](../BinLayoutConvert/) | ✅ 已存在 | ⭐⭐⭐ |

补充：

- `SuperLJFilePackUnpack` 的权威入口优先看其子项目内的 `README.md`、`docs/01`、`docs/02`、`docs/12`
- 本目录下的 `01/02/03/04` 只保留项目级摘要与入口，不再复制工具内的细颗粒实现事实

---

## 文档结构图

```
docs/
├── 00_文档索引_Documentation_Index.md (本文件)
│
├── 01_项目架构总览_Project_Architecture_Overview.md
│   ├── 1. 项目概述
│   ├── 2. 整体架构
│   ├── 3. 核心子系统
│   ├── 4. 技术栈
│   ├── 5. 依赖关系
│   ├── 6. 数据流
│   ├── 7. 部署架构
│   └── 8. 设计原则
│
├── 02_API接口文档_API_Reference_Documentation.md
│   ├── 1. LJFilePack API
│   ├── 2. SuperLJFilePackUnpack API
│   ├── 3. BinLayoutConvert API
│   ├── 4. CEGUI API
│   ├── 5. 算法库API
│   ├── 6. 错误码
│   └── 7. 最佳实践
│
├── 03_环境配置文档_Environment_Configuration.md
│   ├── 1. 系统要求
│   ├── 2. 开发环境配置
│   ├── 3. 编译环境配置
│   ├── 4. 运行环境配置
│   ├── 5. 依赖库配置
│   ├── 6. 环境变量配置
│   ├── 7. 配置文件说明
│   └── 8. 故障排除
│
├── 04_操作流程文档_Operational_Procedures.md
│   ├── 1. 资源打包流程
│   ├── 2. 更新包创建流程
│   ├── 3. 资源解包流程
│   ├── 4. 布局转换流程
│   ├── 5. 版本管理流程
│   ├── 6. 编译构建流程
│   ├── 7. 调试分析流程
│   └── 8. 最佳实践
│
└── 05_文档审计报告与优化总结_Documentation_Audit_Report.md
    ├── 1. 技术准确性审计
    ├── 2. 文档结构评估
    ├── 3. 缺失信息清单
    ├── 4. 优化建议
    └── 5. 实施计划
```

---

## 快速导航

### 按角色查找文档

| 角色 | 推荐文档 | 优先级 |
|------|----------|--------|
| **项目经理** | 项目架构总览、操作流程文档 | ⭐⭐⭐ |
| **架构师** | 项目架构总览、API接口文档 | ⭐⭐⭐ |
| **开发者** | API接口文档、环境配置文档 | ⭐⭐⭐ |
| **运维/测试** | 操作流程文档、环境配置文档 | ⭐⭐⭐ |
| **新成员** | 项目架构总览 → 操作流程文档 | ⭐⭐⭐ |

### 按任务查找文档

| 任务 | 推荐文档 | 相关章节 |
|------|----------|----------|
| **了解项目** | 项目架构总览 | 第1-2章 |
| **开发集成** | API接口文档、环境配置文档 | 全部 |
| **打包资源** | 操作流程文档 | 第1-2章 |
| **解包资源** | 操作流程文档 | 第3章 |
| **转换布局** | 操作流程文档 | 第4章 |
| **编译构建** | 环境配置文档、操作流程文档 | 第3-6章 |
| **调试分析** | 操作流程文档 | 第7-8章 |
| **配置环境** | 环境配置文档 | 全部 |
| **文档维护** | 文档审计报告 | 全部 |

---

## 关键概念速查

### 文件格式

| 扩展名 | 全称 | 描述 | 相关文档 |
|--------|------|------|----------|
| `.ljfp` | Locojoy File Pack | 资源包文件 | 操作流程文档-第1章 |
| `.ljpi` | Locojoy Pack Info | 文件索引信息 | API接口文档-第1章 |
| `.ljzip` | Locojoy ZIP | 加密索引文件 | API接口文档-第1章 |
| `.ljvi` | Locojoy Version Info | 版本信息 | 操作流程文档-第4章 |
| `.ljnd` | Locojoy Node Data | XML节点二进制格式 | API接口文档-第1章 |
| `.layout` | CEGUI Layout | UI布局文件（XML或BinLayout） | 操作流程文档-第3章 |

### 核心模块

| 模块 | 位置 | 职责 | 相关文档 |
|------|------|------|----------|
| **LJFilePack** | `LJFilePack/` | 资源打包、压缩、加密 | API接口文档-第1章 |
| **SuperLJFilePackUnpack** | `SuperLJFilePackUnpack/` | 资源解包、还原 | API接口文档-第2章 |
| **BinLayoutConvert** | `BinLayoutConvert/` | 布局文件转换 | API接口文档-第3章 |
| **CEGUI** | `cegui/` | UI框架 | API接口文档-第4章 |
| **wxWidgets** | `wxWidgets-3.0.5/` | GUI框架 | 环境配置文档-第5章 |

### 技术栈

| 技术 | 版本 | 用途 | 相关文档 |
|------|------|------|----------|
| C++ | C++11 | 开发语言 | 项目架构总览-第4章 |
| Visual Studio | 2013 (v120) | Windows编译工具 | 环境配置文档-第2章 |
| CMake | 3.10+ | 跨平台构建工具 | 环境配置文档-第2章 |
| MiniZ | custom | 压缩库 | API接口文档-第1章 |
| SMS4 | custom | 加密算法（国密SM4） | API接口文档-第1章 |
| zlib | compatible | 压缩算法 | API接口文档-第1章 |
| wxWidgets | 3.0.5 | GUI框架 | 项目架构总览-第3章 |
| CEGUI | custom | UI框架 | 项目架构总览-第3章 |

---

## 文档更新日志

### v1.1 (2026-01-27)

**新增**:
- ✅ 文档审计报告与优化总结
- ✅ 更新包创建流程详细说明
- ✅ 路径映射表使用说明
- ✅ 文件类型检测说明

**优化**:
- ✅ 修正API接口文档中LJFP_Version类不存在的方法描述
- ✅ 修正LJFP_ZipFile构造函数的描述
- ✅ 补充LJFP_Pack和LJFP_FileList类的方法说明
- ✅ 补充SuperLJFilePackUnpack的CMake构建配置说明
- ✅ 修正环境配置文档中硬编码的路径说明

**清理**:
- ✅ 删除LJFilePack/docs/中的冗余文档
- ✅ 删除SuperLJFilePackUnpack/docs/中的冗余文档
- ✅ 删除BinLayoutConvert/中的冗余文档

### v1.0 (2026-01-27)

**新增**:
- ✅ 完整的项目架构总览文档
- ✅ 详细的API接口文档
- ✅ 全面的环境配置文档
- ✅ 实用的操作流程文档
- ✅ 统一的文档索引文件

**覆盖内容**:
- 18个核心模块分析
- 完整目录结构说明
- 核心算法解析
- 配置文件详解
- 命令行工具使用
- 常见问题解答

**文档特点**:
- 中英双语命名规范
- 清晰的章节结构
- 丰富的代码示例
- 详细的操作步骤
- 完整的错误处理

---

## 维护说明

### 文档维护者

- **创建**: AI Assistant
- **项目路径**: `e:\MT3\dependencies\`
- **文档路径**: `e:\MT3\dependencies\docs\`

### 更新建议

当项目发生以下变化时，请更新对应文档：

1. **新增功能** → 更新项目架构总览、API接口文档
2. **修改接口** → 更新API接口文档、操作流程文档
3. **配置变更** → 更新环境配置文档
4. **性能优化** → 更新项目架构总览
5. **安全修复** → 更新项目架构总览、API接口文档
6. **新增依赖** → 更新环境配置文档、项目架构总览

### 文档质量标准

1. **准确性**: 确保所有技术细节准确无误
2. **完整性**: 覆盖所有重要功能和场景
3. **可读性**: 使用清晰的语言和结构
4. **时效性**: 及时更新以反映项目变化
5. **实用性**: 提供实用的示例和最佳实践

---

## 联系方式

- **项目位置**: `dependencies/`
- **文档位置**: `dependencies/docs/`
- **问题反馈**: 通过项目Issue系统提交

---

## 附录

### A. 文档命名规范

所有文档遵循以下命名规范：

```
编号_中文名称_English_Name.md
```

**示例**:
- `01_项目架构总览_Project_Architecture_Overview.md`
- `02_API接口文档_API_Reference_Documentation.md`
- `03_环境配置文档_Environment_Configuration.md`

### B. 文档版本控制

所有文档应使用版本控制系统管理：

- 使用Git进行版本控制
- 每次更新提交清晰的commit message
- 使用分支进行重大修改
- 定期合并到主分支

### C. 文档审查流程

1. **草稿**: 创建文档草稿
2. **审查**: 团队成员审查文档
3. **修改**: 根据反馈修改文档
4. **批准**: 文档批准发布
5. **发布**: 发布文档到文档库
6. **维护**: 定期更新和维护文档

---

**文档版本**: 1.1
**最后更新**: 2026-01-27
**维护**: MT3项目组
