# 03-环境配置文档 Environment Configuration Document

## 1. 概述 Overview

本文档详细说明Nuclear Engine的环境配置方法，包括编译配置、运行时配置、资源路径配置、性能优化配置等。

This document provides a detailed description of Nuclear Engine environment configuration methods, including compilation configuration, runtime configuration, resource path configuration, performance optimization configuration, etc.

## 2. 编译环境配置 Compilation Environment Configuration

### 2.1 Windows平台 Windows Platform

#### 2.1.1 开发环境要求 Development Environment Requirements

- **操作系统**: Windows 7/8/10/11
- **IDE**: Visual Studio 2013（必须，不可升级至更高版本）
- **编译器**: MSVC v120（VS2013 工具链）
- **PlatformToolset**: v120
- **MSBuild**: 12.0
- **Windows SDK**: 8.1

> **重要**: 当前项目强依赖 v120 工具链，使用 v140/v141/v142/v143 会引入 ABI/CRT 不兼容风险。

#### 2.1.2 项目配置 Project Configuration

项目使用Visual Studio项目文件（.vcxproj）进行配置。

**项目文件**:
- `engine.win32.vcxproj` - Win32平台项目文件（主线）
- `project/wp/engine.vcxproj` - Windows Phone平台项目文件（历史，非主线）

**Win32 主线配置选项 Configuration Options**:

```xml
<!-- Debug配置 -->
<ConfigurationType>StaticLibrary</ConfigurationType>
<UseDebugLibraries>true</UseDebugLibraries>
<PlatformToolset>v120</PlatformToolset>

<!-- Release配置 -->
<ConfigurationType>StaticLibrary</ConfigurationType>
<UseDebugLibraries>false</UseDebugLibraries>
<WholeProgramOptimization>true</WholeProgramOptimization>
<PlatformToolset>v120</PlatformToolset>
```

#### 2.1.3 预处理器定义 Preprocessor Definitions

**Debug模式（Win32 主线）**:
```cpp
WIN32;WIN7_32;_WINDOWS;_DEBUG;CEGUI_STATIC;XPP_WIN;CC_SUPPORT_PVRTC;
UNICODE;XP_PERFORMANCE;IGNORE_EXPORT;_CRT_SECURE_NO_WARNINGS;_SCL_SECURE_NO_WARNINGS
```

**Release模式（Win32 主线）**:
```cpp
WIN32;WIN7_32;_WINDOWS;NDEBUG;CEGUI_STATIC;XPP_WIN;CC_SUPPORT_PVRTC;
UNICODE;IGNORE_EXPORT;_CRT_SECURE_NO_WARNINGS;_SCL_SECURE_NO_WARNINGS
```

**关键宏定义 Key Macro Definitions**:

| 宏定义 | 说明 | 适用配置 |
|--------|------|----------|
| `WIN32` | Win32 平台标识 | 所有配置 |
| `WIN7_32` | Win7 32位兼容标识 | 主线配置 |
| `CEGUI_STATIC` | CEGUI 静态链接 | 所有配置 |
| `XPP_WIN` | Nuclear 引擎 Windows 平台 | 所有配置 |
| `UNICODE` | 使用Unicode字符集 | 所有配置 |
| `CC_SUPPORT_PVRTC` | PVRTC 纹理支持 | 所有配置 |
| `XP_PERFORMANCE` | 性能统计开关 | Debug 配置 |
| `IGNORE_EXPORT` | 忽略导出属性 | 主线配置 |
| `_CRT_SECURE_NO_WARNINGS` | 禁用安全警告 | 所有配置 |
| `_SCL_SECURE_NO_WARNINGS` | 禁用STL安全警告 | 所有配置 |
| `DEBUG` / `_DEBUG` | 调试模式 | Debug 配置 |
| `NDEBUG` | 发布模式 | Release 配置 |

#### 2.1.4 包含目录 Include Directories

Win32 主线包含目录（来源于 `engine.win32.vcxproj`）：

```
./
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/include
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/kazmath/include
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/kazmath/include/GL
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/win32
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/winrt
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/win32/zlib
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/win32/libwebp
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/win32/OGLES
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/winrt/freetype/include
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/winrt/angleproject/include
../cocos2d-2.0-rc2-x-2.0.1/cocos2dx/platform/third_party/winrt/angleproject/samples/gles2_book/Common
../cocos2d-2.0-rc2-x-2.0.1/external/fmod/win32/inc
../cocos2d-2.0-rc2-x-2.0.1/extensions/libSpine/spine-c/include
../cocos2d-2.0-rc2-x-2.0.1/extensions/libSpine/spine-c/include/spine
../cocos2d-2.0-rc2-x-2.0.1/extensions/libSpine/spine-cocos2dx/include
../cocos2d-2.0-rc2-x-2.0.1/extensions/libSpine/spine-cocos2dx/include/spine
../common/platform
../common/platform/utils
../common/ljfm/code/include
../dependencies/LJXML/Include
./engine
./common
```

