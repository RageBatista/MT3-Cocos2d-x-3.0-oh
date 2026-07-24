# 02-API接口文档 API Reference Document

## 1. 概述 Overview

本文档详细描述Nuclear Engine的所有公共API接口，包括引擎核心接口、精灵接口、特效接口、世界接口、环境接口等。

This document provides a detailed description of all public API interfaces in Nuclear Engine, including engine core interfaces, sprite interfaces, effect interfaces, world interfaces, environment interfaces, etc.

## 2. 引擎核心接口 Engine Core Interface

### 2.1 IEngine Interface

引擎主接口，提供引擎初始化、运行控制、资源管理等功能。

The main engine interface providing engine initialization, runtime control, resource management, and other features.

#### 2.1.1 引擎生命周期 Engine Lifecycle

```cpp
// 运行引擎
// Parameters:
//   ep - 引擎参数配置
// Returns: 成功返回true，失败返回false
bool Run(const EngineParameter &ep);

// 退出引擎
// Returns: 成功返回true，失败返回false
bool Exit();
```

#### 2.1.2 屏幕管理 Screen Management

```cpp
// 获取屏幕宽度
// Returns: 屏幕宽度（像素）
int GetScreenWidth();

// 获取屏幕高度
// Returns: 屏幕高度（像素）
int GetScreenHeight();

// 获取逻辑宽度
// Returns: 逻辑宽度
int GetLogicWidth();

// 获取逻辑高度
// Returns: 逻辑高度
int GetLogicHeight();

// 获取渲染宽度
// Returns: 渲染宽度
int GetWidth() const;

// 获取渲染高度
// Returns: 渲染高度
int GetHeight() const;
```

#### 2.1.3 时间管理 Time Management

```cpp
// 设置游戏时间速度缩放
// Parameters:
//   fScale - 时间缩放因子，1.0为正常速度
void SetGameTimeSpeedScale(float fScale);

// 获取游戏时间速度缩放
// Returns: 当前时间缩放因子
float GetGameTimeSpeedScale() const;

// 重置FPS计数器
void ResetFPSCounter();

// 获取当前FPS
// Returns: 当前帧率
float GetFPS() const;

// 获取最新FPS
// Returns: 最新帧率
float GetLatestFPS() const;

// 获取时间计数
// Returns: 时间计数（毫秒）
unsigned int GetTimeCount();
```

#### 2.1.4 核心管理器访问 Core Manager Access

```cpp
// 获取世界接口
// Returns: 世界接口指针
IWorld* GetWorld();

// 获取环境接口
// Returns: 环境接口指针
IEnv* GetEnv();

// 获取应用接口
// Returns: 应用接口指针
IApp* GetApp();

// 获取渲染器
// Returns: 渲染器指针
Renderer* GetRenderer();

// 获取文件IO接口
// Returns: 文件IO接口指针
INuclearFileIO* GetFileIO();

// 获取文件IO管理器
// Returns: 文件IO管理器指针
NuclearFileIOManager* GetFileIOManager();
```

#### 2.1.5 任务调度 Task Scheduling

```cpp
// 提交用户任务到引擎线程
// Parameters:
//   task - 任务对象指针
void PutTask(INuclearRunnable *task);

// 调度定时器
// Parameters:
//   timer - 定时器对象指针
//   period - 定时周期（毫秒）
// Returns: 成功返回true，失败返回false
bool ScheduleTimer(INuclearTimer *timer, int period);

// 取消定时器
// Parameters:
//   timer - 定时器对象指针
// Returns: 成功返回true，失败返回false
bool CancelTimer(INuclearTimer *timer);
```

#### 2.1.6 日志管理 Log Management

```cpp
// 设置信息日志路径
// Parameters:
//   fn - 日志文件路径
// Returns: 成功返回true，失败返回false
bool SetInfoLogPath(const std::wstring &fn);

// 设置错误日志路径
// Parameters:
//   fn - 日志文件路径
// Returns: 成功返回true，失败返回false
bool SetErrorLogPath(const std::wstring &fn);

// 设置Segmpak日志路径
// Parameters:
//   fn - 日志文件路径
// Returns: 成功返回true，失败返回false
bool SetSegmpakLogPath(const std::wstring &fn);
```

#### 2.1.7 内存管理 Memory Management

```cpp
// 立即执行GC
void GCNow();

// 设置GC冷却时间
// Parameters:
//   time - 冷却时间（毫秒）
void setGCCooldown(int time);

// 获取当前进程使用内存
// Returns: 内存大小（MB）
float GetCurMemSize();

// 获取当前进程可用内存
// Returns: 可用内存大小（MB）
float GeCurAvailableMemSize();
```

#### 2.1.8 渲染控制 Rendering Control

```cpp
// 绘制一帧
void Draw();

// 设置清屏颜色
// Parameters:
//   color - 颜色值（ARGB格式）
void SetCleanColor(NuclearColor color);

// 获取清屏颜色
// Returns: 当前清屏颜色
NuclearColor GetCleanColor() const;

// 截图
// Returns: 图片句柄
PictureHandle CaptureWorld();
```

#### 2.1.9 窗口状态 Window State

```cpp
// 获取窗口状态
// Returns: 窗口状态枚举
NuclearWindowState GetWindowState() const;
```

#### 2.1.10 非世界精灵管理 Non-World Sprite Management

非世界精灵用于 UI 等场景外的精灵渲染，通过 `EngineSpriteHandle` 句柄管理。

```cpp
// 创建非世界精灵
// Parameters:
//   modelname - 模型名称
//   async - 是否异步加载
//   isUISprite - 是否为UI精灵
// Returns: 精灵句柄
EngineSpriteHandle CreateEngineSprite(const std::wstring &modelname, bool async, bool isUISprite=false);

// 设置非世界精灵模型
// Parameters:
//   handle - 精灵句柄
//   modelname - 模型名称
//   async - 是否异步加载
// Returns: 成功返回true，失败返回false
bool SetEngineSpriteModel(EngineSpriteHandle handle, const std::wstring &modelname, bool async);

// 释放非世界精灵
// Parameters:
//   handle - 精灵句柄
void ReleaseEngineSprite(EngineSpriteHandle handle);

// 渲染非世界精灵
// Parameters:
//   handle - 精灵句柄
void RendererEngineSprite(EngineSpriteHandle handle);

// 设置非世界精灵位置
// Parameters:
//   handle - 精灵句柄
//   loc - 位置（逻辑坐标）
void SetEngineSpriteLoc(EngineSpriteHandle handle, const NuclearLocation& loc);

// 设置非世界精灵方向（枚举方向）
// Parameters:
//   handle - 精灵句柄
//   dir - 方向枚举
void SetEngineSpriteDirection(EngineSpriteHandle handle, NuclearDirection dir);

// 设置非世界精灵方向（目标点）
// Parameters:
//   handle - 精灵句柄
//   target - 目标点
void SetEngineSpriteDirection(EngineSpriteHandle handle, const NuclearPoint &target);

// 设置非世界精灵默认动作
// Parameters:
//   handle - 精灵句柄
//   actname - 动作名称
void SetEngineSpriteDefaultAction(EngineSpriteHandle handle, const std::wstring &actname);

// 设置非世界精灵临时动作
// Parameters:
//   handle - 精灵句柄
//   actname - 动作名称
void SetEngineSpriteAction(EngineSpriteHandle handle, const std::wstring &actname);

// 设置非世界精灵装备组件
// Parameters:
//   handle - 精灵句柄
//   scid - 组件ID
//   resource - 资源名称
//   color - 颜色（XRGB格式，默认0xffffffff）
void SetEngineSpriteComponent(EngineSpriteHandle handle, int scid, const std::wstring& resource, NuclearColor color = 0xffffffff);

// 启用/禁用非世界精灵阴影
// Parameters:
//   handle - 精灵句柄
//   b - 是否启用
void EnableEngineSpriteShadow(EngineSpriteHandle handle, bool b);

// 设置非世界精灵缩放
// Parameters:
//   handle - 精灵句柄
//   scale - 缩放因子
void SetEngineSpriteScale(EngineSpriteHandle handle, float scale);

// 设置非世界精灵透明度
// Parameters:
//   handle - 精灵句柄
//   alpha - Alpha值[0~255]
void SetEngineSpriteAlpha(EngineSpriteHandle handle, unsigned char alpha);

// 获取非世界精灵动作时长
// Parameters:
//   handle - 精灵句柄
//   action_name - 动作名称
//   time - 输出时间（秒）
// Returns: 成功返回true，失败返回false
bool GetEngineSpriteActionTimeByName(EngineSpriteHandle handle, const std::wstring& action_name, float &time);

// 查找并添加非世界精灵到引擎
// Parameters:
//   handle - 精灵句柄
// Returns: 精灵指针
Sprite* FindAndAddEngineSprite(EngineSpriteHandle handle);
```

