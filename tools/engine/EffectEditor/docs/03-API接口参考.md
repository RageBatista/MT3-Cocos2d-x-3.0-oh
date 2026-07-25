# EffectEditor API 接口参考

> 版本: 1.0  
> 生成日期: 2026-04-25  
> 基于源码: `tools/engine/EffectEditor/` 全部源文件  

---

## 1. CEffectEditorApp

**头文件**: `EffectEditor.h`  
**基类**: `CWinApp`

### 构造/析构

```cpp
CEffectEditorApp();
virtual ~CEffectEditorApp();
```

### 生命周期

```cpp
/**
 * @brief 应用初始化入口
 * @return TRUE 初始化成功，FALSE 失败退出
 * 
 * 执行顺序：
 * 1. 创建 CFileIOManager 并 Init(true, true)
 * 2. InitCommonControlsEx
 * 3. CWinApp::InitInstance
 * 4. AfxOleInit
 * 5. 注册 CSingleDocTemplate (Doc/MainFrame/View)
 * 6. ProcessShellCommand
 * 7. 显示主窗口
 */
virtual BOOL InitInstance();

/**
 * @brief 应用退出清理
 * @return CWinApp::ExitInstance 返回值
 * 
 * 销毁 m_pFileIOMgr
 */
virtual int ExitInstance();
```

### 访问器

```cpp
/**
 * @brief 获取可执行文件目录
 * @return 目录路径，如 "E:\MT3\tools\engine\EffectEditor"
 */
CString GetExePath();

/**
 * @brief 获取配置文件路径
 * @return 配置文件完整路径，如 "ExePath\EffectEditorCfg.ini"
 */
CString GetCfgFilePath();

/**
 * @brief 获取 PFS 文件 I/O 管理器
 * @return 管理器指针，可能为 NULL
 */
Nuclear::CFileIOManager* GetFileIOManager();

/**
 * @brief 获取引擎实例
 * @return 引擎指针，可能为 NULL
 */
Nuclear::EngineBase* GetEngine();

/**
 * @brief 设置引擎实例
 * @param pEB 引擎指针
 */
void SetEngine(Nuclear::EngineBase *pEB);
```

### 命令处理

```cpp
/**
 * @brief 批量导出特效文件
 * 
 * 流程：
 * 1. 选择源目录 (默认 ExePath\effect\geffect)
 * 2. 选择目标目录
 * 3. 递归遍历源目录所有 .geffect 文件
 * 4. 对每个文件：PFS 路径转换 → LoadEffect → SaveEffect
 * 5. 失败文件写入 explog.txt
 */
afx_msg void OnBatchExport();

afx_msg void OnAppAbout();
```

---

## 2. CEffectEditorDoc

**头文件**: `EffectEditorDoc.h`  
**基类**: `CDocument`

### 初始化

```cpp
/**
 * @brief 初始化特效 (停止播放)
 * @return bool (注意: 实际无 return 语句)
 * 
 * 调用 m_pToolsEffect->Stop()
 */
bool Init();
```

### 播放控制

```cpp
/**
 * @brief 帧推进
 * @param dt 距上一帧的时间间隔 (毫秒)
 * 
 * Effect 模式：m_pToolsEffect->Update(dt)
 * Sebind 模式：m_ToolsSebind.Tick(m_pSprite, dt)
 * 播放中同时推进 Sprite 帧
 */
void Tick(DWORD dt);

/**
 * @brief 渲染特效
 * @param pRenderer 渲染器指针
 * 
 * Effect 模式：RenderBack → Sprite → RenderFront → 中心十字
 * Sebind 模式：Effect → Sprite → Effect → 中心十字
 * 末尾通知所有 INotify::OnRender()
 */
void Draw(Nuclear::Renderer* pRenderer);

/**
 * @brief 播放特效
 * @return true 成功
 * 
 * 先尝试 Play()，失败则 Resume()
 */
bool Play();

/**
 * @brief 停止特效
 * @return true 成功
 * 
 * 停止特效 + 重置 Sprite 帧到 0
 */
bool Stop();

/**
 * @brief 暂停特效
 * @return true 成功
 */
bool Pause();

/**
 * @brief 设置当前播放帧
 * @param frame 目标帧号 (小于 0 会被钳位到 0)
 * @return true 成功
 * 
 * Effect 模式：CToolsEffect::SetPlayingFrame
 * Sebind 模式：Sprite::SetFrame
 */
bool SetPlayingFrame(int frame);

/**
 * @brief 获取当前播放帧
 * @return 浮点帧号
 * 
 * Effect 模式：GEffect::GetPlayingFrame
 * Sebind 模式：Sprite::GetFloatFrame
 */
float GetPlayingFrame() const;

/**
 * @brief 获取播放状态
 * @return 播放状态枚举
 */
Nuclear::XPEffectState GetPlayState() const;
```

