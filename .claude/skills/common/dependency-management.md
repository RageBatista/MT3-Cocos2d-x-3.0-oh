---
name: dependency-management
version: 1.2.1
priority: medium
category: common
description: |
  MT3 项目依赖管理技能。涵盖依赖矩阵、工具链兼容、版本约束与冲突排查。
  触发词: 依赖, 版本, ABI, 工具链, 冲突, CRT, 第三方库, v120, MultiThreadedDLL, lib, dll, 链接, include
dependencies:
  - project-context
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 12000
---

# 项目依赖管理技能 (MT3 通用)

**版本**: v1.2.1
**最后更新**: 2026-07-03

---

## 🏗️ 依赖架构概览

### 目录结构

```
MT3/
├── dependencies/                 # 第三方依赖目录
│   ├── cegui/                   # UI 框架 (v0.7.1)
│   ├── jpeg/                    # 图片处理 (v9.0)
│   ├── png/                     # PNG 图片 (v1.6.16)
│   ├── libogg-1.3.2/            # OGG 音频容器
│   ├── libvorbis-1.3.5/         # Vorbis 音频编解码
│   ├── speex-1.2rc2/            # 语音编解码
│   ├── freetype-2.4.9/          # 字体渲染
│   ├── SILLY-0.1.0/             # 图片加载
│   ├── vld/                     # 内存泄漏检测
│   ├── wxWidgets-*/             # GUI 框架 (工具链)
│   ├── zlib/                    # 压缩库
│   └── ...
│
├── cocos2d-x-2.2.6/             # 当前 Cocos2d-x 游戏引擎
├── cocos2d-2.0-rc2-x-2.0.1/     # 历史/回滚/差异基线
│
├── common/                       # 公共库
│   ├── cauthc/                  # 客户端认证
│   ├── platform/                # 跨平台基础
│   ├── lua/                     # Lua 解释器
│   └── updateengine/            # 热更新引擎
│
└── server/tools/                 # 服务器依赖
    ├── monkeyking/              # XDB 数据库引擎
    ├── gnet/                    # 网络框架
    └── ...
```

### 依赖分类

| 分类 | 说明 | 位置 |
|------|------|------|
| **客户端核心** | 游戏引擎、UI、渲染 | `cocos2d-*/`, `dependencies/cegui/` |
| **多媒体** | 图片、音频、字体 | `dependencies/jpeg/`, `libogg/`, `freetype/` |
| **公共库** | 跨平台、网络、脚本 | `common/` |
| **服务器核心** | 数据库、RPC | `server/tools/monkeyking/`, `gnet/` |
| **开发工具** | 编辑器、调试 | `dependencies/wxWidgets/`, `vld/` |

---

## 🔴 关键约束 (必须遵守)

### 1. Visual Studio 工具集约束

```yaml
⚠️ 强制约束: 客户端必须使用 v120 工具集

原因:
  - FireClient.lib 为 v120 预编译库
  - 所有 dependencies/*.lib 为 v120 编译
  - ABI 不兼容会导致链接错误或运行时崩溃

验证方法:
  1. 项目属性 → 常规 → 平台工具集 = Visual Studio 2013 (v120)
  2. 检查 lib 文件: dumpbin /HEADERS xxx.lib | findstr "machine"

错误示例:
  - LNK2001: 无法解析的外部符号 (工具集不匹配)
  - LNK2038: 检测到"_MSC_VER"的不匹配项 (编译器版本)
```

### 2. CRT 运行时库约束

```yaml
⚠️ 强制约束: 运行时库必须一致

配置要求:
  Release: /MD (Multi-threaded DLL)
  Debug: /MDd (Multi-threaded Debug DLL)

检查方法:
  项目属性 → C/C++ → 代码生成 → 运行时库

常见错误:
  LNK2038: 检测到"RuntimeLibrary"的不匹配项
  → 原因: 混用 /MD 和 /MT 编译的库

修复方法:
  1. 统一所有项目的运行时库设置
  2. 重新编译不一致的库
```

