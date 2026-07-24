# BinLayoutConvert（CEGUI `.layout` 二进制化工具）

> 位置：`dependencies/BinLayoutConvert/`
>
> 用途：把 CEGUI 的布局文件（XML 形式的 `.layout`）转换为 BinLayout v1（二进制 `.layout`，文件头 `LBFM`），用于发布前的体积/加载性能优化与一定程度的结构封装（非密码学加密）。
>
> 最后更新：2026-01-13

---

## 0. 技术架构总览

### 0.1 系统架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BinLayoutConvert 工具集                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────┐       ┌─────────────────────────────────────────┐ │
│  │ BinLayoutConvert    │       │ BinLayoutStudio                         │ │
│  │ (CLI 批量转换)      │       │ (GUI + CLI 双向转换)                    │ │
│  ├─────────────────────┤       ├─────────────────────────────────────────┤ │
│  │ main.cpp            │       │ BinLayoutStudioWxMain.cpp (wxWidgets)   │ │
│  │ ↓                   │       │ BinLayoutStudioMain.cpp (Win32 API)     │ │
│  │ XMLToBin::convert() │       │ ↓                                       │ │
│  └──────────┬──────────┘       │ BinLayoutStudioBinCodec.cpp (核心解码)  │ │
│             │                  │ BinLayoutStudioXmlWriter.cpp (XML生成)  │ │
│             │                  └──────────────────┬──────────────────────┘ │
│             └──────────────────┬─────────────────┬┘                        │
│                                ↓                 ↓                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    CEGUI BinLayout 核心层                           │   │
│  │  (dependencies/cegui/CEGUI/src/BinLayout/)                          │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │  CEGUIXMLToBin.cpp          - XML 解析 + 二进制序列化               │   │
│  │  CEGUIBinLayoutFileSerializer.cpp - 文件头读写 + 版本分发           │   │
│  │  CEGUIStream.cpp            - 二进制流读写                          │   │
│  │  CEGUIPropertyIds.cpp       - 属性ID ↔ 名称映射                     │   │
│  │  v1/CEGUILayoutSerializer_v1.cpp   - v1 布局序列化                  │   │
│  │  v1/CEGUINodeSerializer_v1.cpp     - v1 节点序列化                  │   │
│  │  v1/CEGUIPropertySerializer_v1.cpp - v1 属性序列化                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 0.2 核心模块职责

| 模块 | 文件 | 职责 |
|------|------|------|
| **CLI 转换器** | `BinLayoutConvert/main.cpp` | 命令行批量 XML→BIN 转换 |
| **GUI 工具** | `BinLayoutStudio/BinLayoutStudioWxMain.cpp` | wxWidgets GUI + CLI 模式 |
| **二进制解码器** | `BinLayoutStudio/BinLayoutStudioBinCodec.cpp` | BIN → AST (XMLFileData) |
| **XML 生成器** | `BinLayoutStudio/BinLayoutStudioXmlWriter.cpp` | AST → XML 文本 |
| **属性类型表** | `BinLayoutStudio/BinLayoutStudioPropTypes_v1.inc` | propId → PayloadKind 映射 |

### 0.3 数据流图

```
XML → BIN (加密/封装):
┌────────────┐    ┌────────────────┐    ┌─────────────────┐    ┌────────────┐
│ XML 文件   │ → │ LJXMLParser    │ → │ XMLFileData AST │ → │ BIN 文件   │
│ (.layout)  │    │ 解析XML结构    │    │ 内存节点树      │    │ (LBFM v1)  │
└────────────┘    └────────────────┘    └─────────────────┘    └────────────┘

BIN → XML (解密/还原):
┌────────────┐    ┌────────────────┐    ┌─────────────────┐    ┌────────────┐
│ BIN 文件   │ → │ BinCodec       │ → │ XMLFileData AST │ → │ XML 文件   │
│ (LBFM v1)  │    │ 二进制解析     │    │ 内存节点树      │    │ (.layout)  │
└────────────┘    └────────────────┘    └─────────────────┘    └────────────┘
```

---

## 1. 现状说明（务必先读）

- 本目录中包含两类工具：
  - **BinLayoutConvert**（控制台）：XML → BinLayout（覆盖写回）。
  - **BinLayoutStudio**（GUI + 可选 CLI）：Bin ↔ XML（离线双向转换/还原）。
