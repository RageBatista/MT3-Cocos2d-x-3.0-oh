---
name: engine-tools-build
version: 1.1.0
priority: medium
category: common
description: |
  tools/engine 模块构建技能。覆盖 VS2013/v120 下核心引擎库与编辑器工具构建流程及排障。
  触发词: engine tools, SpriteEditor, MapEditor, v120, 构建, 编译, 链接
dependencies:
  - windows-build
  - build-troubleshooting
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 10000
---

# tools\engine 编译技能 (Engine Tools Build)

**版本**: v1.2.0
**最后更新**: 2026-04-11

---

## 1. 技能概述

### 1.1 技能定义

掌握 MT3 项目 `tools\engine` 模块的编译构建能力，包括核心引擎库、PFS 文件系统、编辑器工具等组件的编译和维护。

### 1.2 适用场景

- 编译核心引擎库 (engine.lib)
- 编译资源编辑器 (SpriteEditor, MapEditor, etc.)
- 编译 PFS 文件系统
- 排查编译链接错误
- 管理第三方依赖库

### 1.3 前置技能

| 技能 | 优先级 | 说明 |
|------|--------|------|
| [Windows 编译](../client/windows-build.md) | 必需 | VS2013 基础使用 |
| [C++ 开发](../client/cpp-development.md) | 必需 | C++ 代码理解能力 |
| [构建故障排查](build-troubleshooting.md) | 推荐 | 错误诊断能力 |

---

## 2. 核心知识点

### 2.1 目录结构理解

```
tools\engine\
├── build\                    # 构建配置 (.props)
├── lib\                      # 预编译库输出
├── bin\                      # Debug 可执行输出
├── docs\                     # 📚 文档目录
│
├── engine\                   # 核心引擎库
├── pfs\                      # PFS 文件系统
├── xmlio\                    # XML 序列化
├── contrib\                  # 第三方依赖
│
├── SpriteEditor\             # 精灵编辑器
├── MapEditor\                # 地图编辑器
├── ParticleSystemEditor\     # 粒子编辑器
└── ...                       # 其他编辑器
```

### 2.2 工具集约束

```yaml
强制要求:
  工具集: Visual Studio 2013 (v120)
  平台: Win32 (x86)
  字符集: Unicode

禁止使用:
  - v140 (VS2015)
  - v141 (VS2017)
  - v142 (VS2019)
  - v143 (VS2022)

原因:
  - FireClient.lib 为 v120 预编译库
  - C++ ABI 在 v120 与 v140+ 之间不兼容
```

### 2.3 配置矩阵

| 配置 | RuntimeLibrary | 用途 |
|------|----------------|------|
| Debug | /MDd | 调试版本，动态 CRT |
| Release | /MD | 发布版本，动态 CRT |
| Debug.mtd | /MTd | 调试版本，静态 CRT |
| Release.mt | /MT | 发布版本，静态 CRT |

---

## 3. 编译流程

### 3.1 环境准备

```batch
:: 1. 验证 VS2013 安装
where msbuild
:: 应显示: C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe

:: 2. 验证 DirectX SDK
echo %DXSDK_DIR%
:: 应显示: C:\Program Files (x86)\Microsoft DirectX SDK (June 2010)\
```

### 3.2 完整编译

```batch
cd E:\MT3\tools\engine

:: Release 编译
"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" ^
    Tools.sln ^
    /p:Configuration=Release ^
    /p:Platform=Win32 ^
    /m /v:minimal

:: Debug 编译
"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" ^
    Tools.sln ^
    /p:Configuration=Debug ^
    /p:Platform=Win32 ^
    /m /v:minimal
```

### 3.3 单独项目编译

```batch
:: 核心引擎
msbuild engine\engine.vcxproj /p:Configuration=Release /p:Platform=Win32 /m

:: PFS 文件系统
cd pfs\projects
msbuild pfs.sln /p:Configuration=Release.mt /p:Platform=Win32 /m

:: 精灵编辑器
msbuild SpriteEditor\SpriteEditor.vcxproj /p:Configuration=Release /p:Platform=Win32
```

