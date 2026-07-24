# API 接口文档 - Login 应用

> 更新时间：2026-03-01
> 说明：本文档基于代码分析生成，与当前仓库对齐。

## 目录

- [1. 模块概述](#1-模块概述)
- [2. Auth 控制器](#2-auth-控制器)
- [3. Index 控制器](#3-index-控制器)
- [4. User 控制器](#4-user-控制器)
- [5. 错误码说明](#5-错误码说明)

---

## 1. 模块概述

Login 应用提供管理员/代理登录入口和玩家CDK授权功能。

**路由前缀**：`/login`

**控制器映射**：

| 控制器 | 路径 | 说明 |
|--------|------|------|
| [`Auth`](#2-auth-控制器) | `app/login/controller/Auth.php` | CDK授权与玩家认证 |
| [`Index`](#3-index-控制器) | `app/login/controller/Index.php` | 管理员/代理登录 |
| [`User`](#4-user-控制器) | `app/login/controller/User.php` | 玩家账号登录 |

---

## 2. Auth 控制器

**控制器位置**：[`app/login/controller/Auth.php`](../../app/login/controller/Auth.php)

### 2.1 授权页面

- **路径**：`GET /login/auth/index` 或 `GET /login/auth/auth`
- **功能**：显示CDK授权页面
- **鉴权**：无需登录

### 2.2 用户登录页面

- **路径**：`GET /login/auth/userLogin`
- **功能**：显示玩家账号密码登录页面
- **鉴权**：无需登录

### 2.3 用户登录提交

- **路径**：`POST /login/auth/userLoginSubmit`
- **功能**：玩家账号密码登录
- **鉴权**：无需登录
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名（6-18位字母数字） |
| password | string | 是 | 密码（6-18位字母数字） |
| serverid | string | 否 | 服务器ID |

- **响应示例**：
```json
// 成功
{"code": 1, "msg": "登录成功"}

// 失败
{"code": 0, "msg": "账号或密码错误"}
```

### 2.4 获取服务器列表

- **路径**：`GET /login/auth/getServers`
- **功能**：获取可用服务器列表
- **鉴权**：无需登录（需开启授权功能）
- **响应示例**：
```json
{
  "code": 1,
  "data": [
    {"serverid": 1, "name": "服务器1", "groupname": "分组A"}
  ]
}
```

### 2.5 CDK授权提交

- **路径**：`POST /login/auth/authSubmit`
- **功能**：提交CDK授权信息
- **鉴权**：无需登录（需开启授权功能）
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| serverid | string | 是 | 服务器ID |
| authpass | string | 否 | 授权密码 |
| uid | int | 是 | 玩家UID |
| cdk | string | 是 | CDK激活码 |

- **响应示例**：
```json
// 成功（首次绑定）
{"code": 1, "msg": "授权成功（首次绑定）"}

// 失败
{"code": 0, "msg": "CDK不存在"}
```

### 2.6 授权成功页面

- **路径**：`GET /login/auth/authSuccess`
- **功能**：显示授权成功信息
- **鉴权**：需要Session中的授权信息

### 2.7 已有授权登录

- **路径**：`POST /login/auth/authExisting`
- **功能**：使用已有授权记录登录
- **鉴权**：无需登录（需开启授权功能）
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| uid | int | 是 | 玩家UID |
| authpass | string | 是 | 授权密码 |
| serverid | string | 否 | 服务器ID |

- **响应示例**：
```json
// 成功
{"code": 1, "msg": "登录成功（已有授权）"}

// 失败
{"code": 0, "msg": "授权密码不正确"}
```

### 2.8 控制面板

- **路径**：`GET /login/auth/dashboard`
- **功能**：显示授权用户控制面板
- **鉴权**：需要Session中的授权信息

### 2.9 退出登录

- **路径**：`GET /login/auth/logout`
- **功能**：清除授权Session并跳转授权页
- **鉴权**：无需登录

---

## 3. Index 控制器

**控制器位置**：[`app/login/controller/Index.php`](../../app/login/controller/Index.php)

### 3.1 登录页面

- **路径**：`GET /login/index/index`
- **功能**：显示管理员/代理登录页面
- **鉴权**：无需登录

### 3.2 登录提交

- **路径**：`POST /login/index/submit`
- **功能**：管理员/代理登录验证
- **鉴权**：无需登录
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名（6-18位字母数字） |
| password | string | 是 | 密码（6-18位字母数字） |
| captcha | string | 是 | 验证码 |
| super_admin_key | string | 否 | 超级管理员二次验证密钥 |
| verify_step | string | 否 | 验证步骤（默认"1"） |
| csrf_token | string | 是 | CSRF令牌 |

- **响应示例**：
```json
// 成功
{"code": 1, "msg": "登录成功"}

// 失败
{"code": 0, "msg": "验证码不正确"}
```

---

## 4. User 控制器

**控制器位置**：[`app/login/controller/User.php`](../../app/login/controller/User.php)

### 4.1 用户登录页面

- **路径**：`GET /login/user/index`
- **功能**：显示玩家登录页面
- **鉴权**：无需登录

### 4.2 用户登录提交

- **路径**：`POST /login/user/submit`
- **功能**：玩家账号密码登录
- **鉴权**：无需登录（需开启授权功能）
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名（6-18位字母数字） |
| password | string | 是 | 密码（6-18位字母数字） |
| serverid | string | 否 | 服务器ID |

- **响应示例**：
```json
// 成功
{"code": 1, "msg": "登录成功"}

// 失败
{"code": 0, "msg": "账号或密码错误"}
```

---

## 5. 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 操作失败（具体原因见msg字段） |
| 1 | 操作成功 |

### 常见错误信息

| 错误信息 | 说明 |
|----------|------|
| 玩家授权功能未开启 | `config('player.auth_enabled')` 为 false |
| 账号格式不正确 | 用户名不符合6-18位字母数字格式 |
| 密码格式不正确 | 密码不符合6-18位字母数字格式 |
| 账号或密码错误 | 用户名不存在或密码不匹配 |
| 账号已被禁用 | 用户status字段不为1 |
| 暂无可用大区 | 未配置有效服务器 |
| CDK格式不正确 | CDK不符合16或20位字母数字格式 |
| CDK不存在 | 数据库中未找到该CDK |
| CDK已使用 | CDK状态为已使用 |
| 验证码不正确 | 图形验证码校验失败 |

---

## 6. 相关文档

- [API接口文档-公共](02-API接口文档-公共.md)
- [API接口文档-Player](02-API接口文档-Player.md)
- [安全机制说明](04-安全机制说明.md)
- [配置文件说明](03-配置文件说明.md)