#### 2.1.11 非世界精灵特效 Non-World Sprite Effect

```cpp
// 设置非世界精灵持续特效
// Parameters:
//   handle - 精灵句柄
//   effect_name - 特效名称
//   relpos - 相对位置
//   flag - 标志
// Returns: 特效接口指针
IEffect* SetEngineSpriteDurativeEffect(EngineSpriteHandle handle, const std::wstring &effect_name, const NuclearPoint& relpos, unsigned int flag);

// 播放非世界精灵临时特效
// Parameters:
//   handle - 精灵句柄
//   effect_name - 特效名称
//   dx - X偏移
//   dy - Y偏移
//   times - 播放次数
//   flag - 标志
//   soundtype - 声音类型
// Returns: 特效接口指针
IEffect* PlayEngineSpriteEffect(EngineSpriteHandle handle, const std::wstring &effect_name, int dx, int dy, int times, unsigned int flag, unsigned char soundtype);

// 移除非世界精灵持续特效
// Parameters:
//   handle - 精灵句柄
//   pEffect - 特效接口指针
void RemoveEngineSpriteDurativeEffect(EngineSpriteHandle handle, IEffect* pEffect);

// 获取非世界精灵冒泡物件Y偏移
// Parameters:
//   handle - 精灵句柄
// Returns: Y偏移（向上为正）
int GetEngineSpriteBubbleItemOffset(EngineSpriteHandle handle) const;
```

#### 2.1.12 粒子控制 Particle Control

```cpp
// 启用/禁用粒子系统
// Parameters:
//   flag - 是否启用
void EnableParticle(bool flag);
```

#### 2.1.13 界面特效 UI Effect

```cpp
// 创建界面特效
// Parameters:
//   effectname - 特效名称
//   async - 是否异步加载（默认true）
// Returns: 特效接口指针
IEffect* CreateEffect(const std::wstring &effectname, bool async = true);

// 绘制界面特效
// Parameters:
//   pEffect - 特效接口指针
void DrawEffect(IEffect* pEffect);

// 释放界面特效
// Parameters:
//   pEffect - 特效接口指针
void ReleaseEffect(IEffect* pEffect);
```

#### 2.1.14 特效缓存 Effect Cache

```cpp
// 持有特效资源（不限于界面特效）
// Parameters:
//   name - 特效名称
void HoldEffect(const std::wstring &name);

// 释放特效资源
// Parameters:
//   name - 特效名称
void ReleaseEffect(const std::wstring &name);
```

#### 2.1.15 帧率平滑与纹理加载 FPS Smoothing & Texture Loading

```cpp
// 设置帧间隔平滑限制
// Parameters:
//   uiSmoothDeltaLimit - 平滑限制值
void SetSmoothDeltaLimit(unsigned int uiSmoothDeltaLimit);

// 获取帧间隔平滑限制
// Returns: 平滑限制值
unsigned int GetSmoothDeltaLimit();

// 设置是否分步加载纹理
// Parameters:
//   b - 是否分步加载
void SetStepLoadTexture(bool b);

// 获取是否分步加载纹理
// Returns: 分步加载返回true，否则返回false
bool GetStepLoadTexture() const;

// 设置Fire线程秒数限制
// Parameters:
//   limitFireThreadCount - 限制值
void SetLimitFireThreadSecond(int limitFireThreadCount);

// 获取Fire线程秒数限制
// Returns: 限制值
int GetLimitFireThreadSecond();
```

#### 2.1.16 引擎层管理 Engine Layer Management

```cpp
// 设置引擎CCLayer
// Parameters:
//   aPLayer - CCLayer指针
void SetEngineLayer(cocos2d::CCLayer* aPLayer);

// 获取引擎CCLayer
// Returns: CCLayer指针
cocos2d::CCLayer* GetEngineLayer();
```

#### 2.1.17 Windows消息处理 Windows Message Handling

```cpp
// 处理Windows消息（仅Win32平台）
// Parameters:
//   hWnd - 窗口句柄
//   msg - 消息ID
//   wParam - WPARAM
//   lParam - LPARAM
//   pAdditionalParam - 附加参数
// Returns: 消息是否被处理
bool OnWindowsMessage(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam, void* pAdditionalParam = NULL);
```

## 3. 世界接口 World Interface

### 3.1 IWorld Interface

游戏世界管理接口，提供地图加载、精灵管理、特效管理、相机控制等功能。

Game world management interface providing map loading, sprite management, effect management, camera control, and other features.

#### 3.1.1 地图管理 Map Management

```cpp
// 加载地图
// Parameters:
//   mapname - 地图名称
//   mazename - 迷宫名称
//   param - 加载参数（可选）
//   async - 是否异步加载
// Returns: 成功返回true，失败返回false
bool LoadMap(const std::wstring& mapname, const std::wstring &mazename,
            const XPLoadmapParam* param, bool async);

// 卸载地图
// Returns: 成功返回true，失败返回false
bool UnloadMap();

// 获取地图尺寸
// Parameters:
//   size - 输出地图尺寸
// Returns: 成功返回true，失败返回false
bool GetMapSize(NuclearPoint &size) const;

// 立即确保区域资源加载
// Parameters:
//   loc - 位置
void ImmediatelyAssureRegionResource(const Nuclear::NuclearLocation &loc);
```

#### 3.1.2 精灵管理 Sprite Management

```cpp
// 创建精灵
// Parameters:
//   layer - 精灵层级
//   modelname - 模型名称
// Returns: 精灵接口指针
ISprite* NewSprite(NuclearSpriteLayer layer, const std::wstring &modelname);

// 附加精灵
// Parameters:
//   pHostSprite - 主精灵
//   pClientSprite - 客户精灵
//   hostSocket - 主精灵挂点
//   clientSocket - 客户精灵挂点
//   relpos - 相对位置
//   sign - 标志
// Returns: 成功返回true，失败返回false
bool AttachSprite(ISprite *pHostSprite, ISprite *pClientSprite,
                const std::wstring &hostSocket, const std::wstring &clientSocket,
                const NuclearVector3 &relpos, unsigned int sign);

// 分离精灵
// Parameters:
//   layer - 精灵层级
//   pHostSprite - 主精灵
//   pClientSprite - 客户精灵
// Returns: 成功返回true，失败返回false
bool DetachSprite(NuclearSpriteLayer layer, ISprite *pHostSprite,
                 ISprite *pClientSprite);

// 删除精灵
// Parameters:
//   sprite - 精灵接口指针
void DeleteSprite(ISprite* sprite);

// 删除指定层所有精灵
// Parameters:
//   layer - 精灵层级
//   keepAttached - 是否保留附加精灵
void DeleteAllSprite(NuclearSpriteLayer layer, bool keepAttached = false);

// 移动精灵层级
// Parameters:
//   pSprite - 精灵指针
//   fromlayer - 原层级
//   tolayer - 目标层级
void MoveSpriteLayer(ISprite *pSprite, NuclearSpriteLayer fromlayer,
                    NuclearSpriteLayer tolayer);
```

