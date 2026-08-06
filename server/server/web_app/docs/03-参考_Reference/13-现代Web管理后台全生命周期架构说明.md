# 现代 Web 管理后台全生命周期架构说明（源码对齐版）

> 更新时间：2026-04-10（补充 PermissionGuard 细粒度权限校验说明）
> 适用范围：`mt3_web`（ThinkPHP 8.x 多应用单体）
> 对齐基线：`00-源码静态分析与对齐基线.md`
> 说明：本文以"现代 Web 管理后台"五层能力模型为框架，所有结论均以当前仓库真实实现为准，不把未落地能力写成既成事实。

---

## 1. 执行摘要

当前 `mt3_web` 的真实形态是一个 **ThinkPHP 8 多应用服务化单体**，在 P3 调优批次中完成了若干现代化加固：

| 维度 | P3 前状态 | P3 后状态 |
|------|----------|----------|
| Token 机制 | `hash.timestamp` 无吊销 | `hash.timestamp.version` + Redis 版本号，改密/封号立即失效 |
| 限流原子性 | Redis GET→SET 竞争窗口 | Lua 脚本原子 INCR+EXPIRE，Sorted Set 滑动窗口 |
| 请求追踪 | 无 trace_id | `TraceId` 中间件注入 UUID v4，日志全链路可关联 |
| 缓存安全 | 无空值保护，穿透直查 DB | `__NOT_FOUND__` 空值标记 60s，防缓存穿透 |
| 敏感字段 | playerInfo 含 password 字段 | getPlayerInfo() 返回前过滤 5 类敏感字段 |
| 磁盘安全 | 头像上传无配额 | 500MB 配额检查 + 超限警告日志 |
| 配置安全 | OP_SECRET_SALT = CHANGE_ME | 64 字符强随机十六进制盐值 |

系统整体仍属"服务化单体 + 代理层治理 + Redis 锁 + 状态机"架构，而非云原生微服务。

---

## 2. 现代能力映射矩阵

| 能力维度 | 现代后台常见实现 | 项目当前实现 | 结论 |
|---------|-------------|------------|------|
| **网关层** | API Gateway、统一鉴权、熔断、灰度、限流 | 外部 Nginx/LB + 应用内中间件链 + Redis Lua 限流 | 网关职责主要在部署层；应用层限流已原子化 |
| **登录鉴权** | JWT、OAuth2/OIDC、SSO、Refresh Token | Session + HMAC Token（含版本号）+ CSRF + 二次验证 + Bind Ticket | 具备基础认证与会话安全；Token 现支持主动吊销 |
| **全链路追踪** | Trace ID / OpenTelemetry | TraceId 中间件（UUID v4）+ 日志 trace_id 字段 | P3 新增，覆盖 player 模块全链路 |
| **业务服务** | 微服务拆分、消息驱动 | ThinkPHP 多应用单体 + `app/service/*` + 外部支付/JMX | 服务化单体，不是微服务网格 |
| **分布式事务** | XA、Saga、Seata、Outbox | 本地事务 + Redis 原子锁 + 状态机 + 补偿/幂等 | 工程化一致性控制 |
| **数据访问** | ORM、Repository、读写分离 | ThinkPHP Model + Query Builder + 原生 SQL + Redis/File 多级缓存 | 混合数据访问层 |
| **前端形态** | SPA / SSR / 组件化状态管理 | ThinkPHP 模板 SSR + jQuery + bootstrap-table + fetch | 后台操作效率优先的传统 SSR 架构 |

---

## 3. 请求全生命周期

### 3.1 完整请求链路

```
浏览器 / 运维终端
  ↓ HTTPS
Nginx / 负载均衡器
  ↓ 重写 → public/index.php
Route 匹配（route/app.php、route/player.php）
  ↓
全局中间件链
  ├── CheckRequestCache（请求缓存检查）
  ├── SessionInit（会话启动）
  ├── Check（管理员鉴权 / 扫描拦截）
  └── PermissionGuard（细粒度权限点校验，基于 config/permission.php）
  ↓
Player 应用中间件链（按注册顺序）
  ├── TraceId     ← P3新增：生成/透传 UUID v4 trace_id，注入响应头
  ├── PlayerSecurity  ← Redis Lua 滑动窗口限流（Sorted Set）
  ├── PlayerAuth   ← Session/Token校验 + Null Object Cache防穿透
  └── CsrfToken   ← AJAX Lua原子化 + 普通表单单次消费
  ↓
Controller（ProfileController / OrderController 等）
  ↓
Service / Model / Db
  ↓
MySQL / Redis / 文件缓存 / JMX / 第三方支付
  ↓
JSON / HTML / 文本响应（响应头携带 X-Request-ID）
```

