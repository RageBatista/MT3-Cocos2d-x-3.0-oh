# 04 - API 参考

[← 返回索引](INDEX.md)

---

## 1. CImageEditorApp

**头文件**: [`ImageEditor.h`](../ImageEditor.h)  
**源文件**: [`ImageEditor.cpp`](../ImageEditor.cpp)  
**基类**: `CWinApp`

### 1.1 构造/析构

#### `CImageEditorApp()`

- **位置**: [`ImageEditor.cpp:33`](../ImageEditor.cpp:33)
- **说明**: 构造函数，初始化 `m_strResPath` 为空字符串，`m_pFileIOManager` 为 NULL

### 1.2 虚函数重写

#### `BOOL InitInstance()`

- **位置**: [`ImageEditor.cpp:50`](../ImageEditor.cpp:50)
- **返回值**: `TRUE` 初始化成功；`FALSE` 失败
- **说明**: 应用程序初始化入口。执行以下步骤：
  1. 初始化公共控件 (`InitCommonControlsEx`)
  2. 初始化 OLE (`AfxOleInit`)
  3. 注册文档模板 (`CMultiDocTemplate`)
  4. 创建 MDI 主框架 (`CMainFrame`)
  5. 初始化 PFS 文件系统 (`CFileIOManager::Init`)
  6. 计算资源路径
  7. 处理命令行

#### `int ExitInstance()`

- **位置**: [`ImageEditor.cpp:189`](../ImageEditor.cpp:189)
- **返回值**: 基类返回值
- **说明**: 销毁 PFS 文件管理器，释放资源

#### `BOOL OnIdle(LONG lCount)`

- **位置**: [`ImageEditor.cpp:203`](../ImageEditor.cpp:203)
- **返回值**: 基类返回值
- **说明**: MFC 空闲处理。获取当前活动文档的 `CImageEditorView` 并调用 `Render()` 驱动渲染

### 1.3 消息处理

#### `void OnAppAbout()`

- **位置**: [`ImageEditor.cpp:179`](../ImageEditor.cpp:179)
- **命令 ID**: `ID_APP_ABOUT`
- **说明**: 显示"关于"对话框 (`CAboutDlg`)

### 1.4 公共方法

#### `CString GetResPath()`

- **位置**: [`ImageEditor.h:24`](../ImageEditor.h:24)
- **返回值**: 资源根目录路径
- **说明**: 内联函数，返回 `m_strResPath`

### 1.5 成员变量

| 变量 | 类型 | 访问 | 说明 |
|------|------|------|------|
| `m_pFileIOManager` | `Nuclear::CFileIOManager*` | public | PFS 文件系统管理器 |
| `m_strResPath` | `CString` | private | 资源根目录路径 |

---

## 2. CMainFrame

**头文件**: [`MainFrm.h`](../MainFrm.h)  
**源文件**: [`MainFrm.cpp`](../MainFrm.cpp)  
**基类**: `CMDIFrameWnd`

### 2.1 构造/析构

#### `CMainFrame()`

- **位置**: [`MainFrm.cpp:33`](../MainFrm.cpp:33)
- **说明**: 默认构造函数

### 2.2 虚函数重写

#### `BOOL PreCreateWindow(CREATESTRUCT& cs)`

- **位置**: [`MainFrm.cpp:71`](../MainFrm.cpp:71)
- **返回值**: `TRUE` 成功；`FALSE` 失败
- **说明**: 在窗口创建前修改窗口样式

### 2.3 消息处理

#### `int OnCreate(LPCREATESTRUCT lpCreateStruct)`

- **位置**: [`MainFrm.cpp:42`](../MainFrm.cpp:42)
- **参数**: `lpCreateStruct` — 创建参数
- **返回值**: 0 成功；-1 失败
- **说明**: 创建工具栏和状态栏，启用工具栏停靠

### 2.4 成员变量

| 变量 | 类型 | 访问 | 说明 |
|------|------|------|------|
| `m_wndStatusBar` | `CStatusBar` | protected | 状态栏 |
| `m_wndToolBar` | `CToolBar` | protected | 工具栏 |

---

## 3. CViewExSplitWnd

**头文件**: [`ChildFrm.h`](../ChildFrm.h:7)  
**源文件**: [`ChildFrm.cpp`](../ChildFrm.cpp)  
**基类**: `CSplitterWnd`

