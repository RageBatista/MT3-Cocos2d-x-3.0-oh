# Windows客户端功能规格书（基线版）

> 文档版本：2.2.1  
> 最后更新：2026-07-26
> 历史基线：`docs/09-历史归档/专项审计/2026-03-04-客户端三端代码基线审计.md`
> 数据来源：`client/` 实际代码与工程文件（仅保留可直接核验事实）

---

## 1. 范围

本规格书覆盖 Windows 客户端启动、构建与平台特有实现，不再使用“功能数量统计”类推断字段。

核心路径：
- `client/MT3Win32App/`
- `client/Launcher/`
- `client/FireClient/Application/platform/win/`

---

## 2. 启动链路（代码实测口径）

1. 进程入口：`client/MT3Win32App/main.cpp:47` `_tWinMain`
2. 启动器热替换：`main.cpp:56` 调用 `ReplaceLauncher()`
3. 多开信号量：`main.cpp:90` `CreateSemaphore(...)`
4. 分辨率文件读取：`main.cpp:120` `frameSize.txt`
5. 客户端配置读取：`main.cpp:152` `clientsetting_win.ini`
6. 崩溃转储初始化：`main.cpp:174` `CrashDump_Init(...)`
7. 游戏主循环：`main.cpp:175` `gRunGameApplication()`

---

## 3. 工程与构建参数

### 3.1 关键工程文件

- `client/MT3Win32App/mt3.win32.vcxproj`
- `client/MT3Win32App/mt3.vcxproj`
- `client/MT3Win32App/FireClient.win32.vcxproj`
- `client/Launcher/Launcher.sln`
- `client/Launcher/Launcher.vcxproj`
- `client/FireClient/FireClient.sln`

### 3.2 已确认构建参数

