# CEImagesetEditor 编译构建

> **工程**：`tools/CEImagesetEditor-0.7.1/vc++9/CEImagesetEditor.sln`
> **工具链**：Visual Studio 2013 / `v120` / `Win32`
> **依赖**：CEGUI 指向共享的 `tools/CEGUI-0.7.1/`（由 `CEImagesetEditor.vcxproj` 的 `CEGUI`/`CEGUI_INCLUDE`/`CEGUI_LIB` 宏定义），wxWidgets 为自包含的 `tools/CEImagesetEditor-0.7.1/dependencies/wxWidgets-3.0.5/`
> **功能手册**：[CEImagesetEditor 技术手册](../08-技术研究/09-CEImagesetEditor技术手册.md)
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 工程事实

目录名保留历史 `vc++9`，但 `CEImagesetEditor.vcxproj` 已是 `ToolsVersion=12.0` 且 Debug/Release 均使用 `PlatformToolset=v120`。不应根据目录名将其写成 VS2008 当前工程。

| 配置 | CRT | 输出 | 主要库 |
| --- | --- | --- | --- |
| Debug | `/MDd` | `tools/CEImagesetEditor-0.7.1/bin/debug/CEImagesetEditor_d.exe` | `CEGUIBase_d`、`CEGUIOpenGLRenderer_d`、wxWidgets 3.0.5 debug |
| Release | `/MD` | `tools/CEImagesetEditor-0.7.1/bin/release/CEImagesetEditor.exe` | `CEGUIBase`、`CEGUIOpenGLRenderer`、wxWidgets 3.0.5 release |

后构建事件会复制 CEGUI DLL、SILLY DLL 和 `data/` 到对应 `bin` 目录。

## 2. 构建前检查

```powershell
Set-Location E:\MT3
$root = '.\tools\CEImagesetEditor-0.7.1'
$cegui = '.\tools\CEGUI-0.7.1'
@(
  "$root\vc++9\CEImagesetEditor.sln",
  "$root\vc++9\CEImagesetEditor.vcxproj",
  "$cegui\cegui\include",
  "$cegui\lib",
  "$root\dependencies\wxWidgets-3.0.5\include",
  "$root\dependencies\wxWidgets-3.0.5\lib\vc_lib"
) | ForEach-Object { [pscustomobject]@{ Path = $_; Exists = Test-Path -LiteralPath $_ } }
```

若任一必需路径为 `False`，先检查 Git LFS/仓库资产，不要改工程去引用客户端 `dependencies/cegui/` 或 `tools/CEGUI-0.7.9-r5/`。

## 3. 命令行构建

Release：

```powershell
Set-Location E:\MT3
$msbuild = Join-Path ${env:ProgramFiles(x86)} 'MSBuild\12.0\Bin\MSBuild.exe'
& $msbuild '.\tools\CEImagesetEditor-0.7.1\vc++9\CEImagesetEditor.sln' /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /m
```

Debug：

```powershell
Set-Location E:\MT3
$msbuild = Join-Path ${env:ProgramFiles(x86)} 'MSBuild\12.0\Bin\MSBuild.exe'
& $msbuild '.\tools\CEImagesetEditor-0.7.1\vc++9\CEImagesetEditor.sln' /t:Rebuild /p:Configuration=Debug /p:Platform=Win32 /m
```

## 4. 产物校验

```powershell
$release = '.\tools\CEImagesetEditor-0.7.1\bin\release'
Get-ChildItem -LiteralPath $release -File | Sort-Object Name | Select-Object Name,Length,LastWriteTime
Test-Path -LiteralPath "$release\CEImagesetEditor.exe"
Test-Path -LiteralPath "$release\data"
```

启动验证至少包括：

1. EXE 可从对应 `bin/debug` 或 `bin/release` 启动。
2. CEGUI XML parser、Falagard、SILLY/TGA codec 与 OpenGL renderer DLL 可加载。
3. `data/` 已复制，新建/打开 Imageset 时无首个资源阻断。
4. 导入图片、生成/编辑 region、保存 `.imageset` 完成一次往返。

## 5. 常见故障

| 现象 | 直接检查 |
| --- | --- |
| `MSB8020` | VS2013 C++ v120 工具集和 Windows SDK 8.1。 |
| 找不到 `CEGUIBase[_d].lib` | 工程宏 `CEGUI_LIB` 是否指向共享的 `tools/CEGUI-0.7.1/lib`。 |
| 找不到 `wx*.lib` | `wxWidgets-3.0.5/lib/vc_lib` 是否完整，Debug/Release 库后缀是否匹配。 |
| EXE 可链接但启动缺 DLL | 检查后构建事件输出和 `bin/<config>` 中的 CEGUI/SILLY DLL。 |
| 启动后缺资源 | 检查 `data/` 复制、工作目录和资源相对路径。 |
| Debug/Release CRT 冲突 | 检查 CEGUI、wxWidgets 和工具工程的 `/MDd`/`/MD` 一致性。 |

## 6. 职责边界

- 本页只维护构建与产物验证。
- 区域编辑、自动检测、命名、导出和 XML 格式见 [CEImagesetEditor 技术手册](../08-技术研究/09-CEImagesetEditor技术手册.md)。
- 客户端 CEGUI 主线仍是 `dependencies/cegui/` 的 0.7.1 定制实现，不以该工具的自包含库替代。
