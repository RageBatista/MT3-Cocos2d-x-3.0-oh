# API 接口文档 - SDK/开放接口（源码对齐版）

> 更新时间：2026-04-26  
> 主要控制器：`app/api/controller/Sdk.php`、`Pay.php`、`Call.php`、`Notify.php`、`Game.php`、`Enlist.php`、`LegacyRole.php`

## 1. 账号接口（`api/Sdk`）

## 1.1 `user_login`

- 首选路径：`GET/POST /api/v1/sdk/login`
- 兼容路径：`GET/POST /api/sdk/user_login`、`GET/POST /api/sdk/login`
- 参数：`account`、`password`、`platform`
- 返回：`json_encode` 字符串 JSON

行为要点：

1. 优先 POST，缺失字段回退 `param`（兼容 GET/POST 混合提交）
2. 平台标准化为 `android/ios/windows`
3. 成功后更新账号平台/IP并写用户日志

## 1.2 `user_register`

- 首选路径：`GET/POST /api/v1/sdk/register`
- 兼容路径：`GET/POST /api/sdk/user_register`、`GET/POST /api/sdk/register`
- 参数：`account`、`password`、`invitecode`、`captcha`
- 账号/密码校验：6-18 位字母数字组合
- 邀请码校验：4-8 位字母数字组合

## 1.3 iOS 专用兼容

- `GET/POST /api/v1/sdk/register-ios`、`GET/POST /api/sdk/user_regapp`（强制 iOS 注册）
- `GET/POST /api/v1/sdk/login-ios`、`GET/POST /api/sdk/user_app`（强制 iOS 登录）

## 2. 支付接口

## 2.1 商品列表

- 路径：`GET /api/pay/getpayitem`
- 控制器：`Pay::getpayitem`

## 2.2 下单

- 路径：`GET/POST /api/pay/getpay`
- 控制器：`Pay::getpay`
- 关键机制：白名单参数 + 下单锁 + 限购校验 + 事务写单

## 2.3 异步回调

- 路径：`GET/POST /api/call/epay`
- 控制器：`Call::epay`
- 返回：`success` / `fail` / 错误文本

## 2.4 同步回跳

- 路径：`GET/POST /api/notify/epay`
- 控制器：`Notify::epay`
- 返回：HTML 页面

## 2.5 回调调试端点

- `GET/POST /api/call/test`
- `GET/POST /api/call/checkurl`
- `GET/POST /api/call/epay1`（生产环境禁用）

说明：`test/checkurl` 默认关闭，受 `security.debug_endpoints.*` 控制。

## 3. Game 兼容接口

位于 `app/api/controller/Game.php`，包括：

- `sdk`
- `bind`
- `kefu`
- `zhuanqu` / `zhuanquSub`
- `rebate`（默认关闭）
- `fankui` / `fankuiSub`

详见：`02-API接口文档-Game.md`。

## 4. 语音接口

位于 `app/api/controller/Voice.php`：

- `POST /api/voice/receive`
- `GET /api/voice/iat?uuid=...`

当前仅接受 AMR 头校验通过的数据。详见 `10-Voice语音识别模块.md`。

## 5. 其他接口

## 5.1 ChargeAward

- `/api/chargeaward/getchargeitem`
- `/api/chargeaward/receiveday`
- `/api/chargeaward/receiverole`
- `/api/chargeaward/modifypass`

## 5.2 FAQ

- `/api/faq/index`
- `/api/faq/search`

## 6. 旧链路兼容接口

## 6.1 Enlist 兼容（真实可用绑定链路）

显式兼容路由：

- `GET/POST /enlist/submit_code`
- `GET/POST /api/enlist/submit_code`

兼容入口映射：

1. 唯一处理器：`app/api/controller/Enlist::submitCode`（通过 `route/app.php` 显式路由映射）

说明：历史文档中引用的根应用兜底控制器 `app/controller/Enlist.php` 和 `app/controller/api/Enlist.php` 均不存在。

当前行为（按代码）：

1. 校验 `new_serverid/new_roleid` 等兼容参数
2. 可选消费 `bind_ticket`（受 `security.bind_ticket.*` 控制）
3. 调用 `RoleBindService` 完成真实绑定
4. 返回纯文本 `1/0`（兼容旧客户端）

## 6.2 LegacyRole 兼容

显式兼容路由：

- `GET/POST /user/api/index.php/role/set`
- `GET/POST /user/api/index.php/role/get`
- `GET/POST /user/api/index/role/set`
- `GET/POST /user/api/index/role/get`

隐式可达路径（同控制器动作）：

- `/api/legacyrole/set`
- `/api/legacyrole/get`

控制器：`app/api/controller/LegacyRole.php`

行为：

1. `set`：校验并写入绑定关系（支持 bind ticket）
2. `get`：优先查 `user_bind`，为空时降级查 `role`
3. 返回旧协议文本（`'1'/'0'` 或 JSON 字符串）

## 7. 注意事项

1. 返回协议不统一，接入方需按端点逐条解析。
2. 支付最终状态以异步回调 `epay` 为准。
3. 旧接口与新链路并存，新增接入优先走 Player 新链路。
