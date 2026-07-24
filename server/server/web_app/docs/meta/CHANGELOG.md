# 变更日志

本文档记录 mt3_web 项目的所有版本变更历史。

---

## [3.0.1] - 2026-03-01

### 文档修复

- 修复 [`../03-参考_Reference/10-Voice语音识别模块.md`](../03-参考_Reference/10-Voice语音识别模块.md) 中的失效引用（`../02-技术文档/` → 同级路径）
- 修复 [`../03-参考_Reference/11-Duty活动模块.md`](../03-参考_Reference/11-Duty活动模块.md) 中的失效引用（`../02-技术文档/` → 同级路径）
- 修复 [`../03-参考_Reference/01-项目架构说明.md`](../03-参考_Reference/01-项目架构说明.md) 中的转区服务引用（`09-转区服务说明.md` → `12-转区服务说明.md`）
- 修复 [`../03-参考_Reference/04-安全机制说明.md`](../03-参考_Reference/04-安全机制说明.md) 中的转区服务引用（`09-转区服务说明.md` → `12-转区服务说明.md`）
- 修复 [`../03-参考_Reference/05-业务逻辑说明.md`](../03-参考_Reference/05-业务逻辑说明.md) 中的转区服务引用（`09-转区服务说明.md` → `12-转区服务说明.md`）

### 文档清理

- 去除 [`../03-参考_Reference/02-API接口文档-Admin.md`](../03-参考_Reference/02-API接口文档-Admin.md) 的 UTF-8 BOM，保持内容不变

### 文档新增

- 新增 [`../03-参考_Reference/02-API接口文档-Login.md`](../03-参考_Reference/02-API接口文档-Login.md)，涵盖 Auth、Index、User 控制器
- 新增 [`../03-参考_Reference/02-API接口文档-Index.md`](../03-参考_Reference/02-API接口文档-Index.md)，涵盖 Index、Cdk、Duty 控制器
- 更新 [`../03-参考_Reference/README.md`](../03-参考_Reference/README.md)，纳入新增 API 文档导航

### 执行报告

- 新增 [`../文档优化执行报告_2026-03-01.md`](../文档优化执行报告_2026-03-01.md)，记录本次文档优化执行详情

---

## [3.0.0] - 2026-02-28

### 文档架构迁移

将文档目录结构从编号体系迁移至 Diátaxis 框架：

- **01-教程_Tutorials**：学习导向的文档（原04-教程）
  - 01-快速入门/
  - 02-开发者指南/
- **02-操作指南_How-To-Guides**：任务导向的文档（原03-运维指南）
  - 01-部署指南.md
  - 02-配置指南.md
  - 03-监控指南.md
  - 04-故障排查.md
- **03-参考_Reference**：信息导向的文档（原02-技术文档）
  - 项目架构、API文档、配置说明、安全机制等
- **04-解释_Explanation**：理解导向的文档（原01-安全修复记录）
  - 01-安全修复记录总览.md
  - archive/ 历史归档

### 文档更新

- 更新 [`../00-README_文档索引_Documentation_Index.md`](../00-README_文档索引_Documentation_Index.md) 至 Diátaxis 框架结构
- 更新各目录 README.md 以反映新的组织方式
- 修正所有内部链接引用

---

## [2.0.1] - 2026-02-27

### 文档同步