#### 2.1.5 输出目录 Output Directory

```
../lib/$(Configuration)/Win32          # Win32 Debug/Release
```

### 2.2 Android平台 Android Platform

#### 2.2.1 开发环境要求 Development Environment Requirements

- **操作系统**: Windows、Linux、macOS
- **NDK**: Android NDK r8e 或更高版本
- **SDK**: Android SDK API 14 或更高版本
- **构建工具**: Android.mk、ndk-build

#### 2.2.2 Android.mk配置 Android.mk Configuration

```makefile
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := engine_static
LOCAL_MODULE_FILENAME := libengine

# 源文件
LOCAL_SRC_FILES := ${ENGINE_COMMON} ${ENGINE_RENDERER} ${ENGINE_ENGINE} ...

# 包含目录
LOCAL_C_INCLUDES := $(LOCAL_PATH) $(LOCAL_PATH)/common ...

# 链接库
LOCAL_LDLIBS := -llog
LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_spine_static

# 编译标志
LOCAL_CFLAGS := -DUSE_FILE32API -D_OS_IOS -D_OS_ANDROID -DUSE_NED_MALLOC \
                -DSELF_MALLOC -DXPP_IOS -DANDROID -DCC_SUPPORT_PVRTC -D_LOCOJOY_SDK_

LOCAL_CPPFLAGS := -fexceptions -fpermissive

include $(BUILD_STATIC_LIBRARY)

$(call import-module,cocos2dx)
$(call import-module,libSpine)
```

#### 2.2.3 关键编译标志 Key Compilation Flags

| 标志 | 说明 | 默认值 |
|------|------|--------|
| `USE_FILE32API` | 使用32位文件API | 已定义 |
| `_OS_IOS` | iOS平台兼容（Android也使用） | 已定义 |
| `_OS_ANDROID` | Android平台 | 已定义 |
| `USE_NED_MALLOC` | 使用NED内存分配器 | 已定义 |
| `SELF_MALLOC` | 自定义内存管理 | 已定义 |
| `DXPP_IOS` | iOS平台兼容（Android也使用） | 已定义 |
| `ANDROID` | Android平台 | 已定义 |
| `CC_SUPPORT_PVRTC` | 支持PVRTC纹理压缩 | 已定义 |
| `_LOCOJOY_SDK_` | LocoJoy SDK | 已定义 |
| `-fexceptions` | 启用C++异常 | 已定义 |
| `-fpermissive` | 宽松的编译模式 | 已定义 |

### 2.3 iOS平台 iOS Platform

#### 2.3.1 开发环境要求 Development Environment Requirements

- **操作系统**: macOS 10.8 或更高版本
- **IDE**: Xcode 5.0 或更高版本
- **SDK**: iOS SDK 7.0 或更高版本
- **部署目标**: iOS 6.0 或更高版本

#### 2.3.2 Xcode项目配置 Xcode Project Configuration

项目使用Xcode项目文件（.xcodeproj）进行配置。

**项目文件**:
- `engine.xcodeproj/project.pbxproj` - 主项目文件

**配置选项 Configuration Options**:

- **Build Settings**:
  - `Deployment Target`: iOS 6.0
  - `Base SDK`: Latest iOS SDK
  - `Architectures`: armv7, arm64
  - `Valid Architectures`: armv7, arm64

- **Compiler Flags**:
  - `-DUSE_NED_MALLOC`
  - `-DSELF_MALLOC`
  `-DXPP_IOS`
  `-DCC_SUPPORT_PVRTC`

#### 2.3.3 预处理器定义 Preprocessor Definitions

```cpp
USE_NED_MALLOC
SELF_MALLOC
XPP_IOS
CC_SUPPORT_PVRTC
_LOCOJOY_SDK_
```

## 3. 运行时配置 Runtime Configuration

### 3.1 引擎参数配置 Engine Parameter Configuration

#### 3.1.1 EngineParameter结构 EngineParameter Structure

```cpp
struct EngineParameter
{
    wchar_t* szWindowTitle;          // 窗口标题
    wchar_t* szClassName;           // 窗口类名
    NuclearDisplayMode dmode;         // 显示模式（宽度、高度、色深）
    bool bAsyncRead;                // 是否异步读取资源
    bool bApplictionInBuild;        // 应用程序位置（build下true，build\bin下false）
    bool bHasMaximizbox;           // 是否有最大化按钮
    bool bSizeBox;                 // 是否可调整窗口大小
    bool bEnableMipMap;            // 是否使用MipMap
    DWORD dwRenderFlags;            // 渲染标志
    NuclearMultiSampleType multiSampleType;  // 抗锯齿类型
    int nAppInitStepCount;         // 调用IApp::OnInit的次数
    IApp *pApp;                  // 应用程序指针（必须有效）
};
```

#### 3.1.2 NuclearDisplayMode结构 NuclearDisplayMode Structure