#### 3.1.3 不可移动对象管理 Immovable Object Management

```cpp
// 创建不可移动对象
// Parameters:
//   objname - 对象名称
//   layer - 层级
//   color - 颜色
//   freq - 频率
// Returns: 不可移动对象接口指针
IImmovableObj* NewImmovableObj(const std::wstring &objname, int layer,
                              NuclearColor color = 0xffffffff, float freq=1.0f);

// 删除不可移动对象
// Parameters:
//   immobj - 不可移动对象指针
void DeleteImmovableObj(IImmovableObj* immobj);

// 删除所有不可移动对象
void DeleteAllImmovableObj();
```

#### 3.1.4 特效管理 Effect Management

```cpp
// 设置持续特效
// Parameters:
//   name - 特效名称
//   layer - 特效层级
//   pt1 - 起点
//   pt2 - 终点
//   time - 持续时间（秒），<0表示循环
//   async - 是否异步加载
// Returns: 特效接口指针
IEffect* SetLinkedEffect(const std::wstring &name, Nuclear_EffectLayer layer,
                       const NuclearPoint &pt1, const NuclearPoint &pt2,
                       float time, bool async);

// 设置特效
// Parameters:
//   name - 特效名称
//   layer - 特效层级
//   x - X坐标
//   y - Y坐标
//   async - 是否异步加载
// Returns: 特效接口指针
IEffect* SetEffect(const std::wstring &name, Nuclear_EffectLayer layer,
                 int x, int y, bool async);

// 设置连续特效
// Parameters:
//   headEffect - 头部特效
//   midEffect - 中间特效
//   endEffect - 尾部特效
//   continueTime - 持续时间
//   layer - 特效层级
//   x - X坐标
//   y - Y坐标
//   async - 是否异步加载
// Returns: 特效接口指针
IEffect* SetContinueEffect(const std::wstring &headEffect,
                        const std::wstring &midEffect,
                        const std::wstring &endEffect,
                        int continueTime, Nuclear_EffectLayer layer,
                        int x, int y, bool async);

// 移除特效
// Parameters:
//   pEffect - 特效接口指针
void RemoveEffect(IEffect* pEffect);

// 移除特效（扩展版）
// Parameters:
//   pEffect - 特效接口指针
void RemoveEffectEx(IEffect* pEffect);

// 播放一次性特效
// Parameters:
//   name - 特效名称
//   layer - 特效层级
//   x - X坐标
//   y - Y坐标
//   times - 播放次数
//   async - 是否异步加载
//   soundtype - 声音类型
// Returns: 特效接口指针
IEffect* PlayEffect(const std::wstring &name, Nuclear_EffectLayer layer,
                 int x, int y, int times, bool async,
                 unsigned char soundtype);
```

#### 3.1.5 相机控制 Camera Control

```cpp
// 附加相机到精灵
// Parameters:
//   sprite - 精灵指针
void AttachCameraTo(ISprite* sprite);

// 获取视口
// Returns: 视口矩形
const NuclearRect& GetViewport() const;

// 设置视口
// Parameters:
//   loc - 目标位置（视口中心）
//   syncRsrc - 是否同步加载资源
void SetViewport(const NuclearLocation &loc, bool syncRsrc);

// 设置视口左上角
// Parameters:
//   left - 左边界
//   top - 上边界
void SetViewportLT(int left, int top);
```

#### 3.1.6 A*寻路 A* Pathfinding

```cpp
// 获取A*路径
// Parameters:
//   path - 输出路径
//   start - 起始点（逻辑坐标）
//   end - 终点（逻辑坐标）
// Returns: 成功返回true，失败返回false
bool GetAStartPath(astar::Path& path, const Nuclear::NuclearLocation& start,
                  const Nuclear::NuclearLocation& end);
```

#### 3.1.7 障碍管理 Obstacle Management

```cpp
// 设置地图迷宫
// Parameters:
//   mazeBuffer - 迷宫数据缓冲区
//   size - 数据大小
// Returns: 成功返回true，失败返回false
bool SetMapMaze(const void* mazeBuffer, size_t size);

// 设置迷宫掩码
// Parameters:
//   pData - 掩码数据
//   rect - 掩码区域（逻辑坐标）
// Returns: 成功返回true，失败返回false
bool SetMazeMask(const unsigned char* pData, const NuclearRect &rect);

// 获取迷宫掩码
// Parameters:
//   x - X坐标（逻辑坐标）
//   y - Y坐标（逻辑坐标）
// Returns: 掩码值
unsigned int GetMazeMask(int x, int y);

// 设置迷宫颜色
// Parameters:
//   colors - 颜色配置
void SetMazeColors(const XPMazeColors &colors);

// 获取迷宫颜色
// Returns: 颜色配置
const XPMazeColors& GetMazeColors() const;
```

#### 3.1.8 游戏时间 Game Time

```cpp
// 设置游戏时间
// Parameters:
//   time - 游戏时间[0~1)，0代表深夜12点，0.5代表中午12点
void SetGameTime(float time);

// 获取临时游戏时间
// Returns: 游戏时间[0~1)
float GetTempGameTime() const;

// 设置游戏时间周期
// Parameters:
//   time - 一天（24小时）的长度（毫秒）
void SetGameTimeCycle(int time);
```

#### 3.1.9 战斗背景 Battle Background

```cpp
// 加载战斗背景
// Parameters:
//   name - 背景名称
// Returns: 背景句柄
WarBackgroundHandle LoadWarBackgound(const std::wstring &name);

// 释放战斗背景句柄
// Parameters:
//   handle - 背景句柄
void FreeWarBackgroundHandle(WarBackgroundHandle handle);

// 设置战斗背景
// Parameters:
//   handle - 背景句柄
//   type - 背景类型
// Returns: 成功返回true，失败返回false
bool SetWarBackground(WarBackgroundHandle handle, NuclearWarBackgroundType type);

// 释放所有战斗背景
void FreeAllWarBackground();

// 设置战斗背景边缘
// Parameters:
//   fEdge - 边缘值
void SetWarBackgroundEdge(float fEdge);

// 获取战斗背景边缘
// Returns: 边缘值
float GetWarBackgroundEdge() const;
```

#### 3.1.10 振屏控制 Shake Screen Control

```cpp
// 设置振屏控制器
// Parameters:
//   pController - 振屏控制器指针
void SetShakeScreenController(ShakeScreenController *pController);

// 获取振屏控制器
// Returns: 振屏控制器指针
ShakeScreenController* GetShakeScreenController() const;
```

#### 3.1.11 飞行控制 Flight Control

```cpp
// 设置飞行Y偏移目标值
// Parameters:
//   iFlyOffsetYTgt - 目标偏移
void SetFlyOffsetYTgt(int iFlyOffsetYTgt);

// 设置飞行Y偏移当前值
// Parameters:
//   iFlyOffsetYCur - 当前偏移
void SetFlyOffsetYCur(int iFlyOffsetYCur);

// 获取飞行Y偏移当前值
// Returns: 当前偏移
int GetFlyOffsetYCur();

// 设置飞行Y偏移步长
// Parameters:
//   iFlyOffsetYStep - 步长
void SetFlyOffsetYStep(int iFlyOffsetYStep);

// 获取飞行Y偏移步长
// Returns: 步长
int GetFlyOffsetYStep();

// 设置世界缩放
// Parameters:
//   scale - 缩放因子
void SetScale(float scale);

// 获取世界缩放
// Returns: 缩放因子
float GetScale() const;

// 设置是否使用平滑
// Parameters:
//   bSmooth - 是否平滑
void SetUseSmooth(bool bSmooth);
```

