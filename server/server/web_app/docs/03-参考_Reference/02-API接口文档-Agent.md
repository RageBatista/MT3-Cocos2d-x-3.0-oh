# API 接口文档 - Agent 应用

> 更新时间：2026-04-10  
> 对齐来源：`app/agent/controller/*.php`、`app/middleware/Check.php`、`app/model/UserOrder.php`

## 1. 应用总览

Agent 应用主要用于代理商后台（下级代理管理、玩家管理、订单查看、提现申请）。

路由可达方式：

1. 未在 `route/app.php` 显式注册 Agent 业务路由；
2. 通过 ThinkPHP 多应用默认控制器动作路由可达：`/agent/{controller}/{action}`。

鉴权约束：

1. 全局 `Check` 中间件对 `agent` 应用强制鉴权；
2. 未登录或会话失效会被重定向/登出；
3. Agent 控制器动作大多依赖 `BaseController` 注入的 `myAdmin`。

## 2. Index 控制器

**控制器位置**：[`../../app/agent/controller/Index.php`](../../app/agent/controller/Index.php)

### 2.1 退出登录

- 路径：`GET /agent/index/logout`
- 行为：清理代理会话并跳转登录页

### 2.2 首页

- 路径：`GET /agent/index/index`
- 行为：渲染代理后台首页视图

### 2.3 个人信息页

- 路径：`GET /agent/index/my`
- 行为：渲染个人信息页

### 2.4 编辑个人信息（维护关闭）

- 路径：`POST /agent/index/editMy`
- 当前状态：返回维护提示，改密逻辑未开放
- 返回示例：`{"code":0,"msg":"系统维护中：改密功能暂时未开启..."}`

### 2.5 申请提现

- 路径：`POST /agent/index/applyWithdrawal`
- 关键规则：
  1. 需先配置收款信息（支付宝或 USDT）
  2. 存在待审核提现时不可重复提交
  3. 最低提现金额 200 元
  4. 提交后将 `total_commission` 转移到 `pending_withdrawal`

### 2.6 旧结算入口（兼容保留）

- 路径：`GET /agent/index/jiesuan`
- 当前状态：已废弃，仅返回“请使用申请提现”

### 2.7 工作台统计

- 路径：`GET /agent/index/worker`
- 行为：展示玩家数、代理数、订单流水、佣金统计、创建下级资格判断

## 3. Agent 控制器

**控制器位置**：[`../../app/agent/controller/Agent.php`](../../app/agent/controller/Agent.php)

### 3.1 代理列表页

- 路径：`GET /agent/agent/list`
- 行为：渲染下级代理列表页

### 3.2 代理列表数据

- 路径：`GET|POST /agent/agent/list_table`
- 入参（可选）：`username`、`invite`、`lv`、分页/排序参数
- 行为：
  1. 仅返回当前代理树下级数据（`agent_tree like %@当前ID@%`）
  2. 批量计算直属/下级玩家数与流水
  3. 输出佣金、创建资格、上级名称等扩展字段
- 返回：`jsonp({"total":...,"rows":[...]})`

### 3.3 新增下级代理页

- 路径：`GET /agent/agent/add`
- 行为：渲染新增页面并返回 `checkCanCreateAgent` 结果

### 3.4 提交新增下级代理

- 路径：`POST /agent/agent/addSubmit`
- 关键规则：
  1. 仅当直属玩家流水达标时允许创建下级（通过 `CommissionService` 判断）
  2. `username/password` 要求 6-18 位字母+数字
  3. `invite` 要求 4-8 位字母+数字且唯一
  4. 新增代理固定分成 `fencheng = 70`

### 3.5 编辑代理页

- 路径：`GET /agent/agent/edit?id={id}`
- 行为：读取代理资料并渲染编辑页

### 3.6 提交编辑代理（维护关闭）

- 路径：`POST /agent/agent/editSubmit`
- 当前状态：返回维护提示，编辑/改密逻辑未开放

### 3.7 客服配置页

- 路径：`GET /agent/agent/kefu`
- 行为：展示客服/收款配置（QQ、群链接、支付宝、USDT）

### 3.8 提交客服配置

- 路径：`POST /agent/agent/kefuSubmit`
- 行为：保存客服与收款信息（JSON）

## 4. Player 控制器

**控制器位置**：[`../../app/agent/controller/Player.php`](../../app/agent/controller/Player.php)

### 4.1 玩家列表页

- 路径：`GET /agent/player/list`
- 行为：渲染直属玩家页并加载代理筛选列表

### 4.2 玩家列表数据

- 路径：`GET|POST /agent/player/list_table`
- 入参（可选）：`username`、`lastagent`、分页参数
- 行为：返回当前代理可见范围内的玩家列表，并附 `last_username`

### 4.3 玩家编辑页

- 路径：`GET /agent/player/edit?id={id}`
- 行为：渲染玩家编辑页

### 4.4 提交玩家编辑（维护关闭）

- 路径：`POST /agent/player/editSubmit`
- 当前状态：返回维护提示，玩家改密逻辑未开放

### 4.5 绑定列表页

- 路径：`GET /agent/player/bindList`
- 入参：`selected`（`1` 表示查看全量）

### 4.6 绑定列表数据

- 路径：`GET|POST /agent/player/bind_list_table`
- 入参（可选）：`username`、`playerid`、`playername`、`selected`
- 行为：
  1. `selected=1` 时走全量绑定查询
  2. 其他情况按当前代理可见范围查询

### 4.7 修改玩家状态

- 路径：`POST /agent/player/status`
- 权限：`myAdmin['qx'] >= 1`
- 行为：
  1. 切换账号状态（封禁/解封）
  2. 封禁时会遍历已绑定角色并执行 `GM kick`
  3. 记录代理操作日志

## 5. Order 控制器

**控制器位置**：[`../../app/agent/controller/Order.php`](../../app/agent/controller/Order.php)

### 5.1 订单列表页

- 路径：`GET /agent/order/list`
- 入参：`status`（默认 `all`）

### 5.2 订单列表数据

- 路径：`GET|POST /agent/order/list_table`
- 入参（可选）：
  - `status`：`all|yes|tuikuan|no`
  - `orderid`、`user`、分页排序参数
- 行为：
  1. 委托 `UserOrder::getOrderList()` 查询
  2. 仅允许查看当前代理及最多两级下级代理订单
  3. 返回中补充 `agent_name`

## 6. 返回约定

页面数据接口通常返回 JSONP：

```json
{"total": 123, "rows": []}
```

动作接口通常返回 `notify()` 结构（`code` + `msg`）：

- `code = 1`：成功
- `code = 0`：失败/业务拒绝

## 7. 已知限制

1. `editMy`、`editSubmit`、`player/editSubmit` 当前均为维护关闭状态。  
2. Agent 控制器多数动作未单独做 `checkToken()`，当前主要依赖登录态与业务规则控制。  
3. 路由主要依赖默认控制器动作映射，文档中的 HTTP 方法以前端实际调用和控制器取参方式为准。

## 8. 相关文档

- [API接口文档-公共](./02-API接口文档-公共.md)
- [API接口文档-Admin](./02-API接口文档-Admin.md)
- [API接口文档-Player](./02-API接口文档-Player.md)
- [安全机制说明](./04-安全机制说明.md)
- [业务逻辑说明](./05-业务逻辑说明.md)