### 3.1 构造/析构

#### `CViewExSplitWnd()`

- **位置**: [`ChildFrm.cpp:17`](../ChildFrm.cpp:17)

#### `~CViewExSplitWnd()`

- **位置**: [`ChildFrm.cpp:21`](../ChildFrm.cpp:21)

### 3.2 公共方法

#### `CWnd* GetActivePane(int* pRow, int* pCol)`

- **位置**: [`ChildFrm.cpp:25`](../ChildFrm.cpp:25)
- **参数**: `pRow` — 输出行号（可选）；`pCol` — 输出列号（可选）
- **返回值**: 活动视图窗口指针
- **说明**: 重写基类方法。从父框架获取活动视图，而非在分割窗口内查找

---

## 4. CChildFrame

**头文件**: [`ChildFrm.h`](../ChildFrm.h:18)  
**源文件**: [`ChildFrm.cpp`](../ChildFrm.cpp)  
**基类**: `CMDIChildWnd`

### 4.1 构造/析构

#### `CChildFrame()`

- **位置**: [`ChildFrm.cpp:53`](../ChildFrm.cpp:53)
- **说明**: protected 构造函数，由 `DECLARE_DYNCREATE` 宏支持动态创建

### 4.2 虚函数重写

#### `BOOL OnCreateClient(LPCREATESTRUCT lpcs, CCreateContext* pContext)`

- **位置**: [`ChildFrm.cpp:63](../ChildFrm.cpp:63)
- **参数**: `lpcs` — 创建结构；`pContext` — 创建上下文
- **返回值**: `TRUE` 成功；`FALSE` 失败
- **说明**: 创建嵌套分割窗口布局。外层水平分割（信息面板 | 渲染区），内层垂直分割（渲染视图 | 状态视图）

#### `BOOL PreCreateWindow(CREATESTRUCT& cs)`

- **位置**: [`ChildFrm.cpp:113](../ChildFrm.cpp:113)
- **返回值**: `TRUE` 成功；`FALSE` 失败
- **说明**: 设置子框架窗口样式（可调整大小、最小化/最大化、默认最大化）

### 4.3 消息处理

#### `void OnClose()`