### 3.2 中间件执行时序与责任边界

| 层级 | 中间件 | 核心职责 | 失败行为 |
|------|--------|---------|---------|
| G0 | `CheckRequestCache` | 请求缓存命中检查 | 命中则直接返回缓存响应 |
| G1 | `SessionInit` | 启动会话 | - |
| G2 | `Check` | admin/agent 会话鉴权；扫描请求拦截 | 未认证重定向登录页 |
| G3 | `PermissionGuard` | 按 `config/permission.php` 规则校验管理员类型权限 | 403 + JSON 错误响应 |
| L0 | `TraceId` | 生成 UUID v4 trace_id；`$_SERVER['TRACE_ID']` 全局注入；响应头回写 X-Request-ID | 不阻断，降级生成本地 trace_id |
| L1 | `PlayerSecurity` | Redis Sorted Set 滑动窗口（ms级）限流；登录动作 5次/5min；全局 60次/min | 超限返回 429；Redis 不可用降级文件锁 |
| L2 | `PlayerAuth` | Session 三元组校验；Token 版本号验证；Null Object Cache；敏感字段在 Player 模型层已过滤 | 401/403 或重定向登录页 |
| L3 | `CsrfToken` | GET 生成/复用 Token；POST 验证（`hash_equals` 防时序攻击）；AJAX 不消费 Token | 403 或重定向 |

> 说明：G 层为全局中间件（所有应用），L 层为 Player 应用专属中间件。

---

## 4. 网关层：负载均衡与边界安全

### 4.1 真实网关边界

应用本身没有内建 API Gateway；真实入口由以下层级组成：

1. `public/.htaccess` — Apache 场景路径重写
2. `route/app.php`、`route/player.php` — 显式路由
3. `config/route.php` — `url_route_must` 取决于环境变量 `ROUTE_MUST`，生产默认强制路由
4. `Route::miss()` — 未命中统一 404

网关级统一限流、灰度、熔断不在仓库内实现，由 Nginx/WAF/SLB 承担。

### 4.2 负载均衡约束

| 约束项 | 原因 | 解决方案 |
|--------|------|---------|
| Session 文件存储 | `config/session.php: type=cache, store=file` | 改 Redis 共享存储 或 Nginx IP Hash 粘滞 |
| CSRF Token 绑定 Session | `CsrfToken.php` 依赖 Session 键 `csrf_token` | 同上 |
| Token 版本号 Redis 存储 | `token_version:{userId}` 键，P3 新增 | Redis HA 保障（Sentinel/Cluster） |

多节点部署时，必须解决 Session 共享，否则典型故障：登录后跳回登录页、CSRF 随机失败。

### 4.3 应用层限流实现（P3 升级）

#### 登录频率限制（`common.php::checkLoginRateLimit()`）

```
Redis Lua 脚本原子执行（消除 GET→SET 竞争窗口）：
  INCR login_limit:{ip}       # 原子计数
  EXPIRE（首次设置）           # TTL 随计数原子绑定
  → 达到 maxAttempts(5) 后：
      SET login_limit:{ip}:locked {expireTimestamp} EX {lockTime}
```

**降级路径**：Redis 不可用 → 文件锁（LOCK_EX），文件模式增加了 `window_start` 字段防误判。

#### 请求频率监测（`PlayerSecurity.php::checkRequestRateLimit()`）

```
Redis Sorted Set 毫秒级滑动窗口（P3 升级前为序列化数组存储）：
  ZREMRANGEBYSCORE req_rate:{ip} 0 (now-60000ms)   # 移除过期
  ZCARD → 当前窗口计数
  ZADD req_rate:{ip} {now} {now}_{random}           # 防 ZADD 覆盖
  PEXPIRE req_rate:{ip} 61000ms                     # key 自动过期
```

**优势**：精度从秒级提升至毫秒级；Redis Sorted Set 天然按 score 排序，O(log N) 清理。

### 4.4 IP 安全机制

