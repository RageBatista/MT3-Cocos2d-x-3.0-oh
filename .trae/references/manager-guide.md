# Manager 使用指南

> MT3 项目 Manager 体系使用指南

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、Manager 体系概述

### 1.1 什么是 Manager

Manager 是 FireClient 框架中的核心组件，负责管理游戏中的各个子系统。每个 Manager 都是一个单例，负责特定的功能领域。

### 1.2 Manager 的特点

1. **单例模式**: 每个 Manager 只有一个实例
2. **生命周期管理**: Manager 有明确的初始化和清理顺序
3. **职责单一**: 每个 Manager 只负责一个功能领域
4. **线程不安全**: Manager 不是线程安全的，所有操作必须在主线程执行

### 1.3 Manager 列表

| Manager 名称 | 职责 | 初始化优先级 |
|--------------|------|--------------|
| `ConfigManager` | 配置管理 | 1 |
| `LoginManager` | 登录管理 | 2 |
| `GameUIManager` | UI 管理 | 3 |
| `BattleManager` | 战斗管理 | 4 |
| `MessageManager` | 消息管理 | 5 |
| `SceneMovieManager` | 场景电影管理 | 6 |
| `VoiceManager` | 语音管理 | 7 |
| `SpaceManager` | 空间管理 | 8 |
| `ArtTextManager` | 艺术文本管理 | 9 |
| `IconManager` | 图标管理 | 10 |
| `EmotionManager` | 表情管理 | 11 |
| `TaskOnOffEffectManager` | 任务开关特效管理 | 12 |
| `RoleItemManager` | 角色物品管理 | 13 |
| `MainRoleDataManager` | 主角数据管理 | 14 |
| `NewRoleGuideManager` | 新手引导管理 | 15 |
| `DownloadManager` | 下载管理 | 16 |
| `BattleReplayManager` | 战斗回放管理 | 17 |
| `ChannelManager` | 渠道管理 | 18 |
| `GameStateManager` | 游戏状态管理 | 19 |

---

## 二、Manager 生命周期管理

### 2.1 初始化顺序

Manager 必须按以下顺序初始化：

```cpp
bool InitializeManagers()
{
    // 1. 配置管理（最高优先级）
    if (!ConfigManager::sharedManager()->init()) {
        return false;
    }

    // 2. 登录管理
    if (!LoginManager::sharedManager()->init()) {
        return false;
    }

    // 3. UI 管理
    if (!GameUIManager::sharedManager()->init()) {
        return false;
    }

    // 4. 战斗管理
    if (!BattleManager::sharedManager()->init()) {
        return false;
    }

    // 5. 消息管理
    if (!MessageManager::sharedManager()->init()) {
        return false;
    }

    // 6. 场景电影管理
    if (!SceneMovieManager::sharedManager()->init()) {
        return false;
    }

    // 7. 语音管理
    if (!VoiceManager::sharedManager()->init()) {
        return false;
    }

    // 8. 空间管理
    if (!SpaceManager::sharedManager()->init()) {
        return false;
    }

    // 9. 艺术文本管理
    if (!ArtTextManager::sharedManager()->init()) {
        return false;
    }

    // 10. 图标管理
    if (!IconManager::sharedManager()->init()) {
        return false;
    }

    // 11. 表情管理
    if (!EmotionManager::sharedManager()->init()) {
        return false;
    }

    // 12. 任务开关特效管理
    if (!TaskOnOffEffectManager::sharedManager()->init()) {
        return false;
    }

    // 13. 角色物品管理
    if (!RoleItemManager::sharedManager()->init()) {
        return false;
    }

    // 14. 主角数据管理
    if (!MainRoleDataManager::sharedManager()->init()) {
        return false;
    }

    // 15. 新手引导管理
    if (!NewRoleGuideManager::sharedManager()->init()) {
        return false;
    }

    // 16. 下载管理
    if (!DownloadManager::sharedManager()->init()) {
        return false;
    }

    // 17. 战斗回放管理
    if (!BattleReplayManager::sharedManager()->init()) {
        return false;
    }

    // 18. 渠道管理
    if (!ChannelManager::sharedManager()->init()) {
        return false;
    }

    // 19. 游戏状态管理（最后初始化）
    if (!GameStateManager::sharedManager()->init()) {
        return false;
    }

    return true;
}
```