### 特效属性

```cpp
/**
 * @brief 设置 FPS
 * @param fps 帧率值
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
void SetFPS(float fps);

/**
 * @brief 获取 FPS
 * @return 帧率值
 */
float GetFPS() const;

/**
 * @brief 设置总帧数
 * @param frames 总帧数
 * @return true 设置成功 (无 Clip 超出范围)
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
bool SetTotalFrameNum(int frames);

/**
 * @brief 获取总帧数
 * @return 总帧数
 */
int GetTotalFrames() const;

/**
 * @brief 设置前后分层位置
 * @param layer 分层位置索引
 * @return true 设置成功
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
bool SetDivideLayer(int layer);

/**
 * @brief 获取前后分层位置
 * @return 分层位置索引
 */
int GetDivideLayer() const;

/**
 * @brief 设置包围盒
 * @param rt 包围盒矩形 (相对坐标)
 * 
 * 带撤销支持
 */
void SetBoundsRect(const Nuclear::CRECT &rt);

/**
 * @brief 设置绑定类型
 * @param t 绑定类型枚举
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
void SetBindType(Nuclear::XPEFFECT_BIND_TYPE t);

/**
 * @brief 获取绑定类型
 * @return 绑定类型枚举
 */
Nuclear::XPEFFECT_BIND_TYPE GetBindType() const;

/**
 * @brief 获取相对包围盒
 * @return 包围盒矩形引用
 */
const Nuclear::CRECT& GetRelativeBouningBox() const;

/**
 * @brief 获取当前文件类型
 * @return EFT_EFFECT 或 EFT_SEBIND
 */
eEffectFileType GetEffectFileType() const;
```

### Clip 操作