- **位置**: [`ChildFrm.cpp:126](../ChildFrm.cpp:126)
- **说明**: 调用基类 `CMDIChildWnd::OnClose()` 关闭子框架

### 4.4 成员变量

| 变量 | 类型 | 访问 | 说明 |
|------|------|------|------|
| `m_wndSplitter` | `CViewExSplitWnd` | protected | 主分割器（1×2） |
| `m_wndSplitter2` | `CViewExSplitWnd` | protected | 嵌套分割器（2×1） |

---

## 5. CImageEditorDoc

**头文件**: [`ImageEditorDoc.h`](../ImageEditorDoc.h)  
**源文件**: [`ImageEditorDoc.cpp`](../ImageEditorDoc.cpp)  
**基类**: `CDocument`

### 5.1 公共方法

#### `CImageEditorView* GetImageEditorView()`

- **位置**: [`ImageEditorDoc.cpp:46`](../ImageEditorDoc.cpp:46)
- **返回值**: 渲染视图指针；失败返回 NULL 并输出警告日志
- **说明**: 遍历文档关联的所有视图，`dynamic_cast` 查找 `CImageEditorView`

#### `CImageInfoView* GetImageInfoView()`

- **位置**: [`ImageEditorDoc.cpp:60`](../ImageEditorDoc.cpp:60)
- **返回值**: 信息面板视图指针；失败返回 NULL

#### `CImageStatusView* GetImageStatusView()`

- **位置**: [`ImageEditorDoc.cpp:74`](../ImageEditorDoc.cpp:74)
- **返回值**: 状态视图指针；失败返回 NULL

#### `PImg& GetImgObject()`

- **位置**: [`ImageEditorDoc.h:47`](../ImageEditorDoc.h:47)
- **返回值**: 图像集数据对象的引用
- **说明**: 内联函数

#### `bool IsPicInit() const`

- **位置**: [`ImageEditorDoc.h:48`](../ImageEditorDoc.h:48)
- **返回值**: 图片是否已初始化加载到渲染器

#### `void SetPicInit(bool f)`

- **位置**: [`ImageEditorDoc.h:49`](../ImageEditorDoc.h:49)
- **参数**: `f` — 是否已初始化

#### `DWORD GetBackGroundColor()`

- **位置**: [`ImageEditorDoc.h:50`](../ImageEditorDoc.h:50)
- **返回值**: 背景色 (ARGB 格式)

### 5.2 虚函数重写

#### `BOOL OnNewDocument()`

- **位置**: [`ImageEditorDoc.cpp:88`](../ImageEditorDoc.cpp:88)
- **返回值**: `TRUE` 成功

#### `BOOL OnOpenDocument(LPCTSTR lpszPathName)`

- **位置**: [`ImageEditorDoc.cpp:152`](../ImageEditorDoc.cpp:152)
- **参数**: `lpszPathName` — 文件路径
- **返回值**: `TRUE` 成功；`FALSE` 失败
- **说明**: 打开 .set 文件，加载 PImg 数据，初始化视图和边框

#### `BOOL OnSaveDocument(LPCTSTR lpszPathName)`

- **位置**: [`ImageEditorDoc.cpp:130`](../ImageEditorDoc.cpp:130)
- **参数**: `lpszPathName` — 保存路径
- **返回值**: `TRUE` 成功；`FALSE` 失败
- **说明**: 将 PImg 数据序列化到文件

#### `void SetTitle(LPCTSTR lpszTitle)`

- **位置**: [`ImageEditorDoc.cpp:227`](../ImageEditorDoc.cpp:227)
- **说明**: 设置文档标题为文件路径

#### `void OnCloseDocument()`

- **位置**: [`ImageEditorDoc.cpp:256`](../ImageEditorDoc.cpp:256)
- **说明**: 调用基类关闭文档

### 5.3 消息处理

#### `void OnFileSave()`

- **位置**: [`ImageEditorDoc.cpp:191`](../ImageEditorDoc.cpp:191)
- **命令 ID**: `ID_FILE_SAVE`
- **说明**: 调用 `OnSaveDocument(m_strImgFilePath)`

#### `void OnFileSaveAs()`

- **位置**: [`ImageEditorDoc.cpp:196`](../ImageEditorDoc.cpp:196)
- **命令 ID**: `ID_FILE_SAVE_AS`
- **说明**: 弹出文件对话框选择保存路径

#### `void OnFileOpen()`

- **位置**: [`ImageEditorDoc.cpp:212`](../ImageEditorDoc.cpp:212)
- **命令 ID**: `ID_FILE_OPEN`
- **说明**: 弹出文件对话框选择 .set 文件打开

#### `void OnFileClose()`

- **位置**: [`ImageEditorDoc.cpp:234`](../ImageEditorDoc.cpp:234)
- **命令 ID**: `ID_FILE_CLOSE`
- **说明**: 如果文档已修改，提示用户保存后关闭

#### `void OnSetbkcolor()`

- **位置**: [`ImageEditorDoc.cpp:263`](../ImageEditorDoc.cpp:263)
- **命令 ID**: `ID_SETBKCOLOR`
- **说明**: 弹出颜色对话框设置背景色

#### `void OnUpdateFileSave(CCmdUI *pCmdUI)`

- **位置**: [`ImageEditorDoc.cpp:274`](../ImageEditorDoc.cpp:274)
- **说明**: 根据文档修改状态启用/禁用保存按钮

### 5.4 成员变量

| 变量 | 类型 | 访问 | 说明 |
|------|------|------|------|
| `m_imgObject` | `PImg` | private | 图像集数据 |
| `m_bPicInit` | `bool` | private | 图片是否已加载到渲染器 |
| `m_strImgFilePath` | `CString` | private | 当前文件路径 |
| `m_dwBKcolor` | `DWORD` | private | 背景色 (ARGB) |

---

## 6. CImageEditorView

**头文件**: [`ImageEditorView.h`](../ImageEditorView.h)  
**源文件**: [`ImageEditorView.cpp`](../ImageEditorView.cpp)  
**基类**: `CView`, `Nuclear::EngineBase`

### 6.1 公共方法

#### `Renderer* GetDX9Render()`

- **位置**: [`ImageEditorView.h:136`](../ImageEditorView.h:136)
- **返回值**: D3D 渲染器指针

#### `void SetViewSize(int iViewWidth, int iViewHeight)`

- **位置**: [`ImageEditorView.cpp:1082`](../ImageEditorView.cpp:1082)
- **参数**: `iViewWidth` — 视图宽度；`iViewHeight` — 视图高度
- **说明**: 设置视图尺寸并重置滚动位置，记录初始尺寸到 `m_nViewWidth0/m_nViewHeight0`

#### `void ReSetViewSize()`

- **位置**: [`ImageEditorView.cpp:1096`](../ImageEditorView.cpp:1096)
- **说明**: 恢复视图尺寸为初始值

#### `void SetViewSize0()`

- **位置**: [`ImageEditorView.cpp:1107`](../ImageEditorView.cpp:1107)
- **说明**: 将视图尺寸设为 0（禁用滚动）

#### `void InitBorderCentPos()`

- **位置**: [`ImageEditorView.cpp:148`](../ImageEditorView.cpp:148)
- **说明**: 从 PImg 数据初始化边框中心点和顶点位置，以及遮挡多边形缓存

#### `void SetMaskRctFlag(BOOL bSetMaskRct)`

- **位置**: [`ImageEditorView.cpp:1228`](../ImageEditorView.cpp:1228)
- **参数**: `bSetMaskRct` — 是否进入设置遮挡模式
- **说明**: 设置遮挡模式标志，并调用 `SetFocus()` 确保键盘输入

#### `void SetAdjustMaskRctFlag(BOOL bAdjustMaskRct)`

- **位置**: [`ImageEditorView.h:145`](../ImageEditorView.h:145)
- **参数**: `bAdjustMaskRct` — 是否进入调整遮挡模式

#### `void SetZoomRate(float fZoomRate)`

- **位置**: [`ImageEditorView.h:146`](../ImageEditorView.h:146)
- **参数**: `fZoomRate` — 缩放比例

#### `void Render()`

- **位置**: [`ImageEditorView.cpp:190`](../ImageEditorView.cpp:190)
- **说明**: 主渲染函数。创建渲染器（首次）、开始渲染场景、调用 `DrawPic()`、结束渲染场景

### 6.2 私有方法

#### `void DrawPic()`

- **位置**: [`ImageEditorView.cpp:291`](../ImageEditorView.cpp:291)
- **说明**: 绘制图像子图、重心标记、边框和遮挡多边形

#### `void InvertLine(CDC* pDC, CPoint ptFrom, CPoint ptTo)`

- **位置**: [`ImageEditorView.cpp:842`](../ImageEditorView.cpp:842)
- **参数**: `pDC` — 设备上下文；`ptFrom` — 起点；`ptTo` — 终点
- **说明**: 使用 R2_NOT 异或模式绘制橡皮筋线

#### `void ComputerImgFilePos(const CPoint& initialPoint, const CPoint& point)`

- **位置**: [`ImageEditorView.cpp:857`](../ImageEditorView.cpp:857)
- **参数**: `initialPoint` — 拖拽起始点；`point` — 当前鼠标点
- **说明**: 根据两点计算菱形边框四个顶点坐标（32° 俯视角投影）

#### `void SetImgFilePos(PImg& ImgFile)`

- **位置**: [`ImageEditorView.cpp:882`](../ImageEditorView.cpp:882)
- **参数**: `ImgFile` — 图像数据引用
- **说明**: 将计算后的边框坐标写入 PImg 数据，并确定左/下/右/上四个方向顶点

#### `float Computer2PointDis(CPoint pt1, CPoint pt2)`

- **位置**: [`ImageEditorView.cpp:850`](../ImageEditorView.cpp:850)
- **参数**: `pt1`, `pt2` — 两个点
- **返回值**: 欧几里得距离
- **说明**: 计算两点间距离

#### `CPoint ZoomPoint(CPoint pt, float fZoomRate)`

- **位置**: [`ImageEditorView.cpp:550`](../ImageEditorView.cpp:550)
- **参数**: `pt` — 原始点；`fZoomRate` — 缩放比例
- **返回值**: 缩放后的点
- **说明**: 将点坐标乘以缩放比例

### 6.3 EngineBase 虚函数实现

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `GetFileIOManager()` | `theApp.m_pFileIOManager` | 全局 PFS 管理器 |
| `GetSpriteManager()` | `m_pSprMan` | 视图持有的精灵管理器 |
| `GetConfigManager()` | `m_pConfigMan` | 视图持有的配置管理器 |
| `GetAniManager()` | `m_pAniMan` | 视图持有的动画管理器 |
| `GetEffectManager()` | `NULL` | 未使用 |
| `GetRenderer()` | `m_pRenderer` | D3D 渲染器 |
| `GetViewport()` | 客户区矩形 | 当前视口 |
| `GetTick()` | `GetMilliSeconds()` | 当前毫秒时间 |
| `GetApp()` | `NULL` | 未使用 |

### 6.4 消息处理函数

#### `void OnSize(UINT nType, int cx, int cy)`

- **位置**: [`ImageEditorView.cpp:940`](../ImageEditorView.cpp:940)
- **说明**: 窗口大小改变时更新渲染器源矩形和滚动条范围

#### `void OnSizing(UINT fwSide, LPRECT pRect)`

- **位置**: [`ImageEditorView.cpp:985`](../ImageEditorView.cpp:985)
- **说明**: 窗口正在调整大小时更新渲染器源矩形

#### `void OnLButtonDown(UINT nFlags, CPoint point)`

- **位置**: [`ImageEditorView.cpp:432`](../ImageEditorView.cpp:432)
- **说明**: 左键按下。根据当前模式执行：添加遮挡点/选中遮挡点/开始拖拽边框/记录起始点

#### `void OnMouseMove(UINT nFlags, CPoint point)`

- **位置**: [`ImageEditorView.cpp:557`](../ImageEditorView.cpp:557)
- **说明**: 鼠标移动。更新光标形状；拖拽时绘制橡皮筋线或移动遮挡点/边框顶点

#### `void OnLButtonUp(UINT nFlags, CPoint point)`

- **位置**: [`ImageEditorView.cpp:765`](../ImageEditorView.cpp:765)
- **说明**: 左键释放。提交编辑结果到 PImg 数据，调用 `UpdateAllViews()` 刷新

#### `void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)`

- **位置**: [`ImageEditorView.cpp:999`](../ImageEditorView.cpp:999)
- **说明**: 水平滚动处理

#### `void OnVScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar)`

- **位置**: [`ImageEditorView.cpp:1040`](../ImageEditorView.cpp:1040)
- **说明**: 垂直滚动处理

#### `void OnRButtonDown(UINT nFlags, CPoint point)`

- **位置**: [`ImageEditorView.cpp:1125`](../ImageEditorView.cpp:1125)
- **说明**: 右键按下。在调整遮挡模式下，选中遮挡点后弹出右键菜单

#### `void OnDelmask()`

- **位置**: [`ImageEditorView.cpp:1161`](../ImageEditorView.cpp:1161)
- **命令 ID**: `ID_DELMASK`
- **说明**: 删除当前选中的遮挡点

#### `void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags)`

- **位置**: [`ImageEditorView.cpp:1177`](../ImageEditorView.cpp:1177)
- **说明**: 方向键按下时激活窗口

#### `void OnTimer(UINT_PTR nIDEvent)`

- **位置**: [`ImageEditorView.cpp:1317`](../ImageEditorView.cpp:1317)
- **说明**: 定时器事件（30ms 间隔），调用 `Render()`

#### `void OnInitialUpdate()`

- **位置**: [`ImageEditorView.cpp:1219`](../ImageEditorView.cpp:1219)
- **说明**: 视图首次更新时启动 30ms 定时器

---

## 7. CImageInfoView

**头文件**: [`ImageInfoView.h`](../ImageInfoView.h)  
**源文件**: [`ImageInfoView.cpp`](../ImageInfoView.cpp)  
**基类**: `CFormView`

### 7.1 公共方法

#### `float GetCurrentZoomRate()`

- **位置**: [`ImageInfoView.cpp:105`](../ImageInfoView.cpp:105)
- **返回值**: 当前缩放比例（1.0 = 100%）

#### `CString GetImgFileName()`

- **位置**: [`ImageInfoView.h:116](../ImageInfoView.h:116)
- **返回值**: 当前图像文件名（不含路径）