#### 3.1.12 世界模式 World Mode

```cpp
// 设置世界模式
// Parameters:
//   m - 世界模式枚举
void SetWorldMode(eNuclearWorldMode m);

// 获取世界模式
// Returns: 世界模式枚举
eNuclearWorldMode GetWorldMode() const;
```

#### 3.1.13 精灵影子参数 Sprite Shadow Parameters

```cpp
// 获取精灵影子参数
// Parameters:
//   shearX - 输出剪切X
//   scalingY - 输出缩放Y
void GetSpriteShadowParam(float &shearX, float &scalingY) const;

// 设置精灵影子参数
// Parameters:
//   shearX - 剪切X
//   scalingY - 缩放Y
void SetSpriteShadowParam(const float &shearX, const float &scalingY);
```

#### 3.1.14 对象选择 Object Selection

```cpp
// 选择指定位置的对象
// Parameters:
//   loc - 位置（逻辑坐标）
//   ettobjs - 输出选中对象列表
// Returns: 成功返回true，失败返回false
bool SelectObjs(const NuclearLocation &loc, std::vector<ISelectableObj*> &ettobjs);
```

#### 3.1.15 战斗便捷方法 Battle Convenience Methods

IWorld 提供了战斗场景的便捷方法，内部使用 `transformWarLayer2NewLayer` 转换层级：

```cpp
// 创建战斗精灵（使用XPSL_BATTLE层）
ISprite* NewWarSprite(const std::wstring &modelname);

// 附加战斗精灵
bool AttachWarSprite(ISprite *pHostSprite, ISprite *pClientSprite, const std::wstring &hostSocket, const std::wstring &clientSocket, unsigned int sign);

// 分离战斗精灵
bool DetachWarSprite(ISprite *pHostSprite, ISprite *pClientSprite);

// 删除战斗精灵
void DeleteWarSprite(ISprite* sprite);

// 删除所有战斗精灵
void DeleteAllWarSprite();

// 设置战斗特效（层级自动转换）
IEffect* SetWarEffect(const std::wstring &name, Nuclear_EffectLayer layer, int x, int y, bool async);

// 设置战斗连续特效（层级自动转换）
IEffect* SetWarContinueEffect(const std::wstring &headEffect, const std::wstring &midEffect, const std::wstring &endEffect, int continueTime, Nuclear_EffectLayer layer, int x, int y, bool async);

// 移除战斗特效
void RemoveWarEffect(IEffect* pEffect);
```

#### 3.1.16 场景特效控制 Scene Effect Control

```cpp
// 暂停场景特效
void pauseSceneEffects();

// 恢复场景特效
void resumeSceneEffects();

// 显示/隐藏场景特效
// Parameters:
//   bshow - 是否显示
void showSceneEffects(bool bshow);
```

#### 3.1.17 相机更新类型 Camera Update Type

```cpp
// 设置相机更新类型
// Parameters:
//   type - 更新类型
//   pParams - 参数（可选）
// Returns: 成功返回true，失败返回false
bool SetCameraUpdateType(NuclearCameraUpdateType type, void* pParams = NULL);

// 获取相机更新类型
// Returns: 更新类型
NuclearCameraUpdateType GetCameraUpdateType() const;
```

#### 3.1.18 地图资源预取 Map Resource Prefetch

```cpp
// 预取地图资源
// Parameters:
//   mapname - 地图名称
//   mazename - 迷宫名称
//   center - 中心点
//   autoSwitch - 是否自动切换
// Returns: 成功返回true，失败返回false
bool PrefetchMapRes(const std::wstring &mapname, const std::wstring &mazename, const NuclearPoint &center, bool autoSwitch);

// 取消预取
void CancelPrefetch();
```

#### 3.1.19 排序与调试 Sort & Debug

```cpp
// 获取排序Tick
// Returns: 当前SortTick值
int GetSortTick() const;
```

#### 3.1.20 迷宫显示配置 Maze Display Configuration

```cpp
// 设置迷宫掩码显示
// Parameters:
//   mask - 掩码值，0不显示
void SetMaskBoxColor(const NuclearColor &color = 0xffffffff);

// 获取迷宫掩码颜色
// Returns: 颜色值
const NuclearColor& GetMaskBoxColor() const;
```

## 4. 环境接口 Environment Interface

### 4.1 IEnv Interface

环境配置管理接口，提供显示模式、FPS控制、渲染效果、声音系统等配置功能。

Environment configuration management interface providing display mode, FPS control, rendering effects, sound system, and other configuration features.

#### 4.1.1 显示模式 Display Mode

```cpp
// 获取显示模式
// Returns: 显示模式结构
NuclearDisplayMode GetDisplayMode() const;

// 获取当前抗锯齿类型
// Returns: 抗锯齿类型
NuclearMultiSampleType GetCurrentMultiSampleType() const;

// 是否启用抗锯齿
// Returns: 启用返回true，否则返回false
bool IsMultiSampleTypeEnable() const;

// 获取可用抗锯齿类型
// Parameters:
//   window - 是否窗口模式
//   isMode16 - 是否16位色
//   types - 输出可用类型列表
void GetAvailableMultiSampleType(bool window, bool isMode16,
                              std::vector<NuclearMultiSampleType> &types);
```

#### 4.1.2 FPS控制 FPS Control

```cpp
// 设置是否控制FPS
// Parameters:
//   b - 是否控制FPS
void SetControlFPS(bool b);

// 是否控制FPS
// Returns: 控制返回true，否则返回false
bool IsControlFPS() const;

// 设置控制FPS
// Parameters:
//   type - 窗口状态
//   fps - 帧率
void SetControlFPS(NuclearWindowState type, int fps);

// 获取控制FPS
// Parameters:
//   type - 窗口状态
// Returns: 帧率
int GetControlFPS(NuclearWindowState type) const;
```

#### 4.1.3 渲染效果配置 Rendering Effect Configuration

```cpp
// 设置是否使用Shader渲染夜晚效果
// Parameters:
//   b - 是否使用Shader
void SetRenderNightEffectByShader(bool b);

// 是否使用Shader渲染夜晚效果
// Returns: 使用返回true，否则返回false
bool IsRenderNightEffectByShader() const;

// 设置是否使用RenderTarget渲染夜晚效果
// Parameters:
//   b - 是否使用RenderTarget
void SetRenderNightEffectWithRenderTarget(bool b);

// 是否使用RenderTarget渲染夜晚效果
// Returns: 使用返回true，否则返回false
bool IsRenderNightEffectWithRenderTarget() const;

// 设置是否启用地图叠图
// Parameters:
//   b - 是否启用
void SetEnableMaskPic(bool b);

// 是否启用地图叠图
// Returns: 启用返回true，否则返回false
bool IsEnableMaskPic() const;

// 设置是否绘制精灵阴影
// Parameters:
//   b - 是否绘制
void SetRenderSpriteShadow(bool b);

// 是否绘制精灵阴影
// Returns: 绘制返回true，否则返回false
bool IsRenderSpriteShadow() const;

// 设置是否在击退时带残影
// Parameters:
//   b - 是否带残影
void SetBlurForTeleport(bool b);

// 是否在击退时带残影
// Returns: 带残影返回true，否则返回false
bool IsBlurForTeleport() const;

// 设置是否使用地表Cache
// Parameters:
//   b - 是否使用
void SetEnableSurfaceCache(bool b);

// 是否使用地表Cache
// Returns: 使用返回true，否则返回false
bool IsEnableSurfaceCache() const;

// 设置是否同步加载水层以下图
// Parameters:
//   b - 是否同步
void SetSyncBeforeWater(bool b);

// 是否同步加载水层以下图
// Returns: 同步返回true，否则返回false
bool IsSyncBeforeWater() const;

// 设置是否排序精灵和地图中层物件
// Parameters:
//   b - 是否排序
void SetEnableSortMapObjects(bool b);

// 是否排序精灵和地图中层物件
// Returns: 排序返回true，否则返回false
bool IsEnableSortMapObjects() const;

// 设置动态物件是否会动
// Parameters:
//   b - 是否会动
void SetEnableLinkedObjs(bool b);

// 动态物件是否会动
// Returns: 会动返回true，否则返回false
bool IsEnableLinkedObjs() const;
```

