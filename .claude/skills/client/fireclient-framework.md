---
name: fireclient-framework
version: 1.4.0
priority: high
category: client
description: |
  MT3客户端FireClient框架开发技能。涵盖IApp接口、Manager体系、游戏状态管理、场景管理、网络通信、数据管理、Lua集成、UI管理、调试和日志。
  触发词: FireClient, IApp, Manager, 游戏状态, 场景管理, 网络通信, gnet, xbean, Lua集成, UI管理, GameApplication, GameUIManager, BattleManager, NetConnection, MessageManager, ConfigManager
dependencies:
  - cpp-development
  - nuclear-engine
allowed-tools:
  - Bash
  - Read
  - Edit
  - Grep
  - Glob
recommended-model: claude-3.5-sonnet
estimated-tokens: 14000
---

# FireClient 框架开发技能

**版本**: v1.4.0
**最后更新**: 2026-04-11

---

## 🎯 核心知识点

### 1. FireClient框架架构

#### 架构层级（详细架构见 [cpp-development](cpp-development.md)）

```
Layer 4: FireClient 业务层 (C++)
Layer 3: Nuclear 引擎层 (~17k 行)
Layer 2: Cocos2d-x 2.2.6 层
Layer 1: 平台层 (Win32/Android/iOS)
```

#### 模块划分

- **应用层**: GameApplication, GameScene
- **管理器层**: 16个Manager
- **对象层**: 精灵、特效、动画等
- **系统层**: 网络系统、数据系统
- **引擎层**: Nuclear引擎、Cocos2d-x

### 2. IApp接口

#### 接口定义

```cpp
class IApp {
public:
    virtual bool Initialize() = 0;
    virtual void Update(float dt) = 0;
    virtual void Shutdown() = 0;
};
```

#### 实现规范

```cpp
class GameApplication : public IApp {
public:
    bool Initialize() override {
        // 初始化逻辑
        // 必须返回 true 表示成功
        return true;
    }

    void Update(float dt) override {
        // 每帧更新逻辑
        // dt 是 delta time
    }

    void Shutdown() override {
        // 清理逻辑
        // 必须释放所有资源
    }
};
```

### 3. Manager体系

#### Manager列表

| Manager | 职责 |
|---------|------|
| GameUIManager | UI界面管理 |
| LoginManager | 登录流程管理 |
| BattleManager | 战斗系统管理 |
| MessageManager | 消息系统管理 |
| SceneMovieManager | 场景电影管理 |
| VoiceManager | 语音系统管理 |
| ConfigManager | 配置系统管理 |
| EmotionManager | 表情系统管理 |
| IconManager | 图标系统管理 |
| SpaceManager | 空间系统管理 |
| ArtTextManager | 艺术文本系统管理 |
| TaskOnOffEffectManager | 任务开关特效管理 |
| RoleItemManager | 角色物品系统管理 |
| MainRoleDataManager | 主角数据系统管理 |
| NewRoleGuideManager | 新手引导系统管理 |
| DownloadManager | 下载系统管理 |
| BattleReplayManager | 战斗回放系统管理 |
| ChannelManager | 第三方渠道管理 |

#### Manager初始化顺序

```cpp
bool InitializeManagers() {
    // 按顺序初始化 Manager
    if (!ConfigManager::sharedManager()->init()) {
        return false;
    }

    if (!LoginManager::sharedManager()->init()) {
        return false;
    }

    if (!GameUIManager::sharedManager()->init()) {
        return false;
    }

    if (!BattleManager::sharedManager()->init()) {
        return false;
    }

    // ... 其他 Manager

    return true;
}
```

#### Manager清理顺序

```cpp
void CleanupManagers() {
    // 按相反顺序清理 Manager
    BattleManager::sharedManager()->cleanup();
    GameUIManager::sharedManager()->cleanup();
    LoginManager::sharedManager()->cleanup();
    ConfigManager::sharedManager()->cleanup();

    // ... 其他 Manager
}
```

### 4. 游戏状态管理

#### 游戏状态定义

