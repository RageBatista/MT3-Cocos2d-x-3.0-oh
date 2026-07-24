# FireClient 架构设计文档

> MT3 项目 FireClient 客户端框架架构设计文档

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、架构概述

### 1.1 架构目标

FireClient 是 MT3 项目的核心客户端框架，旨在提供：

1. **模块化设计**: 清晰的模块划分，降低耦合度
2. **可扩展性**: 支持新功能的快速集成
3. **高性能**: 优化渲染和逻辑处理，保证流畅体验
4. **跨平台**: 支持 Windows、Android、iOS 平台
5. **易维护**: 清晰的代码结构和文档

### 1.2 架构原则

FireClient 遵循以下架构原则：

1. **单一职责原则**: 每个模块只负责一个功能
2. **开闭原则**: 对扩展开放，对修改关闭
3. **依赖倒置原则**: 依赖抽象而非具体实现
4. **接口隔离原则**: 使用细粒度接口
5. **最少知识原则**: 模块间最小化依赖

### 1.3 架构层次

FireClient 采用分层架构，从上到下分为：

```
┌─────────────────────────────────────────┐
│           应用层 (Application)            │
│  GameApplication, GameScene, LuaEngine   │
├─────────────────────────────────────────┤
│           管理器层 (Manager)              │
│  GameUIManager, LoginManager, Battle...  │
├─────────────────────────────────────────┤
│           对象层 (SceneObj)               │
│  Character, Npc, Pet, Monster, Item...  │
├─────────────────────────────────────────┤
│           系统层 (System)                │
│  Battle, GameUI, Utils, Network...      │
├─────────────────────────────────────────┤
│           引擎层 (Engine)                │
│  Nuclear, CEGUI, Cocos2d-x, FMOD...     │
└─────────────────────────────────────────┘
```

---

## 二、模块划分

### 2.1 应用层 (Application)

**职责**: 管理应用程序生命周期和全局状态

**核心类**:

| 类名 | 职责 |
|------|------|
| `GameApplication` | 游戏应用主类，管理应用生命周期 |
| `GameScene` | 游戏场景基类，管理场景生命周期 |
| `LuaEngine` | Lua 引擎封装，管理 Lua 脚本执行 |
| `NetConnection` | 网络连接管理，处理网络通信 |
| `GameTimer` | 游戏定时器，管理定时任务 |

**模块依赖**:
- 依赖: 管理器层、引擎层
- 被依赖: 无

### 2.2 管理器层 (Manager)

**职责**: 管理游戏各个子系统

**核心类**:

| 类名 | 职责 |
|------|------|
| `GameUIManager` | 管理 UI 界面 |
| `LoginManager` | 管理登录流程 |
| `BattleManager` | 管理战斗系统 |
| `MessageManager` | 管理消息系统 |
| `SceneMovieManager` | 管理场景电影 |
| `VoiceManager` | 管理语音系统 |
| `SpaceManager` | 管理空间系统 |
| `ConfigManager` | 管理配置系统 |
| `EmotionManager` | 管理表情系统 |
| `IconManager` | 管理图标系统 |
| `ArtTextManager` | 管理艺术文本系统 |
| `TaskOnOffEffectManager` | 管理任务开关特效 |
| `RoleItemManager` | 管理角色物品系统 |
| `MainRoleDataManager` | 管理主角数据系统 |
| `NewRoleGuideManager` | 管理新手引导系统 |
| `DownloadManager` | 管理下载系统 |
| `BattleReplayManager` | 管理战斗回放系统 |
| `ChannelManager` | 管理第三方渠道 |
| `ReportManager` | 管理报告系统 |
| `GameStateManager` | 管理游戏状态 |

**模块依赖**:
- 依赖: 对象层、系统层、引擎层
- 被依赖: 应用层

### 2.3 对象层 (SceneObj)

**职责**: 管理游戏场景中的各种对象

**核心类**:

| 类名 | 职责 |
|------|------|
| `Character` | 角色基类 |
| `MainRole` | 主角类 |
| `Npc` | NPC 类 |
| `Pet` | 宠物类 |
| `Monster` | 怪物类 |
| `Item` | 物品类 |
| `Equipment` | 装备类 |
| `Effect` | 特效类 |
| `SceneObject` | 场景对象基类 |

**模块依赖**:
- 依赖: 系统层、引擎层
- 被依赖: 管理器层

### 2.4 系统层 (System)

**职责**: 提供系统级功能和服务

**核心类**:

| 类名 | 职责 |
|------|------|
| `BattleSystem` | 战斗系统 |
| `GameUISystem` | UI 系统 |
| `NetworkSystem` | 网络系统 |
| `AudioSystem` | 音频系统 |
| `InputSystem` | 输入系统 |
| `RenderSystem` | 渲染系统 |
| `PhysicsSystem` | 物理系统 |
| `AnimationSystem` | 动画系统 |
| `ParticleSystem` | 粒子系统 |
| `PathfindingSystem` | 寻路系统 |

