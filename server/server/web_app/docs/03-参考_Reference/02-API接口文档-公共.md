# API 接口文档 - 公共（与当前代码对齐）

> 更新时间：2026-02-23  
> 说明：本文档仅描述当前仓库可确认的公共行为与回调链路，避免使用已过时的统一错误码假设。

## 1. 公共约定

### 1.1 响应形态（现状）

当前项目并非所有接口使用统一 JSON 包装，存在以下常见类型：

1. `json([...])` 返回对象
2. `json_encode([...])` 返回 JSON 字符串
3. 纯字符串（如支付回调返回 `success/fail`）
4. `view(...)` 返回 HTML 页面

因此调用方需按具体接口文档处理，不应假设统一 `code/msg/data`。

### 1.2 认证方式（现状）

- Admin / Agent：`Check` 中间件基于 Session + HMAC Token 校验
- Player：`PlayerAuth` 中间件基于 Session + 玩家 Token 校验
- 支付回调：由支付平台回调 + 签名校验，不走用户会话认证

---

## 2. 支付回调（核心公共接口）

控制器：`app/api/controller/Call.php`

### 2.1 异步回调入口

- 路径：`POST/GET /api/call/epay`
- 作用：支付平台异步通知，完成签名校验、发货、订单状态更新

返回值（字符串）：

- `success`：处理成功或已完成（幂等）
- `fail`：签名失败 / 防重放触发 / 发货失败 / 事务异常
- 其他提示文本：缺少订单号、订单不存在等

### 2.2 安全机制（P0）

由 `config/security.php -> pay_callback` 控制：

1. 防重放开关：`replay_protection_enabled`
2. 时间戳有效期：`timestamp_ttl`
3. 幂等开关：`idempotency_enabled`
4. 日志脱敏开关：`log_masking_enabled`
5. 脱敏字段：`mask_fields`

执行细节：

- 订单已支付直接返回 `success`（幂等短路）
- nonce 去重键：`pay_callback_nonce:{nonce}`
- 幂等锁键：`pay_callback_lock:{orderid}`
- 发货 + 更新状态在同一事务中完成

### 2.3 签名校验

由 `app/api/pay/EpayCore.php::verifyNotify()` 执行：

- 必须包含 `sign` 与 `out_trade_no`
- 通过本地 `getSign()` 重算签名并与回调 `sign` 全等比较

---

## 3. 同步回调（页面回跳）

控制器：`app/api/controller/Notify.php`

- 路径：`GET/POST /api/notify/epay`
- 用途：支付完成后的前端回跳展示
- 行为：验证回跳签名后组装 `findOrder` 并渲染页面
- 返回：HTML（`view('index', ...)`）

说明：订单最终一致性依赖异步回调 `/api/call/epay`，而非同步回跳页。

---

## 4. 调试与测试入口

### 4.1 `POST/GET /api/call/test`

- 用途：快速确认回调路由可达与日志可写
- 返回 JSON，包含日志文件路径、写入结果、请求参数等

### 4.2 `POST/GET /api/call/checkurl`

- 用途：输出当前构造的通知地址及最近订单摘要，用于联调排查

### 4.3 `POST/GET /api/call/epay1`

- 用途：测试/调试入口
- 生产环境限制：`APP_ENV=production` 时返回 `{"code":403,"msg":"此接口仅限测试环境使用"}`

---

## 5. 与支付相关的公共错误语义（按代码）

项目未统一维护完整“全局错误码表”，以下为支付链路可确认语义：

- 下单参数问题：`{"code":0,"msg":"参数..."}`
- 通道不可用：`{"code":0,"msg":"暂无可用通道，请稍后重试"}`
- 下单并发冲突：`{"code":0,"msg":"系统繁忙，请稍后重试"}`
- 购买日限超限：`{"code":0,"msg":"今日购买次数已达上限，请明日再来"}`
- 角色限购超限：`{"code":0,"msg":"当前角色已达到购买限制"}`
- epay1 生产禁用：`{"code":403,...}`

---

## 6. 相关文档

- `02-API接口文档-SDK.md`（SDK/API 业务接口）
- `04-安全机制说明.md`（认证与中间件安全）
- `05-业务逻辑说明.md`（支付/订单/佣金业务流）