```cpp
struct NuclearDisplayMode
{
    int width;      // 屏幕宽度（像素）
    int height;     // 屏幕高度（像素）
    int bitDepth;   // 色深（16或32）
};
```

**常用分辨率 Common Resolutions**:

| 分辨率 | 宽度 | 高度 | 色深 | 适用平台 |
|--------|------|------|--------|----------|
| iPhone 4/4S | 640 | 960 | 32 | iOS |
| iPhone 5/5S | 640 | 1136 | 32 | iOS |
| iPhone 6/7/8 | 750 | 1334 | 32 | iOS |
| iPhone 6+/7+/8+ | 1242 | 2208 | 32 | iOS |
| iPad | 768 | 1024 | 32 | iOS |
| iPad Retina | 1536 | 2048 | 32 | iOS |
| Android 480p | 480 | 800 | 32 | Android |
| Android 720p | 720 | 1280 | 32 | Android |
| Android 1080p | 1080 | 1920 | 32 | Android |
| Windows Phone | 768 | 1280 | 32 | WP8 |

#### 3.1.3 NuclearMultiSampleType枚举 NuclearMultiSampleType Enumeration

```cpp
enum NuclearMultiSampleType
{
    XPMULTISAMPLE_NONE = 0,      // 无抗锯齿
    XPMULTISAMPLE_2_SAMPLES,     // 2倍抗锯齿
    XPMULTISAMPLE_4_SAMPLES,     // 4倍抗锯齿
    XPMULTISAMPLE_8_SAMPLES,     // 8倍抗锯齿
    XPMULTISAMPLE_16_SAMPLES,    // 16倍抗锯齿
};
```

#### 3.1.4 渲染标志 Render Flags

```cpp
// 垂直同步
#define XPCRF_VERTICALSYNC 0x00000001

// 其他渲染标志...
```

### 3.2 环境配置接口 Environment Configuration Interface

#### 3.2.1 显示模式配置 Display Mode Configuration

```cpp
// 获取显示模式
NuclearDisplayMode GetDisplayMode() const;

// 获取当前抗锯齿类型
NuclearMultiSampleType GetCurrentMultiSampleType() const;

// 是否启用抗锯齿
bool IsMultiSampleTypeEnable() const;

// 获取可用抗锯齿类型
void GetAvailableMultiSampleType(bool window, bool isMode16,
                              std::vector<NuclearMultiSampleType> &types);
```

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 获取当前显示模式
NuclearDisplayMode mode = pEnv->GetDisplayMode();
printf("Screen: %dx%d, %d-bit\n", mode.width, mode.height, mode.bitDepth);

// 获取可用抗锯齿类型
std::vector<NuclearMultiSampleType> types;
pEnv->GetAvailableMultiSampleType(true, false, types);

// 选择4倍抗锯齿
if (std::find(types.begin(), types.end(), XPMULTISAMPLE_4_SAMPLES) != types.end())
{
    // 在EngineParameter中设置multiSampleType = XPMULTISAMPLE_4_SAMPLES
}
```

#### 3.2.2 FPS控制配置 FPS Control Configuration

```cpp
// 设置是否控制FPS
void SetControlFPS(bool b);

// 是否控制FPS
bool IsControlFPS() const;

// 设置控制FPS
void SetControlFPS(NuclearWindowState type, int fps);

// 获取控制FPS
int GetControlFPS(NuclearWindowState type) const;
```

**默认FPS配置 Default FPS Configuration**:

| 窗口状态 | 默认FPS | 说明 |
|----------|---------|------|
| XPWS_ACTIVE | 60 | 激活状态 |
| XPWS_INACTIVE | 60 | 非激活状态 |
| XPWS_MINIMIZE | 30 | 最小化状态 |

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 启用FPS控制
pEnv->SetControlFPS(true);

// 设置不同窗口状态的FPS
pEnv->SetControlFPS(XPWS_ACTIVE, 60);      // 激活状态60FPS
pEnv->SetControlFPS(XPWS_INACTIVE, 30);    // 非激活状态30FPS
pEnv->SetControlFPS(XPWS_MINIMIZE, 10);    // 最小化状态10FPS
```

#### 3.2.3 任务执行时间配置 Task Execution Time Configuration

```cpp
// 设置每帧任务执行时间
void SetTaskExecuteTime(NuclearWindowState type, int time);

// 获取每帧任务执行时间
int GetTaskExecuteTime(NuclearWindowState type) const;

// 设置IO更新执行时间
void SetIOUpdateExecuteTime(int time);

// 获取IO更新执行时间
int GetIOUpdateExecuteTime() const;
```

**默认配置 Default Configuration**:

| 配置项 | 默认值 | 单位 | 说明 |
|--------|--------|------|------|
| 任务执行时间 | 30 | 毫秒 | 每帧用户任务执行时间 |
| IO更新时间 | 30 | 毫秒 | 每帧IO更新时间 |

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 设置任务执行时间
pEnv->SetTaskExecuteTime(XPWS_ACTIVE, 20);    // 激活状态20ms
pEnv->SetTaskExecuteTime(XPWS_INACTIVE, 10);  // 非激活状态10ms