```cpp
/**
 * @brief 添加 Clip
 * @param layer 层级 (0 ~ MAX_CLIP_LAYER-1)
 * @param startFrame 起始帧
 * @param endFrame 结束帧
 * @return 新创建的 Clip 指针，失败返回 NULL
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
Nuclear::AbstractEffectClip* AddEffectClip(int layer, int startFrame, int endFrame);

/**
 * @brief 删除 Clip
 * @param clip 要删除的 Clip 指针
 * @return true 删除成功
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
bool DelEffectClip(Nuclear::AbstractEffectClip* clip);

/**
 * @brief 修改 Clip 层级
 * @param clip 目标 Clip
 * @param layer 新层级
 * @return true 修改成功
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
bool ModifyLayer(Nuclear::AbstractEffectClip* clip, int layer);

/**
 * @brief 修改 Clip 起止帧
 * @param clip 目标 Clip
 * @param startFrame 新起始帧
 * @param endFrame 新结束帧 (-1 表示特殊 Clip)
 * @param pSender 触发此操作的视图 (用于定向更新)
 * @return true 修改成功
 * 
 * 仅 Effect 模式有效，带撤销支持
 */
bool ModifyStartEndFrame(Nuclear::AbstractEffectClip* clip, int startFrame, int endFrame, CView* pSender);

/**
 * @brief 选中 Clip
 * @param pClip 要选中的 Clip
 * @return true 选中成功 (之前未选中)
 * 
 * Sebind 模式下始终返回 false
 */
bool SelectClip(Nuclear::AbstractEffectClip* pClip);

/**
 * @brief 取消选中 Clip
 * @param pClip 要取消选中的 Clip
 * @return 移除的元素数
 * 
 * Sebind 模式下始终返回 0
 */
size_t UnSelectClip(Nuclear::AbstractEffectClip* pClip);

/**
 * @brief 取消全部选中
 * 
 * Sebind 模式下无操作
 */
void UnSelectedAllClip();

/**
 * @brief 获取选中 Clip 集合
 * @return 选中 Clip 的 set 引用
 */
const EffectClipSet& GetSelectedClips();

/**
 * @brief 移动选中 Clip
 * @param addX X 方向偏移 (像素)
 * @param addY Y 方向偏移 (像素)
 * 
 * 带撤销支持
 */
void MoveSelectedClips(int addX, int addY);

/**
 * @brief 设置选中 Clip 缩放
 * @param scale 缩放值 (FPOINT: x, y)
 * @return true 设置成功 (仅单选时有效)
 * 
 * 带撤销支持，在当前帧添加/修改缩放关键帧
 */
bool SetScaleForSelectedClip(const Nuclear::FPOINT& scale);

/**
 * @brief 设置选中 Clip 旋转
 * @param angle 旋转弧度
 * @return true 设置成功 (仅单选时有效)
 * 
 * 带撤销支持，在当前帧添加/修改旋转关键帧
 */
bool SetRotationForSelectedClip(float angle);

/**
 * @brief 修改选中 Clip 位置
 * @param adjPoint 位置偏移 (CPoint: x, y)
 * @return true 修改成功
 * 
 * 带撤销支持，在当前帧添加/修改位置关键帧
 */
bool ModifyAdjPosForSelectedClip(CPoint adjPoint);

/**
 * @brief 设置选中 Clip 颜色关键帧
 * @param keyMap 颜色关键帧映射 (帧号 → XPCOLOR)
 * @return true 设置成功
 * 
 * 带撤销支持
 */
bool SetSelectedClipColors(const ColorKeyMap& keyMap);

/**
 * @brief 设置选中 Clip 单值关键帧 (旋转/透明度)
 * @param kt 关键帧类型 (KT_ROTATION / KT_ALPHA)
 * @param vKP 关键点向量
 * @param vSP 采样点向量
 * @param keyMap 关键帧映射 (帧号 → float)
 * @return true 设置成功
 * 
 * 带撤销支持
 */
bool SetSelectedClipSingleKeys(
    Nuclear::AbstractEffectClip::KeyType kt,
    const Nuclear::AbstractEffectClip::KP_VECTOR& vKP,
    const Nuclear::AbstractEffectClip::SP_VECTOR& vSP,
    const SingleKeyMap& keyMap);

/**
 * @brief 设置选中 Clip 双值关键帧 (位置/缩放)
 * @param kt 关键帧类型 (KT_POS / KT_SCALE)
 * @param vKP 关键点向量
 * @param vSP 采样点向量
 * @param keyMap 关键帧映射 (帧号 → FPOINT)
 * @return true 设置成功
 * 
 * 带撤销支持
 */
bool SetSelectedClipDoubleKeys(
    Nuclear::AbstractEffectClip::KeyType kt,
    const Nuclear::AbstractEffectClip::KP_VECTOR& vKP,
    const Nuclear::AbstractEffectClip::SP_VECTOR& vSP,
    const DoubleKeyMap& keyMap);

/**
 * @brief 设置选中 Clip 特殊标记
 * @param spec 是否特殊
 * @param pSender 触发视图
 * @return true 设置成功
 * 
 * 带撤销支持
 */
bool SetSelectedClipSpec(bool spec, CView* pSender);

/**
 * @brief 设置选中 Clip 播放模式与时间
 * @param type 播放模式 (XPPM_LOOP / XPPM_LOOPNUM / XPPM_TIME)
 * @param nTime 播放时间/循环次数
 * @param pSender 触发视图
 * @return true 设置成功
 * 
 * 带撤销支持
 */
bool SaveSelectedClipPlayModeAndTime(Nuclear::XPPLAY_MODE type, int nTime, CView* pSender);

/**
 * @brief 设置选中 Clip 顶点色
 * @param color 顶点颜色
 * @param pSender 触发视图
 * @return true 设置成功
 * 
 * 带撤销支持
 */
bool SetSelectedClipVertexColor(const Nuclear::XPCOLOR& color, CView* pSender);

/**
 * @brief 设置选中 Clip FPS
 * @param fps 帧率
 * @param pSender 触发视图
 * @return true 设置成功
 * 
 * 带撤销支持
 */
bool SetSelectedClipFPS(float fps, CView* pSender);

/**
 * @brief 设置选中音频属性
 * @param nID 属性 ID
 * @param value 属性值 (0-255)
 * @return true 设置成功
 */
bool SetSelectedAudioSoundProperty(int nID, unsigned char value);

/**
 * @brief 设置选中 Clip 控制回调
 * @param control 控制接口指针 (旋转/缩放工具使用)
 */
void SetSelectClipsControl(const Nuclear::IEffectClipControl* control);
```

