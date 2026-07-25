# SplitImageset（GUI 版）

SplitImageset 是 MT3 UI 资源链路中的离线预处理工具，用于按 3 宫格 / 9 宫格规则拆分 `*.imageset` 里的目标 `Image` 节点并写回原文件。

本次重构将原控制台交互改为原生 Win32 GUI：

- 选择 `SplitConfig.xml`
- 选择 imageset 根目录
- 勾选“覆盖前备份为 `.bak`”
- 一键执行并查看日志

同时保留可选批处理入口（便于流水线验证）：

```powershell
tools\SplitImageset\Release\SplitImageset.exe --batch --config <SplitConfig.xml路径> --imageset-root <imageset目录> [--no-backup]
```

## 输入与输出规范

输入：

- 配置文件：`SplitConfig.xml`
- 目标资源：`<imageset-root>\\*.imageset`

配置项（每行一个 `<frame .../>`）：

- `imageset`：目标 imageset 文件名（支持相对路径）
- `image`：要拆分的原图节点名
- `type`：`OnlyWidth` / `OnlyHeight` / `WidthAndHeight`
- 尺寸参数：
  - `OnlyWidth`：`left_width` `center_width` `right_width`
  - `OnlyHeight`：`top_height` `center_height` `bottom_height`
  - `WidthAndHeight`：同时包含上述 6 个参数

输出：

- 覆盖写回原 `imageset`
- 可选生成同名备份：`*.imageset.bak`

## 构建（v120）

```powershell
cmd /c "call \"D:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat\" x86 && msbuild tools\SplitImageset\SplitImageset.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo"
```

产物：

- `tools\SplitImageset\Release\SplitImageset.exe`

说明：

- 项目已切换为 `SubSystem=Windows`，默认启动 GUI。
- `UseOfMfc=Static` + `RuntimeLibrary=MultiThreaded(/MT)`，可减少对开发环境运行库的依赖。

## 打包建议

最小交付目录建议包含：

- `SplitImageset.exe`
- `SplitConfig.xml`（模板）
- `README.md`
- `TECH_ANALYSIS.md`

## 关键代码位置

- GUI 与核心逻辑入口：`tools/SplitImageset/SplitImagesetGuiApp.cpp`
- 工程配置：`tools/SplitImageset/SplitImageset.vcxproj`
- 深度分析文档：`tools/SplitImageset/TECH_ANALYSIS.md`

