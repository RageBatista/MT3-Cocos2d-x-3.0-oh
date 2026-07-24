# API 接口文档 - Index 应用

> 更新时间：2026-03-01
> 说明：本文档基于代码分析生成，与当前仓库对齐。

## 目录

- [1. 模块概述](#1-模块概述)
- [2. Index 控制器](#2-index-控制器)
- [3. Cdk 控制器](#3-cdk-控制器)
- [4. Duty 控制器](#4-duty-控制器)
- [5. 错误码说明](#5-错误码说明)

---

## 1. 模块概述

Index 应用提供前台页面、CDK兑换和GM活动管理功能。

**路由前缀**：`/index`

**控制器映射**：

| 控制器 | 路径 | 说明 |
|--------|------|------|
| [`Index`](#2-index-控制器) | `app/index/controller/Index.php` | 前台首页 |
| [`Cdk`](#3-cdk-控制器) | `app/index/controller/Cdk.php` | CDK兑换与购买 |
| [`Duty`](#4-duty-控制器) | `app/index/controller/Duty.php` | GM活动管理 |

---

## 2. Index 控制器

**控制器位置**：[`app/index/controller/Index.php`](../../app/index/controller/Index.php)

### 2.1 前台首页

- **路径**：`GET /index/index/index`
- **功能**：显示前台首页
- **鉴权**：无需登录

---

## 3. Cdk 控制器

**控制器位置**：[`app/index/controller/Cdk.php`](../../app/index/controller/Cdk.php)

### 3.1 CDK兑换页面

- **路径**：`GET /index/cdk/index`
- **功能**：显示CDK兑换页面
- **鉴权**：无需登录

### 3.2 CDK兑换提交

- **路径**：`POST /index/cdk/redeem`
- **功能**：提交CDK兑换
- **鉴权**：无需登录
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| cdk | string | 是 | CDK激活码 |
| uid | int | 是 | 玩家角色UID |
| qid | int | 是 | 区服QID |

- **响应示例**：
```json
// 成功
{
  "code": 1,
  "msg": "兑换成功",
  "data": {
    "id": 1,
    "cdk": "ABCD1234567890EF",
    "lv": 0,
    "uid": 1001,
    "qid": 1,
    "used_at": "2026-03-01 03:00:00"
  }
}

// 失败
{"code": 0, "msg": "CDK不存在"}
```

### 3.3 CDK购买页面

- **路径**：`GET /index/cdk/buy`
- **功能**：显示CDK购买页面（28元档位）
- **鉴权**：无需登录

### 3.4 CDK购买支付

- **路径**：`POST /index/cdk/pay`
- **功能**：创建CDK购买订单
- **鉴权**：无需登录
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| money | int | 是 | 金额（仅支持28） |
| paytype | string | 是 | 支付方式（alipay/wxpay） |

- **响应示例**：
```json
// 成功
{
  "code": 1,
  "msg": "下单成功",
  "data": {
    "orderid": "cdk2026030103000012345",
    "payurl": "https://..."
  }
}

// 失败
{"code": 0, "msg": "不支持的金额档位"}
```

---

## 4. Duty 控制器

**控制器位置**：[`app/index/controller/Duty.php`](../../app/index/controller/Duty.php)

### 4.1 活动页面

- **路径**：`GET /index/duty/index`
- **功能**：显示GM活动操作页面
- **鉴权**：无需登录

### 4.2 GM操作提交

- **路径**：`POST /index/duty/gmSub`
- **功能**：执行GM操作（封禁/解封/全服封号）
- **鉴权**：无需登录（需口令验证）
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| kouling | string | 是 | 操作口令 |
| playerid | int | 是 | 玩家角色ID |
| gmcmd | string | 是 | GM命令类型 |

- **gmcmd 命令类型**：

| 命令 | 说明 |
|------|------|
| forgmbid | 封禁/解封当前账号 |
| ungmforbid | 解封账号 |
| superforbiduser | 全服封号 |
| superunforbiduser | 全服解封 |

- **响应示例**：
```json
// 成功
{"code": 1, "msg": "封禁成功"}

// 失败
{"code": 0, "msg": "口令不正确"}
```

### 4.3 新活动页面

- **路径**：`GET /index/duty/new`
- **功能**：显示新GM活动页面
- **鉴权**：无需登录

### 4.4 新GM操作提交

- **路径**：`POST /index/duty/gmSub1`
- **功能**：执行新GM操作
- **鉴权**：无需登录（需口令验证）
- **请求参数**：同 `gmSub`

---

## 5. 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 操作失败（具体原因见msg字段） |
| 1 | 操作成功 |

### 常见错误信息

| 错误信息 | 说明 |
|----------|------|
| 请输入有效的CDK | CDK参数为空 |
| 请输入有效的角色UID | UID参数无效 |
| 请输入有效的区服QID | QID参数无效 |
| CDK不存在 | 数据库中未找到该CDK |
| 该CDK已被使用 | CDK状态为已使用 |
| 兑换失败，请稍后重试 | 数据库更新失败 |
| 不支持的金额档位 | 金额不是28元 |
| 不支持的支付方式 | 支付方式不是alipay或wxpay |
| 暂无可用支付通道 | 未配置有效支付通道 |
| 口令参数异常 | 口令参数未提供 |
| 口令不能为空 | 口令为空 |
| 口令不正确 | 口令不在预定义列表中 |
| 玩家信息有误 | playerid参数未提供 |
| 角色ID不能为空 | playerid为空 |
| 未查询到此角色信息 | 角色不存在 |
| 未查询到此角色账号信息 | 角色对应的用户不存在 |
| 操作异常 | gmcmd参数未提供 |
| 未定义操作 | gmcmd不在预定义列表中 |

---

## 6. 相关文档

- [API接口文档-公共](02-API接口文档-公共.md)
- [API接口文档-Admin](02-API接口文档-Admin.md)
- [API接口文档-Player](02-API接口文档-Player.md)
- [Duty活动模块](11-Duty活动模块.md)
- [安全机制说明](04-安全机制说明.md)
