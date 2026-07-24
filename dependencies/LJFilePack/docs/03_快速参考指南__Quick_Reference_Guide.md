# LJFilePack 快速参考指南

> **项目**: LJFilePack (Locojoy File Packager)
> **用途**: 游戏资源打包与版本管理工具
> **更新**: 2025-01-03

---

## 目录

1. [快速开始](#快速开始)
2. [命令行参数](#命令行参数)
3. [配置文件](#配置文件)
4. [工具命令](#工具命令)
5. [常见问题](#常见问题)
6. [示例脚本](#示例脚本)

---

## 快速开始

### 安装

```batch
# 无需安装，直接使用编译好的可执行文件
# 或从源码编译:
msbuild LJFilePack.vcxproj /p:Configuration=Release /p:Platform=Win32
```

### 第一个打包任务

```batch
# 创建配置文件 (首次运行会自动生成)
LJFilePack.exe ?

# 编辑 LJFilePackOption.xml 配置源目录和输出目录

# 执行打包 (使用配置 0)
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:0 filter:0 pack:0 compress:0 code:0
```

### 输出结构

```
输出目录/
├── 1.ljfp          # 资源包 1
├── 2.ljfp          # 资源包 2 (如果超过单包大小限制)
├── 12345678        # 散文件 (以CRC32命名)
├── 87654321
├── ...
├── fl.ljpi         # 文件索引 (未加密)
├── fl.ljzip        # 文件索引 (加密)
└── ver.ljvi        # 版本信息
```

---

## 命令行参数

### 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `version:N` | 使用第N个版本配置 | `version:0` |
| `update:N` | 使用第N个更新配置 | `update:0` |
| `channel:N` | 使用第N个渠道配置 | `channel:0` |
| `extend:N` | 使用第N个扩展配置 | `extend:0` |
| `io:N` | 使用第N个IO配置 | `io:0` |
| `filter:N` | 使用第N个过滤配置 | `filter:0` |
| `pack:N` | 使用第N个打包配置 | `pack:0` |
| `compress:N` | 使用第N个压缩配置 | `compress:0` |
| `code:N` | 使用第N个加密配置 | `code:0` |
| `nopause` | 不显示等待提示 | `nopause` |

### 完整示例

```batch
# iOS 打包示例
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:0 filter:0 pack:0 compress:0 code:0

# Android 打包示例
LJFilePack.exe version:1 update:1 channel:1 extend:1 io:2 filter:0 pack:0 compress:0 code:0

# 散文件模式 (不打包)
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:1 filter:0 pack:0 compress:0 code:0

# 后台运行 (不暂停)
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:0 filter:0 pack:0 compress:0 code:0 nopause
```

---

## 配置文件

### 配置文件结构

`LJFilePackOption.xml` 是打包工具的配置文件：

```xml
<?xml version="1.0" encoding="utf-8"?>
<Root>
    <!-- 版本配置 -->
    <Version Count="2">
        <0 Description="IOS">
            <VersionInfo
                VersionCaption="1.0.0"
                VersionCaptionBase="1.0.0"
                VersionCaptionMinimum="1.0.0"
                VersionDonotCheck="0"/>
        </0>
        <1 Description="Android">
            <VersionInfo
                VersionCaption="1.0.0"
                VersionCaptionBase="1.0.0"
                VersionCaptionMinimum="1.0.0"/>
        </1>
    </Version>

    <!-- 更新服务器配置 -->
    <Update Count="2">
        <0 Description="IOS">
            <URLInfo
                AppURL="http://itunes.apple.com/app/id123456"
                Count="1">
                <0
                    URL="http://192.168.1.100/ios/"
                    System="ios"
                    Network="lan"/>
            </URLInfo>
        </0>
        <1 Description="Android">
            <URLInfo
                AppURL="http://play.google.com/store/apps/details?id=com.locojoy.game"
                Count="1">
                <0
                    URL="http://192.168.1.100/android/"
                    System="android"
                    Network="lan"/>
            </URLInfo>
        </1>
    </Update>

    <!-- 渠道配置 -->
    <Channel Count="2">
        <0 Description="IOS_Locojoy">
            <ChannelInfo Channel="0" ChannelCaption="IOS_Locojoy"/>
        </0>
        <1 Description="Android_Locojoy">
            <ChannelInfo Channel="1" ChannelCaption="Android_Locojoy"/>
        </1>
    </Channel>

    <!-- IO 配置 -->
    <IO Count="4">
        <!-- iOS 打包模式 -->
        <0
            Description="IOS Pack"
            FindPath="Resources/"
            OutputPath="Output/IOS_Pack/"
            OutputType="Pack"/>
        <!-- iOS 散文件模式 -->
        <1
            Description="IOS File"
            FindPath="Resources/"
            OutputPath="Output/IOS_File/"
            OutputType="File"/>
        <!-- Android 打包模式 -->
        <2
            Description="Android Pack"
            FindPath="Resources/"
            OutputPath="Output/Android_Pack/"
            OutputType="Pack"/>
        <!-- Android 散文件模式 -->
        <3
            Description="Android File"
            FindPath="Resources/"
            OutputPath="Output/Android_File/"
            OutputType="File"/>
    </IO>

    <!-- 过滤配置 -->
    <Filter Count="1">
        <0 Description="Default Filters">
            <!-- 过滤的文件扩展名 -->
            <FilterFileType Count="4">
                0="db"
                1="ilk"
                2="pdb"
                3="exe"
            </FilterFileType>
            <!-- 过滤的完整路径 -->
            <FilterDirNameFull Count="1">
                0="config/autoconfig"
            </FilterDirNameFull>
        </0>
    </Filter>

    <!-- 打包配置 -->
    <Pack Count="1">
        <0 Description="Default Pack" MaxSize="52428800">
            <!-- 不打包的文件扩展名 -->
            <UnPackFileType Count="4">
                0="ogg"
                1="mp3"
                2="mp4"
                3="ini"
            </UnPackFileType>
            <!-- 不打包的完整路径 -->
            <UnPackFileNameFull Count="3">
                0="cfg/mount_android.xml"
                1="cfg/mount_ios.xml"
                2="cfg/mount_win.xml"
            </UnPackFileNameFull>
        </0>
    </Pack>

    <!-- 压缩配置 -->
    <Compress Count="1">
        <0 Description="Default Compress">
            <!-- 不压缩的文件扩展名 -->
            <UnCompressFileType Count="5">
                0="ogg"
                1="mp3"
                2="mp4"
                3="ini"
                4="png"
            </UnCompressFileType>
            <!-- 不压缩的完整路径 -->
            <UnCompressFileNameFull Count="3">
                0="cfg/mount_android.xml"
                1="cfg/mount_ios.xml"
                2="cfg/mount_win.xml"
            </UnCompressFileNameFull>
        </0>
    </Compress>

    <!-- 加密配置 -->
    <Code Count="1">
        <0 Description="Default Code">
            <!-- 不加密的文件扩展名 -->
            <UnCodeFileType Count="4">
                0="ogg"
                1="mp3"
                2="mp4"
                3="ini"
            </UnCodeFileType>
            <!-- 不加密的完整路径 -->
            <UnCodeFileNameFull Count="3">
                0="cfg/mount_android.xml"
                1="cfg/mount_ios.xml"
                2="cfg/mount_win.xml"
            </UnCodeFileNameFull>
        </0>
    </Code>
</Root>
```

### 关键配置项说明

#### 版本号格式

```
格式: Major.Minor.Patch
范围: 255.4095.4095

示例:
1.0.0   → 初始版本
1.1.0   → 新增功能
1.1.1   → Bug修复
2.0.0   → 重大更新
```

#### 文件处理优先级

```
1. 完整路径匹配 (最高优先级)
   - UnPackFileNameFull
   - UnCompressFileNameFull
   - UnCodeFileNameFull

2. 文件名匹配
   - UnPackFileName
   - UnCompressFileName
   - UnCodeFileName

3. 扩展名匹配 (最低优先级)
   - UnPackFileType
   - UnCompressFileType
   - UnCodeFileType
```

#### 包大小配置

```
MaxSize: 单个包的最大字节数
- 默认: 52428800 (50MB)
- 建议: 10MB - 100MB
- 作用: 超过此大小会创建新包
```

---

## 工具命令

### 版本工具

```batch
# 版本号转数字
LJFilePack.exe getversionnum
# 输入: 1.0.0
# 输出: 16777216

# 数字转版本号
LJFilePack.exe getversioncaption
# 输入: 16777216
# 输出: 1.0.0
```

### 格式转换

```batch
# 版本文件转 XML
LJFilePack.exe verljvi2xml:ver.ljvi
# 输出: ver.ljvi.xml

# XML 转版本文件
LJFilePack.exe verxml2ljvi:ver.xml
# 输出: ver.xml.ljvi

# 包信息转 XML
LJFilePack.exe ljpi2xml:fl.ljpi
# 输出: fl.ljpi.xml

# 加密包信息转 XML
LJFilePack.exe ljzip2xml:fl.ljzip
# 输出: fl.ljzip.xml (解密→解压→转XML)
```

### 解包工具

```batch
# 解密文件
LJFilePack.exe decode:encrypted.dat
# 输出: encrypted.dat.decode

# 解压文件
LJFilePack.exe unzip:compressed.dat
# 输出: compressed.dat.unzip

# 解密并解压
LJFilePack.exe decodeunzip:packed.dat
# 输出: packed.dat.decodeunzip

# 完整解包
LJFilePack.exe unpack:fl.ljpi
# 或
LJFilePack.exe unpack:fl.ljzip
# 输出: FL/ 目录 (还原所有文件)
```

### 增量更新

```batch
# 单次增量更新
LJFilePack.exe makeupdatepack:res_base/|res_new/|res_delta/
# 比较 res_base/ 和 res_new/
# 输出到 res_delta/

# 批量增量更新
LJFilePack.exe makeupdatepackall:update_list.txt
# update_list.txt 内容:
# res_delta/
# res_v1.0/
# res_v1.1/
# res_v1.2/
# res_v1.3/
# 将依次比较相邻版本
```

### 帮助

```batch
# 显示帮助信息
LJFilePack.exe ?
```

---

## 常见问题

### Q1: 如何跳过对某些文件的打包？

**A**: 在配置的 `<Pack>` 节点添加规则：

```xml
<UnPackFileType Count="3">
    0="ogg"
    1="mp3"
    2="ini"
</UnPackFileType>
```

### Q2: 如何修改加密密钥？

**A**: 需要修改源代码中的 `LJFP_ZipFile` 调用：

```cpp
// 当前硬编码在 LJFP_Pack.h 和 LJFP_Main_Helper.h
SMS4Ex(m_Data, m_DataCode, m_SizeCode, "locojoy123456789");

// 修改为:
SMS4Ex(m_Data, m_DataCode, m_SizeCode, "your_new_key");
```

### Q3: 如何调整单包大小限制？

**A**: 修改配置文件中的 `MaxSize` 属性：

```xml
<Pack Count="1">
    <0 Description="Default Pack" MaxSize="104857600">
        <!-- 100MB = 1024 * 1024 * 100 -->
    </0>
</Pack>
```

### Q4: 支持哪些路径格式？

**A**:
- 源路径: 相对路径或绝对路径
- 输出路径: 相对路径或绝对路径
- 路径分隔符: 支持正斜杠 (/) 和反斜杠 (\)

### Q5: 如何处理中文路径？

**A**:
- 确保配置文件保存为 UTF-8 编码
- 源文件名可以使用中文
- 输出文件名使用 CRC32 编码，无中文问题

### Q6: 增量更新如何判断文件变化？

**A**:
- 通过 CRC32 校验值判断
- CRC32 相同 = 文件未变化
- CRC32 不同 = 文件已修改

### Q7: 如何验证打包后的文件完整性？

**A**:
```batch
# 解包后对比
LJFilePack.exe unpack:fl.ljpi
# 然后使用文件比较工具对比源目录和解包后目录
```

---

## 示例脚本

### 构建脚本 (build.bat)

```batch
@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo LJFilePack 自动构建脚本
echo ========================================

set SOURCE_DIR=Resources
set OUTPUT_DIR=Output
set CONFIG_INDEX=0

echo 清理输出目录...
if exist %OUTPUT_DIR% rd /s /q %OUTPUT_DIR%
mkdir %OUTPUT_DIR%

echo 开始打包资源...
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:%CONFIG_INDEX% filter:0 pack:0 compress:0 code:0 nopause

if %ERRORLEVEL% EQU 0 (
    echo 打包成功!
    echo 输出目录: %OUTPUT_DIR%
) else (
    echo 打包失败，错误代码: %ERRORLEVEL%
)

pause
```

### 多平台构建 (build_all.bat)

```batch
@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo 多平台资源构建
echo ========================================

set SOURCE_DIR=Resources

echo.
echo [1/4] 构建 iOS 打包版本...
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:0 filter:0 pack:0 compress:0 code:0 nopause

echo.
echo [2/4] 构建 iOS 散文件版本...
LJFilePack.exe version:0 update:0 channel:0 extend:0 io:1 filter:0 pack:0 compress:0 code:0 nopause

echo.
echo [3/4] 构建 Android 打包版本...
LJFilePack.exe version:1 update:1 channel:1 extend:1 io:2 filter:0 pack:0 compress:0 code:0 nopause

echo.
echo [4/4] 构建 Android 散文件版本...
LJFilePack.exe version:1 update:1 channel:1 extend:1 io:3 filter:0 pack:0 compress:0 code:0 nopause

echo.
echo ========================================
echo 所有构建完成!
echo ========================================

pause
```

### 增量更新脚本 (update.bat)

```batch
@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo 增量更新包生成
echo ========================================

set BASE_DIR=res_v1.0
set NEW_DIR=res_v1.1
set DELTA_DIR=delta_v1.0_to_v1.1

echo 基准版本: %BASE_DIR%
echo 新版本: %NEW_DIR%
echo 增量输出: %DELTA_DIR%

echo.
echo 清理增量目录...
if exist %DELTA_DIR% rd /s /q %DELTA_DIR%
mkdir %DELTA_DIR%

echo 生成增量更新包...
LJFilePack.exe makeupdatepack:%BASE_DIR%/|%NEW_DIR%/|%DELTA_DIR%/

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 增量更新包生成成功!
    echo ========================================
    echo 输出目录: %DELTA_DIR%
    echo.
    echo 包含内容:
    dir /s /b %DELTA_DIR%
) else (
    echo 增量更新包生成失败!
)

pause
```

### 版本转换脚本 (convert.bat)

```batch
@echo off
echo ========================================
echo 文件格式转换工具
echo ========================================

echo.
echo 1. 版本文件转 XML
echo 2. XML 转版本文件
echo 3. 包信息转 XML
echo 4. 加密包信息转 XML
echo.

set /p CHOICE=请选择操作 (1-4):

if "%CHOICE%"=="1" (
    set /p FILE=输入版本文件路径:
    LJFilePack.exe verljvi2xml:!FILE!
)
if "%CHOICE%"=="2" (
    set /p FILE=输入XML文件路径:
    LJFilePack.exe verxml2ljvi:!FILE!
)
if "%CHOICE%"=="3" (
    set /p FILE=输入包信息文件路径:
    LJFilePack.exe ljpi2xml:!FILE!
)
if "%CHOICE%"=="4" (
    set /p FILE=输入加密包文件路径:
    LJFilePack.exe ljzip2xml:!FILE!
)

pause
```

---

## 附录

### 文件扩展名速查表

| 扩展名 | 说明 | 默认打包 | 默认压缩 | 默认加密 |
|--------|------|----------|----------|----------|
| .ljfp | 资源包文件 | - | 是 | 是 |
| .ljpi | 文件索引 | - | - | - |
| .ljzip | 加密索引 | - | 是 | 是 |
| .ljvi | 版本信息 | - | - | - |
| .xml | 配置文件 | - | - | - |
| .decode | 解密输出 | - | - | - |
| .unzip | 解压输出 | - | - | - |

### 退出代码

| 代码 | 说明 |
|------|------|
| 0 | 成功 |
| -1 | 通用错误 |
| -99 | 版本配置错误 |
| -98 | 更新配置错误 |
| -97 | 渠道配置错误 |
| -96 | 扩展配置错误 |
| -1~-14 | 具体配置项错误 |

### 技术支持

- 项目路径: `dependencies/LJFilePack/`
- 配置文件: `LJFilePackOption.xml`
- 可执行文件: `Release/LJFilePack.exe`

---

**文档版本**: 1.0
**更新日期**: 2025-01-03
