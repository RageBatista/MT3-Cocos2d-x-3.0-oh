# D3 收口报告 - P0-007 StateManager 特效状态持久化

> **状态**: 历史快照
> **适用日期**: 2026-03-06 P0 执行批次
> **当前基线**:
> - [MT3 文档中心](../../../README.md)
> - [13-文档索引](../../../07-参考文档/02-文档索引.md)
> - [文档维护指南](../../../10-管理文档/01-文档维护指南.md)
> **说明**: 本文为 P0-007 收口记录，保留当次执行结论，不直接替代当前问题治理总基线。


## 1. 任务信息

| 字段 | 内容 |
|------|------|
| 任务ID | P0-007 |
| 责任角色 | RD-Renderer |
| 执行日期 | 2026-03-06 |
| 状态 | 已完成 |

## 2. 改动目标

1. 让 `StateManager::SelEffect/SetShaderParam` 具备真实状态持久化能力。
2. 让 `DrawPicture` 可读取当前全局 effect 与参数快照（不提前改渲染生效逻辑）。
3. 保持当前渲染行为稳定，`P0-009` 再接入 effect 消费分支。

## 3. 代码改动点

### 3.1 StateManager 持久化能力

文件：`engine/renderer/nustatemanager.h`、`engine/renderer/nustatemanager.cpp`

1. 新增 `ShaderParamSnapshot` 快照结构与缓存数组，按 effect 保存参数拷贝。
2. `SelEffect` 从空实现改为真实记录 `m_curEffect/m_eRenderEffect`。
3. `SetShaderParam` 从空实现改为：
   - 记录 `m_curParamEffect`
   - 保存参数源指针
   - 对 `XPRE_COLORBALANCE/XPRE_COLORBALANCE_2` 等可识别类型做内存快照
4. 新增读取接口：
   - `GetShaderParam(XPRENDER_EFFECT xpre) const`
   - `GetShaderParamSize(XPRENDER_EFFECT xpre) const`
5. `OnRestore` 增加状态重置与快照清理，确保恢复路径一致。

### 3.2 Renderer 桥接读取

文件：`engine/renderer/nucocos2d_render.cpp`

1. `SelectRenderEffect` 改为调用 `m_stateMan.SelEffect(xpre)`，打通状态写入链路。
2. `DrawPicture` 新增桥接读取：
   - 在 `param.iShaderType == 0` 路径读取 `m_stateMan.GetRenderEffect()/GetShaderParam()`
   - 增加 `[P0][EFFECT] DrawPicture read effect=%d param=%p` 低频日志用于联调确认
3. 明确注释：本阶段只建立“可读状态桥接”，不改变 shader 生效逻辑。

## 4. 关键定位

1. `engine/renderer/nustatemanager.cpp:63` (`SelEffect`)
2. `engine/renderer/nustatemanager.cpp:75` (`SetShaderParam`)
3. `engine/renderer/nustatemanager.cpp:106` (`GetShaderParam`)
4. `engine/renderer/nucocos2d_render.cpp:1803` (`SelectRenderEffect`)
5. `engine/renderer/nucocos2d_render.cpp:1522` (`DrawPicture` 读取桥接)

## 5. 验证结果

### 5.1 编译验证（Android）

执行命令：
1. `powershell -ExecutionPolicy Bypass -File tools/scripts/Build-Android-Locojoy-WithGate.ps1 -ProjectDir client/android/LocojoyProject -Target release -Jobs 4`

结果：
1. 构建成功，退出码 `0`。
2. `engine_static` 中 `nustatemanager.cpp`、`nucocos2d_render.cpp` 编译通过。
3. 存在历史告警（NDK/三方库），无本次新增阻断错误。

### 5.2 运行验证（MuMu）

执行步骤：
1. 覆盖安装 `mt3_locojoy_release.apk`。
2. 启动后抓取 `adb logcat`。

结果：
1. `[P0][BOOT]` 启动日志持续可见（参数链路未回退）。
2. `[P0][EFFECT]` 读取桥接日志需在夜景 effect 实际触发场景验证，纳入 `P0-009/P0-010` 联调清单。

## 6. 结论

`P0-007` 已完成：状态写入和读取桥接均已落地并通过构建验证，后续按计划进入 `P0-009`（`DrawPicture` 消费全局 effect）实施。
