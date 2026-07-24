---
name: fireclient
description: MT3 项目 FireClient 客户端框架 AI 辅助开发技能
---

# FireClient 客户端框架开发技能

> MT3 项目 FireClient 客户端框架 AI 辅助开发技能

## 何时使用

在以下场景使用本技能：

- 需要使用 FireClient 框架时
- 需要使用 Manager 体系时
- 需要处理游戏状态时
- 需要管理场景时
- 需要处理网络通信时
- 需要管理 UI 时
- 需要处理战斗系统时

## 何时不使用

在以下场景不使用本技能：

- 需要创建 UI 界面时 → 使用 [CEGUI 技能](../cegui/SKILL.md)
- 需要创建游戏场景时 → 使用 [Cocos2d-x 技能](../cocos2dx/SKILL.md)
- 需要使用 Nuclear 引擎时 → 使用 [Nuclear 技能](../nuclear/SKILL.md)
- 需要进行 C++/Lua 绑定时 → 使用 [tolua++ 技能](../tolua/SKILL.md)

## 输入要求

使用本技能前需要满足以下条件：

- 已阅读 [公共约束](../references/common-constraints.md)
- 已阅读 [Nuclear 集成指南](../references/nuclear-integration.md)
- 已熟悉 C++ 和 Lua 语言
- 已配置 Visual Studio 2013 和 v120 工具集
- 已了解 Nuclear 引擎集成

## 关键约束

使用本技能时需要注意以下约束：

- **工具集约束**: 必须使用 v120 (VS2013) 工具集
- **编码约束**: C++ 源码使用 UTF-8 with BOM 编码
- **内存管理**: 使用引用计数管理对象生命周期
- **线程安全**: Manager 不是线程安全的，所有操作必须在主线程执行
- **初始化顺序**: Manager 必须按正确顺序初始化
- **清理顺序**: Manager 必须按相反顺序清理

## 工作流程

### 1. 初始化 FireClient

```cpp
#include "GameApplication.h"
#include "GameUIManager.h"
#include "LoginManager.h"
#include "BattleManager.h"

// 初始化 FireClient
bool InitializeFireClient()
{
    // 1. 初始化游戏应用
    GameApplication* app = GameApplication::sharedApplication();
    if (!app->init()) {
        return false;
    }

    // 2. 初始化 Manager 体系
    if (!InitializeManagers()) {
        return false;
    }

    // 3. 初始化游戏状态
    GameStateManager::sharedManager()->setGameState(GameState::INIT);

    return true;
}

// 初始化 Manager 体系
bool InitializeManagers()
{
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

### 2. 使用 Manager 体系

```cpp
// 获取 Manager 单例
GameUIManager* uiManager = GameUIManager::sharedManager();
LoginManager* loginManager = LoginManager::sharedManager();
BattleManager* battleManager = BattleManager::sharedManager();

// 使用 Manager
uiManager->showUI("LoginDialog");
loginManager->login(username, password);
battleManager->startBattle(battleId);
```

### 3. 处理游戏状态

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

### 4. 管理场景

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

### 5. 清理资源

```cpp
// 清理 FireClient
void CleanupFireClient()
{
    // 1. 清理 Manager 体系（与初始化顺序相反）
    CleanupManagers();

    // 2. 清理游戏应用
    GameApplication::sharedApplication()->cleanup();
}

// 清理 Manager 体系
void CleanupManagers()
{
    // 按相反顺序清理 Manager
    BattleManager::sharedManager()->cleanup();
    GameUIManager::sharedManager()->cleanup();
    LoginManager::sharedManager()->cleanup();
    ConfigManager::sharedManager()->cleanup();

    // ... 其他 Manager
}
```

## Manager 体系

### GameUIManager

**职责**: 管理 UI 界面

**主要功能**:
- 显示/隐藏 UI
- UI 层级管理
- UI 事件处理
- UI 动画管理

**使用示例**:

```cpp
// 显示 UI
GameUIManager::sharedManager()->showUI("LoginDialog");

// 隐藏 UI
GameUIManager::sharedManager()->hideUI("LoginDialog");

// 获取 UI
CEGUI::Window* ui = GameUIManager::sharedManager()->getUI("LoginDialog");

// 检查 UI 是否显示
bool isVisible = GameUIManager::sharedManager()->isUIVisible("LoginDialog");
```

### LoginManager

**职责**: 管理登录流程

**主要功能**:
- 用户登录
- 登录状态管理
- 登录错误处理
- 自动登录

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
bool isLoggedIn = LoginManager::sharedManager()->isLoggedIn();

// 登出
LoginManager::sharedManager()->logout();
```

