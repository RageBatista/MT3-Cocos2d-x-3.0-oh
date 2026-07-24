# 06-依赖图谱 Dependency Graph

> **版本**: 1.0.0  
> **创建日期**: 2026-01-13  
> **作者**: 系统架构师  
> **项目**: LJFilePack (LJ文件打包工具)

---

## 1. 依赖关系总览

### 1.1 系统依赖层次

```
┌─────────────────────────────────────────────────────────────────┐
│                        Layer 5: 应用层                            │
│                   LJFP_Main (主程序入口)                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      Layer 4: 业务逻辑层                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ LJFP_Option  │  │ LJFP_Version │  │ LJFP_Find    │          │
│  │  (配置管理)   │  │  (版本管理)   │  │  (文件扫描)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ LJFP_Pack    │  │ LJFP_FileList│  │ LJFP_FileInfo│          │
│  │  (文件打包)   │  │  (文件列表)   │  │  (文件信息)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      Layer 3: 数据结构层                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ LJFP_Node    │  │ LJFP_XML     │  │ LJFP_ZipFile │          │
│  │  (节点结构)   │  │  (XML处理)   │  │  (ZIP封装)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                       Layer 2: 工具库层                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ LJFP_MiniZ   │  │ LJFP_SMS4    │  │ LJFP_CRC32   │          │
│  │  (压缩库)     │  │  (加密库)     │  │  (校验库)     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                      Layer 1: 平台抽象层                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │StringUtil    │  │  FileUtil    │  │  LJFP_Var    │          │
│  │ (字符串工具)   │  │  (文件操作)   │  │  (类型定义)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────┐
│                    Layer 0: 第三方依赖库                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   MiniZ      │  │    LJXML     │  │ StringCover  │          │
│  │  (zlib兼容)   │  │  (XML解析)   │  │ (字符串转换)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐                           │
│  │    zlib      │  │   shlwapi    │                           │
│  │  (系统库)     │  │  (Windows API)│                           │
│  └──────────────┘  └──────────────┘                           │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 模块依赖关系图

```
                    ┌─────────────────────────────────────────────┐
                    │              LJFP_Main                       │
                    │         └──────────┬──────────────┘        │
                    │                    │                        │
                    │  ┌─────────────────┼─────────────────┐      │
                    │  ▼                 ▼                 ▼      │
                    │ ┌─────────┐   ┌─────────┐   ┌─────────┐    │
                    │ │LJFP_Find│   │LJFP_Pack│   │LJFP_Ver │    │
                    │ └────┬────┘   └────┬────┘   └────┬────┘    │
                    │      │            │             │           │
                    │      ▼            ▼             ▼           │
                    │  ┌─────────────────────────────────┐        │
                    │  │         LJFP_Option            │        │
                    │  └───────────────┬────────────────┘        │
                    │                  │                        │
                    │                  ▼                        │
                    │  ┌─────────────────────────────────┐        │
                    │  │          LJFP_XML              │        │
                    │  └───────────────┬────────────────┘        │
                    │                  │                        │
                    │                  ▼                        │
                    │  ┌─────────────────────────────────┐        │
                    │  │         LJFP_Node              │        │
                    │  └─────────────────────────────────┘        │
                    │                                           │
                    │  ┌─────────────────────────────────┐        │
                    │  │       LJFP_FileList            │        │
                    │  └───────────────┬────────────────┘        │
                    │                  │                        │
                    │                  ▼                        │
                    │  ┌─────────────────────────────────┐        │
                    │  │       LJFP_PackInfo           │        │
                    │  └───────────────┬────────────────┘        │
                    │                  │                        │
                    │                  ▼                        │
                    │  ┌─────────────────────────────────┐        │
                    │  │      LJFP_FileInfo            │        │
                    │  └───────────────┬────────────────┘        │
                    │                  │                        │
                    │                  ▼                        │
                    │  ┌─────────────────────────────────┐        │
                    │  │       LJFP_ZipFile             │        │
                    │  └───────┬───────────────┬────────┘        │
                    │          │               │                │
                    │          ▼               ▼                │
                    │  ┌───────────────┐ ┌───────────────┐     │
                    │  │  LJFP_SMS4    │ │  LJFP_MiniZ   │     │
                    │  └───────────────┘ └───────────────┘     │
                    │                                           │
                    │  ┌─────────────────────────────────┐        │
                    │  │      LJFP_CRC32               │        │
                    │  └─────────────────────────────────┘        │
                    │                                           │
                    │  ┌─────────────────────────────────┐        │
                    │  │    LJFP_StringUtil            │        │
                    │  └─────────────────────────────────┘        │
                    │                                           │
                    │  ┌─────────────────────────────────┐        │
                    │  │     LJFP_FileUtil             │        │
                    │  └─────────────────────────────────┘        │
                    │                                           │
                    └─────────────────────────────────────────────┘