### 3. Windows SDK 约束

```yaml
⚠️ 建议约束: 使用 Windows SDK 8.1

检查方法:
  项目属性 → 常规 → Windows SDK 版本

常见错误:
  RC1015: cannot open include file 'winres.h'
  MSB8036: The Windows SDK version was not found

修复方法:
  1. 安装 Windows SDK 8.1
  2. 或修改项目配置使用已安装的 SDK
```

---

## 📊 客户端依赖矩阵

### 核心依赖 (Active)

| 依赖 | 版本 | 用途 | 平台 | 状态 |
|------|------|------|------|------|
| **cegui** | 0.7.1 | UI 框架 | Win32 | ✅ Active |
| **jpeg** | 9.0 | 图片处理 | All | ✅ Active |
| **png** | 1.6.16 | PNG 图片 | All | ✅ Active |
| **libogg** | 1.3.2 | 音频容器 | Win32 | ✅ Active |
| **libvorbis** | 1.3.5 | 音频编解码 | Win32 | ✅ Active |
| **speex** | 1.2rc2 | 语音编解码 | Win32 | ✅ Active |
| **freetype** | 2.4.9 | 字体渲染 | Win32 | ✅ Active |
| **SILLY** | 0.1.0 | 图片加载 | Win32 | ✅ Active |
| **vld** | 2.5.1 | 内存泄漏检测 | Win32 | ✅ Active |
| **LJXML** | - | XML 处理 | Win32 | ✅ Active |

### 工具链依赖

| 依赖 | 版本 | 用途 | 状态 |
|------|------|------|------|
| **wxWidgets** | 2.8.11 | CELayoutEditor | ✅ Tools-only |
| **wxWidgets** | 3.0.5 | BinLayoutStudio | ✅ Tools-only |
| **FreeImage** | - | 图片处理 | ✅ Tools-only |

### 待确认依赖

| 依赖 | 版本 | 状态 | 备注 |
|------|------|------|------|
| **libogg** | 1.3.6 | ⚠️ TBD | 多版本并存 |
| **libvorbis** | 1.3.7 | ⚠️ TBD | 多版本并存 |
| **zlib** | 1.3.1 | ⚠️ TBD | 可能未使用 |
| **wxWidgets** | 3.2.3 | ⚠️ TBD | 最新版本 |

---

## 🔧 依赖配置方法

### 1. vcxproj 配置

```xml
<!-- 头文件包含路径 -->
<AdditionalIncludeDirectories>
  $(SolutionDir)..\dependencies\cegui\include;
  $(SolutionDir)..\dependencies\jpeg\include;
  $(SolutionDir)..\dependencies\png\include;
  %(AdditionalIncludeDirectories)
</AdditionalIncludeDirectories>

<!-- 库文件搜索路径 -->
<AdditionalLibraryDirectories>
  $(SolutionDir)..\dependencies\cegui\lib\win32;
  $(SolutionDir)..\dependencies\jpeg\prebuilt\win32;
  $(SolutionDir)..\dependencies\png\prebuilt\win32;
  %(AdditionalLibraryDirectories)
</AdditionalLibraryDirectories>

<!-- 链接库 -->
<AdditionalDependencies>
  CEGUIBase.lib;
  CEGUIExpatParser.lib;
  jpeg.lib;
  libpng.lib;
  %(AdditionalDependencies)
</AdditionalDependencies>
```

### 2. 属性表 (.props) 配置

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <DependenciesDir>$(SolutionDir)..\dependencies</DependenciesDir>
  </PropertyGroup>

  <ItemDefinitionGroup>
    <ClCompile>
      <AdditionalIncludeDirectories>
        $(DependenciesDir)\cegui\include;
        $(DependenciesDir)\jpeg\include;
        %(AdditionalIncludeDirectories)
      </AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <AdditionalLibraryDirectories>
        $(DependenciesDir)\cegui\lib\win32;
        $(DependenciesDir)\jpeg\prebuilt\win32;
        %(AdditionalLibraryDirectories)
      </AdditionalLibraryDirectories>
    </Link>
  </ItemDefinitionGroup>
