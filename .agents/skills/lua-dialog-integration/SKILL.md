---
name: lua-dialog-integration
description: "处理 MT3 Lua 对话框、Dialog 生命周期、事件绑定、窗口路径查找与 CEGUI 布局协同的技能。用于新增或修改 `client/resource/res/script/**/*.lua` 中的 UI dialog、cell、manager、窗口事件处理、数据同步、`GetLayoutFileName()` 关联逻辑，以及排查 Lua UI 与 C++ 主链交互问题时使用；不用于纯资源链或平台壳层问题。"
---

把 Lua UI 任务先定性为“生命周期 + 数据同步”问题。主链是 `dofile_main.lua` 预加载、`Dialog` 基类加载布局、`LuaUIManager` 登记与退出；不要只补按钮回调。

## 何时使用

- 新增或修改 Lua `dialog/cell/manager`、`GetLayoutFileName()`、窗口事件与数据同步
- 排查 ScriptFunctor 泄漏、死回调、窗口路径或布局入口不一致
- `CEGUI_ct.log` 的 Lua handler 报错来自 `require`、`protodef`、`tabledef`、handler 参数或销毁解绑
- 需要确认 Lua UI 与 C++ 入口、协议回包或 CEGUI 布局的协同关系

## 不使用

- 只涉及 `.layout/.scheme/.looknfeel/.imageset/.font` 资源链时，用 `cegui-layout-integration`
- 只涉及平台入口、JNI、ObjC++ 或渠道生命周期时，用 `platform-bridge`
- 只涉及生成协议定义或 tolua 生成物时，用 `generated-code-guard`

## 输入校验

1. 先判定目标是完整 dialog、cell/嵌入组件，还是 manager/桥接脚本。
2. 确认布局由 `GetLayoutFileName()`、动态 `loadWindowLayout()`，还是 C++ 侧加载。
3. 锁定首个阻塞证据：窗口路径、事件绑定、数据回包、显隐逻辑、协议注册或表定义缺口。
4. 日志只有 `[string "..."]:<line>` 时，用行号和特征词反查真实 Lua 文件；不要把 CEGUI 当作根因层。
5. 先运行静态检查：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\lua-dialog-integration\scripts\check-lua-ui-bindings.ps1 -ScriptPath <lua> -Json
```

## 关键边界

- 完整 dialog 默认复用 `logic/dialog.lua`：单例、`OnCreate()`、`DestroyDialog()`、`OnClose()` 与 `LuaUIManager` 登记必须闭环。
- 覆盖 `OnClose()` 或注册 ScriptFunctor 时，必须调用 `Dialog.OnClose(self)` 或完成等价解绑；半初始化对象的解绑路径必须判空并置 `nil`。
- Cell 多次加载必须传 `nameprefix`；控件改名后全仓反查 `prefix..`、`sID..` 等拼接路径。
- 事件优先显式 `subscribeEvent()`；布局含 `LuaEventOnClicked` 时，确认同名函数存在且不会与显式订阅重复触发。
- `client/resource/res/script/protodef/**` 是运行时 Lua 镜像，不等同于 `client/FireClient/Application/ProtoDef/**` 生成物；不要手写猜协议。
- `GetTableByName("item.xxx")` 同时要求 `tabledef/item/xxx.lua` 与对应配置数据实物；不能只在调用点加空判断。
- 主界面入口至少闭环：layout 节点、`OnCreate()` 取窗、`subscribeEvent()`、打开逻辑、运行时显隐刷新。
- 若同时修改布局或样式资源，组合 `cegui-layout-integration`。

## 最短流程

1. 读取目标脚本、最近布局与直接调用方，再确认 dialog/cell/manager 模式。
2. 沿 `GetLayoutFileName/loadWindowLayout -> getWindow -> subscribeEvent -> data/handler -> DestroyDialog` 追主链。
3. 协议链同时核对发送协议、`protodef/protocols.lua` creator 注册与 `handler/*.lua process()` 路由。
4. 表配置链沿 `BeanConfigManager:GetTableByName()` 反查表名、`tabledef` 与数据文件。
5. 只修首个根因；静态检查通过后再做创建、点击、回包、刷新和销毁回归。

关键锚点：

- `client/resource/res/script/dofile_main.lua`
- `client/resource/res/script/logic/dialog.lua`
- `client/resource/res/script/logic/luauimanager.lua`
- `client/resource/res/script/protodef/protocols.lua`
- `client/FireClient/Application/Framework/GameApplication.cpp`
- `client/FireClient/Application/Manager/LoginManager.cpp`

## 失败处理

- 布局入口不清晰时继续追 `layoutName/strLayoutName/lyoutname` 与字符串拼接，不先改控件名。
- 同时出现 `module ... not found` 和后续 nil/C++ 参数错误时，先修首个 require、协议或表配置缺口，再验证幂等解绑。
- 当前日志与历史日志行号不一致时，以最新 `CEGUI_ct.log`、文件时间戳和当前源码为准。
- 根因落在纯资源、生成边界或平台壳层时，立即切换对应技能，不跨域混改。

## 输出与验证

- 输出：脚本模式、生命周期阶段、首个阻塞锚点、窗口/事件/协议影响面、验证结果。
- 至少回归一条真实链路：创建、控件绑定、事件触发、协议回包/表刷新或销毁解绑。
- Lua 语法用 `lua -e "assert(loadfile(...))"`；历史编码脚本先按原编码处理，写回保持编码、BOM 与换行。
- 协议修复后确认 `protocols.lua`、依赖 bean 与 handler 路由均指向当前实际 dialog。
- 动态布局修复后核对脚本引用的每个 layout 都有工作区实物。

## 资源与上下文预算

- 默认只读目标脚本、最近布局、直接调用方和最新日志。
- 生命周期、事件、动态布局与 Cell 模式需要细节时读 `references/lua-dialog-patterns.md`。
- 协议镜像、表配置、主界面接线和半初始化排障需要细节时读 `references/lua-runtime-troubleshooting.md`。

## 需要时再读

- `references/lua-dialog-reference-index.md`
- `references/lua-dialog-patterns.md`
- `references/lua-runtime-troubleshooting.md`
- `docs/03-开发指南/07-CEGUI与Lua资源集成.md`
- `docs/03-开发指南/08-CEGUI布局Lua与C++关系表.md`
- `docs/03-开发指南/17-核心UI资源健康门禁.md`
