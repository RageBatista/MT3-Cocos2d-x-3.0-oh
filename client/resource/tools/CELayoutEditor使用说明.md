# CELayoutEditor 运行目录使用说明

生成时间: 2026-04-27

本文说明 `client\resource\tools` 目录中运行 `CELayoutEditor.exe` 的配置要求、必备依赖和常用排障入口。

## 启动方式

1. 进入运行目录:

   ```powershell
   Set-Location E:\MT3\client\resource\tools
   .\CELayoutEditor.exe
   ```

2. 也可以直接双击 `client\resource\tools\CELayoutEditor.exe`。
3. 不要把 `CELayoutEditor.exe` 单独复制到其他目录运行。当前资源路径依赖 exe 所在目录解析。

## CELayoutEditor.ini 配置结论

当前 `CELayoutEditor.ini` 基本符合运行目录要求:

- 资源路径保持相对路径，没有盘符绝对路径，也没有 UNC 路径。
- `ConfigsPath=/../res/table/` 会解析到 `E:\MT3\client\resource\res\table\`。
- `FontsPath=/../res/ui/fonts/` 会解析到 `E:\MT3\client\resource\res\ui\fonts\`。
- `ImagesetsPath=/../res/ui/imagesets/` 会解析到 `E:\MT3\client\resource\res\ui\imagesets\`。
- `LookNFeelsPath=/../res/ui/looknfeel/` 会解析到 `E:\MT3\client\resource\res\ui\looknfeel\`。
- `SchemesPath=/../res/ui/schemes/` 会解析到 `E:\MT3\client\resource\res\ui\schemes\`。
- `LayoutsPath=/../res/ui/layouts/` 会解析到 `E:\MT3\client\resource\res\ui\layouts\`。
- `ResourceRoot=/../res/ui/` 会解析到 `E:\MT3\client\resource\res\ui\`。

注意项:

- `ScriptsPath=/../res/ui/lua_scripts/` 当前解析目录不存在。现有编辑器启动和 layout 打开链路不会扫描该目录，因此不构成当前阻塞。若后续启用 CEGUI Lua script 资源，应创建对应目录或把该项改为实际脚本目录，但仍必须保持相对路径。
- `CurrentLayout` 是最近使用状态，不是资源路径主配置。打不开某个 layout 时，优先看 `CELayoutEditor.missing_resources.log`。

## 必备本地文件

`CELayoutEditor.exe` 运行目录至少需要以下文件存在:

```text
CELayoutEditor.exe
CELayoutEditor.exe.manifest
CELayoutEditor.ini
CELayoutEditor.properties.ini
CEGUIBase.dll
CEGUIExpatParser.dll
CEGUIFalagardWRBase.dll
CEGUIOpenGLRenderer.dll
CEGUISILLYImageCodec.dll
SILLY.dll
libcocos2d.dll
glew32.dll
iconv.dll
libxml2.dll
pthreadVCE2.dll
zlib1.dll
msvcp120.dll
msvcr120.dll
```

建议保留以下诊断文件，便于崩溃和资源缺失排查:

```text
CELayoutEditor.pdb
CELayoutEditor.map
CELayoutEditor.log
CELayoutEditor.missing_resources.log
CrashReports\
```

## 必备资源目录

运行目录旁边必须存在以下资源目录:

```text
client\resource\res\table\
client\resource\res\ui\fonts\
client\resource\res\ui\imagesets\
client\resource\res\ui\looknfeel\
client\resource\res\ui\schemes\
client\resource\res\ui\layouts\
```

资源数量的最低判断标准:

- `ui\schemes` 至少包含 `taharezlook.scheme` 和 `taharezlook2.scheme`。
- `ui\fonts` 需要存在 `.font` 文件。
- `ui\imagesets` 需要存在 `.imageset` 文件及其引用的贴图文件。
- `ui\looknfeel` 需要存在 `.looknfeel` 文件。
- `ui\layouts` 需要存在待编辑的 `.layout` 文件。

## 验证命令

在仓库根目录 `E:\MT3` 执行:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Sync-CELayoutEditorRuntime.ps1 -TargetDir .\client\resource\tools -ValidateOnly
```

预期输出:

```text
Runtime validation passed: E:\MT3\client\resource\tools
```

检查 ini 是否仍保持相对路径:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\CELayoutEditor\scripts\Test-CELayoutEditor-Stability.ps1 -CheckRuntime
```

预期输出最后一行:

```text
STATUS: PASS
```

## 打开 layout 时的排障顺序

1. 先看 `CELayoutEditor.log` 中最新时间段的第一条 `Error`。
2. 如果提示资源不可用或 layout 被阻止打开，打开 `CELayoutEditor.missing_resources.log`。
3. `MISSING_IMAGESET` 表示 layout 引用了未注册的 Imageset，需要补 `.imageset` 或修正 layout 引用。
4. `MISSING_IMAGE_IN_IMAGESET` 表示 `.imageset` 存在，但缺少具体 `<Image Name="...">`。
5. 字体 `Failed to load glyph` 当前记录为 `Info`，通常不是阻止 layout 打开的根因。

示例: 当前日志中 `petdepot_mtg.layout` 的阻塞原因是 `MISSING_IMAGE_IN_IMAGESET: ccui/tm`，即 `ccui.imageset` 已注册，但没有定义 `tm` 图片项。这不是 `CELayoutEditor.ini` 路径错误。

## 路径维护规则

- 运行目录配置必须继续使用相对路径，例如 `/../res/ui/layouts/`。
- 不要把 `CELayoutEditor.ini` 改成 `E:\MT3\...` 这样的绝对路径。
- 同步新版 exe 或 DLL 后，重新运行 `Sync-CELayoutEditorRuntime.ps1 -ValidateOnly`。
- 若需要同步最新构建产物，使用:

  ```powershell
  powershell -ExecutionPolicy Bypass -File .\tools\scripts\Sync-CELayoutEditorRuntime.ps1 -TargetDir .\client\resource\tools
  ```
