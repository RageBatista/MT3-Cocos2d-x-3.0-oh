# MT3 已验证构建命令（BUILD_GUIDE）

> **版本**: 2.5.0
> **更新日期**: 2026-04-24
> **定位**: 本文件只保留当前仓库已核验、且在当前工作机上可执行的命令；不放专题排障、案例分析和历史脚本。

---

## 说明

- 以下命令按 2026-04-05 当前工作机环境核验。
- 工具链路径已验证：
  - `D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat`
  - `C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe`
- 当前仓库存在并已核验的脚本：
  - `tools/scripts/Build-MT3-Exe-Canonical.ps1`
  - `tools/scripts/Build-MT3-FullValidation.ps1`
  - `client/Build-MT3-v120.ps1`
  - `tools/scripts/Check-v120Toolset.ps1`
  - `tools/scripts/Audit-RuntimeDependencies.ps1`

## 环境检查

### 1. 检查 v120 工具链

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
```

当前仓库实测说明：

- 默认只检查 Win32 主线链路的 11 个工程，避免把 WinRT/WP8/vendor 工程误判成主线失败。
- 会同时检查 `VS120COMNTOOLS/vcvarsall` 与 `MSBuild 12.0`。
- 如需扫描整个仓库的 `.vcxproj`，显式使用 `-Scope All`：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1 -Scope All
```

### 2. 查看 MSBuild 版本

```powershell
cmd /c '"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" /version'
```

## Win32 客户端构建

### 0. ABI 混编防护（Win32 必读）

以下场景不得只做单项目增量 `Build`，必须按整链顺序重编：

- 修改 `engine/**.h`
- 修改 `client/FireClient/Application/**.h`
- 修改 renderer、engine、framework、公共基类相关头文件
- 修改任何会影响类布局、虚函数表、成员偏移、模板实例或内联实现的公共头文件

强制顺序：

- 影响 `engine` ABI 的改动：`Rebuild engine -> Rebuild FireClient -> Build MT3`
- 仅影响 `FireClient` ABI 的改动：`Rebuild FireClient -> Build MT3`

补充：

- `client/MT3Win32App/FireClient.win32.vcxproj` 与 `client/MT3Win32App/mt3.win32.vcxproj` 共享 `Release.win32` 输出目录（`IntDir` 按项目名分离），局部增量构建仍不能证明产物 ABI 一致。
- 若 fresh process 在启动初始化阶段崩在容器访问或 `this + offset` 成员访问处，应优先复核 ABI 混编，而不是先归因到业务逻辑。

### 1. 手动重编 engine（Release|Win32）

```powershell
cmd /c 'call "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 && msbuild engine\engine.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo'
```

适用场景：

- 修改 `engine/**`
- ABI 敏感头文件变更后，需要从引擎层重新生成一致产物

### 2. 手动重编 FireClient（Release|Win32）

```powershell
cmd /c 'call "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 && msbuild client\MT3Win32App\FireClient.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo'
```

适用场景：

- 修改 `client/FireClient/Application/**`
- 需要确认 `FireClient.lib` 已真实刷新，而不是被共享中间目录的增量构建短路

### 3. 重链主程序 MT3（Release|Win32）

```powershell
cmd /c 'call "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 && msbuild client\MT3Win32App\mt3.win32.vcxproj /t:Build /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo'
```

适用场景：

- `FireClient` 已重编完成后，刷新最终 `MT3.exe`
- 仅修改 `client/MT3Win32App/**` 时，也可直接使用该命令

### 4. 固定入口脚本（唯一，返回稳定退出码）

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release
```

说明：

- 这是“构建 `MT3.exe` 并返回成功退出码”的固定唯一入口。
- 脚本会自动补齐 `ProgramFiles(x86)`、`VS120COMNTOOLS`、`MT3_MSBUILD_PATH`（若缺失）。
- 脚本在正式构建前会自动调用 `tools/scripts/Ensure-MT3-Win32-LinkDeps.ps1`，补齐 `silly/libspeex/libogg/libvorbis/freetype` 等 Win32 外部链接依赖，并在缺失时重建 `libSpine/esUtil/SILLY/libspeex/libogg/libvorbis`。
- 脚本内部调用 `client/Build-MT3-v120.ps1`，并固定 `SafeChain` ABI 链路。
- 默认启用 `-RuntimeAuditWarnOnly -AllowArchiveRuntimeFallback`，避免 runtime audit 的历史 High 项阻断退出码。
- 若编译成功且产物存在，脚本返回 `0`；若构建失败或缺少产物，脚本返回非 `0`。
- 若需严格模式（runtime audit High 直接失败）：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -StrictRuntimeAudit
```