- 重写 [`../02-技术文档/06-功能模块说明.md`](../02-技术文档/06-功能模块说明.md)，按 `app/*/controller/*.php` 与 `route/*.php` 重新梳理模块与方法清单，移除历史失真示例。
- 修正 [`../02-技术文档/02-API接口文档-Player.md`](../02-技术文档/02-API接口文档-Player.md) 转区入口路径为 `GET /player/transfer`。
- 补充 [`../02-技术文档/02-API接口文档-SDK.md`](../02-技术文档/02-API接口文档-SDK.md) 的 `/api/game/rebate` 接口条目。
- 修正 [`../02-技术文档/08-SendItem模块说明.md`](../02-技术文档/08-SendItem模块说明.md) 的实际访问路径为 `/player/cdk/senditem`，并同步 `config/player.php` 中 `op_secret_salt` 默认值。
- 更新 [`../00-README_文档索引_Documentation_Index.md`](../00-README_文档索引_Documentation_Index.md)，补充 `08-Voice语音识别模块.md` 与 `09-Duty活动模块.md` 的索引项，并标注历史并行命名现状。
- 更新 [`../02-技术文档/README.md`](../02-技术文档/README.md) 的模块文档清单，纳入 Voice 与 Duty 文档。
- 修正教程文档中的框架版本引用：[`../04-教程/02-开发者指南/01-项目结构认知.md`](../04-教程/02-开发者指南/01-项目结构认知.md)、[`../04-教程/02-开发者指南/README.md`](../04-教程/02-开发者指南/README.md)。

### 代码同步

- 新增 `app/player/controller/Server.php::detail()`，补齐 `GET /player/server/detail` 路由对应实现。
- 新增视图 `app/player/view/server/detail.html`，用于展示服务器详情与当前玩家在该服角色列表。
- 修复 `app/player/controller/Recharge.php` 的订单写入逻辑，改为与 `user_order` 真实字段（`orderid/user/item/realmoney/...`）对齐。
- 修复 `app/player/controller/Order.php` 的玩家订单查询与详情归属校验，兼容 `user` JSON 中 `playerid` 数字/字符串两种格式，并补齐 `status/order_no` 过滤。
- 修复 `app/player/controller/Auth.php` 找回密码重置链路：重置令牌改为缓存存储（1小时），不再依赖 `user_account` 中不存在的 `reset_token/reset_time` 字段。
- 收敛 `app/player/controller/Auth.php` 找回密码日志输出，不再记录完整重置链接令牌（仅保留脱敏预览）。
- 修复 `app/player/controller/Profile.php` 与 `app/player/view/profile/index.html` 的 `real_name` 字段不一致问题。
- 修复 `app/player/service/TransferService.php` 角色归属字段误用（`uid` → `userid`），并修复 `app/player/view/transfer/index.html` 角色名与原因字段兼容展示。
- 修复 SendItem 前端路由与后端显式路由不一致：`app/player/view/senditem/index.html` 与 `app/player/view/cdk/dashboard.html` 统一使用 `/player/cdk/senditem/*`。
- 在 `app/player/middleware.php` 统一挂载 `PlayerSecurity`、`PlayerAuth`、`CsrfToken`，收敛 Player 应用安全链路。
- 收敛 `app/player/middleware/PlayerAuth.php` 公共路由判定为“控制器+动作”白名单，修复仅按 action 名称放行导致的越权风险。
- 修复 `app/player/controller/SendItem.php`：仅允许已完成 CDK 授权会话访问，`prepareOp(sendItem)` 返回后端签发的 `item_token`，并增加签名异常兜底处理。
- 修复 `app/player/service/GmService.php` 与 `app/player/service/AuthService.php` 的弱默认密钥回退，改为未配置密钥时拒绝签名相关操作。
- 修复 `app/player/service/AuthService.php` 超级管理员二次验证密钥默认值风险：未配置 `MASTER_VERIFY_PASSWORD` 时拒绝超管登录。
- 修复 `app/player/view/admin/login.html` 验证码刷新地址错误（`/player/admin/captcha`）。
- 增补 `app/player/view/cdk/index.html` 的“已有授权登录”表单，打通 `POST /player/cdk/existing` 前端入口。
- 扩展 `app/player/middleware/PlayerSecurity.php` 登录频率限制覆盖范围，将 CDK 授权入口 `auth/existing` 纳入限流。

### 文档同步（增量）

