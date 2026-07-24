# CEGUI 集成指南

> **范围**：CEGUI 0.7.1 资源、Window、Lua/C++ 路径与事件集成。
> **构建职责**：本页不维护第二套构建命令；工具和客户端构建见 `docs/03-开发指南/`、`docs/06-工具链/`。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 新增/修改 UI 的最短路径

1. 确认需要的 Window Type 已在 Scheme/FalagardMapping 注册。
2. 确认 LookNFeel 中存在对应 `WidgetLook`。
3. 确认 Imageset/Font 声明与物理资源存在。
4. 在 `.layout` 中使用正确的 `Type`、`Name`、父子层级和属性。
5. Lua Dialog 的 `GetLayoutFileName()`、`getWindow()` 和事件名与 layout 一致。
6. 需要 C++ 桥接时，使用当前 `GameUIManager` / Dialog / tolua 入口，不新建旁路单例。
7. 验证加载、交互、数据刷新、销毁和重建。

## 2. Scheme

Scheme 负责聚合资源和注册 Falagard 窗口映射。当出现“Unknown object type”时，先查：

- Scheme 是否被加载。
- `FalagardMapping WindowType` 是否与 layout `Type` 完全一致。
- 目标 Window 工厂、WindowRenderer 和 `LookNFeel` 是否已注册。

## 3. LookNFeel

LookNFeel 定义 `WidgetLook`、ImagerySection、StateImagery、NamedArea、ChildWidget 和属性。修改时：

- 保持 WidgetLook 名和 FalagardMapping 引用一致。
- 引用 Image 时同时核对 Imageset 名和 region 名。
- 对 Dim/UDim 表达式保留精度和原有语义。
- 使用 LnFEditor 时仍以实际 XML 差异和客户端加载为最终验证。

## 4. Imageset 与 Font

Imageset 处理图像 region 和原始纹理；Font 处理字形、尺寸与缓存。修改后检查：

- 资源名、文件路径和 resource group。
- 图片 region 边界、透明边缘和 native resolution/auto scaling 属性。
- 字体文件、字号、字符集和缺字回退。
- Android/iOS 前后台后纹理/字形可恢复。

CEImagesetEditor 的构建见 [CEImagesetEditor 编译构建](../06-工具链/07-CEImagesetEditor编译构建.md)，使用和架构见 [CEImagesetEditor 技术手册](09-CEImagesetEditor技术手册.md)。

## 5. Layout 与子布局

- 入口 `.layout` 需保持根 Window 名和 Dialog 预期一致。
- 动态 `loadWindowLayout()` 的子 layout 必须逐个验证，只扫描入口 layout 不足以证明运行时闭环。
- name prefix 会改变实际 Window path，Lua/C++ 查找必须同步。
- 二进制 layout 由工具链生成，修改语义先回到 XML 真源。

## 6. Lua/C++ 事件

| 项目 | 检查 |
| --- | --- |
| 窗口查找 | 完整路径、name prefix、子布局加载时机。 |
| 事件订阅 | 事件名、handler 函数存在、参数类型、重复订阅。 |
| 销毁 | 解绑、Manager 引用、子窗口、计时器和协议 handler。 |
| 数据刷新 | Dialog 存活性、游戏状态、回包顺序和空值。 |

## 7. 静态验证

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\cegui-layout-integration\scripts\validate-cegui-resources.ps1 -Json
```

单布局可使用 `check-cegui-bindings.ps1 -Layout <layout> -Json`。静态检查通过后仍需冷启动和真实交互验证。

## 8. 错误定位顺序

1. 当前 `CEGUI_ct.log` 的首个错误。
2. Layout XML 和子布局。
3. Scheme/FalagardMapping。
4. LookNFeel/WidgetLook。
5. Imageset/Font 物理资源。
6. Lua/C++ Window path 与事件。
7. 只有前述闭环后，才进入 renderer/性能层。
