# API 接口文档 - Call（支付回调，源码对齐版）

> 更新时间：2026-03-23  
> 控制器：`app/api/controller/Call.php`  
> 基础路径：`/api/call/*`

## 1. 核心接口

## 1.1 `epay`

- 路径：`GET/POST /api/call/epay`
- 用途：支付平台异步回调处理
- 返回：字符串（`success` / `fail` / 错误文本）

处理关键点：

1. 订单存在性校验
2. 幂等短路（已支付直接 `success`）
3. 防重放（`timestamp/nonce`）
4. 幂等锁（`pay_callback_lock:{orderid}`）
5. 验签（`EpayCore::verifyNotify`）
6. 发货 + 订单状态更新事务一致

## 2. 调试接口

## 2.1 `test`

- 路径：`GET/POST /api/call/test`
- 作用：回调探针/日志写入验证

## 2.2 `checkurl`

- 路径：`GET/POST /api/call/checkurl`
- 作用：查看当前通知地址与最近订单摘要

## 2.3 `epay1`

- 路径：`GET/POST /api/call/epay1`
- 作用：测试回调入口（非生产环境）

## 3. 安全开关说明

## 3.1 `test/checkurl`

受 `config/security.php` 控制：

- `debug_endpoints.pay_callback_probe_enabled`
- `debug_endpoints.pay_callback_probe_local_only`

未开启时返回 404。

## 3.2 `epay1`

`APP_ENV=production` 时返回：

```json
{"code":403,"msg":"此接口仅限测试环境使用"}
```

## 4. 常见返回语义

- `success`：处理成功或幂等短路
- `fail`：验签失败/防重放触发/发货失败/事务异常
- `缺少订单号`：未提供 `out_trade_no`
- `订单不存在`：订单号未命中

## 5. 日志

默认记录到：

- `runtime/log/{Ymd}_pay_callback.log`

记录内容包含：

1. 脱敏请求参数
2. 验签结果
3. 发货结果
4. 事务处理结果

## 6. 相关文档

- `02-API接口文档-公共.md`
- `02-API接口文档-SDK.md`
- `04-安全机制说明.md`
