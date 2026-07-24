# MT3 Web 项目文档索引（Diátaxis 框架）

> 更新时间：2026-02-28

## 1. 文档结构总览

当前 `docs/` 目录采用 [Diátaxis 框架](https://diataxis.fr/) 组织：

```text
docs/
├── 00-README_文档索引_Documentation_Index.md
├── 文档优化执行报告_2026-02-28.md
├── 01-教程_Tutorials/               # 学习导向
│   ├── README.md
│   ├── 01-快速入门/
│   │   ├── README.md
│   │   ├── 01-环境搭建.md
│   │   ├── 02-首次部署.md
│   │   └── 03-基础使用.md
│   └── 02-开发者指南/
│       ├── README.md
│       ├── 01-项目结构认知.md
│       └── 02-编码规范.md
├── 02-操作指南_How-To-Guides/       # 任务导向
│   ├── README.md
│   ├── 01-部署指南.md
│   ├── 02-配置指南.md
│   ├── 03-监控指南.md
│   └── 04-故障排查.md
├── 03-参考_Reference/               # 信息导向
│   ├── README.md
│   ├── 01-项目架构说明.md
│   ├── 02-API接口文档-公共.md
│   ├── 02-API接口文档-Admin.md
│   ├── 02-API接口文档-Agent.md
│   ├── 02-API接口文档-Call.md
│   ├── 02-API接口文档-Game.md
│   ├── 02-API接口文档-Player.md
│   ├── 02-API接口文档-SDK.md
│   ├── 03-配置文件说明.md
│   ├── 04-安全机制说明.md
│   ├── 05-业务逻辑说明.md
│   ├── 06-功能模块说明.md
│   ├── 07-数据库模式文档.md
│   ├── 08-SendItem模块说明.md
│   ├── 10-Voice语音识别模块.md
│   ├── 11-Duty活动模块.md
│   └── 12-转区服务说明.md
├── 04-解释_Explanation/             # 理解导向
│   ├── README.md
│   ├── 01-安全修复记录总览.md
│   └── archive/
│       └── 历史报告/
│           └── 文档优化执行报告_2026-02-21.md
└── meta/
    ├── README.md
    ├── CHANGELOG.md
    └── CONTRIBUTING.md
```

### Diátaxis 框架说明

| 目录 | 用途 | 受众 |
|------|------|------|
| 01-教程_Tutorials | 学习导向，帮助用户从零开始学习 | 新手、初学者 |
| 02-操作指南_How-To-Guides | 任务导向，解决具体实际问题 | 运维人员、开发者 |
| 03-参考_Reference | 信息导向，提供技术参考资料 | 所有技术人员 |
| 04-解释_Explanation | 理解导向，解释背景和原理 | 所有人员 |

---

## 2. 快速导航

### 2.1 新成员入门

1. [`03-参考_Reference/01-项目架构说明.md`](01-教程_Tutorials/02-开发者指南/01-项目结构认知.md)
2. [`03-参考_Reference/03-配置文件说明.md`](03-参考_Reference/03-配置文件说明.md)
3. [`03-参考_Reference/02-API接口文档-公共.md`](03-参考_Reference/02-API接口文档-公共.md)
4. [`02-操作指南_How-To-Guides/01-部署指南.md`](02-操作指南_How-To-Guides/01-部署指南.md)

### 2.2 开发人员

1. [`01-教程_Tutorials/02-开发者指南/01-项目结构认知.md`](01-教程_Tutorials/02-开发者指南/01-项目结构认知.md)
2. [`03-参考_Reference/02-API接口文档-公共.md`](03-参考_Reference/02-API接口文档-公共.md)
3. [`03-参考_Reference/02-API接口文档-Admin.md`](03-参考_Reference/02-API接口文档-Admin.md)
4. [`03-参考_Reference/02-API接口文档-Agent.md`](03-参考_Reference/02-API接口文档-Agent.md)
5. [`03-参考_Reference/02-API接口文档-Player.md`](03-参考_Reference/02-API接口文档-Player.md)
6. [`03-参考_Reference/02-API接口文档-SDK.md`](03-参考_Reference/02-API接口文档-SDK.md)
7. [`03-参考_Reference/05-业务逻辑说明.md`](03-参考_Reference/05-业务逻辑说明.md)
8. [`03-参考_Reference/07-数据库模式文档.md`](03-参考_Reference/07-数据库模式文档.md)

### 2.3 安全审计

1. [`04-解释_Explanation/01-安全修复记录总览.md`](04-解释_Explanation/01-安全修复记录总览.md)
2. [`03-参考_Reference/04-安全机制说明.md`](03-参考_Reference/04-安全机制说明.md)
3. [`03-参考_Reference/03-配置文件说明.md`](03-参考_Reference/03-配置文件说明.md)
4. [`meta/CHANGELOG.md`](meta/CHANGELOG.md)

### 2.4 运维人员

1. [`02-操作指南_How-To-Guides/01-部署指南.md`](02-操作指南_How-To-Guides/01-部署指南.md)
2. [`02-操作指南_How-To-Guides/02-配置指南.md`](02-操作指南_How-To-Guides/02-配置指南.md)
3. [`02-操作指南_How-To-Guides/03-监控指南.md`](02-操作指南_How-To-Guides/03-监控指南.md)
4. [`02-操作指南_How-To-Guides/04-故障排查.md`](02-操作指南_How-To-Guides/04-故障排查.md)

---

## 3. 文档命名与维护约定

### 3.1 命名约定

- 使用简体中文命名，必要时保留英文后缀说明。
- 使用数字前缀控制顺序（如 `01-`、`02-`）。
- 使用 `.md` 作为文档扩展名。

### 3.2 引用约定

推荐在文档中使用以下引用方式：

- 文件：[`app/middleware/Check.php`](../app/middleware/Check.php)
- 文件+行号：[`app/middleware/Check.php:107`](../app/middleware/Check.php:107)
- 函数/方法：[`Check::generateToken()`](../app/middleware/Check.php:107)

### 3.3 维护原则

1. 文档描述必须可被当前代码验证。
2. 历史/兼容路径需显式标注，不得与主链路混写。
3. 当代码行为变化时，优先更新对应主题文档，再更新索引与变更日志。

---

## 4. 关键索引

### 4.1 安全主题

- 总览：[`04-解释_Explanation/01-安全修复记录总览.md`](04-解释_Explanation/01-安全修复记录总览.md)
- 机制：[`03-参考_Reference/04-安全机制说明.md`](03-参考_Reference/04-安全机制说明.md)
- 配置：[`03-参考_Reference/03-配置文件说明.md`](03-参考_Reference/03-配置文件说明.md)

### 4.2 API 主题

- 公共约定：[`03-参考_Reference/02-API接口文档-公共.md`](03-参考_Reference/02-API接口文档-公共.md)
- 分应用接口：
  - [`03-参考_Reference/02-API接口文档-Admin.md`](03-参考_Reference/02-API接口文档-Admin.md)
  - [`03-参考_Reference/02-API接口文档-Agent.md`](03-参考_Reference/02-API接口文档-Agent.md)
  - [`03-参考_Reference/02-API接口文档-Player.md`](03-参考_Reference/02-API接口文档-Player.md)
  - [`03-参考_Reference/02-API接口文档-SDK.md`](03-参考_Reference/02-API接口文档-SDK.md)

### 4.3 业务与数据主题

- 业务：[`03-参考_Reference/05-业务逻辑说明.md`](03-参考_Reference/05-业务逻辑说明.md)
- 转区：[`03-参考_Reference/12-转区服务说明.md`](03-参考_Reference/12-转区服务说明.md)
- 数据库：[`03-参考_Reference/07-数据库模式文档.md`](03-参考_Reference/07-数据库模式文档.md)

### 4.4 文档治理主题

- 索引（本文件）：[`00-README_文档索引_Documentation_Index.md`](00-README_文档索引_Documentation_Index.md)
- 变更日志：[`meta/CHANGELOG.md`](meta/CHANGELOG.md)
- 贡献约定：[`meta/CONTRIBUTING.md`](meta/CONTRIBUTING.md)

---

## 5. 版本记录

| 版本 | 日期 | 说明 |
|---|---|---|
| 3.0.0 | 2026-02-28 | 迁移至 Diátaxis 框架，重组目录结构 |
| 2.0.1 | 2026-02-27 | 重写功能模块说明并补充索引/API细节，按当前控制器与路由链路对齐 |
| 2.0.0 | 2026-02-23 | 清理失效引用（合并 API 文档、不存在归档目录、错误目录编号），按当前仓库结构重写索引 |
| 1.3.0 | 2026-02-21 | API 文档拆分、教程与索引体系补充 |
| 1.2.0 | 2026-02-19 | 文档审计修正 |
| 1.0.0 | 2026-02-06 | 初始文档体系 |