```php
// getPlayerIP()：仅信任代理才读取 X-Forwarded-For
// 防止客户端直接伪造头部绕过限流
$trustedProxies = config('player.trusted_proxies', ['127.0.0.1', '10.0.0.0/8', ...]);
if (isTrustedProxy($remoteIp, $trustedProxies)) {
    $ip = parseXForwardedFor();
}

// isMaliciousIP()：双键 Redis 设计
// ip_blacklist:{ip}   → 精确匹配（TTL 精确）
// ip_blacklist        → 批量黑名单（哈希表，支持 CIDR）
```

---

## 5. 鉴权层：Token 机制与会话管理

### 5.1 玩家 Token 机制（P3 升级）

**格式升级（向下兼容）**：

```
旧格式（2段）：sha256(uid|username|timestamp|salt) . "." . timestamp
新格式（3段）：sha256(uid|username|timestamp|version|salt) . "." . timestamp . "." . version
```

**版本号机制**（`token_version:{userId}`）：

```
生成 Token：             读取/初始化 Redis version（TTL 30天）→ 嵌入 Token
验证 Token（新格式）：   校验 hash → 校验 Token 中 version === Redis current_version
主动吊销（改密/封号）：  invalidatePlayerTokens(userId) → Redis version +1 → 清除 player_user 缓存
旧格式兼容：             无 version 段时跳过版本校验，记录 info 日志
```

**关键安全属性**：
- 改密/重置密码后旧 Token **立即失效**（不等 24h 超时）
- Redis 不可用时降级：`_getOrCreateTokenVersion()` 返回 `0`，跳过版本校验（可用性优先）
- 使用 `hash_equals()` 防时序攻击

**触发吊销的场景**（`invalidatePlayerTokens()`）：
- `Profile::updatePassword()` — 主动改密
- `Auth::doResetPassword()` — 邮件重置密码
- 管理员后台封号（需调用此函数，按需扩展）

### 5.2 管理员 Token 机制

```
hash_hmac('sha256', adminId + username + passwordHash, ADMIN_AUTH_SECRET_KEY)
```

特点：密码变更后 Token 自动失效（因 password hash 变化）。生产环境 `ADMIN_AUTH_SECRET_KEY` 未配置时直接拒绝高权限鉴权。

### 5.3 Session 键空间设计

```
player_{key}            ← 玩家模块命名空间（PLAYER_SESSION_PREFIX）
  player_id             → 玩家账号/角色 ID
  player_username       → 用户名
  player_token          → hash.timestamp.version 三段格式
  player_auth_time      → 认证时间戳
  player_login_mode     → 'account' | 'cdk'
  player_serverid       → 游戏服 ID
  player_admin_id       → 管理员 ID（双角色兼容）
  player_admin_token    → 管理员签名令牌
csrf_token              ← 独立命名空间（不加 player_ 前缀）
```

**多应用会话隔离**：`player_` 前缀隔离玩家与管理员 Session Key，防止跨模块数据污染。

### 5.4 CSRF 防护

```
GET 请求：
  generateToken()
    → bin2hex(random_bytes(32))
    → 同步写 Session::csrf_token + Session::__csrf_token__（双键兼容）

POST/PUT/DELETE 请求：
  verifyToken($token)
    → hash_equals(sessionToken, requestToken)   ← 防时序攻击
    → 验证失败：403 / 重定向

AJAX 请求特殊处理：
  验证通过后不消费 Token（不删除 Session）
  因为 SPA/AJAX 通常在 meta 标签读一次后复用

普通表单：
  验证通过后单次消费（Session::delete + generateToken(true)）防重放
```

### 5.5 CDK 授权链路（角色级会话）

CDK 授权链路中 `player_id` 存储的是**游戏角色 ID**（非账号 ID），这是区别于账号登录的核心：

```
首次 CDK 授权：
  cdkAuth(roleId, cdk, serverId, authPass)
    → UPDATE cdks SET uid=roleId, status=1 WHERE id=? AND status=0 AND uid=0  // 原子占用
    → setPlayerSession(roleId, ...)   // Session.id = roleId

已有授权登录：
  cdkExistingAuth(roleId, authPass)
    → 查询 cdks WHERE uid=roleId AND status=1
    → 校验 authPass
    → setPlayerSession(roleId, ...)
```

`ensurePlayer()` / `resolveSessionRoleId()` / `resolveSessionUserId()` 等辅助方法处理账号/角色 ID 双语义。

### 5.6 Bind Ticket（角色绑定凭据）

