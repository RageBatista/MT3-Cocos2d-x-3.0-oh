# API 接口文档 - Login（源码对齐版）

> 更新时间：2026-04-10  
> 应用定位：历史授权兼容入口（当前主链路为 `player/*`）

## 1. 路由口径

Login 应用存在两类入口：

1. 显式兼容重定向（定义在 `route/player.php`）  
2. 隐式控制器路由（开发环境 `url_route_must=false` 时 `/login/{controller}/{action}` 可达；生产环境走显式重定向）

说明：当路径命中显式重定向时，优先走重定向，不会进入 Login 控制器对应方法。

## 2. Index 控制器（后台登录）

控制器：[`../../app/login/controller/Index.php`](../../app/login/controller/Index.php)

### 2.1 登录页

- 路径：`GET /login/index/index`

### 2.2 登录提交

- 路径：`POST /login/index/submit`
- 参数：
  - `username`
  - `password`
  - `captcha`（`verify_step=1` 时必填）
  - `verify_step`（`1|2`）
  - `super_admin_key`（超管二次验证）
  - `csrf_token`
- 关键行为：
  1. 强制 CSRF 校验
  2. 超管第一步返回 `code=99` 提示二次验证
  3. 鉴权成功后写入 `player_admin_*` 与兼容 Session 键

## 3. User 控制器（历史账号登录）

控制器：[`../../app/login/controller/User.php`](../../app/login/controller/User.php)

### 3.1 页面

- 路径：`GET /login/user/index`

### 3.2 提交

- 路径：`POST /login/user/submit`
- 参数：
  - `username`
  - `password`
  - `serverid`（可选）
- 关键行为：
  1. 受 `player.auth_enabled` 开关控制
  2. 登录成功后写入 `auth_*` 会话（`auth_uid/auth_serverid/auth_cdk...`）

## 4. Auth 控制器（历史 CDK/GM 入口）

控制器：[`../../app/login/controller/Auth.php`](../../app/login/controller/Auth.php)

### 4.1 页面与账号登录

- `GET /login/auth/index`
- `GET /login/auth/auth`
- `GET /login/auth/userLogin`
- `POST /login/auth/userLoginSubmit`

### 4.2 CDK 授权链路

- `GET /login/auth/getServers`
- `POST /login/auth/authSubmit`
- `POST /login/auth/authExisting`
- `GET /login/auth/authSuccess`
- `GET /login/auth/dashboard`
- `GET /login/auth/logout`

授权相关参数：

- `uid`：游戏角色ID
- `cdk`：CDK（16/20位）
- `authpass`：授权密码
- `serverid`：区组标识（兼容 `serverid/主键id/gmport`）

### 4.3 历史发放能力（兼容）

- `POST /login/auth/getItemList`
- `POST /login/auth/prepareOp`
- `POST /login/auth/sendItem`
- `POST /login/auth/rechargeXianyu`

签名约束：

1. `prepareOp` 返回 `ts`、`sig`
2. 真正执行时需提交 `op_ts`、`op_sig`
3. `sendItem` 需 `item_token` + `number`
4. `rechargeXianyu` 需 `number`

## 5. 显式兼容重定向（当前生效）

以下路径在 `route/player.php` 中已定义重定向：

- `GET /login/auth` -> `/player/cdk/index`
- `GET /login/auth/auth` -> `/player/cdk/index`
- `GET /login/auth/dashboard` -> `/player/cdk/dashboard`
- `GET /login/auth/senditem` -> `/player/cdk/senditem`
- `GET /login/auth/sendItem` -> `/player/cdk/senditem`
- `GET /login/auth/senditem/index` -> `/player/cdk/senditem`
- `GET /login/auth/logout` -> `/player/cdk/logout`
- `GET /login/auth/success` -> `/player/cdk/dashboard`
- `GET /login/index` -> `/player/admin/login`
- `GET /login/user` -> `/player/cdk/index`
- `POST /login/index/submit` -> `/player/admin/doLogin`

## 6. 已知限制

1. Login 模块是兼容层，新增接入应优先使用 `player/*`。  
2. `Auth` 发放接口依赖 `OP_SECRET_SALT` 与授权会话，不建议对外直接暴露。  
3. `Login` 与 `Player` 存在并行会话语义，联调时需明确是“账号登录态”还是“CDK 授权态”。

## 7. 相关文档

- [API接口文档-Player](./02-API接口文档-Player.md)
- [API接口文档-公共](./02-API接口文档-公共.md)
- [安全机制说明](./04-安全机制说明.md)