</Project>
```

### 3. 运行时 DLL 复制

```batch
@echo off
REM copy_runtime_dlls.bat

set SRC=..\dependencies
set DST=.\Release.win32

REM CEGUI DLLs
copy /Y "%SRC%\cegui\bin\win32\CEGUIBase.dll" "%DST%\"
copy /Y "%SRC%\cegui\bin\win32\CEGUIExpatParser.dll" "%DST%\"

REM Image DLLs
copy /Y "%SRC%\jpeg\prebuilt\win32\jpeg.dll" "%DST%\"
copy /Y "%SRC%\png\prebuilt\win32\libpng16.dll" "%DST%\"

REM Audio DLLs
copy /Y "%SRC%\libogg-1.3.2\bin\win32\ogg.dll" "%DST%\"
copy /Y "%SRC%\libvorbis-1.3.5\bin\win32\vorbis.dll" "%DST%\"

echo DLLs copied successfully.
```

---

## 🔍 依赖版本确认方法

### 方法 1: 目录名

```bash
# 直接查看目录名
ls dependencies/
# libogg-1.3.2  → 版本 1.3.2
# libvorbis-1.3.5  → 版本 1.3.5
```

### 方法 2: 源码版本文件

```bash
# PNG 版本
grep "PNG_LIBPNG_VER_STRING" dependencies/png/include/png.h
# → #define PNG_LIBPNG_VER_STRING "1.6.16"

# JPEG 版本
grep "JPEG_LIB_VERSION" dependencies/jpeg/include/jpeglib.h
# → #define JPEG_LIB_VERSION  90

# CEGUI 版本
grep "CEGUI_VERSION" dependencies/cegui/include/CEGUIVersion.h
# → #define CEGUI_VERSION_MAJOR 0
# → #define CEGUI_VERSION_MINOR 7
# → #define CEGUI_VERSION_PATCH 1
```

### 方法 3: 扫描工程引用

```powershell
# 扫描哪些依赖被引用
rg -n "dependencies[\\/]" -g "*.vcxproj" -g "*.props" -g "*.sln"

# 扫描特定依赖
rg -n "dependencies[\\/](cegui|jpeg|png)" -g "*.vcxproj"
```

### 方法 4: 检查预编译库

```bash
# 检查 prebuilt 目录
ls dependencies/jpeg/prebuilt/
# → android/  ios/  mac/  win32/

# 检查库文件信息
dumpbin /HEADERS dependencies/jpeg/prebuilt/win32/jpeg.lib | findstr "machine"
```

---

## 🧠 自动进化高价值规则（2026-03 回灌）

来源：`.claude/evolution/evolved/skills/backfill-proposals.md`（2026-03-05）。

### 规则：LNK 三段式依赖排查（confidence=0.95）

当出现 `LNK*` 链接错误时，依赖管理排查顺序固定为：

1. 工具集一致性：确认 `PlatformToolset=v120`。
2. 链接顺序与路径：确认 `AdditionalLibraryDirectories`、`AdditionalDependencies` 完整且顺序正确。
3. ABI/CRT 一致性：确认预编译库与主工程编译器代际、运行时库一致（避免 `v140+`、`/MD` 与 `/MT` 混用）。

推荐快速核查命令：

```powershell
rg -n "PlatformToolset" -g "*.vcxproj" client
rg -n "AdditionalDependencies|AdditionalLibraryDirectories" -g "*.vcxproj" client
```

---

## ⚠️ 常见问题与解决

### 问题 1: LNK2001 无法解析的外部符号

```
错误: LNK2001: 无法解析的外部符号 "__imp__jpeg_read_header"