- 运行时"解密/反序列化"（BinLayout → `CEGUI::Window` 树）由 CEGUI 内部完成：`CEGUI::WindowManager::loadWindowLayoutFromFile` 会自动识别 `LBFM` 并走 BinLayout 解析路径。

更完整的机制分析见：
- `dependencies/BinLayoutConvert/00-BinLayoutConvert布局加密解密逻辑分析-BinLayoutConvert-Layout-Encrypt-Decrypt-Analysis.md`
- `dependencies/BinLayoutConvert/01-BinLayoutStudio离线双向转换工具方案-BinLayoutStudio-Design.md`

---

## 2. 构建要求（Windows）

### 2.1 工具链硬约束

- Visual Studio 2013（`v120`）
- Windows SDK 8.1（通常）

原因：该工具链接/依赖链与主工程（尤其是 `FireClient.lib`）一致，必须保持 ABI 兼容。

### 2.2 GUI 依赖（wxWidgets-3.0.5）

- `BinLayoutStudio` 的 GUI 基于 `dependencies/wxWidgets-3.0.5`（静态库：`lib/vc_lib`）。
- 工程已配置好 include/lib 路径，无需额外安装。

### 2.3 MSBuild / PowerShell（命令行）示例

> 说明：在 PowerShell 里直接执行 `.bat` 不会把环境变量带回当前 shell，因此用 `cmd /c "call ... && msbuild ..."`。

构建 `BinLayoutConvert.exe`（XML → BinLayout 原地转换工具）：

```powershell
Set-Location e:\MT3
cmd /c "call \"%VS120COMNTOOLS%..\\..\\VC\\vcvarsall.bat\" x86 && msbuild .\\dependencies\\BinLayoutConvert\\BinLayoutConvert.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32 /m /nologo"
```

构建 `BinLayoutStudio.exe`（GUI/CLI 双向转换工具）：

```powershell
Set-Location e:\MT3
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Build-BinLayoutStudio-v120.ps1 -Configuration Release -Target Rebuild -FailOnWarnings
```

产物位置（默认 VS/MSBuild 规则）通常为（以 Release 为例）：
- `dependencies/BinLayoutConvert/Release/BinLayoutConvert.exe`（或以工程 `OutDir` 为准）
- `dependencies/BinLayoutConvert/BinLayoutStudio/Release/BinLayoutStudio.exe`

> 运行提示（重要）：两个工具均链接了客户端运行期依赖（多 DLL）。为避免直接运行时报 `0xC0000135`（缺 DLL），工程 PostBuild 会把 exe 复制到：
> - `client/resource/bin/<Configuration>/`
>
> 因此推荐在该目录下运行（或把同目录 DLL 加入 PATH）。

如需确认实际输出目录，请在 VS 中查看 `BinLayoutConvert.vcxproj` 的 `OutDir`/`TargetName`（当前工程未显式设置时使用默认值）。

---

## 3. 使用方法（XML → BinLayout）

入口：`dependencies/BinLayoutConvert/BinLayoutConvert/main.cpp`

### 3.1 单文件

> 建议在 `client/resource/bin/<Configuration>/` 下运行（依赖 DLL 更齐全），并尽量对“副本”操作，避免误覆盖源文件。

```powershell
Set-Location e:\MT3\client\resource\bin\release

Copy-Item -Force e:\MT3\client\resource\res\ui\layouts\vip.layout e:\MT3\docs\research\vip_for_convert.layout
.\BinLayoutConvert.exe e:\MT3\docs\research\vip_for_convert.layout
```

### 3.2 目录批处理（递归扫描 `*.layout`）

```powershell
Set-Location e:\MT3\client\resource\bin\release
.\BinLayoutConvert.exe e:\MT3\client\resource\res\ui\layouts\
```

### 3.3 重要注意事项

- 工具会 **原地覆盖写回**（`convert(src, src)`）；请务必先备份或在可回滚环境中运行。
- 若输入文件已经是 BinLayout（二进制布局，前 4 字节为 `LBFM`），转换逻辑会检测并跳过（见 `CEGUIXMLToBin.cpp`）。

---

## 3.1 BinLayoutStudio（离线双向转换/还原）

入口工程：
- VS/MSBuild：`dependencies/BinLayoutConvert/BinLayoutStudio/BinLayoutStudio.vcxproj`
- 推荐脚本：`tools/scripts/Build-BinLayoutStudio-v120.ps1`
- 源码：`dependencies/BinLayoutConvert/BinLayoutStudio/`