- 更新 [`../02-技术文档/04-安全机制说明.md`](../02-技术文档/04-安全机制说明.md)，同步 Player 应用中间件统一挂载现状。
- 更新 [`../02-技术文档/02-API接口文档-Player.md`](../02-技术文档/02-API接口文档-Player.md)，补充订单筛选参数、充值渠道取值与找回密码缓存令牌说明。
- 更新 [`../02-技术文档/08-SendItem模块说明.md`](../02-技术文档/08-SendItem模块说明.md)，修正授权入口并补充 POST 请求 CSRF 要求。
- 继续更新上述三份文档，补充 SendItem 的 `item_token` 签发流程、CDK 控制台访问前置条件与 PlayerAuth 白名单机制。
- 更新 [`../02-技术文档/03-配置文件说明.md`](../02-技术文档/03-配置文件说明.md)，同步 `MASTER_VERIFY_PASSWORD` 当前用途与生产环境要求。

---

## [2.0.0] - 2026-02-23

### 文档同步

- 重写 [`../01-安全修复记录/01-安全修复记录总览.md`](../01-安全修复记录/01-安全修复记录总览.md)，按当前代码同步 P0/P1/P2 安全修复事实。
- 更新 [`../01-安全修复记录/README.md`](../01-安全修复记录/README.md)，改为与总览一致的导航入口。
- 重写 [`../00-README_文档索引_Documentation_Index.md`](../00-README_文档索引_Documentation_Index.md)，修复失效路径与不存在目录引用。

### 一致性修正

- 修正 [`../04-教程/01-快速入门/03-基础使用.md`](../04-教程/01-快速入门/03-基础使用.md) 中旧合并 API 文档链接为拆分后公共 API 文档。
- 修正 [`../03-运维指南/04-故障排查.md`](../03-运维指南/04-故障排查.md) 中错误目录编号引用（`03-技术文档` / `04-运维指南`）。
- 修正 [`../02-技术文档/06-功能模块说明.md`](../02-技术文档/06-功能模块说明.md) 末尾附录中的历史失效引用。
- 修正 [`../02-技术文档/README.md`](../02-技术文档/README.md) 对不存在 `02-API接口文档_归档.md` 的描述。
- 更新 [`../02-技术文档/04-安全机制说明.md`](../02-技术文档/04-安全机制说明.md) 中 PlayerSecurity/CsrfToken 描述，明确“实现存在”与“路由统一挂载证据不足”的边界。

### 已知历史条目说明

- 本文件中 `1.3.0` 及更早版本保留历史记录，其内关于 `02-API接口文档_归档.md` 与 `meta/archive/audit-reports/` 的描述属于历史语义，不代表当前仓库仍存在对应文件/目录。

---

## [1.3.0] - 2026-02-21

### 文档新增

#### API 文档拆分
- 新增 [`02-API接口文档-SDK.md`](../02-技术文档/02-API接口文档-SDK.md)：SDK 接口文档（登录、注册、授权等）
- 新增 [`02-API接口文档-Admin.md`](../02-技术文档/02-API接口文档-Admin.md)：管理后台接口文档
- 新增 [`02-API接口文档-Agent.md`](../02-技术文档/02-API接口文档-Agent.md)：代理商接口文档
- 新增 [`02-API接口文档-Player.md`](../02-技术文档/02-API接口文档-Player.md)：玩家接口文档
- 新增 [`02-API接口文档-公共.md`](../02-技术文档/02-API接口文档-公共.md)：公共接口文档

#### 模块文档
- 新增 [`08-SendItem模块说明.md`](../02-技术文档/08-SendItem模块说明.md)：SendItem 发送物品模块详细说明
- 新增 [`09-转区服务说明.md`](../02-技术文档/09-转区服务说明.md)：转区服务架构与流程说明

#### 教程文档
- 新增 [`04-教程/`](../04-教程/) 目录及完整教程体系
- 新增 [`01-快速入门/`](../04-教程/01-快速入门/) 子目录
  - [`01-环境搭建.md`](../04-教程/01-快速入门/01-环境搭建.md)：开发环境配置指南
  - [`02-首次部署.md`](../04-教程/01-快速入门/02-首次部署.md)：项目部署步骤
  - [`03-基础使用.md`](../04-教程/01-快速入门/03-基础使用.md)：基本功能使用说明
