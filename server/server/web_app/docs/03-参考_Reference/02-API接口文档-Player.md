# API 接口文档 - Player 应用

> 更新时间：2026-02-27
> 说明：本文档基于代码分析生成，与当前仓库对齐。

## 目录

- [1. Auth 控制器](#1-auth-控制器)
- [2. Index 控制器](#2-index-控制器)
- [3. Profile 控制器](#3-profile-控制器)
- [4. Server 控制器](#4-server-控制器)
- [5. Role 控制器](#5-role-控制器)
- [6. Order 控制器](#6-order-控制器)
- [7. Recharge 控制器](#7-recharge-控制器)
- [8. Transfer 控制器](#8-transfer-控制器)
- [9. Service 控制器](#9-service-控制器)
- [10. Feedback 控制器](#10-feedback-控制器)
- [11. SendItem 控制器](#11-senditem-控制器)
- [12. Cdk 控制器](#12-cdk-控制器)
- [13. Admin 控制器](#13-admin-控制器)
- [14. 错误码说明](#14-错误码说明)

---

## 1. Auth 控制器

**控制器位置**：[`app/player/controller/Auth.php`](../../app/player/controller/Auth.php)

### 1.1 登录页面

- **路径**：`GET /player/auth/login`
- **说明**：显示玩家登录页面

### 1.2 执行登录

- **路径**：`POST /player/auth/doLogin`
- **说明**：执行玩家登录
- **参数**：
  - `username`：用户名
  - `password`：密码

### 1.3 注册页面

- **路径**：`GET /player/auth/register`
- **说明**：显示玩家注册页面

### 1.4 执行注册

- **路径**：`POST /player/auth/doRegister`
- **说明**：执行玩家注册
- **参数**：
  - `username`：用户名
  - `password`：密码
  - `confirm_password`：确认密码
  - `invite_code`：邀请码（可选）
  - `csrf_token`：CSRF 令牌

### 1.5 忘记密码页面

- **路径**：`GET /player/auth/forgot`
- **说明**：显示忘记密码页面

### 1.6 发送验证码

- **路径**：`POST /player/auth/doForgot`
- **说明**：提交找回密码申请（基于账号 + 邮箱匹配，重置令牌存入缓存，1小时有效）
- **参数**：
  - `username`：用户名
  - `email`：邮箱
  - `csrf_token`：CSRF 令牌

### 1.7 重置密码页面

- **路径**：`GET /player/auth/resetPassword`
- **说明**：显示重置密码页面（需携带 `token` 查询参数）

### 1.8 执行重置密码

- **路径**：`POST /player/auth/doResetPassword`
- **说明**：执行重置密码
- **参数**：
  - `token`：重置令牌
  - `password`：新密码
  - `confirm_password`：确认新密码
  - `csrf_token`：CSRF 令牌

### 1.9 退出登录

- **路径**：`GET /player/auth/logout`
- **说明**：清除玩家会话

---

## 2. Index 控制器

**控制器位置**：[`app/player/controller/Index.php`](../../app/player/controller/Index.php)

### 2.1 首页

- **路径**：`GET /player/index`
- **说明**：玩家中心首页

---

## 3. Profile 控制器

**控制器位置**：[`app/player/controller/Profile.php`](../../app/player/controller/Profile.php)

### 3.1 个人资料页面

- **路径**：`GET /player/profile`
- **说明**：显示个人资料页面

### 3.2 更新资料

- **路径**：`POST /player/profile/update`
- **说明**：更新个人资料

### 3.3 修改密码页面

- **路径**：`GET /player/profile/password`
- **说明**：显示修改密码页面

### 3.4 执行修改密码

- **路径**：`POST /player/profile/updatePassword`
- **说明**：执行修改密码
- **参数**：
  - `old_password`：原密码
  - `new_password`：新密码

### 3.5 头像设置页面

- **路径**：`GET /player/profile/avatar`
- **说明**：显示头像设置页面

### 3.6 上传头像

- **路径**：`POST /player/profile/uploadAvatar`
- **说明**：上传并设置头像

---

## 4. Server 控制器

**控制器位置**：[`app/player/controller/Server.php`](../../app/player/controller/Server.php)

### 4.1 服务器列表

- **路径**：`GET /player/server`
- **说明**：显示服务器列表页面

### 4.2 服务器详情

- **路径**：`GET /player/server/detail`
- **说明**：显示指定服务器详情（支持 `id` 参数传 `serverid`、主键 `id` 或 `gmport`）

---

## 5. Role 控制器

**控制器位置**：[`app/player/controller/Role.php`](../../app/player/controller/Role.php)

### 5.1 角色列表

- **路径**：`GET /player/role`
- **说明**：显示角色列表页面

### 5.2 角色详情

- **路径**：`GET /player/role/detail`
- **说明**：获取角色详情

### 5.3 按服务器查询角色

- **路径**：`GET /player/role/getByServer`
- **说明**：根据服务器ID获取角色列表

---

## 6. Order 控制器

**控制器位置**：[`app/player/controller/Order.php`](../../app/player/controller/Order.php)

### 6.1 订单列表

- **路径**：`GET /player/order`
- **说明**：显示订单列表页面
- **可选参数**：
  - `status`：订单状态（`0` 待支付，`1` 已支付，`2` 已退款）
  - `order_no`：订单号模糊搜索（对应 `user_order.orderid`）
  - `page`：页码
  - `limit`：每页数量（最大100）

### 6.2 订单详情

- **路径**：`GET /player/order/detail`
- **说明**：获取订单详情

---

## 7. Recharge 控制器

**控制器位置**：[`app/player/controller/Recharge.php`](../../app/player/controller/Recharge.php)

### 7.1 充值页面

- **路径**：`GET /player/recharge`
- **说明**：显示充值页面

### 7.2 创建订单

- **路径**：`POST /player/recharge/createOrder`
- **说明**：创建充值订单
- **参数**：
  - `item_id`：充值商品 ID
  - `server_id`：服务器 ID（serverid）
  - `role_id`：角色 ID
  - `pay_channel`：支付渠道（`wechat` 或 `alipay`）
  - `csrf_token`：CSRF 令牌

---

## 8. Transfer 控制器

**控制器位置**：[`app/player/controller/Transfer.php`](../../app/player/controller/Transfer.php)

### 8.1 转区申请页面

- **路径**：`GET /player/transfer`
- **说明**：显示转区申请页面

### 8.2 提交转区申请

- **路径**：`POST /player/transfer/submit`
- **说明**：提交转区申请

### 8.3 获取角色列表

- **路径**：`GET /player/transfer/getRoles`
- **说明**：获取可转区的角色列表

### 8.4 转区详情

- **路径**：`GET /player/transfer/detail`
- **说明**：获取转区申请详情

---

## 9. Service 控制器

**控制器位置**：[`app/player/controller/Service.php`](../../app/player/controller/Service.php)

### 9.1 客服页面

- **路径**：`GET /player/service`
- **说明**：显示客服页面

---

## 10. Feedback 控制器

**控制器位置**：[`app/player/controller/Feedback.php`](../../app/player/controller/Feedback.php)

### 10.1 反馈页面

- **路径**：`GET /player/feedback`
- **说明**：显示用户反馈页面

### 10.2 提交反馈

- **路径**：`POST /player/feedback/submit`
- **说明**：提交用户反馈
- **参数**：
  - `content`：反馈内容
  - `images`：截图（可选）

---

## 11. SendItem 控制器

**控制器位置**：[`app/player/controller/SendItem.php`](../../app/player/controller/SendItem.php)

### 11.1 赠送礼物页面

- **路径**：`GET /player/cdk/senditem`
- **说明**：显示赠送礼物页面（需已完成 CDK 授权）

### 11.2 获取物品列表

- **路径**：`POST /player/cdk/senditem/getItemList`
- **说明**：获取可赠送的物品列表（需 CDK 授权会话 + CSRF）

### 11.3 准备操作

- **路径**：`POST /player/cdk/senditem/prepareOp`
- **说明**：准备发放操作签名（`sendItem` 场景会返回后端签发的 `item_token`）

### 11.4 执行赠送

- **路径**：`POST /player/cdk/senditem/sendItem`
- **说明**：执行赠送礼物（需 `item_token` + 操作签名）
- **参数**：
  - `item_token`：物品令牌
  - `number`：数量
  - `ts`：时间戳
  - `sig`：签名

### 11.5 仙玉充值

- **路径**：`POST /player/cdk/senditem/rechargeXianyu`
- **说明**：为仙玉充值（需操作签名）

### 11.6 切换服务器

- **路径**：`POST /player/cdk/senditem/switchServer`
- **说明**：切换游戏服务器（需 CDK 授权会话 + CSRF）

---

## 12. Cdk 控制器

**控制器位置**：[`app/player/controller/Cdk.php`](../../app/player/controller/Cdk.php)

### 12.1 CDK 兑换页面

- **路径**：`GET /player/cdk/index`
- **说明**：显示CDK授权页面（含首次授权与已有授权登录表单）

### 12.2 CDK 验证

- **路径**：`POST /player/cdk/auth`
- **说明**：执行 CDK 首次授权

### 12.3 已有兑换码

- **路径**：`POST /player/cdk/existing`
- **说明**：执行已有授权登录（通过授权密码验证）

### 12.4 CDK 仪表盘

- **路径**：`GET /player/cdk/dashboard`
- **说明**：显示CDK管理仪表盘（需已登录授权会话）

### 12.5 CDK 服务器列表

- **路径**：`GET /player/cdk/servers`
- **说明**：获取可用的服务器列表

### 12.6 CDK 登出

- **路径**：`GET /player/cdk/logout`
- **说明**：CDK登出

---

## 13. Admin 控制器

**控制器位置**：[`app/player/controller/Admin.php`](../../app/player/controller/Admin.php)

### 13.1 管理员登录页面

- **路径**：`GET /player/admin/login`
- **说明**：显示管理员登录页面

### 13.2 管理员登录

- **路径**：`POST /player/admin/doLogin`
- **说明**：执行管理员登录

### 13.3 管理员登出

- **路径**：`GET /player/admin/logout`
- **说明**：管理员退出登录

### 13.4 验证码

- **路径**：`GET /player/admin/captcha`
- **说明**：获取登录验证码

---

## 14. 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 操作失败 |
| 1 | 操作成功 |
| 401 | 未登录或登录已过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 422 | 参数验证失败 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |

---

## 相关文档

- [API接口文档-公共](./02-API接口文档-公共.md)
- [API接口文档-Admin](./02-API接口文档-Admin.md)
- [API接口文档-Agent](./02-API接口文档-Agent.md)
- [安全机制说明](./04-安全机制说明.md)
- [业务逻辑说明](./05-业务逻辑说明.md)