### Sprite/角色操作

```cpp
/**
 * @brief 设置 Sprite 位置
 * @param pos 位置坐标
 * 
 * 同时设置 m_pToolsEffect->SetLocation(pos) 和 m_pSprite->SetPosition(pos)
 * 包含 assert(m_pSprite != NULL) 和 assert(m_pToolsEffect != NULL)
 */
void SetSpritePosition(const Nuclear::Location &pos);

/**
 * @brief 设置 Sprite 方向
 * @param dir 方向枚举
 */
void SetSpriteDirection(Nuclear::XPDIRECTION dir);

/**
 * @brief 获取方向
 * @return 当前方向枚举
 */
Nuclear::XPDIRECTION GetDirection();

/**
 * @brief 设置是否绘制角色
 * @param isDraw true 绘制
 */
void SetDrawRole(bool isDraw);

/**
 * @brief 获取是否绘制角色
 * @return true 绘制
 */
bool IsDrawRole();

/**
 * @brief 通过名称设置动作
 * @param name 动作名
 * 
 * 同时调用 ResetEffectForBind() 和 UpdateAllViews()
 */
void SetActionByName(const std::wstring& name);

/**
 * @brief 通过名称设置模型
 * @param modelname 模型名
 */
void SetModelByName(const std::wstring &modelname);

/**
 * @brief 获取组件名
 * @param sc 组件索引
 * @return 组件资源名
 */
std::wstring GetComponent(int sc);

/**
 * @brief 设置组件
 * @param sc 组件索引
 * @param resource 资源名
 * @param color 颜色 (默认 0xffffffff)
 */
void SetComponent(int sc, const std::wstring& resource, Nuclear::XPCOLOR color=0xffffffff);

int GetSpriteTotalTime();
int GetFrameCount();
std::wstring GetActionName() const;
std::wstring GetModelName() const;
```

### Sebind 操作

```cpp
/**
 * @brief 获取绑定特效
 * @return 特效指针
 */
Nuclear::Effect* GetBindEffect();
const Nuclear::Effect* GetBindEffect() const;

/**
 * @brief 设置绑定特效
 * @param pEffect 特效指针 (接管所有权)
 * 
 * 仅 Sebind 模式有效 (XPASSERT 检查)
 * 设置后标记 m_bNeedReplay = true
 */
void SetEffectForBind(Nuclear::Effect *pEffect);

/**
 * @brief 重置绑定特效
 * 
 * 根据当前 Sprite 方向/动作重新创建或获取对应 Clip
 */
void ResetEffectForBind();
```

### 通知

```cpp
/**
 * @brief 注册通知监听器
 * @param pNotify 监听器指针
 * @return true 注册成功 (未重复注册)
 */
bool AddNotify(INotify *pNotify);
```

### 文件操作

```cpp
afx_msg void OnFileOpen();
afx_msg void OnFileNew();
afx_msg void OnRefresh();
afx_msg void OnFileExport();
virtual BOOL OnSaveDocument(LPCTSTR lpszPathName);
virtual BOOL OnOpenDocument(LPCTSTR lpszPathName);
virtual BOOL DoSave(LPCTSTR lpszPathName, BOOL bReplace = TRUE);
virtual void Serialize(CArchive& ar);
virtual BOOL OnNewDocument();
```

### 撤销/重做

```cpp
afx_msg void OnEditUndo();
afx_msg void OnEditRedo();
afx_msg void OnUpdateEditUndo(CCmdUI *pCmdUI);
afx_msg void OnUpdateEditRedo(CCmdUI *pCmdUI);
```

---

## 3. CToolsEffect

**头文件**: `ToolsEffect.h`  
**基类**: `Nuclear::GEffect`

### 构造