```cpp
enum class GameState {
    INIT,           // 初始化
    LOGIN,          // 登录
    GAME,           // 游戏中
    BATTLE,         // 战斗中
    LOADING,        // 加载中
    PAUSE           // 暂停
};
```

#### 状态管理

```cpp
// 获取游戏状态管理器
GameStateManager* stateManager = GameStateManager::sharedManager();

// 设置游戏状态
stateManager->setGameState(GameState::LOGIN);

// 获取当前游戏状态
GameState currentState = stateManager->getGameState();

// 监听游戏状态变化
stateManager->registerStateChangeListener([](GameState oldState, GameState newState) {
    printf("State changed: %d -> %d\n", oldState, newState);
});
```

### 5. 场景管理

#### 场景创建

```cpp
// 创建场景
GameScene* scene = GameScene::create();

// 添加到场景管理器
SceneManager::sharedManager()->pushScene(scene);

// 切换场景
SceneManager::sharedManager()->replaceScene(newScene);

// 弹出场景
SceneManager::sharedManager()->popScene();
```

#### 场景切换

```cpp
void EnterScene(int sceneId) {
    // 创建场景
    GameScene* scene = GameScene::create(sceneId);

    // 加载场景资源
    scene->loadResources([](bool success) {
        if (success) {
            // 资源加载完成，切换场景
            SceneManager::sharedManager()->replaceScene(scene);
        } else {
            // 资源加载失败
            GameUIManager::sharedManager()->showError("Failed to load scene");
        }
    });
}
```

### 6. 网络通信（gnet框架）

#### RPC调用

```cpp
// 定义RPC协议
namespace fire.pb.login {
    rpc Login(SLoginArg) returns (SLoginRes);
}

// RPC调用
LoginManager::sharedManager()->login(username, password, [](bool success, const std::string& error) {
    if (success) {
        printf("Login success\n");
    } else {
        printf("Login failed: %s\n", error.c_str());
    }
});
```

#### 协议定义

```xml
<namespace name="fire.pb.login">
    <bean name="SLoginArg">
        <variable name="username" type="string"/>
        <variable name="password" type="string"/>
    </bean>

    <bean name="SLoginRes">
        <variable name="result" type="int"/>
        <variable name="roleid" type="long"/>
    </bean>

    <rpc name="Login" argument="SLoginArg" result="SLoginRes"/>
</namespace>
```

### 7. 数据管理（xbean系统）

#### 数据表定义

```xml
<!-- 物品实体定义 -->
<xbean name="Item">
    <variable name="id" type="int"/>
    <variable name="flags" type="int"/>
    <variable name="position" type="int" default="-1"/>
    <variable name="number" type="int"/>
    <variable name="timeout" type="long" default="0"/>
    <variable name="uniqueid" type="long"/>
</xbean>

<!-- 背包表定义 -->
<table name="bag"
       key="long"
       value="Bag"
       cacheCapacity="7024"
       lock="rolelock"/>
```

#### Procedure事务

```java
public class AddItemProcedure extends Procedure {
    @Override
    protected boolean process() {
        xbean.Bag bag = xtable.Bag.get().select(roleId);
        if (bag == null) return false;

        // 业务逻辑
        xbean.Item item = new xbean.Item();
        item.setId(itemId);
        bag.getItems().put(bag.getNextid(), item);

        return true;  // 提交事务
    }
}
```

### 8. Lua集成（tolua++绑定）

#### Lua调用C++

```lua
-- 获取Manager单例
local uiManager = GameUIManager:sharedManager()
local loginManager = LoginManager:sharedManager()

-- 调用Manager方法
uiManager:showUI("LoginDialog")
loginManager:login(username, password)
```

#### C++调用Lua

```cpp
// 执行Lua脚本
lua_State* L = LuaEngine::sharedEngine()->getLuaState();
luaL_dostring(L, "print('Hello from Lua!')");

// 调用Lua函数
lua_getglobal(L, "OnLoginButtonClick");
lua_pushstring(L, username);
lua_pushstring(L, password);
lua_call(L, 2, 0);
```

### 9. UI管理（CEGUI集成）

#### UI显示/隐藏

