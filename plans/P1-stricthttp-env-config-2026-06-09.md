# P1 StrictHttp 环境配置化任务单（2026-06-09）

> 来源：`build_logs/security-gate-strict-final.json`
> 当前结论：普通安全门禁 PASS；发布严格模式 `-StrictHttp` FAIL。

## 1. 当前阻断摘要

- status: FAIL
- strict_http: True
- scanned_files: 1967
- blockers: 85
- warnings: 10

## 2. 阻断分布

| 范围 | 数量 | 处理建议 |
| --- | ---: | --- |
| `client\resource` | 36 | Lua 配置源收敛，优先抽配置表/平台参数，删除示例内网 URL 或改为注释白名单 |
| `client\FireClient` | 31 | 客户端 C++ 配置源收敛，优先迁移到 XML/渠道配置/运行环境读取 |
| `common\updateengine` | 12 | 热更新/CDN 根地址改由发布参数或版本索引注入 |
| `common\platform` | 3 | 平台公共示例 URL 与更新示例拆分白名单或配置化 |
| `common\cauthc` | 2 | 逐文件确认是否运行时 URL、示例文档或第三方版权链接 |
| `tools\scripts` | 1 | 逐文件确认是否运行时 URL、示例文档或第三方版权链接 |

## 3. Top 文件清单

| 文件 | 阻断数 | 优先级 |
| --- | ---: | --- |
| `client\FireClient\Application\Framework\GameApplication.cpp` | 11 | P1-第一批 |
| `client\resource\res\script\logic\space\spaceprotocol.lua` | 5 | P1-第一批 |
| `client\FireClient\Application\Framework\ConnectGetServerInfo.h` | 4 | P1-第一批 |
| `client\FireClient\Application\Framework\WinWebBrowser\WinSDK.cpp` | 4 | P1-第一批 |
| `client\resource\res\script\logic\share\sharedlg.lua` | 4 | P1-第一批 |
| `client\FireClient\Application\Framework\ConnectGetServerInfo.cpp` | 3 | P1-第二批 |
| `client\resource\res\script\logic\space\spacepro\spaceprotocol_liuyan.lua` | 3 | P1-第二批 |
| `common\updateengine\UpdateManagerEx.cpp` | 3 | P1-第二批 |
| `common\updateengine\ios\ZipArchive\minizip\unzip.h` | 3 | P1-第二批 |
| `common\updateengine\ios\ZipArchive\minizip\zip.h` | 3 | P1-第二批 |
| `client\resource\res\script\logic\logo\logoinfodlg.lua` | 2 | P1-第二批 |
| `client\resource\res\script\logic\space\spacepro\spaceprotocol_receiveGiftList.lua` | 2 | P1-第二批 |
| `client\resource\res\script\logic\space\spacepro\spaceprotocol_selfFriendAround.lua` | 2 | P1-第二批 |
| `client\resource\res\script\logic\space\spacepro\spaceprotocol_selfSayState.lua` | 2 | P1-第二批 |
| `client\resource\res\script\logic\space\spacepro\spaceprotocol_sendState.lua` | 2 | P1-第二批 |
| `common\platform\utils\UpdateUtil.h` | 2 | P1-第二批 |
| `client\FireClient\Application\client.xml` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\lua_client.xml` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\pkg_client.xml` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\GameUI\CEGUIIMEDelegate.h` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\Manager\BattleReplayManager.cpp` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\Manager\GameUIManager.cpp` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\Manager\VoiceManager.cpp` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\protocols\pb.xml` | 1 | P2-第三批/白名单候选 |
| `client\FireClient\Application\Utils\OpenUDID.h` | 1 | P2-第三批/白名单候选 |

## 4. 执行原则

- 不直接删除业务仍需使用的 URL；先确认配置源与渠道/发布参数。
- 运行时 HTTP/private/test URL 必须迁移为环境配置、渠道配置或发布索引参数。
- 第三方版权/协议说明类 URL、纯注释示例 URL 应建立明确白名单或调整扫描规则，避免污染 StrictHttp。
- 修复后必须复跑：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Test-MT3-SecurityGate.ps1 -StrictHttp -ReportPath build_logs\security-gate-strict.json
```

## 5. 建议批次

1. 第一批：`GameApplication.cpp`、`WinSDK.cpp`、`UpdateManagerEx.cpp`、`sharedlg.lua`、`spaceprotocol.lua`。
2. 第二批：`ConnectGetServerInfo.*`、`spacepro/*.lua`、`UpdateUtil.h`。
3. 第三批：第三方 minizip/cocos 版权链接、示例测试文件，按白名单或扫描规则处理。
