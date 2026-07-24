# 01-架构总览 Architecture Overview

> **版本**: 1.0.0  
> **创建日期**: 2026-01-13  
> **作者**: 系统架构师  
> **项目**: LJFilePack (LJ文件打包工具)

---

## 1. 项目概述

### 1.1 项目简介

LJFilePack（LJ File Pack）是一个专为梦幻西游MG版本游戏设计的文件打包与资源管理工具。该工具负责将游戏资源文件进行压缩、加密、打包，并生成相应的索引文件，以支持客户端的资源加载和版本更新功能。

### 1.2 核心功能

- **文件扫描与过滤**：递归扫描指定目录，支持按目录名、文件名、文件类型进行过滤
- **文件压缩**：使用MiniZ（zlib兼容）算法对文件进行压缩
- **文件加密**：使用SMS4国密算法对文件进行加密保护
- **文件打包**：将文件打包成.ljfp格式的资源包，支持分包（按大小限制）
- **版本管理**：支持多版本号管理（格式：255.4095.4095）
- **渠道管理**：支持多渠道配置（iOS、Android等）
- **索引生成**：生成.ljpi（文件索引）和.ljzip（加密索引）文件
- **XML配置**：支持XML格式的配置文件读写

### 1.3 技术特点

- **纯C++实现**：无第三方框架依赖，仅使用STL
- **跨平台设计**：支持Windows平台（主要目标）
- **高性能压缩**：集成MiniZ压缩库，提供zlib兼容的压缩功能
- **安全性**：集成SMS4国密算法进行数据加密
- **灵活配置**：通过XML配置文件实现高度可定制的打包策略

---

## 2. 系统架构

### 2.1 五层架构设计

```
┌─────────────────────────────────────────────────────────┐
│              Layer 5: 应用层                 │
│         (命令行工具 + 配置管理)              │
├─────────────────────────────────────────────────────────┤
│              Layer 4: 业务逻辑层                 │
│         (打包/解包/版本管理核心)              │
├─────────────────────────────────────────────────────────┤
│              Layer 3: 数据结构层                 │
│         (文件信息/索引/节点树)              │
├─────────────────────────────────────────────────────────┤
│              Layer 2: 工具库层                   │
│    (MiniZ压缩 + SMS4加密 + CRC32校验)        │
├─────────────────────────────────────────────────────────┤
│              Layer 1: 平台抽象层                 │
│         (文件操作 + 字符串处理)              │
└─────────────────────────────────────────────────────────┘
```

### 2.2 模块依赖关系图

```
                    ┌─────────────────┐
                    │   Main      │
                    └──────┬──────┘
                           │
         ┌───────────┴─────────────┐
         │                         Option        │
         │                         │
         ┌────────┴────────┐      ┌────────┴────────┐
         │                  │      │                  │
      Version            Find            Pack           │
         │                  │      │                  │
         └────────┬─────────┘      └────────┬─────────┘
                │                         │
                │                        │
         ┌────────┴────────┐      ┌────────┴────────┐
         │                  │      │                  │
      XML                Node            FileInfo         │
         │                  │      │                  │
                └────────┬─────────┘      └────────┬─────────┘
                │                         │
                │                        │
         ┌────────┴────────┐      ┌────────┴────────┐
         │                  │      │                  │
      ZipFile            SMS4            MiniZ           │
         │                  │      │                  │
                └────────┬─────────┘      └────────┬─────────┘
                │                         │
                │                        │
         ┌──────────────────────────────────────────────────┐
         │            CRC32              StringUtil         FileUtil         │
         └──────────────────────────────────────────────────┘
```

---

## 3. 核心模块说明

### 3.1 主程序模块 (LJFP_Main)

**文件**: [`LJFP_Main.h`](../LJFP_Main.h)

**职责**:
- 命令行参数解析与处理
- 调用打包流程
- 提供实用工具函数（版本号转换、CRC32计算、格式转换等）

**主要命令**:
- `getversionnum` - 版本号转换（格式 → 数字）
- `getversioncaption` - 版本号转换（数字 → 格式）
- `getstrcrc32` - 字符串CRC32计算
- `verljvi2xml` - 版本文件格式转换（.ljvi → .xml）
- `verxml2ljvi` - 版本文件格式转换（.xml → .ljvi）
- `ljpi2xml` - 打包索引格式转换（.ljpi → .xml）
- `ljzip2xml` - 打包文件格式转换（.ljzip → .ljpi + .xml）
- `decode` - 解密文件
- `unzip` - 解压文件
- `decodeunzip` - 解密并解压文件
- `unpack` - 解包文件列表
- `makeupdatepack` - 制作增量更新包
- `makeupdatepackall` - 批量制作增量更新包
- 配置参数：`version:`, `update:`, `channel:`, `extend:`, `io:`, `filter:`, `pack:`, `compress:`, `code:`