```cpp
/**
 * @brief 构造函数
 * @param pEB 引擎基类指针
 * 
 * 初始化 FPS 为 8.0
 */
CToolsEffect(Nuclear::EngineBase* pEB);
```

### Clip 管理

```cpp
/**
 * @brief 创建并添加新 Clip
 * @param layer 层级 [0, MAX_CLIP_LAYER)
 * @param startFrame 起始帧 [0, ∞)
 * @param endFrame 结束帧 [startFrame, totalFrames) 或 -1
 * @return 新 Clip 指针，失败返回 NULL
 */
Nuclear::AbstractEffectClip* AddClip(int layer, int startFrame, int endFrame);

/**
 * @brief 添加已有 Clip 到指定层
 * @param clip Clip 指针
 * @param layer 目标层级
 * @return true 添加成功
 */
bool AddClip(Nuclear::AbstractEffectClip* clip, int layer);

/**
 * @brief 添加已有 Clip (使用 Clip 自身 layer)
 * @param clip Clip 指针
 * @return true 添加成功
 */
bool AddClip(Nuclear::AbstractEffectClip* clip);

/**
 * @brief 删除 Clip
 * @param clip 要删除的 Clip
 * @return true 删除成功
 */
bool DelClip(Nuclear::AbstractEffectClip* clip);

/**
 * @brief 修改 Clip 层级
 * @param clip 目标 Clip
 * @param layer 新层级
 * @return true 修改成功
 */
bool ModifyLayer(Nuclear::AbstractEffectClip* clip, int layer);

/**
 * @brief 修改 Clip 起止帧
 * @param clip 目标 Clip
 * @param startFrame 新起始帧
 * @param endFrame 新结束帧
 * @return true 修改成功
 */
bool ModifyStartEndFrame(Nuclear::AbstractEffectClip* clip, int startFrame, int endFrame);
```

### 特效属性

```cpp
/**
 * @brief 设置包围盒 (直接赋值，不经过验证)
 * @param rc 包围盒矩形
 */
void SetBoundsRect(const Nuclear::CRECT& rc);

/**
 * @brief 设置总帧数
 * @param frames 总帧数
 * @return true 设置成功 (无 Clip 超出范围)
 */
bool SetTotalFrame(int frames);

/**
 * @brief 设置播放帧
 * @param frame 目标帧号
 * @return true 设置成功
 * 
 * 实现：Stop → Play → 逐帧推进到目标帧 → 恢复原播放状态
 */
bool SetPlayingFrame(int frame);
```

### 查询

```cpp
/**
 * @brief 获取指定层 Clip 列表
 * @param layer 层级
 * @param clipList [out] Clip 列表 (按起始帧排序)
 */
void GetClipList(int layer, Nuclear::AbstractEffectClip_LIST& clipList);

/**
 * @brief 删除整层 Clip
 * @param layer 层级
 */
void DelLayer(int layer);

/**
 * @brief 是否有独立音频
 * @return true 有独立音频 Clip
 */
bool HasIndependentSound() const;
```

### 更新/保存

```cpp
/**
 * @brief 更新特效
 * @param tickTime 时间增量
 * @return true 更新成功
 * 
 * 播放态：调用 GEffect::Update
 * 非播放态：手动更新各 Clip 位置/缩放/旋转/颜色
 */
virtual bool Update(DWORD tickTime);

/**
 * @brief 保存特效到 XML 节点
 * @param root 根输出节点
 * @param soundcliproot 音频 Clip 输出节点 (可为 NULL)
 * @param flag 保存标志 (EFFECT_IO_NORMAL / EFFECT_IO_EDIT)
 * @return 0 成功
 */
int SaveEffect(XMLIO::CONode& root, XMLIO::CONode* soundcliproot, int flag);

/**
 * @brief 保存特效到文件
 * @param lpszPathName 文件路径
 * @param flag 保存标志
 * @return true 保存成功
 */
bool SaveEffect(LPCTSTR lpszPathName, int flag);

/**
 * @brief 加载特效 Clip (代理到 GEffect)
 * @param root 输入节点
 * @param flag 加载标志
 * @return 错误码
 */
int LoadEffectClips(XMLIO::CINode& root, int flag);
```

---

## 4. CToolsSebind