如需单独预修复 Win32 链接依赖，可显式运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Ensure-MT3-Win32-LinkDeps.ps1 -Configuration Debug
```

### 4.1 构建模式分层（Win32 提速规则）

```powershell
# 日常开发（推荐，最快）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -FastLocal -MaxParallelJobs 8

# 日常 Release 快速验证（不做全量重建）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode Incremental -MaxParallelJobs 8

# 发版前安全构建（全链路 SafeChain）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit

# 里程碑全量验证（最慢）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both -MaxParallelJobs 8 -StrictRuntimeAudit
```

执行约束：
- 日常构建默认不加 `-Clean`。
- 仅在 ABI 敏感头文件改动、工具链漂移排查或发版前，使用 `SafeChain` / `FullValidation`。
- `-MaxParallelJobs` 根据机器核数调整（如 `8/12/16`）。
- 若 `Incremental` 被 ABI 防护拦截，按提示切回 `SafeChain` 执行一次。

### 5. Debug + Release 全量验证（构建 + 审计 + 可选实跑）

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both
```

常用参数：

- `-StrictRuntimeAudit`：把 runtime audit High 问题升级为失败。
- `-RunSmoke -SmokeSeconds 30`：对每个配置启动 `MT3.exe` 做短时实跑。
- `-RunP0Collectors`：执行 Win32 `[P0][BOOT]` 与 `[P0][EFFECT]` 日志采样脚本。
- `-ReportPath build_logs/xxx.json`：指定整体验证报告输出路径。

默认输出：

- 汇总报告：`build_logs/mt3-full-validation-report.json`
- 分配置 runtime audit 报告：
  - `build_logs/runtime-audit-release-full-validation.json`
  - `build_logs/runtime-audit-debug-full-validation.json`

## Android 客户端构建（Locojoy）

### 0. 环境硬门禁（JDK8 + 完整旧 SDK）

当前工作机在 2026-06-18 已验证的 Android 打包环境：

- JDK：`C:\Program Files\Java\jdk1.8.0_144`
- Ant：`D:\apache-ant-1.9.7\bin\ant.bat`
- Ant 打包 SDK：`D:\android-sdk_r24.1.2-windows\android-sdk-windows`
- arm64 native NDK：`D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd`

必须先确认 JDK8 门禁：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Assert-AndroidJdk8Gate.ps1 -JdkHome "C:\Program Files\Java\jdk1.8.0_144"
```

常见坑复盘：

- `D:\Android\android-sdk-64` 有 NDK r16，但缺 `tools\ant\build.xml`，不可作为 Ant `ANDROID_HOME`。
- `D:\Android\android-sdk-windows` 有 `tools\ant\build.xml`，但本机缺 `platform-tools`，会报 `SDK Platform Tools component is missing`。
- `D:\android-sdk_r24.1.2-windows\android-sdk-windows` 同时具备 `tools/ant`、`platform-tools`、`build-tools/22.0.1`、`platforms/android-22`，是当前 Ant 打包 SDK。
- JDK17 会触发旧 Ant 工程 `source/target 5 is no longer supported`，不得进入 Android 构建链。
- 机器级 `Oracle\Java\javapath` 可能抢占 `java/javac`；构建脚本会在当前进程内强制 `JAVA_HOME\bin` 优先，但系统级清理需管理员权限。

推荐在 PowerShell 中显式设置本次构建环境：

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_144"
$env:ANDROID_HOME = "D:\android-sdk_r24.1.2-windows\android-sdk-windows"
$env:ANDROID_SDK_ROOT = "D:\android-sdk_r24.1.2-windows\android-sdk-windows"
$env:Path = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\tools;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\build-tools\22.0.1;$env:Path"
```

Release 签名必须从本机环境变量或脚本参数注入，禁止把密码写入 `client/android/**/ant.properties`：

