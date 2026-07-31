# CEGUI 0.7.1 至 0.7.9 版本演进与差异分析报告

> **文档状态**：经源码与 MT3 工程实物核对后的修订版
>
> **适用范围**：上游 CEGUI `v0-7-1` 与 `v0-7-9` 标签的源码差异，以及 MT3 当前 Win32 `Upgrade30` 配置的迁移影响
>
> **核对日期**：2026-07-31
>
> **重要边界**：MT3 的 `tools/CEGUI-0.7.9-r5/` 是包含 Cocos2D 渲染器、MT3 定制控件和 BinLayout 文件的定制树，不等同于未经修改的上游发行包。

---

## 一、结论摘要

1. 上游仓库存在从 `v0-7-0` 到 `v0-7-9` 的 0.7.x 标签序列，`v0-7-9` 是该序列的最后一个标签。该事实不等同于官方 LTS 承诺，也不构成长期维护状态证明。
2. `v0-7-1` 至 `v0-7-9` 期间，渲染器、文本控件、列表控件、FreeType 和工程生成脚本均有源码变动。其中，Direct3D 11 渲染器是在 `v0-7-9` 标签中新增的模块，不能描述为 0.7.1 中已经存在但尚未稳定的模块。
3. 现有源码证据不足以支持“全部 API/XML 100% 向下兼容”“二进制兼容”“零成本升级”“直接替换头文件和库”等结论。公共头、渲染器模块和 MT3 定制接口均存在差异，升级须以完整重编和资源回归验证为准。
4. MT3 Win32 canonical 主线固定采用 `cocos2d-x-3.0-oh + CEGUI-0.7.9-r5`，并要求 `CEGUI -> engine -> FireClient -> MT3` 的下游重编顺序。`dependencies/cegui/` 的 0.7.1 树只服务于尚未迁移的平台或历史链路，不能混入 `Upgrade30` 产物。

---

## 二、证据范围与方法

本报告仅将下列材料视为事实依据：

