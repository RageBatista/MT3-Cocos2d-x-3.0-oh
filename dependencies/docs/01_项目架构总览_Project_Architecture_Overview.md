# 01_项目架构总览_Project_Architecture_Overview

> **项目名称**: MT3 Dependencies（游戏开发依赖库集合）
> **文档版本**: 1.0
> **更新日期**: 2026-04-22
> **文档类型**: 架构设计文档

---

## 目录

1. [项目概述](#1-项目概述)
2. [整体架构](#2-整体架构)
3. [核心子系统](#3-核心子系统)
4. [技术栈](#4-技术栈)
5. [依赖关系](#5-依赖关系)
6. [数据流](#6-数据流)
7. [部署架构](#7-部署架构)

---

## 1. 项目概述

### 1.1 项目简介

MT3 Dependencies 是一个完整的游戏开发依赖库集合，为游戏客户端提供资源管理、UI框架、音频处理、网络通信等核心功能。

### 1.2 核心目标

- **资源管理**: 提供高效的资源打包、压缩、加密和版本管理
- **UI框架**: 提供跨平台的GUI界面和布局系统
- **多媒体**: 支持音频、图像等多媒体资源的处理
- **网络**: 提供HTTP网络通信能力
- **跨平台**: 支持Windows、iOS、Android多平台

### 1.3 主要子系统

| 子系统 | 功能描述 | 技术方案 |
|--------|----------|----------|
| **资源打包系统** | LJFilePack | 自定义格式 + SMS4加密 + zlib压缩 |
| **资源解包系统** | SuperLJFilePackUnpack | 逆向解包 + 完整性校验 |
| **布局转换系统** | BinLayoutConvert | XML↔BinLayout双向转换 |
| **UI框架** | CEGUI + wxWidgets | 跨平台GUI |
| **音频系统** | libogg + libvorbis | Ogg Vorbis音频编解码 |
| **图像系统** | libpng + SILLY | PNG图像处理 |
| **字体系统** | freetype | 字体渲染 |
| **网络系统** | ASIHTTPRequest | HTTP网络请求 |
| **调试工具** | VLD | 内存泄漏检测 |

---

## 2. 整体架构

### 2.1 分层架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           应用层 (Application Layer)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  游戏客户端   │  │  编辑器工具   │  │  资源转换工具 │  │  调试分析工具 │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           框架层 (Framework Layer)                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    CEGUI UI Framework                                 │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │  │
│  │  │  布局系统     │  │  事件系统     │  │  渲染系统     │              │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                    wxWidgets GUI Framework                            │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │  │
│  │  │  原生控件     │  │  事件处理     │  │  绘图系统     │              │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           服务层 (Service Layer)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  资源管理服务 │  │  音频服务     │  │  网络服务     │  │  日志服务     │ │
│  │  LJFilePack  │  │  libogg      │  │  ASIHTTP     │  │  自定义日志    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  图像服务     │  │  字体服务     │  │  调试服务     │  │  配置服务     │ │
│  │  libpng/SILLY│  │  freetype    │  │  VLD         │  │  LJXML       │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           基础层 (Foundation Layer)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  压缩算法     │  │  加密算法     │  │  正则表达式   │  │  XML解析      │ │
│  │  MiniZ/zlib  │  │  SMS4        │  │  PCRE        │  │  LJXML       │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  字符串工具   │  │  文件工具     │  │  崩溃处理     │  │  内存管理     │ │
│  │  StringUtil  │  │  FileUtil    │  │  Breakpad    │  │  VLD         │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                           平台层 (Platform Layer)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Windows     │  │  iOS         │  │  Android     │  │  macOS       │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 模块依赖关系

```
                    ┌─────────────────┐
                    │   应用程序       │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ↓              ↓              ↓
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │  CEGUI   │   │wxWidgets │   │ LJFilePack│
        └────┬─────┘   └────┬─────┘   └────┬─────┘
             │             │             │
             └──────────────┼─────────────┘
                          ↓
              ┌─────────────────────────┐
              │    基础服务层          │
              │  (libpng, freetype,    │
              │   libogg, ASIHTTP,     │
              │   PCRE, LJXML)         │
              └──────────┬────────────┘
                         ↓
              ┌─────────────────────────┐
              │    核心算法层          │
              │  (MiniZ, SMS4, CRC32) │
              └──────────┬────────────┘
                         ↓
              ┌─────────────────────────┐
              │    平台抽象层          │
              │  (Windows/iOS/Android) │
              └─────────────────────────┘
```

---

## 3. 核心子系统

### 3.1 资源打包系统 (LJFilePack)

**功能**: 游戏资源的打包、压缩、加密和版本管理

**核心模块**:
- `LJFP_Pack.h`: 打包核心逻辑
- `LJFP_ZipFile.h`: 加密压缩文件处理
- `LJFP_SMS4.h`: SMS4加密算法
- `LJFP_MiniZ.h`: MiniZ压缩库
- `LJFP_CRC32.h`: CRC32校验算法
- `LJFP_Version.h`: 版本管理

**文件格式**:
- `.ljfp`: 打包文件（资源包）
- `.ljpi`: 索引文件（二进制）
- `.ljzip`: 加密索引文件
- `.ljvi`: 版本信息文件
- `.ljnd`: XML节点二进制格式

**技术特点**:
- 支持散文件和打包文件混合存储
- SMS4国密加密（密钥: "locojoy123456789"）
- zlib压缩（兼容MiniZ）
- CRC32完整性校验
- 三段式版本号（Major.Minor.Patch）

### 3.2 资源解包系统 (SuperLJFilePackUnpack)

**功能**: LJFilePack 资源包的逆向解包、路径恢复、失败诊断与结果审阅

**核心模块**:
- `SLJFP_Unpack.h/cpp`: 解包核心类
- `SLJFP_UnpackIndexIO.*`: `.ljpi/.ljzip` 索引加载与边界校验
- `SLJFP_UnpackSourceIO.*`: 散文件 / `.ljfp` 源数据读取
- `SLJFP_PathMappingGenerator.*`: 路径映射生成
- `SLJFP_FileTypeDetector.*`: 文件类型探测
- `SLJFP_AndroidBinaryKey.*`: Android `libgame.so` key 提取
- `Workflow*`: GUI 审阅与失败导出工作流

**支持格式**:
- `.ljpi`: 索引文件解析
- `.ljzip`: 加密索引文件解密解压
- `.ljfp`: 包文件提取

**技术特点**:
- 完整的解密解压管道
- CRC32 完整性校验
- 自动 / 固定解密模式切换
- 输出路径 sidecar 审计
- GUI / CLI / 诊断 CLI 三种入口
- 可配置的解包选项与失败诊断数据模型

### 3.3 布局转换系统 (BinLayoutConvert)

**功能**: CEGUI布局文件的XML与二进制格式双向转换

**核心组件**:
- `BinLayoutConvert`: CLI批量转换工具
- `BinLayoutStudio`: GUI双向转换工具

**文件格式**:
- `.layout` (XML): CEGUI布局文件
- `.layout` (BinLayout): 二进制布局文件（魔数: LBFM）

**技术特点**:
- XML ↔ BinLayout双向转换
- 支持v1版本格式
- 原子写入保护
- 多线程并行处理
- 属性类型系统（224种属性）

### 3.4 UI框架系统 (CEGUI + wxWidgets)

**CEGUI**:
- 跨平台GUI框架
- 布局系统（XML/BinLayout）
- 事件系统
- 渲染系统

**wxWidgets**:
- 原生GUI控件
- 事件处理
- 绘图系统
- 版本: 3.0.5

### 3.5 多媒体系统

**音频系统** (libogg + libvorbis):
- Ogg Vorbis音频编解码
- 版本: libogg-1.3.6, libvorbis-1.3.7

**图像系统** (libpng + SILLY):
- PNG图像处理
- 版本: libpng-1.4.5, SILLY-0.1.0

**字体系统** (freetype):
- 字体渲染
- 版本: freetype-2.4.9

### 3.6 网络系统 (ASIHTTPRequest)

**功能**: HTTP网络请求

**特点**:
- 异步请求
- 缓存支持
- 代理支持
- 断点续传

### 3.7 调试工具 (VLD + Breakpad)

**VLD** (Visual Leak Detector):
- 内存泄漏检测
- Windows平台

**Breakpad** (Google):
- 崩溃报告
- 跨平台支持

---

## 4. 技术栈

### 4.1 开发语言

| 语言 | 版本 | 用途 |
|------|------|------|
| C++ | C++11 | 主要开发语言 |
| Objective-C | - | iOS平台支持 |
| Lua | - | 脚本支持 |

### 4.2 编译工具

| 工具 | 版本 | 平台 |
|------|------|------|
| Visual Studio | 2013 (v120) | Windows |
| GCC | 4.8+ | Linux |
| Xcode | - | iOS/macOS |
| Android NDK | - | Android |

### 4.3 核心库

| 库名 | 版本 | 用途 | 许可证 |
|------|------|------|--------|
| wxWidgets | 3.0.5 | GUI框架 | wxWindows Library Licence |
| CEGUI | 自定义 | UI框架 | MIT |
| MiniZ | 自定义 | 压缩 | Public Domain |
| libogg | 1.3.6 | Ogg容器 | BSD |
| libvorbis | 1.3.7 | Vorbis音频 | BSD |
| libpng | 1.4.5 | PNG图像 | libpng license |
| freetype | 2.4.9 | 字体渲染 | FTL/GPL |
| PCRE | 8.31 | 正则表达式 | BSD |
| Breakpad | - | 崩溃报告 | BSD |

### 4.4 算法

| 算法 | 用途 | 实现 |
|------|------|------|
| SMS4 | 加密 | 自定义（国密SM4） |
| zlib | 压缩 | MiniZ |
| CRC32 | 校验 | 自定义 |
| Vorbis | 音频编码 | libvorbis |

---

## 5. 依赖关系

### 5.1 模块依赖图

```
LJFilePack
├── LJFP_SMS4 (SMS4加密)
├── LJFP_MiniZ (zlib压缩)
├── LJFP_CRC32 (CRC32校验)
├── LJFP_XML (XML解析)
├── LJFP_FileUtil (文件工具)
└── LJFP_StringUtil (字符串工具)

SuperLJFilePackUnpack
├── LJFP_SMS4
├── LJFP_MiniZ
├── LJFP_CRC32
├── LJFP_FileUtil
└── LJFP_StringUtil

BinLayoutConvert
├── CEGUI (UI框架)
│   ├── BinLayout (二进制布局)
│   │   ├── v1 (版本1序列化)
│   │   └── CEGUIPropertyIds (属性定义)
│   ├── CEGUIString (字符串)
│   └── CEGUIDefaultLogger (日志)
└── wxWidgets (GUI支持，可选)

CEGUI
├── freetype (字体)
├── libpng (图像)
└── SILLY (图像加载)

wxWidgets
├── libpng (图像)
├── zlib (压缩)
├── expat (XML)
└── 自定义渲染后端
```

### 5.2 编译依赖

**Windows**:
- Visual Studio 2013
- Windows SDK 8.1
- DirectX SDK (可选)

**iOS**:
- Xcode
- iOS SDK

**Android**:
- Android NDK
- Android SDK

---

## 6. 数据流

### 6.1 资源打包流程

```
原始资源文件
    ↓
文件扫描 (LJFP_Find)
    ↓
文件信息收集 (LJFP_FileInfo)
    ↓
数据加载 (LJFP_File::LoadData)
    ↓
压缩处理 (LJFP_File::CompressData)
    ↓
加密处理 (LJFP_File::CodeData)
    ↓
打包写入 (LJFP_Pack)
    ↓
生成索引文件 (.ljpi)
    ↓
加密索引 (.ljzip)
    ↓
生成版本信息 (.ljvi)
```

### 6.2 资源解包流程

```
加载索引文件 (.ljpi/.ljzip)
    ↓
解密解压 (.ljzip)
    ↓
解析文件列表
    ↓
遍历文件列表
    ↓
读取文件数据
    ↓
解密处理 (如果加密)
    ↓
解压处理 (如果压缩)
    ↓
CRC32校验
    ↓
写入输出文件
```

### 6.3 布局转换流程

**XML → BinLayout**:
```
XML文件 (.layout)
    ↓
LJXMLParser解析
    ↓
XMLFileData AST
    ↓
BinLayout序列化
    ↓
BinLayout文件 (LBFM)
```

**BinLayout → XML**:
```
BinLayout文件 (LBFM)
    ↓
BinCodec解码
    ↓
XMLFileData AST
    ↓
XMLWriter生成
    ↓
XML文件 (.layout)
```

---

## 7. 部署架构

### 7.1 目录结构

```
dependencies/
├── LJFilePack/              # 资源打包工具
│   ├── Release/            # 编译输出
│   ├── Debug/              # 调试输出
│   ├── docs/               # 文档
│   └── *.h                 # 头文件
├── SuperLJFilePackUnpack/  # 资源解包工具
│   ├── docs/               # 工具内权威文档
│   ├── examples/           # 主 CLI 示例
│   ├── gui/                # wxWidgets GUI
│   ├── include/            # 公开头文件
│   ├── libs/               # 内嵌依赖头
│   ├── src/                # 源代码
│   ├── test/               # 内置测试
│   └── tools/              # 诊断 CLI / 脚本 / 运行时辅助
├── BinLayoutConvert/        # 布局转换工具
│   ├── BinLayoutConvert/    # CLI工具
│   ├── BinLayoutStudio/     # GUI工具
│   └── docs/               # 文档
├── cegui/                 # CEGUI框架
├── wxWidgets-3.0.5/        # wxWidgets框架
├── libogg-1.3.6/          # Ogg容器库
├── libvorbis-1.3.7/       # Vorbis音频库
├── libpng-1.4.5/          # PNG图像库
├── freetype-2.4.9/         # 字体库
├── pcre-8.31/             # 正则表达式库
├── asihttp/               # HTTP网络库
├── google-breakpad/       # 崩溃报告库
├── vld/                  # 内存泄漏检测
└── docs/                  # 统一文档目录
```

### 7.2 编译输出

**LJFilePack**:
- `Release/LJFilePack.exe`
- `Debug/LJFilePack.exe`

**SuperLJFilePackUnpack**:
- `build/lib/Release/SuperLJFilePackUnpack.lib`（本地生成）
- `build/bin/Release/ljfp-unpack.exe`（本地生成）
- `build/bin/Release/ljfp-unpack-diag.exe`（本地生成）
- `build/bin/Release/LJFilePackUnpacker.exe`（GUI 构建开启时，本地生成）

**BinLayoutConvert**:
- `Release/BinLayoutConvert.exe`
- `BinLayoutStudio/Release/BinLayoutStudio.exe`

---

## 8. 设计原则

### 8.1 模块化设计

- 每个子系统独立封装
- 清晰的接口定义
- 最小化模块间耦合

### 8.2 跨平台支持

- 平台抽象层
- 条件编译
- 统一的API接口

### 8.3 性能优化

- 内存池管理
- 流式处理
- 多线程支持
- 缓存机制

### 8.4 安全性

- 资源加密（SMS4）
- 完整性校验（CRC32）
- 崩溃报告（Breakpad）
- 内存泄漏检测（VLD）

### 8.5 可扩展性

- 插件架构
- 配置驱动
- 回调机制

---

## 9. 未来规划

### 9.1 短期目标

- 完善单元测试覆盖
- 优化性能瓶颈
- 增强错误处理
- 改进文档质量

### 9.2 中期目标

- 支持新的平台（Linux）
- 升级依赖库版本
- 引入新的压缩算法
- 改进GUI工具

### 9.3 长期目标

- 完全模块化重构
- 云端资源管理
- 实时更新机制
- AI辅助工具

---

**文档版本**: 1.0
**最后更新**: 2026-01-27
**维护者**: MT3项目组