// 设置IO更新时间
pEnv->SetIOUpdateExecuteTime(20);
```

#### 3.2.4 渲染效果配置 Rendering Effect Configuration

**夜晚效果配置 Night Effect Configuration**:

```cpp
// 设置是否使用Shader渲染夜晚效果
void SetRenderNightEffectByShader(bool b);

// 是否使用Shader渲染夜晚效果
bool IsRenderNightEffectByShader() const;

// 设置是否使用RenderTarget渲染夜晚效果
void SetRenderNightEffectWithRenderTarget(bool b);

// 是否使用RenderTarget渲染夜晚效果
bool IsRenderNightEffectWithRenderTarget() const;
```

**精灵阴影配置 Sprite Shadow Configuration**:

```cpp
// 设置是否绘制精灵阴影
void SetRenderSpriteShadow(bool b);

// 是否绘制精灵阴影
bool IsRenderSpriteShadow() const;
```

**残影效果配置 Blur Effect Configuration**:

```cpp
// 设置是否在击退时带残影
void SetBlurForTeleport(bool b);

// 是否在击退时带残影
bool IsBlurForTeleport() const;
```

**地图叠图配置 Map Mask Configuration**:

```cpp
// 设置是否启用地图叠图
void SetEnableMaskPic(bool b);

// 是否启用地图叠图
bool IsEnableMaskPic() const;
```

**地表缓存配置 Surface Cache Configuration**:

```cpp
// 设置是否使用地表Cache
void SetEnableSurfaceCache(bool b);

// 是否使用地表Cache
bool IsEnableSurfaceCache() const;
```

**水层同步配置 Water Layer Sync Configuration**:

```cpp
// 设置是否同步加载水层以下图
void SetSyncBeforeWater(bool b);

// 是否同步加载水层以下图
bool IsSyncBeforeWater() const;
```

**地图对象排序配置 Map Object Sorting Configuration**:

```cpp
// 设置是否排序精灵和地图中层物件
void SetEnableSortMapObjects(bool b);

// 是否排序精灵和地图中层物件
bool IsEnableSortMapObjects() const;
```

**动态物件配置 Linked Object Configuration**:

```cpp
// 设置动态物件是否会动
void SetEnableLinkedObjs(bool b);

// 动态物件是否会动
bool IsEnableLinkedObjs() const;
```

#### 3.2.5 半透明配置 Translucency Configuration

```cpp
// 获取精灵半透明类型
NuclearSpriteTranslucentType GetSpriteTranslucentType() const;

// 设置精灵半透明类型
void SetSpriteTranslucentType(NuclearSpriteTranslucentType t);

// 获取遮罩Alpha
float GetMaskAlpha() const;

// 设置遮罩Alpha
void SetMaskAlpha(float f);

// 是否绘制遮挡物底图
bool IsRenderSolidMask() const;

// 设置是否绘制遮挡物底图
void SetRenderSolidMask(bool b);
```

**半透明类型 Translucency Types**:

```cpp
enum NuclearSpriteTranslucentType
{
    XPSTT_ELEMENT_TRANSLUCENT,  // 遮挡物半透明
    XPSTT_SPRITE_TRANSLUCENT,   // 精灵半透明
};
```

**配置说明 Configuration Notes**:

- **XPSTT_ELEMENT_TRANSLUCENT**: 遮挡物半透明模式，精灵被遮挡时，遮挡物变半透明
  - `SetMaskAlpha()`: 设置遮挡物Alpha值[0~1]，默认0.6
  - `SetRenderSolidMask()`: 是否绘制遮挡物底图，默认绘制

- **XPSTT_SPRITE_TRANSLUCENT**: 精灵半透明模式，精灵被遮挡时，精灵变半透明
  - `SetMaskAlpha()`: 设置精灵Alpha值[0~1]，默认0.6
  - `SetRenderSolidMask()`: 不生效

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 设置半透明类型
pEnv->SetSpriteTranslucentType(XPSTT_ELEMENT_TRANSLUCENT);

// 设置遮罩Alpha
pEnv->SetMaskAlpha(0.7f);

// 设置是否绘制遮挡物底图
pEnv->SetRenderSolidMask(true);
```

#### 3.2.6 声音系统配置 Sound System Configuration

```cpp
// 获取背景音乐类型
unsigned char GetBGMType() const;

// 设置背景音乐类型
void SetBGMType(unsigned char t);

// 获取环境音类型
unsigned char GetEnvSoundType() const;

// 设置环境音类型
void SetEnvSoundType(unsigned char t);

// 获取脚步声类型
unsigned char GetStepSoundType() const;

// 设置脚步声类型
void SetStepSoundType(unsigned char t);

// 获取动作声音类型
unsigned char GetActionSoundType(const std::wstring &action_name) const;

// 设置动作声音类型
void SetActionSoundType(const std::wstring &action_name, unsigned char t);

// 获取3D角色声音类型
unsigned char Get3DSpriteActionSoundType() const;

// 设置3D角色声音类型
void Set3DSpriteActionSoundType(unsigned char t);

// 获取脚步声优先级
short GetStepSoundPriority() const;

// 设置脚步声优先级
void SetStepSoundPriority(short p);
```