### 3.2 配置管理模块 (LJFP_Option)

**文件**: [`LJFP_Option.h`](../LJFP_Option.h)

**职责**:
- 加载和解析XML配置文件
- 管理版本信息（当前版本、基础版本、最小版本）
- 管理更新信息（URL列表、系统类型、网络类型）
- 管理渠道信息（渠道ID、渠道名称）
- 管理扩展信息（键值对）
- 管理IO配置（查找路径、输出路径、输出类型）
- 管理过滤配置（目录过滤、文件名过滤、文件类型过滤）
- 管理打包配置（最大包大小、不打包文件、不压缩文件、不加密文件）
- 管理压缩配置（不压缩文件类型）
- 管理加密配置（不加密文件类型）

**配置结构**:
```xml
<Root>
  <Version Count="N">
    <0 Description="IOS">
      <VersionInfo VersionCaption="0.0.1" VersionCaptionBase="0.0.1" VersionCaptionMinimum="0.0.1"/>
    </0>
    <1 Description="Android">
      <VersionInfo VersionCaption="0.0.1" VersionCaptionBase="0.0.1" VersionCaptionMinimum="0.0.1"/>
    </1>
  </Version>
  <Update Count="N">
    <0 Description="IOS">
      <URLInfo AppURL="http://..." Count="1">
        <0 URL="http://..." System="ios" Network="lan"/>
      </URLInfo>
    </0>
    <1 Description="Android">
      <URLInfo AppURL="http://..." Count="1">
        <0 URL="http://..." System="android" Network="lan"/>
      </URLInfo>
    </1>
  </Update>
  <Channel Count="N">
    <0 Description="IOS_Locojoy">
      <ChannelInfo Channel="0" ChannelCaption="IOS_Locojoy"/>
    </0>
    <1 Description="Android_Locojoy">
      <ChannelInfo Channel="0" ChannelCaption="Android_Locojoy"/>
    </1>
  </Channel>
  <Extend Count="N">
    <0 Description="IOS">
      <ExtendInfo Test1="0" Test2="0.0.1"/>
    </0>
  </Extend>
  <IO Count="N">
    <0 Description="Pack Mode">
      <FindPath>Root/</FindPath>
      <OutputPath>IOS_Pack/</OutputPath>
      <OutputType>Pack</OutputType>
    </0>
  </IO>
  <Filter Count="N">
    <0 Description="Filter Rules">
      <FilterFileType Count="4">
        <0>db</0>
        <1>ilk</1>
        <2>pdb</2>
        <3>exe</3>
      </FilterFileType>
      <FilterFileName Count="0"/>
      <FilterFileNameFull Count="1">
        <0>config/autoconfig</0>
      </FilterFileNameFull>
      <FilterDirName Count="0"/>
      <FilterDirNameFull Count="1">
        <0>config/autoconfig</0>
      </FilterDirNameFull>
    </0>
  </Filter>
  <Pack Count="N">
    <0 Description="Pack Config">
      <MaxSize>52428800</MaxSize>
      <UnPackFileType Count="4">
        <0>ogg</0>
        <1>mp3</1>
        <2>mp4</2>
        <3>ini</3>
      </UnPackFileType>
      <UnPackFileName Count="0"/>
      <UnPackFileNameFull Count="3">
        <0>cfg/mount_android.xml</0>
        <1>cfg/mount_ios.xml</1>
        <2>cfg/mount_win.xml</2>
      </UnPackFileNameFull>
    </0>
  </Pack>
  <Compress Count="N">
    <0 Description="Compress Config">
      <UnCompressFileType Count="5">
        <0>ogg</0>
        <1>mp3</1>
        <2>mp4</2>
        <3>ini</3>
        <4>png</4>
      </UnCompressFileType>
      <UnCompressFileName Count="0"/>
      <UnCompressFileNameFull Count="3">
        <0>cfg/mount_android.xml</0>
        <1>cfg/mount_ios.xml</1>
        <2>cfg/mount_win.xml</2>
      </UnCompressFileNameFull>
    </0>
  </Compress>
  <Code Count="N">
    <0 Description="Code Config">
      <UnCodeFileType Count="4">
        <0>ogg</0>
        <1>mp3</1>
        <2>mp4</2>
        <3>ini</3>
      </UnCodeFileType>
      <UnCodeFileName Count="0"/>
      <UnCodeFileNameFull Count="3">
        <0>cfg/mount_android.xml</0>
        <1>cfg/mount_ios.xml</1>
        <2>cfg/mount_win.xml</2>
      </UnCodeFileNameFull>
    </0>
  </Code>
</Root>
```

