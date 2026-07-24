# SendItem 模块说明

## 1. 模块概述

### 1.1 功能定位

SendItem 模块是玩家服务中心的核心功能模块，提供玩家物品发放和仙玉充值功能。该模块允许已授权的玩家向自己的游戏角色发送指定的物品和仙玉。

### 1.2 所属应用

- **应用名称**: Player（玩家服务中心）
- **访问路径**: `/player/cdk/senditem`
- **控制器位置**: [`app/player/controller/SendItem.php`](../../app/player/controller/SendItem.php:12)

### 1.3 依赖服务

| 服务 | 位置 | 说明 |
|------|------|------|
| GmService | [`app/player/service/GmService.php`](../../app/player/service/GmService.php:11) | GM命令服务，处理与游戏服务器的通信 |
| ServerService | [`app/player/service/ServerService.php`](../../app/player/service/ServerService.php) | 服务器管理服务，获取区组信息 |
| Gm | [`app/gm/Gm.php`](../../app/gm/Gm.php) | 游戏GM命令底层实现 |

## 2. 功能清单

### 2.1 物品发送功能

| 功能 | 方法 | 说明 |
|------|------|------|
| 物品发送页面 | [`index()`](../../app/player/controller/SendItem.php:24) | 显示物品发送界面，包含区组选择、物品选择 |
| 获取物品列表 | [`getItemList()`](../../app/player/controller/SendItem.php:46) | 返回可发送的物品白名单列表 |
| 发送物品 | [`sendItem()`](../../app/player/controller/SendItem.php:110) | 执行物品发送操作 |
| 预处理操作 | [`prepareOp()`](../../app/player/controller/SendItem.php:67) | 生成操作签名，用于前端请求验证 |

### 2.2 仙玉充值功能

| 功能 | 方法 | 说明 |
|------|------|------|
| 仙玉充值 | [`rechargeXianyu()`](../../app/player/controller/SendItem.php:148) | 为角色充值仙玉（游戏货币） |

### 2.3 区组管理功能

| 功能 | 方法 | 说明 |
|------|------|------|
| 切换区组 | [`switchServer()`](../../app/player/controller/SendItem.php:179) | 切换当前操作的区组 |

### 2.4 物品类型支持

系统支持以下类型的物品发送（通过 [`ccs/`](../../ccs/) 目录下的配置文件定义）：

| 文件名 | 物品类型 |
|--------|----------|
| `effectitem.txt` | 特技特效物品 |
| `equipitem.txt` | 装备物品 |
| `equiptisitem.txt` | 装备强化物品 |
| `plitem.txt` | 普通物品 |
| `sditem.txt` | 神兽物品 |
| `skillitem.txt` | 技能物品 |
| `taozhuang.txt` | 套装物品 |

## 3. 使用说明

### 3.1 访问入口

1. 登录玩家服务中心：`/player/auth/login`
2. 完成角色授权：`/player/cdk/index`
3. 访问物品发送页面：`/player/cdk/senditem`

### 3.2 操作步骤

#### 发送物品

1. **选择区组**：在页面顶部选择目标区组
2. **选择物品**：点击"选择物品"按钮，在弹出的物品列表中选择要发送的物品
3. **输入数量**：输入物品数量（范围：1-9999）
4. **确认发送**：点击"发送物品"按钮完成操作

#### 充值仙玉

1. **选择区组**：确保已选择正确的区组
2. **输入数量**：输入仙玉数量（范围：1-99999999）
3. **快捷选择**：可使用快捷按钮（100/500/1000/5000/10000）
4. **确认充值**：点击"充值仙玉"按钮完成操作

### 3.3 注意事项

1. **登录要求**：必须先完成玩家授权登录，获取角色ID
2. **区组选择**：必须选择有效的区组才能进行操作
3. **物品白名单**：只能发送白名单中的物品，非白名单物品会被拒绝
4. **签名验证**：所有操作需要通过签名验证，防止请求伪造
5. **CSRF校验**：所有 POST 请求需携带 `csrf_token`
6. **操作日志**：所有物品发送和充值操作都会被记录

## 4. 技术实现

### 4.1 与游戏服务器的通信方式

SendItem 模块通过 JMX（Java Management Extensions）与游戏服务器通信：

```
┌─────────────┐      JMX       ┌─────────────┐
│  Web服务器   │ ──────────────>│  游戏服务器  │
│  (PHP)      │                │  (Java)     │
└─────────────┘                └─────────────┘
```

**通信流程**：

1. PHP 通过 `exec()` 调用 `jmxc.jar` 工具
2. JMX 工具连接游戏服务器的 GM 端口
3. 发送 GM 命令（如 `addsuperitem`、`addqian`）
4. 接收并解析返回结果

**关键配置**：

```php
// config/player.php
'jmxc_jar_paths' => [
    root_path() . 'jmxc/jmxc.jar',
],
```

### 4.2 物品ID映射

物品ID通过配置文件进行映射，存储在 [`ccs/`](../../ccs/) 目录：