### 2.2 清理顺序

Manager 必须按相反顺序清理：

```cpp
void CleanupManagers()
{
    // 19. 游戏状态管理（最先清理）
    GameStateManager::sharedManager()->cleanup();

    // 18. 渠道管理
    ChannelManager::sharedManager()->cleanup();

    // 17. 战斗回放管理
    BattleReplayManager::sharedManager()->cleanup();

    // 16. 下载管理
    DownloadManager::sharedManager()->cleanup();

    // 15. 新手引导管理
    NewRoleGuideManager::sharedManager()->cleanup();

    // 14. 主角数据管理
    MainRoleDataManager::sharedManager()->cleanup();

    // 13. 角色物品管理
    RoleItemManager::sharedManager()->cleanup();

    // 12. 任务开关特效管理
    TaskOnOffEffectManager::sharedManager()->cleanup();

    // 11. 表情管理
    EmotionManager::sharedManager()->cleanup();

    // 10. 图标管理
    IconManager::sharedManager()->cleanup();

    // 9. 艺术文本管理
    ArtTextManager::sharedManager()->cleanup();

    // 8. 空间管理
    SpaceManager::sharedManager()->cleanup();

    // 7. 语音管理
    VoiceManager::sharedManager()->cleanup();

    // 6. 场景电影管理
    SceneMovieManager::sharedManager()->cleanup();

    // 5. 消息管理
    MessageManager::sharedManager()->cleanup();

    // 4. 战斗管理
    BattleManager::sharedManager()->cleanup();

    // 3. UI 管理
    GameUIManager::sharedManager()->cleanup();

    // 2. 登录管理
    LoginManager::sharedManager()->cleanup();

    // 1. 配置管理（最后清理）
    ConfigManager::sharedManager()->cleanup();
}
```

### 2.3 初始化检查

在初始化 Manager 时，必须检查初始化是否成功：

```cpp
bool InitializeManagers()
{
    if (!ConfigManager::sharedManager()->init()) {
        printf("ConfigManager init failed\n");
        return false;
    }

    if (!LoginManager::sharedManager()->init()) {
        printf("LoginManager init failed\n");
        ConfigManager::sharedManager()->cleanup();
        return false;
    }

    // ... 其他 Manager

    return true;
}
```

---

## 三、Manager 使用规范

### 3.1 获取 Manager 实例

使用 `sharedManager()` 方法获取 Manager 单例：

```cpp
GameUIManager* uiManager = GameUIManager::sharedManager();
LoginManager* loginManager = LoginManager::sharedManager();
BattleManager* battleManager = BattleManager::sharedManager();
```

### 3.2 检查 Manager 初始化状态

在调用 Manager 方法前，检查 Manager 是否已初始化：

```cpp
void ShowUI(const std::string& uiName)
{
    GameUIManager* uiManager = GameUIManager::sharedManager();

    if (!uiManager->isInitialized()) {
        printf("GameUIManager not initialized\n");
        return;
    }

    uiManager->showUI(uiName);
}
```

### 3.3 错误处理

检查 Manager API 调用的返回值，处理错误情况：

```cpp
void Login(const std::string& username, const std::string& password)
{
    LoginManager* loginManager = LoginManager::sharedManager();

    if (!loginManager->isInitialized()) {
        printf("LoginManager not initialized\n");
        return;
    }

    loginManager->login(username, password, [](bool success, const std::string& error) {
        if (success) {
            printf("Login success\n");
        } else {
            printf("Login failed: %s\n", error.c_str());
        }
    });
}
```

---

## 四、Manager 间协作

### 4.1 Manager 依赖关系

某些 Manager 依赖其他 Manager，必须先初始化被依赖的 Manager：

```
ConfigManager (无依赖)
    ↓
LoginManager (依赖 ConfigManager)
    ↓
GameUIManager (依赖 LoginManager)
    ↓
BattleManager (依赖 GameUIManager)
    ↓
...
```

### 4.2 Manager 间通信