```

---

## 2. 核心依赖关系详解

### 2.1 内部模块依赖矩阵

| 模块 | LJFP_Main | LJFP_Option | LJFP_Find | LJFP_Pack | LJFP_Version | LJFP_FileList | LJFP_FileInfo | LJFP_ZipFile | LJFP_XML | LJFP_Node | LJFP_SMS4 | LJFP_MiniZ | LJFP_CRC32 | StringUtil | FileUtil |
|------|-----------|-------------|-----------|-----------|--------------|---------------|---------------|--------------|----------|-----------|----------|-----------|-----------|------------|-----------|
| **LJFP_Main** | - | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **LJFP_Option** | - | - | - | - | ✓ | - | - | - | ✓ | ✓ | - | - | - | - | - |
| **LJFP_Find** | - | ✓ | - | - | - | - | - | - | - | - | - | - | - | - | - |
| **LJFP_Pack** | - | - | - | - | - | ✓ | ✓ | ✓ | - | - | - | - | - | - | - |
| **LJFP_Version** | - | ✓ | - | - | - | - | - | - | ✓ | ✓ | - | - | - | - | - |
| **LJFP_FileList** | - | - | - | ✓ | - | - | ✓ | - | - | - | - | - | - | - | - |
| **LJFP_FileInfo** | - | - | - | - | - | - | - | - | - | - | - | - | - | ✓ | ✓ |
| **LJFP_ZipFile** | - | - | - | - | - | - | - | - | - | - | ✓ | ✓ | ✓ | - | - |
| **LJFP_XML** | - | - | - | - | - | - | - | - | - | ✓ | - | - | - | - | - |
| **LJFP_Node** | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| **LJFP_SMS4** | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| **LJFP_MiniZ** | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| **LJFP_CRC32** | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| **StringUtil** | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| **FileUtil** | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |

**图例**:
- `✓` - 存在依赖关系
- `-` - 无依赖关系

### 2.2 外部依赖库

| 依赖库 | 版本 | 用途 | 依赖模块 | 来源 |
|--------|------|------|----------|------|
| **MiniZ** | 1.14 | zlib兼容压缩库 | LJFP_MiniZ | 内置 |
| **LJXML** | - | XML解析库 | LJFP_XML | 外部 (../LJXML/) |
| **StringCover** | - | 字符串工具库 | StringUtil | 外部 (../../common/platform/utils/) |
| **zlib** | - | zlib压缩库 | 系统兼容 | Windows SDK |
| **shlwapi** | - | Windows API | FileUtil | Windows SDK |

---

## 3. 编译依赖链

### 3.1 头文件依赖顺序

```
1. LJFP_Var.h           (类型定义和函数指针)
2. LJFP_StringUtil.h    (字符串工具)
3. LJFP_FileUtil.h      (文件操作)
4. LJFP_CRC32.h         (CRC32校验)
5. LJFP_SMS4.h          (SMS4加密)
6. LJFP_MiniZ.h         (MiniZ压缩)
7. LJFP_ZipFile.h       (ZIP封装)
8. LJFP_XML.h           (XML处理)
9. LJFP_Node.h          (节点结构)
10. LJFP_Option.h       (配置管理)
11. LJFP_Find.h         (文件查找)
12. LJFP_Pack.h         (文件打包)
13. LJFP_Version.h      (版本管理)
14. LJFP_FileInfo.h     (文件信息)
15. LJFP_FileList.h     (文件列表)
16. LJFP_Main.h         (主程序)
```

### 3.2 链接顺序

```
┌─────────────────────────────────────────────────────────────────┐
│  链接顺序 (从下到上)                                              │
├─────────────────────────────────────────────────────────────────┤
│  1. LJFP_Var.h (类型定义)                                        │
│  2. LJFP_StringUtil.h (字符串工具)                               │
│  3. LJFP_FileUtil.h (文件操作)                                   │
│  4. LJFP_CRC32.h (CRC32校验)                                     │
│  5. LJFP_SMS4.h (SMS4加密)                                       │
│  6. LJFP_MiniZ.h (MiniZ压缩)                                     │
│  7. LJFP_ZipFile.h (ZIP封装)                                     │
│  8. LJFP_XML.h (XML处理)                                         │
│  9. LJFP_Node.h (节点结构)                                       │
│  10. LJFP_Option.h (配置管理)                                    │
│  11. LJFP_Find.h (文件查找)                                      │
│  12. LJFP_Pack.h (文件打包)                                      │
│  13. LJFP_Version.h (版本管理)                                   │
│  14. LJFP_FileInfo.h (文件信息)                                 │
│  15. LJFP_FileList.h (文件列表)                                  │
│  16. LJFP_Main.h (主程序入口)                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. 模块依赖详情