> 注意：`dependencies/BinLayoutConvert/BinLayoutConvert.sln` 当前只包含 `BinLayoutConvert`，不包含 `BinLayoutStudio`。构建 `BinLayoutStudio` 请直接使用独立 `.vcxproj` 或推荐脚本。

### GUI（推荐）

- 打开 `.layout`（自动识别 BIN/XML）
- 单文件工作台：
  - XML 与 BIN 现在都可以直接解析为树结构，而不再只是“XML 可导出 BIN”的提示态
  - 顶部统一操作区提供 `打开文件 / 重新加载 / 导出 XML / 导出 BIN / 目录工作台`
  - 中部增加文件、格式、节点统计、操作提示四张状态卡片，右侧属性面板支持按 Name/Value 搜索过滤
- 菜单 `转换`：
  - `导出 XML`（BIN → XML，离线还原，快捷键 `Ctrl+E`）
  - `导出 BIN`（XML → BIN / BIN 重编码，快捷键 `Ctrl+B`）
  - `打开目录转换工作区`（快捷键 `F7`）
- 目录转换工作区（2026-03-31 新增）：
  - 支持多层级目录扫描、`*.layout` 过滤、自动识别 XML/BIN
  - 支持镜像输出 / 打平输出、保留原名 / 自动追加 `_bin` / `_xml` 后缀
  - 支持规则变更后的实时预览、冲突提示、批量转换进度和日志落盘
- 常用增强：
  - 支持拖拽 `.layout` 文件到窗口打开
  - 菜单 `文件` → `最近打开`（持久化保存，默认配置文件：`%LOCALAPPDATA%\\BinLayoutStudio\\BinLayoutStudio.ini`）
  - 底部共享日志区统一记录带时间戳的单文件 / 目录批量操作
  - 菜单 `视图` → `导出日志...`（快捷键 `Ctrl+Shift+S`）

> 输出文件名策略：导出时 **不会自动改变输出文件名**（不再追加 `_xml` / `_bin`，也不会强制追加扩展名），以保存对话框选择为准。

> 说明：为方便运行时依赖，Release/Debug 构建后会把 `BinLayoutStudio.exe` 复制到 `client/resource/bin/<Configuration>/`。

### CLI（便于批处理）

在 `client/resource/bin/release/` 下运行（依赖 DLL 更齐全）：

> 提示：`BinLayoutStudio.exe` 为 Windows 子系统程序（GUI），在 PowerShell 直接运行时默认不会阻塞等待；批处理建议用 `Start-Process -Wait`。

```powershell
Set-Location e:\MT3\client\resource\bin\release

# Bin -> XML
Start-Process -FilePath .\BinLayoutStudio.exe -ArgumentList @('--bin2xml', 'e:\MT3\client\resource\bin\release\test.layout', 'e:\MT3\docs\research\test_decoded.layout') -Wait -PassThru

# XML -> Bin
Start-Process -FilePath .\BinLayoutStudio.exe -ArgumentList @('--xml2bin', 'e:\MT3\client\resource\res\ui\layouts\vip.layout', 'e:\MT3\docs\research\vip_bin.layout') -Wait -PassThru
```

---

## 4. 快速自检：判断 `.layout` 是 XML 还是 BinLayout

```powershell
$p = "e:\MT3\client\resource\res\ui\layouts\vip.layout"
$b = Get-Content -AsByteStream -TotalCount 4 -Path $p
($b | ForEach-Object { [char]$_ }) -join ''
```

输出：
- `LBFM` → BinLayout（二进制）
- `<?xm` / `\uFEFF<` → XML（可能带 BOM）

---

## 5. 关联源码入口（排查时最常用）

- XML → Bin：`dependencies/cegui/CEGUI/src/BinLayout/CEGUIXMLToBin.cpp`
- Bin 读取/分发：`dependencies/cegui/CEGUI/src/BinLayout/CEGUIBinLayoutFileSerializer.cpp`
- v1 结构：`dependencies/cegui/CEGUI/src/BinLayout/v1/`
- 加载入口（自动识别 XML/Bin）：`dependencies/cegui/CEGUI/src/CEGUIWindowManager.cpp`

---

## 6. BinLayout v1 二进制格式规范

### 6.1 文件头结构