原因分析:
  1. 缺少 lib 文件
  2. 工具集不匹配 (v120 vs v140)
  3. 库路径配置错误

解决方法:
  1. 检查 AdditionalDependencies 是否包含 jpeg.lib
  2. 检查 AdditionalLibraryDirectories 路径是否正确
  3. 验证 lib 文件工具集版本
     dumpbin /HEADERS jpeg.lib | findstr "linker version"
```

### 问题 2: LNK2038 RuntimeLibrary 不匹配

```
错误: LNK2038: 检测到"RuntimeLibrary"的不匹配项

原因分析:
  主项目使用 /MD，但某个库使用 /MT 编译

解决方法:
  1. 确认所有项目运行时库一致
  2. 重新编译不一致的库:
     - 打开库项目
     - 属性 → C/C++ → 代码生成 → 运行时库 = /MD
     - 重新编译
```

### 问题 3: 找不到 DLL

```
错误: 程序无法启动，因为计算机中丢失 CEGUIBase.dll

原因分析:
  DLL 文件未复制到可执行文件目录

解决方法:
  1. 运行 copy_runtime_dlls.bat
  2. 或手动复制 DLL 到 exe 所在目录
  3. 或将 DLL 目录添加到 PATH 环境变量
```

### 问题 4: 头文件找不到

```
错误: fatal error C1083: 无法打开包括文件: "CEGUI.h"

原因分析:
  头文件包含路径未配置

解决方法:
  1. 项目属性 → C/C++ → 常规 → 附加包含目录
  2. 添加: $(SolutionDir)..\dependencies\cegui\include
```

### 问题 5: 版本冲突

```
场景: 项目中存在多个版本的同一依赖

分析:
  dependencies/libogg-1.3.2  (Active)
  dependencies/libogg-1.3.6  (TBD)

解决方法:
  1. 确认哪个版本被实际引用
     rg -n "libogg" -g "*.vcxproj"
  2. 清理未使用的版本
  3. 更新依赖矩阵文档
```

---

## 🛠️ 添加新依赖流程

### 步骤 1: 准备依赖文件

```
dependencies/
└── new-library-1.0/
    ├── include/          # 头文件
    │   └── newlib.h
    ├── lib/
    │   └── win32/        # v120 编译的静态库
    │       └── newlib.lib
    ├── bin/
    │   └── win32/        # 运行时 DLL (如有)
    │       └── newlib.dll
    └── prebuilt/         # 预编译产物 (多平台)
        ├── android/
        ├── ios/
        └── win32/
```

### 步骤 2: 编译库文件 (如需)

```bash
# 1. 打开源码项目
# 2. 修改项目配置:
#    - PlatformToolset = v120
#    - RuntimeLibrary = /MD (Release) 或 /MDd (Debug)
#    - Platform = Win32
# 3. 编译
msbuild newlib.vcxproj /p:Configuration=Release /p:Platform=Win32
```

### 步骤 3: 配置项目引用

```xml
<!-- 在 vcxproj 中添加 -->
<AdditionalIncludeDirectories>
  $(SolutionDir)..\dependencies\new-library-1.0\include;
  %(AdditionalIncludeDirectories)
</AdditionalIncludeDirectories>

<AdditionalLibraryDirectories>
  $(SolutionDir)..\dependencies\new-library-1.0\lib\win32;
  %(AdditionalLibraryDirectories)
</AdditionalLibraryDirectories>

<AdditionalDependencies>
  newlib.lib;
  %(AdditionalDependencies)
</AdditionalDependencies>
```

### 步骤 4: 更新文档

```markdown
# 更新 docs/16-依赖矩阵-Dependency-Matrix.md

| new-library | 1.0 | win32 | active(mainline-win32) | 新功能支持 |
```

### 步骤 5: 验证

```bash
# 1. 编译项目
msbuild mt3.win32.vcxproj /p:Configuration=Release