`BindTicketService` 是项目中最接近 OAuth2 授权码语义的组件：
- 票据只落库哈希，不保存明文
- 含 `nonce + issued_at + expires_at + 签名（HMAC-SHA256）`
- 支持单次消费、使用计数、宽限期

仅服务于角色绑定场景，**不是通用 OAuth2 授权服务器**。

---

## 6. 业务逻辑层：服务化单体架构

### 6.1 代码组织边界

```
Controller  → HTTP 输入解析、视图/接口分流、玩家身份确认
Service     → 跨模型编排、外部系统调用、复杂业务状态机
Model       → 实体映射、状态机封装、部分查询聚合
外部系统    → 支付平台（HTTP 回调）、JMX/GM（TCP/HTTP）
```

核心服务类：
- `app/player/service/AuthService.php` — 统一认证（P3 升级：版本号 Token）
- `app/service/TransferExecutionService.php` — 转区（跨系统准事务）
- `app/service/BindTicketService.php` — 角色绑定凭据
- `app/service/CacheLockService.php` — Redis 分布式锁封装
- `app/service/CommissionService.php` — 佣金分配

### 6.2 数据一致性策略

#### 支付链路（本地事务 + 幂等锁 + 状态机）

```
下单（pay/getpay）：
  1. SETNX pay_order_lock:{roleid}:{payid}    ← Redis 互斥锁
  2. 检查日限 / 角色限购
  3. DB::startTrans() → 写 user_order 表 → commit()

回调（api/Call::epay）：
  1. timestamp + nonce 防重放检查
  2. SETNX pay_callback_lock:{orderid}         ← 幂等锁
  3. 校验订单状态（只有 PENDING 才继续）
  4. DB::startTrans() → UserOrder::upOrderStatus() → commit()
  5. 触发 JMX 发货（DB 事务外，存在跨系统一致性风险）
```

**已知边界**：发货成功 + DB 提交失败 = 重复发货风险；通过幂等锁 + 日志补救降低概率。

#### 转区链路（分布式锁 + 补偿式一致性）

```
TransferExecutionService：
  1. SETNX transfer_execution_lock:{transferId}
  2. DB::startTrans() → 更新 user_transfer + user_bind
  3. if gm_migration_enabled：调用 GM 在线检查、备份、迁移、恢复
  4. 默认 binding_only 模式
```

**结论**：补偿式一致性，不是 XA/Saga 统一分布式事务。

### 6.3 Redis 并发控制

| 锁键格式 | 用途 | 降级行为 |
|---------|------|---------|
| `pay_order_lock:{roleid}:{payid}` | 下单去重 | 失败拒绝下单 |
| `pay_callback_lock:{orderid}` | 回调幂等 | 失败跳过本次回调 |
| `transfer_execution_lock:{id}` | 转区互斥 | 失败拒绝执行 |
| `token_version:{userId}` | Token 吊销版本 ← P3新增 | Redis 不可用时版本返回 0，跳过版本校验 |

---

## 7. 数据交互层：ORM、查询优化与多级缓存

### 7.1 混合数据访问层

| 访问方式 | 代表场景 | 特点 |
|---------|---------|------|
| Model 继承 | `UserOrder`、`Transfer`、`Player` | 状态机封装、实体语义清晰 |
| `Db::name()` 查询构造器 | `user_bind`、`role` 联表 | 条件灵活、类型安全 |
| `Db::query()` 原生 SQL | CDK 查询、统计、批量场景 | 性能可控、兼容复杂查询 |

**重要数据特征**：`user_order.user` / `.item` 存储 JSON 字符串，导致订单归属查询必须用 `LIKE` 兼容数字/字符串格式 playerid，是性能瓶颈来源之一（`buildPlayerOrderWhere()`）。

### 7.2 缓存策略（三级）

```
L1: 请求内存（static $cache = []）
    → 权限列表等同一请求内多次访问的热点

L2: Redis（Cache::store('redis')）
    → 各类业务热点数据（TTL 30s ~ 30天）

L3: MySQL（最终数据源）
```

**P3 缓存穿透防护**（`PlayerAuth.php`）：

```php
$cached = Cache::get('player_user:' . $playerId);
if ($cached === '__NOT_FOUND__') {
    return redirect($loginRedirect);   // 命中空值标记，直接拦截
}
// ...查库...
if (!$playerInfo) {
    Cache::set('player_user:' . $playerId, '__NOT_FOUND__', 60);  // 写入空值缓存
}
Cache::set('player_user:' . $playerId, $playerInfo, 600);         // 正常缓存 600s
```