**头文件**: `ToolsSebind.h`  
**基类**: `Nuclear::Sebind`

### 构造/析构

```cpp
CToolsSebind(void);
virtual ~CToolsSebind(void);
```

### Clip 管理

```cpp
/**
 * @brief 为指定方向+动作添加 Clip
 * @param dir 方向枚举
 * @param action 动作名
 * @param frameCount 帧数
 * @return 新 Clip 指针，已存在返回 NULL
 */
Nuclear::EffectClip* AddClip(Nuclear::XPDIRECTION dir, const std::wstring& action, int frameCount);
```

### 特效管理

```cpp
/**
 * @brief 获取绑定特效
 * @return 特效指针
 */
Nuclear::Effect* GetEffect() const;

/**
 * @brief 设置绑定特效 (接管所有权，旧特效被 delete)
 * @param pEffect 特效指针
 * 
 * 如果 m_pEffect 已存在则先 delete
 */
void SetEffect(Nuclear::Effect* pEffect);
```

### 帧推进

```cpp
/**
 * @brief 帧推进 (内联方法)
 * @param pSprite Sprite 指针 (提供方向/动作/帧/位置)
 * @param tickTime 时间增量
 * @return true 特效在播放
 * 
 * 内部调用 Sebind::Tick(dir, actionName, floatFrame, pos, m_pEffect, tickTime)
 */
bool Tick(Sprite* pSprite, DWORD tickTime);
```

### 序列化

```cpp
/**
 * @brief 保存到 XML 节点
 * @param root 输出节点
 * @param flag 保存标志
 */
void Save(XMLIO::CONode& root, int flag = 0);

/**
 * @brief 保存到文件
 * @param lpszPathName 文件路径
 * @param flag 保存标志
 * @return true 保存成功
 */
bool Save(const wchar_t* lpszPathName, int flag = 0);

/**
 * @brief 从 XML 节点加载
 * @param root 输入节点
 * @param flag 加载标志
 * @return true 加载成功
 */
bool Load(XMLIO::CINode& root, int flag = 0);
```

### 清理

```cpp
void ClearAll();
void ReleaseAll();
```

---

## 5. Sprite

**头文件**: `Sprite.h`

### 构造

```cpp
/**
 * @brief 构造函数
 * @param pEB 引擎基类指针
 */
Sprite(Nuclear::EngineBase *pEB);
```

### 模型/动作

```cpp
/**
 * @brief 设置模型
 * @param modelname 模型名
 * @return true 模型改变且有效
 * 
 * 重新初始化组件/颜色数组，设置特效层标记
 * 类型为 1 的模型返回 false (不可用)
 */
bool SetModel(const std::wstring &modelname);

/**
 * @brief 设置动作
 * @param action_name 动作名 (空字符串清除动作)
 * 
 * 通过 SpriteManager 查找动作引用，重置帧和时间
 */
void SetAction(const std::wstring& action_name);

/**
 * @brief 设置组件
 * @param sc 组件索引
 * @param resource 资源名
 * @param color 颜色
 */
void SetComponent(int sc, const std::wstring& resource, Nuclear::XPCOLOR color);

/**
 * @brief 获取组件名
 * @param sc 组件索引
 * @return 组件资源名，无效索引返回空字符串
 */
std::wstring GetComponent(int sc);
```

### 帧控制

```cpp
/**
 * @brief 帧推进
 * @param deltaTime 时间增量 (毫秒)
 * 
 * 根据时间比例计算当前帧号和浮点帧号
 */
void Tick(DWORD deltaTime);

/**
 * @brief 设置当前帧
 * @param frame 帧号 (必须 >= 0)
 */
void SetFrame(int frame);
```

### 渲染

```cpp
/**
 * @brief 渲染 Sprite
 * 
 * 遍历组件，获取动画帧图片，处理特效层混合
 * 支持 8 方向镜像渲染
 */
void Render();
```

### 访问器

```cpp
const Nuclear::CPOINT& GetPosition() const;
Nuclear::XPDIRECTION GetDirection() const;
const std::wstring& GetModelName() const;
const std::wstring& GetActionName() const;
int GetTime();
int GetFrameCount();
float GetFloatFrame() const;
int GetCurFrame() const;
void SetPosition(Nuclear::CPOINT pos);
void SetDirection(Nuclear::XPDIRECTION dir);
```