#### `void SetControlRange(int minFrame, int maxFrame)`

- **位置**: [`ImageInfoView.cpp:110`](../ImageInfoView.cpp:110)
- **参数**: `minFrame` — 最小值；`maxFrame` — 最大值
- **说明**: 设置缩放滑块范围

#### `void UpdateControlState(bool isEnable)`

- **位置**: [`ImageInfoView.cpp:117`](../ImageInfoView.cpp:117)
- **参数**: `isEnable` — 是否启用控件
- **说明**: 启用/禁用搜索按钮、版本转换按钮、导出信息按钮

### 7.2 私有方法（Stub 实现）

以下方法在当前版本中为空实现或返回默认值：

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `Refresh(LPCTSTR)` | 0 | 刷新文件列表 |
| `SetFileListInfo(WIN32_FIND_DATA*, int)` | FALSE | 设置文件列表项信息 |
| `ShowFileList()` | FALSE | 显示文件列表 |
| `AddItem(FileInfo)` | FALSE | 添加列表项 |
| `LoadPicFile(CString, BYTE**, DWORD&)` | FALSE | 加载图片文件 |
| `ConversionImgFile(vector<CString>&)` | void | 批量转换图像文件 |
| `ReadOldImgFile(CString&, OLDIMGFILE**)` | FALSE | 读取旧版本图像文件 |
| `FindSetFileInfo(CString&)` | void | 查找 set 文件信息 |