### BattleManager

**职责**: 管理战斗系统

**主要功能**:
- 战斗开始/结束
- 战斗状态管理
- 战斗数据管理
- 战斗回放

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

// 结束战斗
BattleManager::sharedManager()->endBattle();

// 战斗回放
BattleManager::sharedManager()->startReplay(replayId);
```

### MessageManager

**职责**: 管理消息系统

**主要功能**:
- 消息发送
- 消息接收
- 消息队列管理
- 消息过滤

**使用示例**:

```cpp
// 发送消息
MessageManager::sharedManager()->sendMessage(message);

// 注册消息处理器
MessageManager::sharedManager()->registerMessageHandler(messageType, [](const Message& msg) {
    printf("Received message: %s\n", msg.content.c_str());
});

// 取消消息处理器
MessageManager::sharedManager()->unregisterMessageHandler(messageType);
```

### SceneMovieManager

**职责**: 管理场景电影

**主要功能**:
- 播放场景电影
- 电影状态管理
- 电影跳过
- 电影回调

**使用示例**:

```cpp
// 播放场景电影
SceneMovieManager::sharedManager()->playMovie(movieId, []() {
    printf("Movie finished\n");
});

// 跳过电影
SceneMovieManager::sharedManager()->skipMovie();

// 检查是否正在播放电影
bool isPlaying = SceneMovieManager::sharedManager()->isPlaying();
```

### VoiceManager

**职责**: 管理语音系统

**主要功能**:
- 语音录制
- 语音播放
- 语音上传
- 语音下载

**使用示例**:

```cpp
// 开始录制
VoiceManager::sharedManager()->startRecording();

// 停止录制
VoiceManager::sharedManager()->stopRecording([](const std::string& filePath) {
    printf("Recording saved: %s\n", filePath.c_str());
});

// 播放语音
VoiceManager::sharedManager()->playVoice(voiceId);

// 停止播放
VoiceManager::sharedManager()->stopPlaying();
```

### ConfigManager

**职责**: 管理配置系统

**主要功能**:
- 配置读取
- 配置写入
- 配置缓存
- 配置热更新

**使用示例**:

```cpp
// 读取配置
std::string value = ConfigManager::sharedManager()->getString("key");
int intValue = ConfigManager::sharedManager()->getInt("key");
bool boolValue = ConfigManager::sharedManager()->getBool("key");

// 写入配置
ConfigManager::sharedManager()->setString("key", "value");
ConfigManager::sharedManager()->setInt("key", 123);
ConfigManager::sharedManager()->setBool("key", true);

// 保存配置
ConfigManager::sharedManager()->save();
```

### EmotionManager

**职责**: 管理表情系统

**主要功能**:
- 表情播放
- 表情列表管理
- 表情下载
- 表情缓存

**使用示例**:

```cpp
// 播放表情
EmotionManager::sharedManager()->playEmotion(emotionId);

// 获取表情列表
std::vector<Emotion> emotions = EmotionManager::sharedManager()->getEmotionList();

// 下载表情
EmotionManager::sharedManager()->downloadEmotion(emotionId, [](bool success) {
    if (success) {
        printf("Emotion downloaded\n");
    }
});
```

### IconManager

**职责**: 管理图标系统

**主要功能**:
- 图标加载
- 图标缓存
- 图标释放
- 图标热更新

**使用示例**:

```cpp
// 加载图标
CEGUI::Image* icon = IconManager::sharedManager()->loadIcon(iconId);

// 获取图标
CEGUI::Image* icon = IconManager::sharedManager()->getIcon(iconId);

// 释放图标
IconManager::sharedManager()->releaseIcon(iconId);

// 清理未使用的图标
IconManager::sharedManager()->cleanupUnusedIcons();
```

### SpaceManager

**职责**: 管理空间系统

**主要功能**:
- 空间加载
- 空间切换
- 空间数据管理
- 空间事件

**使用示例**:

```cpp
// 加载空间
SpaceManager::sharedManager()->loadSpace(spaceId, [](bool success) {
    if (success) {
        printf("Space loaded\n");
    }
});

// 切换空间
SpaceManager::sharedManager()->switchSpace(spaceId);