### 3.3 文件查找模块 (LJFP_Find)

**文件**: [`LJFP_Find.h`](../LJFP_Find.h)

**职责**:
- 递归扫描指定目录
- 应用过滤规则（目录、文件名、文件类型）
- 调用回调函数处理找到的文件和目录

**核心类**: [`LJFP_Find`](../LJFP_Find.h)
- `m_FindFunc` - 文件发现回调函数指针
- `OnFindDir()` - 处理目录发现事件
- `OnFindFile()` - 处理文件发现事件
- `OnFindData()` - 处理文件数据事件
- `FindFiles()` - 递归查找文件

### 3.4 文件打包模块 (LJFP_Pack)

**文件**: [`LJFP_Pack.h`](../LJFP_Pack.h)

**职责**:
- 管理待打包文件列表
- 执行文件压缩、加密操作
- 生成打包文件（.ljfp）和索引文件（.ljpi/.ljzip）
- 支持分包（按最大包大小限制）

**核心类**:
- [`LJFP_File`](../LJFP_Pack.h) - 单个文件对象
  - 管理文件数据（原始、压缩后、加密后）
  - 执行加载、压缩、加密、保存操作
  
- [`LJFP_Pack`](../LJFP_Pack.h) - 文件包对象
  - 管理文件列表
  - 检测重复文件（CRC32冲突）
  - 导出文件信息和索引

- [`LJFP_FileList`](../LJFP_Pack.h) - 文件列表管理对象
  - 管理三个包：m_FilePackNo（散文件）、m_FilePack（打包文件）、m_FilePackAll（全部文件）
  - 管理路径映射
  - 执行导出操作

### 3.5 文件信息模块 (LJFP_FileInfo)

**文件**: [`LJFP_FileInfo.h`](../LJFP_FileInfo.h)

**职责**:
- 存储文件元数据（位置、大小、CRC32、压缩类型、加密类型）
- 支持二进制序列化/反序列化
- 支持从XML节点加载/保存到XML节点

**核心类**:
- [`LJFP_FileInfo`](../LJFP_FileInfo.h) - 单个文件信息对象
  - `m_FileArea` - 文件区域标识
  - `m_PackIndex` - 包索引
  - `m_Pos` - 文件在包中的位置
  - `m_Size` - 文件大小
  - `m_CRC32` - CRC32校验值
  - `m_CompressType` - 压缩类型
  - `m_CodeType` - 加密类型
  - `m_SizeOriginal` - 原始大小
  - `m_CRC32Original` - 原始CRC32
  - `m_PathFileName` - 文件路径名
  - `m_PackFileName` - 包文件名

- [`LJFP_PackInfo`](../LJFP_FileInfo.h) - 包信息对象
  - `m_FileInfoMap` - 文件信息映射（按CRC32索引）
  - `m_FileInfoArr` - 文件信息数组
  - `m_PackInfoOne` - 各包统计信息
  - 支持从节点树加载/保存到节点树

### 3.6 XML与节点模块 (LJFP_XML, LJFP_Node)

**文件**: [`LJFP_XML.h`](../LJFP_XML.h), [`LJFP_Node.h`](../LJFP_Node.h)

**职责**:
- 提供XML格式配置文件读写功能
- 提供二进制格式节点树序列化功能
- 支持节点属性、子节点管理

**核心类**:
- [`LJFP_Node`](../LJFP_Node.h) - 基础节点类
  - `m_Name` - 节点名称
  - `m_Text` - 节点文本
  - `m_AttrMap` - 属性映射
  - `m_NodeMap` - 子节点映射
  - 支持属性和子节点的增删改查

- [`LJFP_NodeEx`](../LJFP_XML.h) - 扩展节点类（继承自LJFP_Node）
  - 继承自 [`LJFP_Node`](../LJFP_Node.h)
  - 添加XML序列化功能
  - 支持从XML文件加载配置