- 新增 [`02-开发者指南/`](../04-教程/02-开发者指南/) 子目录
  - [`01-项目结构认知.md`](../04-教程/02-开发者指南/01-项目结构认知.md)：项目目录结构说明
  - [`02-编码规范.md`](../04-教程/02-开发者指南/02-编码规范.md)：代码编写规范

#### 索引文档
- 新增 [`02-技术文档/README.md`](../02-技术文档/README.md)：技术文档目录索引
- 新增 [`03-运维指南/README.md`](../03-运维指南/README.md)：运维指南目录索引

#### 元文档
- 新增 [`meta/CONTRIBUTING.md`](CONTRIBUTING.md)：文档贡献指南

### 文档归档

- 归档 [`02-API接口文档.md`](../02-技术文档/02-API接口文档_归档.md)：原统一文档拆分后归档
- 归档 `文档审计报告_*.md` → [`meta/archive/audit-reports/`](archive/audit-reports/)

### 结构优化

- 创建 [`meta/`](.) 目录结构，包含：
  - [`CHANGELOG.md`](CHANGELOG.md)：变更日志
  - [`README.md`](README.md)：元文档说明
  - [`CONTRIBUTING.md`](CONTRIBUTING.md)：贡献指南
  - [`archive/`](archive/)：归档目录
- 更新文档索引 [`00-README_文档索引_Documentation_Index.md`](../00-README_文档索引_Documentation_Index.md)

### 修改文件

**新增文件：**
- `docs/02-技术文档/02-API接口文档-SDK.md`
- `docs/02-技术文档/02-API接口文档-Admin.md`
- `docs/02-技术文档/02-API接口文档-Agent.md`
- `docs/02-技术文档/02-API接口文档-Player.md`
- `docs/02-技术文档/02-API接口文档-公共.md`
- `docs/02-技术文档/08-SendItem模块说明.md`
- `docs/02-技术文档/09-转区服务说明.md`
- `docs/02-技术文档/README.md`
- `docs/03-运维指南/README.md`
- `docs/04-教程/README.md`
- `docs/04-教程/01-快速入门/README.md`
- `docs/04-教程/01-快速入门/01-环境搭建.md`
- `docs/04-教程/01-快速入门/02-首次部署.md`
- `docs/04-教程/01-快速入门/03-基础使用.md`
- `docs/04-教程/02-开发者指南/README.md`
- `docs/04-教程/02-开发者指南/01-项目结构认知.md`
- `docs/04-教程/02-开发者指南/02-编码规范.md`
- `docs/meta/CONTRIBUTING.md`

**归档文件：**
- `docs/02-技术文档/02-API接口文档.md` → `docs/02-技术文档/02-API接口文档_归档.md`
- `docs/文档审计报告_*.md` → `docs/meta/archive/audit-reports/`

---

## [1.2.0] - 2026-02-19

### 修复
- 修复 `bind_list.html` 全局 `htmlEncode()` 函数缺失导致绑定列表无法渲染的问题

### 文档
- 修正 README 索引目录编号错位（02→01, 03→02, 04→03）
- 删除索引中引用的不存在目录（05-接口变更记录、06-系统分析报告）
- 基于 `mhxy.sql` 全面重写数据库模式文档（修正 20+ 张表的字段定义）
- 补全 Player 控制器文档（2 个方法→14 个方法）
- 新增 Transfer 控制器文档（8 个方法）
- 更新 Admin 目录结构（新增 Transfer.php、player 视图子目录）

---

## [1.1.0] - 2026-02-18