- 工具集：`v120`（`mt3.win32.vcxproj:24`）
- 配置组合：`Debug|Win32`、`Release|Win32`
- 输出目录：`$(SolutionDir)$(Configuration).win32\`（`mt3.win32.vcxproj:43,46`）
- 中间目录：`$(ProjectName).$(Configuration).win32\`（`mt3.win32.vcxproj:44,47`，与 `FireClient.win32.vcxproj` 共享 `OutDir` 但 `IntDir` 各自独立）

---

## 4. 平台特有实现

- 录音实现路径：`client/FireClient/Application/platform/win/`
  - `WavRecorder.cpp`
  - `SoundCapturer/SoundCapturer.cpp`
  - `SoundCapturer/WaveFile.cpp`
- 启动器工程独立存在：`client/Launcher/`
- 资源目录独立存在：`client/res_win/`（含 PFS 打包资源，文件数随发布批次变化）

---

## 5. 与共享层边界

- Windows 入口层仅负责启动/窗口/实例控制/CrashDump。
- 业务主循环统一进入 `gRunGameApplication()`，共享核心在：
  - `client/FireClient/Application/`
  - `client/resource/res/script/`

---

## 6. 快速复核命令

```powershell
Select-String -Path client/MT3Win32App/main.cpp -Pattern '_tWinMain|CreateSemaphore|CrashDump_Init|gRunGameApplication'
Select-String -Path client/MT3Win32App/mt3.win32.vcxproj -Pattern 'PlatformToolset|OutDir|IntDir'
Get-ChildItem client/FireClient/Application/platform/win -Recurse -File
```

---

## 7. 维护规则

- 本文件仅记录“代码已存在并可定位”的事实。
- 后续若入口、工程文件或构建参数变更，必须同步更新本规格书与基线审计报告日期。

---

## 8. Win32 关闭退出链路（2026-03-04 修订）

### 8.1 标准关闭路径

1. 退出确认（UI）触发 `WM_CLOSE` 到主窗口。  
2. `CCEGLView` 处理 `WM_CLOSE` 时直接销毁窗口（`DestroyWindow`）。  
3. 进入 `WM_DESTROY`，调用 `PostQuitMessage(0)`。  
4. `CCApplication::run()` 消息循环收到 `WM_QUIT` 后退出。  
5. 引擎 `Exit()` 回调应用 `OnExit()`，完成业务、UI、网络模块收尾。

### 8.2 关键实现落点

- `client/FireClient/Application/Manager/MessageManager.cpp`  
  `HandleExitGameConfirmed`（Win32）：`PostMessage(hwnd, WM_CLOSE, ...)`

- `cocos2d-x-2.2.6/cocos2dx/platform/win32/CCEGLView.cpp`
  `WindowProc` 的 `WM_CLOSE`：`DestroyWindow(m_hWnd)`

- `client/FireClient/Application/Framework/GameApplication.cpp`  
  `OnExit`：`ExitGame(...)` 在前、`CleanupNetModule()` 在后；  
  `CleanupNetModule`：先 `FireNet::GetNetIO()->CloseAll()` 再 `GetNetSystem()->Cleanup()`

### 8.3 目标问题与修复结果

- 目标问题：关闭客户端后 `MT3.exe` 残留后台进程。  
- 修复方向：去除“仅依赖下一帧清理”的退出路径，改为稳定触发 `WM_QUIT`；同时强化网络会话清理顺序。

### 8.4 禁改规则

- 不要将 Win32 `WM_CLOSE` 改回仅 `CCDirector::end()`。
- 不要将网络模块清理提前到 `ExitGame` 之前。
- 退出链路改动必须附带“任务管理器无残留进程”手工验证记录。

---

## 9. 时装切换后角色不可见问题（2026-03-05 修订）

### 9.1 现象

- 外观衣橱切换到时装模型（如 `3000001`、`3001001`）时，角色/武器/坐骑可能整体不显示。  
- 切回角色基础模型（如 `3010001`）显示恢复正常。  

### 9.2 证据链（可复核）

1. 运行日志显示 Lua 侧切模和武器下发正常：  
   - `client/resource/bin/Debug/mt3_ct.log:786` `EquipDialog.InitSpriteModel rawShape=3000001 validShape=3000001`  
   - `client/resource/bin/Debug/mt3_ct.log:965` `CharacterShiZhuangDlg.getPreviewWeaponId model=3001001 ... final=9250101`
2. 配置映射确认时装模型来源：  
   - `client/resource/res/table/xmltable/npc.CNpcShape.xml:893` `id="3000001" shape="fashion-jianxiake1"`  
   - `client/resource/res/table/xmltable/npc.CNpcShape.xml:904` `id="3001001" shape="fashion-jianxiake2"`  
   - `client/resource/res/table/xmltable/npc.CNpcShape.xml:2763` `id="3010001" shape="role-jianxiake"`
3. 资源盘点确认结构缺口：  
   - `fashion-*` 模型目录均不存在 `weapon/weapon.lmx`（本次盘点：`102/102` 缺失）。  
   - 但 `layerdef.lmx` 仍声明 `weapon` 层（`id="2"`），触发加载路径。

### 9.3 根因

- `engine/sprite/nuspritemanager.cpp` 中 `SpriteManager::XModel::LoadBase()` 对各 layer 的 `*.lmx` 采用“缺失即失败”策略。  
- 时装模型 `fashion-*` 的 `weapon` 层是“结构声明存在、资源文件不存在”的历史资源形态；因此加载 `weapon/weapon.lmx` 失败会直接 `return false`，导致整模型加载失败，而不是仅武器层失败。  

### 9.4 修复方案

- 在 `LoadBase()` 中将 `fashion-*` 模型的 `weapon` 层改为“可选层”：  
  - 路径缺失或解析失败时 `continue` 跳过该层；  
  - 其他层保持原有严格校验。  
- 修复落点：`engine/sprite/nuspritemanager.cpp`（`LoadBase` 层级加载分支）。  
- 保持既有策略：时装武器动画仍优先回退到 `role-*` 武器资源路径，确保“时装仅换外观，武器沿用角色当前装备”。

### 9.5 防回归检查项

发布前必须执行：

```powershell
# 1) 检查时装模型是否普遍缺 weapon.lmx（历史资源特征）
$root='client/resource/res/model'
$fashion=Get-ChildItem $root -Directory | ? { $_.Name -like 'fashion-*' }
$missing=@()
foreach($d in $fashion){
  if(-not (Test-Path (Join-Path $d.FullName 'weapon/weapon.lmx'))){ $missing += $d.Name }
}
"fashion_total=$($fashion.Count) missing_weapon_lmx=$($missing.Count)"