### 4.1 LJFP_Main 模块

**文件**: [`LJFP_Main.h`](../LJFP_Main.h)

**依赖模块**:
- [`LJFP_Option`](../LJFP_Option.h) - 配置管理
- [`LJFP_Find`](../LJFP_Find.h) - 文件查找
- [`LJFP_Pack`](../LJFP_Pack.h) - 文件打包
- [`LJFP_Version`](../LJFP_Version.h) - 版本管理
- [`LJFP_FileList`](../LJFP_FileList.h) - 文件列表
- [`LJFP_FileInfo`](../LJFP_FileInfo.h) - 文件信息
- [`LJFP_ZipFile`](../LJFP_ZipFile.h) - ZIP封装
- [`LJFP_XML`](../LJFP_XML.h) - XML处理
- [`LJFP_Node`](../LJFP_Node.h) - 节点结构
- [`LJFP_SMS4`](../LJFP_SMS4.h) - 加密功能
- [`LJFP_MiniZ`](../LJFP_MiniZ.h) - 压缩功能
- [`LJFP_CRC32`](../LJFP_CRC32.h) - CRC32校验
- [`LJFP_StringUtil`](../LJFP_StringUtil.h) - 字符串工具
- [`LJFP_FileUtil`](../LJFP_FileUtil.h) - 文件操作

**依赖关系图**:
```
LJFP_Main
├─ LJFP_Option (配置加载)
│  ├─ LJFP_XML (XML处理)
│  └─ LJFP_Node (节点结构)
├─ LJFP_Find (文件扫描)
│  └─ LJFP_Option (过滤配置)
├─ LJFP_Pack (文件打包)
│  ├─ LJFP_FileList (文件列表)
│  │  └─ LJFP_PackInfo (包信息)
│  │     └─ LJFP_FileInfo (文件信息)
│  ├─ LJFP_FileInfo (文件信息)
│  └─ LJFP_ZipFile (ZIP封装)
│     ├─ LJFP_SMS4 (加密)
│     ├─ LJFP_MiniZ (压缩)
│     └─ LJFP_CRC32 (校验)
├─ LJFP_Version (版本管理)
│  ├─ LJFP_Option (配置同步)
│  ├─ LJFP_XML (XML处理)
│  └─ LJFP_Node (节点结构)
├─ LJFP_FileList (文件列表)
│  ├─ LJFP_PackInfo (包信息)
│  └─ LJFP_FileInfo (文件信息)
├─ LJFP_FileInfo (文件信息)
│  ├─ LJFP_StringUtil (字符串转换)
│  └─ LJFP_FileUtil (文件操作)
└─ LJFP_ZipFile (ZIP封装)
   ├─ LJFP_SMS4 (加密)
   ├─ LJFP_MiniZ (压缩)
   └─ LJFP_CRC32 (校验)
```

