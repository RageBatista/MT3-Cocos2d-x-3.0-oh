# 04-操作流程文档 Operation Workflow Document

## 1. 概述 Overview

本文档详细说明Nuclear Engine的完整操作流程，包括引擎初始化、精灵管理、特效管理、地图管理、资源管理等核心功能的操作步骤和最佳实践。

This document provides a detailed description of the complete operation workflow of Nuclear Engine, including engine initialization, sprite management, effect management, map management, resource management, and other core functions' operation steps and best practices.

## 2. 引擎初始化流程 Engine Initialization Workflow

### 2.1 完整初始化流程 Complete Initialization Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 创建应用程序实例                      │
│         Create Application Instance                   │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 配置引擎参数                         │
│          Configure Engine Parameters                  │
│  - 窗口标题、类名                                  │
│  - 显示模式（分辨率、色深）                          │
│  - 异步加载开关                                    │
│  - 抗锯齿类型                                      │
│  - 渲染标志                                       │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 设置日志路径                           │
│           Set Log Paths                            │
│  - 信息日志                                        │
│  - 错误日志                                        │
│  - Segmpak日志                                    │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              4. 运行引擎                             │
│              Run Engine                             │
│  - 初始化渲染器                                     │
│  - 初始化管理器                                     │
│  - 调用IApp::OnInit                               │
│  - 进入主循环                                       │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              5. 主循环                               │
│              Main Loop                             │
│  - 处理消息                                       │
│  - 更新逻辑（OnTick）                               │
│  - 渲染（OnRender）                                │
│  - 控制FPS                                        │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              6. 退出引擎                             │
│              Exit Engine                            │
│  - 调用IApp::OnExit                               │
│  - 清理资源                                         │
│  - 释放管理器                                       │
└─────────────────────────────────────────────────────────┘
```

### 2.2 初始化代码示例 Initialization Code Example

```cpp
#include "nuiengine.h"

using namespace Nuclear;

class MyApp : public IApp
{
public:
    virtual bool OnInit()
    {
        // 获取引擎和环境接口
        IEngine* pEngine = GetEngine();
        IWorld* pWorld = pEngine->GetWorld();
        IEnv* pEnv = pEngine->GetEnv();

        // 配置环境参数
        pEnv->SetControlFPS(true);
        pEnv->SetControlFPS(XPWS_ACTIVE, 60);
        pEnv->SetRenderSpriteShadow(true);
        pEnv->SetEnableSurfaceCache(true);

        // 加载地图
        pWorld->LoadMap(L"map1", L"maze1", NULL, true);

        // 创建主角
        m_pPlayer = pWorld->NewSprite(XPSL_MIDDLE1, L"male");
        m_pPlayer->SetLocation(NuclearLocation(100, 100));
        m_pPlayer->SetDefaultAction(L"idle", XPSALT_ASYNC, 1.0f, false);

        // 附加相机
        pWorld->AttachCameraTo(m_pPlayer);

        return true;
    }

    virtual void OnTick(DWORD delta)
    {
        // 更新游戏逻辑
        UpdateGameLogic(delta);
    }

    virtual void OnRender()
    {
        // 渲染游戏画面
        RenderGame();
    }

    virtual void OnExit()
    {
        // 清理资源
        if (m_pPlayer)
        {
            GetEngine()->GetWorld()->DeleteSprite(m_pPlayer);
            m_pPlayer = NULL;
        }
    }

private:
    ISprite* m_pPlayer;
};