# 2) 验证运行日志中时装模型与武器组件下发正常
rg -n "EquipDialog.InitSpriteModel rawShape=3000001|CharacterShiZhuangDlg.getPreviewWeaponId model=3001001|final=9250101" client/resource/bin/Debug/mt3_ct.log
```

手工验收口径：

- 外观衣橱切换 `fashion-jianxiake1/2` 不再出现整模消失；  
- 主场景、背包、外观界面均能稳定显示；  
- 切回基础模型显示无回归。  

### 9.6 证据归档模板（必留）

每次发布前后至少保留以下证据（便于回溯）：

1. `mt3_ct.log` 三条关键日志：  
   - `EquipDialog.InitSpriteModel rawShape=3000001`  
   - `CharacterShiZhuangDlg.getPreviewWeaponId model=3001001`  
   - `final=9250101`（或本次测试角色的实际装备武器 id）
2. 时装资源统计命令输出：  
   - `fashion_total=... missing_weapon_lmx=...`
3. 三张截图：  
   - 主场景切时装后可见人物+武器+坐骑  
   - 外观衣橱中时装预览可见武器  
   - 背包/角色面板可见武器

### 9.7 Release 专项：`LoadFromPak` 资源映射缺口防护（2026-03-05）

现象特征：

- Debug 版本切时装正常，Release 版本切时装整模不显示。  
- Lua 日志显示模型 ID/武器 ID 下发正常，但渲染层资源实际缺失。  

根因：

- Windows 发布态默认 `LoadFromPak=true`，资源从 `res1/fl.ljpi` 映射读取。  
- 当 `fl.ljpi` 映射与实际资源不同步时，`model/fashion-*` 资源可能在包映射中缺失，导致 `GetFileInfo` 直接 miss。  

修复（当前实现，2026-07-26 按源码复核）：

- 文件：`common/ljfm/code/source/ljfmopen.cpp`  
- 策略（现行）：  
  - 发布态**优先使用打包资源索引**；早期“对 `model/fashion-*` 强制优先散文件”的策略已关停——`IsLooseResPreferredCandidate()`（第 142-147 行）恒返回 `false`，源码注释明确“发布态要求优先使用打包资源索引，不再做强制优先 loose res”。  
  - 对 `model/*` 前缀资源（通用前缀判定，非 fashion 专属，见 `IsLooseResFallbackCandidate()` 第 136-140 行）保留“pack 映射 miss 时回退散文件”兜底。  
- 告警日志现状：  
  - `WARN: LJFMOpen fallback to loose res for model/...` —— 回退发生时会实际输出（第 283-286 行）；  
  - `WARN: LJFMOpen prefer loose res for ...` —— 代码保留（第 298-301 行）但因 prefer 分支已关停，当前不会触发。

发布前检查（新增）：

```powershell
# Release 手工测试后，检查是否出现过模型回退告警
# （“prefer loose res”分支已关停，正常只可能出现 fallback 告警）
rg -n "fallback to loose res for model/" client/resource/bin/Release/mt3_ct.log
```

说明：

- 若存在该告警，表示包映射存在缺口，客户端已自动自愈；  
- 仍需在资源发布链路补齐 `fl.ljpi`，避免长期依赖回退路径。
