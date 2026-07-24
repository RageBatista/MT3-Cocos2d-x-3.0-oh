# P0-010 effect 链路联调记录

> **状态**: 历史执行记录（最终状态：根因已定位、显式开关修复与双端构建已完成，尚未留下 `Status=pass` 的复采记录）
> **执行日期**: 2026-03-06
> **当前基线**:
> - [MT3 文档中心](../../../README.md)
> - [文档索引](../../../07-参考文档/02-文档索引.md)
> - [文档维护指南](../../../10-管理文档/01-文档维护指南.md)
> **证据边界**: 本文完整合并当次模板与 Round 1/2/3。各轮原始命令中的 `docs/audit/...` 路径按执行现场保留；原始 CSV 已以文件级 Git 移动归档到本文同目录，OID 和内容不变。

## 1. 原始 CSV 与批次来源

### 1.1 effect 链路直接证据

- [p0_effect_chain_records.csv](p0_effect_chain_records.csv)：Win32/Android effect 链路采样记录。

### 1.2 同批次 P0 状态与启动采样

- [p0_boot_capture_records.csv](p0_boot_capture_records.csv)
- [p0_visual_quality_progress_2026-03-05.csv](p0_visual_quality_progress_2026-03-05.csv)
- [p0_visual_quality_progress_2026-03-06.csv](p0_visual_quality_progress_2026-03-06.csv)
- [p0_visual_quality_tasks_jira.csv](p0_visual_quality_tasks_jira.csv)

### 1.3 合并源指纹

| 阶段 | 原始文件 | 原始 SHA256 |
| --- | --- | --- |
| 判定模板 | `D4_P0-010_effect_chain_alignment_template.md` | `200032F2DA4D4AF640852CE0375559DDEFECDB5AD1CE644F3179A74057F216C2` |
| Round 1 | `D4_P0-010_effect_chain_round1.md` | `043D9F98678E8703F57B9885661A38CEF7A20E27C69895F3E2F5642C9200EE86` |
| Round 2 | `D4_P0-010_effect_chain_round2.md` | `9BC4685CC617F52F30041FAD39FDBC86DC34ACD887EEFF0C2FBC5A1C0B0AE340` |
| Round 3 | `D4_P0-010_effect_chain_round3.md` | `05E7E07121B2BF03A09BAEFAFF847A5896FE0CD333AA9169678AC7E29C587139` |

## 2. 判定口径（2026-03-06 模板）

### 1. 任务范围

1. 基于 `[P0][EFFECT]` 日志验证 `SelectRenderEffect -> SetShaderParam -> DrawPicture read` 链路。
2. 本轮平台范围：Win32 + Android（iOS 采样已按执行决策延期）。
3. 输出统一记录到 `docs/audit/p0_execution/p0_effect_chain_records.csv`。

### 2. 执行命令

#### 2.1 Win32

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Win32.ps1 `
  -LogPath "client/resource/bin/Release/mt3_ct.log" `
  -OutputCsv "docs/audit/p0_execution/p0_effect_chain_records.csv"
```

#### 2.2 Android

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Android.ps1 `
  -OutputCsv "docs/audit/p0_execution/p0_effect_chain_records.csv" `
  -WaitSeconds 8
```

### 3. 判定标准

1. `Status=pass`：`SetParamEffect == DrawEffect` 且 `SetParamPtr == DrawParamPtr`。
2. `SelectRenderEffect` 日志允许缺失（该日志存在去重策略）；缺失时 `Reason=select_not_found_optional`。
3. `Status=mismatch`：effect 或 param 指针不一致，需提交联调缺陷。
4. `Status=no_match/blocked`：`Set/Draw` 日志缺失或采样环境问题，需先解除阻塞。

### 4. 联调回填项

1. 记录本次采样时间、构建包版本、设备信息。
2. 对 `mismatch` 条目附带原始日志片段和复现步骤。
3. 将结论同步到 `plans/P0-画质优化-可执行任务清单-2026-03-05.md` 的 13.2/13.4 节。

## 3. Round 1（2026-03-06 02:39）

### 1. 执行信息

| 字段 | 内容 |
|------|------|
| 任务ID | P0-010 |
| 执行时间 | 2026-03-06 02:39 |
| 执行平台 | Win32 + Android |
| 数据文件 | `docs/audit/p0_execution/p0_effect_chain_records.csv` |

### 2. 执行命令

1. `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Win32.ps1 -OutputCsv "docs/audit/p0_execution/p0_effect_chain_records.csv"`
2. `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Android.ps1 -OutputCsv "docs/audit/p0_execution/p0_effect_chain_records.csv" -WaitSeconds 8`

### 3. 首轮结果

| 平台 | 状态 | 结论 |
|------|------|------|
| Win32 | `no_match` | 未采到 `Select/Set/Draw` 三类 `[P0][EFFECT]` 日志 |
| Android | `no_match` | 未采到 `Select/Set/Draw` 三类 `[P0][EFFECT]` 日志 |

`Reason`：`select_not_found|set_not_found|draw_not_found`

### 4. 分析与下一步

1. 本轮采样仅证明脚本链路可执行，尚未进入可触发夜景 effect 的有效场景。
2. 下一轮需先进入夜景/地下宫殿场景并触发 `World::SetNightEffect`，再重新采样。
3. 采样目标：至少得到 1 组 `SetParamEffect == DrawEffect` 且 `SetParamPtr == DrawParamPtr` 的 `pass` 记录。