**默认配置 Default Configuration**:

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| BGMType | 0 | 背景音乐音量类型 |
| EnvSoundType | 1 | 环境音音量类型 |
| StepSoundType | 1 | 脚步声音量类型 |
| 3DSpriteActionSoundType | 0 | 3D角色动作声音类型 |
| StepSoundPriority | 40 | 脚步声优先级 |

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 设置背景音乐类型
pEnv->SetBGMType(0);

// 设置环境音类型
pEnv->SetEnvSoundType(1);

// 设置脚步声类型
pEnv->SetStepSoundType(1);

// 设置特定动作的声音类型
pEnv->SetActionSoundType(L"attack", 1);

// 设置脚步声优先级
pEnv->SetStepSoundPriority(50);
```

#### 3.2.7 GC配置 GC Configuration

```cpp
// 设置动画图片GC时间
void SetAniPicGCTime(int t);

// 获取动画图片GC时间
int GetAniPicGCTime() const;

// 设置动画结构GC时间
void SetAniXapGCTime(int t);

// 获取动画结构GC时间
int GetAniXapGCTime() const;

// 设置最大3D特效组件数
void SetMax3DEffectComponentCount(int count);
```

**默认配置 Default Configuration**:

| 配置项 | 默认值 | 单位 | 说明 |
|--------|--------|------|------|
| AniPicGCTime | 20000 | 毫秒 | 动画图片GC时间 |
| AniXapGCTime | 1200000 | 毫秒 | 动画结构GC时间 |
| Max3DEffectComponentCount | 15 | 个 | 最大3D特效组件数 |

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 设置动画图片GC时间（20秒）
pEnv->SetAniPicGCTime(20000);

// 设置动画结构GC时间（20分钟）
pEnv->SetAniXapGCTime(1200000);

// 设置最大3D特效组件数
pEnv->SetMax3DEffectComponentCount(20);
```

#### 3.2.8 平滑移动配置 Smooth Movement Configuration

```cpp
// 是否平滑移动
bool IsSmoothMove() const;

// 设置平滑移动
void SetSmoothMove(bool b);

// 获取最小Delta
short GetMinDelta() const;

// 设置最小Delta
void SetMinDelta(short d);

// 获取相邻两帧最大差值
short GetMaxDiffDelta() const;

// 设置相邻两帧最大差值
void SetMaxDiffDelta(short d);

// 获取与平均值最大差值
short GetMaxDiffFromAvg() const;

// 设置与平均值最大差值
void SetMaxDiffFromAvg(short d);
```

**默认配置 Default Configuration**:

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| SmoothMove | true | 是否平滑移动 |
| MinDelta | 0 | 最小Delta |
| MaxDiffDelta | 0 | 相邻两帧最大差值 |
| MaxDiffFromAvg | 0 | 与平均值最大差值 |

#### 3.2.9 涉水效果配置 Wade Effect Configuration

```cpp
// 是否启用涉水半透明效果
bool IsEnableWade() const;

// 设置是否启用涉水半透明效果
void SetEnableWade(bool b);
```

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 启用涉水效果
pEnv->SetEnableWade(true);
```

#### 3.2.10 卸载地图声音淡出配置 Unload Map Sound Fade Out Configuration

```cpp
// 获取卸载地图时声音淡出时间
int GetUnloadMapBGSoundFadeOutTime() const;

// 设置卸载地图时声音淡出时间
void SetUnloadMapBGSoundFadeOutTime(int t);
```

**默认配置 Default Configuration**:

| 配置项 | 默认值 | 单位 | 说明 |
|--------|--------|------|------|
| UnloadMapBGSoundFadeOutTime | 0 | 毫秒 | 声音淡出时间 |

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 设置卸载地图时声音淡出时间（1秒）
pEnv->SetUnloadMapBGSoundFadeOutTime(1000);
```

#### 3.2.11 精灵移动平滑配置 Sprite Movement Smooth Configuration

```cpp
// 设置精灵移动平滑限制
void SetSpriteMoveSmoothLimit(int iLimit);

// 获取精灵移动平滑限制
int GetSpriteMoveSmoothLimit() const;
```

**配置说明 Configuration Notes**:

- `= 1`: 不平滑处理，精灵沿格子中心的连线移动，按8方向移动
- `<= 0`: 进行平滑处理，查找路径时，一次性完成所有格子的平滑处理
- `> 1`: 进行平滑处理，边走边处理，每次处理格子数量不超过限制