### 安全修复
- 新增 `htmlEncode()` XSS 防护函数，应用于 `list.html`、`bind_list.html`、`voice_list.html` 所有动态字段
- 修复 `editSubmit()` 中 `$id` 和 `$lastagent` 未使用 `intval()` 的输入验证漏洞
- 修复 `status()` 和 `zhiboqu()` 中直接使用 `$post['id']` 而非已验证变量的安全隐患
- 新增 SweetAlert 删除确认弹窗，防止误操作

### 改进
- 重构 Session 搜索机制：`list_table()` 和 `bind_list_table()` 改为从 POST 直接读取搜索参数，解决多标签页搜索冲突
- 迁移 4 处 `jsonp()` 为 `json()`（同域无需 JSONP）
- 提取公共 `showToast()` 函数，消除 7 处 Swal.mixin 重复代码
- 新增 `voice_list.html` UUID/内容搜索功能
- 修正 `edit.html` 格式提示从 "8-16位" 改为 "6-18位"，与后端验证一致

### 修改文件
- `app/admin/controller/Player.php`
- `app/admin/view/player/list.html`
- `app/admin/view/player/bind_list.html`
- `app/admin/view/player/voice_list.html`
- `app/admin/view/player/edit.html`

---

## [1.0.0] - 2026-02-06

### 新增
- 新增玩家授权功能模块
- 新增CDK授权登录接口
- 新增账号密码登录接口
- 新增获取服务器列表接口
- 新增准备操作接口
- 新增发送物品接口
- 新增充值仙玉接口
- 新增获取物品列表接口
- 新增CDK查询接口
- 新增CDK生成接口
- 新增代理佣金系统
- 新增玩家控制台功能
- 新增GM权限验证机制

### 修改
- 修改GM命令执行接口，添加权限验证和操作日志
- 修改服务器状态检查逻辑，添加端口号严格验证和命令注入防护
- 修改admin_account表结构，新增佣金相关字段
- 新增agent_commission表，记录代理佣金明细

### 安全改进
- 添加GM权限检查（仅type=1的管理员可执行）
- 添加操作日志记录（使用PermissionAuditService）
- 添加命令注入防护（严格验证端口号）
- 新增签名验证机制（HMAC-SHA256算法）
- 新增超时控制，防止重放攻击
- 严格验证端口号（is_numeric检查）
- 验证端口范围（1-65535）
- 使用escapeshellarg防止命令注入

### 配置变更
- 新增PLAYER_AUTH_ENABLED配置（是否启用玩家授权功能）
- 新增OP_SECRET_SALT配置（操作签名盐值）
- 新增SIGNATURE_TIMEOUT配置（签名超时时间）
- 新增ITEM_WHITELIST_CACHE_TTL配置（物品白名单缓存时间）
- 新增PET_WHITELIST_CACHE_TTL配置（宠物白名单缓存时间）
- 新增TCP_DIRECT_ENABLED配置（是否启用TCP直连）
- 新增player.php配置文件

### 路由变更
- 新增player路由组，包含所有玩家授权相关路由
- 新增向后兼容路由（login/index/*）
- 新增简化路径路由（login/auth/*）

### 数据库变更
- 新增agent_commission表，记录代理佣金明细
- 修改admin_account表，新增direct_commission、sub_commission、total_commission等字段

---

## [0.9.0] - 2026-02-01

### 新增
- 新增Web管理后台系统
- 新增API接口文档
- 新增安全机制说明文档
- 新增部署指南和运维指南

### 修改
- 优化系统架构设计
- 完善业务逻辑说明

---

## 变更类型说明

| 类型 | 说明 |
|------|------|
| 新增 | 新增功能或接口 |
| 修改 | 修改现有功能或接口 |
| 删除 | 删除功能或接口 |
| 修复 | 修复bug或问题 |
| 安全改进 | 安全相关的改进 |

---

## 文档更新记录

- 2026-02-15: 创建CHANGELOG.md，整合接口变更记录
- 2026-02-06: 新增接口变更记录文档
- 2026-02-01: 初始文档结构建立

---

## 联系方式

如有问题或建议，请联系技术支持团队。