int main()
{
    // 获取引擎实例
    IEngine* pEngine = GetEngine();

    // 配置引擎参数
    EngineParameter ep;
    ep.szWindowTitle = L"My Game";
    ep.szClassName = L"MyGameWindow";
    ep.dmode = NuclearDisplayMode(1024, 768, 32);
    ep.bAsyncRead = true;
    ep.bApplictionInBuild = false;
    ep.bHasMaximizbox = true;
    ep.bSizeBox = true;
    ep.bEnableMipMap = true;
    ep.dwRenderFlags = XPCRF_VERTICALSYNC;
    ep.multiSampleType = XPMULTISAMPLE_4_SAMPLES;
    ep.nAppInitStepCount = 1;
    ep.pApp = new MyApp();

    // 设置日志路径
    pEngine->SetInfoLogPath(L"logs/info.log");
    pEngine->SetErrorLogPath(L"logs/error.log");

    // 运行引擎
    pEngine->Run(ep);

    return 0;
}
```

## 3. 精灵管理流程 Sprite Management Workflow

### 3.1 创建精灵流程 Create Sprite Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 获取世界接口                         │
│           Get World Interface                      │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 创建精灵                             │
│            Create Sprite                            │
│  - 指定层级（XPSL_BOTTOM/MIDDLE1/MIDDLE2/TOP）      │
│  - 指定模型名称                                    │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 设置位置和方向                         │
│         Set Position and Direction                  │
│  - SetLocation() 设置位置                              │
│  - SetDirection() 设置方向                            │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              4. 设置默认动作                           │
│           Set Default Action                        │
│  - SetDefaultAction() 设置默认动作                      │
│  - 指定加载类型（同步/异步）                          │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              5. 设置组件（可选）                       │
│          Set Components (Optional)                  │
│  - SetComponent() 设置装备组件                         │
│  - 指定组件ID和资源                                │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              6. 附加特效（可选）                       │
│         Attach Effects (Optional)                    │
│  - SetDurativeEffect() 设置持续特效                    │
│  - 指定特效名称和位置                                │
└─────────────────────────────────────────────────────────┘
```

### 3.2 创建精灵代码示例 Create Sprite Code Example

```cpp
// 获取世界接口
IWorld* pWorld = GetEngine()->GetWorld();

// 创建精灵
ISprite* pSprite = pWorld->NewSprite(XPSL_MIDDLE1, L"male");
if (!pSprite)
{
    // 创建失败处理
    return false;
}

// 设置位置
pSprite->SetLocation(NuclearLocation(100, 100));

// 设置方向
pSprite->SetDirection(XPD_EAST);

// 设置默认动作
pSprite->SetDefaultAction(L"idle", XPSALT_ASYNC, 1.0f, false);

// 设置装备组件
pSprite->SetComponent(0, L"weapon_sword", 0xffffffff);
pSprite->SetComponent(1, L"armor_chest", 0xffffffff);
pSprite->SetComponent(2, L"helmet", 0xffffffff);

// 设置持续特效
pSprite->SetDurativeEffect(L"aura", NuclearPoint(0, -50), 0);

// 设置可见性
pSprite->SetVisible(true);
pSprite->SetEntityVisible(true);
pSprite->SetTitleVisible(true);

// 设置缩放
pSprite->SetScale(1.0f);

// 设置Alpha
pSprite->SetAlpha(255);
```

### 3.3 精灵移动流程 Sprite Movement Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 设置移动速度                           │
│          Set Movement Speed                         │
│  - SetMoveSpeed() 设置速度（像素/毫秒）                 │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 移动到目标点                         │
│           Move to Target Point                      │
│  - MoveTo() 移动到目标点                            │
│  - 指定目标坐标和范围                                │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 监控移动状态                           │
│          Monitor Movement State                      │
│  - IsMoving() 检查是否移动中                         │
│  - GetPath() 获取当前路径                             │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              4. 停止移动（可选）                       │
│          Stop Movement (Optional)                    │
│  - StopMove() 停止移动                               │
└─────────────────────────────────────────────────────────┘
```

### 3.4 精灵移动代码示例 Sprite Movement Code Example

```cpp
// 设置移动速度（像素/毫秒）
pSprite->SetMoveSpeed(0.16f);

// 移动到目标点
int targetX = 500;
int targetY = 500;
int range = 2;  // 范围（逻辑坐标）
pSprite->MoveTo(targetX, targetY, range, NULL, false);

// 检查是否移动中
if (pSprite->IsMoving())
{
    // 获取当前路径
    astar::Path path;
    pSprite->GetPath(path);

    // 遍历路径点
    for (auto it = path.begin(); it != path.end(); ++it)
    {
        printf("Path point: (%d, %d)\n", it->x, it->y);
    }
}

