# Duty 活动模块

> 更新时间：2026-02-23

## 1. 模块概述

Duty 模块提供游戏活动管理和 GM 操作功能。该模块允许通过特定口令执行游戏内管理操作，包括玩家封禁、解封、全服封号等操作。

## 2. 技术架构

### 2.1 核心组件

| 组件 | 说明 |
|------|------|
| `app/index/controller/Duty.php` | 活动/GM 操作控制器 |
| `app/model/User.php` | 用户数据模型 |
| `app/model/Bind.php` | 绑定关系模型 |
| `app/gm/Gm.php` | 游戏 GM 操作类 |

### 2.2 配置文件

- 活动口令定义在控制器中：
  - `knqyyh4mlhqq`
  - `tkqfdepx1d2h`
  - `1vas8frmlmuk`
  - `5xfjorjql5nn`

## 3. API 接口

### 3.1 活动首页

- **路径**：`GET /index/duty/index`
- **说明**：显示活动/GM 操作页面

### 3.2 GM 操作提交

- **路径**：`POST /index/duty/gmSub`
- **说明**：执行 GM 操作
- **请求参数**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| kouling | string | 是 | 操作口令 |
| playerid | int | 是 | 玩家角色ID |
| gmcmd | string | 是 | GM 命令类型 |

- **gmcmd 命令类型**：

| 命令 | 说明 |
|------|------|
| forgmbid | 封禁/解封当前账号 |
| ungmforbid | 解封账号 |
| superforbiduser | 全服封号 |
| superunforbiduser | 全服解封 |

- **响应示例**：
```json
// 成功
{"code": 1, "msg": "封禁成功"}

// 失败
{"code": 0, "msg": "口令不正确"}
```

### 3.3 新活动页面

- **路径**：`GET /index/duty/new`
- **说明**：显示新活动页面

### 3.4 新 GM 操作提交

- **路径**：`POST /index/duty/gmSub1`
- **说明**：执行新 GM 操作

## 4. 业务流程

### 4.1 封禁账号流程

1. 验证操作口令
2. 根据 playerid 查询角色信息
3. 获取角色绑定的用户账号
4. 执行封禁/解封操作
5. 记录操作日志
6. 如需封 IP，将 IP 加入黑名单

### 4.2 全服封号流程

1. 获取玩家所有服务器绑定
2. 遍历所有服务器执行 GM 命令
3. 记录操作日志

## 5. 安全机制

1. **口令验证**：必须使用预定义的口令才能执行操作
2. **参数校验**：验证 playerid 和 gmcmd 参数
3. **角色验证**：验证角色是否存在
4. **IP 保护**：封禁时检查是否与本机 IP 相同
5. **操作日志**：记录所有 GM 操作到日志表

## 6. 相关文档

- [API接口文档-Admin](02-API接口文档-Admin.md)
- [API接口文档-Player](02-API接口文档-Player.md)
- [数据库模式文档](07-数据库模式文档.md)