**默认配置 Default Configuration**:

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| SpriteMoveSmoothLimit | 80 | 平滑处理格子数限制 |

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 设置平滑处理限制
pEnv->SetSpriteMoveSmoothLimit(100);
```

#### 3.2.12 逻辑坐标到世界坐标转换配置 Logic to World Coordinate Conversion Configuration

```cpp
// 获取逻辑坐标到世界坐标转换因子（X方向）
float GetLogicToWorldScaleX() const;

// 设置逻辑坐标到世界坐标转换因子（X方向）
void SetLogicToWorldScaleX(float fScale);
```

**配置说明 Configuration Notes**:

- 转换关系：世界坐标.x = 逻辑坐标.x * GetLogicToWorldScaleX()
- 转换关系：世界坐标.y = 逻辑坐标.y
- 默认值：1.0

**配置示例 Configuration Example**:

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 设置转换因子
pEnv->SetLogicToWorldScaleX(2.0f);
```

## 4. 资源路径配置 Resource Path Configuration

### 4.1 资源目录结构 Resource Directory Structure

```
项目根目录/
├── model/              # 模型资源
│   ├── sprites.xml     # 精灵模型列表
│   ├── male/          # 男性角色模型
│   │   ├── layerdef.xml    # 层定义
│   │   ├── idle/          # 待机动作
│   │   ├── walk/          # 行走动作
│   │   └── ...
│   └── female/        # 女性角色模型
├── map/                # 地图资源
│   ├── map1/          # 地图1
│   │   ├── map.xml       # 地图配置
│   │   ├── ground/       # 地面资源
│   │   ├── bg/           # 背景资源
│   │   └── ...
│   └── map2/
├── effect/             # 特效资源
│   ├── fireball/      # 火球特效
│   ├── aura/          # 光环特效
│   └── ...
├── sound/              # 声音资源
│   ├── bgm/           # 背景音乐
│   ├── sfx/           # 音效
│   └── step/          # 脚步声
├── font/               # 字体资源
│   ├── font1.ttf
│   └── font2.ttf
└── texture/            # 纹理资源
    ├── ui/
    └── ...
```

### 4.2 资源加载配置 Resource Loading Configuration

#### 4.2.1 异步加载配置 Asynchronous Loading Configuration

```cpp
// 引擎参数中设置
EngineParameter ep;
ep.bAsyncRead = true;  // 启用异步加载
```

#### 4.2.2 资源预取配置 Resource Prefetch Configuration

```cpp
// 预取精灵动作资源
ISprite* pSprite = ...;
pSprite->PrefetchAction(L"walk");

// 持有特效资源
GetEngine()->HoldEffect(L"fireball");

// 释放特效资源
GetEngine()->ReleaseEffect(L"fireball");
```

#### 4.2.3 资源GC配置 Resource GC Configuration

```cpp
// 设置动画图片GC时间
GetEngine()->GetEnv()->SetAniPicGCTime(20000);  // 20秒

// 设置动画结构GC时间
GetEngine()->GetEnv()->SetAniXapGCTime(1200000);  // 20分钟

// 立即执行GC
GetEngine()->GCNow();
```

## 5. 性能优化配置 Performance Optimization Configuration

### 5.1 渲染优化配置 Rendering Optimization Configuration

#### 5.1.1 批量渲染配置 Batch Rendering Configuration

引擎自动进行批量渲染优化，无需手动配置。

#### 5.1.2 视锥裁剪配置 Frustum Culling Configuration

引擎自动进行视锥裁剪优化，无需手动配置。

#### 5.1.3 层级排序配置 Layer Sorting Configuration

```cpp
// 设置是否排序精灵和地图中层物件
GetEngine()->GetEnv()->SetEnableSortMapObjects(true);
```

### 5.2 内存优化配置 Memory Optimization Configuration

#### 5.2.1 GC配置 GC Configuration

```cpp
// 设置GC冷却时间
GetEngine()->setGCCooldown(5000);  // 5秒

// 设置GC触发阈值
GetEngine()->SetGCMemVolume(500.0f);        // 需要GC的内存阈值（MB）
GetEngine()->SetMustGCMemVolume(600.0f);    // 必须GC的内存阈值（MB）
GetEngine()->SetAvailableMemVolume(100.0f);    // 可用内存阈值（MB）
GetEngine()->SetGCMemFPSValue(30.0f);       // GC触发FPS阈值
GetEngine()->SetGetPicNeedFPSValue(20.0f);   // 同步加载图片需要的FPS阈值
```

#### 5.2.2 资源缓存配置 Resource Cache Configuration

```cpp
// 设置是否使用地表Cache
GetEngine()->GetEnv()->SetEnableSurfaceCache(true);

// 设置是否同步加载水层以下图
GetEngine()->GetEnv()->SetSyncBeforeWater(false);
```

### 5.3 CPU优化配置 CPU Optimization Configuration

#### 5.3.1 任务执行时间配置 Task Execution Time Configuration

