# API 接口文档 - Admin 应用

> 更新时间：2026-04-26
> 说明：本文档基于代码分析生成，与当前仓库对齐。Admin/Agent 后台路由统一由 `route/web_admin_routes.php` 定义，根路由与模块路由共享同一真源。GM 模块由 5 个子控制器承载。

## 目录

- [1. Index 控制器](#1-index-控制器)
- [2. Agent 控制器](#2-agent-控制器)
- [3. Player 控制器](#3-player-控制器)
- [4. Order 控制器](#4-order-控制器)
- [5. Settlement 控制器](#5-settlement-控制器)
- [6. Transfer 控制器](#6-transfer-控制器)
- [7. GmBase 基类](#7-gmbase-基类)
- [8. GmPlayer 控制器](#8-gmplayer-控制器)
- [9. GmServer 控制器](#9-gmserver-控制器)
- [10. GmMail 控制器](#10-gmmail-控制器)
- [11. GmCdk 控制器](#11-gmcdk-控制器)
- [12. GmCleanData 控制器](#12-gmcleandata-控制器)
- [13. Item 控制器](#13-item-控制器)
- [14. Configure 控制器](#14-configure-控制器)
- [15. Log 控制器](#15-log-控制器)
- [16. Fankui 控制器](#16-fankui-控制器)
- [17. AgentRelation 控制器](#17-agentrelation-控制器)
- [18. 错误码说明](#18-错误码说明)

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
- **注意**：当前已禁用（硬编码返回"系统维护中"）

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

- **路径**：`GET /admin/player/role_table`
- **说明**：获取角色数据（AJAX，当前页面 `app/admin/view/player/role_list.html` 使用 `bootstrapTable(method=get)`）

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

## 7. GmBase 基类

**控制器位置**：[`app/admin/controller/GmBase.php`](../../app/admin/controller/GmBase.php)

所有 GM 子控制器继承此基类，提供统一能力：

- `checkGMPermission()`：验证当前管理员 type=1
- `logGMOperation()`：通过 `PermissionAuditService` 记录 GM 操作日志
- `requireGMPermission()`：权限拦截快捷方法
- `requireCSRF()`：CSRF 校验快捷方法

---

## 8. GmPlayer 控制器

**控制器位置**：[`app/admin/controller/GmPlayer.php`](../../app/admin/controller/GmPlayer.php)  
**继承**：`GmBase`

### 8.1 玩家GM操作

- **路径**：`GET /admin/gm/player`
- **说明**：显示GM操作页面
- **参数**：`playerid`（可选，首次设置后存入 Session）、`mod`（可选，默认 `basic`）

### 8.2 玩家GM提交

- **路径**：`POST /admin/gm/playerSub`
- **说明**：提交GM操作（含CSRF验证）
- **支持的 mod 类型**：`basic`、`role`、`pet`、`gang`、`equip`

### 8.3 基础GM命令（basic）

支持的 `gmcmd`：`nonvoice`、`unnonvoice`、`coquest`、`clearbag`、`forgmbid`、`ungmforbid`、`superforbiduser`、`superunforbiduser`、`kick`、`baitantimeclear`、`checkcode`、`hideme`、`showme`、`battleEndSuccess`、`battleEndFail`、`cangbatou`

### 8.4 角色GM命令（role）

支持的 `gmcmd`：`addlevel`、`addRechargecurrency`/`addqian`、`subfushi`、`addvipexp`、`setvip`、`addgold`、`changebindtel`、`addsuperitem`、`grmail`、`addtitle`、`deltitle`、`addhyd`、`addRechargecurrencyS`/`addqianS`、`award`、`offlinetime`、`rolecmd`

### 8.5 宠物GM命令（pet）

支持的 `gmcmd`：`addpetexp`、`addpet`、`addpetskill`、`delpetskill`、`setpetvalue`

### 8.6 帮派GM命令（gang）

支持的 `gmcmd`：`addbanggong`、`addfactionmoney`、`bpgx`、`yaofangrefresh`、`dismissguild`

### 8.7 装备GM命令（equip）

执行 `Gm::adddingzhiequip` 定制装备操作。

---

## 9. GmServer 控制器

**控制器位置**：[`app/admin/controller/GmServer.php`](../../app/admin/controller/GmServer.php)  
**继承**：`GmBase`

### 9.1 服务器指令

- **路径**：`GET /admin/gm/server_cmd`
- **说明**：显示服务器指令页面

### 9.2 服务器指令提交

- **路径**：`POST /admin/gm/serverSub`
- **说明**：提交服务器指令（含CSRF验证）
- **支持的 gmcmd**：`cmd`、`setdays`、`post`、`zmd`、`destroyzone`、`reload`、`stopgamegs`、`createrole0`、`createrole1`

---

## 10. GmMail 控制器

**控制器位置**：[`app/admin/controller/GmMail.php`](../../app/admin/controller/GmMail.php)  
**继承**：`GmBase`

### 10.1 全服邮件

- **路径**：`GET /admin/gm/server_mail`
- **说明**：显示全服邮件页面

### 10.2 全服邮件提交

- **路径**：`POST /admin/gm/serverMailSub`
- **说明**：提交全服邮件（含CSRF验证），调用 `Gm::mailbycond`

---

## 11. GmCdk 控制器

**控制器位置**：[`app/admin/controller/GmCdk.php`](../../app/admin/controller/GmCdk.php)  
**继承**：`GmBase`

### 11.1 CDK管理

- **路径**：`GET /admin/gm/cdk`
- **说明**：显示CDK管理页面

### 11.2 查询CDK

- **路径**：`POST /admin/gm/cdkQuery`
- **参数**：`cdk`、`uid`、`qid`、`status`、`page`、`pageSize`
- **说明**：多条件分页查询CDK

### 11.3 CDK列表-未使用

- **路径**：`GET /admin/gm/cdkListUnused`
- **说明**：获取未使用CDK分页列表

### 11.4 CDK列表-已使用

- **路径**：`GET /admin/gm/cdkListUsed`
- **说明**：获取已使用CDK分页列表

### 11.5 CDK统计

- **路径**：`GET /admin/gm/cdkStats`
- **说明**：获取CDK总量/已用/未用统计

### 11.6 生成CDK

- **路径**：`POST /admin/gm/cdkGenerate`
- **参数**：`count`（<=100000）、`lv`、`length`（16或20）、`csrf_token`
- **说明**：批量生成CDK（含CSRF验证）

### 11.7 更新CDK用户

- **路径**：`POST /admin/gm/cdkUpdateUid`
- **说明**：更新已使用CDK的绑定用户（含CSRF验证）

### 11.8 删除CDK

- **路径**：`POST /admin/gm/cdkDelete`
- **说明**：删除CDK记录（含CSRF验证）

### 11.9 更新CDK密码

- **路径**：`POST /admin/gm/cdkUpdatePass`
- **说明**：更新已使用CDK的密码（含CSRF验证）

---

## 12. GmCleanData 控制器

**控制器位置**：[`app/admin/controller/GmCleanData.php`](../../app/admin/controller/GmCleanData.php)  
**继承**：`GmBase`

### 12.1 数据清理

- **路径**：`GET /admin/gm/cleanData`
- **说明**：显示数据清理页面

### 12.2 清理数据提交

- **路径**：`POST /admin/gm/cleanDataSub`
- **说明**：执行单条数据清理（含CSRF验证）
- **支持的 gmcmd**：`cleandata`、`cleanrole`、`cleanmail`、`cleangang`、`cleanshop`、`cleantask`

### 12.3 查询清理数据

- **路径**：`POST /admin/gm/queryCleanData`
- **说明**：查询玩家关联数据统计（账号/绑定/订单/日志等）
- **参数**：`userId` 或 `playerId`、`csrf_token`

### 12.4 执行清理

- **路径**：`POST /admin/gm/doCleanData`
- **说明**：执行指定玩家数据清理（含CSRF验证 + 确认口令 `DELETE`）
- **参数**：`userId` 或 `playerId`、`confirm_phrase`（必须为 `DELETE`）、`resetAutoIncrement`、`csrf_token`

### 12.5 获取数据统计

- **路径**：`GET /admin/gm/getDataStatistics`
- **说明**：获取各表行数统计（含CSRF验证）

### 12.6 清理所有数据

- **路径**：`POST /admin/gm/doCleanAll`
- **说明**：执行全量数据清理（含CSRF验证 + 确认口令 `DELETE_ALL`）
- **参数**：`confirm_phrase`（必须为 `DELETE_ALL`）、`resetAutoIncrement`、`csrf_token`

---

## 13. Item 控制器

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

## 14. Configure 控制器

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

## 15. Log 控制器

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

## 16. Fankui 控制器

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

## 17. AgentRelation 控制器

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

## 18. 错误码说明

| 错误码 | 说明 |
|--------|------|
| 1 | 操作成功 |
| 0 | 操作失败/业务拒绝 |
| 403 | 无权限访问（PermissionGuard 拦截） |
| 99 | 超管二次验证提示 |
| 404 | 路由未命中/资源不存在 |
| 401 | 未登录或登录已过期 |
| 500 | 服务器内部错误 |

> 说明：`PermissionGuard` 中间件在全局中间件链中执行细粒度权限校验，拦截时返回 HTTP 403 + `{"code":403,"msg":"无权限访问该资源","request_id":"..."}`。

---

## 相关文档

- [API接口文档-公共](./02-API接口文档-公共.md)
- [API接口文档-Agent](./02-API接口文档-Agent.md)
- [API接口文档-Player](./02-API接口文档-Player.md)
- [安全机制说明](./04-安全机制说明.md)
- [业务逻辑说明](./05-业务逻辑说明.md)
