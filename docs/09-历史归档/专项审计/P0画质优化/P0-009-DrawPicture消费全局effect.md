# D4 执行单 - P0-009 DrawPicture 消费全局 effect

> **状态**: 历史快照
> **适用日期**: 2026-03-06 P0 执行批次
> **当前基线**:
> - [MT3 文档中心](../../../README.md)
> - [13-文档索引](../../../07-参考文档/02-文档索引.md)
> - [文档维护指南](../../../10-管理文档/01-文档维护指南.md)
> **说明**: 本文为 P0-009 执行单，保留当次 DrawPicture/effect 联调证据，不直接替代当前渲染链验证总流程。


## 1. 基本信息

| 字段 | 内容 |
|------|------|
| 任务ID | P0-009 |
| 日期 | 2026-03-06 |
| 责任角色 | RD-Renderer |
| 协作角色 | INT, QA-Func |
| 当前状态 | 开发完成，待联调/QA验证 |

## 2. 本次落地范围

1. 在 `DrawPicture(const DrawPictureParam&)` 中读取 `StateManager` 当前 effect/param，并建立可消费开关。
2. 仅在 `param.iShaderType == 0` 时启用全局 effect 分支，保持 HSV/灰度路径优先级不变。
3. 在默认贴图路径接入 `kCCShader_PositionTextureColorX / kCCShader_PositionTextureColorXEtc`。
4. 维持 `[P0][EFFECT]` 现有日志格式，不改 `[P0][BOOT]`。

## 3. 代码变更点

1. 文件：`engine/renderer/nucocos2d_render.cpp`
2. 关键改动：
   - 新增全局 effect 可消费变量：`currentEffect/currentEffectParam/bEnableGlobalColorBalance`
   - `iShaderType==0` 且 effect 为 `XPRE_COLORBALANCE/XPRE_COLORBALANCE_2` 时，进入 X shader 分支
   - X shader 分支设置 `u_tss_color_op=0`（MODULATE，占位模式）
   - `popShader` 条件补齐：默认路径在“ETC 或全局 effect shader”时都可正确出栈

## 4. 自检与验证

1. 编码/BOM 校验通过：`engine/renderer/nucocos2d_render.cpp` 仍为 UTF-8 with BOM（`EF BB BF`）。
2. 代码结构校验通过：`iShaderType!=0` 的 HSV/灰度逻辑未改，优先级保持。
3. 日志点校验通过：`[P0][EFFECT] DrawPicture read effect=%d param=%p` 保持不变。
4. 构建与运行验证：本轮未执行完整 Win32/iOS 构建，待 `P0-010/P0-008` 联调与 QA 回归补齐。

## 5. 风险与后续

1. 当前 X shader 仅作为 `P0-009` 链路消费占位，未接入 ColorBalance 专用 uniform 映射。
2. `P0-012` 需要完成 ColorBalance/ColorBalance2 shader 动态注册与参数接线，才能形成目标夜景视觉差异。
