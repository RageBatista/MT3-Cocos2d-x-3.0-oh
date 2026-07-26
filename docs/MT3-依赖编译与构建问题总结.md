# MT3 依赖编译与构建问题系统总结

> **版本**：1.0.0
> **日期**：2026-07-26
> **范围**：从依赖库全量重编译到 MT3.exe 最终成功启动的全链路问题梳理
> **工具链**：VS2013 (v120) + MSBuild 12.0 + Windows SDK 8.1

---

## 目录

1. [问题全景图](#1-问题全景图)
2. [分类一：依赖库编译问题](#2-分类一依赖库编译问题)
3. [分类二：链接问题](#3-分类二链接问题)
4. [分类三：运行时崩溃问题](#4-分类三运行时崩溃问题)
5. [分类四：构建系统问题](#5-分类四构建系统问题)
6. [关键技术点](#6-关键技术点)
7. [经验教训](#7-经验教训)
8. [预防措施与最佳实践](#8-预防措施与最佳实践)

---

## 1. 问题全景图

本次工作涉及 **14 个依赖库** 的 VS2013 全量重编译，以及 `engine`、`FireClient`、`MT3` 三个主工程的链接与运行验证。整个过程共遇到 **18 个独立问题**，按类别分布如下：

| 类别 | 问题数 | 严重程度 |
|------|--------|----------|
| 依赖库编译 | 8 | 中 |
| 链接问题 | 5 | 高 |
| 运行时崩溃 | 3 | 致命 |
| 构建系统 | 2 | 中 |

### 依赖库构建清单

| # | 库名 | 版本 | 源码来源 | 构建方式 |
|---|------|------|----------|----------|
| 1 | zlib | 1.2.5 | `dependencies/zlib-1.2.5/` | 现有 vcxproj + 补丁 |
| 2 | libjpeg | 8b | `dependencies/jpeg-8b/` | 新建 vcxproj |
| 3 | libpng | 1.4.7 | `dependencies/libpng-1.4.7/` | 新建 vcxproj |
| 4 | libtiff | 4.0.3 | `dependencies/third-party-rebuild/tiff-4.0.3/` | 新建 vcxproj |
| 5 | glew | 1.7.0 | `dependencies/glew-1.7.0/` | 新建 vcxproj |
| 6 | libogg | 1.3.2 | `dependencies/libogg-1.3.2/` | 现有 sln + 参数覆盖 |
| 7 | libvorbis | 1.3.5 | `dependencies/libvorbis-1.3.5/` | 现有 vcxproj + 补丁 |
| 8 | libspeex | 1.2rc2 | `dependencies/speex-1.2rc2/` | 现有 vcxproj |
| 9 | FreeType | 2.4.12 | `dependencies/freetype-2.4.12/` | 现有 sln |
| 10 | SILLY | 0.1.0 | `dependencies/SILLY-0.1.0/` | 新建 vcxproj |
| 11 | pthreadVCE2 | 2.x | `dependencies/third-party-rebuild/pthreads-w32/` | 新建 vcxproj |
| 12 | libcurl | 7.48.0 | `dependencies/third-party-rebuild/curl-7.48.0/` | 现有 sln |
| 13 | pcre | 8.31 | `dependencies/pcre-8.31/` | 现有 vcxproj |
| 14 | CEGUI | 0.7.1 | `dependencies/cegui/` | 现有 sln |

---

## 2. 分类一：依赖库编译问题

### 2.1 zlib — 输出命名与工具集版本不匹配

**表现**：zlib 原工程使用 `v100` (VS2010) 工具集，且输出文件名为 `zlibstat.lib`，而 MT3 链接期望 `libzlib.lib`。

**根因**：
- `dependencies/zlib-1.2.5/contrib/vstudio/vc10/zlibstat.vcxproj` 默认 `PlatformToolset=v100`
- Debug 配置使用 `MultiThreadedDebug` (`/MTd`)，与 cocos2d 的 `MultiThreadedDebugDLL` (`/MDd`) 不一致
- 定义了 `ZLIB_WINAPI` 宏导致使用 `stdcall` 调用约定，而 cocos2d 期望 `cdecl`

**解决方案**：
1. 将 `PlatformToolset` 从 `v100` 改为 `v120`
2. 移除 `ZLIB_WINAPI` 宏定义
3. Debug 配置将 `RuntimeLibrary` 从 `MultiThreadedDebug` 改为 `MultiThreadedDebugDLL`
4. 构建后将 `zlibstat.lib` 重命名为 `libzlib.lib`，并同步到 `cocos2d-x-2.2.6/cocos2dx/platform/third_party/win32/libraries/`

**关键代码**（[Rebuild-AllDependencies-v120.ps1#L171-L217](file:///e:/MT3/tools/scripts/Rebuild-AllDependencies-v120.ps1#L171-L217)）：
```powershell
$patched = $content -replace 'ZLIB_WINAPI;?', ''
$patched = $patched -replace '(<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>)',
    '<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>'
# 构建后重命名
Copy-Item "$zlibOutputDir\zlibstat.lib" "$zlibOutputDir\libzlib.lib" -Force
```

### 2.2 libogg — CRT 运行时库不匹配

**表现**：libogg 的 Debug 配置使用静态 CRT (`/MTd`)，与 cocos2d 的动态 CRT (`/MDd`) 冲突，链接时产生 `LNK2005` 符号重复定义错误。

**根因**：`libogg_static.sln` 中 Debug 配置的 `RuntimeLibrary` 为 `MultiThreadedDebug`。

**解决方案**：通过 MSBuild 命令行参数覆盖运行时库设置：
```powershell
msbuild libogg_static.sln /p:Configuration=Debug /p:RuntimeLibrary=MultiThreadedDebugDLL
```

### 2.3 libvorbis — 依赖路径与命名约定

**表现**：libvorbis 编译失败，找不到 libogg 的头文件和库文件。

**根因**：
1. `libogg.props` 中的 `AdditionalIncludeDirectories` 和 `AdditionalLibraryDirectories` 指向不存在的历史路径
2. `vorbisenc` 子项目期望 `libogg_static.lib`，但 libogg 实际输出 `libogg.lib`

**解决方案**：
1. 修复 `libogg.props` 中的路径指向正确的 libogg 位置
2. 将 `libogg.lib` 复制为 `libogg_static.lib` 以满足 vorbisenc 的依赖

**关键代码**（[Rebuild-AllDependencies-v120.ps1#L367-L432](file:///e:/MT3/tools/scripts/Rebuild-AllDependencies-v120.ps1#L367-L432)）：
```powershell
# 修复 libogg.props 路径
$correctOggInclude = "$repoRoot\dependencies\libogg-1.3.2\include"
$correctOggLibDir = "$repoRoot\dependencies\libogg-1.3.2\win32\VS2010\Release.win32"
# 创建 libogg_static.lib 别名
Copy-Item $liboggLib $liboggStaticLib
```

### 2.4 libspeex — 配置名不匹配

**表现**：libspeex 的 Debug 配置使用 `/MTd`，导致 CRT 冲突。

**根因**：原工程有 `Debug_RTL_dll` 和 `Release_RTL_dll` 配置用于 DLL CRT 链接，但默认 `Debug` 配置使用静态 CRT。

**解决方案**：使用 `Debug_RTL_dll` / `Release_RTL_dll` 配置名代替默认的 `Debug` / `Release`：
```powershell
$speexConfig = if ($Configuration -eq "Debug") { "Debug_RTL_dll" } else { "Release_RTL_dll" }
```

### 2.5 libcurl — 配置名不匹配

**表现**：libcurl 的 `curl-all.sln` 包含多个项目和配置，默认 `Debug` / `Release` 配置缺少必要的 SSPI 和 SSL 特性。

**根因**：MT3 使用的预编译 libcurl 基于 `DLL Release - DLL Windows SSPI` 配置构建。

**解决方案**：使用完整的配置名，并只构建 `libcurl` 项目（避免编译测试项目）：
```powershell
$cfg = "DLL Release - DLL Windows SSPI"  # Release
$cfg = "DLL Debug - DLL Windows SSPI"    # Debug
msbuild curl-all.sln /t:libcurl /p:Configuration="$cfg"
```

### 2.6 FreeType — 输出路径漂移

**表现**：FreeType 构建成功但输出文件路径与预期不同。

**根因**：FreeType 的输出目录在 `objs/win32/vc2010/` 而非标准 `Debug.win32/` 目录。

**解决方案**：在构建后从实际输出路径复制到预编译库目录：
```powershell
$ftLib = "$repoRoot\dependencies\freetype-2.4.12\objs\win32\vc2010\freetype.lib"
Copy-Item $ftLib $prebuiltWinRT -Force
```

### 2.7 libwebp — CRT 库冲突

**表现**：链接 `libcocos2d.dll` 时报告 `LNK2005` 错误，libwebp 的静态 CRT (`libcmt`) 与 cocos2d 的动态 CRT (`msvcrt`) 冲突。

**根因**：预编译的 `libwebp.lib` 使用 `/MT` (静态 CRT) 编译，而 cocos2d 使用 `/MD` (动态 CRT)。

**解决方案**：在 [cocos2d.vcxproj#L98](file:///e:/MT3/cocos2d-x-2.2.6/cocos2dx/proj.win32/cocos2d.vcxproj#L98) 中添加 `IgnoreSpecificDefaultLibraries` 忽略冲突的静态 CRT：
```xml
<IgnoreSpecificDefaultLibraries>LIBCMT;%(IgnoreSpecificDefaultLibraries)</IgnoreSpecificDefaultLibraries>
```

### 2.8 各库的 `_d` 后缀问题

**表现**：Debug 构建的库自动添加 `_d` 后缀（如 `libjpeg_d.lib`），导致链接器找不到预期的库名。

**根因**：新建 vcxproj 模板中未禁用 Debug 后缀。

**解决方案**：在 `New-VS2013StaticLib` 函数中，确保 `TargetName` 与 `ProjectName` 一致，不添加额外后缀。

---

## 3. 分类二：链接问题

### 3.1 GLEW_STATIC 宏缺失

**表现**：链接 `cegui_d.lib` 时报告大量 unresolved external symbol 错误，符号名包含 `__imp_glew*`（DLL 导入符号）。

**根本原因**：CEGUI 源码中通过 `#ifdef GLEW_STATIC` 判断是静态链接还是动态链接 GLEW。缺少该宏时，编译器生成 `__declspec(dllimport)` 形式的导入符号，但实际链接的是静态库 `glew32.lib`。

**影响范围**：3 个 vcxproj 文件：
- [engine.win32.vcxproj#L334](file:///e:/MT3/engine/engine.win32.vcxproj#L334) — 已添加
- [cegui.win32.vcxproj#L68](file:///e:/MT3/dependencies/cegui/project/win32/cegui.win32.vcxproj#L68) — 已添加
- [mt3.win32.vcxproj#L72](file:///e:/MT3/client/MT3Win32App/mt3.win32.vcxproj#L72) — 已添加

**排查方法**：使用 `dumpbin /symbols` 检查 `.lib` 中的符号，对比 `__imp_` 前缀与普通符号的区别。

**修复**：在各 vcxproj 的 `PreprocessorDefinitions` 中添加 `GLEW_STATIC`。

### 3.2 PTW32_STATIC_LIB 和 LIBTIFF_STATIC 宏缺失

**表现**：与 GLEW_STATIC 类似，pthread 和 libtiff 的静态链接也缺少对应的 `*_STATIC` 宏。

**解决方案**：在 [cocos2d.vcxproj#L77](file:///e:/MT3/cocos2d-x-2.2.6/cocos2dx/proj.win32/cocos2d.vcxproj#L77) 中已有 `PTW32_STATIC_LIB` 和 `LIBTIFF_STATIC`，但新增的 vcxproj 需要同步添加。

### 3.3 pcre.lib 缺失

**表现**：MT3.exe 链接时报 `LNK1104: 无法打开文件"pcre.lib"`。

**根本原因**：pcre 是 CEGUI 的依赖，但 `dependencies/cegui/lib/` 目录下没有 pcre.lib。链接器搜索路径中包含 `../../dependencies/cegui/lib`，但 pcre.lib 实际位于 `dependencies/pcre-8.31/Debug.win32/`。

**解决方案**：将 pcre 构建输出复制到 CEGUI 的 lib 目录：
```powershell
New-Item -ItemType Directory -Path "E:\MT3\dependencies\cegui\lib" -Force
Copy-Item "E:\MT3\dependencies\pcre-8.31\Debug.win32\pcre.lib" "E:\MT3\dependencies\cegui\lib\pcre.lib"
```

### 3.4 platform.lib 缺失

**表现**：清理构建产物后，MT3.exe 链接时找不到 `platform.lib`。

**根本原因**：手动清理 `Debug.win32` 目录时，删除了共享输出目录中的所有 `*.lib` 文件，包括 `platform.lib`、`cauthc.lib`、`ljfm.lib` 等。这些库由 `common/` 下的独立工程构建，但它们在 MT3 的构建依赖链中。

**解决方案**：使用 canonical 构建脚本 `Build-MT3-Exe-Canonical.ps1` 而非手动逐个构建，该脚本会自动处理全链依赖。

### 3.5 链接搜索路径不完整

**表现**：`platform.lib` 所在目录 `common/platform/` 不在 MT3 的链接器搜索路径中。

**根本原因**：`mt3.win32.vcxproj` 的 `AdditionalLibraryDirectories` 只包含 `$(OutDir)` 和 `$(SolutionDir)$(Configuration).win32/`，而 `platform.lib` 需要先由 `common/platform` 工程构建并输出到共享目录。

**解决方案**：canonical 构建脚本会先构建 `platform` → `ljfm` → `cauthc` 等依赖工程，再构建 MT3。构建顺序由脚本维护，不在 vcxproj 中硬编码跨模块路径。

---

## 4. 分类三：运行时崩溃问题

### 4.1 崩溃：glGenBuffers 空指针调用

**表现**：MT3.exe 启动后立即闪退，生成崩溃转储 `崩溃26_0_48_6.dmp`。

**崩溃点**：[nucocos2d_render.cpp#L303-L308](file:///e:/MT3/engine/renderer/nucocos2d_render.cpp#L303-L308) 中的 `Cocos2dRenderer::InitBatchVB()`：
```cpp
bool Cocos2dRenderer::InitBatchVB()
{
    glGenBuffers(1, &m_particleVB);   // <-- crash: glGenBuffers is NULL
    glGenBuffers(1, &m_particleUVB);
    glGenBuffers(1, &m_particleIB);
}
```

**根本原因**：`glGenBuffers` 是 OpenGL 1.5+ 的扩展函数，需要通过 GLEW 在运行时动态解析。GLEW 未初始化时，所有扩展函数指针均为 NULL。

**调用链分析**：
```
Engine::Run()
  └─ #ifdef WIN7_32 → 跳过 CCApplication::run()      ← [nuengine.cpp#L390-L396]
       └─ CCEGLView::initGL() 未被调用
            └─ glewInit() 未被调用                        ← [CCEGLView.cpp#L219]
                 └─ 所有 gl* 扩展函数指针为 NULL
                      └─ Cocos2dRenderer::InitBatchVB() 崩溃
```

**关键发现**：`WIN7_32` 宏在 [nuengine.cpp#L390-L396](file:///e:/MT3/engine/engine/nuengine.cpp#L390-L396) 中跳过了 `CCApplication::sharedApplication()->run()`，而 `CCEGLView::initGL()` 中的 `glewInit()` 调用（[CCEGLView.cpp#L219](file:///e:/MT3/cocos2d-x-2.2.6/cocos2dx/platform/win32/CCEGLView.cpp#L219)）依赖 `CCApplication::run()` 触发。

**修复**：在 [nuengine.cpp#L409-L425](file:///e:/MT3/engine/engine/nuengine.cpp#L409-L425) 中添加 WIN7_32 路径下的显式 GLEW 初始化：
```cpp
#ifdef WIN7_32
    MT3_ENGINE_TRACE("Engine::Run WIN7_32 defined, about to ensure GLEW init");
    {
        cocos2d::CCEGLView* pEglView = cocos2d::CCEGLView::sharedOpenGLView();
        HGLRC hRC = wglGetCurrentContext();
        if (pEglView && hRC)
        {
            GLenum glewResult = glewInit();
            MT3_ENGINE_TRACE("Engine::Run glewInit before CreateRenderer result=%d", (int)glewResult);
        }
    }
#endif
```

### 4.2 崩溃分析中的误判：DLL 版本不一致

**表现**：初步怀疑运行时目录中的 DLL 与构建输出不一致导致崩溃。

**排查过程**：对比 `E:\MT3\client\resource\bin\Debug\` 与 `E:\MT3\cocos2d-x-2.2.6\Debug.win32\` 中所有 DLL 的时间戳，确认全部一致。进一步检查发现 `fmodex.dll`、`msvcp120.dll`、`msvcr120.dll` 等独立运行时 DLL 也正确存在。

**结论**：崩溃与 DLL 版本无关，问题在代码逻辑层面。

### 4.3 增量编译导致修复代码未生效

**表现**：在 `nuengine.cpp` 中添加 WIN7_32 路径的 GLEW 初始化代码后，重新编译并运行，但 `startup_bootstrap.log` 中仍无对应的 trace 日志。

**排查过程**：
1. 确认 `engine.win32.vcxproj` 中 `WIN7_32` 已定义 ✓
2. 确认 `engine.lib` 和 `MT3.exe` 时间戳晚于 `nuengine.cpp` 修改时间 ✓
3. 确认日志中其他 `MT3_ENGINE_TRACE` 正常输出 ✓
4. 但 WIN7_32 路径的 trace 始终不出现 ✗

**根本原因**：增量编译的局限——MSBuild 的增量编译基于文件时间戳和依赖图，但在某些情况下（如 PCH 预编译头未失效、中间文件残留），即使源文件已修改，部分 `.obj` 可能未被重新编译。

**解决方案**：清理所有中间构建产物后执行全量 Rebuild：
```powershell
Remove-Item -Recurse -Force "E:\MT3\engine\Debug.win32"
Remove-Item -Recurse -Force "E:\MT3\engine\engine.debug.win32"
Remove-Item -Recurse -Force "E:\MT3\client\MT3Win32App\FireClient.debug.win32"
Remove-Item -Recurse -Force "E:\MT3\client\MT3Win32App\Debug.win32"
# 然后使用 canonical 脚本全链重建
& "E:\MT3\tools\scripts\Build-MT3-Exe-Canonical.ps1" -Configuration Debug -BuildMode SafeChain
```

**验证结果**（日志确认修复生效）：
```
[MT3_ENGINE] Engine::Run WIN7_32 defined, about to ensure GLEW init
[MT3_ENGINE] Engine::Run eglView=02490310 wglGetCurrentContext=00010000
[MT3_ENGINE] Engine::Run glewInit before CreateRenderer result=0    ← GLEW_OK
[MT3_ENGINE] Engine::Run before CreateRenderer
[MT3_RNDR] Cocos2dRenderer::Create done                             ← 不再崩溃
[MT3_ENGINE] Engine::Init step 12 success state=1                   ← 引擎初始化完成
[MT3_LUA_STACK] executeScriptFile begin file=dofile_main.lua        ← 进入 Lua 阶段
```

---

## 5. 分类四：构建系统问题

### 5.1 并行编译 PDB 冲突

**表现**：构建过程中 MSBuild 报告 PDB 文件访问冲突，多个项目同时写入同一个 `.pdb` 文件。

**根因**：`FireClient.win32.vcxproj` 和 `mt3.win32.vcxproj` 共享 `$(SolutionDir)$(Configuration).win32` 输出目录，当启用并行编译 (`/m`) 时，两个项目的 PDB 生成可能冲突。

**解决方案**：
1. 禁用并行编译或使用 `/m:1` 限制单任务
2. 在构建前删除旧的 PDB 文件：
```powershell
Remove-Item -Recurse -Force "E:\MT3\client\MT3Win32App\FireClient.debug.win32" -ErrorAction SilentlyContinue
```

### 5.2 UTF-8 BOM 问题

**表现**：修改 `nuengine.cpp` 后编译报错，VS2013 的 `cl.exe` 无法正确解析文件中的非 ASCII 字符。

**根因**：VS2013 的 `cl.exe` 要求含非 ASCII 字符的 UTF-8 源文件必须带 BOM（字节顺序标记），否则会将文件误当作 ANSI 编码处理。

**解决方案**：使用 PowerShell 以 UTF-8 BOM 编码写回文件：
```powershell
$content = [System.IO.File]::ReadAllText($path)
[System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($true))
```

**注意**：`.md`、`.json`、`.xml`、`.ps1`、`.lua`、`.java` 等非 C/C++ 文件默认使用 UTF-8 无 BOM。

---

## 6. 关键技术点

### 6.1 CRT 链接模式一致性

**核心原则**：所有链接到同一最终可执行文件/DLL 的 `.lib` 必须使用相同的 CRT 链接模式。

| 模式 | 编译选项 | 运行时库 | 说明 |
|------|----------|----------|------|
| 动态 Debug | `/MDd` | `msvcrtd.dll` | MT3 Debug 主线 |
| 动态 Release | `/MD` | `msvcrt.dll` | MT3 Release 主线 |
| 静态 Debug | `/MTd` | 静态链接 | 不兼容，会产生 `LNK2005` 错误 |
| 静态 Release | `/MT` | 静态链接 | 不兼容，会产生 `LNK2005` 错误 |

**检测方法**：使用 `dumpbin /directives foo.lib | findstr "DEFAULTLIB"` 查看库的默认 CRT 链接。

### 6.2 `*_STATIC` 宏的作用

许多库通过条件编译控制是静态链接还是动态链接：

| 库 | 宏 | 作用 |
|----|-----|------|
| GLEW | `GLEW_STATIC` | 定义后使用静态链接，否则使用 `__declspec(dllimport)` |
| pthread | `PTW32_STATIC_LIB` | 定义后使用静态链接 |
| libtiff | `LIBTIFF_STATIC` | 定义后使用静态链接 |
| zlib | `ZLIB_WINAPI` | 定义后使用 `stdcall` 调用约定（通常需要移除） |
| SILLY | `SILLY_STATIC` | 定义后使用静态链接 |

**排查方法**：当链接器报告 `unresolved external symbol __imp_*` 时，说明缺少对应的 `*_STATIC` 宏。

### 6.3 WIN7_32 宏的影响范围

`WIN7_32` 是 MT3 项目中的一个关键条件编译宏，影响范围包括：

| 文件 | 影响 |
|------|------|
| [nuengine.cpp#L390-L396](file:///e:/MT3/engine/engine/nuengine.cpp#L390-L396) | 跳过 `CCApplication::run()`，需手动初始化 GLEW |
| [nuengine.cpp#L461-L464](file:///e:/MT3/engine/engine/nuengine.cpp#L461-L464) | 恢复 `CCApplication::run()` 调用 |
| [thread.h](file:///e:/MT3/common/platform/platform/thread.h) | 使用 `<thread>` 代替 `<pthread.h>` |
| [UpdateEngine.cpp#L5-L9](file:///e:/MT3/common/updateengine/UpdateEngine.cpp#L5-L9) | 使用 `UpdateManagerEx_Win.h` 代替 `UpdateManagerEx.h` |
| [nucocos2d_render.cpp#L38-L41](file:///e:/MT3/engine/renderer/nucocos2d_render.cpp#L38-L41) | 跳过 ETCHeader 包含 |

### 6.4 构建依赖拓扑

MT3 的构建顺序必须遵循以下依赖拓扑：

```
platform → ljfm → cauthc
  ↓
libBox2D, libchipmunk, liblua, cocos2d, CocosDenshion, libExtensions, CEGUI
  ↓
engine → FireClient → MT3
```

使用 `Build-MT3-Exe-Canonical.ps1` 的 `SafeChain` 模式可以自动处理依赖顺序。

### 6.5 预编译库同步路径

构建产出的 `.lib` 需要同步到多个位置：

| 目标路径 | 用途 |
|----------|------|
| `cocos2d-x-2.2.6/cocos2dx/platform/third_party/win32/libraries/` | cocos2d 链接时搜索 |
| `cocos2d-x-2.2.6/cocos2dx/platform/third_party/winrt/libraries/vs2013/Win32/` | WinRT 备用路径 |
| `dependencies/cegui/lib/` | CEGUI 依赖（如 pcre.lib） |
| `$(SolutionDir)$(Configuration).win32/` | 共享输出目录（通过构建自动产出） |

---

## 7. 经验教训

### 7.1 增量编译不可靠

**教训**：在排查"修改代码但未生效"的问题时，增量编译可能是罪魁祸首。MSBuild 的增量判断基于时间戳，但在 PCH（预编译头）、模板实例化、宏条件变化等场景下可能失效。

**建议**：当修改涉及预处理器宏、头文件包含路径或条件编译分支时，执行全量 Rebuild 而非增量 Build。

### 7.2 日志是排查运行时问题的第一手段

**教训**：`startup_bootstrap.log` 中的 `MT3_ENGINE_TRACE` 和 `MT3_RNDR` 日志是定位崩溃位置的最有效工具。没有日志时，崩溃转储分析需要更多时间且容易误判。

**建议**：在关键初始化路径上保留 trace 日志（即使问题解决后）。这些日志在生产环境可通过宏关闭，在 Debug 环境非常有价值。

### 7.3 清理后必须使用 canonical 脚本

**教训**：手动清理 `Debug.win32` 目录后，逐个工程构建容易遗漏 `platform.lib`、`cauthc.lib` 等基础依赖，导致链接失败。

**建议**：清理后始终使用 `Build-MT3-Exe-Canonical.ps1` 进行全链构建。

### 7.4 库命名约定需要统一

**教训**：不同库的输出命名约定不一致（`zlibstat.lib` vs `libzlib.lib`，`libogg.lib` vs `libogg_static.lib`），导致链接时找不到文件。

**建议**：在重构脚本中统一处理命名映射，并在构建后立即验证所有预期输出文件是否存在。

### 7.5 CRT 冲突是最高频的链接错误

**教训**：混合使用 `/MT` 和 `/MD` 编译的库是最常见的链接错误来源。`LNK2005`（符号重复定义）和 `LNK4098`（默认库冲突）几乎总是 CRT 模式不一致导致的。

**建议**：在构建任何依赖库之前，先确认目标 CRT 模式（MT3 使用 `/MDd` Debug、`/MD` Release），并确保所有库一致。

---

## 8. 预防措施与最佳实践

### 8.1 构建前检查清单

- [ ] 确认目标 `Configuration`（Debug/Release）
- [ ] 确认所有依赖库的 `RuntimeLibrary` 设置一致（`/MDd` 或 `/MD`）
- [ ] 确认所有 `*_STATIC` 宏已在对应 vcxproj 中定义
- [ ] 确认 `PlatformToolset` 为 `v120`
- [ ] 清理旧的中间文件（`*.debug.win32/`、`Debug.win32/` 下的过期 `.obj` 和 `.pdb`）
- [ ] 检查 `pcre.lib` 是否在 `dependencies/cegui/lib/` 下

### 8.2 构建命令模板

```powershell
# 全量构建（推荐）
& "E:\MT3\tools\scripts\Build-MT3-Exe-Canonical.ps1" `
    -Configuration Debug `
    -BuildMode SafeChain `
    -FastLocal `
    -SkipToolchainPrecheck `
    -SkipSourceNulScan `
    -SkipRuntimeSync `
    -SkipRuntimeAudit

# 仅重建依赖库
& "E:\MT3\tools\scripts\Rebuild-AllDependencies-v120.ps1" -Configuration Debug

# 仅重建指定库
& "E:\MT3\tools\scripts\Rebuild-AllDependencies-v120.ps1" -Configuration Debug -Libraries "zlib,libpng"
```

### 8.3 运行时验证清单

- [ ] 启动前删除旧日志：`Remove-Item startup_bootstrap.log`
- [ ] 启动 MT3.exe 后检查日志中的关键节点：
  - `Engine::Run WIN7_32 defined` → GLEW 初始化路径
  - `glewInit before CreateRenderer result=0` → GLEW 初始化成功
  - `CreateRenderer result=0` → 渲染器创建成功
  - `Engine::Init step 12 success state=1` → 引擎初始化完成
  - `executeScriptFile begin file=dofile_main.lua` → Lua 脚本加载
- [ ] 检查是否生成新的 `.dmp` 崩溃转储文件

### 8.4 常见错误速查表

| 错误信息 | 可能原因 | 解决方案 |
|----------|----------|----------|
| `LNK2005: _* already defined` | CRT 模式不一致 | 统一所有库的 `RuntimeLibrary` |
| `LNK1104: cannot open file '*.lib'` | 库文件路径不正确 | 检查库是否已构建并复制到搜索路径 |
| `unresolved external symbol __imp_glew*` | 缺少 `GLEW_STATIC` | 在 vcxproj 中添加 `GLEW_STATIC` |
| `unresolved external symbol __imp_pthread*` | 缺少 `PTW32_STATIC_LIB` | 在 vcxproj 中添加 `PTW32_STATIC_LIB` |
| `error C2001: newline in constant` | UTF-8 BOM 缺失 | 以 UTF-8 BOM 编码保存 C/C++ 源文件 |
| `fatal error C1083: Cannot open include file` | 头文件路径错误 | 检查 `AdditionalIncludeDirectories` |
| 启动闪退（无日志） | OpenGL 上下文未初始化 | 检查 `glewInit()` 是否被调用 |
| `glGenBuffers` 崩溃 | GLEW 未初始化 | 确认 `WIN7_32` 路径下有显式 GLEW 初始化 |
| 修改代码后未生效 | 增量编译未触发重建 | 清理中间文件后全量 Rebuild |

---

## 附录：文件变更清单

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `engine/engine/nuengine.cpp` | 修改 | 添加 WIN7_32 路径 GLEW 初始化代码 |
| `engine/engine.win32.vcxproj` | 修改 | 添加 `GLEW_STATIC` 宏 |
| `dependencies/cegui/project/win32/cegui.win32.vcxproj` | 修改 | 添加 `GLEW_STATIC` 宏 |
| `client/MT3Win32App/mt3.win32.vcxproj` | 修改 | 添加 `GLEW_STATIC` 宏 |
| `tools/scripts/Rebuild-AllDependencies-v120.ps1` | 新建 | 14 个依赖库的自动化构建脚本 |
| `dependencies/cegui/lib/pcre.lib` | 新建 | 从 pcre-8.31 构建输出同步 |
| `cocos2d-x-2.2.6/cocos2dx/proj.win32/cocos2d.vcxproj` | 修改 | 添加 `IgnoreSpecificDefaultLibraries` |