```cpp
// 显示UI
GameUIManager::sharedManager()->showUI("LoginDialog");

// 隐藏UI
GameUIManager::sharedManager()->hideUI("LoginDialog");

// 获取UI
CEGUI::Window* ui = GameUIManager::sharedManager()->getUI("LoginDialog");

// 检查UI是否显示
bool isVisible = GameUIManager::sharedManager()->isUIVisible("LoginDialog");
```

#### UI层级管理

```cpp
// 设置UI层级
GameUIManager::sharedManager()->setUILayer("LoginDialog", 10);

// 获取UI层级
int layer = GameUIManager::sharedManager()->getUILayer("LoginDialog");
```

### 10. 调试和日志

#### 日志输出

```cpp
// 信息日志
LOG_INFO("User logged in: %s", username.c_str());

// 警告日志
LOG_WARNING("Login failed: %s", error.c_str());

// 错误日志
LOG_ERROR("Network error: %s", error.c_str());
```

#### 断言检查

```cpp
// 检查前置条件
ASSERT(sprite != nullptr, "Sprite is null");

// 检查后置条件
ASSERT(result == true, "Operation failed");

// 检查不变量
ASSERT(count >= 0, "Count is negative");
```

---

## 🚨 常见陷阱

### 陷阱1: Manager初始化顺序错误

**错误**:
```cpp
// ❌ 错误：初始化顺序错误
if (!GameUIManager::sharedManager()->init()) {
    return false;
}

if (!ConfigManager::sharedManager()->init()) {  // ConfigManager 应该先初始化
    return false;
}
```

**正确**:
```cpp
// ✅ 正确：按正确顺序初始化
if (!ConfigManager::sharedManager()->init()) {  // 先初始化ConfigManager
    return false;
}

if (!GameUIManager::sharedManager()->init()) {
    return false;
}
```

### 陷阱2: 游戏状态转换失败

**错误**:
```cpp
// ❌ 错误：状态转换规则不满足
GameStateManager::sharedManager()->setGameState(GameState::BATTLE);
// 当前状态是LOGIN，不能直接转换到BATTLE
```

**正确**:
```cpp
// ✅ 正确：检查状态转换规则
if (GameStateManager::sharedManager()->canTransitionTo(GameState::BATTLE)) {
    GameStateManager::sharedManager()->setGameState(GameState::BATTLE);
} else {
    printf("Cannot transition to BATTLE from current state\n");
}
```

### 陷阱3: 线程安全问题

**错误**:
```cpp
// ❌ 错误：在非主线程调用Manager
std::thread workerThread([]() {
    GameUIManager::sharedManager()->showUI("LoginDialog");  // 线程不安全！
});
```

**正确**:
```cpp
// ✅ 正确：在主线程调用Manager
void OnWorkerThreadComplete() {
    GameUIManager::sharedManager()->showUI("LoginDialog");  // 主线程安全
}
```

### 陷阱4: 内存泄漏

**错误**:
```cpp
// ❌ 错误：忘记释放场景
GameScene* scene = GameScene::create();
SceneManager::sharedManager()->pushScene(scene);
// 忘记调用 popScene 或 release
```

**正确**:
```cpp
// ✅ 正确：及时释放场景
GameScene* scene = GameScene::create();
SceneManager::sharedManager()->pushScene(scene);

// 使用场景...
SceneManager::sharedManager()->popScene();
scene->release();
scene = nullptr;
```

---

## 🛠️ 实践项目

### 项目1: 实现登录流程

**目标**: 实现完整的登录流程

**步骤**:
1. 创建登录UI
2. 实现LoginManager
3. 实现网络通信
4. 实现游戏状态转换
5. 实现错误处理

**代码示例**:
```cpp
void OnLoginButtonClick() {
    // 获取登录管理器
    LoginManager* loginManager = LoginManager::sharedManager();

    // 获取用户名和密码
    std::string username = GetUsernameFromUI();
    std::string password = GetPasswordFromUI();

    // 执行登录
    loginManager->login(username, password, [](bool success, const std::string& error) {
        if (success) {
            // 登录成功，切换到游戏状态
            GameStateManager::sharedManager()->setGameState(GameState::GAME);

            // 显示主界面
            GameUIManager::sharedManager()->showUI("MainDialog");
        } else {
            // 登录失败，显示错误提示
            GameUIManager::sharedManager()->showError(error);
        }
    });
}
```

