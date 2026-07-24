# 安全规则

> **优先级**: 🔴 强制性
> **适用范围**: 所有代码和配置

---

## 禁止提交的文件

### 敏感信息

```yaml
绝对禁止提交:
  - .env, .env.local, .env.production
  - credentials.json, secrets.json
  - *.pem, *.key, *.p12 (私钥文件)
  - config/local/*.xml (本地配置)
  - 包含密码的配置文件
```

### 大型二进制文件

```yaml
避免提交:
  - *.apk (Android 安装包)
  - *.ipa (iOS 安装包)
  - *.dll, *.lib (除非是项目依赖)
  - *.pdb (调试符号)
  - res.zip (资源包)
```

---

## 代码安全

### 输入验证

```cpp
// ✅ 正确: 验证所有外部输入
void Player::setName(const std::string& name) {
    if (name.empty() || name.length() > MAX_NAME_LENGTH) {
        return;  // 拒绝无效输入
    }
    m_name = name;
}

// ❌ 危险: 不验证输入
void Player::setName(const std::string& name) {
    m_name = name;  // 可能导致缓冲区溢出或注入
}
```

```java
// ✅ 正确: 验证玩家 ID
public Player getPlayer(int playerId) {
    if (playerId <= 0 || playerId > MAX_PLAYER_ID) {
        throw new IllegalArgumentException("Invalid player ID");
    }
    return playerMap.get(playerId);
}
```

### SQL 注入防护

```java
// ❌ 危险: 字符串拼接
String sql = "SELECT * FROM players WHERE name = '" + playerName + "'";

// ✅ 正确: 使用参数化查询 (xbean 自动处理)
// xbean 框架已内置防注入机制
```

### XSS 防护

```lua
-- ❌ 危险: 直接显示用户输入
label:setString(playerInput)

-- ✅ 正确: 过滤特殊字符
local function sanitize(input)
    return input:gsub("[<>&\"']", "")
end
label:setString(sanitize(playerInput))
```

---

## 网络安全

### 协议验证

```java
// ✅ 正确: 验证协议来源
public void handleMessage(int playerId, Message msg) {
    // 验证玩家是否已登录
    if (!isPlayerLoggedIn(playerId)) {
        return;
    }

    // 验证消息类型是否合法
    if (!isValidMessageType(msg.getType())) {
        log.warn("Invalid message type from player {}", playerId);
        return;
    }

    // 处理消息
    processMessage(playerId, msg);
}
```

### 频率限制

```java
// ✅ 正确: 限制请求频率
private RateLimiter rateLimiter = new RateLimiter(100, TimeUnit.SECONDS);

public void handleRequest(int playerId, Request req) {
    if (!rateLimiter.tryAcquire(playerId)) {
        log.warn("Rate limit exceeded for player {}", playerId);
        return;
    }
    processRequest(playerId, req);
}
```

---

## 内存安全

### 空指针检查

```cpp
// ✅ 正确: 检查空指针
void GameScene::update(float dt) {
    if (m_player == nullptr) {
        return;
    }
    m_player->update(dt);
}

// ✅ 正确: 使用 CC_SAFE 宏
CC_SAFE_RELEASE_NULL(m_sprite);
```

### 资源释放

```cpp
// ✅ 正确: 确保资源释放
class ResourceLoader {
public:
    ~ResourceLoader() {
        // 析构函数中释放资源
        CC_SAFE_RELEASE_NULL(m_texture);
        CC_SAFE_DELETE(m_buffer);
    }
};
```

---

## 日志安全

### 禁止记录敏感信息

```java
// ❌ 危险: 记录密码
log.info("User login: {} password: {}", username, password);

// ✅ 正确: 不记录敏感信息
log.info("User login: {}", username);
```

### 日志级别

```yaml
生产环境:
  - ERROR: 系统错误，需要立即处理
  - WARN: 潜在问题，需要关注
  - INFO: 重要业务事件

开发环境:
  - 可以启用 DEBUG 级别
```

---

## 安全检查清单

### 代码提交前

- [ ] 没有硬编码的密码或密钥
- [ ] 所有外部输入已验证
- [ ] 没有 SQL 注入风险
- [ ] 空指针已检查
- [ ] 资源已正确释放

### 代码审查时

- [ ] 检查敏感信息泄露
- [ ] 检查输入验证
- [ ] 检查权限控制
- [ ] 检查异常处理

---

**相关文档**:
- [调试技巧](../skills/common/debugging.md)
- [性能优化](../skills/common/performance-optimization.md)