**文件格式**：
```
# 注释行以#开头
1001 物品名称1
1002 物品名称2
```

**解析逻辑**（[`GmService::getItemList()`](../../app/player/service/GmService.php:123)）：
- 每行格式：`物品ID 物品名称`
- 支持 `#` 开头的注释行
- 自动去重并按ID排序

### 4.3 安全机制

#### 4.3.1 签名验证流程

```
┌──────────┐    1. prepareOp()    ┌──────────┐
│  前端     │ ──────────────────> │  后端     │
│          │ <────────────────── │          │
│          │    ts + sig         │          │
│          │                     │          │
│          │    2. sendItem()    │          │
│          │ ──────────────────> │          │
│          │    + op_ts + op_sig │          │
│          │ <────────────────── │          │
└──────────┘    验证结果          └──────────┘
```

#### 4.3.2 物品Token机制

物品选择时生成带过期时间的 Token：

- 前端选择物品后先调用 `prepareOp(action=sendItem)`；
- 后端将原始 `itemId` 生成受保护 `item_token` 并回传；
- `sendItem` 接口仅接受 `item_token`，拒绝直接传递裸 `itemId`。

```php
// Token 结构：base64(itemId|expireTime|signature)
$token = generateItemToken($itemId);

// Token 验证
[$valid, $itemId, $error] = parseItemToken($token);
```

### 4.4 错误处理

| 错误类型 | 处理方式 |
|----------|----------|
| 未登录 | 重定向到授权页面 |
| 区组未选择 | 返回错误提示 |
| 物品不在白名单 | 返回 "item is not in whitelist" |
| Token过期 | 返回 "item token expired, please refresh" |
| 签名验证失败 | 返回 "签名校验失败" |
| GM命令失败 | 尝试邮件补发，记录日志 |

### 4.5 邮件补发机制

当直接发送物品失败时，系统自动尝试通过游戏邮件补发：

```php
// 发送物品失败时的处理
if (strpos($line, 'success') === false) {
    // 尝试邮件补发
    $mailData['title'] = '系统补发';
    $mailData['content'] = '请到游戏内邮箱查收';
    $mailData['awardContent'] = $itemId . '|' . $number;
    $Game->mail($mailData);
}
```

## 5. 相关配置

### 5.1 配置文件位置

- **主配置**: [`config/player.php`](../../config/player.php:1)
- **转区配置**: [`config/transfer.php`](../../config/transfer.php:1)
- **物品数据**: [`ccs/*.txt`](../../ccs/)

### 5.2 关键配置项

| 配置项 | 位置 | 默认值 | 说明 |
|--------|------|--------|------|
| `op_secret_salt` | [`config/player.php:9`](../../config/player.php:9) | `''`（空字符串） | 操作签名盐值（生产必须配置） |
| `signature_timeout` | [`config/player.php:11`](../../config/player.php:11) | `300` | 签名有效期（秒） |
| `item_whitelist_cache_ttl` | [`config/player.php:14`](../../config/player.php:14) | `3600` | 物品白名单缓存时间 |
| `ccs_dir` | [`config/player.php:20`](../../config/player.php:20) | `root_path() . 'ccs/'` | 物品配置目录 |
| `item_files` | [`config/player.php:23`](../../config/player.php:23) | 物品文件列表 | 可发送的物品类型 |
| `gm_timeout` | [`config/player.php:43`](../../config/player.php:43) | `5` | GM命令超时时间 |

### 5.3 环境变量

在 `.env` 文件中可配置：

```env
# 玩家授权开关
PLAYER_AUTH_ENABLED=true

# 操作签名密钥（生产环境必须修改）
OP_SECRET_SALT=your_secure_salt_here

# 签名超时时间
SIGNATURE_TIMEOUT=300

# 物品白名单缓存时间
ITEM_WHITELIST_CACHE_TTL=3600

# TCP直连模式
TCP_DIRECT_ENABLED=true
```

## 6. 视图文件

### 6.1 页面模板

- **物品发送页面**: [`app/player/view/senditem/index.html`](../../app/player/view/senditem/index.html:1)

### 6.2 页面结构

```
┌────────────────────────────────────────┐
│           当前区组选择                  │
├──────────────────┬─────────────────────┤
│    发送物品       │     仙玉充值         │
│  ┌────────────┐  │  ┌──────────────┐   │
│  │ 物品选择    │  │  │ 数量输入      │   │
│  │ 数量输入    │  │  │ 快捷按钮      │   │
│  │ 发送按钮    │  │  │ 充值按钮      │   │
│  └────────────┘  │  └──────────────┘   │
├──────────────────┴─────────────────────┤
│           物品选择弹窗                   │
│  ┌────────────────────────────────┐    │
│  │ 搜索框 | 物品列表               │    │
│  └────────────────────────────────┘    │
└────────────────────────────────────────┘
```

## 7. 相关文档

- [API接口文档 - Player](02-API接口文档-Player.md)
- [配置文件说明](03-配置文件说明.md)
- [安全机制说明](04-安全机制说明.md)
- [功能模块说明](06-功能模块说明.md)