### 7.3 静态方法

#### `static int CALLBACK CompareFunc(LPARAM lParam1, LPARAM lParam2, LPARAM lParamSort)`

- **位置**: [`ImageInfoView.cpp:100`](../ImageInfoView.cpp:100)
- **返回值**: 0（当前未实现排序比较）
- **说明**: `CListCtrl` 排序回调函数

### 7.4 成员变量

| 变量 | 类型 | 访问 | 说明 |
|------|------|------|------|
| `m_texfmtmap` | `map<wstring, XPTEXTURE_FORMAT>` | public | 纹理格式名称映射 |
| `m_comboImgFileFormat` | `CComboBox` | public | 格式选择下拉框 |
| `m_ListCtrl` | `CListCtrl` | public | 文件列表控件 |
| `m_sliderZoomRate` | `CSliderCtrl` | private | 缩放滑块 |
| `m_fZoomRate` | `float` | private | 当前缩放比例 |
| `m_bSetMaskpt` | `BOOL` | private | 设置遮挡模式标志 |
| `m_bAdjustMaskpt` | `BOOL` | private | 调整遮挡模式标志 |
| `m_strFileName_old` | `CString` | private | 当前文件名 |
| `m_pRenderer` | `Renderer*` | private | 渲染器指针 |

---

## 8. CImageStatusView

