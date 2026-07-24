# API 接口文档 - SDK/游戏接入（与当前代码对齐）

> 更新时间：2026-02-23  
> 说明：本文件聚焦当前代码可确认接口，尤其支付/回调相关链路。

## 1. 账号接口（`app/api/controller/Sdk.php`）

## 1.1 用户登录

- 路径：`POST/GET /api/sdk/user_login`
- 参数：`account`、`password`、`platform`
- 行为：
  - 兼容 GET/POST 混合取参
  - 平台标准化为 `android/ios/windows`
  - 成功时更新用户平台/IP并记录日志

成功响应（字符串 JSON）：

```json
{"code":1,"msg":"登录成功","account":"...","password":"..."}
```

失败响应：`{"code":0,"msg":"..."}`

## 1.2 用户注册

- 路径：`POST/GET /api/sdk/user_register`
- 参数：`account`、`password`、`invitecode`、`captcha`
- 约束：
  - 账号/密码：6~18 位字母+数字
  - 邀请码：4~8 位字母+数字

## 1.3 iOS 注册

- 路径：`POST/GET /api/sdk/user_regapp`
- 行为：复用 `user_register()`，强制平台为 `ios`

## 1.4 iOS 登录

- 路径：`POST/GET /api/sdk/user_app`
- 行为：复用 `user_login()`，强制平台为 `ios`

---

## 2. 支付下单（`app/api/controller/Pay.php`）

## 2.1 获取支付商品

- 路径：`GET /api/pay/getpayitem`
- 返回：商品列表 JSON 字符串

## 2.2 创建订单

- 路径：`POST/GET /api/pay/getpay`
- 必填参数：`account`、`roleid`、`payid`、`paytype`（代码对白名单字段做空值检查）

关键实现（P1-B/P2）：

1. 参数白名单，防变量覆盖
2. 下单锁：`pay_order_lock:{roleid}:{payid}`（Redis）
3. 限购检查在锁内执行（`rolelimit/daylimit`）
4. 支付通道缓存 300 秒：`pay_channels:{type}`
5. 订单号使用 `random_int()`（替代弱随机）
6. 订单写入使用事务

成功响应示例：

```json
{"code":1,"url":"base64(...)"}
```

失败响应示例：

```json
{"code":0,"msg":"系统繁忙，请稍后重试"}
```

---

## 3. 游戏接入接口（`app/api/controller/Game.php`）

## 3.1 游戏登录鉴权

- 路径：`POST/GET /api/game/sdk`
- 返回：历史兼容字符串（`{"Code":"1"}`/`{"Code":"2"}`）

## 3.2 绑定角色

- 路径：`POST /api/game/bind`
- 返回：`json_encode(1/0)`

## 3.3 客服信息页

- 路径：`POST/GET /api/game/kefu`
- 返回：HTML

## 3.4 旧转区页与提交

- 页面：`/api/game/zhuanqu`
- 提交：`/api/game/zhuanquSub`

说明：该链路与 `Player/Admin + TransferExecutionService` 新转区链路并存。

## 3.5 反馈页与提交

- 页面：`/api/game/fankui`
- 提交：`/api/game/fankuiSub`

## 3.6 返利查询接口

- 路径：`POST/GET /api/game/rebate`
- 用途：返回玩家返利信息查询结果（当前实现直接输出 JSON 字符串）

---

## 4. 支付回调接口（重点）

## 4.1 异步回调

- 路径：`POST/GET /api/call/epay`
- 控制器：`app/api/controller/Call.php`
- 返回：`success/fail/...`
- 含 P0 安全加固：防重放、幂等锁、事务一致性、日志脱敏

## 4.2 同步回调（页面）

- 路径：`POST/GET /api/notify/epay`
- 控制器：`app/api/controller/Notify.php`
- 返回：HTML 页面

## 4.3 测试入口

- `/api/call/test`
- `/api/call/checkurl`
- `/api/call/epay1`（生产环境禁用，返回 403）

---

## 5. 语音与其他接口

### 5.1 语音识别

- `POST /api/voice/receive`
- `POST /api/voice/iat`

### 5.2 充值奖励

- `GET /api/chargeaward/getchargeitem`
- `POST /api/chargeaward/receiveday`
- `POST /api/chargeaward/receiverole`
- `POST /api/chargeaward/modifypass`

### 5.3 FAQ

- `GET /api/faq/index`
- `GET /api/faq/search`

---

## 6. 特殊说明（避免误用）

1. 文档中的响应示例为“当前实现形态”，不是统一网关协议。
2. 订单最终状态以异步回调 `/api/call/epay` 为准。
3. `epay1` 仅用于非生产调试，生产访问会被拒绝。
4. 部分历史接口继续存在（如 `/api/game/zhuanqu*`），不代表推荐新接入使用。