```powershell
$env:MT3_ANDROID_KEYSTORE = "E:\MT3\client\chuhancommon\android_adt"
$env:MT3_ANDROID_KEY_ALIAS = "LJ"
$env:MT3_ANDROID_KEYSTORE_PASSWORD = "<本机或 CI Secret 注入>"
$env:MT3_ANDROID_KEY_ALIAS_PASSWORD = "<本机或 CI Secret 注入>"
```

### 1. 固定入口脚本（推荐）

如本轮包含资源改动，先回到资源源目录生成 Android 打包资源；不要手动修改 `client/android/LocojoyProject/assets/res/**`：

```powershell
cmd /c "cd /d E:\MT3\client\resource\tools && LJFilePack_打包安卓.bat"
```

```powershell
# 免费服
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir "client/android/LocojoyProject" -BuildType Release -Channel free -Jobs 4 -CleanIntermediates -SyncRes -ResSourceDir "client/res_android/res" -NdkBuildPath "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd" -JdkHome $env:JAVA_HOME -AndroidSdkRoot $env:ANDROID_HOME -RequireArm64InApk

# 点卡服当前未恢复/未验证；脚本会拒绝 -Channel monthpayment，直到 build_monthpayment.xml 恢复并重新验收。

# 64位包（当前 LocojoyProject arm64-v8a 编译闭环）
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Assert-AndroidArm64Migration.ps1
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir "client/android/LocojoyProject" -BuildType Debug -Channel free -Jobs 4 -SyncRes -ResSourceDir "client/res_android/res" -NdkBuildPath "D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd" -JdkHome $env:JAVA_HOME -AndroidSdkRoot $env:ANDROID_HOME -RequireArm64InApk
```

说明：

- 脚本固定执行 `ndk-build clean -> ndk-build -> ant debug/release -> APK 结构门禁 -> ABI 门禁 -> zipalign`。
- 脚本会在当前构建进程内强制 JDK8 和完整旧 SDK；显式传错 `-JdkHome` 会立即失败，不会进入 ndk-build。
- Release 签名密码只允许来自 `MT3_ANDROID_*` 环境变量或显式参数，禁止提交到源码。
- 业务资源源头固定为 `client/resource/res/**`；改资源先运行 `client/resource/tools/LJFilePack_打包安卓.bat`，不要直接改 Android 工程内产物。
- `client/res_android/res` 是打包后的 Android 资源同步输入；推荐固定加 `-SyncRes -ResSourceDir "client/res_android/res"`。
- `client/android/LocojoyProject/assets/res/**` 是同步到 APK 工程的生成产物，严禁手工修改；如需更新，只能由打包脚本和 `-SyncRes`/构建链刷新。
- 启用 `-RequireArm64InApk` 时，会在结构门禁后执行 ABI 门禁，校验 APK 内 `lib/arm64-v8a` 及必需 so。
- 默认会自动探测 `ndk-build.cmd` 与 `ant.bat`；也可显式传 `-NdkBuildPath/-AntPath`。
- `Assert-AndroidArm64Migration.ps1` 是 arm64 构建前置总门禁：会校验 `Application.mk`、当前 `cocos2d-x-2.2.6` 下的 arm64 静态库、`libxml2/libwebp` import 不得漂回旧 2.0 树、JNI ClassLoader bridge，以及 common/Locojoy/Joysdk/Yijie 的 `nativeInitJniBridge(this) -> nativeSetPaths(...)` 顺序。
- `cocos2d-x-2.2.6/cocos2dx/platform/third_party/android/prebuilt/libwebp/libs/arm64-v8a/libwebp.a` 与 `libxml2/libs/arm64-v8a/libxml2.a` 是 arm64 基线归档文件，必须随当前 2.2.6 树纳入版本控制；若被 `.gitignore` 忽略，总门禁会失败。

### 2. 手动命令（排障兜底）

```powershell
cd client/android/LocojoyProject
cmd /c "set ProgramW6432=C:\Program Files&& D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd clean"
cmd /c "set ProgramW6432=C:\Program Files&& D:\Android\android-sdk-64\ndk\16.1.4479499\ndk-build.cmd NDK_DEBUG=0 -j4"
D:\apache-ant-1.9.7\bin\ant.bat -buildfile build.xml debug
```

点卡服当前未恢复/未验证；不要在主线手动命令中替换为 `build_monthpayment.xml`。