// 停止移动
pSprite->StopMove();
```

### 3.5 精灵动作播放流程 Sprite Action Playback Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 播放临时动作                           │
│           Play Temporary Action                      │
│  - PlayAction() 播放临时动作                          │
│  - 指定动作名称和加载类型                              │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 监控动作状态                           │
│          Monitor Action State                       │
│  - GetCurActionName() 获取当前动作名称                   │
│  - GetCurrentFrame() 获取当前帧号                      │
│  - GetTotalFrame() 获取总帧数                         │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 动作完成回调（可选）                     │
│        Action Complete Callback (Optional)             │
│  - 注册SpriteNotify监听动作完成事件                      │
└─────────────────────────────────────────────────────────┘
```

### 3.6 精灵动作播放代码示例 Sprite Action Playback Code Example

```cpp
// 播放临时动作
pSprite->PlayAction(L"walk", XPSALT_ASYNC, 1.0f);

// 检查当前动作
std::wstring curAction = pSprite->GetCurActionName();
printf("Current action: %ls\n", curAction.c_str());

// 检查动作帧信息
int currentFrame = pSprite->GetCurrentFrame();
int totalFrame = pSprite->GetTotalFrame();
printf("Frame: %d / %d\n", currentFrame, totalFrame);

// 获取动作时间
float actionTime;
if (pSprite->GetActionTimeByName(L"walk", actionTime))
{
    printf("Action time: %.2f seconds\n", actionTime);
}

// 注册动作完成通知
class MySpriteNotify : public SpriteNotify
{
public:
    virtual void OnPlayFrame(ISprite* pSprite, const std::wstring &actionName, int frame)
    {
        printf("Frame %d of action %ls\n", frame, actionName.c_str());
    }
};

MySpriteNotify notify;
pSprite->RegisterFrameNotify(&notify, L"walk", 10);  // 第10帧触发
```

### 3.7 删除精灵流程 Delete Sprite Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 停止精灵动作和移动                     │
│      Stop Sprite Action and Movement               │
│  - StopMove() 停止移动                               │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 移除精灵特效                           │
│          Remove Sprite Effects                      │
│  - RemoveDurativeEffect() 移除持续特效                   │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 删除精灵                               │
│            Delete Sprite                             │
│  - DeleteSprite() 删除精灵                            │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              4. 清空指针                               │
│          Clear Pointer                             │
│  - pSprite = NULL                                   │
└─────────────────────────────────────────────────────────┘
```

### 3.8 删除精灵代码示例 Delete Sprite Code Example

```cpp
// 停止移动
pSprite->StopMove();

// 移除持续特效
// 需要保存特效指针
std::vector<IEffect*> effects;
// ... 获取特效列表 ...
for (auto pEffect : effects)
{
    pSprite->RemoveDurativeEffect(pEffect);
}

// 删除精灵
GetEngine()->GetWorld()->DeleteSprite(pSprite);

// 清空指针
pSprite = NULL;
```

## 4. 特效管理流程 Effect Management Workflow

### 4.1 创建场景特效流程 Create Scene Effect Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 获取世界接口                         │
│           Get World Interface                      │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 创建特效                             │
│            Create Effect                            │
│  - SetEffect() 创建普通特效                            │
│  - SetLinkedEffect() 创建链接特效                       │
│  - SetContinueEffect() 创建连续特效                     │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 设置特效属性                           │
│          Set Effect Properties                      │
│  - SetLocation() 设置位置                              │
│  - SetDirection() 设置方向                            │
│  - SetScale() 设置缩放                                │
│  - SetVertexColor() 设置颜色                           │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              4. 控制特效播放                           │
│          Control Effect Playback                    │
│  - Play() 播放                                      │
│  - Stop() 停止                                      │
│  - Pause() 暂停                                     │
│  - Resume() 恢复                                    │
└─────────────────────────────────────────────────────────┘
```

### 4.2 创建场景特效代码示例 Create Scene Effect Code Example