**头文件**: [`ImageStatusView.h`](../ImageStatusView.h)  
**源文件**: [`ImageStatusView.cpp`](../ImageStatusView.cpp)  
**基类**: `CView`

### 8.1 虚函数重写

#### `void OnDraw(CDC* pDC)`

- **位置**: [`ImageStatusView.cpp:29`](../ImageStatusView.cpp:29)
- **参数**: `pDC` — 绘图设备上下文
- **说明**: 使用 GDI 绘制图像元数据信息（尺寸、格式、重心、边框顶点）

### 8.2 成员变量

| 变量 | 类型 | 访问 | 说明 |
|------|------|------|------|
| `m_fmtMap` | `map<XPTEXTURE_FORMAT, wstring>` | protected | 格式枚举到字符串的映射 |

---

## 9. CDialogSetPlaySpeed

**头文件**: [`DialogSetPlaySpeed.h`](../DialogSetPlaySpeed.h)  
**源文件**: [`DialogSetPlaySpeed.cpp`](../DialogSetPlaySpeed.cpp)  
**基类**: `CDialog`

### 9.1 公共方法

#### `CDialogSetPlaySpeed(CWnd* pParent)`

- **位置**: [`DialogSetPlaySpeed.cpp:13`](../DialogSetPlaySpeed.cpp:13)
- **参数**: `pParent` — 父窗口（默认 NULL）

#### `void SetFPS(int fps)`

- **位置**: [`DialogSetPlaySpeed.cpp:35`](../DialogSetPlaySpeed.cpp:35)
- **参数**: `fps` — 帧率值

#### `int GetFPS()`

- **位置**: [`DialogSetPlaySpeed.cpp:40`](../DialogSetPlaySpeed.cpp:40)
- **返回值**: 当前帧率值

### 9.2 成员变量

| 变量 | 类型 | 访问 | 说明 |
|------|------|------|------|
| `m_nFPS` | `int` | private | 帧率值（默认 5，范围 0~100） |