```cpp
// 设置每帧任务执行时间
GetEngine()->GetEnv()->SetTaskExecuteTime(XPWS_ACTIVE, 20);  // 20ms

// 设置IO更新执行时间
GetEngine()->GetEnv()->SetIOUpdateExecuteTime(20);  // 20ms
```

#### 5.3.2 FPS控制配置 FPS Control Configuration

```cpp
// 设置不同窗口状态的FPS
GetEngine()->GetEnv()->SetControlFPS(XPWS_ACTIVE, 60);      // 激活60FPS
GetEngine()->GetEnv()->SetControlFPS(XPWS_INACTIVE, 30);    // 非激活30FPS
GetEngine()->GetEnv()->SetControlFPS(XPWS_MINIMIZE, 10);    // 最小化10FPS
```

## 6. 调试配置 Debug Configuration

### 6.1 日志配置 Log Configuration

```cpp
// 设置信息日志路径
GetEngine()->SetInfoLogPath(L"logs/info.log");

// 设置错误日志路径
GetEngine()->SetErrorLogPath(L"logs/error.log");

// 设置Segmpak日志路径
GetEngine()->SetSegmpakLogPath(L"logs/segmpak.log");
```

### 6.2 控制台信息配置 Console Info Configuration

```cpp
// 设置屏幕调试信息开关
void SetConsoleInfo(NuclearConsoleInfo eInfo, bool bOn);

// 测试控制台信息开关
bool TestConsoleInfo(NuclearConsoleInfo eInfo) const;
```

### 6.3 帧状态调试信息配置 Frame State Debug Info Configuration

```cpp
// 设置帧状态调试信息开关
void SetFrameStateInfo(NuclearFrameStatType type, bool bOn);

// 测试帧状态调试信息开关
bool TestFrameStateInfo(NuclearFrameStatType type) const;

// 设置帧状态调试信息颜色
void SetFrameStateColor(NuclearFrameStatType type, NuclearColor color);

// 获取帧状态调试信息颜色
NuclearColor GetFrameStateColor(NuclearFrameStatType type) const;
```

### 6.4 显示调试信息配置 Display Debug Info Configuration

```cpp
// 显示精灵路径
void ShowSpritePath(bool b);

// 显示精灵尾迹
void ShowSpriteTrail(bool b);

// 显示迷宫格子
void ShowMapGrid(bool b);

// 设置迷宫掩码
void SetMapMazeMask(unsigned int mask);

// 获取迷宫掩码
unsigned int GetMapMazeMask() const;
```

## 7. 平台特定配置 Platform Specific Configuration

### 7.1 Windows平台特定配置 Windows Platform Specific Configuration

#### 7.1.1 窗口配置 Window Configuration

```cpp
EngineParameter ep;
ep.szWindowTitle = L"My Game";
ep.szClassName = L"MyGameWindow";
ep.bHasMaximizbox = true;
ep.bSizeBox = true;
```

#### 7.1.2 抗锯齿配置 Anti-aliasing Configuration

```cpp
// 获取可用抗锯齿类型
std::vector<NuclearMultiSampleType> types;
GetEngine()->GetEnv()->GetAvailableMultiSampleType(true, false, types);

// 选择抗锯齿类型
EngineParameter ep;
ep.multiSampleType = XPMULTISAMPLE_4_SAMPLES;
```

### 7.2 Android平台特定配置 Android Platform Specific Configuration

#### 7.2.1 纹理压缩配置 Texture Compression Configuration

```cpp
// Android.mk中定义
LOCAL_CFLAGS := -DCC_SUPPORT_PVRTC
```

#### 7.2.2 内存分配器配置 Memory Allocator Configuration

```cpp
// Android.mk中定义
LOCAL_CFLAGS := -DUSE_NED_MALLOC -DSELF_MALLOC
```

### 7.3 iOS平台特定配置 iOS Platform Specific Configuration

#### 7.3.1 纹理压缩配置 Texture Compression Configuration

```cpp
// Xcode项目中定义
CC_SUPPORT_PVRTC
```

#### 7.3.2 内存分配器配置 Memory Allocator Configuration

```cpp
// Xcode项目中定义
USE_NED_MALLOC
SELF_MALLOC
```

## 8. 配置文件示例 Configuration File Examples

### 8.1 引擎初始化配置示例 Engine Initialization Configuration Example

```cpp
#include "nuiengine.h"

using namespace Nuclear;

class MyApp : public IApp
{
public:
    virtual bool OnInit()
    {
        // 初始化游戏逻辑
        return true;
    }

    virtual void OnTick(DWORD delta)
    {
        // 游戏逻辑更新
    }

    virtual void OnRender()
    {
        // 渲染
    }

    virtual void OnExit()
    {
        // 清理资源
    }
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

### 8.2 环境配置示例 Environment Configuration Example

```cpp
// 获取环境接口
IEnv* pEnv = GetEngine()->GetEnv();