---

## 6. CActionList

**头文件**: `Action.h`

### 构造

```cpp
/**
 * @brief 构造函数
 * @param pDoc 关联的文档指针
 */
CActionList(CEffectEditorDoc* pDoc);
```

### 操作

```cpp
/**
 * @brief 执行新操作
 * @param pOper 操作对象 (接管所有权)
 * 
 * 1. 截断 redo 历史并释放
 * 2. 入队
 * 3. 超出 MAX_LENGTH(50) 则淘汰最旧
 * 4. 标记文档已修改
 */
void DoOneAction(CAction* pOper);

/**
 * @brief 撤销一个操作
 * @return true 撤销成功
 */
bool UndoOneAction();

/**
 * @brief 重做一个操作
 * @return true 重做成功
 */
bool RedoOneAction();

/**
 * @brief 是否可撤销
 */
bool CanUndo();

/**
 * @brief 是否可重做
 */
bool CanRedo();

/**
 * @brief 清空所有历史
 */
void CleanAll();
```

---

## 7. CTimeBarCtrl

**头文件**: `TimeBarCtrl.h`

### 构造

```cpp
CTimeBarCtrl(CWnd* pParent = NULL);
```

### Clip 对象管理

```cpp
/**
 * @brief 添加 Clip 对象
 * @param obj Clip 描述结构
 * @return true 添加成功
 */
bool AddAnObj(const ClipObj& obj);

/**
 * @brief 修改 Clip 对象
 * @param obj 新的 Clip 描述 (按 objID 匹配)
 * @return true 修改成功
 */
bool ModifyAnObj(const ClipObj& obj);

/**
 * @brief 删除 Clip 对象
 * @param objId 对象 ID
 * @return true 删除成功
 */
bool DeleteAnObj(DWORD objId);

/**
 * @brief 清除所有对象
 * @return true 清除成功
 */
bool RemoveAll();
```

### 属性设置

```cpp
void SetMaxFrame(int maxFrame);
void SetLayerCount(int layerCount);
void SetLayerSeparatorPos(int layerSeparatorPos);
void SetPlayPos(float pos);
void SetNotify(TimeBarNotify* notify);
float GetPlayPos();
void ResetScrollBar();
```

---

## 8. bezier::CBezierControl

**头文件**: `BezierControl.h`

### 构造

```cpp
CBezierControl(CWnd* pParent = NULL);
```

### 线条管理

```cpp
/**
 * @brief 设置曲线条数
 * @param count 条数
 */
virtual void SetLineCount(size_t count);

/**
 * @brief 设置线条名称
 * @param id 线条 ID
 * @param name 名称
 */
virtual void SetLineName(LineID id, CString name);

/**
 * @brief 获取线条数
 */
virtual size_t GetLineCount() const;
```

### 控制点管理

```cpp
/**
 * @brief 添加控制点 (自动设置控制手柄与位置重合)
 * @param line 线条 ID
 * @param point 点坐标
 * @return true 添加成功
 */
virtual bool AddPoint(LineID line, const FPoint& point);

/**
 * @brief 添加控制点 (完整切线点)
 * @param line 线条 ID
 * @param tp 切线点数据
 * @return true 添加成功
 */
virtual bool AddPoint(LineID line, const TangentPoint& tp);

/**
 * @brief 清除指定线控制点
 */
virtual void CleanPoints(LineID line);

/**
 * @brief 清除所有线控制点
 */
virtual void CleanAllLinePoints();

/**
 * @brief 修改起始点
 * @param line 线条 ID
 * @param y Y 坐标值
 * @param prevCtrlPt 前控制手柄坐标
 */
virtual void ModifyStartPoint(LineID line, float y, const FPoint &prevCtrlPt);

/**
 * @brief 修改结束点
 * @param line 线条 ID
 * @param y Y 坐标值
 * @param nextCtrlPt 后控制手柄坐标
 */
virtual void ModifyEndPoint(LineID line, float y, const FPoint &nextCtrlPt);
```

### 坐标范围