```cpp
// 获取世界接口
IWorld* pWorld = GetEngine()->GetWorld();

// 创建普通特效
IEffect* pEffect = pWorld->SetEffect(L"fireball", XPEL_SPRITE, 100, 100, true);
if (pEffect)
{
    // 设置特效属性
    pEffect->SetLocation(NuclearLocation(100, 100));
    pEffect->SetDirection(XPD_EAST);
    pEffect->SetScale(1.5f, 1.5f);
    pEffect->SetVertexColor(0xffffffff);

    // 设置声音
    pEffect->SetSoundType(1);
    pEffect->SetSoundPriority(50);

    // 播放特效
    pEffect->Play();
}

// 创建链接特效
IEffect* pLinkedEffect = pWorld->SetLinkedEffect(
    L"lightning", XPEL_SPRITE,
    NuclearPoint(100, 100), NuclearPoint(200, 200),
    -1.0f,  // 循环播放
    true
);

// 创建连续特效
IEffect* pContinueEffect = pWorld->SetContinueEffect(
    L"trail_head", L"trail_mid", L"trail_end",
    5000,  // 持续5秒
    XPEL_SPRITE, 150, 150, true
);

// 播放一次性特效
IEffect* pOneTimeEffect = pWorld->PlayEffect(
    L"explosion", XPEL_SPRITE,
    200, 200, 1,  // 播放1次
    true, 0
);
```

### 4.3 创建精灵特效流程 Create Sprite Effect Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 获取精灵对象                         │
│           Get Sprite Object                        │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 创建持续特效                           │
│         Create Durative Effect                      │
│  - SetDurativeEffect() 创建持续特效                     │
│  - 指定特效名称和相对位置                            │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 创建临时特效（可选）                     │
│       Create Temporary Effect (Optional)             │
│  - PlayEffect() 播放临时特效                          │
│  - 指定特效名称和播放次数                            │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              4. 移除特效（可选）                       │
│          Remove Effect (Optional)                    │
│  - RemoveDurativeEffect() 移除持续特效                   │
└─────────────────────────────────────────────────────────┘
```

### 4.4 创建精灵特效代码示例 Create Sprite Effect Code Example

```cpp
// 创建持续特效
IEffect* pDurativeEffect = pSprite->SetDurativeEffect(
    L"aura",
    NuclearPoint(0, -50),  // 相对精灵中心的位置
    0  // 标志
);

// 创建连续特效
IEffect* pContinueEffect = pSprite->SetContinueEffect(
    L"shield_head", L"shield_mid", L"shield_end",
    10000,  // 持续10秒
    NuclearPoint(0, 0),
    0
);

// 播放临时特效
IEffect* pTempEffect = pSprite->PlayEffect(
    L"attack_effect",
    20, 20,  // 相对位置
    1,  // 播放1次
    0,  // 标志
    1   // 声音类型
);

// 修改特效位置
pSprite->ChangeEffectOffset(pDurativeEffect, NuclearPoint(0, -60));

// 移除持续特效
pSprite->RemoveDurativeEffect(pDurativeEffect);
```

### 4.5 删除特效流程 Delete Effect Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 停止特效播放                           │
│          Stop Effect Playback                      │
│  - Stop() 停止特效                                  │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 移除特效                               │
│            Remove Effect                             │
│  - RemoveEffect() 移除场景特效                       │
│  - RemoveDurativeEffect() 移除精灵特效                 │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 清空指针                               │
│          Clear Pointer                             │
│  - pEffect = NULL                                   │
└─────────────────────────────────────────────────────────┘
```

### 4.6 删除特效代码示例 Delete Effect Code Example

```cpp
// 停止特效
pEffect->Stop();

// 移除场景特效
GetEngine()->GetWorld()->RemoveEffect(pEffect);

// 移除精灵特效
pSprite->RemoveDurativeEffect(pEffect);

// 清空指针
pEffect = NULL;
```

## 5. 地图管理流程 Map Management Workflow

### 5.1 加载地图流程 Load Map Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 获取世界接口                         │
│           Get World Interface                      │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 加载地图                             │
│              Load Map                             │
│  - LoadMap() 加载地图                                │
│  - 指定地图名称和迷宫名称                              │
│  - 指定是否异步加载                                  │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 设置地图参数（可选）                     │
│        Set Map Parameters (Optional)               │
│  - SetMapMaze() 设置迷宫数据                          │
│  - SetMazeMask() 设置迷宫掩码                          │
│  - SetMazeColors() 设置迷宫颜色                        │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              4. 设置游戏时间（可选）                     │
│        Set Game Time (Optional)                   │
│  - SetGameTime() 设置游戏时间                          │
│  - SetGameTimeCycle() 设置游戏时间周期                   │
└─────────────────────────────────────────────────────────┘
```

### 5.2 加载地图代码示例 Load Map Code Example

```cpp
// 获取世界接口
IWorld* pWorld = GetEngine()->GetWorld();