#### 4.1.4 半透明配置 Translucency Configuration

```cpp
// 获取精灵半透明类型
// Returns: 半透明类型
NuclearSpriteTranslucentType GetSpriteTranslucentType() const;

// 设置精灵半透明类型
// Parameters:
//   t - 半透明类型
void SetSpriteTranslucentType(NuclearSpriteTranslucentType t);

// 获取遮罩Alpha
// Returns: Alpha值[0~1]
float GetMaskAlpha() const;

// 设置遮罩Alpha
// Parameters:
//   f - Alpha值[0~1]
void SetMaskAlpha(float f);

// 是否绘制遮挡物底图
// Returns: 绘制返回true，否则返回false
bool IsRenderSolidMask() const;

// 设置是否绘制遮挡物底图
// Parameters:
//   b - 是否绘制
void SetRenderSolidMask(bool b);
```

#### 4.1.5 声音系统配置 Sound System Configuration

```cpp
// 获取背景音乐类型
// Returns: 音量类型
unsigned char GetBGMType() const;

// 设置背景音乐类型
// Parameters:
//   t - 音量类型
void SetBGMType(unsigned char t);

// 获取环境音类型
// Returns: 音量类型
unsigned char GetEnvSoundType() const;

// 设置环境音类型
// Parameters:
//   t - 音量类型
void SetEnvSoundType(unsigned char t);

// 获取脚步声类型
// Returns: 音量类型
unsigned char GetStepSoundType() const;

// 设置脚步声类型
// Parameters:
//   t - 音量类型
void SetStepSoundType(unsigned char t);

// 获取动作声音类型
// Parameters:
//   action_name - 动作名称
// Returns: 音量类型
unsigned char GetActionSoundType(const std::wstring &action_name) const;

// 设置动作声音类型
// Parameters:
//   action_name - 动作名称
//   t - 音量类型
void SetActionSoundType(const std::wstring &action_name, unsigned char t);

// 获取3D角色声音类型
// Returns: 音量类型
unsigned char Get3DSpriteActionSoundType() const;

// 设置3D角色声音类型
// Parameters:
//   t - 音量类型
void Set3DSpriteActionSoundType(unsigned char t);

// 获取脚步声优先级
// Returns: 优先级
short GetStepSoundPriority() const;

// 设置脚步声优先级
// Parameters:
//   p - 优先级
void SetStepSoundPriority(short p);
```

#### 4.1.6 GC配置 GC Configuration

```cpp
// 设置动画图片GC时间
// Parameters:
//   t - 时间（毫秒）
void SetAniPicGCTime(int t);

// 获取动画图片GC时间
// Returns: 时间（毫秒）
int GetAniPicGCTime() const;

// 设置动画结构GC时间
// Parameters:
//   t - 时间（毫秒）
void SetAniXapGCTime(int t);

// 获取动画结构GC时间
// Returns: 时间（毫秒）
int GetAniXapGCTime() const;

// 设置最大3D特效组件数
// Parameters:
//   count - 组件数
void SetMax3DEffectComponentCount(int count);
```

## 5. 精灵接口 Sprite Interface

### 5.1 ISprite Interface

精灵接口，提供精灵创建、移动、动作播放、特效绑定等功能。

Sprite interface providing sprite creation, movement, action playback, effect binding, and other features.

#### 5.1.1 位置和方向 Position and Direction

```cpp
// 设置位置
// Parameters:
//   location - 位置（世界像素坐标）
void SetLocation(const NuclearLocation& location);

// 获取位置
// Returns: 位置（世界像素坐标）
NuclearLocation GetLocation() const;

// 设置方向
// Parameters:
//   direction - 方向
void SetDirection(NuclearDirection direction);

// 获取方向
// Returns: 方向
NuclearDirection GetDirection() const;

// 获取向量方向
// Returns: 向量方向
NuclearFPoint GetVectorDirection() const;

// 转向目标点
// Parameters:
//   targetx - 目标X坐标
//   targety - 目标Y坐标
void SetDirection(int targetx, int targety);
```

#### 5.1.2 可见性控制 Visibility Control

```cpp
// 设置是否可见
// Parameters:
//   v - 是否可见
void SetVisible(bool v);

// 是否可见
// Returns: 可见返回true，否则返回false
bool IsVisiable() const;

// 设置实体是否可见
// Parameters:
//   v - 是否可见
void SetEntityVisible(bool v);

// 实体是否可见
// Returns: 可见返回true，否则返回false
bool IsEntityVisible() const;

// 设置标题是否可见
// Parameters:
//   v - 是否可见
void SetTitleVisible(bool v);

// 标题是否可见
// Returns: 可见返回true，否则返回false
bool IsTitleVisible() const;
```

#### 5.1.3 颜色和透明度 Color and Alpha

```cpp
// 设置Alpha
// Parameters:
//   a - Alpha值[0~255]
void SetAlpha(unsigned char a);

// 获取Alpha
// Returns: Alpha值[0~255]
unsigned char GetAlpha() const;

// 是否实体
// Returns: 实体返回true，否则返回false
bool IsSolidMask() const;

// 设置是否实体
// Parameters:
//   b - 是否实体
void SetSolidMask(bool b);
```

#### 5.1.4 缩放 Scale

```cpp
// 设置缩放
// Parameters:
//   scale - 缩放因子
void SetScale(float scale);

// 获取缩放
// Returns: 缩放因子
float GetScale() const;
```

#### 5.1.5 模型和组件 Model and Component

```cpp
// 设置精灵模型
// Parameters:
//   modelname - 模型名称
//   async - 是否异步加载
// Returns: 成功返回true，失败返回false
bool SetModel(const std::wstring &modelname, bool async);

// 获取模型名称
// Returns: 模型名称
const std::wstring& GetModelName() const;

// 设置精灵组件
// Parameters:
//   scid - 组件ID
//   resource - 资源名称
//   color - 颜色
//   wsLayerName - 层名称
// Returns: 成功返回true，失败返回false
bool SetComponent(int scid, const std::wstring& resource,
                NuclearColor color = 0xffffffff,
                std::wstring wsLayerName = L"");

// 获取组件资源
// Parameters:
//   scid - 组件ID
//   resource - 输出资源名称
// Returns: 成功返回true，失败返回false
bool GetComponent(int scid, std::wstring& resource);

// 获取组件颜色
// Parameters:
//   scid - 组件ID
//   color - 输出颜色
// Returns: 成功返回true，失败返回false
bool GetComponentColor(int scid, NuclearColor &color);
```

#### 5.1.6 动作系统 Action System

