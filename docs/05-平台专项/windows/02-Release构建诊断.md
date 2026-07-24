# Windows Release 构建诊断

> 返回 [Windows 完整构建指南](../../03-开发指南/02-Windows完整构建指南.md)。本页只处理 `Release|Win32` 的首错取证与定向诊断；标准构建入口仍是 Canonical wrapper。

## 1. 基线

- 工具链：VS2013 / v120 / Windows SDK 8.1 / MSBuild 12.0。
- 入口：`tools/scripts/Build-MT3-Exe-Canonical.ps1`。
- 内部链：`client/Build-MT3-v120.ps1`。
- 最终产物：`client/resource/bin/Release/MT3.exe`。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 `
  -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit
```

## 2. 首错取证

构建失败后先记录：

```powershell
git status --short
Get-ChildItem -LiteralPath .\build_logs -File | Sort-Object LastWriteTime -Descending | Select-Object -First 10 Name,Length,LastWriteTime
rg -n "error C[0-9]+|fatal error|LNK[0-9]+|MSB[0-9]+" build_logs
```

只处理最早出现的编译/链接错误，后续错误通常是级联结果。

## 3. 常见首错

### 3.1 C1083：文件不存在

1. 核对工程项引用的相对路径。
2. 判断文件应从真源恢复，还是工程项已过期。
3. 不创建同名空文件绕过编译。

```powershell
Select-String -Encoding UTF8 -LiteralPath .\client\MT3Win32App\FireClient.win32.vcxproj -Pattern 'ClCompile Include|ClInclude Include'
```

### 3.2 C1041：PDB 并发写入

先确认是否多个工程/编译单元共享 PDB 或中间目录。仅在已定位并发冲突时，把相关诊断构建降为串行；不要永久关闭全链并行以掩盖目录冲突。

### 3.3 LNK1104：库文件找不到

核对上游项目是否真实重编、输出路径是否与 `AdditionalLibraryDirectories` 一致、当前配置是否为 `Release|Win32`。不要跨工具集复制旧 `.lib`。

### 3.4 LNK2001/LNK1120：符号未解析

核对声明/定义、导出宏、调用方和库版本；若接口或公共头文件刚改变，按依赖顺序重编对应库及下游。

### 3.5 LNK4098/CRT 冲突

检查 `RuntimeLibrary` 是否在库链上保持一致。禁止使用 `/FORCE` 或盲目追加 `/NODEFAULTLIB` 作为交付修复。

## 4. ABI 混编诊断

出现以下信号时停止增量补链：

- fresh process 在初始化阶段崩于容器或 `this + offset`；
- 同名类型出现两套 `sizeof`/成员偏移；
- `engine.lib`、`FireClient.lib`、`MT3.exe` 时间戳不符合重编顺序。

恢复顺序：

- 影响 `engine`：`Rebuild engine -> Rebuild FireClient -> Build MT3`。
- 仅影响 `FireClient` ABI：`Rebuild FireClient -> Build MT3`。

优先让 Canonical wrapper 执行 `SafeChain`，不要手工替换二进制。

## 5. 产物与运行时诊断

```powershell
Get-Item .\client\resource\bin\Release\MT3.exe | Select-Object FullName,Length,LastWriteTime
Get-ChildItem .\client\resource\bin\Release -File | Select-Object Name,Length,LastWriteTime
```

构建成功但启动失败时：

1. 保存 runtime audit 报告。
2. 核对同目录 DLL 来源与位数。
3. 检查 Windows 事件日志、应用日志和 DMP。
4. 使用匹配本次构建的 EXE/PDB 解析崩溃。

## 6. 关联文档

- [Windows 完整构建指南](../../03-开发指南/02-Windows完整构建指南.md)
- [Windows 构建前检查清单](../../03-开发指南/03-Windows构建前检查清单.md)
- [编译问题排查](../../04-问题排查/01-编译问题排查.md)
- [DMP 调试与崩溃栈分析](../../04-问题排查/05-DMP调试与崩溃栈分析.md)
