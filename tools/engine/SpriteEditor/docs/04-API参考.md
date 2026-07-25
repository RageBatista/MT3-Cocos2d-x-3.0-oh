# SpriteEditor API 参考

> **目标**: 为维护和排障提供准确的当前接口摘要  
> **校对日期**: 2026-04-23

---

## 1. 类层次

```text
CWinApp
└─ CSpriteEditorApp

CFrameWnd
└─ CMainFrame

CDocument + Nuclear::EngineBase
└─ CSpriteEditorDoc

CView
└─ CSpriteEditorView

CFormView
├─ CAnimationOpView
├─ CEquipSelectView
└─ CActionControlView

ISpriteEditorCommand
├─ CompositeCommand
├─ PropertyChangeCommand<T>
├─ LambdaCommand
├─ ChangeAnimationCommand
├─ ToggleVisibilityCommand
├─ AddLayerCommand
└─ 其他具体命令
```

---

## 2. 应用与窗口类

### 2.1 CSpriteEditorApp

文件： [SpriteEditor.h](file:///e:/MT3/tools/engine/SpriteEditor/SpriteEditor.h) / [SpriteEditor.cpp](file:///e:/MT3/tools/engine/SpriteEditor/SpriteEditor.cpp)

关键职责：

- 应用初始化
- 命令行参数解析
- 帮助菜单对话框入口
- 关闭前保存检查

关键成员：

- `CString m_ExePath`
- `CSpriteEditorView* m_pView`
- `PackRegressionAutomationOptions m_packRegressionOptions`

关键方法：

- `InitInstance()`
- `ExitInstance()`
- `OnIdle(LONG)`
- `OnFrameClose()`
- `GetPackRegressionOptions()`

### 2.2 CMainFrame

文件： [MainFrm.h](file:///e:/MT3/tools/engine/SpriteEditor/MainFrm.h) / [MainFrm.cpp](file:///e:/MT3/tools/engine/SpriteEditor/MainFrm.cpp)

关键职责：

- splitter 布局创建
- 拖拽打开 `.ani`
- 布局持久化
- Ctrl+方向键路由到文档偏移调整

关键方法：

- `OnCreateClient()`
- `OnDropFiles()`
- `OnCommand()`
- `PreTranslateMessage()`
- `SaveLayoutPreferences()`
- `LoadLayoutPreferences()`

---

## 3. 文档核心类

### 3.1 CSpriteEditorDoc

文件： [SpriteEditorDoc.h](file:///e:/MT3/tools/engine/SpriteEditor/SpriteEditorDoc.h) / [SpriteEditorDoc.cpp](file:///e:/MT3/tools/engine/SpriteEditor/SpriteEditorDoc.cpp)

#### 主要接口分组

**文件与资源**

- `OnOpenDocument(LPCTSTR)`
- `OpenAnimationFile()`
- `OpenAnimationFile(const CString& url)`
- `Save(bool prompt, bool saveact, int saveequip)`
- `OnFileSave()`
- `ReleaseRuntimeResources()`

**播放控制**

- `PlayReset()`
- `PlayDir(int)`
- `PlayFrame(int)`
- `PlayRR()` / `PlayLR()`
- `PlayFirst()` / `PlayLast()` / `PlayPrev()` / `PlayNext()`

**模型/动作/装备**

- `ChangeModel(const std::wstring&)`
- `OpenAction(std::wstring)`
- `RenameAnimation(const std::wstring&)`
- `DeleteAnimation(const std::wstring&)`
- `ShowEquipment(int, bool)`
- `ReloadEquipment(int)`
- `SelectEquipment(int, std::wstring)`
- `DeleteEquipment(int)`
- `NewEquipment(int)`
- `ChangeEquipmentColor(int)`

**位置与显示**

- `AdjustBase(...)`
- `AdjustBorder(...)`
- `AdjustBaseCenter(int, int)`
- `AdjustOffset(int, int)`
- `SetBasePointDisplay(bool)`
- `SetBorderDisplay(bool)`
- `ToggleTrajectoryOverlay()`
- `ToggleDebugOverlay()`
- `AdjustTrajectoryControl(const CSize&)`
- `ResetTrajectoryControl()`

**导出与打包**

- `OnExport()`
- `OnExportPngSequence()`
- `OnExportPngSequenceHd2()`
- `OnExportPngSequenceHd4()`
- `OnPack()`
- `OnToolPack()`
- `PackByDir(...)`
- `PackFromIni(const std::wstring&, bool)`
- `RunPackRegressionSuite(...)`

**视图协同**

- `UpdateControlView(LPARAM)`
- `UpdatePlayStateView()`
- `OnViewportResized(int, int, int, int)`

**引擎桥接**

- `GetApp()`
- `GetTick() const`
- `GetViewport() const`
- `GetRenderer(HWND)`
- `GetTitleManager()`
- `GetAniManager()`
- `GetConfigManager()`
- `GetSpriteManager()`
- `GetFileIOManager()`
- `GetPathFinder()`

#### 关键数据结构

**sPlayState**

- 当前帧 `m_iCurFrame`
- 当前方向 `m_iCurDir`
- 自动播放 / 循环 / 单次播放标志
- 起始 tick

**ConfigBridgeTableInfo**

- `tableName`
- `relativeBinPath`
- `absoluteBinPath`
- `exists`
- `fileSize`

#### 脏状态与命令接口

- `SetDocumentDirty(DirtyBit)`
- `ClearDocumentDirty(DirtyBit)`
- `IsDocumentDirty(DirtyBit) const`
- `GetDirtyFlagsRaw() const`
- `CanUndo() const`
- `CanRedo() const`
- `Undo()`
- `Redo()`
- `GetUndoCount() const`
- `GetRedoCount() const`
- `ExecuteCommand(ISpriteEditorCommand*)`

---

## 4. 视图类接口

### 4.1 CSpriteEditorView

关键方法：

- `Render()`
- `RefreshViewportLayout()`
- `EnsureRuntimeReadyForAutomation()`
- `OnInitialUpdate()`
- `OnTimer(UINT_PTR)`
- `OnMouseWheel(...)`
- `OnLButtonDown/Up(...)`
- `OnMouseMove(...)`
- `OnKeyDown(...)`

关键私有方法：

- `EnsureRuntimeInitialized()`
- `InitializeRuntime(const CRect&)`
- `SyncRendererViewport(bool)`
- `TryBeginTrajectoryControlDrag(...)`
- `UpdateTrajectoryControlDrag(...)`
- `EndTrajectoryControlDrag()`

### 4.2 CAnimationOpView

关键方法：

- `OnInitialUpdate()`
- `OnUpdate(...)`
- `OnLbnSelchangeListBoxAnimation()`
- `OnBnClickedBtnOpenAnimation()`
- `OnBnClickedBtnNewAnimation()`
- `OnBnClickedBtnDeleteAnimation()`
- `OnBnClickedBtnRenameAnimation()`

### 4.3 CEquipSelectView

关键方法：

- `OnEquipLayerCheckChanged(UINT)`
- `OnEquipLayerNew(UINT)`
- `OnEquipLayerReload(UINT)`
- `OnEquipLayerDelete(UINT)`
- `OnEquipLayerColorChange(UINT)`
- `OnEquipLayerComboChanged(UINT)`
- `GetLayerIndexFromControlID(UINT) const`
- `ProcessEquipLayerAction(int, const char*)`

### 4.4 CActionControlView

关键方法：

- `Update()`
- `RelayoutControls()`
- `OnBnClickedBtnMoveUp()`
- `OnBnClickedBtnMoveDown()`
- `OnBnClickedBtnApplyAllDir()`
- `OnBnClickedBtnSetTime()`
- `OnBnClickedBtnApplyAll()`
- `OnBnClickedSettingBoundingBox()`
- `OnBnClickedSettingBase()`
- `OnBnClickedButtonResetScale()`

---

## 5. 算法与工具类

### 5.1 PngExporter

文件： [PngExporter.h](file:///e:/MT3/tools/engine/SpriteEditor/PngExporter.h) / [PngExporter.cpp](file:///e:/MT3/tools/engine/SpriteEditor/PngExporter.cpp)

核心结构：

- `PngExportOptions`
- `PngExportFrame`
- `PngExportResult`

主要接口：

- `PngExporter(Nuclear::Renderer*)`
- `ExportAni(const std::wstring&, const Nuclear::XAni&, const PngExportOptions&)`

### 5.2 SpritePackCoreService

文件： [SpritePackCoreService.h](file:///e:/MT3/tools/engine/SpriteEditor/SpritePackCoreService.h) / [SpritePackCoreService.cpp](file:///e:/MT3/tools/engine/SpriteEditor/SpritePackCoreService.cpp)

主要接口：

- `BuildAtlas(...)`
- `RectPacking(...)`
- `GetBigPicSize(...)`
- `PicArrange(...)`
- `WriteConvertedAni(...)`
- `GetLastBuildStats() const`

内部结构：

- `MaxRectSlot`
- `MaxRectsBin`

### 5.3 OldAniPack

用途：读取旧 `.ani` 包结构并为转包提供输入。

### 5.4 DirtyFlags

文件： [DirtyFlags.h](file:///e:/MT3/tools/engine/SpriteEditor/DirtyFlags.h)

主要内容：

- `enum class DirtyBit`
- `class DirtyFlags`
- `struct DisplayFlags`

### 5.5 CommandManager

文件： [CommandManager.h](file:///e:/MT3/tools/engine/SpriteEditor/CommandManager.h)

主要接口：

- `Execute()`
- `Undo()`
- `Redo()`
- `MarkSaved()`
- `IsModified() const`
- `SetChangeCallback(...)`

---

## 6. 重要约束

- `CSpriteEditorDoc` 是事实上的核心调度中心，新增功能通常应先判断是否放入文档层。
- `PngExporter` 与 `SpritePackCoreService` 是纯工具算法模块，适合保持低耦合。
- `EquipmentLayer.h/.cpp` 是抽象化方向，但当前主线仍不能假设所有装备逻辑都已迁移到该层。
- `CommandManager` 已接入部分 UI 编辑操作，但不能假设“所有编辑都可撤销”。