# 2. 运行测试
./Release.win32/MT3.exe

# 3. 检查依赖
dumpbin /DEPENDENTS Release.win32/MT3.exe | findstr newlib
```

---

## 📊 服务器依赖管理

### 核心依赖

| 依赖 | 版本 | 用途 | 位置 |
|------|------|------|------|
| **monkeyking** | - | XDB 数据库引擎 | `server/tools/monkeyking/` |
| **gnet** | - | RPC 网络框架 | `server/tools/gnet/` |
| **jio** | - | I/O 序列化库 | `server/tools/jio/` |
| **convxml** | - | XML 代码生成 | `server/tools/convxml/` |

### Ant 依赖配置

```xml
<!-- build.xml 示例 -->
<project name="game-server">
    <property name="lib.dir" value="../bin"/>

    <path id="classpath">
        <fileset dir="${lib.dir}">
            <include name="monkeyking.jar"/>
            <include name="gnet.jar"/>
            <include name="jio.jar"/>
        </fileset>
    </path>

    <target name="compile">
        <javac srcdir="src" destdir="classes" classpathref="classpath"/>
    </target>
</project>
```

### JAR 依赖检查

```bash
# 查看 JAR 依赖
jar tf monkeyking.jar | head -20

# 检查 MANIFEST
unzip -p monkeyking.jar META-INF/MANIFEST.MF

# 运行时依赖分析
jdeps -s game-server.jar
```

---

## 🎯 实践项目

### 初级: 依赖审计报告

```
目标: 生成当前项目的依赖清单
任务:
  1. 扫描所有 vcxproj 文件
  2. 提取依赖引用
  3. 生成 Markdown 报告
预计时间: 2-3天
```

### 中级: 升级单个依赖

```
目标: 将 libogg 从 1.3.2 升级到 1.3.6
任务:
  1. 下载新版本源码
  2. 使用 v120 编译
  3. 替换旧版本文件
  4. 测试兼容性
预计时间: 1周
```

### 高级: 依赖管理自动化

```
目标: 创建依赖版本检查脚本
任务:
  1. 自动扫描依赖版本
  2. 对比官方最新版本
  3. 生成升级建议报告
  4. 集成到 CI/CD
预计时间: 2周
```

---

## ✅ 技能自测清单

### 基础认知
- [ ] 知道 dependencies/ 目录结构
- [ ] 理解 v120 工具集约束
- [ ] 能够查找依赖版本信息

### 配置能力
- [ ] 能够配置头文件包含路径
- [ ] 能够配置库文件链接
- [ ] 能够处理运行时 DLL

### 问题解决
- [ ] 能够解决 LNK2001 错误
- [ ] 能够解决 LNK2038 错误
- [ ] 能够排查 DLL 缺失问题

### 高级技能
- [ ] 能够编译 v120 版本的库
- [ ] 能够添加新的第三方依赖
- [ ] 能够维护依赖矩阵文档

---

## 📚 相关文档

- [依赖矩阵](../../../docs/06-工具链/02-依赖矩阵.md) - 完整依赖清单
- [Windows 编译](../client/windows-build.md) - 客户端编译指南
- [第三方库编译指南](../../../docs/03-开发指南/05-第三方库编译指南.md) - 库重编译方法
- [CRT 库冲突分析](../../../docs/06-工具链/02-依赖矩阵.md) - 运行时库问题

---

## 📝 更新日志

### v1.0.0 (2026-01-01)
- 初始版本
- 依赖架构概览
- 关键约束说明 (v120, CRT, SDK)
- 客户端依赖矩阵
- 依赖配置方法
- 版本确认方法
- 常见问题与解决
- 添加新依赖流程
- 服务器依赖管理

---

**维护者**: 技术委员会
**下次审查**: 2026-04-01
