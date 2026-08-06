# API 接口文档 - Game（源码对齐版）

> 更新时间：2026-03-23  
> 控制器：`app/api/controller/Game.php`  
> 基础路径：`/api/game/*`（`route/app.php` 显式路由定义）

## 1. 模块定位

`Game` 为历史游戏接入兼容层，当前包含：

1. SDK 登录鉴权（旧协议）
2. 角色绑定（支持绑定票据）
3. 客服页与反馈页
4. 旧版转区页面与提交接口
5. 返利入口（默认关闭）

说明：该模块与 `player/*` 新链路并存，新增接入优先使用 Player 链路。

## 2. 接口清单

## 2.1 `sdk`

- 路径：`GET/POST /api/game/sdk`
- 必填参数：`account`、`password`、`serverId`
- 兼容参数处理：
  - `account` 支持 `a,b` 形式，取第一个
  - `password` 支持 `xxx|pwd` 形式，取 `|` 后段
- 返回格式受 `API_SDK_LEGACY_RAW` 控制：
  - 默认（`false`）：`api_json(...)` 结构化 JSON
  - 开启（`true`）：`json_encode(...)` 字符串 JSON

成功返回字段（示例）：

- `Code`=`1`
- `Channel`、`PlatformId`
- `Account`
- `Message`
- `Session`（HMAC 派生）
- `BindTicket`、`BindTicketExpire`（启用 bind ticket 时签发）

失败返回：`Code=2`（并记录失败原因日志）。

## 2.2 `bind`

- 路径：`POST /api/game/bind`
- 入参：
  - 常规：`account`、`qu`、`roleid`、`name`
  - 票据：`bind_ticket`（兼容 `ticket`、`bindTicket`）
- 行为：
  - 当 `security.bind_ticket.enabled=true` 时可消费票据并强校验归属
  - 当 `security.bind_ticket.required_on_api_bind=true` 时，`bind_ticket` 必填
  - 调用 `RoleBindService::bind` 执行绑定/刷新绑定
- 返回格式受 `API_BIND_LEGACY_SCALAR` 控制：
  - 默认（`false`）：`{"code":1|0,"msg":"..."}` 风格
  - 开启（`true`）：`json_encode(1|0)` 旧标量协议

## 2.3 `kefu`

- 路径：`GET/POST /api/game/kefu`
- 参数：`username`（可选）
- 返回：HTML 视图（`api/view/game/kefu.html`）
- 说明：若账号/代理客服信息缺失，回落默认客服数据。

## 2.4 `zhuanqu`

- 路径：`GET/POST /api/game/zhuanqu`
- 必填参数：`username`
- 返回：HTML 视图（`api/view/game/zhuanqu.html`）
- 说明：渲染账号绑定角色列表与区服信息。

## 2.5 `zhuanquSub`

- 路径：`POST /api/game/zhuanquSub`
- 必填参数：`oldrole`、`newrole`
- 返回：`notify(code,msg)`

核心校验（按代码）：

1. 新旧角色都必须存在
2. 新旧角色必须属于同一账号
3. 新旧角色不能相同
4. 新角色未领过转区福利
5. 旧角色累计充值 >= 1000
6. 新角色累计充值 >= 旧角色累计充值 * 50%

执行逻辑：

1. 事务开启
2. 踢出旧角色
3. 给新角色发放仙玉、VIP经验
4. 更新“已转区”与绑定状态
5. 成功提交 / 失败回滚

发放公式：

- 仙玉：`old_charge * 600`
- VIP经验：`old_charge * 3`

## 2.6 `rebate`

- 路径：`GET/POST /api/game/rebate`
- 当前行为：函数开头直接返回“功能关闭”响应，主体历史逻辑不可达
- 返回格式受 `API_REBATE_LEGACY_TEXT` 控制：
  - 默认（`false`）：`notify(0,'此功能已关闭')`
  - 开启（`true`）：纯文本 `此功能已关闭`

## 2.7 `fankui`

- 路径：`GET/POST /api/game/fankui`
- 必填参数：`username`
- 返回：HTML 视图（`api/view/game/fankui.html`）

## 2.8 `fankuiSub`

- 路径：`POST /api/game/fankuiSub`
- 必填参数：`role`、`info`
- 返回：`notify(code,msg)`

行为要点：

1. 同角色在 24 小时内有未完成工单时拒绝重复提交
2. 自动反查并写入 `uid`、`username`
3. 写入 `user_fankui` 并同步 `created_at/updated_at`

## 3. 兼容与风险提示

1. 返回形态混合（结构化 JSON / JSON 字符串 / HTML），调用方不得假设统一协议。
2. `Game` 属于历史兼容层，后续新增业务应优先走 Player 新链路。
3. `rebate` 主体逻辑不可达，不能作为真实业务能力依赖。

## 4. 相关文档

- `02-API接口文档-公共.md`
- `02-API接口文档-SDK.md`
- `02-API接口文档-Player.md`
- `12-转区服务说明.md`
