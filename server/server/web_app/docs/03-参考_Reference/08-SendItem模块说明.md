# SendItem 模块说明（源码对齐版）

> 更新时间：2026-03-20  
> 控制器：`app/player/controller/SendItem.php`  
> 服务：`app/player/service/GmService.php`

## 1. 模块定位

SendItem 属于 Player CDK 授权控制台能力，提供：

1. 物品发放
2. 仙玉充值
3. 区组切换

入口路由（显式）：

- `GET /player/cdk/senditem`
- `POST /player/cdk/senditem/getItemList`
- `POST /player/cdk/senditem/prepareOp`
- `POST /player/cdk/senditem/sendItem`
- `POST /player/cdk/senditem/rechargeXianyu`
- `POST /player/cdk/senditem/switchServer`

## 2. 前置条件

必须同时满足：

1. 已通过 Player 登录鉴权（`PlayerAuth`）
2. 会话中存在 CDK 标记（`getSession('cdk')`）
3. 已选择区组（`getSession('serverid')`）

否则返回 `请先完成CDK授权` 或 `请先选择区组`。

## 3. 物品列表来源（当前真值）

当前 `GmService::getItemList()` 仅读取：

- `public/txt/itemid.txt`

说明：

- 文档历史中提到的 `ccs/*.txt` 为旧链路（`login/Auth.php`）兼容逻辑，不是 Player SendItem 主链路
- 解析支持分隔符：`;` `,` `|` `TAB` 或空格
- 支持注释行（`#` / `//`）

## 4. 安全机制

## 4.1 item_token 机制

`sendItem` 不直接信任裸 `itemId`：

1. `prepareOp(action=sendItem)` 可接收前端传的数字 itemId 并生成 `item_token`
2. `sendItem` 仅接受 `item_token`
3. `parseItemToken` 校验：
   - 结构合法
   - 未过期
   - HMAC 签名正确
   - 物品 ID 在白名单中

## 4.2 操作签名

由 `computeOpSig/validateOpSignature` 完成：

- 请求需带 `op_ts` 与 `op_sig`
- 签名超时取 `config('player.signature_timeout')`
- 秘钥为 `player.op_secret_salt`（未配置会拒绝）

## 4.3 参数约束

- 物品数量：`1 ~ 9999`
- 仙玉数量：`1 ~ 99999999`

## 5. 发送流程

## 5.1 `sendItem`

1. 校验会话与区组
2. 解析并校验 `item_token`
3. 校验数量
4. 校验 `op_sig`
5. 调用 `Gm::addsuperitem`
6. 若失败，自动尝试 `Gm::mail` 邮件补发

返回：

- 成功：`code=1`
- 失败：`code=0` + 具体错误

## 5.2 `rechargeXianyu`

1. 校验会话与区组
2. 校验数量与签名
3. 调用 `Gm::addqian`

## 5.3 `switchServer`

1. 校验会话
2. 校验 `server_id`
3. 查 `ServerService::getServerById`
4. 更新会话：
   - `serverid`
   - `servername`
   - `groupname`

## 6. 依赖关系

1. `ServerService`：区组列表与区组详情
2. `GmService`：签名、白名单、GM命令封装
3. `app/gm/Gm.php`：底层命令执行
4. `player/common.php`：统一 Session 与 CSRF

## 7. 常见失败原因

1. `OP_SECRET_SALT` 未配置（签名链路直接失败）
2. `item_token` 过期或签名错误
3. 物品 ID 不在白名单
4. 区组会话缺失或区组数据无效
5. GM 命令执行失败（会尝试邮件补发）

## 8. 与历史口径差异

1. 主链路物品源已是 `public/txt/itemid.txt`，不是 `ccs/*.txt`
2. SendItem 控制器主链路使用 `GmService`，而非 `login/Auth` 的历史实现
3. 当前安全链路强依赖 `item_token + op_sig`
