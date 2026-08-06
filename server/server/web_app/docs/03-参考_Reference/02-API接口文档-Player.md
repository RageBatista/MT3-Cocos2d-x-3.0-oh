# API 接口文档 - Player 应用（源码对齐版）

> 更新时间：2026-04-10  
> 对齐来源：`route/player.php` + `app/player/controller/*.php`

## 1. 应用总览

Player 应用是当前玩家侧主入口，包含三类能力：

1. 账号体系：注册/登录/资料/订单/充值/反馈/转区  
2. CDK 授权体系：`/player/cdk/*`  
3. 后台登录体系：`/player/admin/*`

中间件说明（`app/player/middleware.php`）：

1. `TraceId`（全链路追踪，生成/透传 `X-Request-ID`，UUID v4 格式）
2. `PlayerSecurity`（频率控制 + 恶意 IP 检测）
3. `PlayerAuth`（登录态校验）
4. `CsrfToken`（写操作 CSRF）

## 2. Auth 控制器

控制器：[`../../app/player/controller/Auth.php`](../../app/player/controller/Auth.php)

- `GET /player/auth/login`
- `POST /player/auth/doLogin`  
  参数：`username`、`password`、`csrf_token`
- `GET /player/auth/register`
- `POST /player/auth/doRegister`  
  参数：`username`、`password`、`confirm_password`、`invite_code`(可选)、`csrf_token`
- `GET /player/auth/forgot`
- `POST /player/auth/doForgot`  
  参数：`username`、`email`、`csrf_token`
- `GET /player/auth/resetPassword`（需 `token`）
- `POST /player/auth/doResetPassword`  
  参数：`token`、`password`、`confirm_password`、`csrf_token`
- `GET /player/auth/logout`

## 3. Index 控制器

控制器：[`../../app/player/controller/Index.php`](../../app/player/controller/Index.php)

- `GET /player`
- `GET /player/index`

行为：渲染玩家中心首页（统计信息 + 服务器列表）。

## 4. Profile 控制器

控制器：[`../../app/player/controller/Profile.php`](../../app/player/controller/Profile.php)

- `GET /player/profile`
- `POST /player/profile/update`  
  参数：`csrf_token` + 可选资料字段（`nickname/real_name/realname/gender/birthday/phone/email/qq/wechat/province/city/address`）
- `GET /player/profile/password`
- `POST /player/profile/updatePassword`  
  参数：`old_password`、`new_password`、`confirm_password`、`csrf_token`
- `GET /player/profile/avatar`
- `POST /player/profile/uploadAvatar`  
  参数：`avatar`(文件)、`csrf_token`

上传约束：仅 `jpg/jpeg/png/gif/webp`，大小 <= 2MB。

## 5. Server 控制器

控制器：[`../../app/player/controller/Server.php`](../../app/player/controller/Server.php)

- `GET /player/server`
- `GET /player/server/detail`

`detail` 参数：

- `id`（支持 `serverid` / 表主键 `id` / `gmport`）

## 6. Role 控制器

控制器：[`../../app/player/controller/Role.php`](../../app/player/controller/Role.php)

- `GET /player/role`
- `GET /player/role/detail`（参数：`id`）
- `GET /player/role/getByServer`（参数：`server_id`）

## 7. Order 控制器

控制器：[`../../app/player/controller/Order.php`](../../app/player/controller/Order.php)

- `GET /player/order`
- `GET /player/order/detail`

`/player/order` 可选参数：

- `status`：`0|1|2`
- `order_no`：订单号模糊查询（匹配 `orderid`）
- `page`
- `limit`（1-100）

`/player/order/detail` 参数：

- `id`

## 8. Recharge 控制器

控制器：[`../../app/player/controller/Recharge.php`](../../app/player/controller/Recharge.php)

- `GET /player/recharge`
- `POST /player/recharge/createOrder`

`createOrder` 参数：