## 4. Round 2（2026-03-06 11:10 / 11:13）

> **采集逻辑变化**: 本轮修正 Win32 默认日志源、指针正则、`Select` 可选判定和 CSV 追加空行问题；以下保留完整命令、结果与下一步。

### 1. 本轮变更

1. 修正 Win32 默认采样源为 `client/resource/bin/Release/mt3_ct.log`。
2. 放宽指针正则，兼容 `0x...`、纯十六进制、`(nil)`。
3. 调整判定规则：`Set/Draw` 必选，`Select` 可选（日志去重场景）。
4. 修正 CSV 追加策略，移除空行问题。

### 2. 执行命令

1. `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Win32.ps1 -OutputCsv "docs/audit/p0_execution/p0_effect_chain_records.csv"`
2. `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Android.ps1 -OutputCsv "docs/audit/p0_execution/p0_effect_chain_records.csv" -WaitSeconds 8`

### 3. 结果（11:10 与 11:13 两次采样）

| 平台 | 状态 | Reason |
|------|------|------|
| Win32 | `no_match` | `set_not_found|draw_not_found` |
| Android | `no_match` | `set_not_found|draw_not_found` |

结论：脚本规则已修正并可稳定产出，但当前运行会话仍未触发夜景 effect 链路（未采到 `SetShaderParam/DrawPicture read`）。

### 4. 下一步（联调动作）

1. 按 D1 场景复现单进入夜景或地下宫殿地图后立即复采。
2. 复采目标：至少出现 1 条 `Status=pass`（`SetParamEffect == DrawEffect` 且 `SetParamPtr == DrawParamPtr`）。

## 5. Round 3（2026-03-06 11:47，修复产物截至 12:13:48）

### 1. 前置条件

1. Win32 客户端与 Android APK 已手动启动。
2. 已进入夜景/地下宫殿场景后立即执行采样。

### 2. 执行命令

1. `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Win32.ps1`
2. `powershell -ExecutionPolicy Bypass -File .\tools\scripts\Collect-P0EffectChain-Android.ps1 -WaitSeconds 5`

### 3. 本次结果（2026-03-06 11:47）

| 平台 | 状态 | Reason |
|------|------|------|
| Win32 | `no_match` | `set_not_found|draw_not_found` |
| Android | `no_match` | `set_not_found|draw_not_found` |

对应记录已写入：`docs/audit/p0_execution/p0_effect_chain_records.csv`
- `2026-03-06 11:47:00` Win32
- `2026-03-06 11:47:06` Android

### 4. 结论与下一步

1. 在确认进入目标场景后，双端仍未采到 `[P0][EFFECT]` 的 `SetShaderParam/DrawPicture` 对应链路。
2. 下一步应转入代码链路定位：优先核查夜景 shader 开关是否被显式开启，再复跑 `P0-010` 采样拿 `pass`。

### 5. 开关链路定位结果（2026-03-06）

1. `engine/engine/nuconfigmanager.cpp:31` 默认值为 `m_bRenderNightEffectByShader = false`。
2. `engine/world/nuworld.cpp:2436` 与 `engine/world/nuworld.cpp:3085` 都以 `IsRenderNightEffectByShader()` 作为夜景 shader 分支前置条件。
3. 全仓检索（排除文档和生成代码）未发现任何真实业务调用 `SetRenderNightEffectByShader(true)` 或 `SetRenderNightEffectWithRenderTarget(...)`。
4. 结论：当前运行链路下夜景 shader 开关未被开启，`P0-010` 持续 `no_match` 的根因已定位。

### 6. 开关修复落地（2026-03-06）

1. 已在 `client/FireClient/Application/Framework/GameApplication.cpp` 的 `OnInit step3` 增加显式赋值：
   - `SetRenderNightEffectByShader(true)`
   - `SetRenderNightEffectWithRenderTarget(false)`
2. 已增加回读日志 `[P0][NIGHT] RenderNightEffectByShader=...`，用于联调确认；原有 `[P0][BOOT]` 格式未改动。
3. 已完成双端重编译产物：
   - Win32：`client/resource/bin/Release/MT3.exe`（2026-03-06 12:05:37）
   - Android：`client/android/LocojoyProject/bin/mt3_locojoy_release.apk`（2026-03-06 12:13:48）
4. 当前状态：代码与构建已就绪，待进入夜景/地下宫殿后复跑 `P0-010` 采样拿 `pass`。

## 6. 最终结论

1. Round 1 只证明采集脚本可执行，双端均为 `no_match`，当时判断尚未进入能触发夜景 effect 的有效场景。
2. Round 2 完成四项采集逻辑修正后，11:10 与 11:13 两次采样仍为 `no_match`，说明问题不再是 CSV 追加或指针解析规则。
3. Round 3 在确认进入目标场景后仍为 `no_match`；代码定位确认 `m_bRenderNightEffectByShader` 默认 `false`，且当时业务链没有显式开启调用，这是持续未命中的根因。
4. 2026-03-06 已在 `GameApplication.cpp` 显式设置 `SetRenderNightEffectByShader(true)`、`SetRenderNightEffectWithRenderTarget(false)`，并完成 Win32 与 Android 重编产物。
5. 最终历史状态是“根因定位 + 修复落地 + 双端构建完成，等待目标场景复采”；原记录没有 `Status=pass`，不得把本次合并表述为联调最终通过。
