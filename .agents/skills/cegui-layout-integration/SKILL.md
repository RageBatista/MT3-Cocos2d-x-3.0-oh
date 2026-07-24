---
name: cegui-layout-integration
description: "处理 MT3 CEGUI XML 资源声明链与布局绑定。用于 .layout/.scheme/.looknfeel/.imageset/.font 的新增、解析和排障，以及控件命名与 Lua/C++ 查找路径校对；不用于渲染器、绘制顺序、DrawCall、纯 Lua 生命周期或平台壳层问题。"
---

# CEGUI 布局集成技能

MT3 的 CEGUI 资源链按 `Scheme -> FalagardMapping -> LookNFeel -> WidgetLook -> Imageset/Font -> Layout -> Lua/C++ Window path` 闭环排查。先确认阻塞发生在哪一层，再决定是否联动 Lua、渲染链或资源发布链。

## 何时使用

- 新增或修改 `.layout`、`.scheme`、`.looknfeel`、`.imageset`、`.font`。
- 处理布局加载失败、窗口类型未注册、图片/字体缺失、XML 解析失败、控件路径找不到。
- 校验 `LuaEventOnClicked`、Lua `getWindow()`、C++ `WindowManager` 查找路径与 layout 控件命名是否一致。
- 分析 CEGUI 布局加载耗时、窗口数量与图片集/字体声明数量；若已进入 DrawCall 或绘制执行链，转 `rendering-pipeline`。

## 不使用

- 纯 Lua Dialog 生命周期、事件解绑、数据同步或 manager 回调问题，改用 `lua-dialog-integration`。
- 资源 XML 已闭环，问题在渲染器、绘制顺序、裁剪、批处理或 DrawCall 时，改用 `rendering-pipeline`。
- 平台壳层、JNI、WebView、下载器或渠道生命周期问题，改用 `platform-bridge`。
- PFS、热更新、版本索引或补丁发布问题，改用 `resource-packaging-pipeline`。
- 服务端协议、xbean/rpc 或 Ant 构建问题，不使用本技能。

## 输入校验

1. 先拿到当前日志窗口内的首个 CEGUI 错误、布局名、资源路径和复现步骤。
2. 判断主故障层：layout、scheme、looknfeel、imageset/font、窗口路径、事件绑定、性能或运行时渲染。
3. 若 `CEGUI_ct.log` 首错是 `Unable to call Lua event handler`、Lua traceback、`module 'protodef.*' not found`、`module 'tabledef.*' not found`、`BeanConfigManager:MakeTableValue` 或 C++ Lua 桥接参数错误，主故障层先切到 `lua-dialog-integration`，不要先改 layout。
4. 若同时命中 `client/resource/res/script/**`，联动 `lua-dialog-integration` 检查 Lua 生命周期、事件绑定、协议镜像和回包 handler。
5. 修改任何布局、脚本或中文文档前，按 `encoding-bom-guard` 确认编码、BOM 与换行。

## 执行顺序

1. 查 Layout：确认 `<Window Type="..." Name="...">`、控件路径、父子层级和动态 nameprefix。
2. 查 Scheme：确认 `FalagardMapping WindowType="..."` 已声明对应窗口类型。
3. 查 LookNFeel：确认 `WidgetLook name="..."` 存在且 XML 可解析。
4. 查 Imageset/Font：确认 `.imageset/.font` 文件存在、scheme 已声明、图片/字体资源可读取。
5. 查 Lua/C++：确认 `getWindow()`、`loadWindowLayout()` 子布局、`LuaEventOnClicked`、C++ 查找路径与 layout 名称完全一致。
6. 需要批量静态检查时，运行 `scripts/check-cegui-bindings.ps1` 或 `scripts/validate-cegui-resources.ps1`。

## 失败处理

- 若只有“窗口类型未注册”，先向前排查 scheme/looknfeel/XML 解析失败，不要直接补控件定义。
- 若 CEGUI 日志只是事件分发外壳，错误体来自 Lua `require`、`BeanConfigManager` 表定义、协议模块缺失、handler `process()` 或销毁解绑，先追 Lua/tabledef/protodef 链路；CEGUI 资源链不作为首修目标。
- 若主 layout 检查通过但脚本里动态 `loadWindowLayout("*.layout")`，必须逐个确认子 layout 文件存在；静态检查器只扫入口 layout 时不代表运行期子布局闭环。
- 若当前日志和历史日志混杂，先确认时间戳与冷启动复现，再判断根因。
- 若静态检查和运行时表现冲突，优先补资源加载日志、CELayoutEditor 冷启动和真实运行目录对比。
- 若验证脚本失败，先修首个 failure；不要批量改 layout 或统一转码。

## 输出与验证

- 输出至少包含：首个错误、故障层、受影响资源、窗口类型闭环、Lua/C++ 路径闭环、修改建议和验证步骤。
- 单布局检查：`powershell -ExecutionPolicy Bypass -File ./.agents/skills/cegui-layout-integration/scripts/check-cegui-bindings.ps1 -Layout <layout> -Json`。
- 批量资源链检查：`powershell -ExecutionPolicy Bypass -File ./.agents/skills/cegui-layout-integration/scripts/validate-cegui-resources.ps1 -Json`。
- 修改后至少确认：入口 layout 和动态子 layout 可加载、控件可查找、图片/字体正常、事件可达、日志首个 blocker 前移或消失。

## 资源与上下文预算

- 默认只读目标 layout、相关 scheme/looknfeel/imageset/font、对应 Lua 文件和当前日志。
- 需要资源链、初始化顺序与生命周期背景时读 `docs/03-开发指南/07-CEGUI与Lua资源集成.md`。
- 需要判断完整 dialog、动态 cell/子布局、C++ 入口或隐式布局名时读 `docs/03-开发指南/08-CEGUI布局Lua与C++关系表.md`。
- 需要事件/API、控件转换、动态布局与 Cell 模式时读 `../lua-dialog-integration/references/lua-dialog-patterns.md`。
- 首错落在 Lua `require`、协议、表配置、handler 或销毁路径时读 `../lua-dialog-integration/references/lua-runtime-troubleshooting.md`，并切换或组合 `lua-dialog-integration`。
- 需要发布阻断条件、核心 UI 路径或聚合验证入口时读 `docs/03-开发指南/17-核心UI资源健康门禁.md`。
- 不批量展开所有 UI 资源；优先按布局族、窗口类型或首个错误收敛范围。