### 4.2 LJFP_Option 模块

**文件**: [`LJFP_Option.h`](../LJFP_Option.h)

**依赖模块**:
- [`LJFP_Version`](../LJFP_Version.h) - 版本信息同步
- [`LJFP_XML`](../LJFP_XML.h) - XML配置文件解析

**依赖关系图**:
```
LJFP_Option
├─ LJFP_Version (版本信息读取)
│  ├─ LJFP_XML (XML处理)
│  └─ LJFP_Node (节点结构)
└─ LJFP_XML (配置文件保存)
   └─ LJFP_Node (节点结构)
```

### 4.3 LJFP_Find 模块

**文件**: [`LJFP_Find.h`](../LJFP_Find.h)

**依赖模块**:
- [`LJFP_Option`](../LJFP_Option.h) - 过滤规则查询

**依赖关系图**:
```
LJFP_Find
└─ LJFP_Option (过滤配置)
   ├─ LJFP_XML (XML处理)
   └─ LJFP_Node (节点结构)
```

### 4.4 LJFP_Pack 模块

**文件**: [`LJFP_Pack.h`](../LJFP_Pack.h)

**依赖模块**:
- [`LJFP_FileInfo`](../LJFP_FileInfo.h) - 文件信息管理
- [`LJFP_FileList`](../LJFP_FileList.h) - 文件列表管理
- [`LJFP_ZipFile`](../LJFP_ZipFile.h) - ZIP封装

**依赖关系图**:
```
LJFP_Pack
├─ LJFP_FileInfo (文件信息存储)
│  ├─ LJFP_StringUtil (字符串转换)
│  └─ LJFP_FileUtil (文件操作)
├─ LJFP_FileList (文件列表)
│  └─ LJFP_PackInfo (包信息)
│     └─ LJFP_FileInfo (文件信息)
└─ LJFP_ZipFile (ZIP封装)
   ├─ LJFP_SMS4 (加密)
   ├─ LJFP_MiniZ (压缩)
   └─ LJFP_CRC32 (校验)
```

### 4.5 LJFP_FileList 模块

**文件**: [`LJFP_FileList.h`](../LJFP_FileList.h)

**依赖模块**:
- [`LJFP_FileInfo`](../LJFP_FileInfo.h) - 文件信息类
- [`LJFP_PackInfo`](../LJFP_Pack.h) - 包信息类

**依赖关系图**:
```
LJFP_FileList
├─ LJFP_FileInfo (文件信息对象)
│  ├─ LJFP_StringUtil (字符串转换)
│  └─ LJFP_FileUtil (文件操作)
└─ LJFP_PackInfo (包信息管理)
   └─ LJFP_FileInfo (文件信息)
```

### 4.6 LJFP_FileInfo 模块

**文件**: [`LJFP_FileInfo.h`](../LJFP_FileInfo.h)

**依赖模块**:
- [`LJFP_StringUtil`](../LJFP_StringUtil.h) - 字符串转换
- [`LJFP_FileUtil`](../LJFP_FileUtil.h) - 文件操作

**依赖关系图**:
```
LJFP_FileInfo
├─ LJFP_StringUtil (字符串转换)
└─ LJFP_FileUtil (文件操作)
```

### 4.7 LJFP_ZipFile 模块

