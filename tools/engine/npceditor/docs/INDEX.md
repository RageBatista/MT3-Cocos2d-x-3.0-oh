# NPC 编辑器（MazeAndNpcEditor）技术文档索引

> **版本**: 1.0.0  
> **更新日期**: 2026-04-25  
> **源码路径**: `tools/engine/npceditor/`  
> **内部名称**: MazeAndNpcEditor（SoundEditor）

---

## 文档列表

| 序号 | 文档 | 内容摘要 |
|------|------|----------|
| 01 | [架构设计](01-架构设计__Architecture-Design.md) | 系统概述、整体架构模式（MFC SDI + Nuclear 引擎嵌入）、进程/线程模型、模块划分、依赖关系、视图布局、编辑状态与工具状态枚举 |
| 02 | [模块功能说明](02-模块功能说明__Module-Description.md) | 各模块详尽功能说明：SoundApp、CMainDlg、CSoundEditorDoc、Sprite、CNpc、CRegionBuffer、数据结构、UI 面板模块的成员变量表、成员函数表与职责描述 |
| 03 | [数据流向](03-数据流向__Data-Flow.md) | 地图数据加载到显示的完整流程、数据持久化流程、用户交互数据流、核心函数调用链（加载/编辑/保存/渲染） |

---

## 约定

- 所有文档使用中文撰写，技术术语保留英文
- 文件编码：UTF-8 无 BOM
- 类名、函数名、变量名引用格式：`ClassName`（[`filename.h`](../filename.h:line)）
- 代码片段和调用链基于静态分析结果，与实际源码保持一致