使用消息机制进行 Manager 间通信：

```cpp
// 发送消息
MessageManager::sharedManager()->sendMessage(message);

// 注册消息处理器
MessageManager::sharedManager()->registerMessageHandler(messageType, [](const Message& msg) {
    printf("Received message: %s\n", msg.content.c_str());
});
```

### 4.3 Manager 间协作示例

登录流程中的 Manager 协作：

```cpp
void OnLoginButtonClick()
{
    // 1. LoginManager 执行登录
    LoginManager::sharedManager()->login(username, password, [](bool success, const std::string& error) {
        if (success) {
            // 2. 登录成功，GameStateManager 切换状态
            GameStateManager::sharedManager()->setGameState(GameState::GAME);

            // 3. GameUIManager 显示主界面
            GameUIManager::sharedManager()->hideUI("LoginDialog");
            GameUIManager::sharedManager()->showUI("MainDialog");

            // 4. MainRoleDataManager 加载主角数据
            MainRoleDataManager::sharedManager()->loadData([](bool success) {
                if (success) {
                    printf("Main role data loaded\n");
                }
            });
        } else {
            // 5. 登录失败，GameUIManager 显示错误提示
            GameUIManager::sharedManager()->showError(error);
        }
    });
}
```

---

## 五、常用 Manager 详细说明

### 5.1 GameUIManager

**职责**: 管理 UI 界面

**主要方法**:

```cpp
// 初始化
bool init();

// 清理
void cleanup();

// 显示 UI
void showUI(const std::string& name);

// 隐藏 UI
void hideUI(const std::string& name);

// 获取 UI
CEGUI::Window* getUI(const std::string& name);

// 检查 UI 是否显示
bool isUIVisible(const std::string& name);

// 预加载 UI
void preloadUI(const std::string& name, std::function<void(bool)> callback);

// 检查 UI 是否存在
bool hasUI(const std::string& name);

// 检查是否已初始化
bool isInitialized();
```

**使用示例**:

```cpp
// 显示 UI
GameUIManager::sharedManager()->showUI("LoginDialog");

// 隐藏 UI
GameUIManager::sharedManager()->hideUI("LoginDialog");

// 获取 UI
CEGUI::Window* ui = GameUIManager::sharedManager()->getUI("LoginDialog");
if (ui) {
    ui->setText("Hello");
}

// 检查 UI 是否显示
if (GameUIManager::sharedManager()->isUIVisible("LoginDialog")) {
    printf("LoginDialog is visible\n");
}
```

---

### 5.2 LoginManager

**职责**: 管理登录流程

**主要方法**:

```cpp
// 初始化
bool init();

// 清理
void cleanup();

// 登录
void login(const std::string& username, const std::string& password, std::function<void(bool, const std::string&)> callback);

// 登出
void logout();

// 获取登录状态
bool isLoggedIn();

// 获取用户信息
UserInfo getUserInfo();

// 自动登录
void autoLogin(std::function<void(bool, const std::string&)> callback);

// 检查是否已初始化
bool isInitialized();
```

**使用示例**:

```cpp
// 登录
LoginManager::sharedManager()->login(username, password, [](bool success, const std::string& error) {
    if (success) {
        printf("Login success\n");
    } else {
        printf("Login failed: %s\n", error.c_str());
    }
});

// 获取登录状态
if (LoginManager::sharedManager()->isLoggedIn()) {
    printf("User is logged in\n");
}

// 登出
LoginManager::sharedManager()->logout();

// 自动登录
LoginManager::sharedManager()->autoLogin([](bool success, const std::string& error) {
    if (success) {
        printf("Auto login success\n");
    }
});
```

---

### 5.3 BattleManager

**职责**: 管理战斗系统

**主要方法**:

```cpp
// 初始化
bool init();

// 清理
void cleanup();

// 开始战斗
void startBattle(int battleId, std::function<void(bool)> callback);

// 结束战斗
void endBattle();

// 获取战斗状态
BattleState getBattleState();

// 战斗回放
void startReplay(int replayId);

// 停止回放
void stopReplay();

// 暂停战斗
void pauseBattle();

// 恢复战斗
void resumeBattle();

// 检查是否已初始化
bool isInitialized();
```