**文件**: [`LJFP_ZipFile.h`](../LJFP_ZipFile.h)

**依赖模块**:
- [`LJFP_SMS4`](../LJFP_SMS4.h) - 加密功能
- [`LJFP_MiniZ`](../LJFP_MiniZ.h) - 压缩功能
- [`LJFP_CRC32`](../LJFP_CRC32.h) - CRC32校验

**依赖关系图**:
```
LJFP_ZipFile
├─ LJFP_SMS4 (加密)
├─ LJFP_MiniZ (压缩)
└─ LJFP_CRC32 (校验)
```

### 4.8 LJFP_XML 模块

**文件**: [`LJFP_XML.h`](../LJFP_XML.h)

**依赖模块**:
- [`LJFP_Node`](../LJFP_Node.h) - 节点类基础

**依赖关系图**:
```
LJFP_XML
└─ LJFP_Node (节点结构基础)
```

---

## 5. 依赖冲突检测

### 5.1 潜在的依赖冲突

| 依赖项 | 冲突类型 | 冲突描述 | 解决方案 |
|--------|----------|----------|----------|
| MiniZ vs zlib | 版本冲突 | 使用MiniZ替代zlib，避免版本不兼容 | MiniZ是zlib的兼容实现 |
| LJXML vs TinyXML | XML解析冲突 | 使用LJXML替代TinyXML | LJXML是项目自研XML库 |
| StringCover vs shlwapi | 字符串处理冲突 | 使用StringCover替代shlwapi | StringCover提供跨平台支持 |

### 5.2 依赖版本管理

| 依赖库 | 当前版本 | 兼容版本 | 说明 |
|--------|----------|----------|------|
| MiniZ | 1.14 | 系统自带的zlib 1.2.x | zlib兼容 |
| zlib | - | 系统自带的zlib 1.2.x | 系统库 |
| LJXML | - | 外部版本 | 项目自研 |
| StringCover | - | 外部版本 | 项目自研 |

### 5.3 编译器要求

| 编译器 | 版本 | 说明 |
|--------|------|------|
| Visual Studio 2013 | v120 | 必须使用v120工具集 |
| C++标准 | C++98/03 | 支持C++11特性 |

---

## 6. 第三方库集成

### 6.1 MiniZ 库

**位置**: [`dependencies/LJFilePack/`](../)

**集成方式**: 头文件直接包含（`#include "LJFP_MiniZ.h"`）

**功能**:
- zlib兼容的压缩/解压缩功能
- 支持多种压缩级别（0-9）
- 提供流式和块式压缩接口

**接口兼容性**:
```cpp
// 压缩函数
int mz_compress2(unsigned char *pDest, mz_ulong *pDest_len, 
                 const unsigned char *pSource, mz_ulong source_len, int level);

// 解压缩函数
int mz_uncompress(unsigned char *pDest, mz_ulong *pDest_len, 
                 const unsigned char *pSource, mz_ulong source_len);
```

### 6.2 LJXML 库

**位置**: [`dependencies/LJXML/`](../LJXML/)

**集成方式**: 头文件直接包含（`#include "LJFP_XML.h"`）

**功能**:
- XML文件解析和生成
- 支持节点树结构
- 支持属性和子节点管理

**核心类**:
- [`LJXML::LJXML_Node`](../LJXML/Include/LJXML_Node.hpp) - XML节点类
- [`LJXML::LJXML_Document`](../LJXML/Include/LJXML_Document.hpp) - XML文档类

### 6.3 StringCover 库

**位置**: [`../../common/platform/utils/`](../../common/platform/utils/)

**集成方式**: 头文件直接包含（`#include "LJFP_StringUtil.h"`）

**功能**:
- 宽字符与窄字符互转
- 字符串分割
- 大小写转换

