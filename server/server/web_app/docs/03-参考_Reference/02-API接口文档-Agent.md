# API 接口文档 - Agent 应用

> 更新时间：2026-02-23
> 说明：本文档基于代码分析生成，与当前仓库对齐。

## 目录

- [1. Index 控制器](#1-index-控制器)
- [2. Agent 控制器](#2-agent-控制器)
- [3. Player 控制器](#3-player-控制器)
- [4. Order 控制器](#4-order-控制器)
- [5. 错误码说明](#5-错误码说明)

---

## 1. Index 控制器

**控制器位置**：[`app/agent/controller/Index.php`](../../app/agent/controller/Index.php)

### 1.1 退出登录

- **路径**：`GET /agent/index/logout`
- **说明**：清除代理商会话并跳转登录页

### 1.2 首页

- **路径**：`GET /agent/index/index`
- **说明**：代理商后台首页

### 1.3 个人信息

- **路径**：`GET /agent/index/my`
- **说明**：获取当前代理商个人信息

### 1.4 编辑个人信息

- **路径**：`POST /agent/index/editMy`
- **说明**：编辑入口存在，但当前代码中改密/编辑被维护开关禁用

### 1.5 申请提现

- **路径**：`POST /agent/index/applyWithdrawal`
- **说明**：申请佣金提现

### 1.6 结算

- **路径**：`GET /agent/index/jiesuan`
- **说明**：旧结算入口（已废弃，代码返回提示改用申请提现）

### 1.7 工作台

- **路径**：`GET /agent/index/worker`
- **说明**：获取工作台数据统计

---

## 2. Agent 控制器

**控制器位置**：[`app/agent/controller/Agent.php`](../../app/agent/controller/Agent.php)

### 2.1 代理列表

- **路径**：`GET /agent/agent/list`
- **说明**：显示下级代理列表页面

### 2.2 代理列表数据

- **路径**：`POST /agent/agent/list_table`
- **说明**：获取下级代理列表数据（AJAX）

### 2.3 添加代理

- **路径**：`GET /agent/agent/add`
- **说明**：显示添加下级代理页面

### 2.4 提交添加代理

- **路径**：`POST /agent/agent/addSubmit`
- **说明**：提交新增下级代理表单

### 2.5 编辑代理

- **路径**：`GET /agent/agent/edit`
- **说明**：显示编辑下级代理页面

### 2.6 提交编辑代理

- **路径**：`POST /agent/agent/editSubmit`
- **说明**：编辑提交入口（当前代码中改密相关逻辑处于维护关闭状态）

### 2.7 客服信息

- **路径**：`GET /agent/agent/kefu`
- **说明**：显示客服信息页面

### 2.8 提交客服信息

- **路径**：`POST /agent/agent/kefuSubmit`
- **说明**：提交客服信息表单

---

## 3. Player 控制器

**控制器位置**：[`app/agent/controller/Player.php`](../../app/agent/controller/Player.php)

### 3.1 玩家列表

- **路径**：`GET /agent/player/list`
- **说明**：显示直属玩家列表页面

### 3.2 玩家列表数据

- **路径**：`POST /agent/player/list_table`
- **说明**：获取直属玩家列表数据（AJAX）

### 3.3 编辑玩家

- **路径**：`GET /agent/player/edit`
- **说明**：显示编辑玩家页面

### 3.4 提交编辑玩家

- **路径**：`POST /agent/player/editSubmit`
- **说明**：提交编辑玩家表单

### 3.5 绑定列表

- **路径**：`GET /agent/player/bindList`
- **说明**：显示玩家绑定角色列表

### 3.6 绑定列表数据

- **路径**：`POST /agent/player/bind_list_table`
- **说明**：获取绑定列表数据（AJAX）

### 3.7 修改玩家状态

- **路径**：`POST /agent/player/status`
- **说明**：封禁/解封玩家

---

## 4. Order 控制器

**控制器位置**：[`app/agent/controller/Order.php`](../../app/agent/controller/Order.php)

### 4.1 订单列表

- **路径**：`GET /agent/order/list`
- **说明**：显示直属玩家订单列表页面

### 4.2 订单列表数据

- **路径**：`POST /agent/order/list_table`
- **说明**：获取订单列表数据（AJAX）

---

## 5. 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 操作失败 |
| 1 | 操作成功 |
| 401 | 未登录或登录已过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 相关文档

- [API接口文档-公共](./02-API接口文档-公共.md)
- [API接口文档-Admin](./02-API接口文档-Admin.md)
- [API接口文档-Player](./02-API接口文档-Player.md)
- [安全机制说明](./04-安全机制说明.md)
- [业务逻辑说明](./05-业务逻辑说明.md)