### 3.7 加密模块 (LJFP_SMS4)

**文件**: [`LJFP_SMS4.h`](../LJFP_SMS4.h)

**职责**:
- 实现SMS4国密算法
- 提供32轮密钥扩展
- 支持ECB模式和CBC模式

**核心类**: [`SMS4`](../LJFP_SMS4.h)
- `m_Key[4]` - 128位密钥
- `mRK[32]` - 32轮子密钥
- `KeyExpansion()` - 密钥扩展
- `Cipher()` - 加密函数
- `InvCipher()` - 解密函数

### 3.8 压缩模块 (LJFP_MiniZ)

**文件**: [`LJFP_MiniZ.h`](../LJFP_MiniZ.h)

**职责**:
- 提供zlib兼容的压缩/解压缩功能
- 支持多种压缩级别（0-9）
- 支持原始deflate流和zlib流

**核心函数**:
- `mz_compress()` - 压缩函数
- `mz_compress2()` - 带级别的压缩函数
- `mz_uncompress()` - 解压缩函数
- `mz_deflateInit()` / `mz_inflateInit()` - 流初始化
- `mz_crc32()` - CRC32计算函数

### 3.9 ZIP文件封装模块 (LJFP_ZipFile)

**文件**: [`LJFP_ZipFile.h`](../LJFP_ZipFile.h)

**职责**:
- 封装压缩和加密后的数据为ZIP格式
- 支持自定义密钥
- 生成文件头（密钥标识、压缩后大小、原始大小、CRC32）

**核心类**: [`LJFP_ZipFile`](../LJFP_ZipFile.h)
- `m_uiKey` - 密钥标识
- `m_CRC32Func` - CRC32函数指针
- `m_ZipFunc` - 压缩函数指针
- `m_UnZipFunc` - 解压缩函数指针
- `m_SMS4Func` - 加密函数指针
- `m_DeSMS4Func` - 解密函数指针
- `m_strPassword` - 密钥字符串
- `ZipStream()` - 压缩流操作
- `UnZipStream()` - 解压缩流操作
- `ZipFile()` - 压缩文件操作
- `UnZipFile()` - 解压缩文件操作

### 3.10 CRC32校验模块 (LJFP_CRC32)

**文件**: [`LJFP_CRC32.h`](../LJFP_CRC32.h)

**职责**:
- 提供CRC32校验算法
- 支持快速查表优化

**核心函数**:
- `crc32_nn()` - CRC32计算函数
- 查表：`crc32_tab[]` - 256项标准CRC32表

### 3.11 工具类模块

**StringUtil** ([`LJFP_StringUtil.h`](../LJFP_StringUtil.h))
- 字符串转换工具（宽字符与窄字符互转、分割等）

**FileUtil** ([`LJFP_FileUtil.h`](../LJFP_FileUtil.h))
- 文件操作工具（目录创建、文件存在检查、路径处理等）

---

## 4. 数据流与处理流程

### 4.1 打包流程