// 加载地图
bool success = pWorld->LoadMap(L"map1", L"maze1", NULL, true);
if (!success)
{
    // 加载失败处理
    return false;
}

// 获取地图尺寸
NuclearPoint mapSize;
pWorld->GetMapSize(mapSize);
printf("Map size: %d x %d\n", mapSize.x, mapSize.y);

// 设置迷宫数据（如果有）
// unsigned char mazeData[100][100];
// pWorld->SetMapMaze(mazeData, sizeof(mazeData));

// 设置迷宫掩码
// unsigned char maskData[10][10];
// NuclearRect maskRect(0, 0, 10, 10);
// pWorld->SetMazeMask(maskData, maskRect);

// 设置迷宫颜色
XPMazeColors colors;
colors.color0 = 0xff000000;  // 障碍0的颜色
colors.color1 = 0xff0000ff;  // 障碍1的颜色
colors.color2 = 0xff00ff00;  // 障碍2的颜色
pWorld->SetMazeColors(colors);

// 设置游戏时间
pWorld->SetGameTime(0.5f);  // 中午12点
pWorld->SetGameTimeCycle(7200000);  // 2小时（毫秒）
```

### 5.3 卸载地图流程 Unload Map Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 删除所有精灵                           │
│          Delete All Sprites                        │
│  - DeleteAllSprite() 删除所有精灵                      │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 删除所有特效                           │
│          Delete All Effects                       │
│  - RemoveEffect() 移除所有特效                         │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 卸载地图                             │
│             Unload Map                             │
│  - UnloadMap() 卸载地图                              │
└─────────────────────────────────────────────────────────┘
```

### 5.4 卸载地图代码示例 Unload Map Code Example

```cpp
// 删除所有精灵
GetEngine()->GetWorld()->DeleteAllSprite(XPSL_MIDDLE1, false);

// 删除所有不可移动对象
GetEngine()->GetWorld()->DeleteAllImmovableObj();

// 卸载地图
GetEngine()->GetWorld()->UnloadMap();
```

## 6. 相机管理流程 Camera Management Workflow

### 6.1 附加相机流程 Attach Camera Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 获取世界接口                         │
│           Get World Interface                      │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 附加相机到精灵                       │
│         Attach Camera to Sprite                    │
│  - AttachCameraTo() 附加相机                          │
│  - 指定精灵对象                                    │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 设置视口（可选）                       │
│          Set Viewport (Optional)                    │
│  - SetViewport() 设置视口                              │
│  - 指定目标位置和是否同步资源                         │
└─────────────────────────────────────────────────────────┘
```

### 6.2 附加相机代码示例 Attach Camera Code Example

```cpp
// 获取世界接口
IWorld* pWorld = GetEngine()->GetWorld();

// 附加相机到精灵
pWorld->AttachCameraTo(m_pPlayer);

// 设置视口到指定位置
pWorld->SetViewport(NuclearLocation(500, 500), true);

// 获取当前视口
NuclearRect viewport = pWorld->GetViewport();
printf("Viewport: left=%d, top=%d, right=%d, bottom=%d\n",
           viewport.left, viewport.top, viewport.right, viewport.bottom);
```

## 7. 资源管理流程 Resource Management Workflow

### 7.1 资源预取流程 Resource Prefetch Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 精灵动作预取                         │
│         Sprite Action Prefetch                     │
│  - PrefetchAction() 预取动作资源                      │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 特效资源预取                         │
│          Effect Resource Prefetch                  │
│  - HoldEffect() 持有特效资源                         │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 资源释放（可选）                       │
│       Resource Release (Optional)                   │
│  - ReleaseAction() 释放动作资源                        │
│  - ReleaseEffect() 释放特效资源                        │
└─────────────────────────────────────────────────────────┘
```

### 7.2 资源预取代码示例 Resource Prefetch Code Example

