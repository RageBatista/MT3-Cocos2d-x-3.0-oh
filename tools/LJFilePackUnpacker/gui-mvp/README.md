# LJFilePackUnpacker MVP GUI

## 定位

这是 `tools/LJFilePackUnpacker` 的桌面壳层，不负责真正的解包算法实现。

它的职责只有三件事：

1. 收集输入目录、输出目录、索引和映射文件。
2. 在需要时收集 Android `libgame.so` 路径，用于自动提取解密 key。
3. 解析并展示 CLI 的日志与进度。
4. 在 legacy CLI 和诊断 CLI 之间做最小兼容适配。

## 支持的后端

GUI 会按如下顺序自动寻找可执行文件：

1. 同目录 `ljfp-unpack.exe`
2. 同目录 `ljfp-unpack-diag.exe`
3. `dependencies/SuperLJFilePackUnpack/build/bin/Release/ljfp-unpack.exe`（仅当本机保留了本地构建输出时）
4. `dependencies/SuperLJFilePackUnpack/build/bin/Release/ljfp-unpack-diag.exe`（仅当本机保留了本地构建输出时）
5. `dependencies/SuperLJFilePackUnpack/out/mvp_cli_manual/ljfp-unpack.exe`

协议差异：

- `ljfp-unpack.exe`
  - 支持完整参数协议。
  - GUI 的 CRC、覆盖、类型检测、索引覆盖、解密模式、解密 Key 和 `Android SO` 提示路径都会生效。
- `ljfp-unpack-diag.exe`
  - 作为诊断兼容后端使用。
  - GUI 会自动提示哪些选项被忽略。
  - 自定义索引文件路径只在索引文件仍位于输入目录、且文件名为 `fl.ljpi/fl.ljzip` 时兼容。
  - `Android SO` 路径仍会透传，用于自动提取解密 key。

## Android SO 自动取 key

- 当未手填“解密 Key”时，可以在 GUI 中指定 `Android SO` 为 `libgame.so` 文件，或其上级 APK 解包目录。
- CLI 会优先尝试从该 `libgame.so` 中提取资源解密 key，再回填给索引加载和资源解包流程。
- 若未指定 `Android SO`，核心库也会继续尝试从输入目录附近的 Android 包目录结构中自动发现 `lib/armeabi-v7a/libgame.so` 等常见位置。

## 构建

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\LJFilePackUnpacker\scripts\Build-MVP-OneClickUnpacker.ps1
```

如需单文件自包含发布：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\LJFilePackUnpacker\scripts\Build-MVP-OneClickUnpacker.ps1 -SelfContained
```

## 运行

```bat
tools\LJFilePackUnpacker\scripts\Run-MVP-OneClickUnpacker.bat
```

产物目录：

`tools\LJFilePackUnpacker\dist\mvp\`

> 说明：仓库清理后，本机的 `dependencies/SuperLJFilePackUnpack/build/` 可能不存在；正常使用应优先依赖 `dist\mvp\ljfp-unpack.exe`。