```
偏移量    大小    内容              说明
────────────────────────────────────────────────────
0x00      4       "LBFM"           魔数 (Layout Binary File Magic)
0x04      4       int32            版本号 (当前为 1)
0x08      ...     NodeData         根节点数据（递归结构）
```

### 6.2 节点类型枚举 (NodeType)

```cpp
enum NodeType {
    NT_Window       = 0,  // 窗口节点（含子节点）
    NT_AutoWindow   = 1,  // 自动窗口（含子节点）
    NT_LayoutImport = 2,  // 布局导入（无子节点）
    NT_Event        = 3,  // 事件绑定（无子节点）
    NT_Property     = 4,  // 属性节点（无子节点，仅作为父节点的子项）
};
```

### 6.3 节点数据结构

**Window 节点 (NT_Window = 0):**
```
字段          类型              说明
────────────────────────────────────────────────────
nodeType      int32            = 0 (NT_Window)
type          String           窗口类型 (如 "TaharezLook/FrameWindow")
name          String           窗口名称 (如 "VIPPanel")
propCount     int32            属性数量
properties    Property[N]      属性列表
childCount    int32            子节点数量
children      NodeData[N]      子节点列表（递归）
```

**AutoWindow 节点 (NT_AutoWindow = 1):**
```
字段          类型              说明
────────────────────────────────────────────────────
nodeType      int32            = 1 (NT_AutoWindow)
nameSuffix    String           名称后缀 (如 "__auto_titlebar__")
propCount     int32            属性数量
properties    Property[N]      属性列表
childCount    int32            子节点数量
children      NodeData[N]      子节点列表（递归）
```

**LayoutImport 节点 (NT_LayoutImport = 2):**
```
字段          类型              说明
────────────────────────────────────────────────────
nodeType      int32            = 2 (NT_LayoutImport)
prefix        String           前缀
filename      String           导入的布局文件名
resourceGroup String           资源组名称
```

**Event 节点 (NT_Event = 3):**
```
字段          类型              说明
────────────────────────────────────────────────────
nodeType      int32            = 3 (NT_Event)
name          String           事件名称 (如 "Clicked")
function      String           处理函数名 (如 "OnVIPButtonClicked")
```

### 6.4 属性数据结构

```
字段          类型              说明
────────────────────────────────────────────────────
propId        int32            属性ID (见 CEGUIPropertyIds.h)
payload       varies           属性值（类型由 propId 决定）
```

### 6.5 基础类型编码

| 类型 | 编码方式 | 示例 |
|------|----------|------|
| **bool** | 1 字节 (0/1) | `true` → `0x01` |
| **int32** | 4 字节小端 | `123` → `7B 00 00 00` |
| **uint32** | 4 字节小端 | `0xFF` → `FF 00 00 00` |
| **float** | 4 字节 IEEE 754 | `1.0f` → `00 00 80 3F` |
| **int64** | 8 字节小端 | - |
| **String** | length(int32) + chars | `"ABC"` → `03 00 00 00 41 42 43` |

### 6.6 复合类型编码

| 类型 | 编码方式 |
|------|----------|
| **Size** | float(w) + float(h) |
| **Point** | float(x) + float(y) |
| **Vector3** | float(x) + float(y) + float(z) |
| **Rect** | float(left) + float(top) + float(right) + float(bottom) |
| **colour** | uint32 (ARGB) |
| **ColourRect** | colour(tl) + colour(tr) + colour(bl) + colour(br) |
| **UDim** | float(scale) + float(offset) |
| **UVector2** | UDim(x) + UDim(y) |
| **URect** | UDim(left) + UDim(top) + UDim(right) + UDim(bottom) |

---

## 7. 属性类型系统 (PayloadKind)

### 7.1 PayloadKind 枚举

BinLayoutStudio 使用 `PayloadKind` 枚举来确定每个属性的载荷类型：