```cpp
// 预取精灵动作资源
ISprite* pSprite = ...;
NuclearPrefetchResult result = pSprite->PrefetchAction(L"walk");
if (result == XP_PREFETCH_SUCCESS)
{
    printf("Action prefetched successfully\n");
}
else if (result == XP_PREFETCH_ALREADY_LOADED)
{
    printf("Action already loaded\n");
}
else
{
    printf("Action prefetch failed\n");
}

// 持有特效资源
GetEngine()->HoldEffect(L"fireball");
GetEngine()->HoldEffect(L"explosion");
GetEngine()->HoldEffect(L"aura");

// 释放特效资源
GetEngine()->ReleaseEffect(L"fireball");
GetEngine()->ReleaseEffect(L"explosion");
GetEngine()->ReleaseEffect(L"aura");

// 持有精灵动作资源
pSprite->HoldAction(L"walk");
pSprite->HoldAction(L"attack");
pSprite->HoldAction(L"skill1");

// 释放精灵动作资源
pSprite->ReleaseAction(L"walk");
pSprite->ReleaseAction(L"attack");
pSprite->ReleaseAction(L"skill1");
```

### 7.3 内存管理流程 Memory Management Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 配置GC参数                           │
│          Configure GC Parameters                    │
│  - SetAniPicGCTime() 设置动画图片GC时间                │
│  - SetAniXapGCTime() 设置动画结构GC时间                │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 监控内存使用                           │
│          Monitor Memory Usage                      │
│  - GetCurMemSize() 获取当前内存使用                      │
│  - GeCurAvailableMemSize() 获取可用内存                   │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 手动触发GC（可选）                     │
│      Manual Trigger GC (Optional)                 │
│  - GCNow() 立即执行GC                               │
└─────────────────────────────────────────────────────────┘
```

### 7.4 内存管理代码示例 Memory Management Code Example

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 配置GC参数
pEnv->SetAniPicGCTime(20000);      // 动画图片GC时间：20秒
pEnv->SetAniXapGCTime(1200000);    // 动画结构GC时间：20分钟

// 配置GC触发阈值
GetEngine()->SetGCMemVolume(500.0f);        // 需要GC的内存阈值：500MB
GetEngine()->SetMustGCMemVolume(600.0f);    // 必须GC的内存阈值：600MB
GetEngine()->SetAvailableMemVolume(100.0f);    // 可用内存阈值：100MB
GetEngine()->SetGCMemFPSValue(30.0f);       // GC触发FPS阈值：30
GetEngine()->SetGetPicNeedFPSValue(20.0f);   // 同步加载图片需要的FPS阈值：20

// 监控内存使用
float curMemSize = GetEngine()->GetCurMemSize();
float availableMemSize = GetEngine()->GeCurAvailableMemSize();
printf("Current memory: %.2f MB, Available: %.2f MB\n",
           curMemSize, availableMemSize);

// 手动触发GC
GetEngine()->GCNow();
```

## 8. 性能优化流程 Performance Optimization Workflow

### 8.1 FPS控制流程 FPS Control Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 启用FPS控制                           │
│          Enable FPS Control                        │
│  - SetControlFPS(true) 启用FPS控制                     │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 设置不同窗口状态的FPS                     │
│     Set FPS for Different Window States            │
│  - SetControlFPS(XPWS_ACTIVE, 60)                   │
│  - SetControlFPS(XPWS_INACTIVE, 30)                 │
│  - SetControlFPS(XPWS_MINIMIZE, 10)                 │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 监控FPS                               │
│          Monitor FPS                               │
│  - GetFPS() 获取当前FPS                               │
│  - GetLatestFPS() 获取最新FPS                          │
└─────────────────────────────────────────────────────────┘
```

### 8.2 FPS控制代码示例 FPS Control Code Example

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 启用FPS控制
pEnv->SetControlFPS(true);

// 设置不同窗口状态的FPS
pEnv->SetControlFPS(XPWS_ACTIVE, 60);      // 激活状态60FPS
pEnv->SetControlFPS(XPWS_INACTIVE, 30);    // 非激活状态30FPS
pEnv->SetControlFPS(XPWS_MINIMIZE, 10);    // 最小化状态10FPS

// 监控FPS
float fps = GetEngine()->GetFPS();
float latestFps = GetEngine()->GetLatestFPS();
printf("Current FPS: %.2f, Latest FPS: %.2f\n", fps, latestFps);

// 重置FPS计数器
GetEngine()->ResetFPSCounter();
```