**使用示例**:

```cpp
// 开始战斗
BattleManager::sharedManager()->startBattle(battleId, [](bool success) {
    if (success) {
        printf("Battle started\n");
    }
});

// 获取战斗状态
BattleState state = BattleManager::sharedManager()->getBattleState();
if (state == BattleState::FIGHTING) {
    printf("Battle is in progress\n");
}

// 结束战斗
BattleManager::sharedManager()->endBattle();

// 战斗回放
BattleManager::sharedManager()->startReplay(replayId);

// 暂停战斗
BattleManager::sharedManager()->pauseBattle();

// 恢复战斗
BattleManager::sharedManager()->resumeBattle();
```

---

### 5.4 MessageManager

**职责**: 管理消息系统

**主要方法**:

```cpp
// 初始化
bool init();

// 清理
void cleanup();

// 发送消息
void sendMessage(const Message& message);

// 注册消息处理器
void registerMessageHandler(MessageType type, std::function<void(const Message&)> handler);

// 取消消息处理器
void unregisterMessageHandler(MessageType type);

// 检查是否已初始化
bool isInitialized();
```

**使用示例**:

```cpp
// 发送消息
Message message;
message.type = MessageType::CHAT;
message.content = "Hello";
MessageManager::sharedManager()->sendMessage(message);

// 注册消息处理器
MessageManager::sharedManager()->registerMessageHandler(MessageType::CHAT, [](const Message& msg) {
    printf("Received chat message: %s\n", msg.content.c_str());
});

// 取消消息处理器
MessageManager::sharedManager()->unregisterMessageHandler(MessageType::CHAT);
```

---

### 5.5 GameStateManager

**职责**: 管理游戏状态

**主要方法**:

```cpp
// 初始化
bool init();

// 清理
void cleanup();

// 设置游戏状态
void setGameState(GameState state);

// 获取游戏状态
GameState getGameState();

// 检查是否可以转换到指定状态
bool canTransitionTo(GameState state);

// 注册状态变化监听器
void registerStateChangeListener(std::function<void(GameState, GameState)> listener);

// 启用状态转换日志
void enableStateTransitionLog(bool enable);

// 检查是否已初始化
bool isInitialized();
```

**使用示例**:

```cpp
// 设置游戏状态
GameStateManager::sharedManager()->setGameState(GameState::LOGIN);

// 获取游戏状态
GameState state = GameStateManager::sharedManager()->getGameState();

// 检查是否可以转换到指定状态
if (GameStateManager::sharedManager()->canTransitionTo(GameState::GAME)) {
    GameStateManager::sharedManager()->setGameState(GameState::GAME);
}

// 注册状态变化监听器
GameStateManager::sharedManager()->registerStateChangeListener([](GameState oldState, GameState newState) {
    printf("State changed: %d -> %d\n", oldState, newState);
});

// 启用状态转换日志
GameStateManager::sharedManager()->enableStateTransitionLog(true);
```

---

### 5.6 ConfigManager

**职责**: 管理配置系统

**主要方法**:

```cpp
// 初始化
bool init();

// 清理
void cleanup();

// 读取字符串配置
std::string getString(const std::string& key);

// 读取整数配置
int getInt(const std::string& key);

// 读取布尔配置
bool getBool(const std::string& key);

// 读取浮点数配置
float getFloat(const std::string& key);

// 写入字符串配置
void setString(const std::string& key, const std::string& value);

// 写入整数配置
void setInt(const std::string& key, int value);

// 写入布尔配置
void setBool(const std::string& key, bool value);

// 写入浮点数配置
void setFloat(const std::string& key, float value);

// 保存配置
void save();

// 加载配置
void load();

// 检查是否已初始化
bool isInitialized();
```

**使用示例**:

```cpp
// 读取配置
std::string serverAddress = ConfigManager::sharedManager()->getString("server.address");
int serverPort = ConfigManager::sharedManager()->getInt("server.port");
bool enableDebug = ConfigManager::sharedManager()->getBool("debug.enable");

// 写入配置
ConfigManager::sharedManager()->setString("server.address", "127.0.0.1");
ConfigManager::sharedManager()->setInt("server.port", 8080);
ConfigManager::sharedManager()->setBool("debug.enable", true);

// 保存配置
ConfigManager::sharedManager()->save();

// 加载配置
ConfigManager::sharedManager()->load();
```