// 获取当前空间
Space* currentSpace = SpaceManager::sharedManager()->getCurrentSpace();
```

### ArtTextManager

**职责**: 管理艺术文本系统

**主要功能**:
- 艺术文本渲染
- 文本特效
- 文本动画
- 文本缓存

**使用示例**:

```cpp
// 创建艺术文本
ArtText* artText = ArtTextManager::sharedManager()->createArtText(text);

// 设置文本特效
artText->setEffect(ArtTextEffect::GLOW);

// 播放文本动画
artText->playAnimation(ArtTextAnimation::FADE_IN);

// 销毁艺术文本
ArtTextManager::sharedManager()->destroyArtText(artText);
```

### TaskOnOffEffectManager

**职责**: 管理任务开关特效

**主要功能**:
- 任务特效播放
- 任务特效停止
- 任务特效列表管理
- 任务特效缓存

**使用示例**:

```cpp
// 播放任务特效
TaskOnOffEffectManager::sharedManager()->playEffect(taskId, effectId);

// 停止任务特效
TaskOnOffEffectManager::sharedManager()->stopEffect(taskId);

// 获取任务特效列表
std::vector<Effect> effects = TaskOnOffEffectManager::sharedManager()->getTaskEffects(taskId);
```

### RoleItemManager

**职责**: 管理角色物品系统

**主要功能**:
- 物品列表管理
- 物品使用
- 物品装备
- 物品丢弃

**使用示例**:

```cpp
// 获取物品列表
std::vector<Item> items = RoleItemManager::sharedManager()->getItems();

// 使用物品
RoleItemManager::sharedManager()->useItem(itemId, [](bool success) {
    if (success) {
        printf("Item used\n");
    }
});

// 装备物品
RoleItemManager::sharedManager()->equipItem(itemId);

// 丢弃物品
RoleItemManager::sharedManager()->dropItem(itemId);
```

### MainRoleDataManager

**职责**: 管理主角数据系统

**主要功能**:
- 主角属性管理
- 主角状态管理
- 主角数据同步
- 主角数据缓存

**使用示例**:

```cpp
// 获取主角属性
RoleAttribute attr = MainRoleDataManager::sharedManager()->getAttribute();

// 更新主角属性
MainRoleDataManager::sharedManager()->updateAttribute(attr);

// 获取主角状态
RoleState state = MainRoleDataManager::sharedManager()->getState();

// 同步主角数据
MainRoleDataManager::sharedManager()->syncData([](bool success) {
    if (success) {
        printf("Data synced\n");
    }
});
```

### NewRoleGuideManager

**职责**: 管理新手引导系统

**主要功能**:
- 引导步骤管理
- 引导显示/隐藏
- 引导完成
- 引导跳过

**使用示例**:

```cpp
// 显示引导
NewRoleGuideManager::sharedManager()->showGuide(guideId);

// 隐藏引导
NewRoleGuideManager::sharedManager()->hideGuide(guideId);

// 完成引导
NewRoleGuideManager::sharedManager()->completeGuide(guideId);

// 跳过引导
NewRoleGuideManager::sharedManager()->skipGuide(guideId);

// 检查引导是否完成
bool isCompleted = NewRoleGuideManager::sharedManager()->isGuideCompleted(guideId);
```

### DownloadManager

**职责**: 管理下载系统

**主要功能**:
- 文件下载
- 下载队列管理
- 下载暂停/恢复
- 下载进度

**使用示例**:

```cpp
// 下载文件
DownloadManager::sharedManager()->downloadFile(url, savePath, [](float progress) {
    printf("Download progress: %.2f%%\n", progress * 100);
}, [](bool success, const std::string& error) {
    if (success) {
        printf("Download success\n");
    } else {
        printf("Download failed: %s\n", error.c_str());
    }
});

// 暂停下载
DownloadManager::sharedManager()->pauseDownload(downloadId);

// 恢复下载
DownloadManager::sharedManager()->resumeDownload(downloadId);

// 取消下载
DownloadManager::sharedManager()->cancelDownload(downloadId);
```

### BattleReplayManager

**职责**: 管理战斗回放系统

**主要功能**:
- 回放录制
- 回放播放
- 回放控制
- 回放保存

**使用示例**:

```cpp
// 开始录制回放
BattleReplayManager::sharedManager()->startRecording();

// 停止录制回放
BattleReplayManager::sharedManager()->stopRecording([](const std::string& replayId) {
    printf("Replay saved: %s\n", replayId.c_str());
});

// 播放回放
BattleReplayManager::sharedManager()->playReplay(replayId);

// 暂停回放
BattleReplayManager::sharedManager()->pauseReplay();

