# EffectEditor 技术文档

> **版本**: 2.0.0 | **更新日期**: 2026-03-02 | **工具集**: Visual Studio 2013 (v120)

---

## 目录

1. [概述](#1-概述)
2. [架构设计](#2-架构设计)
3. [核心接口](#3-核心接口)
4. [使用指南](#4-使用指南)
5. [技术边界](#5-技术边界)

---

## 1. 概述

### 1.1 工具功能描述

EffectEditor 是MT3项目的特效编辑器，用于创建和编辑游戏中的视觉特效资源。该工具支持粒子特效、音频特效和角色绑定特效的编辑，为游戏提供丰富的视觉效果。

### 1.2 主要特性

| 特性 | 说明 |
|------|------|
| **粒子系统** | 支持粒子发射器、颜色渐变、大小变化等 |
| **音频同步** | 支持特效与音频文件的同步播放 |
| **角色绑定** | 特效可绑定到角色骨骼点 |
| **时间轴编辑** | 可视化时间轴，支持多轨道编辑 |
| **关键帧动画** | 支持位置、缩放、旋转、颜色等属性的关键帧 |
| **曲线编辑器** | 贝塞尔曲线编辑器，精细控制动画曲线 |
| **实时预览** | 编辑时实时预览特效效果 |

### 1.3 技术栈

```yaml
语言: C++
框架: MFC (Microsoft Foundation Classes)
工具集: Visual Studio 2013 (v120)
依赖:
  - Nuclear引擎 (渲染支持)
  - DirectSound (音频播放)
  - GDI+ (界面绘制)
```

---

## 2. 架构设计

### 2.1 核心类结构

```
┌─────────────────────────────────────────────────────────────┐
│                    EffectEditor 架构                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │ CEffectEditorApp│    │    MainFrm      │                │
│  │ (应用程序类)     │    │  (主框架窗口)    │                │
│  └────────┬────────┘    └────────┬────────┘                │
│           │                      │                          │
│           ▼                      ▼                          │
│  ┌─────────────────────────────────────────────┐           │
│  │            CEffectEditorDoc                 │           │
│  │  (文档类 - 特效数据管理)                      │           │
│  │  ├── CToolsEffect (特效工具类)               │           │
│  │  ├── CToolsSebind (角色绑定工具)             │           │
│  │  ├── Sprite (角色精灵)                       │           │
│  │  └── EffectClipSet (选中特效片段)            │           │
│  └─────────────────────┬───────────────────────┘           │
│                        │                                    │
│           ┌────────────┼────────────┐                      │
│           ▼            ▼            ▼                      │
│  ┌─────────────┐ ┌───────────┐ ┌──────────────┐           │
│  │CEffectEditor│ │ TimeBarView│ │ PropertyView │           │
│  │    View     │ │ (时间轴)    │ │  (属性面板)   │           │
│  │ (渲染视图)   │ └───────────┘ └──────────────┘           │
│  └─────────────┘                                            │
│                                                             │
│  ┌─────────────────────────────────────────────┐           │
│  │              特效属性面板                     │           │
│  │  ├── ParticleProp (粒子属性)                 │           │
│  │  ├── AudioProp (音频属性)                    │           │
│  │  ├── AniPicProp (动画图片属性)               │           │
│  │  ├── RoleProp (角色属性)                     │           │
│  │  └── EffectProp (特效属性)                   │           │
│  └─────────────────────────────────────────────┘           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块 | 文件 | 职责 |
|------|------|------|
| **文档模块** | `EffectEditorDoc.cpp/h` | 特效数据管理、文件I/O |
| **视图模块** | `EffectEditorView.cpp/h` | 渲染、用户交互 |
| **时间轴模块** | `TimeBarView.cpp/h`, `TimeBarCtrl.cpp/h` | 时间轴编辑 |
| **属性面板** | `PropertyView.cpp/h`, `TabPropPanel.cpp/h` | 属性编辑 |
| **特效工具** | `ToolsEffect.cpp/h` | 特效操作封装 |
| **角色绑定** | `ToolsSebind.cpp/h` | 角色绑定特效 |
| **曲线编辑** | `BezierControl.cpp/h`, `DlgProp*Curve.cpp/h` | 曲线编辑器 |

### 2.3 数据流

```
┌──────────────┐     加载      ┌──────────────┐
│ .effect文件  │─────────────▶│CEffectEditor │
│ .sebind文件  │              │    Doc       │
└──────────────┘              └──────┬───────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              │                      │                      │
              ▼                      ▼                      ▼
     ┌────────────────┐    ┌────────────────┐    ┌────────────────┐
     │ CToolsEffect   │    │  CToolsSebind  │    │    Sprite      │
     │ (特效管理)      │    │  (角色绑定)     │    │  (角色精灵)     │
     └────────┬───────┘    └────────────────┘    └────────────────┘
              │
              ▼
     ┌────────────────────────────────────────────┐
     │            EffectClip (特效片段)            │
     │  ├── ParticleEffectClip (粒子特效)         │
     │  ├── AudioEffectClip (音频特效)            │
     │  ├── AniPicEffectClip (动画图片特效)       │
     │  └── RoleEffectClip (角色特效)             │
     └────────────────────────────────────────────┘
              │
              ▼
     ┌────────────────────────────────────────────┐
     │            渲染与预览                       │
     │  ├── CEffectEditorView (主视图)            │
     │  ├── TimeBarView (时间轴)                  │
     │  └── PropertyView (属性面板)               │
     └────────────────────────────────────────────┘
```

---

## 3. 核心接口

### 3.1 主要类和方法

#### CEffectEditorDoc (文档类)

```cpp
class CEffectEditorDoc : public CDocument {
public:
    // 文件操作
    virtual BOOL OnNewDocument();
    virtual BOOL OnOpenDocument(LPCTSTR lpszPathName);
    virtual BOOL OnSaveDocument(LPCTSTR lpszPathName);
    
    // 特效管理
    Nuclear::AbstractEffectClip* AddEffectClip(int layer, int startFrame, int endFrame);
    bool DelEffectClip(Nuclear::AbstractEffectClip* clip);
    bool ModifyLayer(Nuclear::AbstractEffectClip* clip, int layer);
    bool ModifyStartEndFrame(Nuclear::AbstractEffectClip* clip, int startFrame, int endFrame, CView* pSender);
    
    // 播放控制
    bool Play();
    bool Pause();
    bool Stop();
    bool SetPlayingFrame(int frame);
    float GetPlayingFrame() const;
    Nuclear::XPEffectState GetPlayState() const;
    
    // 属性设置
    void SetFPS(float fps);
    float GetFPS() const;
    bool SetTotalFrameNum(int frames);
    int GetTotalFrames() const;
    
    // 特效属性修改
    bool SetScaleForSelectedClip(const Nuclear::FPOINT& scale);
    bool SetRotationForSelectedClip(float angle);
    bool SetSelectedClipColors(const ColorKeyMap& keyMap);
    bool SetSelectedClipFPS(float fps, CView* pSender);
    
    // 角色绑定
    Nuclear::Effect* GetBindEffect();
    void SetEffectForBind(Nuclear::Effect* pEffect);
    void SetSpriteDirection(Nuclear::XPDIRECTION dir);
    void SetSpritePosition(const Nuclear::Location& pos);
    
    // 选择管理
    bool SelectClip(Nuclear::AbstractEffectClip* pClip);
    void ClearSelectedClips();
    const EffectClipSet& GetSelectedClips() const;
    
private:
    CToolsEffect* m_pToolsEffect;       // 特效工具类
    CToolsSebind m_ToolsSebind;         // 角色绑定工具
    Sprite* m_pSprite;                  // 角色精灵
    EffectClipSet m_pSelectedEffectClips; // 选中的特效片段
    eEffectFileType m_EffectFileType;   // 文件类型
};
```

#### CEffectEditorView (视图类)

```cpp
class CEffectEditorView : public CView, Nuclear::IEffectClipControl, Nuclear::EngineBase {
public:
    // 渲染
    virtual void OnDraw(CDC* pDC);
    void RenderEffect();
    
    // EngineBase 接口实现
    virtual Nuclear::Renderer* GetRenderer(HWND hwnd = NULL);
    virtual Nuclear::EffectManager* GetEffectManager();
    virtual Nuclear::AniManager* GetAniManager();
    virtual Nuclear::SpriteManager* GetSpriteManager();
    virtual Nuclear::DirectSoundManager* GetSoundManager();
    
    // IEffectClipControl 接口实现
    virtual bool GetRotationRadian(float& angle) const;
    virtual bool GetScale(Nuclear::FPOINT& scale) const;
    
    // 工具状态
    void SetToolState(eToolState state);
    eToolState GetToolState() const;
    
    // 背景设置
    void SetBackgroundColor(Nuclear::XPCOLOR color);
    bool SetBackgroundPicture(const wchar_t* filename);
    
    // 显示控制
    void SetShowBox(bool show);
    void SetShowCenterCross(bool show);
    
private:
    Nuclear::Renderer* m_pRenderer;
    Nuclear::EffectManager* m_pEffectManager;
    Nuclear::DirectSoundManager* m_pSoundManager;
    eToolState m_ToolsState;
    eBackgroundMode m_BgMode;
};
```

#### CToolsEffect (特效工具类)

```cpp
class CToolsEffect : public Nuclear::GEffect {
public:
    // 特效片段管理
    Nuclear::AbstractEffectClip* AddClip(int layer, int startFrame, int endFrame);
    bool AddClip(Nuclear::AbstractEffectClip* clip);
    bool DelClip(Nuclear::AbstractEffectClip* clip);
    bool ModifyLayer(Nuclear::AbstractEffectClip* clip, int layer);
    bool ModifyStartEndFrame(Nuclear::AbstractEffectClip* clip, int startFrame, int endFrame);
    
    // 时间轴控制
    bool SetPlayingFrame(int frame);
    void SetBoundsRect(const Nuclear::CRECT& rc);
    bool SetTotalFrame(int frames);
    
    // 文件操作
    int LoadEffectClips(XMLIO::CINode& root, int flag);
    int SaveEffect(XMLIO::CONode& root, XMLIO::CONode* soundcliproot, int flag);
    bool SaveEffect(LPCTSTR lpszPathName, int flag);
    
    // 获取片段列表
    void GetClipList(int layer, Nuclear::AbstractEffectClip_LIST& clipList);
};
```

### 3.2 文件格式规范

#### .effect 文件格式 (特效定义文件)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<effect version="2.0" fps="30" totalFrames="100">
    <!-- 边界框定义 -->
    <bounds x="-100" y="-100" width="200" height="200"/>
    
    <!-- 特效片段列表 -->
    <clips>
        <!-- 粒子特效 -->
        <clip type="particle" layer="1" startFrame="0" endFrame="50">
            <emitter>
                <position x="0" y="0"/>
                <direction min="0" max="360"/>
                <speed min="50" max="100"/>
                <emissionRate value="30"/>
                <particleLife min="1.0" max="2.0"/>
            </emitter>
            <particle>
                <size start="10" end="2"/>
                <color>
                    <key time="0" r="255" g="255" b="255" a="255"/>
                    <key time="0.5" r="255" g="128" b="0" a="200"/>
                    <key time="1" r="255" g="0" b="0" a="0"/>
                </color>
            </particle>
            <texture path="effect/particle/fire.png"/>
        </clip>
        
        <!-- 音频特效 -->
        <clip type="audio" layer="0" startFrame="5" endFrame="35">
            <sound path="effect/sound/explosion.wav" volume="100"/>
        </clip>
        
        <!-- 动画图片特效 -->
        <clip type="anipic" layer="2" startFrame="10" endFrame="40">
            <animation path="effect/anim/explosion.ani" fps="15"/>
            <position x="0" y="0"/>
            <scale x="1.0" y="1.0"/>
            <rotation angle="0"/>
        </clip>
    </clips>
</effect>
```

#### .sebind 文件格式 (角色绑定特效)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<sebind version="1.0">
    <!-- 绑定的角色精灵 -->
    <sprite model="model/character/warrior.xml"/>
    
    <!-- 特效绑定点 -->
    <bindings>
        <binding bone="hand_right" effect="effect/weapon/fire.effect">
            <offset x="10" y="0"/>
        </binding>
        <binding bone="foot_left" effect="effect/step/dust.effect">
            <trigger action="walk" frame="3"/>
        </binding>
    </bindings>
</sebind>
```

#### 文件结构说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `effect` | 根元素 | 特效定义，包含fps和总帧数 |
| `bounds` | 复合 | 边界框定义 |
| `clips/clip` | 复合 | 特效片段，type可以是particle/audio/anipic |
| `emitter` | 复合 | 粒子发射器配置 |
| `particle` | 复合 | 粒子属性配置 |
| `color/key` | 复合 | 颜色关键帧 |
| `sebind` | 根元素 | 角色绑定特效定义 |
| `bindings/binding` | 复合 | 特效绑定点配置 |

---

## 4. 使用指南

### 4.1 构建说明

#### 环境要求

```yaml
操作系统: Windows 7/8/10/11
IDE: Visual Studio 2013
工具集: v120 (必须)
Windows SDK: 8.1
依赖库:
  - Nuclear引擎库
  - DirectSound库
  - GDI+库
```

#### 构建步骤

```powershell
# 1. 打开 Visual Studio 2013
# 2. 打开项目文件
start tools\engine\EffectEditor\EffectEditor.vcxproj

# 3. 选择配置
#    - Debug: 调试版本
#    - Release: 发布版本

# 4. 构建项目 (Ctrl+Shift+B)
# 或使用命令行
msbuild EffectEditor.vcxproj /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120
```

#### 输出位置

```
tools/engine/EffectEditor/
├── Debug/
│   └── EffectEditor.exe    # 调试版本
└── Release/
    └── EffectEditor.exe    # 发布版本
```

### 4.2 基本操作流程

#### 创建新特效

1. **文件 → 新建** (Ctrl+N)
2. 选择特效类型：
   - 普通特效 (.effect)
   - 角色绑定特效 (.sebind)
3. 设置基本参数：
   - 帧率 (FPS)
   - 总帧数
   - 边界框大小

#### 添加特效片段

1. 在时间轴上右键点击
2. 选择"添加特效片段"
3. 选择片段类型：
   - 粒子特效
   - 音频特效
   - 动画图片
4. 在属性面板中配置参数

#### 编辑粒子特效

1. 选中粒子特效片段
2. 在属性面板中设置：
   - 发射器位置
   - 发射方向和速度
   - 粒子生命周期
   - 颜色渐变
   - 纹理贴图
3. 使用曲线编辑器精细调整

#### 创建角色绑定特效

1. **文件 → 新建 → 角色绑定特效**
2. 选择要绑定的角色模型
3. 添加绑定点：
   - 选择骨骼点
   - 选择要绑定的特效
   - 设置偏移量
4. 设置触发条件（动作、帧）

### 4.3 输入/输出格式

#### 输入格式

| 格式 | 扩展名 | 说明 |
|------|--------|------|
| 特效文件 | `.effect` | XML格式的特效定义 |
| 绑定文件 | `.sebind` | 角色绑定特效定义 |
| 粒子纹理 | `.png`, `.tga` | 粒子贴图 |
| 音频文件 | `.wav`, `.mp3` | 音频资源 |
| 动画文件 | `.ani` | Nuclear动画格式 |

#### 输出格式

| 格式 | 扩展名 | 说明 |
|------|--------|------|
| 特效文件 | `.effect` | XML格式的特效定义 |
| 绑定文件 | `.sebind` | 角色绑定特效定义 |

---

## 5. 技术边界

### 5.1 不支持的功能

| 功能 | 说明 | 替代方案 |
|------|------|----------|
| **3D粒子** | 不支持真正的3D粒子系统 | 使用2D粒子模拟3D效果 |
| **物理模拟** | 不支持物理碰撞和力学 | 使用预设动画曲线 |
| **视频导入** | 不支持直接导入视频 | 转换为序列帧后使用 |
| **实时协作** | 不支持多人同时编辑 | 使用版本控制系统 |
| **脚本扩展** | 不支持用户脚本 | 需修改源码添加功能 |

### 5.2 已知限制

| 限制 | 说明 | 影响 |
|------|------|------|
| **粒子数量** | 单个发射器建议不超过1000粒子 | 过多影响性能 |
| **片段层数** | 建议不超过10层 | 过多影响编辑效率 |
| **音频格式** | 仅支持WAV和MP3 | 其他格式需转换 |
| **帧率限制** | 建议15-60 FPS | 过高影响性能 |
| **内存占用** | 大型特效可能占用较多内存 | 建议分批编辑 |

### 5.3 扩展建议

#### 添加新特效类型

1. 继承 [`Nuclear::AbstractEffectClip`](../../../engine/effect/geffect.h:1) 类
2. 实现必要的虚函数：
   ```cpp
   class MyEffectClip : public Nuclear::AbstractEffectClip {
   public:
       virtual void Update(DWORD tickTime);
       virtual void Render(Nuclear::Renderer* pRenderer);
       virtual bool Save(XMLIO::CONode& node);
       virtual bool Load(XMLIO::CINode& node);
   };
   ```
3. 在 [`ToolsEffect.cpp`](../ToolsEffect.cpp:1) 中注册新类型
4. 添加对应的属性面板

#### 添加新属性编辑器

1. 创建属性对话框类
2. 继承属性面板接口
3. 在 [`TabPropPanel.cpp`](../TabPropPanel.cpp:1) 中注册

#### 性能优化建议

```cpp
// 1. 使用对象池管理粒子
ParticlePool pool(1000);  // 预分配1000个粒子

// 2. 使用脏标志避免不必要的更新
if (m_bNeedReplay) {
    UpdateEffect();
    m_bNeedReplay = false;
}

// 3. 批量渲染
pRenderer->BeginBatch();
for (auto& clip : clips) {
    clip->Render(pRenderer);
}
pRenderer->EndBatch();
```

---

## 附录

### A. 快捷键参考

| 快捷键 | 功能 |
|--------|------|
| Ctrl+N | 新建特效 |
| Ctrl+O | 打开特效 |
| Ctrl+S | 保存特效 |
| Space | 播放/暂停 |
| Ctrl+Z | 撤销 |
| Ctrl+Y | 重做 |
| Delete | 删除选中片段 |
| Ctrl+C | 复制片段 |
| Ctrl+V | 粘贴片段 |
| Left/Right | 上一帧/下一帧 |
| Home | 跳转到开始帧 |
| End | 跳转到结束帧 |

### B. 特效类型说明

| 类型 | 类名 | 说明 |
|------|------|------|
| 粒子特效 | `ParticleEffectClip` | 粒子系统特效 |
| 音频特效 | `AudioEffectClip` | 音频播放特效 |
| 动画图片 | `AniPicEffectClip` | 序列帧动画特效 |
| 角色特效 | `RoleEffectClip` | 角色绑定特效 |

### C. 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 2.0.0 | 2025-06-01 | 添加角色绑定功能，优化时间轴 |
| 1.5.0 | 2025-01-01 | 添加曲线编辑器 |
| 1.0.0 | 2024-01-01 | 初始版本 |

### D. 相关文档

- [README.md](../README.md) - 项目概述
- [AGENTS.md](../../../../AGENTS.md) - 项目技术规范
- [BUILD_GUIDE.md](../../../../.claude/BUILD_GUIDE.md) - 构建指南

---

**维护者**: 技术委员会
**下次审查**: 2026-06-02
**许可证**: 内部使用
