# Win32 v120 构建细节

## 目录

- [固定入口与模式](#固定入口与模式)
- [ABI 重编顺序](#abi-重编顺序)
- [手动排障命令](#手动排障命令)
- [C2001 与 UTF-8 BOM](#c2001-与-utf-8-bom)
- [产物验证](#产物验证)
- [性能经验边界](#性能经验边界)
- [深度文档](#深度文档)

## 固定入口与模式

canonical wrapper：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32
```

模式选择：

```powershell
# 日常 Debug，最快
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -FastLocal -MaxParallelJobs 8

# 日常 Release 增量
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode Incremental -MaxParallelJobs 8

# 发版前整链
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit

# 里程碑 Debug + Release
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both -MaxParallelJobs 8 -StrictRuntimeAudit
```

日常默认不加 `-Clean`。ABI 敏感头、工具链漂移或发版验收才使用 SafeChain/FullValidation。Incremental 被 ABI 防护拒绝时按提示切回 SafeChain。

## ABI 重编顺序

Win32 主链顺序：

1. `common/platform`
2. `common/ljfm`
3. `common/lua`
4. `common/cauthc`
5. `Box2D`
6. `liblua`
7. `libcocos2d`
8. `libCocosDenshion`
9. `engine`
10. `FireClient`
11. `MT3`

最低强制规则：

- `engine/**.h`、renderer/framework 公共布局变更：`Rebuild engine -> Rebuild FireClient -> Build MT3`
- `client/FireClient/Application/**.h` ABI 变更：`Rebuild FireClient -> Build MT3`
- Cocos/CocosDenshion 变更：重编对应库及全部下游

禁止跨工具集替换 `.lib/.dll/.exe`，禁止 `/FORCE` 掩盖 CRT、符号或对象布局冲突。

## 手动排障命令

手动命令只用于定位 canonical wrapper 的内部失败，不替代外部入口：

```powershell
cmd /c 'call "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 && msbuild engine\engine.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo'

cmd /c 'call "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 && msbuild client\MT3Win32App\FireClient.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo'

cmd /c 'call "D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86 && msbuild client\MT3Win32App\mt3.win32.vcxproj /t:Build /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo'
```

PowerShell 里调用 cmd 语法时必须显式 `cmd /c`，不要混用 `%VAR%` 与 `$env:VAR`。

## C2001 与 UTF-8 BOM

同时满足以下信号时先查 BOM：

- VS2013/cl.exe 编译 C/C++ 文件
- 错误集中在中文 `L"..."` 或普通中文字符串附近
- hex 中字符串完整，但稳定报 `C2001: 常量中有换行符`

先探测原编码。若文件确为无 BOM UTF-8 且含非 ASCII，恢复 UTF-8 BOM 后 Rebuild；不要批量转码：

```powershell
$enc = New-Object System.Text.UTF8Encoding($true)
$text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($path, $text, $enc)
```

恢复 BOM 后仍失败，才检查真实跨行字符串、宏展开或内容损坏。

## 产物验证

```powershell
Get-Item .\client\resource\bin\Release\MT3.exe
Get-Item .\client\MT3Win32App\Release.win32\FireClient.lib
Get-Item .\client\MT3Win32App\Release.win32\engine.lib
```

核对：

- 工具集仍是 v120
- 三个产物时间戳符合本次重编顺序
- canonical wrapper 返回 0
- 若有运行时变更，执行 runtime audit 或 smoke，不只看文件存在

## 性能经验边界

历史实测只用于估算，不作为成功判据：SafeChain 可能接近一小时；热 Debug/Release 增量可降到分钟或秒级；首次大范围增量仍可能触发长时间重编。

## 深度文档

- `.claude/BUILD_GUIDE.md`
- `.claude/skills/client/windows-build.md`
- `docs/03-开发指南/02-Windows完整构建指南.md`
- `docs/03-开发指南/04-Windows构建命令速查.md`
