# ImageEditor 技术文档索引

> 版本：1.0  
> 生成日期：2026-04-24  
> 基于源码静态分析自动生成

---

## 文档列表

| 序号 | 文档名称 | 内容概述 |
|------|----------|----------|
| 1 | [01-概览.md](01-概览.md) | 项目概览、功能定位、技术栈、文件清单 |
| 2 | [02-架构设计.md](02-架构设计.md) | 系统架构、MFC Document/View 模式、类继承关系、模块划分、依赖关系 |
| 3 | [03-模块功能说明.md](03-模块功能说明.md) | 各模块（Application / MainFrame / ChildFrame / Document / Views / Dialog）的详细功能描述 |
| 4 | [04-API参考.md](04-API参考.md) | 所有类、成员函数的完整 API 参考（含参数、返回值、功能说明） |
| 5 | [05-数据流向.md](05-数据流向.md) | 数据在各组件间的流转路径，包括文件加载、渲染、交互的数据流 |
| 6 | [06-关键算法.md](06-关键算法.md) | 菱形边框计算、遮挡多边形、橡皮筋线、缩放与滚动等关键算法逻辑 |

---

## 源文件索引

| 文件路径 | 类型 | 说明 |
|----------|------|------|
| [ImageEditor.h](../ImageEditor.h) | 头文件 | 应用程序类 `CImageEditorApp` 定义 |
| [ImageEditor.cpp](../ImageEditor.cpp) | 源文件 | 应用程序入口、初始化、消息循环 |
| [MainFrm.h](../MainFrm.h) | 头文件 | MDI 主框架 `CMainFrame` 定义 |
| [MainFrm.cpp](../MainFrm.cpp) | 源文件 | 主框架实现（工具栏、状态栏） |
| [ChildFrm.h](../ChildFrm.h) | 头文件 | MDI 子框架 `CChildFrame` 和分割窗口 `CViewExSplitWnd` 定义 |
| [ChildFrm.cpp](../ChildFrm.cpp) | 源文件 | 子框架与三视图分割布局实现 |
| [ImageEditorDoc.h](../ImageEditorDoc.h) | 头文件 | 文档类 `CImageEditorDoc` 定义 |
| [ImageEditorDoc.cpp](../ImageEditorDoc.cpp) | 源文件 | 文档序列化、文件打开/保存实现 |
| [ImageEditorView.h](../ImageEditorView.h) | 头文件 | 主渲染视图 `CImageEditorView` 定义 |
| [ImageEditorView.cpp](../ImageEditorView.cpp) | 源文件 | DirectX 渲染、鼠标交互、边框/遮挡编辑 |
| [ImageInfoView.h](../ImageInfoView.h) | 头文件 | 文件信息面板 `CImageInfoView` 定义 |
| [ImageInfoView.cpp](../ImageInfoView.cpp) | 源文件 | 文件列表、缩放控制、格式选择实现 |
| [ImageStatusView.h](../ImageStatusView.h) | 头文件 | 状态信息视图 `CImageStatusView` 定义 |
| [ImageStatusView.cpp](../ImageStatusView.cpp) | 源文件 | 图像元数据（尺寸、重心、边框）显示 |
| [DialogSetPlaySpeed.h](../DialogSetPlaySpeed.h) | 头文件 | 播放速度对话框 `CDialogSetPlaySpeed` 定义 |
| [DialogSetPlaySpeed.cpp](../DialogSetPlaySpeed.cpp) | 源文件 | FPS 设置对话框实现 |
| [resource.h](../resource.h) | 头文件 | 资源 ID 常量定义 |
| [stdafx.h](../stdafx.h) | 头文件 | 预编译头文件 |
| [stdafx.cpp](../stdafx.cpp) | 源文件 | 预编译头源文件 |
| [ImageEditor.rc](../ImageEditor.rc) | 资源文件 | 菜单、对话框、工具栏、图标、字符串表 |
| [ImageEditor.vcxproj](../ImageEditor.vcxproj) | 构建文件 | VS2013 v120 工程配置 |

---

## 约定

- 所有文档中的文件路径相对于 `tools/engine/ImageEditor/` 目录
- 代码引用格式为 [`符号名`](相对路径:行号)
- 类图和调用链使用文本形式表示
- 中文撰写，技术术语保留英文原文