```cpp
enum class PayloadKind {
    Unknown = 0,
    Bool,               // 布尔值
    Int,                // 32位整数
    UInt,               // 32位无符号整数
    Float,              // 32位浮点数
    Int64,              // 64位整数
    String,             // 字符串
    Size,               // 尺寸 (w, h)
    Point,              // 点 (x, y)
    Vector3,            // 三维向量 (x, y, z)
    Rect,               // 矩形 (l, t, r, b)
    Colour,             // 颜色 (ARGB)
    ColourRect,         // 四角颜色
    UDim,               // 统一维度 (scale, offset)
    UVector2,           // 统一二维向量
    URect,              // 统一矩形
    Range2Float,        // 浮点范围 (min, max)
    SortMode,           // 排序模式
    SortDirection,      // 排序方向
    SelectionMode,      // 选择模式
    SizeType,           // 尺寸类型
    TextInputMode,      // 文本输入模式
    TabPanePosition,    // 标签页位置
    HorzFormatting,     // 水平格式化
    VertFormatting,     // 垂直格式化
    VerticalAlignment,  // 垂直对齐
    HorizontalAlignment,// 水平对齐
    CreateEffectType,   // 创建效果类型
    CloseEffectType,    // 关闭效果类型
    ItemCellStyle,      // 单元格样式
    PropertyDefinition, // 属性定义 (name + value)
};
```

### 7.2 属性映射表 (propId → PayloadKind)

属性映射定义在 `BinLayoutStudioPropTypes_v1.inc` 文件中，共 **224 个属性**。

常用属性示例：

| 属性ID | 属性名 | PayloadKind | 说明 |
|--------|--------|-------------|------|
| PI_Alpha | Alpha | Float | 透明度 (0.0~1.0) |
| PI_Visible | Visible | Bool | 是否可见 |
| PI_Text | Text | String | 文本内容 |
| PI_UnifiedAreaRect | UnifiedAreaRect | URect | 统一区域矩形 |
| PI_UnifiedPosition | UnifiedPosition | UVector2 | 统一位置 |
| PI_UnifiedSize | UnifiedSize | UVector2 | 统一尺寸 |
| PI_Image | Image | String | 图像资源路径 |
| PI_Font | Font | String | 字体名称 |
| PI_TextColour | TextColour | Colour | 文本颜色 |
| PI_HorzFormatting | HorzFormatting | HorzFormatting | 水平格式化方式 |
| PI_VertFormatting | VertFormatting | VertFormatting | 垂直格式化方式 |

### 7.3 特殊属性处理

某些属性有特殊的编解码逻辑：

```cpp
// PI_LuaForDialog / PI_LuaUsed: 无载荷，仅有 propId
if (propId == PI_LuaForDialog || propId == PI_LuaUsed) {
    outName = PropertyIdUtil::getPropNameById(propId);
    outValue = "True";
    return true;
}

// PI_PropertyDefinition: 两个字符串 (name + value)
if (kind == PayloadKind::PropertyDefinition) {
    String name, value;
    stream >> name >> value;
    outName = name;
    outValue = value;
    return true;
}
```

---

## 8. 核心代码逻辑分析

### 8.1 XML → BIN 转换流程

**入口**: `BinLayoutConvert/main.cpp`

```cpp
// 1. 注册 v1 序列化器
CEGUI::BinLayout::g_RegSerializers_v1();

// 2. 创建转换器
CEGUI::BinLayout::XMLToBin xmlToBin;

// 3. 执行转换（原地覆盖）
xmlToBin.convert(srcFilename, srcFilename);
```

**内部流程** (`CEGUIXMLToBin.cpp`):
1. 检测文件是否已是 BIN 格式（读取前 4 字节）
2. 如果是 XML，使用 `LJXMLParser` 解析为 `XMLFileData` AST
3. 调用 `BinLayoutFileSerializer::write()` 序列化为二进制

### 8.2 BIN → XML 转换流程

**入口**: `BinLayoutStudio/BinLayoutStudioBinCodec.cpp`

```cpp
bool ConvertBinToXmlFile(const char* srcBinPath, const char* dstXmlPath, std::string& outError) {
    // 1. 加载 BIN 到 AST
    XMLFileData::NodeData* root = NULL;
    if (!LoadBinLayoutToXmlData(srcBinPath, &root, outError)) {
        return false;
    }

    // 2. AST 转 XML 字符串
    std::string xml;
    if (!BuildLayoutXml(root, xml, outError)) {
        delete root;
        return false;
    }

    // 3. 写入文件
    FILE* fp = fopen(dstXmlPath, "wb");
    fwrite(xml.data(), 1, xml.size(), fp);
    fclose(fp);

    delete root;
    return true;
}
```

### 8.3 二进制解码核心逻辑

**递归节点读取** (`readNode` 函数):