### 项目2: 实现战斗系统

**目标**: 实现完整的战斗系统

**步骤**:
1. 创建BattleManager
2. 实现战斗UI
3. 实现战斗逻辑
4. 实现战斗状态管理
5. 实现战斗回放

**代码示例**:
```cpp
void StartBattle(int battleId) {
    // 获取战斗管理器
    BattleManager* battleManager = BattleManager::sharedManager();

    // 开始战斗
    battleManager->startBattle(battleId, [](bool success) {
        if (success) {
            // 战斗开始成功，切换到战斗状态
            GameStateManager::sharedManager()->setGameState(GameState::BATTLE);

            // 显示战斗UI
            GameUIManager::sharedManager()->showUI("BattleDialog");
        } else {
            // 战斗开始失败
            GameUIManager::sharedManager()->showError("Failed to start battle");
        }
    });
}
```

### 项目3: 实现场景管理系统

**目标**: 实现完整的场景管理系统

**步骤**:
1. 创建SceneManager
2. 实现场景切换
3. 实现场景加载
4. 实现场景缓存
5. 实现场景资源管理

**代码示例**:
```cpp
class SceneManager {
public:
    static SceneManager* sharedManager() {
        static SceneManager instance;
        return &instance;
    }

    void pushScene(GameScene* scene) {
        m_sceneStack.push_back(scene);
        scene->enter();
    }

    void popScene() {
        if (!m_sceneStack.empty()) {
            GameScene* scene = m_sceneStack.back();
            scene->exit();
            m_sceneStack.pop_back();
        }
    }

    void replaceScene(GameScene* newScene) {
        if (!m_sceneStack.empty()) {
            m_sceneStack.back()->exit();
        }
        m_sceneStack.clear();
        m_sceneStack.push_back(newScene);
        newScene->enter();
    }

private:
    std::vector<GameScene*> m_sceneStack;
};
```

---

## 📚 参考资料

### 项目文档
- [FireClient 框架架构文档](../../../.trae/references/fireclient-architecture.md)
- [FireClient 框架开发规则](../../../.roo/rules/fireclient-rules.md)
- [Nuclear 引擎开发技能](nuclear-engine.md)
- [Cocos2d-x 使用指南](cocos2dx-usage.md)
- [CEGUI UI 框架指南](cegui-usage.md)
- [tolua++ 绑定开发](tolua-binding.md)

### 相关技能
- [C++ 开发指南](cpp-development.md)
- [Lua 脚本指南](lua-scripting.md)
- [gnet 框架技能](../server/gnet-framework.md)
- [xbean 系统技能](../server/xbean-system.md)

### 外部资源
- [gnet 网络框架文档](https://github.com/gnet-framework/gnet)
- [xbean 数据系统文档](https://github.com/xbean-framework/xbean)
- [tolua++ 绑定文档](https://www.codenix.com/~tolua/)

---

## ✅ 技能验证清单

### 基础能力
- [ ] 能够实现IApp接口
- [ ] 能够初始化Manager体系
- [ ] 能够清理Manager体系
- [ ] 能够管理游戏状态
- [ ] 能够管理场景

### 进阶能力
- [ ] 能够使用GameUIManager
- [ ] 能够使用LoginManager
- [ ] 能够使用BattleManager
- [ ] 能够使用MessageManager
- [ ] 能够实现网络通信
- [ ] 能够实现数据管理

### 高级能力
- [ ] 能够实现Lua集成
- [ ] 能够实现UI管理
- [ ] 能够实现调试和日志
- [ ] 能够排查内存泄漏问题
- [ ] 能够排查性能瓶颈问题
- [ ] 能够设计新的Manager

### 实践项目
- [ ] 完成项目1：实现登录流程
- [ ] 完成项目2：实现战斗系统
- [ ] 完成项目3：实现场景管理系统

---

## 📝 更新日志

| 版本 | 日期 | 变更 |
|-----|------|------|
| 1.0.0 | 2026-01-27 | 初始版本 |
