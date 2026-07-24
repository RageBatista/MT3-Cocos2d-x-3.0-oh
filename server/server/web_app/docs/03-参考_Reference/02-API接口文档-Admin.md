# API 接口文档 - Admin 应用

> 更新时间：2026-02-23
> 说明：本文档基于代码分析生成，与当前仓库对齐。

## 目录

- [1. Index 控制器](#1-index-控制器)
- [2. Agent 控制器](#2-agent-控制器)
- [3. Player 控制器](#3-player-控制器)
- [4. Order 控制器](#4-order-控制器)
- [5. Settlement 控制器](#5-settlement-控制器)
- [6. Transfer 控制器](#6-transfer-控制器)
- [7. Gm 控制器](#7-gm-控制器)
- [8. Item 控制器](#8-item-控制器)
- [9. Configure 控制器](#9-configure-控制器)
- [10. Log 控制器](#10-log-控制器)
- [11. Fankui 控制器](#11-fankui-控制器)
- [12. AgentRelation 控制器](#12-agentrelation-控制器)
- [13. TestPay 控制器](#13-testpay-控制器)
- [14. 错误码说明](#14-错误码说明)

---

## 1. Index 控制器

**控制器位置**：[`app/admin/controller/Index.php`](../../app/admin/controller/Index.php)

### 1.1 退出登录

- **路径**：`GET /admin/index/logout`
- **说明**：清除管理员会话并跳转登录页

### 1.2 首页

- **路径**：`GET /admin/index/index`
- **说明**：管理后台首页

### 1.3 个人信息

- **路径**：`GET /admin/index/my`
- **说明**：获取当前管理员个人信息

### 1.4 编辑个人信息

- **路径**：`POST /admin/index/editMy`
- **说明**：编辑入口存在，但当前代码中改密/编辑被维护开关禁用

### 1.5 工作台

- **路径**：`GET /admin/index/worker`
- **说明**：获取工作台数据统计

---

## 2. Agent 控制器

**控制器位置**：[`app/admin/controller/Agent.php`](../../app/admin/controller/Agent.php)

### 2.1 代理列表

- **路径**：`GET /admin/agent/list`
- **说明**：显示代理列表页面

### 2.2 结算列表

- **路径**：`GET /admin/agent/jiesuanlist`
- **说明**：显示代理结算列表页面

### 2.3 结算数据

- **路径**：`POST /admin/agent/list_jiesuan`
- **说明**：获取代理结算数据

### 2.4 代理列表数据

- **路径**：`POST /admin/agent/list_table`
- **说明**：获取代理列表数据（AJAX）

### 2.5 执行结算

- **路径**：`POST /admin/agent/jiesuan`
- **说明**：执行代理佣金结算

### 2.6 添加代理

- **路径**：`GET /admin/agent/add`
- **说明**：显示添加代理页面

### 2.7 提交添加代理

- **路径**：`POST /admin/agent/addSubmit`
- **说明**：提交新增代理表单

### 2.8 编辑代理

- **路径**：`GET /admin/agent/edit`
- **说明**：显示编辑代理页面

### 2.9 提交编辑代理

- **路径**：`POST /admin/agent/editSubmit`
- **说明**：提交编辑代理表单

### 2.10 修改代理状态

- **路径**：`POST /admin/agent/status`
- **说明**：启用/禁用代理账号

### 2.11 提现管理

- **路径**：`GET /admin/agent/tixian`
- **说明**：代理提现管理页面

### 2.12 权限管理

- **路径**：`GET /admin/agent/quanxian`
- **说明**：代理权限管理页面

---

## 3. Player 控制器

**控制器位置**：[`app/admin/controller/Player.php`](../../app/admin/controller/Player.php)

### 3.1 玩家列表

- **路径**：`GET /admin/player/list`
- **说明**：显示玩家列表页面

### 3.2 玩家列表数据

- **路径**：`POST /admin/player/list_table`
- **说明**：获取玩家列表数据（AJAX）

### 3.3 编辑玩家

- **路径**：`GET /admin/player/edit`
- **说明**：显示编辑玩家页面

### 3.4 提交编辑玩家

- **路径**：`POST /admin/player/editSubmit`
- **说明**：提交编辑玩家表单（含CSRF验证）

### 3.5 补充充值

- **路径**：`POST /admin/player/modify`
- **说明**：为玩家补充充值

### 3.6 删除玩家

- **路径**：`POST /admin/player/del`
- **说明**：删除玩家账号（含CSRF验证）

### 3.7 绑定列表

- **路径**：`GET /admin/player/bindList`
- **说明**：显示玩家绑定角色列表

### 3.8 绑定列表数据

- **路径**：`POST /admin/player/bind_list_table`
- **说明**：获取绑定列表数据（AJAX）

### 3.9 修改玩家状态

- **路径**：`POST /admin/player/status`
- **说明**：封禁/解封玩家（含CSRF验证）

### 3.10 直播区权限

- **路径**：`POST /admin/player/zhiboqu`
- **说明**：切换玩家直播区权限（含CSRF验证）

### 3.11 语音列表

- **路径**：`GET /admin/player/voiceList`
- **说明**：显示语音识别记录列表

### 3.12 语音列表数据

- **路径**：`POST /admin/player/voice_list_table`
- **说明**：获取语音列表数据（AJAX，支持UUID/内容搜索）

### 3.13 角色列表

- **路径**：`GET /admin/player/roleList`
- **说明**：显示角色管理页面

### 3.14 角色数据

- **路径**：`POST /admin/player/role_table`
- **说明**：获取角色数据（AJAX）

---

## 4. Order 控制器

**控制器位置**：[`app/admin/controller/Order.php`](../../app/admin/controller/Order.php)

### 4.1 订单列表

- **路径**：`GET /admin/order/list`
- **说明**：显示订单列表页面

### 4.2 订单列表数据

- **路径**：`POST /admin/order/list_table`
- **说明**：获取订单列表数据（AJAX）

### 4.3 退款

- **路径**：`POST /admin/order/tuikuan`
- **说明**：执行订单退款操作

---

## 5. Settlement 控制器

**控制器位置**：[`app/admin/controller/Settlement.php`](../../app/admin/controller/Settlement.php)

### 5.1 结算首页

- **路径**：`GET /admin/settlement/index`
- **说明**：显示结算首页

### 5.2 结算数据

- **路径**：`POST /admin/settlement/list_table`
- **说明**：获取结算数据（AJAX）

### 5.3 执行结算

- **路径**：`POST /admin/settlement/settle`
- **说明**：执行佣金结算

### 5.4 结算记录

- **路径**：`GET /admin/settlement/records`
- **说明**：显示结算记录页面

### 5.5 结算记录数据

- **路径**：`POST /admin/settlement/records_table`
- **说明**：获取结算记录数据（AJAX）

### 5.6 结算统计

- **路径**：`POST /admin/settlement/statistics`
- **说明**：获取结算统计数据

---

## 6. Transfer 控制器

**控制器位置**：[`app/admin/controller/Transfer.php`](../../app/admin/controller/Transfer.php)

### 6.1 转区申请列表

- **路径**：`GET /admin/transfer/list`
- **说明**：显示转区申请列表页面

### 6.2 转区申请数据

- **路径**：`POST /admin/transfer/table`
- **说明**：获取转区申请数据（AJAX）

### 6.3 转区详情

- **路径**：`GET /admin/transfer/detail`
- **说明**：显示转区申请详情页面

### 6.4 审核通过

- **路径**：`POST /admin/transfer/approve`
- **说明**：审核通过转区申请

### 6.5 审核拒绝

- **路径**：`POST /admin/transfer/reject`
- **说明**：拒绝转区申请

### 6.6 开始处理

- **路径**：`POST /admin/transfer/process`
- **说明**：开始处理转区（含CSRF验证）

### 6.7 完成转区

- **路径**：`POST /admin/transfer/complete`
- **说明**：完成转区操作

### 6.8 自动执行

- **路径**：`POST /admin/transfer/autoExecute`
- **说明**：自动执行转区

---

## 7. Gm 控制器

**控制器位置**：[`app/admin/controller/Gm.php`](../../app/admin/controller/Gm.php)

### 7.1 玩家GM操作

- **路径**：`GET /admin/gm/player`
- **说明**：显示GM操作页面

### 7.2 玩家GM提交

- **路径**：`POST /admin/gm/playerSub`
- **说明**：提交GM操作

### 7.3 基础信息GM

- **路径**：`POST /admin/gm/basic`
- **说明**：执行基础信息GM（禁言、解禁、踢人等）

### 7.4 角色GM

- **路径**：`POST /admin/gm/role`
- **说明**：执行角色GM（设置等级、经验等）

### 7.5 宠物GM

- **路径**：`POST /admin/gm/pet`
- **说明**：执行宠物GM操作

### 7.6 帮派GM

- **路径**：`POST /admin/gm/gang`
- **说明**：执行帮派GM操作

### 7.7 装备GM

- **路径**：`POST /admin/gm/equip`
- **说明**：执行装备GM操作

### 7.8 服务器指令

- **路径**：`GET /admin/gm/server_cmd`
- **说明**：显示服务器指令页面

### 7.9 服务器指令提交

- **路径**：`POST /admin/gm/serverSub`
- **说明**：提交服务器指令

### 7.10 全服邮件

- **路径**：`GET /admin/gm/server_mail`
- **说明**：显示全服邮件页面

### 7.11 全服邮件提交

- **路径**：`POST /admin/gm/serverMailSub`
- **说明**：提交全服邮件

### 7.12 数据清理

- **路径**：`GET /admin/gm/cleanData`
- **说明**：显示数据清理页面

### 7.13 查询清理数据

- **路径**：`POST /admin/gm/queryCleanData`
- **说明**：查询可清理的数据

### 7.14 执行清理

- **路径**：`POST /admin/gm/doCleanData`
- **说明**：执行数据清理

### 7.15 获取数据统计

- **路径**：`POST /admin/gm/getDataStatistics`
- **说明**：获取数据统计信息

### 7.16 清理所有数据

- **路径**：`POST /admin/gm/doCleanAll`
- **说明**：执行清理所有数据

### 7.17 CDK管理

- **路径**：`GET /admin/gm/cdk`
- **说明**：显示CDK管理页面

### 7.18 查询CDK

- **路径**：`POST /admin/gm/cdkQuery`
- **说明**：查询CDK信息

### 7.19 CDK列表-未使用

- **路径**：`GET /admin/gm/cdkListUnused`
- **说明**：获取未使用CDK列表

### 7.20 CDK列表-已使用

- **路径**：`GET /admin/gm/cdkListUsed`
- **说明**：获取已使用CDK列表

### 7.21 CDK统计

- **路径**：`GET /admin/gm/cdkStats`
- **说明**：获取CDK统计信息

### 7.22 生成CDK

- **路径**：`POST /admin/gm/cdkGenerate`
- **说明**：批量生成CDK

### 7.23 更新CDK用户

- **路径**：`POST /admin/gm/cdkUpdateUid`
- **说明**：更新CDK绑定用户

### 7.24 删除CDK

- **路径**：`POST /admin/gm/cdkDelete`
- **说明**：删除CDK

### 7.25 更新CDK密码

- **路径**：`POST /admin/gm/cdkUpdatePass`
- **说明**：更新CDK密码

---

## 8. Item 控制器

**控制器位置**：[`app/admin/controller/Item.php`](../../app/admin/controller/Item.php)

### 8.1 测试物品

- **路径**：`GET /admin/item/test`
- **说明**：测试物品功能

### 8.2 物品列表

- **路径**：`GET /admin/item/itemList`
- **说明**：显示物品列表页面

### 8.3 物品列表数据

- **路径**：`POST /admin/item/list_table`
- **说明**：获取物品列表数据（AJAX）

### 8.4 物品同步

- **路径**：`POST /admin/item/itemSync`
- **说明**：同步物品数据

### 8.5 清空物品

- **路径**：`POST /admin/item/clearAll`
- **说明**：清空物品数据

---

## 9. Configure 控制器

**控制器位置**：[`app/admin/controller/Configure.php`](../../app/admin/controller/Configure.php)

### 9.1 服务器配置

- **路径**：`GET /admin/configure/serverConfig`
- **说明**：显示服务器配置页面

### 9.2 服务器列表

- **路径**：`GET /admin/configure/serverList`
- **说明**：获取服务器列表数据

### 9.3 添加服务器

- **路径**：`GET /admin/configure/serverAdd`
- **说明**：显示添加服务器页面

### 9.4 提交添加服务器

- **路径**：`POST /admin/configure/serverAddSubmit`
- **说明**：提交添加服务器表单

### 9.5 编辑服务器

- **路径**：`GET /admin/configure/serverEdit`
- **说明**：显示编辑服务器页面

### 9.6 提交编辑服务器

- **路径**：`POST /admin/configure/serverEditSubmit`
- **说明**：提交编辑服务器表单

### 9.7 删除服务器

- **路径**：`POST /admin/configure/serverDel`
- **说明**：删除服务器

### 9.8 服务器标题

- **路径**：`POST /admin/configure/serverTitle`
- **说明**：更新服务器标题

### 9.9 生成服务器列表

- **路径**：`POST /admin/configure/makeServerList`
- **说明**：生成服务器列表缓存

### 9.10 系统配置

- **路径**：`GET /admin/configure/sysConfig`
- **说明**：显示系统配置页面

### 9.11 更新系统配置

- **路径**：`POST /admin/configure/upSys`
- **说明**：更新系统配置

### 9.12 公告配置

- **路径**：`GET /admin/configure/noticeConfig`
- **说明**：显示公告配置页面

### 9.13 更新公告

- **路径**：`POST /admin/configure/upNotice`
- **说明**：更新公告内容

### 9.14 支付配置

- **路径**：`GET /admin/configure/payConfig`
- **说明**：显示支付配置页面

### 9.15 支付渠道

- **路径**：`GET /admin/configure/payChannel`
- **说明**：显示支付渠道页面

### 9.16 添加支付渠道

- **路径**：`POST /admin/configure/addPayChannel`
- **说明**：添加支付渠道

### 9.17 提交添加渠道

- **路径**：`POST /admin/configure/addChannelSub`
- **说明**：提交添加支付渠道表单

### 9.18 删除支付渠道

- **路径**：`POST /admin/configure/delPayChannel`
- **说明**：删除支付渠道

### 9.19 编辑支付渠道

- **路径**：`GET /admin/configure/editPayChannel`
- **说明**：显示编辑支付渠道页面

### 9.20 提交编辑渠道

- **路径**：`POST /admin/configure/upChannelSub`
- **说明**：提交编辑支付渠道表单

---

## 10. Log 控制器

**控制器位置**：[`app/admin/controller/Log.php`](../../app/admin/controller/Log.php)

### 10.1 玩家登录日志页面

- **路径**：`GET /admin/log/playerLogin`
- **说明**：显示玩家登录日志页面

### 10.2 玩家登录日志数据

- **路径**：`POST /admin/log/playerLoginList`
- **说明**：获取玩家登录日志数据（AJAX）

### 10.3 用户日志页面

- **路径**：`GET /admin/log/userLog`
- **说明**：显示用户操作日志页面

### 10.4 用户日志数据

- **路径**：`POST /admin/log/list_table`
- **说明**：获取用户操作日志数据（AJAX）

---

## 11. Fankui 控制器

**控制器位置**：[`app/admin/controller/Fankui.php`](../../app/admin/controller/Fankui.php)

### 11.1 反馈列表

- **路径**：`GET /admin/fankui/fankuiList`
- **说明**：显示用户反馈列表页面

### 11.2 反馈列表数据

- **路径**：`POST /admin/fankui/fankui_list_table`
- **说明**：获取反馈列表数据（AJAX）

### 11.3 回复页面

- **路径**：`GET /admin/fankui/mail`
- **说明**：显示反馈回复页面

### 11.4 提交回复

- **路径**：`POST /admin/fankui/mailSub`
- **说明**：向玩家发送客服邮件回复，并更新工单状态

---

## 12. AgentRelation 控制器

**控制器位置**：[`app/admin/controller/AgentRelation.php`](../../app/admin/controller/AgentRelation.php)

### 12.1 初始化代理关系

- **路径**：`POST /admin/agentRelation/initRelation`
- **说明**：初始化/修复代理关系链路

### 12.2 关系树视图

- **路径**：`GET /admin/agentRelation/viewTree`
- **说明**：查看代理关系树结构

### 12.3 更新金额统计

- **路径**：`POST /admin/agentRelation/updateAmount`
- **说明**：更新代理流水/金额统计

### 12.4 佣金统计

- **路径**：`GET /admin/agentRelation/commissionStats`
- **说明**：查看代理佣金统计

### 12.5 全量重算

- **路径**：`POST /admin/agentRelation/recalculateAll`
- **说明**：全量重算代理关系与统计数据

---

## 13. TestPay 控制器

**控制器位置**：[`app/admin/controller/TestPay.php`](../../app/admin/controller/TestPay.php)

### 13.1 测试支付首页

- **路径**：`GET /admin/testPay/index`
- **说明**：测试支付调试页面

### 13.2 支付回调测试

- **路径**：`POST/GET /admin/testPay/callback`
- **说明**：测试支付回调处理

### 13.3 创建测试订单

- **路径**：`POST /admin/testPay/createOrder`
- **说明**：创建测试订单

### 13.4 查看测试佣金

- **路径**：`GET /admin/testPay/viewCommission`
- **说明**：查看测试佣金结果

---

## 14. 错误码说明

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
- [API接口文档-Agent](./02-API接口文档-Agent.md)
- [API接口文档-Player](./02-API接口文档-Player.md)
- [安全机制说明](./04-安全机制说明.md)
- [业务逻辑说明](./05-业务逻辑说明.md)
