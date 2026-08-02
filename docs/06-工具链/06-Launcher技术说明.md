# Launcher 技术说明

> **定位**：说明 `client/Launcher/` 的模块、数据流和边界；构建命令只见 [05-Launcher编译构建](05-Launcher编译构建.md)。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 组件定位

Launcher 是独立的 Win32 登录前/更新容器，不是 `FireClient/Application` 的平台壳层。它的网络主链是 HTTP/JSON 和文件下载；游戏进程启动后才进入 `NetConnection` + FireNet + ProtoDef 的 TCP 协议链。

```text
Launcher.exe
├─ Launcher.cpp / LauncherUI.h        程序入口与 DUI 主窗口
├─ UpdateEngine.*                    版本与更新计算
├─ UpdateManagerEx.*                更新任务编排
├─ DownloadManager.h / DownloadOne.h 下载调度与单文件任务
├─ HttpClient/* / JsonUtil.*          HTTP 与 JSON
├─ LJFM/* / LJFP/*                   文件、包和版本数据结构
├─ UIControl/* / WebBrowser/*        DUI 控件与 WebBrowser 容器
└─ CrashDump.*                       Win32 崩溃转储
```

## 2. 启动主线

1. `Launcher.cpp` 进入 Windows 应用。
2. 初始化崩溃处理和 DUI 窗口。
3. 加载 Launcher 数据与本地版本状态。
4. `UpdateManagerEx` / `UpdateEngine` 构造检查和更新任务。
5. HTTP/JSON 获取远端信息，下载器落地必要文件。
6. 校验、替换并刷新 UI 进度/状态。
7. 条件满足后启动游戏客户端进程。

具体分支、URL、包格式和失败处理必须以当前 `client/Launcher/Code/` 源码取证，不使用历史文档中的地址示例作为现行配置。

## 3. 模块边界

### 3.1 UI 层

- `LauncherUI.h` 组装主窗口和可见状态。
- `UIControl/` 提供图片、文本、链接、进度条、按钮和窗口管理。
- `WebBrowser/` 是 Win32/OLE 浏览器容器，不是游戏 CEGUI WebView。

### 3.2 更新层

- `UpdateEngine` 聚合版本、文件与包数据，计算更新动作。
- `UpdateManagerEx` 组织外部请求、下载和状态切换。
- `UpdateBin.h`、`UpdateJson.h` 等文件是更新数据结构与辅助逻辑，修改时需与服务端/产物格式同步核对。

### 3.3 网络与下载

- `HttpClient/` 负责 GET/POST 和通用 HTTP 处理。
- `JsonUtil.*` 负责 Launcher 业务 JSON。
- `DownloadManager` / `DownloadOne` 负责下载队列与单任务生命周期。
- 这套 HTTP/JSON 数据不使用 `client/FireClient/Application/ProtoDef/`。

### 3.4 文件与包

`LJFM/`、`LJFP/` 封装版本、节点、压缩、校验、加密和文件工具。该层的格式变更会影响已发布产物，需要样本回归和回滚证据。

## 4. 关键状态与日志

排障时至少记录：

- 本地版本、远端版本和选中的更新路径。
- HTTP 状态、下载文件名、期望长度/校验值和临时文件状态。
- 替换前后的产物路径与时间戳。
- Launcher 启动游戏进程前的最后状态和返回码。
- CrashDump 产物路径和对应 EXE/PDB 哈希。

日志中不记录 token、cookie、用户隐私或完整鉴权参数。

## 5. 变更验证

| 改动类型 | 最小验证 |
| --- | --- |
| DUI / 控件 | 启动、重绘、点击、进度刷新和关闭路径。 |
| HTTP/JSON | 正常响应、超时、非 2xx、缺字段和无效 JSON。 |
| 下载/替换 | 断点/重试、磁盘失败、校验失败、原子替换和回滚副本。 |
| LJFP/LJFM 格式 | 历史样本读取、当前样本往返、端到端更新。 |
| CrashDump | 转储生成、EXE/PDB 匹配和敏感信息处理。 |

## 6. 与游戏客户端的分工

| 能力 | Launcher | 游戏客户端 |
| --- | --- | --- |
| UI | Win32 DUI/OLE | Launcher 自身 DUI/OLE；游戏主界面由 CEGUI 0.7.9-r5 + Lua + FireClient 提供 |
| 更新前网络 | HTTP/JSON | 非主责 |
| 游戏协议 | 非主责 | `NetConnection` + FireNet + ProtoDef |
| 平台 | Win32 | Win32 / Android / iOS |
| 启动入口 | `client/Launcher/Code/Launcher.cpp` | 平台壳层 -> `gRunGameApplication()` |