### 8.2 渲染优化流程 Rendering Optimization Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 启用渲染优化                           │
│          Enable Rendering Optimization               │
│  - SetRenderSpriteShadow() 启用精灵阴影                 │
│  - SetEnableSurfaceCache() 启用地表缓存                │
│  - SetEnableSortMapObjects() 启用地图对象排序            │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 配置半透明效果                         │
│        Configure Translucency Effect                │
│  - SetSpriteTranslucentType() 设置半透明类型              │
│  - SetMaskAlpha() 设置遮罩Alpha                      │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 配置夜晚效果                           │
│        Configure Night Effect                     │
│  - SetRenderNightEffectByShader() 启用Shader夜晚效果        │
│  - SetRenderNightEffectWithRenderTarget() 启用RT夜晚效果   │
└─────────────────────────────────────────────────────────┘
```

### 8.3 渲染优化代码示例 Rendering Optimization Code Example

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 启用渲染优化
pEnv->SetRenderSpriteShadow(true);
pEnv->SetEnableSurfaceCache(true);
pEnv->SetEnableSortMapObjects(true);
pEnv->SetSyncBeforeWater(false);

// 配置半透明效果
pEnv->SetSpriteTranslucentType(XPSTT_ELEMENT_TRANSLUCENT);
pEnv->SetMaskAlpha(0.6f);
pEnv->SetRenderSolidMask(true);

// 配置夜晚效果
pEnv->SetRenderNightEffectByShader(true);
pEnv->SetRenderNightEffectWithRenderTarget(false);

// 配置其他效果
pEnv->SetBlurForTeleport(true);
pEnv->SetEnableMaskPic(false);
pEnv->SetEnableLinkedObjs(true);
```

## 9. 调试流程 Debug Workflow

### 9.1 日志记录流程 Log Recording Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 设置日志路径                           │
│          Set Log Paths                            │
│  - SetInfoLogPath() 设置信息日志路径                     │
│  - SetErrorLogPath() 设置错误日志路径                    │
│  - SetSegmpakLogPath() 设置Segmpak日志路径              │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 记录日志                               │
│              Record Logs                            │
│  - 引擎自动记录日志                                  │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 查看日志                               │
│              View Logs                             │
│  - 打开日志文件查看                                   │
└─────────────────────────────────────────────────────────┘
```

### 9.2 日志记录代码示例 Log Recording Code Example

```cpp
// 获取引擎接口
IEngine* pEngine = GetEngine();

// 设置日志路径
pEngine->SetInfoLogPath(L"logs/info.log");
pEngine->SetErrorLogPath(L"logs/error.log");
pEngine->SetSegmpakLogPath(L"logs/segmpak.log");

// 引擎会自动记录日志到指定文件
```

### 9.3 调试信息显示流程 Debug Info Display Workflow

```
┌─────────────────────────────────────────────────────────┐
│              1. 启用调试信息                           │
│          Enable Debug Info                        │
│  - ShowSpritePath() 显示精灵路径                      │
│  - ShowSpriteTrail() 显示精灵尾迹                    │
│  - ShowMapGrid() 显示迷宫格子                        │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              2. 设置迷宫掩码                           │
│          Set Maze Mask                            │
│  - SetMapMazeMask() 设置迷宫掩码                       │
└─────────────────────────────────────────────────────────┘
                        │
┌─────────────────────────────────────────────────────────┐
│              3. 查看调试信息                           │
│              View Debug Info                        │
│  - 屏幕上显示调试信息                                 │
└─────────────────────────────────────────────────────────┘
```

### 9.4 调试信息显示代码示例 Debug Info Display Code Example

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 启用调试信息
pEnv->ShowSpritePath(true);
pEnv->ShowSpriteTrail(true);
pEnv->ShowMapGrid(true);

// 设置迷宫掩码（只显示特定类型的障碍）
pEnv->SetMapMazeMask(0x01);  // 只显示障碍类型0

// 禁用调试信息
pEnv->ShowSpritePath(false);
pEnv->ShowSpriteTrail(false);
pEnv->ShowMapGrid(false);
pEnv->SetMapMazeMask(0);  // 不显示任何障碍
```

## 10. 完整游戏流程示例 Complete Game Workflow Example

### 10.1 游戏主循环 Game Main Loop