**模块依赖**:
- 依赖: 引擎层
- 被依赖: 对象层、管理器层

### 2.5 引擎层 (Engine)

**职责**: 提供底层引擎功能

**核心类**:

| 类名 | 职责 |
|------|------|
| `Nuclear::Engine` | Nuclear 引擎核心 |
| `CEGUI::System` | CEGUI 系统 |
| `cocos2d::CCDirector` | Cocos2d-x 导演 |
| `FMOD::System` | FMOD 音频系统 |

**模块依赖**:
- 依赖: 无
- 被依赖: 系统层、对象层、管理器层、应用层

---

## 三、模块间依赖关系

### 3.1 依赖图

```
Application (应用层)
    ↓
    Manager (管理器层)
    ↓
    SceneObj (对象层)
    ↓
    System (系统层)
    ↓
    Engine (引擎层)
```

### 3.2 依赖规则

1. **单向依赖**: 上层依赖下层，下层不依赖上层
2. **最小依赖**: 模块间最小化依赖，只依赖必要的模块
3. **接口依赖**: 依赖接口而非具体实现
4. **循环依赖禁止**: 禁止模块间循环依赖

### 3.3 依赖管理

**依赖注入**:

```cpp
class BattleManager {
public:
    void setNetworkSystem(NetworkSystem* network) {
        m_network = network;
    }

    void setRenderSystem(RenderSystem* render) {
        m_render = render;
    }

private:
    NetworkSystem* m_network;
    RenderSystem* m_render;
};
```

**依赖倒置**:

```cpp
// 抽象接口
class IUIManager {
public:
    virtual void showUI(const std::string& name) = 0;
    virtual void hideUI(const std::string& name) = 0;
};

// 具体实现
class GameUIManager : public IUIManager {
public:
    void showUI(const std::string& name) override {
        // 实现
    }

    void hideUI(const std::string& name) override {
        // 实现
    }
};
```

---

## 四、数据流向

### 4.1 输入数据流

```
用户输入
    ↓
InputSystem (输入系统)
    ↓
GameApplication (应用层)
    ↓
Manager (管理器层)
    ↓
SceneObj (对象层)
    ↓
System (系统层)
    ↓
Engine (引擎层)
```

### 4.2 渲染数据流

```
Engine (引擎层)
    ↓
System (系统层)
    ↓
SceneObj (对象层)
    ↓
Manager (管理器层)
    ↓
GameApplication (应用层)
    ↓
屏幕输出
```

### 4.3 网络数据流

```
网络数据
    ↓
NetworkSystem (网络系统)
    ↓
MessageManager (消息管理器)
    ↓
Manager (管理器层)
    ↓
SceneObj (对象层)
    ↓
System (系统层)
    ↓
Engine (引擎层)
```

---

## 五、关键设计模式

### 5.1 单例模式 (Singleton)

**应用场景**: Manager 类

**实现示例**:

```cpp
class GameUIManager {
public:
    static GameUIManager* sharedManager() {
        static GameUIManager instance;
        return &instance;
    }

private:
    GameUIManager() {}
    ~GameUIManager() {}
    GameUIManager(const GameUIManager&) = delete;
    GameUIManager& operator=(const GameUIManager&) = delete;
};
```

### 5.2 观察者模式 (Observer)

**应用场景**: 游戏状态变化监听

**实现示例**:

```cpp
class GameStateManager {
public:
    using StateChangeListener = std::function<void(GameState, GameState)>;

    void registerStateChangeListener(StateChangeListener listener) {
        m_listeners.push_back(listener);
    }

    void setGameState(GameState newState) {
        GameState oldState = m_currentState;
        m_currentState = newState;

        for (auto& listener : m_listeners) {
            listener(oldState, newState);
        }
    }

private:
    GameState m_currentState;
    std::vector<StateChangeListener> m_listeners;
};
```

### 5.3 工厂模式 (Factory)

**应用场景**: 对象创建

**实现示例**:

```cpp
class CharacterFactory {
public:
    static Character* createCharacter(CharacterType type) {
        switch (type) {
            case CharacterType::MAIN_ROLE:
                return new MainRole();
            case CharacterType::NPC:
                return new Npc();
            case CharacterType::MONSTER:
                return new Monster();
            default:
                return nullptr;
        }
    }
};
```

### 5.4 策略模式 (Strategy)

**应用场景**: 战斗策略

**实现示例**:

```cpp
class BattleStrategy {
public:
    virtual void execute(BattleManager* manager) = 0;
};

class AttackStrategy : public BattleStrategy {
public:
    void execute(BattleManager* manager) override {
        // 攻击策略
    }
};

class DefendStrategy : public BattleStrategy {
public:
    void execute(BattleManager* manager) override {
        // 防御策略
    }
};
```