```cpp
virtual void SetMinX(float minX);
virtual void SetMaxX(float maxX);
virtual void SetMinY(float minY);
virtual void SetMaxY(float maxY);
virtual float GetMinX() const;
virtual float GetMaxX() const;
virtual float GetMinY() const;
virtual float GetMaxY() const;
```

### 采样

```cpp
/**
 * @brief 设置采样数
 * @param count 采样点数
 */
virtual void SetSampleCount(int count);

/**
 * @brief 获取采样数
 */
virtual int GetSampleCount() const;

/**
 * @brief 设置采样点数据
 * @param spc 采样点容器
 * @return true 设置成功
 */
virtual bool SetSamples(const SamplePointContanter &spc);

/**
 * @brief 获取采样点数据
 */
const SamplePointContanters& GetSamplePoints() const;

/**
 * @brief 获取切线点数据
 */
const TangentPointContanters& GetTangentPoints() const;
```

### 工作模式

```cpp
/**
 * @brief 设置工作模式
 * @param workMode WORK_MODE_CURVE 或 WORK_MODE_SAMPLEING
 */
virtual void SetWorkMode(WORK_MODE workMode);
```

### 通知

```cpp
void SetNotify(INotify *pNotify);
```

---

## 9. colorbarctrl::CColorBarCtrl

**头文件**: `ColorBarCtrl.h`

### 构造

```cpp
CColorBarCtrl(CWnd* pParent = NULL);
```

### 属性

```cpp
void SetMaxX(int maxX);
int GetMaxX() const;
void SetColors(const Colors &colors);
const Colors& GetColors() const;
void SetSilderHeight(int height);
int GetSilderHeight() const;
void SetSilderWidth(int width);
int GetSilderWidth() const;
```

---

## 10. 接口定义

### 10.1 INotify

```cpp
class INotify {
public:
    virtual void OnRender() {};
};
```

### 10.2 TimeBarNotify

```cpp
class TimeBarNotify {
public:
    virtual bool OnUnSelectedAllItem() { return true; }
    virtual bool OnDragingPlayFrame(int frame) { return true; }
    virtual bool OnDragingPlayPos(float pos) { return true; }
    virtual bool OnUnSelectedItem(DWORD objID) { return true; }
    virtual bool OnSelectedItem(DWORD objID) { return true; }
    virtual bool OnModifyMaxFrame(int nMaxFrame) { return true; }
    virtual bool OnModifySpare(int pos) { return true; }
    virtual bool OnModify(const ClipObj& obj) { return true; }
};
```

### 10.3 IToolsNotify

```cpp
class IToolsNotify {
public:
    virtual void OnAddClip() { }
    virtual void OnToolsControl(UINT nID) { }
};
```

### 10.4 bezier::INotify

```cpp
namespace bezier {
    class INotify {
    public:
        virtual void OnClick() {}
        virtual void OnSampleCount(int sampleCount) {}
        virtual void OnSamplesReady(bool bReady) {}
    };
}
```

### 10.5 Nuclear::IEffectClipControl

```cpp
// CEffectEditorView 实现
virtual bool GetRotationRadian(float& angle) const;
virtual bool GetScale(Nuclear::FPOINT& scale) const;
```

---

## 11. 全局类型定义

```cpp
// stdafx.h
enum eAnimationPlayType {
    APT_NORMAL,        // 普通播放
    APT_SPEC_NORMAL,   // 特殊单次播放
    APT_SPEC_LOOP      // 特殊循环播放
};

enum eEffectFileType {
    EFT_EFFECT,        // 独立特效文件
    EFT_SEBIND         // 绑定文件
};

// Action.h
typedef std::set<Nuclear::AbstractEffectClip*> EffectClipSet;
typedef std::map<int, Nuclear::FPOINT> DoubleKeyMap;
typedef std::map<int, float> SingleKeyMap;
typedef std::map<int, Nuclear::XPCOLOR> ColorKeyMap;

// 全局辅助函数
inline int FreqToSave(int f);    // f + 128
inline int FreqToShow(int f);    // f - 128
inline int Vol100to255(int v);   // 百分比转 0-255
inline int Vol255to100(int v);   // 0-255 转百分比
bool SelectFolder(CString &fullPath, CString &folderName, HWND hWnd, CString &title, UINT flag);
unsigned int ReverseColor(unsigned int color);
```