```cpp
class MyGame : public IApp
{
public:
    virtual bool OnInit()
    {
        // 初始化游戏
        InitializeGame();
        return true;
    }

    virtual void OnTick(DWORD delta)
    {
        // 更新游戏逻辑
        UpdateGameLogic(delta);
    }

    virtual void OnRender()
    {
        // 渲染游戏画面
        RenderGame();
    }

    virtual void OnExit()
    {
        // 清理游戏资源
        CleanupGame();
    }

private:
    void InitializeGame()
    {
        // 获取引擎接口
        IEngine* pEngine = GetEngine();
        IWorld* pWorld = pEngine->GetWorld();
        IEnv* pEnv = pEngine->GetEnv();

        // 配置环境
        pEnv->SetControlFPS(true);
        pEnv->SetControlFPS(XPWS_ACTIVE, 60);
        pEnv->SetRenderSpriteShadow(true);
        pEnv->SetEnableSurfaceCache(true);

        // 加载地图
        pWorld->LoadMap(L"map1", L"maze1", NULL, true);

        // 创建主角
        m_pPlayer = pWorld->NewSprite(XPSL_MIDDLE1, L"male");
        m_pPlayer->SetLocation(NuclearLocation(100, 100));
        m_pPlayer->SetDefaultAction(L"idle", XPSALT_ASYNC, 1.0f, false);
        m_pPlayer->SetMoveSpeed(0.16f);

        // 附加相机
        pWorld->AttachCameraTo(m_pPlayer);

        // 预取资源
        m_pPlayer->PrefetchAction(L"walk");
        m_pPlayer->PrefetchAction(L"attack");
        pEngine->HoldEffect(L"fireball");
    }

    void UpdateGameLogic(DWORD delta)
    {
        // 更新主角状态
        UpdatePlayer(delta);

        // 更新敌人AI
        UpdateEnemies(delta);

        // 检测碰撞
        CheckCollisions();

        // 更新UI
        UpdateUI();
    }

    void RenderGame()
    {
        // 引擎自动渲染
        // 可以在这里添加自定义渲染
    }

    void CleanupGame()
    {
        // 删除主角
        if (m_pPlayer)
        {
            GetEngine()->GetWorld()->DeleteSprite(m_pPlayer);
            m_pPlayer = NULL;
        }

        // 卸载地图
        GetEngine()->GetWorld()->UnloadMap();
    }

    void UpdatePlayer(DWORD delta)
    {
        // 处理玩家输入
        HandlePlayerInput();

        // 更新主角状态
        // ...
    }

    void UpdateEnemies(DWORD delta)
    {
        // 更新敌人AI
        // ...
    }

    void CheckCollisions()
    {
        // 检测碰撞
        // ...
    }

    void UpdateUI()
    {
        // 更新UI
        // ...
    }

    void HandlePlayerInput()
    {
        // 处理玩家输入
        // ...
    }

private:
    ISprite* m_pPlayer;
};
```

## 11. 最佳实践 Best Practices

### 11.1 性能优化建议 Performance Optimization Recommendations

1. **异步加载**: 始终使用异步加载资源，避免阻塞主线程
2. **资源预取**: 预取即将使用的资源，提升加载速度
3. **合理GC**: 合理设置GC时间，平衡内存和性能
4. **FPS控制**: 根据设备性能调整FPS，低端设备降低FPS
5. **渲染优化**: 启用各项渲染优化，减少Draw Call

### 11.2 内存管理建议 Memory Management Recommendations

1. **及时释放**: 不再使用的资源及时释放
2. **合理缓存**: 常用资源保持缓存，避免重复加载
3. **监控内存**: 定期检查内存使用情况，及时GC
4. **避免泄漏**: 注意资源引用计数，避免内存泄漏

### 11.3 代码规范建议 Code Style Recommendations

1. **错误检查**: 检查所有API调用的返回值
2. **资源管理**: 使用RAII模式管理资源生命周期
3. **日志记录**: 记录重要操作和错误信息
4. **注释清晰**: 添加清晰的代码注释

### 11.4 调试建议 Debug Recommendations

1. **启用日志**: 开发时启用详细日志，便于问题定位
2. **调试信息**: 使用调试信息功能，监控性能和状态
3. **性能分析**: 使用性能统计功能，分析性能瓶颈
4. **逐步优化**: 先保证功能正确，再进行性能优化