### 5.5 命令模式 (Command)

**应用场景**: 技能释放

**实现示例**:

```cpp
class SkillCommand {
public:
    virtual void execute() = 0;
    virtual void undo() = 0;
};

class FireballCommand : public SkillCommand {
public:
    void execute() override {
        // 释放火球术
    }

    void undo() override {
        // 撤销火球术
    }
};
```

---

## 六、线程模型

### 6.1 主线程

**职责**:
- UI 渲染
- 游戏逻辑
- 输入处理
- Manager 调用

**约束**:
- 所有 Manager 操作必须在主线程执行
- UI 操作必须在主线程执行
- Nuclear 引擎操作必须在主线程执行

### 6.2 网络线程

**职责**:
- 网络数据接收
- 网络数据发送
- 网络事件处理

**约束**:
- 网络线程不能直接调用 Manager
- 网络线程必须通过消息队列与主线程通信

### 6.3 加载线程

**职责**:
- 资源加载
- 资源解压
- 资源验证

**约束**:
- 加载线程不能直接操作 UI
- 加载线程必须通过回调通知主线程

### 6.4 线程通信

**消息队列**:

```cpp
class MessageQueue {
public:
    void post(const Message& message) {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_queue.push(message);
    }

    Message take() {
        std::lock_guard<std::mutex> lock(m_mutex);
        Message message = m_queue.front();
        m_queue.pop();
        return message;
    }

private:
    std::queue<Message> m_queue;
    std::mutex m_mutex;
};
```

---

## 七、内存管理

### 7.1 引用计数

**应用场景**: Cocos2d-x 对象

**实现示例**:

```cpp
class Character : public cocos2d::CCObject {
public:
    static Character* create() {
        Character* character = new Character();
        if (character->init()) {
            character->autorelease();
            return character;
        }
        CC_SAFE_DELETE(character);
        return nullptr;
    }
};
```

### 7.2 智能指针

**应用场景**: C++ 对象

**实现示例**:

```cpp
class BattleManager {
public:
    void addBattler(std::shared_ptr<Battler> battler) {
        m_battlers.push_back(battler);
    }

private:
    std::vector<std::shared_ptr<Battler>> m_battlers;
};
```

### 7.3 对象池

**应用场景**: 频繁创建销毁的对象

**实现示例**:

```cpp
class EffectPool {
public:
    static EffectPool& getInstance() {
        static EffectPool instance;
        return instance;
    }

    Effect* obtain(const std::string& type) {
        if (!m_pool.empty()) {
            Effect* effect = m_pool.back();
            m_pool.pop_back();
            return effect;
        }
        return createEffect(type);
    }

    void recycle(Effect* effect) {
        effect->reset();
        m_pool.push_back(effect);
    }

private:
    std::vector<Effect*> m_pool;
};
```

---

## 八、性能优化

### 8.1 渲染优化

**优化策略**:
- 减少绘制调用
- 使用批处理
- 优化纹理格式
- 使用 LOD (Level of Detail)

### 8.2 逻辑优化

**优化策略**:
- 减少不必要的计算
- 使用空间分区
- 优化碰撞检测
- 使用对象池

### 8.3 内存优化

**优化策略**:
- 及时释放资源
- 使用资源缓存
- 优化纹理大小
- 使用压缩格式

---

## 九、扩展性设计

### 9.1 插件系统

**设计目标**: 支持动态加载插件

**实现示例**:

```cpp
class IPlugin {
public:
    virtual void onLoad() = 0;
    virtual void onUnload() = 0;
};

class PluginManager {
public:
    void loadPlugin(const std::string& name) {
        IPlugin* plugin = createPlugin(name);
        plugin->onLoad();
        m_plugins.push_back(plugin);
    }

    void unloadPlugin(const std::string& name) {
        // 卸载插件
    }

private:
    std::vector<IPlugin*> m_plugins;
};
```

### 9.2 脚本系统

**设计目标**: 支持 Lua 脚本扩展

**实现示例**:

```cpp
class LuaScriptManager {
public:
    void executeScript(const std::string& script) {
        lua_State* L = m_luaEngine->getLuaState();
        luaL_dostring(L, script.c_str());
    }

    void registerFunction(const std::string& name, lua_CFunction func) {
        lua_State* L = m_luaEngine->getLuaState();
        lua_register(L, name.c_str(), func);
    }

private:
    LuaEngine* m_luaEngine;
};
```

---

## 十、跨平台适配

### 10.1 平台抽象层

**设计目标**: 屏蔽平台差异

**实现示例**:

```cpp
class Platform {
public:
    virtual std::string getDocumentsPath() = 0;
    virtual std::string getCachePath() = 0;
    virtual void showMessageBox(const std::string& title, const std::string& message) = 0;
};

class Win32Platform : public Platform {
public:
    std::string getDocumentsPath() override {
        // Windows 实现
    }

    std::string getCachePath() override {
        // Windows 实现
    }

    void showMessageBox(const std::string& title, const std::string& message) override {
        // Windows 实现
    }
};

class AndroidPlatform : public Platform {
public:
    std::string getDocumentsPath() override {
        // Android 实现
    }

    std::string getCachePath() override {
        // Android 实现
    }

    void showMessageBox(const std::string& title, const std::string& message) override {
        // Android 实现
    }
};
```

### 10.2 平台特定代码

**使用条件编译**:

```cpp
#if defined(_WIN32)
    // Windows 平台代码
#elif defined(ANDROID)
    // Android 平台代码
#elif defined(IOS)
    // iOS 平台代码
#endif
```

---

## 十一、错误处理

### 11.1 错误类型

| 错误类型 | 说明 | 处理方式 |
|----------|------|----------|
| 初始化错误 | Manager 初始化失败 | 记录日志，退出应用 |
| 运行时错误 | 运行时异常 | 捕获异常，记录日志，恢复状态 |
| 网络错误 | 网络连接失败 | 重试，显示错误提示 |
| 资源错误 | 资源加载失败 | 使用默认资源，显示错误提示 |

### 11.2 错误处理机制

**错误回调**:

```cpp
class ErrorManager {
public:
    using ErrorCallback = std::function<void(const Error& error)>;

    void registerErrorCallback(ErrorCallback callback) {
        m_callback = callback;
    }

    void reportError(const Error& error) {
        if (m_callback) {
            m_callback(error);
        }
    }

private:
    ErrorCallback m_callback;
};
```

---

## 十二、日志系统

### 12.1 日志级别

| 级别 | 说明 | 使用场景 |
|------|------|----------|
| DEBUG | 调试信息 | 开发调试 |
| INFO | 一般信息 | 正常运行信息 |
| WARNING | 警告信息 | 潜在问题 |
| ERROR | 错误信息 | 错误发生 |
| FATAL | 致命错误 | 程序崩溃 |

### 12.2 日志输出

**实现示例**:

```cpp
class Logger {
public:
    enum class Level {
        DEBUG,
        INFO,
        WARNING,
        ERROR,
        FATAL
    };

    static void log(Level level, const std::string& message) {
        std::string levelStr = getLevelString(level);
        std::string timestamp = getTimestamp();
        printf("[%s] [%s] %s\n", timestamp.c_str(), levelStr.c_str(), message.c_str());
    }

private:
    static std::string getLevelString(Level level) {
        switch (level) {
            case Level::DEBUG: return "DEBUG";
            case Level::INFO: return "INFO";
            case Level::WARNING: return "WARNING";
            case Level::ERROR: return "ERROR";
            case Level::FATAL: return "FATAL";
            default: return "UNKNOWN";
        }
    }

    static std::string getTimestamp() {
        time_t now = time(nullptr);
        char buffer[80];
        strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", localtime(&now));
        return buffer;
    }
};
```

---

## 十三、测试策略

### 13.1 单元测试

**测试框架**: Google Test

**测试示例**:

```cpp
TEST(GameUIManagerTest, ShowUI) {
    GameUIManager* manager = GameUIManager::sharedManager();
    manager->init();

    manager->showUI("TestDialog");
    EXPECT_TRUE(manager->isUIVisible("TestDialog"));

    manager->cleanup();
}
```

### 13.2 集成测试

**测试场景**: Manager 间协作

**测试示例**:

```cpp
TEST(IntegrationTest, LoginFlow) {
    LoginManager::sharedManager()->init();
    GameUIManager::sharedManager()->init();

    LoginManager::sharedManager()->login("test", "test", [](bool success, const std::string& error) {
        EXPECT_TRUE(success);
        EXPECT_TRUE(GameUIManager::sharedManager()->isUIVisible("MainDialog"));
    });
}
```

---

## 十四、部署与发布

### 14.1 构建配置

| 配置 | 说明 |
|------|------|
| Debug | 调试版本，包含调试信息 |
| Release | 发布版本，优化性能 |
| Distribution | 分发版本，去除调试信息 |

### 14.2 版本管理

**版本号格式**: `MAJOR.MINOR.PATCH`

- `MAJOR`: 主版本号，重大更新
- `MINOR`: 次版本号，功能更新
- `PATCH`: 补丁版本号，Bug 修复

---

## 十五、参考资料

- [FireClient 技能文档](../skills/fireclient/SKILL.md)
- [Manager 使用指南](../references/manager-guide.md)
- [公共约束](../references/common-constraints.md)
- [Nuclear 集成指南](../references/nuclear-integration.md)
- [性能优化指南](../references/performance-guide.md)
