# 第三方运行库说明

GUI 发布包包含以下运行时组件：

- .NET Desktop Runtime 10（由 `dotnet publish --self-contained` 写入发布目录）。发布目录中的 .NET 运行时文件沿用 Microsoft .NET 的许可和再分发条款。
- `msvcp120.dll`、`msvcr120.dll`（Microsoft Visual C++ 2013 x86 Redistributable）。这两个 DLL 仅用于 Win32 `LJFilePack.exe`，沿用 Microsoft Visual C++ 再分发条款。

核对入口：

- .NET：<https://dotnet.microsoft.com/platform/free>
- Visual C++ 2013 再分发：<https://learn.microsoft.com/visualstudio/releases/2013/2013-redistribution>

发布脚本会把本说明复制到最终目录，并在发布完成前检查文件存在。