---

## 六、Manager 最佳实践

### 6.1 初始化最佳实践

```cpp
bool InitializeManagers()
{
    // 1. 按顺序初始化 Manager
    if (!ConfigManager::sharedManager()->init()) {
        printf("ConfigManager init failed\n");
        return false;
    }

    if (!LoginManager::sharedManager()->init()) {
        printf("LoginManager init failed\n");
        ConfigManager::sharedManager()->cleanup();
        return false;
    }

    // ... 其他 Manager

    // 2. 检查所有 Manager 是否初始化成功
    if (!CheckAllManagersInitialized()) {
        printf("Some managers not initialized\n");
        CleanupManagers();
        return false;
    }

    return true;
}
```

### 6.2 清理最佳实践

```cpp
void CleanupManagers()
{
    // 1. 按相反顺序清理 Manager
    GameStateManager::sharedManager()->cleanup();
    ChannelManager::sharedManager()->cleanup();
    // ... 其他 Manager
    ConfigManager::sharedManager()->cleanup();

    // 2. 检查所有 Manager 是否已清理
    if (!CheckAllManagersCleaned()) {
        printf("Some managers not cleaned\n");
    }
}
```

### 6.3 使用最佳实践

```cpp
void UseManager()
{
    // 1. 获取 Manager 实例
    GameUIManager* uiManager = GameUIManager::sharedManager();

    // 2. 检查 Manager 是否已初始化
    if (!uiManager->isInitialized()) {
        printf("GameUIManager not initialized\n");
        return;
    }

    // 3. 调用 Manager 方法
    uiManager->showUI("LoginDialog");

    // 4. 检查返回值
    if (!uiManager->isUIVisible("LoginDialog")) {
        printf("Failed to show UI\n");
        return;
    }
}
```

---

## 七、常见问题

### 7.1 Manager 未初始化

**问题**: 调用 Manager 方法时提示 "Manager not initialized"

**原因**: Manager 未调用 init() 方法

**解决方案**:
```cpp
// 确保按正确顺序初始化 Manager
if (!ConfigManager::sharedManager()->init()) {
    return false;
}

if (!LoginManager::sharedManager()->init()) {
    return false;
}

// ... 其他 Manager

// 检查 Manager 是否已初始化
if (!GameUIManager::sharedManager()->isInitialized()) {
    printf("GameUIManager not initialized\n");
}
```

### 7.2 Manager 清理顺序错误

**问题**: 清理 Manager 时出现崩溃

**原因**: Manager 清理顺序错误

**解决方案**:
```cpp
// 按相反顺序清理 Manager
GameStateManager::sharedManager()->cleanup();
ChannelManager::sharedManager()->cleanup();
// ... 其他 Manager
ConfigManager::sharedManager()->cleanup();
```

### 7.3 Manager 线程安全问题

**问题**: 在子线程中调用 Manager 方法时出现崩溃

**原因**: Manager 不是线程安全的

**解决方案**:
```cpp
// 所有 Manager 操作必须在主线程执行
void OnNetworkThread()
{
    // 错误：在子线程中调用 Manager
    // GameUIManager::sharedManager()->showUI("LoginDialog");

    // 正确：通过消息队列通知主线程
    Message message;
    message.type = MessageType::SHOW_UI;
    message.content = "LoginDialog";
    MessageManager::sharedManager()->sendMessage(message);
}

void OnMainThread()
{
    // 在主线程中处理消息
    MessageManager::sharedManager()->registerMessageHandler(MessageType::SHOW_UI, [](const Message& msg) {
        GameUIManager::sharedManager()->showUI(msg.content);
    });
}
```

---

## 八、参考资料

- [FireClient 技能文档](../skills/fireclient/SKILL.md)
- [FireClient 架构设计](../references/fireclient-architecture.md)
- [公共约束](../references/common-constraints.md)
- [错误处理策略](../references/error-handling.md)