---

## 4. 常见问题处理

### 4.1 LNK2026: SAFESEH 不兼容

```yaml
错误: error LNK2026: module unsafe for SAFESEH image

原因: 旧静态库包含未标记 SAFESEH 的 x86 汇编代码

解决:
  1. 检查项目是否引用 Engine.LinkFixes.props
  2. 或手动设置: ImageHasSafeExceptionHandlers=false
```

### 4.2 LNK2005: 符号重复

```yaml
错误: error LNK2005: _malloc already defined in LIBCMTD.lib

原因: Debug 库与 Release 库混用

解决:
  1. 统一所有库的 RuntimeLibrary 配置
  2. Debug 使用 *d.lib, *.mtd.lib
  3. Release 使用无后缀或 *.mt.lib
```

### 4.3 C1083: 找不到头文件

```yaml
错误: fatal error C1083: Cannot open include file: 'd3dx9.h'

原因: DirectX SDK 未安装或路径未配置

解决:
  1. 安装 DirectX SDK (June 2010)
  2. 设置 DXSDK_DIR 环境变量
  3. 验证: dir "%DXSDK_DIR%Include\d3dx9.h"
```

---

## 5. 权威文档

### 5.1 tools\engine 专用文档

以下文档属于 runtime-local `tools/engine` 工作区；clean checkout 可能不存在。使用前必须先执行 `Test-Path tools/engine/docs`，不存在时停在证据缺口，不把表内路径当作已跟踪入口。

| 文档 | 路径 | 说明 |
|------|------|------|
| **文档索引** | `tools/engine/docs/00-文档索引-Documentation-Index.md` | 文档导航入口 |
| **编译完整指南** | `tools/engine/docs/01-编译完整指南-Engine-Compilation-Guide.md` | 完整编译流程 |
| **第三方依赖** | `tools/engine/docs/02-第三方依赖清单-Third-Party-Dependencies.md` | 依赖库清单 |
| **预编译库规范** | `tools/engine/docs/03-预编译库规范-Prebuilt-Libraries-Specification.md` | 库文件规范 |
| **快速构建** | `tools/engine/docs/04-快速构建指南-Quick-Build-Guide.md` | 快速参考 |
| **已知问题** | `tools/engine/docs/05-已知问题与解决方案-Known-Issues-Solutions.md` | 问题解决方案 |
| **架构分析** | `tools/engine/docs/06-VS2013构建架构分析-VS2013-Build-Architecture-Analysis.md` | 架构详解 |

### 5.2 项目通用文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 项目规则 | [../RULES.md](../../RULES.md) | 强制性约束 |
| 项目架构 | [AGENTS.md](../../../AGENTS.md) | 项目整体规范 |
| Windows 编译 | [Windows 完整构建指南](../../../docs/03-开发指南/02-Windows完整构建指南.md) | 客户端编译 |

---

## 6. 技能验证清单

### 6.1 初级验证 (1周)

- [ ] 能够成功编译 Tools.sln (Release 配置)
- [ ] 理解项目目录结构
- [ ] 知道如何查找文档

### 6.2 中级验证 (2周)

- [ ] 能够单独编译各个项目
- [ ] 能够诊断和解决常见编译错误
- [ ] 理解 RuntimeLibrary 配置
- [ ] 理解工具集约束原因

### 6.3 高级验证 (1月)

- [ ] 能够修改编译配置
- [ ] 能够集成新的第三方库
- [ ] 能够处理复杂的链接问题
- [ ] 能够优化编译性能

---

## 7. 相关技能

| 技能 | 关系 | 说明 |
|------|------|------|
| [Windows 编译](../client/windows-build.md) | 前置 | VS2013 基础 |
| [C++ 开发](../client/cpp-development.md) | 前置 | 代码理解 |
| [构建故障排查](build-troubleshooting.md) | 补充 | 错误诊断 |
| [Cocos2d-x 使用](../client/cocos2dx-usage.md) | 相关 | 引擎使用 |

---

**最后更新**: 2025-12-28
**维护者**: MT3 开发团队