| 类别 | 核对对象 | 用途 |
| --- | --- | --- |
| 上游标签 | [CEGUI v0-7-1](https://github.com/cegui/cegui/tree/v0-7-1)、[CEGUI v0-7-9](https://github.com/cegui/cegui/tree/v0-7-9) | 核对版本存在性、目录和源码差异 |
| 本地版本标识 | `dependencies/cegui/CEGUI/include/CEGUIVersion.h`、`tools/CEGUI-0.7.9-r5/cegui/include/CEGUIVersion.h` | 确认本地两树分别标记为 0.7.1 和 0.7.9 |
| MT3 工程配置 | `AGENTS.md`、`.claude/RULES.md`、`.claude/BUILD_GUIDE.md` | 确认 canonical 配置、ABI 和重编约束 |
| Win32 工程实物 | `client/MT3Win32App/FireClient.win32.vcxproj`、`tools/CEGUI-0.7.9-r5/cegui-0.7.9.win32.vcxproj` | 确认实际 include、静态链接宏、TinyXML 与 Cocos2D 渲染器 |
| 构建入口 | `tools/scripts/Build-MT3-Exe-Canonical.ps1`、`client/Build-MT3-v120.ps1` | 确认 `Upgrade30` 根目录校验和构建顺序 |

未找到能够逐项佐证历史 bug 成因、影响范围和修复结果的上游 issue、发布说明或提交引用时，本文只记录“源码发生变动”，不把变动推断为某个特定故障已经修复。

---

## 三、上游 0.7.1 至 0.7.9 的可证实差异

### 1. 版本与模块演进

| 维度 | v0-7-1 | v0-7-9 | 经核对的结论 |
| --- | --- | --- | --- |
| 版本标签 | 存在 | 存在，且为 0.7.x 最后一个标签 | 可将 0.7.9 视为该标签序列的末项；不使用“LTS”或“终极稳定版”表述 |
| Direct3D 11 | 不含 `RendererModules/Direct3D11` 源码 | 新增完整 Direct3D 11 渲染器源码和 Premake 项目 | 这是功能模块新增，不是旧模块的稳定性修补 |
| Direct3D 9 / 10 | 已有模块 | 相关 GeometryBuffer、Renderer、Texture 等文件有修改 | 需要按实际后端单独编译与运行验证 |
| Ogre | 已有模块 | Ogre 渲染器多个源文件有修改 | 两个标签的 pkg-config 元数据均为 `OGRE >= 1.6.0`；没有证据把支持范围收窄为仅 1.6，或承诺 1.7/1.8 的完整认证 |
| OpenGL | 已有 OpenGL 渲染器 | OpenGL 渲染器及 GLEW 相关文件有修改 | 两个标签树均未包含独立 GLES 渲染器源码，不能把上游差异描述为 GLES 1/2 专项修复 |
| Null renderer | 未见该模块 | 新增 Null renderer | 属于模块扩展，与 MT3 当前 Cocos2D 后端无直接运行时关系 |
| XML 解析器 | 多种解析器和构建选项 | 增加 RapidXML 相关模块 | XML 兼容性仍须以实际 `.scheme`、`.looknfeel`、`.layout`、`.imageset` 和 `.font` 文件回归结果判定 |

### 2. 控件、文本与字体相关源码

`CEGUIEditbox.cpp`、`CEGUIMultiLineEditbox.cpp`、`CEGUIListbox.cpp`、`CEGUICombobox.cpp` 和 `CEGUIFreeTypeFont.cpp` 在两标签间均存在差异。这说明这些子系统经过维护，但不能仅凭文件 diff 推导以下具体结论：中文输入光标错位已完全解决、双击选词行为已改变、列表清空存在越界风险，或模态窗口捕获问题已经修复。

对已核对的实现，结论如下：

- 0.7.1 的 `FreeTypeFont::free()` 已调用 `FT_Done_Face(d_fontFace)`；“0.7.9 修复 Font 销毁时未释放 Face”的说法不准确。
- 两个本地版本的 `Listbox::resetList()` 主流程均通过 `resetList_impl()` 后发送列表内容变更事件。`Combobox::resetList()` 的可见差异是 0.7.9 移除了只读状态下清空文本的分支，源码未显示“滚动条未重置导致越界”的直接证据。
- 文本、控件和字体行为应通过目标字体、中文输入、换行、选区、焦点与列表重置等回归用例判定，而不是以版本号推断。

### 3. 构建系统与编译器边界

上游 `v0-7-1` 和 `v0-7-9` 标签树使用 Autotools 与 Premake 工程组织；两树均未包含 `CMakeLists.txt`、`FindFreeType`、`FindPCRE` 或 `FindExpat` 模块。因此，不应将该版本区间描述为 CMake `Find*` 脚本升级。

上游源码对不同编译器和平台做过适配，但本报告不以此给出“MSVC 2008-2012、GCC 4.6+、Clang 完美支持”之类的承诺。实际可支持范围取决于选用的 renderer、依赖库、构建脚本和目标平台。

---

## 四、兼容性评估

### 1. API、ABI 与二进制兼容性

上游公共头文件中 `CEGUIWindow.h`、`CEGUIString.h`、`CEGUIFreeTypeFont.h`、`CEGUIEditbox.h`、`CEGUIMultiLineEditbox.h`、`CEGUIListbox.h` 与 `CEGUICombobox.h` 均存在版本差异。即使业务代码在源级别能够通过编译，也不能据此推断对象布局、内联实现、符号或静态库 ABI 保持一致。

MT3 还存在定制接口差异。例如旧树包含 `CEGUISkillBox.h`、`CEGUIResLoadThread.h` 和 `CEGUILoadingTaskManager.h` 等头文件，当前 0.7.9-r5 树并不以同一路径提供这些接口；反之，0.7.9-r5 包含 BinLayout 相关文件。迁移前必须逐个清点调用点、注册代码和资源生产链。

**结论：不承诺二进制兼容，也不采用“替换库文件”作为升级方法。**

### 2. XML、LookNFeel 与资源兼容性

0.7.x 使用的 XML 资源格式具有较强延续性，但本次核对没有发现可作为“全部 XML/LookNFeel 永久兼容保证”的上游契约。对 MT3，资源兼容性由以下链路共同决定：

```text
Scheme -> FalagardMapping -> LookNFeel -> WidgetLook
       -> Imageset / Font -> Layout -> Lua / C++ Window path
```

升级验证至少应覆盖全部入口 UI、动态加载的子 layout、字体与图片集、Falagard 控件注册和 Lua/C++ 窗口查找路径。若使用 BinLayout，还应确认当前工程是否实际编译并注册对应序列化模块，再验证二进制布局的版本与回退策略。

### 3. 渲染器兼容性

渲染器属于独立风险面：D3D9、D3D10、D3D11、Ogre、OpenGL 与 Cocos2D 的源码、依赖和设备生命周期均不同。上游某一 renderer 的改动不应外推为 MT3 Cocos2D renderer 的改动收益。

MT3 Win32 0.7.9-r5 工程实际编译 TinyXML Parser 与 Cocos2D renderer，FireClient 工程显式引用 `RendererModules/Cocos2D` 并定义 `CEGUI_STATIC`。因此，本项目的重点是 Cocos2d-x 3.0-oh 集成、Falagard 资源和 Win32 静态链接，而不是 Ogre 或 Direct3D 11 行为。

---

## 五、MT3 升级现状与正确流程

### 1. 当前配置事实

| 项目范围 | 当前事实 |
| --- | --- |
| Win32 canonical | `cocos2d-x-3.0-oh + tools/CEGUI-0.7.9-r5`，`EngineProfile=Upgrade30` |
| 历史/未迁移链路 | `dependencies/cegui/` 的 0.7.1 树，不能混入 Win32 `Upgrade30` 产物 |
| 工具链 | VS2013 `v120` + Windows SDK 8.1 + MSBuild 12.0 |
| 构建入口 | `tools/scripts/Build-MT3-Exe-Canonical.ps1` |
| CEGUI 构建形态 | 静态链接；FireClient 与 CEGUI 工程均使用 `CEGUI_STATIC` |

canonical 构建脚本会校验 `Upgrade30` 使用 `tools/CEGUI-0.7.9-r5`，并拒绝与 `dependencies/cegui` 的混合配置。这一校验是 ABI 和渲染器一致性的必要门禁。

### 2. 迁移实施步骤

1. 固定基线：记录旧 0.7.1 树、0.7.9-r5 树、Cocos2d-x 根目录、编译器和构建配置；保留可启动的回滚产物。
2. 清点定制内容：比对公共头、定制控件、Falagard 映射、Lua 绑定、BinLayout、资源加载线程和所有 CEGUI 库名；将无法映射的接口逐项迁移或保留兼容层。
3. 统一工程引用：Win32 `Upgrade30` 的 include、库目录和项目引用只能指向 `tools/CEGUI-0.7.9-r5` 与 `cocos2d-x-3.0-oh`。
4. 按依赖顺序重编：`Cocos2d-x / CEGUI -> engine -> FireClient -> MT3`。公共头、renderer、对象布局或宏分支变更时使用 `Rebuild`，不以局部增量构建替代。
5. 验证资源与运行时：加载入口 layout 与动态子 layout，检查字体、图片集、Falagard 控件、Lua 事件、中文输入、列表控件、分辨率切换和退出重入。
6. 留存证据：记录构建日志、库与可执行文件时间戳、运行日志首个错误和回归结果；异常时回退至固定基线。

### 3. 推荐构建命令

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 `
  -Configuration Release `
  -EngineProfile Upgrade30 `
  -BuildMode SafeChain
```

针对 ABI 敏感修改，最小下游顺序为：

```text
Rebuild CEGUI -> Rebuild engine -> Rebuild FireClient -> Build MT3
```

构建成功后，核对 `engine.lib`、`FireClient.lib` 与 `MT3.exe` 的时间戳顺序；共享输出目录中的产物仅显示“文件存在”不足以证明依赖链已完整刷新。

---

## 六、验证矩阵

| 验证项 | 目标 | 通过标准 |
| --- | --- | --- |
| 工程根目录门禁 | 排除 0.7.1 与 0.7.9-r5 混用 | canonical 脚本的 `EngineProfile=Upgrade30` 校验通过 |
| CEGUI 与下游重编 | 消除 ABI 混编 | CEGUI、engine、FireClient、MT3 按顺序完成，产物时间戳合理 |
| 资源声明链 | 确认 XML、LookNFeel、图片和字体可用 | Scheme、FalagardMapping、WidgetLook、Imageset、Font、Layout 均成功加载 |
| 控件行为 | 覆盖版本差异高风险区域 | Editbox/MultiLineEditbox 中文输入、选区、换行；Listbox/Combobox 增删与重置；模态窗口焦点与鼠标行为正常 |
| 渲染与显示 | 确认 MT3 实际后端 | Cocos2D renderer 下启动、界面切换、分辨率变化和退出重入无新增首错 |
| 回归日志 | 定位运行期问题 | `CEGUI_ct.log`、客户端日志和崩溃记录无新增 CEGUI 首个阻塞错误 |

---

## 七、风险、回滚与决策建议

### 1. 主要风险

- **ABI 混编**：不同版本头文件、静态库或宏展开结果混用，可能在启动期或容器访问中产生不稳定崩溃。
- **定制接口遗漏**：旧 MT3 控件、资源加载接口或 Lua 绑定缺失会导致编译失败、控件未注册或运行时查找失败。
- **资源链不完整**：XML 可解析不代表资源声明、字体、图片集、子 layout 和脚本路径均已闭环。
- **错误的 renderer 外推**：Ogre、D3D 或 OpenGL 的上游变动不能替代 Cocos2D renderer 的实机验证。
- **工具链漂移**：Win32 主线使用 v120；以其他工具集生成的库不应混入交付产物。

### 2. 回滚原则

回滚以版本化的源码、工程引用和完整构建产物为单位。发生构建或运行回归时，恢复到最近一次已验证的 CEGUI/Cocos2D/engine/FireClient/MT3 一致组合，再基于首个错误进行定位；不通过替换单个 `.lib` 或 `.exe` 进行临时修补。

### 3. 最终建议

对于需要升级 CEGUI 的 MT3 分支，建议将工作定义为“0.7.1 历史链路到 0.7.9-r5 定制链路的迁移”，而不是普通小版本替换。上游 0.7.9 提供了可参考的代码演进，但交付结论必须以 MT3 的定制接口适配、完整重编和资源/运行时回归结果为准。

---

## 八、引用与复核入口

1. CEGUI 上游标签：<https://github.com/cegui/cegui/tree/v0-7-1>、<https://github.com/cegui/cegui/tree/v0-7-9>
2. MT3 架构与 CEGUI 边界：[AGENTS.md](../AGENTS.md)
3. ABI、工具链和重编约束：[.claude/RULES.md](../.claude/RULES.md)
4. 已验证构建命令：[.claude/BUILD_GUIDE.md](../.claude/BUILD_GUIDE.md)
5. canonical 构建入口：[Build-MT3-Exe-Canonical.ps1](../tools/scripts/Build-MT3-Exe-Canonical.ps1)