// 恢复回放
BattleReplayManager::sharedManager()->resumeReplay();
```

### ChannelManager

**职责**: 管理第三方渠道

**主要功能**:
- 渠道初始化
- 渠道登录
- 渠道支付
- 渠道分享

**使用示例**:

```cpp
// 初始化渠道
ChannelManager::sharedManager()->initChannel(channelId);

// 渠道登录
ChannelManager::sharedManager()->channelLogin([](bool success, const std::string& token) {
    if (success) {
        printf("Channel login success: %s\n", token.c_str());
    }
});

// 渠道支付
ChannelManager::sharedManager()->channelPay(productId, [](bool success) {
    if (success) {
        printf("Payment success\n");
    }
});

// 渠道分享
ChannelManager::sharedManager()->channelShare(title, content, [](bool success) {
    if (success) {
        printf("Share success\n");
    }
});
```

## 代码示例

### 示例 1: 初始化 FireClient

```cpp
#include "GameApplication.h"
#include "GameUIManager.h"
#include "LoginManager.h"
#include "BattleManager.h"

bool InitializeFireClient()
{
    // 初始化游戏应用
    GameApplication* app = GameApplication::sharedApplication();
    if (!app->init()) {
        return false;
    }

    // 初始化 Manager 体系
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

    // 设置初始游戏状态
    GameStateManager::sharedManager()->setGameState(GameState::INIT);

    return true;
}
```

### 示例 2: 使用 Manager 体系

```cpp
void OnLoginButtonClick()
{
    // 获取登录管理器
    LoginManager* loginManager = LoginManager::sharedManager();

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

### 示例 3: 处理游戏状态转换

```cpp
// 注册游戏状态变化监听
GameStateManager::sharedManager()->registerStateChangeListener([](GameState oldState, GameState newState) {
    switch (newState) {
        case GameState::LOGIN:
            // 进入登录状态
            GameUIManager::sharedManager()->showUI("LoginDialog");
            break;

        case GameState::GAME:
            // 进入游戏状态
            GameUIManager::sharedManager()->hideUI("LoginDialog");
            GameUIManager::sharedManager()->showUI("MainDialog");
            break;

        case GameState::BATTLE:
            // 进入战斗状态
            GameUIManager::sharedManager()->hideUI("MainDialog");
            GameUIManager::sharedManager()->showUI("BattleDialog");
            break;

        default:
            break;
    }
});
```

### 示例 4: 场景管理

```cpp
void EnterScene(int sceneId)
{
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

## 常见错误与解决方案

### 错误 1: Manager 未初始化

**错误信息**:
```
Manager not initialized
```

**原因**:
- Manager 未调用 init() 方法
- Manager 初始化顺序错误

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

---

### 错误 2: 游戏状态转换失败

**错误信息**:
```
State transition failed
```

**原因**:
- 状态转换规则不满足
- 状态转换回调失败

**解决方案**:
```cpp
// 检查状态转换是否允许
if (GameStateManager::sharedManager()->canTransitionTo(newState)) {
    GameStateManager::sharedManager()->setGameState(newState);
} else {
    printf("Cannot transition to state: %d\n", newState);
}

// 使用状态转换回调
GameStateManager::sharedManager()->setGameStateWithCallback(newState, [](bool success) {
    if (!success) {
        printf("State transition failed\n");
    }
});
```

---

### 错误 3: UI 显示失败

**错误信息**:
```
Failed to show UI
```

**原因**:
- UI 资源未加载
- UI 文件不存在
- UI 名称错误

**解决方案**:
```cpp
// 检查 UI 是否存在
if (!GameUIManager::sharedManager()->hasUI("LoginDialog")) {
    printf("UI not found: LoginDialog\n");
    return;
}

// 预加载 UI 资源
GameUIManager::sharedManager()->preloadUI("LoginDialog", [](bool success) {
    if (success) {
        // 资源加载完成，显示 UI
        GameUIManager::sharedManager()->showUI("LoginDialog");
    }
});
```

---

### 错误 4: Manager 清理顺序错误

**错误信息**:
```
Manager cleanup failed
```

**原因**:
- Manager 清理顺序错误
- Manager 依赖关系未正确处理

**解决方案**:
```cpp
// 按相反顺序清理 Manager
BattleManager::sharedManager()->cleanup();
GameUIManager::sharedManager()->cleanup();
LoginManager::sharedManager()->cleanup();
ConfigManager::sharedManager()->cleanup();

// 确保所有 Manager 都已清理
if (BattleManager::sharedManager()->isInitialized()) {
    printf("BattleManager not cleaned up\n");
}
```

## 调试技巧

### 技巧 1: 打印 Manager 状态

```cpp
void PrintManagerStatus()
{
    printf("=== Manager Status ===\n");
    printf("GameUIManager: %s\n", GameUIManager::sharedManager()->isInitialized() ? "Initialized" : "Not Initialized");
    printf("LoginManager: %s\n", LoginManager::sharedManager()->isInitialized() ? "Initialized" : "Not Initialized");
    printf("BattleManager: %s\n", BattleManager::sharedManager()->isInitialized() ? "Initialized" : "Not Initialized");
    printf("GameState: %d\n", GameStateManager::sharedManager()->getGameState());
}
```

### 技巧 2: 调试游戏状态转换

```cpp
// 启用游戏状态转换日志
GameStateManager::sharedManager()->enableStateTransitionLog(true);

// 监听状态转换
GameStateManager::sharedManager()->registerStateChangeListener([](GameState oldState, GameState newState) {
    printf("State transition: %d -> %d\n", oldState, newState);
});
```

### 技巧 3: 调试 UI 显示

```cpp
// 启用 UI 显示日志
GameUIManager::sharedManager()->enableUILog(true);

// 打印 UI 树
GameUIManager::sharedManager()->printUITree();
```

## 性能优化

### 优化 1: 减少 Manager 调用

```cpp
// 错误：频繁调用 Manager
void Update()
{
    GameUIManager::sharedManager()->update();
    LoginManager::sharedManager()->update();
    BattleManager::sharedManager()->update();
}

// 正确：批量更新 Manager
void Update()
{
    std::vector<Manager*> managers = {
        GameUIManager::sharedManager(),
        LoginManager::sharedManager(),
        BattleManager::sharedManager()
    };

    for (auto manager : managers) {
        manager->update();
    }
}
```

### 优化 2: 优化状态转换

```cpp
// 使用状态机优化状态转换
class GameStateMachine {
public:
    void setState(GameState newState) {
        if (canTransition(newState)) {
            m_currentState = newState;
            onStateChanged(newState);
        }
    }

private:
    bool canTransition(GameState newState) {
        // 检查状态转换规则
        return true;
    }

    void onStateChanged(GameState newState) {
        // 处理状态变化
    }

    GameState m_currentState;
};
```

### 优化 3: 使用对象池

```cpp
// 使用对象池复用 UI 对象
class UIObjectPool {
public:
    static UIObjectPool& getInstance() {
        static UIObjectPool instance;
        return instance;
    }

    CEGUI::Window* obtain(const std::string& type) {
        if (!m_pool.empty()) {
            CEGUI::Window* window = m_pool.back();
            m_pool.pop_back();
            return window;
        }
        return createUI(type);
    }

    void recycle(CEGUI::Window* window) {
        window->setVisible(false);
        m_pool.push_back(window);
    }

private:
    std::vector<CEGUI::Window*> m_pool;
};
```

## 注意事项

1. **Manager 生命周期**: Manager 必须按正确顺序初始化和清理
2. **状态管理**: 游戏状态转换必须符合规则
3. **线程安全**: Manager 不是线程安全的，所有操作必须在主线程执行
4. **内存管理**: 使用引用计数管理对象生命周期，避免内存泄漏
5. **错误处理**: 检查所有 Manager API 调用的返回值，处理错误情况
6. **资源管理**: 及时释放不再使用的资源，避免内存占用过高
7. **性能考虑**: 减少 Manager 调用频率，优化状态转换逻辑

## 相关技能

- [Nuclear 引擎技能](../nuclear/SKILL.md) - Nuclear 引擎集成与开发
- [CEGUI 技能](../cegui/SKILL.md) - CEGUI UI 开发
- [Cocos2d-x 技能](../cocos2dx/SKILL.md) - Cocos2d-x 2.0 引擎开发
- [tolua++ 绑定技能](../tolua/SKILL.md) - C++/Lua 绑定开发
- [公共约束](../references/common-constraints.md) - 编码规范与代码风格
- [Nuclear 集成指南](../references/nuclear-integration.md) - Nuclear 引擎集成方法

## 参考资料

- [FireClient 架构设计](../references/fireclient-architecture.md)
- [Manager 使用指南](../references/manager-guide.md)
- [性能优化指南](../references/performance-guide.md)
- [错误处理策略](../references/error-handling.md)
- [调试命令集合](../references/debugging-commands.md)