```cpp
// 设置默认动作
// Parameters:
//   action_name - 动作名称
//   type - 加载类型
//   fScaleForTotalTime - 总时间缩放因子
//   bHoldLastFrame - 是否保持最后一帧
// Returns: 成功返回true，失败返回false
bool SetDefaultAction(const std::wstring& action_name,
                   XPSPRITE_ACTION_LOAD_TYPE type,
                   float fScaleForTotalTime,
                   bool bHoldLastFrame);

// 获取默认动作
// Returns: 动作名称
const std::wstring &GetDefaultAction() const;

// 播放临时动作
// Parameters:
//   action_name - 动作名称
//   type - 加载类型
//   fScaleForTotalTime - 总时间缩放因子
// Returns: 成功返回true，失败返回false
bool PlayAction(const std::wstring& action_name,
               XPSPRITE_ACTION_LOAD_TYPE type,
               float fScaleForTotalTime);

// 获取当前动作名称
// Returns: 动作名称
const std::wstring &GetCurActionName() const;

// 获取动作时间
// Parameters:
//   action_name - 动作名称
//   time - 输出时间（秒）
// Returns: 成功返回true，失败返回false
bool GetActionTimeByName(const std::wstring& action_name, float &time);

// 获取当前帧
// Returns: 当前帧号
int GetCurrentFrame() const;

// 获取总帧数
// Returns: 总帧数
int GetTotalFrame() const;

// 预取动作资源
// Parameters:
//   action_name - 动作名称
// Returns: 预取结果
NuclearPrefetchResult PrefetchAction(const std::wstring &action_name);

// 持有动作资源
// Parameters:
//   action_name - 动作名称
void HoldAction(const std::wstring &action_name);

// 释放动作资源
// Parameters:
//   action_name - 动作名称
void ReleaseAction(const std::wstring &action_name);

// 设置是否保持最后一帧
// Parameters:
//   bHoldLastFrame - 是否保持
void SetHoldLastFrame(bool bHoldLastFrame);
```

#### 5.1.7 移动系统 Movement System

```cpp
// 设置移动速度
// Parameters:
//   speed - 速度（像素/毫秒）
void SetMoveSpeed(float speed);

// 获取移动速度
// Returns: 速度（像素/毫秒）
float GetMoveSpeed() const;

// 停止移动
void StopMove();

// 是否移动中
// Returns: 移动中返回true，否则返回false
bool IsMoving() const;

// 设置暂停状态
// Parameters:
//   moveSuspended - 是否暂停
void SetMoveSuspended(bool moveSuspended);

// 是否暂停
// Returns: 暂停返回true，否则返回false
bool IsMoveSuspended() const;

// 移动到目标点
// Parameters:
//   targetX - 目标X坐标
//   targetY - 目标Y坐标
//   range - 范围（逻辑坐标）
//   size - 搜索范围（像素坐标）
//   straight - 是否直线移动
void MoveTo(int targetX, int targetY, int range, const CSIZE * size,
            bool straight = false);

// 沿尾迹移动
// Parameters:
//   trail - 尾迹路径（逻辑坐标）
void MoveTo(astar::Path & trail);

// 获取当前路径
// Parameters:
//   path - 输出路径（逻辑坐标）
void GetPath(astar::Path & path);

// 设置是否记录尾迹
// Parameters:
//   keep - 是否记录
void KeepMoveTrail(bool keep);

// 是否记录尾迹
// Returns: 记录返回true，否则返回false
bool IsKeepMoveTrail() const;

// 取走尾迹
// Parameters:
//   trail - 输出尾迹（逻辑坐标）
// Returns: 成功返回true，失败返回false
bool TakeMoveTrail(astar::Path & trail);

// 设置移动掩码
// Parameters:
//   mask - 掩码值
void SetMoveMask(unsigned int mask);

// 无损设置位置和方向
// Parameters:
//   point - 位置（逻辑坐标）
void SetLocationDirection(const astar::Point &);

// 获取逻辑坐标
// Returns: 逻辑坐标
NuclearLocation GetLogicLocation() const;

// 是否在攻击范围内
// Parameters:
//   target - 目标位置（世界坐标）
//   range - 范围（逻辑坐标）
//   mask - 掩码
// Returns: 在范围内返回true，否则返回false
bool InAttackRange(const Nuclear::NuclearLocation & target, int range,
                 unsigned int mask);
```

#### 5.1.8 特效绑定 Effect Binding

```cpp
// 设置持续特效
// Parameters:
//   effect_name - 特效名称
//   relpos - 相对位置
//   flag - 标志
// Returns: 特效接口指针
IEffect* SetDurativeEffect(const std::wstring &effect_name,
                        const NuclearPoint& relpos,
                        unsigned int flag);

// 设置连续特效
// Parameters:
//   headEffect - 头部特效
//   midEffect - 中间特效
//   endEffect - 尾部特效
//   continueTime - 持续时间
//   relpos - 相对位置
//   flag - 标志
// Returns: 特效接口指针
IEffect* SetContinueEffect(const std::wstring &headEffect,
                        const std::wstring &midEffect,
                        const std::wstring &endEffect,
                        int continueTime,
                        const NuclearPoint& relpos,
                        unsigned int flag);

// 移除持续特效
// Parameters:
//   pEffect - 特效接口指针
void RemoveDurativeEffect(IEffect* pEffect);

// 修改特效偏移
// Parameters:
//   pEffect - 特效接口指针
//   relpos - 相对位置
// Returns: 成功返回true，失败返回false
bool ChangeEffectOffset(IEffect* pEffect, const NuclearPoint &relpos);

// 播放临时特效
// Parameters:
//   effect_name - 特效名称
//   dx - X偏移
//   dy - Y偏移
//   times - 播放次数
//   flag - 标志
//   soundtype - 声音类型
//   TimeMode - 时间模式
//   iRot - 旋转
// Returns: 特效接口指针
IEffect* PlayEffect(const std::wstring &effect_name, int dx, int dy,
                 int times, unsigned int flag,
                 unsigned char soundtype, int TimeMode = 0, int iRot = 0);

// 播放3D特效
// Parameters:
//   effect_name - 特效名称
//   relpos - 相对位置
//   times - 播放次数
//   hostname - 主机名称
//   async - 是否异步加载
// Returns: 特效接口指针
IEffect* PlayEffect(const std::wstring &effect_name,
                 const NuclearPoint& relpos, int times,
                 const std::wstring &hostname, bool async);
```

#### 5.1.9 阴影和残影 Shadow and Blur

```cpp
// 启用阴影
// Parameters:
//   b - 是否启用
void EnableShadow(bool b);

// 是否启用阴影
// Returns: 启用返回true，否则返回false
bool IsEnableShadow();

// 瞬移带残影
// Parameters:
//   point - 目标位置
//   telTime - 移动时间
//   blurTime - 残影持续时间
void TeleportWithBlur(const NuclearLocation &point, int telTime, int blurTime);

// 停止瞬移
// Parameters:
//   point - 目标位置
void StopTeleport(const NuclearLocation &point);
```

#### 5.1.10 标题系统 Title System

```cpp
// 设置标题
// Parameters:
//   handle - 标题句柄
//   align - 对齐方式
void SetTitle(EntitativeTitleHandle handle,
             NuclearTitleAlign align = XPTA_DEFAULT);

// 获取标题
// Returns: 标题句柄
EntitativeTitleHandle GetTitle();

// 取消标题
// Returns: 标题句柄
EntitativeTitleHandle UnsetTitle();

// 设置标题大小
// Parameters:
//   width - 宽度
//   height - 高度
void SetTitleSize(int width, int height);

// 获取标题宽度
// Returns: 宽度
int GetTitleWidth() const;

// 获取标题高度
// Returns: 高度
int GetTitleHeight() const;

// 设置标题绑定挂点
// Parameters:
//   socket - 挂点名称
void SetTitleBindSocket(const std::wstring &socket);

// 获取标题绑定挂点
// Returns: 挂点名称
std::wstring GetTitleBindSocket() const;

// 获取冒泡物件偏移
// Returns: Y偏移（向上为正）
int GetBubbleItemOffset() const;
```