**关键缓存键**：

| 键名 | TTL | 用途 |
|------|-----|------|
| `player_user:{id}` | 600s / 60s(NOT_FOUND) | 玩家信息（含穿透防护）|
| `token_version:{userId}` | 30天（续期） | Token 吊销版本 |
| `player_roles:{userId}` | 3600s | 角色列表 |
| `login_limit:{ip}` | 动态（Lua INCR） | 登录频率计数 |
| `login_limit:{ip}:locked` | lockTime | 锁定状态 |
| `req_rate:{ip}` | 61000ms | 请求频率（Sorted Set）|
| `pay_channels:{type}` | 300s | 支付通道配置 |
| `admin:server:online:{s}:{p}` | 30s | JMX 在线人数 |
| `ip_blacklist:{ip}` | 动态 | 单 IP 封禁 |
| `ip_blacklist` | 动态 | 批量黑名单（CIDR 支持）|

### 7.3 缓存三防措施

| 问题 | 防护手段 |
|------|---------|
| **缓存穿透** | `__NOT_FOUND__` 空值缓存 60s（P3 新增）|
| **缓存击穿** | Redis `SETNX` 分布式锁；登录/下单路径已有锁保护 |
| **缓存雪崩** | `player_roles` 等 TTL 未加随机抖动（待优化）|

### 7.4 数据库连接管理

PHP-FPM 模型：每个 Worker 持有独立连接，无连接池中间件。高并发场景建议引入 ProxySQL / PgBouncer。

ThinkPHP 数据库配置（`config/database.php`）：
```php
'rw_separate'     => false, // 当前未启用读写分离
'deploy'          => 0,     // 集中式部署
'break_reconnect' => false, // 无断线重连
```

---

## 8. 响应输出层：标准化封装与前端渲染

### 8.1 响应格式约定

```php
// 标准 JSON 响应（表单/操作类）
return json([
    'code' => 1,         // 1=成功, 0=失败, 401=未认证, 403=无权限, 429=限流
    'msg'  => '操作成功',
    'data' => $payload,
]);

// 列表分页响应（bootstrap-table 格式）
return json([
    'total' => $total,
    'rows'  => $list,
]);
```

P3 建议（未强制落地）：响应中可加入 `trace_id` 字段（已在响应头 `X-Request-ID` 中），方便前端日志关联。

### 8.2 敏感字段过滤（P3 新增）

`Player::getPlayerInfo()` 返回前过滤：

```php
$sensitiveFields = ['password', 'pay_password', 'secret_key', 'pay_key', 'salt'];
foreach ($sensitiveFields as $field) {
    unset($playerInfo[$field]);
}
```

`$request->player` 注入到控制器前已完成过滤，视图层无需二次处理。

### 8.3 前端渲染架构

当前以 **SSR（服务端模板渲染）** 为主：

1. `ThinkPHP View` 负责首屏 HTML（含 CSRF Token 注入 `<meta>` 标签）
2. `jQuery/fetch` 负责表单和局部操作
3. `bootstrap-table` 负责后台分页列表（服务端分页）
4. `auth.css/player.css` 统一视觉风格

**已落地前端优化**：
- 首屏 SSR，无需等待 JS 框架
- 服务端分页，避免全量数据传输
- 物品列表按需拉取（选区后才加载）
- JMX 在线探针 30s 缓存，减少后端压力
- 移动端优先样式（玩家端）

**前端约束**：
- 非 SPA，无统一前端路由
- 响应格式存在差异（列表/操作/兼容接口）
- 部分页面存在内联脚本，工程化程度有限
- 外部 CDN jQuery 存在供应链风险

---

## 9. 全链路追踪（P3 新增）

### 9.1 TraceId 中间件

```php
// TraceId.php — 注册为 Player 模块第一个中间件
class TraceId {
    public function handle($request, $next) {
        // 透传或生成 UUID v4
        $traceId = $this->parseOrGenerate($request->header('x-request-id'));
        $request->traceId = $traceId;
        $_SERVER['TRACE_ID'] = $traceId;          // 全局注入

        $response = $next($request);
        $response->header(['X-Request-ID' => $traceId]);  // 响应头回写

        return $response;
    }
}
```

### 9.2 日志关联

`logPlayerAction()` 自动携带 `trace_id`：