**核心函数**:
```cpp
// 宽字符转窄字符
std::string WStrToNum<int>(const std::wstring& InSrc);

// 窄字符转宽字符
std::wstring S2WS(const std::string& S);

// 字符串分割
std::size_t SplitStrW(const std::wstring& SourceStr, const std::wstring& DelimitStr, 
                std::vector<std::wstring>& ResultStr);
```

---

## 7. 编译与部署

### 7.1 编译环境

| 组件 | 版本要求 | 安装方式 |
|------|----------|----------|
| Visual Studio 2013 | v120 | Visual Studio 2013 Update 5 |
| Windows SDK | Windows 8.1 | 系统自带 |
| C++ 运行时库 | MSVCRT v120 | MSVCRT v120 |
| C++ 标准 | C++98/03 | C++11特性 |
| .NET Framework | - | - |

### 7.2 编译步骤

1. **准备阶段**
   - 安装 Visual Studio 2013
   - 打开 LJFilePack.sln
   - 配置生成工具集为 v120

2. **编译阶段**
   - 清理解决方案
   - 生成项目文件
   - 编译静态库（如需要）
   - 编译主程序

3. **生成阶段**
   - 生成可执行文件
   - 复制资源文件到输出目录

### 7.3 部署配置

**配置文件**:
- `Option.xml` - 主配置文件，包含所有打包规则
- `version.ljvi` - 版本信息文件
- `fl.ljpi` - 文件索引文件
- `fl.ljzip` - 加密索引文件

**输出目录**:
- 根据配置的OutputPath设置
- 默认：项目根目录下的输出目录

---

## 8. 常见问题与解决方案

### 8.1 编译问题

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| v120工具集未安装 | VS2013未安装v120工具集 | 安装VS2013 v120工具集 |
| 缺少头文件 | include路径配置错误 | 检查并添加正确的include路径 |
| 链接错误 | 依赖库路径配置错误 | 更新项目依赖配置 |
| 内存不足 | 系统内存不足 | 增加虚拟内存大小 |

### 8.2 运行时问题

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 配置文件损坏 | 配置文件格式错误 | 使用默认配置重新生成 |
| 找不到文件 | 文件路径配置错误 | 检查并修正文件路径 |
| 打包失败 | 磁盘空间不足 | 检查磁盘空间并清理 |

### 8.3 功能问题

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 文件CRC32冲突 | 文件名相同导致CRC32相同 | 检查并重命名重复文件 |
| 压缩失败 | 内存不足或磁盘空间不足 | 增加虚拟内存或清理磁盘空间 |
| 加密失败 | 密钥配置错误 | 检查并修正密钥配置 |

---

## 9. 附录

### 9.1 术语表

| 术语 | 说明 |
|------|------|
| ljfp | LJ文件打包格式 |
| ljpi | 文件索引文件格式 |
| ljzip | 加密索引文件格式 |
| ljvi | 版本信息文件格式 |
| xml | XML配置文件格式 |
| crc32 | 循环冗余校验算法 |
| sms4 | SMS4国密算法 |
| miniz | zlib兼容压缩库 |
| node | 节点数据结构 |

### 9.2 命令行参数

| 参数 | 说明 |
|------|------|
| version:0 | 指定版本索引 |
| update:1 | 指定更新索引 |
| channel:0 | 指定渠道索引 |
| extend:0 | 指定扩展索引 |
| io:0 | 指定IO索引 |
| filter:0 | 指定过滤索引 |
| pack:0 | 指定打包索引 |
| compress:0 | 指定压缩索引 |
| code:0 | 指定加密索引 |
| nopause | 禁用暂停提示 |

### 9.3 文件扩展名

| 扩展名 | 说明 |
|--------|------|
| .ljfp | 打包文件格式 |
| .ljpi | 文件索引格式 |
| .ljzip | 加密索引文件格式 |
| .ljvi | 版本信息文件格式 |
| .xml | XML配置文件格式 |
| .ljnd | 节点文件格式 |
| .exe | 可执行文件 |

---

**文档版本**: 1.0.0  
**最后更新**: 2026-01-13