```
┌─────────────────────────────────────────────────────────────┐
│                      加载配置文件                     │
│                  (LJFP_Option.xml)                  │
├─────────────────────────────────────────────────────────────┤
│                      扫描文件目录                     │
│                  (LJFP_Find)                        │
├─────────────────────────────────────────────────────────────┤
│                  应用过滤规则                     │
│                  (目录/文件名/类型过滤)               │
├─────────────────────────────────────────────────────────────┤
│                  收集文件列表                     │
│                  (LJFP_FileList)                    │
├─────────────────────────────────────────────────────────────┤
│                  分类处理文件                     │
│                  (散文件/打包文件)                  │
├─────────────────────────────────────────────────────────────┤
│                  压缩/加密处理                   │
│                  (MiniZ + SMS4)                      │
├─────────────────────────────────────────────────────────────┤
│                  生成索引文件                     │
│                  (fl.ljpi + fl.ljzip)              │
├─────────────────────────────────────────────────────────────┤
│                  生成版本文件                     │
│                  (version.ljvi)                      │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 版本号格式

**格式**: `255.4095.4095` (主版本号.次版本号.修订号)

- 主版本号 (Version1): 8位 (0-255)
- 次版本号 (Version2): 12位 (0-4095)
- 修订号 (Version3): 12位 (0-4095)

**示例**:
- `1.0.1` → `0x01000001`
- `255.4095.4095` → `0xFFFFFFFF`

### 4.3 文件包格式

**.ljfp文件** (打包文件):
- 文件头：包含文件列表和元数据
- 支持分包：按最大包大小限制自动分割
- 文件按CRC32索引存储

**.ljpi文件** (索引文件):
- 包文件列表索引
- 文件元数据（位置、大小、CRC32等）
- 支持快速查找

**.ljzip文件** (加密索引):
- .ljpi文件的加密版本
- 使用SMS4加密保护
- 包含压缩后的数据

---

## 5. 第三方依赖

### 5.1 核心依赖

| 依赖库 | 版本 | 用途 | 来源 |
|--------|------|------|------|
| MiniZ | 1.14 | zlib兼容压缩库 | 内置（LJFP_MiniZ.h） |
| LJXML | - | XML解析库 | 外部（../LJXML/） |
| StringCover | - | 字符串工具库 | 外部（../../common/platform/utils/） |

### 5.2 平台依赖

| 平台 | 依赖 | 说明 |
|------|------|------|
| Windows | Win32 API, shlwapi.h | 目录操作、路径处理 |

### 5.3 编译工具链

- **Visual Studio 2013** (v120工具集)
- **CMake** (可选，用于第三方依赖编译)

---

## 6. 文件格式规范

### 6.1 配置文件格式 (Option.xml)

详见第3.2节的XML配置结构。

### 6.2 打包文件格式 (.ljfp)

二进制格式，包含：
- 文件列表
- 文件元数据
- 包统计信息

### 6.3 索引文件格式 (.ljpi)

二进制格式，包含：
- 文件索引（按CRC32快速查找）
- 文件详细信息
- 包统计信息

### 6.4 加密索引文件格式 (.ljzip)

ZIP格式，包含：
- 加密的.ljpi文件
- 密钥标识头

---

## 7. 编译与构建

### 7.1 项目文件

- [`LJFilePack.sln`](../LJFilePack.sln) - Visual Studio解决方案
- [`LJFilePack.vcxproj`](../LJFilePack.vcxproj) - 主项目文件
- [`LJFilePack.vcxproj.filters`](../LJFilePack.vcxproj.filters) - 项目过滤器

### 7.2 编译要求

- **编译器**: Visual Studio 2013 (v120)
- **C++标准**: C++98/03
- **字符集**: Unicode (宽字符)
- **运行时库**: MSVCRT (v120)

### 7.3 构建输出

- **可执行文件**: LJFilePack.exe
- **输出目录**: 根据配置的OutputPath设置

---

## 8. 使用示例

### 8.1 基本打包命令

```bash
# 使用默认配置打包
LJFilePack.exe

# 指定配置索引打包
LJFilePack.exe version:0 io:0

# 指定输出目录打包
LJFilePack.exe io:1

# 禁用暂停
LJFilePack.exe nopause
```

### 8.2 格式转换命令

```bash
# 版本号转数字
LJFilePack.exe getversionnum

# 数字转版本号
LJFilePack.exe getversioncaption

# 字符串CRC32计算
LJFilePack.exe getstrcrc32
```

### 8.3 解包命令

```bash
# 解密文件
LJFilePack.exe decode:input.ljzip

# 解压文件
LJFilePack.exe unzip:input.ljzip

# 解密并解压
LJFilePack.exe decodeunzip:input.ljzip

# 解包文件列表
LJFilePack.exe unpack:input.ljpi
```

---

## 9. 技术约束与注意事项

### 9.1 编码约束

- **源文件编码**: UTF-8 with BOM（C++源码）
- **配置文件编码**: UTF-8 无BOM（XML配置）
- **字符串编码**: 项目内部使用宽字符（std::wstring）

### 9.2 性能考虑

- **大文件处理**: 支持分包避免单个文件过大
- **内存管理**: 及时释放已分配的内存
- **CRC32冲突检测**: 检测并报告重复文件

### 9.3 安全考虑

- **密钥管理**: 密钥通过配置文件管理，不应硬编码
- **文件验证**: 使用CRC32确保文件完整性

---

## 10. 扩展与维护

### 10.1 扩展点

- 添加新的压缩算法支持
- 添加新的加密算法支持
- 支持更多文件格式
- 添加增量更新优化

### 10.2 维护建议

- 定期更新MiniZ库版本
- 保持与客户端的接口兼容性
- 添加单元测试覆盖核心功能

---

**文档版本**: 1.0.0  
**最后更新**: 2026-01-13
