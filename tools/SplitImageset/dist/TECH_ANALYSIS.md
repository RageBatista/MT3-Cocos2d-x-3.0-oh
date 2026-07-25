# SplitImageset 深度技术调研与功能分析

## 1. 工具定位

`tools/SplitImageset` 是 MT3 UI 离线处理链上的资源预处理工具，面向 CEGUI `imageset` 资源做 3/9 宫格拆分，核心目标是让运行时拉伸时减少失真。

原始版本以命令行方式运行，读取 `SplitConfig.xml` 后批量改写目标 `*.imageset`。

## 2. 原始实现结构（重构前）

原始代码集中在单文件 `SplitImageset.cpp`，职责混合：

- 程序入口（`_tmain`）
- 配置读取与 XML 解析（`SplitImagesets`）
- 单 frame 处理（`SplitImageset`）
- 文件删除与重写

主要流程：

1. 读取 `SplitConfig.xml`
2. 按 `<frame>` 节点遍历
3. 拼出 `../res/ui/imagesets/<imageset>`
4. 解析目标 imageset 中的 `Image` 节点
5. 按类型生成子块节点并替换原节点
6. 覆盖写回原文件

## 3. 输入输出契约

### 3.1 输入文件

- `SplitConfig.xml`：拆分任务列表
- `*.imageset`：被改写目标文件

`frame` 节点关键属性：

- `imageset`
- `image`
- `type`：`OnlyWidth` / `OnlyHeight` / `WidthAndHeight`
- 尺寸属性：
  - 宽向：`left_width` `center_width` `right_width`
  - 高向：`top_height` `center_height` `bottom_height`

### 3.2 输出文件

- 原 `imageset` 被覆盖
- （新 GUI 版可选）自动生成 `.bak` 备份

## 4. 依赖与构建约束

- 平台：Windows
- 工程：`SplitImageset.vcxproj`
- 工具链：`v120 (VS2013)` + Win32
- 资源侧依赖：CEGUI `imageset` XML 格式

重构后构建设置：

- `SubSystem=Windows`（GUI 入口）
- `UseOfMfc=Static`
- `RuntimeLibrary=MultiThreaded(/MT)`（Release）

## 5. 核心算法逻辑

### 5.1 目标节点匹配

在 `imageset` 的 `<Image ... />` 列表中，按 `Name == frame.image` 匹配目标节点。

### 5.2 三种拆分模式

- `OnlyWidth`：拆成 `_l/_c/_r`
- `OnlyHeight`：拆成 `_t/_c/_b`
- `WidthAndHeight`：拆成 9 块 `_lt/_lc/_lb/_ct/_cc/_cb/_rt/_rc/_rb`

### 5.3 坐标与尺寸生成

- 新节点坐标由原节点 `(XPos, YPos)` 加偏移计算
- 偏移与尺寸来自配置中的宽高参数
- 生成节点插入原节点位置，随后删除原节点

### 5.4 新版安全校验

在写回前新增校验：

- 所有必要尺寸必须大于 0
- 宽向分割和必须等于原图 `Width`
- 高向分割和必须等于原图 `Height`

避免产生越界或逻辑错误的切片定义。

## 6. 旧版风险点与修复

重构前主要风险：

- 命令行交互门槛高，易误用路径
- 错误反馈粒度不足
- 覆盖写无备份
- 原解析过程耦合度高，不利于定位异常

GUI 版改进：

- 图形化路径选择，降低误操作
- 内置日志面板，逐 frame 可见处理结果
- 备份开关（默认开启）
- 分割尺寸与命中结果显式报错

## 7. GUI 重构设计

入口文件：`SplitImagesetGuiApp.cpp`

界面功能：

- 配置文件选择
- imageset 根目录选择
- 备份开关
- 执行按钮
- 日志窗口
- 状态栏

交互流程：

1. 选择配置与目录
2. 点击“开始处理”
3. 依次处理所有 frame
4. 实时输出日志与最终汇总

## 8. 代码结构（重构后）

虽然仍是单编译单元，但内部已按职责分段：

- 路径/编码/文件 I/O 工具函数
- 配置解析（手工 tag 解析，兼容历史“无根节点配置”）(`ParseConfig`)
- imageset 解析（手工属性提取）(`LoadImageset`)
- 拆分与校验 (`ValidateDimensions` / `GenerateSplitImages` / `ApplySplit`)
- 执行编排 (`RunSplitProcess`)
- Win32 GUI (`MainWndProc` / `wWinMain`)

## 9. 打包与独立运行

建议交付目录：

- `SplitImageset.exe`
- `SplitConfig.xml`（模板）
- `README.md`
- `TECH_ANALYSIS.md`

该产物可直接在 Windows 上运行（无需依赖 VS IDE），用于资源团队离线处理。
