# API接口文档 - Call（支付回调）

> **版本**: v1.0
> **更新日期**: 2026-02-28
> **基础路径**: `/api/call/`
> **源码位置**: [`app/api/controller/Call.php`](../../app/api/controller/Call.php)

## 概述

Call模块负责处理支付平台的异步回调通知，是支付流程的关键环节。该模块实现了P0级安全加固，包含幂等控制、防重放攻击、事务一致性和日志脱敏等安全机制。

## 接口列表

### 1. 支付回调处理（核心接口）

**接口地址**: `GET/POST /api/call/epay`

**功能描述**: 接收支付平台的异步回调通知，验证签名后完成订单状态更新和游戏内发货。

**请求参数**:

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| out_trade_no | string | 是 | 商户订单号 |
| timestamp | int | 否 | 回调时间戳（用于防重放） |
| nonce | string | 否 | 随机字符串（用于防重放） |
| sign | string | 是 | 签名（由支付平台生成） |
| 其他参数 | mixed | - | 根据支付通道不同可能有额外参数 |

**响应格式**: 纯文本字符串

**成功响应**:
```
success
```

**失败响应**:
```
fail
缺少订单号
订单不存在
```

**处理流程**:

```
1. 接收回调参数 → 日志脱敏记录
2. 验证订单号存在性
3. 幂等检查（订单状态是否已支付）
4. 防重放检查（timestamp/nonce验证）
5. 获取分布式锁（防止并发回调）
6. 开启数据库事务
7. 验证支付签名
8. 执行发货逻辑（send方法）
9. 更新订单状态
10. 提交事务 → 返回success
```

---

### 2. 回调测试接口

**接口地址**: `GET/POST /api/call/test`

**功能描述**: 用于确认回调URL可以从公网访问，帮助排查网络连通性问题。

**请求参数**: 无

**响应示例**:

```json
{
    "status": "ok",
    "message": "回调接口正常",
    "time": "2026-02-28 10:30:00",
    "log_path": "/runtime/log/",
    "log_file": "/runtime/log/20260228_pay_callback.log",
    "log_writable": true,
    "log_exists": true,
    "write_result": "success",
    "get": {},
    "post": {}
}
```

---

### 3. 回调URL检查接口

**接口地址**: `GET/POST /api/call/checkurl`

**功能描述**: 查看最近订单信息和当前生成的回调URL，用于排查支付回调问题。

**请求参数**: 无

**响应示例**:

```json
{
    "message": "最近订单信息",
    "current_notify_url": "https://example.com:88/api/call/epay",
    "server_info": {
        "REQUEST_SCHEME": "https",
        "HTTP_HOST": "example.com",
        "SERVER_NAME": "example.com",
        "REMOTE_ADDR": "127.0.0.1"
    },
    "recent_orders": [
        {
            "orderid": "pay20260228103000001",
            "status": 1,
            "date": "2026-02-28 10:30:00",
            "channel": "epay"
        }
    ],
    "tip": "检查 current_notify_url 是否可以从公网访问"
}
```

---

### 4. 测试回调入口（仅开发环境）

**接口地址**: `GET/POST /api/call/epay1`

**功能描述**: 用于开发/测试环境调试支付回调逻辑。

**环境限制**: 仅允许非生产环境访问（`APP_ENV != production`）

**响应示例**:

生产环境访问时：
```json
{
    "code": 403,
    "msg": "此接口仅限测试环境使用"
}
```

---

## 安全机制

### P0级安全加固

#### 1. 幂等控制

防止重复回调导致重复发货：

```php
// 订单状态检查
if($findOrder['status'] == 1){
    return 'success'; // 已支付订单直接返回成功
}

// 分布式锁（Redis）
$lockKey = 'pay_callback_lock:' . $orderid;
Cache::store('redis')->set($lockKey, 1, 60); // 60秒锁
```

#### 2. 防重放保护

通过时间戳和nonce验证防止重放攻击：

| 机制 | 说明 | 配置项 |
|------|------|--------|
| 时间戳验证 | 检查回调时间与服务器时间差值 | `timestamp_ttl`（默认300秒） |
| Nonce验证 | 检查随机字符串是否已被使用 | Redis存储，有效期比TTL稍长 |

配置位置：`config/security.php`

```php
'pay_callback' => [
    'replay_protection_enabled' => true,
    'timestamp_ttl' => 300,
    'idempotency_enabled' => true,
    'log_masking_enabled' => true,
    'mask_fields' => ['password', 'key', 'token', 'secret', 'pay_key']
]
```

#### 3. 事务一致性

发货和订单状态更新在同一数据库事务中执行：

```php
Db::startTrans();
try {
    $send = $this->send($findOrder);  // 发货
    if($send) {
        $order->upOrderStatus($status_data);  // 更新订单
        Db::commit();
        return 'success';
    }
    Db::rollback();
    return 'fail';
} catch (\Exception $e) {
    Db::rollback();
    return 'fail';
}
```

#### 4. 日志脱敏

自动屏蔽敏感字段，防止敏感信息泄露：

```php
$maskFields = ['password', 'key', 'token', 'secret', 'pay_key'];
// 敏感字段替换为 ***MASKED***
```

---

## 发货逻辑（send方法）

### 处理流程

1. **用户验证**: 验证用户账号存在性
2. **角色绑定验证**: 验证角色绑定关系
3. **服务器验证**: 获取游戏服务器信息
4. **限购检查**: 
   - 日限（daylimit）: 使用Redis原子计数器
   - 角色限（rolelimit）: 数据库条件更新
5. **充值累计**: 更新角色累计充值金额
6. **游戏发货**: 通过GM接口发送奖励
   - 闲鱼（xianyu）: 游戏货币
   - VIP经验（vip）: VIP等级经验
   - 邮件（mailinfo）: 邮件附件奖励

### 限购机制

```php
// Redis原子计数器实现日限
$redisDayLimitKey = 'daylimit:' . $bindId . ':' . $itemId . ':' . date('Y-m-d');
$currentCount = Cache::store('redis')->inc($redisDayLimitKey);
```

---

## 错误码说明

| 返回值 | 说明 |
|--------|------|
| `success` | 处理成功 |
| `fail` | 处理失败（签名验证失败/发货失败/异常） |
| `缺少订单号` | 请求参数中缺少out_trade_no |
| `订单不存在` | 订单号在数据库中不存在 |

---

## 日志说明

### 日志路径

```
runtime/log/{Ymd}_pay_callback.log
```

### 日志格式

```
2026-02-28 10:30:00 - 收到支付回调 GET: {...} POST: {...}
2026-02-28 10:30:00 - 解析参数: {...}
2026-02-28 10:30:00 - 签名验证结果: 成功/失败
2026-02-28 10:30:00 - 发货结果: ...
2026-02-28 10:30:00 - 订单更新成功
```

---

## 注意事项

1. **回调URL配置**: 确保回调URL（`:88/api/call/epay`）可从支付平台服务器访问
2. **防火墙配置**: 开放支付平台服务器IP的访问权限
3. **SSL证书**: 如果使用HTTPS，确保证书有效
4. **日志监控**: 定期检查回调日志，及时发现异常
5. **并发处理**: 系统已实现分布式锁，可安全处理并发回调
6. **测试环境**: `epay1`接口在生产环境自动禁用

---

## 相关文档

- [API接口文档 - Pay支付](02-API接口文档-Pay.md)
- [API接口文档 - 公共](02-API接口文档-公共.md)
- [安全机制说明](04-安全机制说明.md)