// 显示模式配置
NuclearDisplayMode mode = pEnv->GetDisplayMode();
printf("Screen: %dx%d, %d-bit\n", mode.width, mode.height, mode.bitDepth);

// FPS控制配置
pEnv->SetControlFPS(true);
pEnv->SetControlFPS(XPWS_ACTIVE, 60);
pEnv->SetControlFPS(XPWS_INACTIVE, 30);
pEnv->SetControlFPS(XPWS_MINIMIZE, 10);

// 渲染效果配置
pEnv->SetRenderNightEffectByShader(true);
pEnv->SetRenderSpriteShadow(true);
pEnv->SetBlurForTeleport(true);
pEnv->SetEnableMaskPic(false);
pEnv->SetEnableSurfaceCache(true);
pEnv->SetSyncBeforeWater(false);
pEnv->SetEnableSortMapObjects(true);
pEnv->SetEnableLinkedObjs(true);

// 半透明配置
pEnv->SetSpriteTranslucentType(XPSTT_ELEMENT_TRANSLUCENT);
pEnv->SetMaskAlpha(0.6f);
pEnv->SetRenderSolidMask(true);

// 声音系统配置
pEnv->SetBGMType(0);
pEnv->SetEnvSoundType(1);
pEnv->SetStepSoundType(1);
pEnv->SetStepSoundPriority(40);

// GC配置
pEnv->SetAniPicGCTime(20000);
pEnv->SetAniXapGCTime(1200000);
pEnv->SetMax3DEffectComponentCount(15);

// 平滑移动配置
pEnv->SetSmoothMove(true);
pEnv->SetSpriteMoveSmoothLimit(80);

// 涉水效果配置
pEnv->SetEnableWade(true);

// 任务执行时间配置
pEnv->SetTaskExecuteTime(XPWS_ACTIVE, 30);
pEnv->SetIOUpdateExecuteTime(30);
```

### 8.3 性能优化配置示例 Performance Optimization Configuration Example

```cpp
// 获取引擎和环境接口
IEngine* pEngine = GetEngine();
IEnv* pEnv = pEngine->GetEnv();

// GC配置
pEngine->setGCCooldown(5000);
pEngine->SetGCMemVolume(500.0f);
pEngine->SetMustGCMemVolume(600.0f);
pEngine->SetAvailableMemVolume(100.0f);
pEngine->SetGCMemFPSValue(30.0f);
pEngine->SetGetPicNeedFPSValue(20.0f);

// 资源缓存配置
pEnv->SetEnableSurfaceCache(true);
pEnv->SetSyncBeforeWater(false);

// CPU优化配置
pEnv->SetTaskExecuteTime(XPWS_ACTIVE, 20);
pEnv->SetIOUpdateExecuteTime(20);
```

## 9. 配置最佳实践 Configuration Best Practices

### 9.1 性能优化建议 Performance Optimization Recommendations

1. **FPS控制**: 根据设备性能调整FPS，低端设备降低FPS
2. **异步加载**: 启用异步加载，避免阻塞主线程
3. **资源预取**: 预取即将使用的资源，提升加载速度
4. **GC配置**: 合理设置GC时间，平衡内存和性能
5. **渲染优化**: 启用各项渲染优化，减少Draw Call

### 9.2 内存管理建议 Memory Management Recommendations

1. **及时释放**: 不再使用的资源及时释放
2. **合理缓存**: 常用资源保持缓存，避免重复加载
3. **监控内存**: 定期检查内存使用情况，及时GC
4. **避免泄漏**: 注意资源引用计数，避免内存泄漏

### 9.3 调试建议 Debug Recommendations

1. **启用日志**: 开发时启用详细日志，便于问题定位
2. **调试信息**: 使用调试信息功能，监控性能和状态
3. **性能分析**: 使用性能统计功能，分析性能瓶颈
4. **逐步优化**: 先保证功能正确，再进行性能优化

## 10. 常见问题 FAQ

### 10.1 编译问题 Compilation Issues

**Q: 编译时提示找不到头文件？**
A: 检查包含目录配置，确保所有依赖库的路径正确。

**Q: 链接错误？**
A: 检查链接库配置，确保所有依赖库都已正确链接。

### 10.2 运行时问题 Runtime Issues

**Q: 游戏卡顿？**
A: 检查FPS配置，降低FPS或优化渲染和逻辑。

**Q: 内存占用过高？**
A: 检查GC配置，调整GC时间，及时释放资源。

**Q: 资源加载慢？**
A: 启用异步加载，预取即将使用的资源。

### 10.3 配置问题 Configuration Issues

**Q: 抗锯齿不生效？**
A: 检查显卡是否支持，使用GetAvailableMultiSampleType查询可用类型。

**Q: 夜晚效果不显示？**
A: 检查SetRenderNightEffectByShader配置，确保已启用。

**Q: 声音播放不正常？**
A: 检查声音类型配置，确保音量和优先级设置正确。
