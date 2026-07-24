# Launcher 编译构建

> **工程**：`client/Launcher/Launcher.sln` / `client/Launcher/Launcher.vcxproj`
> **工具链**：Visual Studio 2013，`v120`，`Win32`，Debug/Release
> **Release 产物**：`client/resource/Launcher.exe`
> **架构说明**：[06-Launcher技术说明](06-Launcher技术说明.md)
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 工程事实

`Launcher.vcxproj` 当前明确声明：

- `ToolsVersion=12.0`，Debug/Release 均为 `PlatformToolset=v120`。
- 工程类型为 Windows `Application`，字符集为 Unicode。
- Debug 使用静态调试 CRT `MultiThreadedDebug` (`/MTd`)。
- Release 使用静态 CRT `MultiThreaded` (`/MT`)。
- 系统链接库包括 `gdiplus.lib`、`ws2_32.lib`、`winmm.lib`、`wldap32.lib`、`Msimg32.lib`。
- Release `OutputFile` 固定为 `../resource/$(ProjectName).exe`，即 `client/resource/Launcher.exe`。

Launcher 的 CRT 选择与 MT3 游戏客户端主链不同；不要为了“全仓统一”擅自改写。

## 2. 构建前检查

```powershell
Set-Location E:\MT3
Test-Path .\client\Launcher\Launcher.sln
Test-Path .\client\Launcher\Launcher.vcxproj
rg -n '<PlatformToolset>|<RuntimeLibrary>|<OutputFile>' .\client\Launcher\Launcher.vcxproj
```

预期可看到 `v120`、Debug `/MTd`、Release `/MT` 以及 Release 固定输出路径。

## 3. 命令行构建

在 PowerShell 中显式调用 MSBuild 12.0：

```powershell
Set-Location E:\MT3
$msbuild = Join-Path ${env:ProgramFiles(x86)} 'MSBuild\12.0\Bin\MSBuild.exe'
& $msbuild .\client\Launcher\Launcher.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /m
```

Debug：

```powershell
Set-Location E:\MT3
$msbuild = Join-Path ${env:ProgramFiles(x86)} 'MSBuild\12.0\Bin\MSBuild.exe'
& $msbuild .\client\Launcher\Launcher.sln /t:Rebuild /p:Configuration=Debug /p:Platform=Win32 /m
```

也可使用 VS2013 打开 `Launcher.sln`，选择 `Win32` 和目标配置后执行 Rebuild。

## 4. 产物验证

Release 构建后：

```powershell
$launcher = Resolve-Path .\client\resource\Launcher.exe
Get-Item -LiteralPath $launcher | Select-Object FullName,Length,LastWriteTime
Get-FileHash -Algorithm SHA256 -LiteralPath $launcher
```

需要启动验证时，先保留现有可回滚产物，再从 `client/resource/` 所需的真实运行目录启动；更新 URL、资源和运行环境以当前配置为准。

## 5. 常见阻断

| 现象 | 首先检查 |
| --- | --- |
| `MSB8020` / v120 缺失 | VS2013 C++ 工具集和 Windows SDK 8.1 是否完整安装。 |
| 构建成功但找不到 Release 产物 | 检查 `client/resource/Launcher.exe`，不要只在工程默认 `Release/` 目录查找。 |
| 链接系统库失败 | 检查 Windows SDK 8.1 和 `Launcher.vcxproj` 的 `AdditionalDependencies`。 |
| 启动后网络/更新失败 | 这是运行时配置或 Launcher 业务链问题，继续按 [06-Launcher技术说明](06-Launcher技术说明.md) 取证。 |

## 6. 变更后最小验证

1. Release/Win32 Rebuild 退出码为 0。
2. `client/resource/Launcher.exe` 时间戳更新。
3. 应用入口可启动，DUI 主窗口可见。
4. 版本检查、下载和更新状态转换没有新增首个阻断。
5. 保存 MSBuild 日志、EXE 哈希和回滚副本。