```json
{
  "trace_id": "550e8400-e29b-41d4-a716-446655440000",
  "player_id": 12345,
  "action": "update_profile",
  "detail": "更新个人资料",
  "ip": "1.2.3.4",
  "created_at": "2026-03-31 20:00:00"
}
```

同一次请求的所有日志行共享 `trace_id`，可直接用于问题定位。

---

## 10. 风险与调优矩阵

### 10.1 已通过 P3 修复的风险

| 原风险 | 修复方案 | 文件 |
|--------|---------|------|
| 🔴 Token 无吊销，改密 24h 内旧 Token 有效 | Redis 版本号机制，立即失效 | `common.php`, `AuthService.php` |
| 🔴 限流原子性（GET→SET 竞争） | Lua 脚本原子操作 | `common.php`, `PlayerSecurity.php` |
| 🟠 playerInfo 含 password 等敏感字段 | `getPlayerInfo()` 过滤 5 类字段 | `Player.php` |
| 🟡 缓存穿透（不存在 ID 频繁查库） | `__NOT_FOUND__` 空值缓存 60s | `PlayerAuth.php` |
| 🟡 无全链路追踪 | TraceId 中间件 + 日志 trace_id | `TraceId.php`, `common.php` |
| 🟡 头像上传无磁盘配额 | 500MB 配额检查 | `Profile.php` |
| 🟡 OP_SECRET_SALT 弱默认值 | 64 字符强随机盐值 | `.env` |

### 10.2 仍需关注的风险

| 风险 | 等级 | 建议 |
|------|------|------|
| Session 文件存储，多节点无法粘滞 | 🔴 | 迁移至 Redis 共享 Session |
| Redis 对支付/转区锁是关键依赖 | 🔴 | Redis Sentinel/Cluster 保障 HA |
| player_roles 等 TTL 无随机抖动 | 🟡 | 加 `rand(0, 300)` 秒抖动 |
| 发货成功但 DB 失败时重复发货风险 | 🟡 | 引入 Outbox 表或补偿日志 |
| 外部 CDN jQuery（供应链风险） | 🟢 | 迁移至本地静态资源 |
| `login/*` 历史链路与 `player/*` 并存 | 🟢 | 逐步收敛，减少维护成本 |

### 10.3 演进建议

仅在以下场景才建议引入 JWT/OAuth2 或微服务拆分：
1. 需对接多个外部前端、开放平台或第三方合作方
2. 需要统一 SSO / 授权委托 / 客户端注册
3. 需要跨团队独立发布支付、账号、活动、GM 平台

在此之前，继续扎实"服务化单体 + 代理层治理 + Redis 锁 + 状态机"通常比贸然拆微服务更稳妥。

---

## 11. 关键代码定位

| 主题 | 关键文件 |
|------|---------|
| 路由与入口 | `route/app.php`、`route/player.php`、`config/route.php` |
| 中间件链 | `app/player/middleware.php`（TraceId → PlayerSecurity → PlayerAuth → CsrfToken）|
| 全链路追踪 | `app/player/middleware/TraceId.php` ← P3 新增 |
| 玩家公共鉴权 | `app/player/common.php`（Token 生成/验证/吊销）|
| Token 版本机制 | `common.php::_getOrCreateTokenVersion()` / `invalidatePlayerTokens()` |
| Player 安全链 | `PlayerSecurity.php`、`PlayerAuth.php`、`CsrfToken.php` |
| 认证服务 | `app/player/service/AuthService.php` |
| 绑定票据 | `app/service/BindTicketService.php` |
| 支付下单/回调 | `app/api/controller/Pay.php`、`Call.php`、`app/model/UserOrder.php` |
| 转区服务 | `app/service/TransferExecutionService.php` |
| 敏感字段过滤 | `app/player/model/Player.php::getPlayerInfo()` ← P3 新增 |
| 磁盘配额 | `app/player/controller/Profile.php::uploadAvatar()` ← P3 新增 |
| Cookie/Session/Cache | `config/cookie.php`、`config/session.php`、`config/cache.php` |
| 全局鉴权 | `app/middleware/Check.php` |

---

## 12. 相关文档

1. `01-项目架构说明.md`
2. `04-安全机制说明.md`（P3 同步更新）
3. `09-前后端架构与全链路实现审计.md`
4. `12-转区服务说明.md`
5. `04-解释_Explanation/01-安全修复记录总览.md`
6. `04-解释_Explanation/02-P3调优修复说明.md` ← P3 新增专项文档
