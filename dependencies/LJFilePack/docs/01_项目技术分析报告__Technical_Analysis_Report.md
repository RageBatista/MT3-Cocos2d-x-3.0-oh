# LJFilePack 技术分析报告

> **项目名称**: LJFilePack (Locojoy File Packager)
> **版本**: 1.0
> **分析日期**: 2025-01-03
> **项目类型**: 游戏资源打包与版本管理工具

---

## 目录

1. [项目概述](#1-项目概述)
2. [目录结构分析](#2-目录结构分析)
3. [技术栈分析](#3-技术栈分析)
4. [架构设计](#4-架构设计)
5. [核心模块详解](#5-核心模块详解)
6. [代码质量评估](#6-代码质量评估)
7. [依赖关系分析](#7-依赖关系分析)
8. [部署环境要求](#8-部署环境要求)
9. [已知问题与改进建议](#9-已知问题与改进建议)

---

## 1. 项目概述

### 1.1 项目简介

LJFilePack 是由乐卓网络（Locojoy）开发的**游戏资源打包与版本管理工具**，主要用于：

- **资源打包**: 将游戏资源文件打包成自定义格式的压缩包
- **版本管理**: 管理游戏客户端的版本信息和更新
- **增量更新**: 支持生成增量更新包
- **资源加密**: 支持资源文件的加密存储（SMS4算法）
- **多平台支持**: 同时支持 iOS 和 Android 平台

### 1.2 核心功能

| 功能模块 | 描述 |
|---------|------|
| 文件打包 | 将散文件打包成 .ljfp 格式 |
| 文件压缩 | 使用 MiniZ（zlib 兼容）进行压缩 |
| 文件加密 | 使用 SMS4 国密算法加密 |
| 版本控制 | 三段式版本号管理 (Major.Minor.Patch) |
| 增量更新 | 对比两个版本生成增量包 |
| 格式转换 | 支持 .ljvi/.ljpi/.ljzip/.xml 格式互转 |

### 1.3 文件格式说明

| 扩展名 | 描述 |
|--------|------|
| `.ljfp` | 打包文件格式，包含多个资源 |
| `.ljpi` | Pack Info，文件索引信息（二进制格式） |
| `.ljzip` | 加密压缩的 .ljpi 文件 |
| `.ljvi` | Version Info，版本信息（二进制格式） |
| `.ljnd` | Node Data，XML 节点二进制格式 |
| `.xml` | 可读的 XML 配置格式 |

---

## 2. 目录结构分析

### 2.1 完整目录树

```
LJFilePack/
├── Debug/                          # Debug 编译输出目录
│   ├── LJFilePack.exe             # 可执行文件
│   ├── LJFilePack.pdb             # 调试符号
│   ├── LJFilePack.log             # 日志文件
│   └── LJFilePack.tlog/           # 编译日志
├── Release/                        # Release 编译输出目录
│   ├── LJFilePack.exe             # 可执行文件
│   ├── LJFilePack.pdb             # 调试符号
│   └── LJFilePack.tlog/           # 编译日志
├── Root/                           # 测试资源目录
│   ├── A/
│   │   ├── AA/
│   │   │   └── TestAA.txt
│   │   └── TestA.txt
│   ├── B/
│   │   └── TestB.txt
│   ├── C/
│   │   └── ZD.doc
│   └── TestRoot.txt
├── docs/                           # 技术文档目录（新增）
├── LJFilePack.sln                  # Visual Studio 解决方案文件
├── LJFilePack.vcxproj              # 项目文件
├── LJFilePack.vcxproj.filters      # 项目过滤器
├── LJFilePackOption.xml            # 默认配置文件
├── LJFP_Compress.h                 # 压缩功能测试
├── LJFP_CRC32.h                    # CRC32 校验算法
├── LJFP_FileInfo.h                 # 文件信息结构定义
├── LJFP_FileUtil.h                 # 文件操作工具
├── LJFP_Find.h                     # 文件查找功能
├── LJFP_Main.h                     # 主程序入口
├── LJFP_Main_Helper.h              # 主程序辅助函数
├── LJFP_MiniZ.h                    # MiniZ 压缩库
├── LJFP_Node.h                     # XML 节点类
├── LJFP_Option.h                   # 配置管理
├── LJFP_Pack.h                     # 打包核心逻辑
├── LJFP_SMS4.h                     # SMS4 加密算法
├── LJFP_StringUtil.h               # 字符串工具
├── LJFP_Var.h                      # 全局变量和类型定义
├── LJFP_Version.h                  # 版本管理
├── LJFP_XML.h                      # XML 解析器
└── LJFP_ZipFile.h                  # 文件压缩加密包装
```

### 2.2 文件分类统计

| 类别 | 文件数 | 文件列表 |
|------|--------|----------|
| **头文件** | 18 | 所有 .h 文件 |
| **源文件** | 1 | LJFP_Main.h（含 main 函数） |
| **项目文件** | 3 | .sln, .vcxproj, .vcxproj.filters |
| **配置文件** | 1 | LJFilePackOption.xml |
| **输出目录** | 2 | Debug/, Release/ |
| **文档目录** | 1 | docs/ |
| **测试数据** | 1 | Root/ |

### 2.3 代码规模估算

```
总行数: 约 3,500+ 行
核心代码: 约 2,500 行
注释和空行: 约 1,000 行
```

---

## 3. 技术栈分析

### 3.1 开发语言与框架

| 技术 | 版本 | 用途 |
|------|------|------|
| **C++** | C++11 | 主要开发语言 |
| **STL** | 标准 | 容器、字符串、算法 |
| **Visual Studio** | 2013 (v120) | IDE 和编译器 |
| **Windows SDK** | Win32 | 平台 API |

### 3.2 核心依赖库

| 库名称 | 版本 | 用途 | 许可证 |
|--------|------|------|--------|
| **MiniZ** | Custom | zlib 兼容的压缩库 | MIT/Public Domain |
| **SMS4** | Custom | 国密 SM4 分组密码 | 国密标准 |
| **shlwapi** | Windows | Shell 轻量级工具库 | Windows SDK |
| **platform** | Internal | 公共平台库（内部） | - |

### 3.3 编译配置

```xml
<!-- 关键编译选项 -->
<PlatformToolset>v120</PlatformToolset>    <!-- VS2013 工具集 -->
<CharacterSet>Unicode</CharacterSet>        <!-- Unicode 字符集 -->
<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>
<WholeProgramOptimization>true</WholeProgramOptimization>
```

---

## 4. 架构设计

### 4.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         LJFilePack 架构                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   命令行参数  │───▶│  配置管理器   │───▶│   工作流引擎   │      │
│  │   解析模块    │    │  (Option)    │    │  (Workflow)   │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│                                                         │        │
│                                                         ▼        │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   文件扫描器   │◀───│   任务调度器   │───▶│   文件打包器   │      │
│  │   (Find)     │    │  (Scheduler)  │    │   (Pack)     │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│         │                    │                    │             │
│         ▼                    ▼                    ▼             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   文件过滤     │    │   CRC32 校验   │    │   压缩加密     │      │
│  │  (Filter)    │    │   (CRC32)     │    │ (MiniZ/SMS4) │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│                                                         │        │
│                                                         ▼        │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   版本管理器   │    │   增量更新生成  │    │   格式转换器   │      │
│  │  (Version)   │    │ (UpdatePack)  │    │ (Converter)  │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 模块依赖关系

```
LJFP_Main.h (入口)
    │
    ├─▶ LJFP_Main_Helper.h (辅助功能)
    │       │
    │       ├─▶ LJFP_Pack.h (打包核心)
    │       │       │
    │       │       ├─▶ LJFP_FileInfo.h (文件信息)
    │       │       ├─▶ LJFP_ZipFile.h (压缩加密)
    │       │       ├─▶ LJFP_SMS4.h (SMS4加密)
    │       │       └─▶ LJFP_MiniZ.h (MiniZ压缩)
    │       │
    │       ├─▶ LJFP_Find.h (文件扫描)
    │       │       └─▶ LJFP_FileUtil.h (文件工具)
    │       │
    │       └─▶ LJFP_Option.h (配置管理)
    │               │
    │               ├─▶ LJFP_XML.h (XML解析)
    │               │       └─▶ LJFP_Node.h (节点类)
    │               │               └─▶ LJFP_StringUtil.h (字符串)
    │               │
    │               └─▶ LJFP_Version.h (版本管理)
    │
    ├─▶ LJFP_CRC32.h (CRC32校验)
    └─▶ LJFP_Var.h (类型定义)
```

### 4.3 数据流图

```
原始资源文件
      │
      ▼
┌─────────────┐
│  文件扫描    │ FindFiles()
└─────────────┘
      │
      ▼
┌─────────────┐
│  文件过滤    │ IsFilterFile()
└─────────────┘
      │
      ▼
┌─────────────┐
│  读取文件    │ LoadData()
└─────────────┘
      │
      ▼
┌─────────────┐
│  压缩处理    │ mz_compress2()
└─────────────┘
      │
      ▼
┌─────────────┐
│  加密处理    │ SMS4Ex()
└─────────────┘
      │
      ▼
┌─────────────┐
│  写入输出    │ SaveData()
└─────────────┘
      │
      ▼
输出资源包
```

---

## 5. 核心模块详解

### 5.1 LJFP_Option - 配置管理模块

**职责**: 管理打包工具的所有配置项

**主要配置项**:
```cpp
class LJFP_Option {
    // 版本配置
    static int InitVersion(std::wstring OptionIndexVersion);

    // 更新配置 (URL、网络类型)
    static int InitUpdate(std::wstring OptionIndexUpdate);

    // 渠道配置
    static int InitChannel(std::wstring OptionIndexChannel);

    // 扩展配置
    static int InitExtend(std::wstring OptionIndexExtend);

    // 过滤器配置
    static int InitOptionOne(...);

    // 文件判断函数
    static int IsFilterDir(...);
    static int IsFilterFile(...);
    static int IsPackFile(...);
    static int IsCompressFile(...);
    static int IsCodeFile(...);
};
```

**配置文件结构** (LJFilePackOption.xml):
```xml
<Root>
    <Version>      <!-- 版本信息 -->
    <Update>       <!-- 更新服务器信息 -->
    <Channel>      <!-- 渠道信息 -->
    <Extend>       <!-- 扩展信息 -->
    <IO>           <!-- 输入输出配置 -->
    <Filter>       <!-- 文件过滤规则 -->
    <Pack>         <!-- 打包配置 -->
    <Compress>     <!-- 压缩配置 -->
    <Code>         <!-- 加密配置 -->
</Root>
```

### 5.2 LJFP_Pack - 打包核心模块

**职责**: 文件打包的核心逻辑实现

**核心类**:
```cpp
// 单个文件处理
class LJFP_File {
    unsigned int m_Pack;           // 所属包号
    unsigned int m_Pos;            // 包内位置
    unsigned int m_Size;           // 文件大小
    unsigned int m_CRC32;          // CRC32校验值
    unsigned char* m_Data;         // 文件数据

    // 处理流程
    int LoadData();        // 加载原始数据
    int CompressData();    // 压缩
    int CodeData();        // 加密
    int SaveData();        // 保存
    int ReleaseData();     // 释放内存
};

// 打包管理器
class LJFP_Pack {
    unsigned int m_PackMaxSize;    // 单包最大大小 (50MB)
    std::vector<LJFP_File*> m_FileArr;

    int AddFile(LJFP_File* pFile);
    int CheckSameCRC32();           // 检查重复
    int ExportFileInfo(...);        // 导出文件信息
};

// 文件列表管理
class LJFP_FileList {
    LJFP_Pack* m_FilePack;      // 需打包文件
    LJFP_Pack* m_FilePackNo;    // 散文件
    LJFP_Pack* m_FilePackAll;   // 所有文件

    int ExportRes(...);         // 导出资源
};
```

### 5.3 LJFP_FileInfo - 文件信息模块

**职责**: 定义和序列化文件信息结构

**数据结构**:
```cpp
struct LJFP_FileInfo {
    unsigned int m_FileArea;         // 文件区域
    unsigned int m_PackIndex;        // 包索引
    unsigned int m_Pos;              // 包内位置
    unsigned int m_Size;             // 文件大小
    unsigned int m_CRC32;            // CRC32
    unsigned int m_CompressType;     // 压缩类型
    unsigned int m_CodeType;         // 加密类型
    unsigned int m_SizeOriginal;     // 原始大小
    unsigned int m_CRC32Original;    // 原始CRC32
    unsigned int m_PathFileNameCRC32;// 路径文件名CRC32
};

class LJFP_PackInfo {
    LJFP_FileInfoMap m_FileInfoMap;  // CRC32索引
    LJFP_FileInfoArr m_FileInfoArr;  // 文件数组
    LJFP_PackInfoOneMap m_PackInfoOne; // 包信息

    LJFP_FileInfo* GetFileInfo(std::wstring wstrPathFileName);
    LJFP_FileInfo* FindFileInfo(unsigned int uiCRC32);
};
```

### 5.4 LJFP_Version - 版本管理模块

**职责**: 版本号的解析和管理

**版本号格式**: `Major.Minor.Patch` (255.4095.4095)
```cpp
class LJFP_Version {
    static unsigned int VersionCaption2Version(std::wstring VersionCaption);
    static std::wstring Version2VersionCaption(unsigned int Version);

    // 版本信息
    unsigned int m_uiVersion;          // 当前版本
    unsigned int m_uiVersionBase;      // 基准版本
    unsigned int m_uiVersionMinimum;   // 最低兼容版本

    // 更新信息
    URLInfoArr m_URLInfoArr;           // 更新服务器列表
    std::wstring m_AppURL;             // 应用商店URL

    // 渠道信息
    unsigned int m_uiChannel;
    std::wstring m_ChannelCaption;

    // 扩展信息
    std::map<std::wstring, std::wstring> m_ExtendMap;
};
```

### 5.5 LJFP_ZipFile - 压缩加密模块

**职责**: 文件的压缩和加密处理

**处理流程**:
```cpp
class LJFP_ZipFile {
    // 压缩加密流程: 原始数据 -> 压缩 -> 加密 -> 输出
    int ZipStream(std::ifstream& FSSrc, std::ofstream& FSDst);

    // 解密解压流程: 输入 -> 解密 -> 解压 -> 原始数据
    int UnZipStream(std::ifstream& FSSrc, std::ofstream& FSDst);

    unsigned int m_uiKey;              // 文件标识
    CRC32_Func m_CRC32Func;            // CRC32函数
    Zip_Func m_ZipFunc;                // 压缩函数
    UnZip_Func m_UnZipFunc;            // 解压函数
    SMS4_Func m_SMS4Func;              // 加密函数
    DeSMS4_Func m_DeSMS4Func;          // 解密函数
    std::string m_strPassword;         // 加密密钥
};
```

**文件格式**:
```
+--------+--------+--------+--------+--------+--------+
|  Key   | SMS4   |  Data  |  Zip   |  Src   | CRC32  |
|  4B    |  4B    |  N B   |  4B    |  4B    |  4B    |
+--------+--------+--------+--------+--------+--------+
```

### 5.6 LJFP_SMS4 - 加密算法模块

**职责**: 国密 SM4 分组密码算法实现

**算法特点**:
- 分组长度: 128位
- 密钥长度: 128位
- 加密模式: ECB (电子密码本)

### 5.7 LJFP_MiniZ - 压缩算法模块

**职责**: zlib 兼容的压缩算法

**函数接口**:
```cpp
// 压缩
int mz_compress2(unsigned char *pDest, unsigned int *pDest_len,
                  const unsigned char *pSource, unsigned int source_len,
                  int level);

// 解压
int mz_uncompress(unsigned char *pDest, unsigned int *pDest_len,
                  const unsigned char *pSource, unsigned int source_len);
```

### 5.8 LJFP_Find - 文件扫描模块

**职责**: 递归扫描目录获取文件列表

**核心函数**:
```cpp
class LJFP_Find {
    std::wstring m_RootPath;
    Find_File_Func m_FindFunc;    // 文件回调

    int FindFiles(std::wstring wsPath,
                  std::wstring wsParentPath,
                  std::wstring wsFileNameFilter);
};
```

---

## 6. 代码质量评估

### 6.1 代码规范

| 方面 | 评价 | 说明 |
|------|------|------|
| **命名规范** | ⭐⭐⭐ | 类名使用 LJFP_ 前缀，成员变量使用 m_ 前缀 |
| **注释覆盖** | ⭐⭐ | 代码注释较少，主要靠命名理解意图 |
| **错误处理** | ⭐⭐⭐ | 有基本的错误返回值，但缺少异常处理 |
| **内存管理** | ⭐⭐⭐ | 手动内存管理，正确使用 new/delete |
| **代码复用** | ⭐⭐⭐ | 良好的模块划分，函数职责单一 |

### 6.2 优点分析

1. **模块化设计良好**: 各模块职责清晰，耦合度低
2. **配置灵活**: 通过 XML 配置文件支持多种打包策略
3. **功能完整**: 支持压缩、加密、版本管理、增量更新
4. **跨平台路径**: 使用了 `#ifdef ANDROID` 宏支持移动平台

### 6.3 潜在问题

1. **内存管理**: 使用手动内存管理，存在内存泄漏风险
2. **错误处理**: 缺少统一的错误处理机制
3. **日志系统**: 日志输出简单，缺少分级和持久化
4. **测试覆盖**: 缺少单元测试和集成测试
5. **硬编码**: 加密密钥 "locojoy123456789" 硬编码在代码中

### 6.4 代码示例分析

**良好的模块化设计**:
```cpp
// 清晰的接口定义
typedef unsigned int(*CRC32_Func)(unsigned int crc,
                                   const unsigned char* ptr,
                                   size_t buf_len);
typedef int(*Zip_Func)(unsigned char *pDest, unsigned int *pDest_len,
                       const unsigned char *pSource,
                       unsigned int source_len, int level);
typedef void(*SMS4_Func)(unsigned char* inBuff, unsigned char* ouBuff,
                         unsigned int uiSize, std::string strPassword);
```

**使用函数指针实现解耦**:
```cpp
class LJFP_ZipFile {
    CRC32_Func m_CRC32Func;    // 注入的CRC32函数
    Zip_Func m_ZipFunc;        // 注入的压缩函数
    SMS4_Func m_SMS4Func;      // 注入的加密函数
    // ... 允许替换不同的实现
};
```

---

## 7. 依赖关系分析

### 7.1 外部依赖

```
LJFilePack
    │
    ├── common/platform/utils/StringUtil.cpp  (内部公共库)
    │
    ├── shlwapi.lib                          (Windows Shell Light)
    │       └── PathFileExistsW, Path functions
    │
    └── Windows SDK
            ├── stdio.h, stdlib.h
            ├── string.h, fstream
            └── io.h, direct.h
```

### 7.2 内部模块依赖

```
LJFP_Main.h
    │
    ├── LJFP_Main_Helper.h
    │       ├── LJFP_Pack.h ──▶ LJFP_FileInfo.h
    │       │                       │
    │       ├── LJFP_Find.h ────────┤
    │       │                       │
    │       ├── LJFP_FileUtil.h ────┤
    │       │                       │
    │       ├── LJFP_Option.h ──────┤
    │       │                       │
    │       └── LJFP_Version.h ┈────┘
    │
    ├── LJFP_CRC32.h
    ├── LJFP_MiniZ.h
    ├── LJFP_SMS4.h
    └── LJFP_XML.h ──▶ LJFP_Node.h ──▶ LJFP_StringUtil.h
```

---

## 8. 部署环境要求

### 8.1 编译环境

| 要求 | 版本/规格 |
|------|----------|
| **操作系统** | Windows 7+ |
| **IDE** | Visual Studio 2013 |
| **Platform Toolset** | v120 (VS2013) |
| **C++ 标准** | C++11 |
| **字符集** | Unicode |

### 8.2 运行环境

| 要求 | 版本/规格 |
|------|----------|
| **操作系统** | Windows XP+ |
| **运行时库** | MSVCR120.dll |
| **磁盘空间** | 根据打包资源大小 |
| **内存** | 最小 512MB |

### 8.3 编译命令

```batch
# Debug 构建
msbuild LJFilePack.vcxproj /p:Configuration=Debug /p:Platform=Win32 /v:m

# Release 构建
msbuild LJFilePack.vcxproj /p:Configuration=Release /p:Platform=Win32 /v:m
```

### 8.4 使用示例

```batch
# 基本打包命令
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:0 filter:0 pack:0 compress:0 code:0 nopause

# 转换版本文件格式
LJFilePack.exe verljvi2xml:ver.ljvi

# 解包资源
LJFilePack.exe unpack:fl.ljpi

# 生成增量更新包
LJFilePack.exe makeupdatepack:res0/|res1/|resNew/

# 显示帮助
LJFilePack.exe ?
```

---

## 9. 已知问题与改进建议

### 9.1 已知问题

| 问题 | 影响 | 优先级 |
|------|------|--------|
| 加密密钥硬编码 | 安全风险 | 高 |
| 缺少错误日志 | 调试困难 | 中 |
| 内存手动管理 | 潜在泄漏 | 中 |
| 中文路径可能乱码 | 兼容性问题 | 低 |
| 大文件处理无进度 | 用户体验 | 低 |

### 9.2 改进建议

#### 9.2.1 安全性改进

```cpp
// 建议: 使用配置文件或环境变量存储密钥
// 当前:
SMS4Ex(m_Data, m_DataCode, m_SizeCode, "locojoy123456789");

// 建议:
std::string password = GetPasswordFromConfig();
SMS4Ex(m_Data, m_DataCode, m_SizeCode, password.c_str());
```

#### 9.2.2 内存管理改进

```cpp
// 建议: 使用智能指针
#include <memory>

class LJFP_File {
    std::unique_ptr<unsigned char[]> m_DataOriginal;
    std::unique_ptr<unsigned char[]> m_DataCompress;
    std::unique_ptr<unsigned char[]> m_DataCode;
    // 自动释放，无需手动 delete
};
```

#### 9.2.3 日志系统改进

```cpp
// 建议: 实现分级日志
enum class LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR
};

class Logger {
    void Log(LogLevel level, const wchar_t* format, ...);
    void SetLogFile(const std::wstring& filePath);
};
```

#### 9.2.4 错误处理改进

```cpp
// 建议: 使用异常处理或错误码枚举
enum class ErrorCode {
    SUCCESS = 0,
    FILE_NOT_FOUND,
    CRC32_MISMATCH,
    COMPRESS_FAILED,
    DECRYPT_FAILED
};

ErrorCode LoadDataSafe();
```

#### 9.2.5 进度显示改进

```cpp
// 建议: 添加进度回调
typedef void(*ProgressCallback)(size_t current, size_t total);

class LJFP_FileList {
    ProgressCallback m_ProgressCallback;
    void SetProgressCallback(ProgressCallback callback);
};
```

### 9.3 功能扩展建议

1. **多线程支持**: 大文件使用多线程压缩
2. **校验和增强**: 支持 SHA256 等更强校验
3. **增量压缩**: 支持类似 rsync 的块级增量
4. **配置校验**: 启动时校验配置文件完整性
5. **单元测试**: 添加 Google Test 测试框架

---

## 附录

### A. 命令行参数完整列表

```
参数列表:
  version:N       使用第N个版本配置
  update:N        使用第N个更新配置
  channel:N       使用第N个渠道配置
  extend:N        使用第N个扩展配置
  io:N            使用第N个IO配置
  filter:N        使用第N个过滤配置
  pack:N          使用第N个打包配置
  compress:N      使用第N个压缩配置
  code:N          使用第N个加密配置
  nopause         不显示等待提示

工具命令:
  getversionnum   版本号转数字
  getversioncaption 数字转版本号
  verljvi2xml     LJVI转XML
  verxml2ljvi     XML转LJVI
  ljpi2xml        LJPI转XML
  ljzip2xml       LJZIP转XML
  decode:file     解密文件
  unzip:file      解压文件
  decodeunzip:file 解密并解压
  unpack:file     解包
  makeupdatepack:base|new|result  生成增量包
  makeupdatepackall:configfile    批量生成增量包
  ?               显示帮助
```

### B. 版本号编码规则

```
格式: Major.Minor.Patch (范围: 255.4095.4095)

编码:
  Major: 8位  (0-255)   → bits 24-31
  Minor: 12位 (0-4095)  → bits 12-23
  Patch: 12位 (0-4095)  → bits 0-11

示例:
  "1.0.0"   → 0x01000000 = 16777216
  "0.1.0"   → 0x00001000 = 4096
  "1.2.3"   → 0x01012003 = 16783619
```

### C. 文件类型默认配置

| 类型 | 打包 | 压缩 | 加密 | 说明 |
|------|------|------|------|------|
| ogg | ❌ | ❌ | ❌ | 已压缩音频 |
| mp3 | ❌ | ❌ | ❌ | 已压缩音频 |
| mp4 | ❌ | ❌ | ❌ | 已压缩视频 |
| ini | ❌ | ⚠️ | ⚠️ | 可配置 |
| png | ✅ | ❌ | ⚠️ | 可配置 |
| 其他 | ✅ | ✅ | ✅ | 默认处理 |

### D. 配置文件示例

```xml
<?xml version="1.0" encoding="utf-8"?>
<Root>
    <Version Count="2">
        <0 Description="IOS">
            <VersionInfo VersionCaption="1.0.0"
                         VersionCaptionBase="1.0.0"
                         VersionCaptionMinimum="1.0.0"/>
        </0>
        <1 Description="Android">
            <VersionInfo VersionCaption="1.0.0"
                         VersionCaptionBase="1.0.0"
                         VersionCaptionMinimum="1.0.0"/>
        </1>
    </Version>
    <IO Count="4">
        <0 FindPath="Root/" OutputPath="IOS_Pack/" OutputType="Pack"/>
        <1 FindPath="Root/" OutputPath="IOS_File/" OutputType="File"/>
        <2 FindPath="Root/" OutputPath="Android_Pack/" OutputType="Pack"/>
        <3 FindPath="Root/" OutputPath="Android_File/" OutputType="File"/>
    </IO>
</Root>
```

---

**文档版本**: 1.0
**分析完成日期**: 2025-01-03
**分析者**: Claude AI Assistant