#### 5.1.11 通知系统 Notification System

```cpp
// 注册帧通知
// Parameters:
//   pNotify - 通知对象
//   actionName - 动作名称
//   frame - 帧号
void RegisterFrameNotify(SpriteNotify* pNotify,
                      const std::wstring &actionName, int frame);

// 取消帧通知
// Parameters:
//   pNotify - 通知对象
//   actionName - 动作名称
//   frame - 帧号
void DeregisterFrameNotify(SpriteNotify* pNotify,
                        const std::wstring &actionName, int frame);

// 注册绘制名称回调
// Parameters:
//   drawNameCB - 回调函数
void RegisterDrawNameCB(DrawName_CallBack drawNameCB);

// 取消绘制名称回调
void DeregisterDrawNameCB();

// 清除所有通知
void ClearAllNotify();
```

## 6. 特效接口 Effect Interface

### 6.1 IEffect Interface

特效接口，提供特效播放、控制、位置设置等功能。

Effect interface providing effect playback, control, position setting, and other features.

#### 6.1.1 播放控制 Playback Control

```cpp
// 播放
// Returns: 成功返回true，失败返回false
bool Play();

// 停止
// Returns: 成功返回true，失败返回false
bool Stop();

// 暂停
// Returns: 成功返回true，失败返回false
bool Pause();

// 恢复
// Returns: 成功返回true，失败返回false
bool Resume();
```

#### 6.1.2 位置和方向 Position and Direction

```cpp
// 设置位置
// Parameters:
//   location - 位置（世界像素坐标）
void SetLocation(const NuclearLocation& location);

// 获取位置
// Returns: 位置（世界像素坐标）
NuclearLocation GetLocation() const;

// 设置方向
// Parameters:
//   direction - 方向
void SetDirection(NuclearDirection direction);

// 获取方向
// Returns: 方向
NuclearDirection GetDirection() const;

// 设置方向（目标点）
// Parameters:
//   target - 目标点
void SetDirection(const NuclearFPoint &target);
```

#### 6.1.3 变换 Transform

```cpp
// 设置旋转弧度
// Parameters:
//   radian - 旋转弧度
void SetRotationRadian(float radian);

// 获取旋转弧度
// Returns: 旋转弧度
float GetRotationRadian() const;

// 设置缩放
// Parameters:
//   scaleX - X缩放
//   scaleY - Y缩放
void SetScale(float scaleX, float scaleY);

// 获取缩放
// Returns: 缩放向量
const NuclearFPoint& GetScale() const;

// 设置顶点颜色
// Parameters:
//   color - 颜色
void SetVertexColor(NuclearColor color);

// 获取顶点颜色
// Returns: 颜色
NuclearColor GetVertexColor() const;
```

#### 6.1.4 特效属性 Effect Properties

```cpp
// 获取相对包围盒
// Returns: 包围盒
const NuclearRect& GetRelBouningBox() const;

// 设置特效挂点类型
// Parameters:
//   t - 挂点类型
void SetEffectBindType(Nuclear_EffectBindType t);

// 获取特效挂点类型
// Returns: 挂点类型
Nuclear_EffectBindType GetEffectBindType() const;

// 获取播放状态
// Returns: 播放状态
Nuclear_EffectState GetPlayState() const;
```

#### 6.1.5 声音控制 Sound Control

```cpp
// 设置声音类型
// Parameters:
//   type - 声音类型
void SetSoundType(unsigned char type);

// 获取声音类型
// Returns: 声音类型
unsigned char GetSoundType() const;

// 设置声音优先级
// Parameters:
//   priority - 优先级
void SetSoundPriority(short priority);

// 获取声音优先级
// Returns: 优先级
short GetSoundPriority() const;
```

#### 6.1.6 通知系统 Notification System

```cpp
// 添加通知
// Parameters:
//   pNotify - 通知对象
void AddNotify(IEffectNotify* pNotify);

// 移除通知
// Parameters:
//   pNotify - 通知对象
void RemoveNotify(IEffectNotify* pNotify);

// 清除通知
void ClearNotify();
```

#### 6.1.7 更新 Update

```cpp
// 更新特效
// Parameters:
//   tickTime - 时间增量（毫秒）
// Returns: 播放完毕返回false，否则返回true
bool Update(DWORD tickTime);
```

### 6.2 IParticleEffect Interface

粒子特效接口，提供粒子系统高级控制功能。

Particle effect interface providing advanced particle system control features.

#### 6.2.1 发射器控制 Emitter Control

```cpp
// 修改目标点
// Parameters:
//   pt - 目标点
void ModifyObjectPoint(const NuclearFPoint &pt);

// 修改线长度
// Parameters:
//   length - 线长度
void ModifyLineLength(float length);

// 修改矩形宽高
// Parameters:
//   width - 宽度
//   height - 高度
void ModifyRectWH(float width, float height);
```

#### 6.2.2 盲区设置 Blind Area

```cpp
// 设置矩形盲区
// Parameters:
//   vet - 盲区列表
void SetRctBlindAreas(const std::vector<NuclearRect> &vet);
```

#### 6.2.3 循环模式 Cycle Mode

```cpp
// 设置循环模式
// Parameters:
//   mode - 循环模式
// Returns: 成功返回true，失败返回false
bool SetCycleMode(XPParticleEffectCycleMode mode);

// 获取循环模式
// Returns: 循环模式
XPParticleEffectCycleMode GetCycleMode() const;

// 设置系统生命长度
// Parameters:
//   time - 生命长度（秒），-1表示默认
// Returns: 成功返回true，失败返回false
bool SetSysLife(float time);

// 获取系统生命长度
// Returns: 生命长度（秒）
float GetSysLife();
```

#### 6.2.4 特效链 Effect Chain

```cpp
// 设置发射器链端点
// Parameters:
//   pt - 端点
//   type - 类型（0=起点，1=终点）
// Returns: 成功返回true，失败返回false
bool SetEmitterLinkPoint(const NuclearFPoint &pt, int type);

// 获取发射器链端点
// Parameters:
//   pt - 输出端点
//   type - 类型（0=起点，1=终点）
// Returns: 成功返回true，失败返回false
bool GetEmitterLinkPoint(NuclearFPoint &pt, int type);
```

#### 6.2.5 粒子统计 Particle Statistics

```cpp
// 获取活跃粒子数
// Returns: 粒子数
int GetNumActiveParticles() const;

// 获取粒子最大存活时间
// Returns: 时间（秒）
float GetParticleMaxLife() const;
```

#### 6.2.6 特殊粒子特效 Special Particle Effect

```cpp
// 设置特殊粒子纹理
// Parameters:
//   ShapesTexture - 纹理句柄
//   fu - 最大U坐标
//   fv - 最大V坐标
// Returns: 成功返回true，失败返回false
bool SetSpecialPsTexture(PictureHandle ShapesTexture,
                       float fu=1.0f, float fv=1.0f);

// 获取特殊粒子纹理句柄
// Returns: 纹理句柄
PictureHandle GetSpecialPSTextureHandle() const;

// 设置特殊粒子缩放
// Parameters:
//   fcx - X缩放
//   fcy - Y缩放
// Returns: 成功返回true，失败返回false
bool SetSpecialPsScale(float fcx=1.0f, float fcy=1.0f);

// 设置静默时间
// Parameters:
//   ftime - 静默时间（秒）
// Returns: 成功返回true，失败返回false
bool SetSilentTime(float ftime);
```

## 7. 查询接口 Query Interface

### 7.1 IQuery Interface

查询接口，提供引擎内部信息查询功能。

Query interface providing engine internal information query features.

#### 7.1.1 动作信息查询 Action Info Query