### 3. Android 产物校验

```powershell
Get-Item .\client\android\LocojoyProject\bin\mt3-debug.apk | Select-Object FullName, Length, LastWriteTime
Get-FileHash .\client\android\LocojoyProject\bin\mt3-debug.apk -Algorithm SHA256
```

```powershell
& "D:\android-sdk_r24.1.2-windows\android-sdk-windows\build-tools\22.0.1\aapt.exe" dump badging .\client\android\LocojoyProject\bin\mt3-debug.apk
```

## 产物校验

### 0. C2001 / 中文字符串诡异报错排障（VS2013 必读）

若 Win32/工具工程在 VS2013 下出现以下现象：

- `error C2001: 常量中有换行符`
- 报错行集中在中文 `L"..."` 宽字符串或普通中文字符串附近
- 字节级检查（hex dump）显示字符串完整、没有物理换行
- 清理中间目录并 `Rebuild` 后仍报同样的 C2001

优先按“**源码 UTF-8 BOM 丢失**”处理，而不是先怀疑字符串内容本身损坏。

原因：

- VS2013 的 `cl.exe` 在读取**无 BOM 的 UTF-8 C/C++ 源文件**时，会按系统默认编码（通常是 `CP936/GBK`）解析源码。
- 含中文的 UTF-8 多字节序列会被错误解码，最终表现为编译器视角中的伪断行、伪字符串闭合失败、后续语法级联报错。
- 这是**解码器选错**问题，不一定能从文本视图或简单十六进制检查看出。

最小处理顺序：

1. 先确认报错文件是否为 C/C++ 源文件，且包含中文或其他非 ASCII 字符。
2. 检查文件是否缺少 UTF-8 BOM。
3. 若缺少 BOM，用显式 `UTF8Encoding($true)` 读写原文本，恢复 BOM 后再 `Rebuild`。
4. 只有在恢复 BOM 后错误仍存在时，才继续检查真实字符串拼接、宏展开或换行损坏。

参考修复：

```powershell
$enc = New-Object System.Text.UTF8Encoding($true)
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($path, $text, $enc)
```

经验边界：

- 本问题在 `tools/**` 下的 Win32 工具工程同样成立，不只限于 `client/**`。
- 若文件原本就是 `UTF-8 with BOM`，不要反向改成 `UTF-8 no BOM`。
- 对 `.md/.json/.ps1` 等文本文件仍按各自规则执行；此经验主要针对交给 VS2013/cl.exe 编译的 C/C++ 源文件。

### 1. 检查 Win32 主程序产物

```powershell
Get-Item .\client\resource\bin\Release\MT3.exe | Select-Object FullName, Length, LastWriteTime
```

### 2. 检查中间产物目录

```powershell
Get-Item .\client\MT3Win32App\Release.win32\MT3.exe | Select-Object FullName, Length, LastWriteTime
Get-Item .\client\MT3Win32App\Release.win32\FireClient.lib | Select-Object FullName, Length, LastWriteTime
Get-Item .\client\MT3Win32App\Release.win32\engine.lib | Select-Object FullName, Length, LastWriteTime
```

### 3. ABI 一致性复核

建议在以下情况下执行：

- 刚做过 ABI 敏感头文件改动
- 曾经只做过局部 `Build`，现在需要确认是否存在混编风险
- 新进程启动期出现异常崩溃，且堆栈落在引擎初始化、容器访问或成员偏移访问

最低复核要求：

- 确认 `engine.lib`、`FireClient.lib`、`MT3.exe` 的 `LastWriteTime` 与本次重编顺序一致
- 确认使用的是 `v120` 工具链，而不是其他 `PlatformToolset`
- 若 dump 或 PDB 中出现同名类型两套布局记录，直接按本文件第 0 节顺序整链重编

## Launcher 与服务器入口（路径已核验存在）

### 1. Launcher 解决方案路径

```powershell
Get-Item .\client\Launcher\Launcher.sln
```

### 2. 服务器主构建入口路径

```powershell
Get-Item .\server\server\game_server\build.xml
```

## 说明边界

- 本文件不再记录登录链路、时装缺失、后台残留等专题排障。
- 这些内容应下沉到对应问题文档，而不是继续混入构建指南。
- 若某命令路径失效或命令无法执行，应先修正文档，再继续扩充本文件。