```cpp
static bool readNode(Stream& stream, NodeData*& outNode, std::string& outError) {
    int nodeTypeInt = -1;
    stream >> nodeTypeInt;

    switch (static_cast<NodeType>(nodeTypeInt)) {
    case NT_Window: {
        WindowData* w = new WindowData();
        stream >> w->mType >> w->mName;

        // 读取属性
        readProperties(stream, w, outError);

        // 递归读取子节点
        int childCount = 0;
        stream >> childCount;
        for (int i = 0; i < childCount; ++i) {
            NodeData* child = NULL;
            readNode(stream, child, outError);
            w->addChild(child);
        }

        outNode = w;
        return true;
    }
    // ... 其他节点类型处理
    }
}
```

**属性载荷解码** (`decodePropertyPayload` 函数):

```cpp
static bool decodePropertyPayload(Stream& stream, int propId,
    String& outName, String& outValue, std::string& outError) {

    // 查找属性类型
    PayloadKind kind = g_kindByPropId[propId];
    outName = PropertyIdUtil::getPropNameById(propId);

    switch (kind) {
    case PayloadKind::Bool: {
        bool v = false;
        stream >> v;
        outValue = PropertyHelper::boolToString(v);
        return true;
    }
    case PayloadKind::Float: {
        float v = 0.0f;
        stream >> v;
        outValue = PropertyHelper::floatToString(v);
        return true;
    }
    case PayloadKind::URect: {
        URect v;
        stream >> v;
        outValue = PropertyHelper::urectToString(v);
        return true;
    }
    // ... 其他类型处理
    }
}
```

### 8.4 XML 生成逻辑

**递归节点写入** (`BinLayoutStudioXmlWriter.cpp`):

```cpp
static void writeNodeXml(std::ostringstream& oss, const NodeData* node, int indent) {
    switch (node->getType()) {
    case NT_Window: {
        const WindowData* w = static_cast<const WindowData*>(node);

        // 写入开标签
        oss << makeIndent(indent) << "<Window Type=\"" << escapeXml(w->mType)
            << "\" Name=\"" << escapeXml(w->mName) << "\"";

        // 属性和子节点
        if (w->getChildCount() == 0) {
            oss << " />\n";
        } else {
            oss << ">\n";

            // 写入 Property 子节点
            for (int i = 0; i < w->getChildCount(); ++i) {
                writeNodeXml(oss, w->getChild(i), indent + 1);
            }

            oss << makeIndent(indent) << "</Window>\n";
        }
        break;
    }
    case NT_Property: {
        const PropertyData* p = static_cast<const PropertyData*>(node);
        oss << makeIndent(indent) << "<Property Name=\"" << escapeXml(p->mName)
            << "\" Value=\"" << escapeXml(p->mValue) << "\" />\n";
        break;
    }
    // ... 其他节点类型
    }
}
```

---

## 9. 扩展与维护指南

### 9.1 添加新属性支持

1. **更新属性ID** (`CEGUIPropertyIds.h`):
   ```cpp
   enum PropertyId {
       // ...
       PI_NewProperty = 225,  // 新属性ID
       PI_COUNT
   };
   ```

2. **添加名称映射** (`CEGUIPropertyIds.cpp`):
   ```cpp
   case PI_NewProperty: return "NewProperty";
   ```

3. **添加载荷类型** (`BinLayoutStudioPropTypes_v1.inc`):
   ```cpp
   { CEGUI::BinLayout::PI_NewProperty, PayloadKind::String },
   ```

4. **实现序列化** (`v1/CEGUIPropertySerializer_v1.cpp`):
   ```cpp
   case PI_NewProperty:
       stream << window->getProperty("NewProperty");
       break;
   ```

### 9.2 调试技巧

**启用详细日志**:
```cpp
// BinLayoutStudioBinCodec.cpp
#define BINLAYOUT_DEBUG 1
#if BINLAYOUT_DEBUG
    logf("Decoding propId=%d, kind=%d", propId, (int)kind);
#endif
```

**十六进制查看 BIN 文件**:
```powershell
Format-Hex -Path "test.layout" -Count 64
```

### 9.3 常见问题排查

| 错误信息 | 可能原因 | 解决方案 |
|----------|----------|----------|
| "not a BinLayout file" | 魔数不匹配 | 检查文件是否被截断或损坏 |
| "unsupported version" | 版本不兼容 | 使用对应版本的工具 |
| "unknown payload kind" | 未知属性ID | 更新 PropTypes_v1.inc |
| "conversion failed" | XML 解析失败 | 检查 XML 格式是否正确 |