- `item_id`
- `server_id`
- `role_id`
- `pay_channel`（`wechat` 或 `alipay`）
- `csrf_token`

## 9. Transfer 控制器

控制器：[`../../app/player/controller/Transfer.php`](../../app/player/controller/Transfer.php)

- `GET /player/transfer`
- `POST /player/transfer/submit`
- `GET /player/transfer/getRoles`
- `GET /player/transfer/detail`

`submit` 参数：

- `source_server_id`
- `target_server_id`
- `role_id`
- `contact`
- `reason`
- `csrf_token`

`getRoles` 参数：

- `server_id`

`detail` 参数：

- `id`

## 10. Service 控制器

控制器：[`../../app/player/controller/Service.php`](../../app/player/controller/Service.php)

- `GET /player/service`

行为：渲染客服页（客服配置 + FAQ）。

## 11. Feedback 控制器

控制器：[`../../app/player/controller/Feedback.php`](../../app/player/controller/Feedback.php)

- `GET /player/feedback`
- `POST /player/feedback/submit`

`submit` 参数：

- `role`（角色ID）
- `content`（10-500字符）
- `csrf_token`

说明：当前代码未使用 `images` 字段。

## 12. SendItem / Cdk 控制器

控制器：

- [`../../app/player/controller/Cdk.php`](../../app/player/controller/Cdk.php)
- [`../../app/player/controller/SendItem.php`](../../app/player/controller/SendItem.php)

### 12.1 CDK 授权入口

- `GET /player/cdk/`
- `GET /player/cdk/index`
- `POST /player/cdk/auth`  
  参数：`uid`、`cdk`、`serverid`、`authpass`、`csrf_token`
- `POST /player/cdk/existing`  
  参数：`uid`、`authpass`、`serverid`(可选)、`csrf_token`
- `GET /player/cdk/servers`
- `GET /player/cdk/dashboard`
- `GET /player/cdk/logout`

### 12.2 发放操作入口

- `GET /player/cdk/senditem`
- `GET /player/cdk/sendItem`（兼容别名）
- `GET /player/cdk/senditem/index`（兼容别名）
- `POST /player/cdk/senditem/getItemList`
- `POST /player/cdk/senditem/prepareOp`
- `POST /player/cdk/senditem/sendItem`
- `POST /player/cdk/senditem/rechargeXianyu`
- `POST /player/cdk/senditem/switchServer`

签名口径：

1. `prepareOp` 返回 `ts`、`sig`  
2. 真正执行时校验字段为 `op_ts`、`op_sig`

`sendItem` 参数：

- `item_token`
- `number`
- `op_ts`
- `op_sig`

`rechargeXianyu` 参数：

- `number`
- `op_ts`
- `op_sig`

`switchServer` 参数：

- `server_id`

## 13. Admin 控制器

控制器：[`../../app/player/controller/Admin.php`](../../app/player/controller/Admin.php)

- `GET /player/admin/login`
- `POST /player/admin/doLogin`
- `GET /player/admin/logout`
- `GET /player/admin/captcha`

`doLogin` 参数：

- `username`
- `password`
- `captcha`（`verify_step=1` 时使用）
- `verify_step`
- `super_admin_key`
- `csrf_token`

## 14. 返回与错误语义

1. 常见业务返回：`notify(code,msg,data)` 或 `json({code,msg,data})`
2. 业务成功：通常 `code=1`
3. 业务失败：通常 `code=0`
4. 超管二次验证提示：`code=99`
5. 中间件失败场景可见：`401/403/429`
6. 所有响应均携带 `X-Request-ID` 响应头（TraceId 中间件自动注入）

## 15. 相关文档

- [API接口文档-公共](./02-API接口文档-公共.md)
- [API接口文档-Login](./02-API接口文档-Login.md)
- [安全机制说明](./04-安全机制说明.md)
- [业务逻辑说明](./05-业务逻辑说明.md)
