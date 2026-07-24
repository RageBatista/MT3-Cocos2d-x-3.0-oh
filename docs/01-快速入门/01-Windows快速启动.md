# 01-Windows 快速启动

> **适用范围**：MT3 Win32 客户端主线
> **工具链**：Visual Studio 2013、`v120`、Windows SDK 8.1、MSBuild 12.0
> **外部构建入口**：`tools/scripts/Build-MT3-Exe-Canonical.ps1`

## 1. 准备环境

在仓库根目录打开 PowerShell，确认以下组件已安装：

- Visual Studio 2013 C++ 工具链；
- Windows SDK 8.1；
- MSBuild 12.0；
- Git LFS，且仓库 LFS 文件已签出。

运行主线环境检查：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Check-v120Toolset.ps1
```

预期结果：VS2013/`vcvarsall.bat`、MSBuild 12.0 和 Win32 主线工程的 `v120` 检查通过。

## 2. 选择构建模式

### 日常 Debug 开发

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -Platform Win32 -FastLocal -MaxParallelJobs 8
```

`-FastLocal` 会使用增量模式，并默认跳过工具链预检和 runtime audit，适合已完成首次环境检查后的本地迭代。

### 日常 Release 验证

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode Incremental -MaxParallelJobs 8
```

### ABI 改动或发版前验证

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit
```

以下变更不要使用普通增量构建：

- `engine/**.h`、renderer/framework 公共头或对象布局发生变化；
- `client/FireClient/Application/**.h` 中类成员、继承、虚函数、模板或内联实现发生变化；
- 已怀疑存在不同工具集、不同头文件版本或不同宏展开结果的混编产物。

## 3. 验证产物

```powershell
Get-Item .\client\resource\bin\Debug\MT3.exe | Select-Object FullName, Length, LastWriteTime
Get-Item .\client\resource\bin\Release\MT3.exe | Select-Object FullName, Length, LastWriteTime
Get-ChildItem .\build_logs -Filter 'msbuild_*_Win32.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 10
```

只检查本次构建的配置。构建脚本退出码为 `0` 且对应 `MT3.exe` 存在，才表示构建阶段完成。

## 4. 从运行目录启动

客户端依赖相对路径资源。启动前切到对应运行目录：

```powershell
Push-Location .\client\resource\bin\Debug
try {
    .\MT3.exe
} finally {
    Pop-Location
}
```

Release 验证时将目录替换为 `client/resource/bin/Release`。

## 5. 修改后的重编边界

- `client/FireClient/Application/**` 业务改动：至少重编 `FireClient`，再链接 `MT3`。
- `engine/**` 改动：重编 `engine`，再重编下游。
- ABI 敏感头文件：按 [Windows 完整构建指南](../03-开发指南/02-Windows完整构建指南.md) 执行强制 Rebuild 链，不能只做单项目增量构建。

## 6. 失败时

- 首个构建错误：[Release 构建诊断](../05-平台专项/windows/02-Release构建诊断.md)
- 通用编译问题：[编译问题排查](../04-问题排查/01-编译问题排查.md)
- 崩溃与 DMP：[DMP 调试与崩溃栈分析](../04-问题排查/05-DMP调试与崩溃栈分析.md)
- 命令速查：[Windows 构建命令速查](../03-开发指南/04-Windows构建命令速查.md)

## 7. 下一步

- [项目概述](./02-项目概述.md)
- [Windows 编译环境准备](../03-开发指南/01-Windows编译环境准备.md)
- [Windows 完整构建指南](../03-开发指南/02-Windows完整构建指南.md)
- [Windows 构建前检查清单](../03-开发指南/03-Windows构建前检查清单.md)
- [Windows 构建命令速查](../03-开发指南/04-Windows构建命令速查.md)
- [编译问题排查](../04-问题排查/01-编译问题排查.md)