```cpp
// 获取动作信息
// Parameters:
//   modelname - 模型名称
//   actname - 动作名称
//   info - 输出动作信息
// Returns: 成功返回true，失败返回false
bool GetActionInfo(const std::wstring &modelname,
                const std::wstring &actname,
                IQuery::ActionInfo &info) const;
```

#### 7.1.2 精灵层级信息查询 Sprite Layer Info Query

```cpp
// 获取精灵层级信息
// Parameters:
//   modelname - 模型名称
// Returns: 层级信息列表
std::vector<SpriteLayerInfo> GetSpriteLayerInfo(const std::wstring &modelname) const;
```

## 8. 数据结构 Data Structures

### 8.1 EngineParameter

引擎参数结构。

Engine parameter structure.

```cpp
struct EngineParameter
{
    wchar_t* szWindowTitle;          // 窗口标题（默认 NULL）
    wchar_t* szClassName;           // 窗口类名（默认 NULL）
    NuclearDisplayMode dmode;         // 显示模式（默认 1024x768x32）
    bool bAsyncRead;                // 是否异步读取（默认 false）
    bool bApplictionInBuild;        // exe在build目录下为true，在build/bin下为false（默认 false）
    bool bHasMaximizbox;           // 是否有最大化按钮（默认 true）
    bool bSizeBox;                 // 是否可调整大小（默认 true）
    bool bEnableMipMap;            // 是否使用MipMap（默认 true）
    DWORD dwRenderFlags;            // 渲染标志（默认 XPCRF_VERTICALSYNC）
    NuclearMultiSampleType multiSampleType;  // 抗锯齿参数（默认 XPMULTISAMPLE_NONE）
    int nAppInitStepCount;         // 调用IApp::OnInit的次数（默认 1）
    IApp *pApp;                  // 应用程序指针（禁止为空，需保证在Engine::Run()期间有效）
};
```

### 8.2 ActionInfo

动作信息结构。

Action information structure.

```cpp
struct ActionInfo
{
    int nTime;     // 正常播放需要的时间（毫秒）
    int nFrame;    // 帧数
    int nStride;   // 步幅（像素），仅移动动作有效
};
```

### 8.3 SpriteLayerInfo

精灵层级信息结构。

Sprite layer information structure.

```cpp
struct SpriteLayerInfo
{
    std::wstring name;  // 层名称（同时作为目录名）
    std::wstring des;   // 描述（双汉字）
};
```

## 9. 枚举类型 Enum Types

### 9.1 NuclearSpriteLayer

精灵层级枚举。

Sprite layer enumeration.

```cpp
enum NuclearSpriteLayer
{
    XPSL_BOTTOM,      // 底层
    XPSL_MIDDLE1,     // 中层1
    XPSL_MIDDLE2,     // 中层2
    XPSL_TOP,         // 顶层
    XPSL_BATTLE,      // 战斗层
    XPSL_UI,          // UI层
};
```

### 9.2 Nuclear_EffectLayer

特效层级枚举。

Effect layer enumeration.

```cpp
enum Nuclear_EffectLayer
{
    XPEL_BOTTOM,          // 底层
    XPEL_SPRITE,         // 精灵层
    XPEL_ABOVE_SPRITE,   // 精灵上层
    XPEL_TOP,            // 顶层
    XPEL_BATTLE_LOW,      // 战斗底层
    XPEL_BATTLE_MID,      // 战斗中层
    XPEL_BATTLE_HEIGHT,   // 战斗高层
};
```

### 9.3 NuclearDirection

方向枚举。

Direction enumeration.

```cpp
enum NuclearDirection
{
    XPD_NORTH = 0,       // 北
    XPD_NORTHEAST = 1,   // 东北
    XPD_EAST = 2,        // 东
    XPD_SOUTHEAST = 3,   // 东南
    XPD_SOUTH = 4,       // 南
    XPD_SOUTHWEST = 5,   // 西南
    XPD_WEST = 6,        // 西
    XPD_NORTHWEST = 7,   // 西北
};
```

### 9.4 NuclearWindowState

窗口状态枚举。

Window state enumeration.

```cpp
enum NuclearWindowState
{
    XPWS_ACTIVE,      // 激活
    XPWS_INACTIVE,    // 非激活
    XPWS_MINIMIZE,    // 最小化
};
```

### 9.5 Nuclear_EffectState

特效播放状态枚举。

Effect playback state enumeration.

```cpp
enum Nuclear_EffectState
{
    XPES_STOPPED,    // 已停止
    XPES_PLAYING,    // 播放中
    XPES_PAUSED,     // 已暂停
    XPES_FINISHED,    // 已完成
};
```

### 9.6 XPSPRITE_ACTION_LOAD_TYPE

精灵动作加载类型枚举。

Sprite action load type enumeration.

```cpp
enum XPSPRITE_ACTION_LOAD_TYPE
{
    XPSALT_SYNC = 0,        // 同步加载
    XPSALT_ASYNC,           // 异步加载
    XPSALT_BASE_ASYNC,       // 异步加载，加载完第一帧就绘制
};
```

## 10. 使用示例 Usage Examples

### 10.1 初始化引擎 Initialize Engine

```cpp
#include "nuiengine.h"

using namespace Nuclear;

int main()
{
    // 获取引擎实例
    IEngine* pEngine = GetEngine();

    // 配置引擎参数
    EngineParameter ep;
    ep.szWindowTitle = L"My Game";
    ep.dmode = NuclearDisplayMode(1024, 768, 32);
    ep.bAsyncRead = true;
    ep.pApp = new MyApp();

    // 运行引擎
    pEngine->Run(ep);

    return 0;
}
```

### 10.2 创建精灵 Create Sprite

```cpp
// 获取世界接口
IWorld* pWorld = GetEngine()->GetWorld();

// 创建精灵
ISprite* pSprite = pWorld->NewSprite(XPSL_MIDDLE1, L"male");

// 设置位置
pSprite->SetLocation(NuclearLocation(100, 100));

// 设置方向
pSprite->SetDirection(XPD_EAST);

// 设置默认动作
pSprite->SetDefaultAction(L"idle", XPSALT_ASYNC, 1.0f, false);
```

### 10.3 播放特效 Play Effect

```cpp
// 获取世界接口
IWorld* pWorld = GetEngine()->GetWorld();

// 创建特效
IEffect* pEffect = pWorld->PlayEffect(L"fireball", XPEL_SPRITE,
                                     100, 100, 1, true, 0);

// 特效播放完毕后自动删除
```

### 10.4 精灵移动 Sprite Movement

```cpp
// 移动到目标点
pSprite->MoveTo(500, 500, 2, NULL, false);

// 检查是否移动中
if (pSprite->IsMoving())
{
    // 精灵正在移动
}

// 停止移动
pSprite->StopMove();
```

### 10.5 绑定特效到精灵 Bind Effect to Sprite

```cpp
// 设置持续特效
IEffect* pEffect = pSprite->SetDurativeEffect(L"aura",
                                            NuclearPoint(0, -50),
                                            0);

// 移除特效
pSprite->RemoveDurativeEffect(pEffect);
```

## 11. 注意事项 Notes

1. **坐标系** - 注意区分世界坐标和逻辑坐标，寻路相关接口使用逻辑坐标，其他接口使用世界坐标。

2. **异步加载** - 建议使用异步加载资源，避免阻塞主线程。

3. **内存管理** - 合理设置GC时间，及时释放不再使用的资源。

4. **FPS控制** - 根据实际需求调整FPS，平衡性能和流畅度。

5. **线程安全** - 引擎接口主要在主线程调用，跨线程调用需要使用任务队列。

6. **资源路径** - 资源路径使用宽字符（std::wstring）。

7. **错误处理** - 大部分接口返回bool表示成功/失败，需要检查返回值。
