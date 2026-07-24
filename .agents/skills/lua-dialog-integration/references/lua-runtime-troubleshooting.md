# Lua UI 运行时排障参考

## 日志与根因顺序

1. 先按时间戳区分当前 `CEGUI_ct.log` 与历史 `CEGUI.log/CEGUI_history.log`。
2. 从第一个 Lua `require`、语法或 handler 错误开始，不先修后续 nil 参数。
3. 缩略路径只有 `[string "..."]:<line>` 时，用行号、函数名和错误特征词反查源码。
4. `OnCreate()` 中途失败后仍会进入销毁路径；C++ handler、ScriptFunctor、manager 与货币文本解绑都要判空并置 `nil`。

## 协议资源闭环

Lua 运行时协议至少核对三层：

1. 发送/响应协议文件在 `client/resource/res/script/protodef/**` 有实物。
2. `client/resource/res/script/protodef/protocols.lua` 已注册 creator。
3. `handler/*.lua` 的 `process()` 路由到当前 dialog/manager，依赖 bean 也已同步。

运行时 Lua 协议镜像不是 `client/FireClient/Application/ProtoDef/**` 生成物。缺文件时优先对照已有打包/解包实物和服务端定义；若服务端 `sizepolicy.conf`、`gs.xio.xml.m4` 与 Java 协议类也无注册，先判断为旧 Lua 遗留名，不手写假协议。

若旧协议只查询本地已同步的货币或状态，优先复用现有 manager/cache，例如 `CurrencyManager.registerTextWidget` 与 `getOwnCurrencyMount`，不要新增无服务端闭环的请求。

## 表配置闭环

遇到 `BeanConfigManager:MakeTableValue` 或 `module 'tabledef.*' not found`：

1. 沿调用方 `BeanConfigManager:GetTableByName()` 取得完整表名。
2. 确认 `client/resource/res/script/tabledef/<path>.lua` 存在。
3. 确认对应 `.bin/.xml` 配置数据存在并进入当前资源链。
4. 验证读取结果与 dialog 刷新路径，而不是只在调用处返回空值。

## 主界面与子布局接线

给现有主界面补入口至少检查：

1. layout 中有目标节点。
2. `OnCreate()` 成功 `getWindow()` 并做正确控件转换。
3. `subscribeEvent()` 指向存在的回调。
4. 点击后打开正确 dialog。
5. 开服天数、等级、系统设置或简化模式的刷新逻辑不会再次隐藏入口。

接回旧功能时优先对照旧版 `layout + dialog` 的命名、显隐条件与打开逻辑，复用遗留按钮坑位；不要凭猜测重造入口链。

对新接入功能目录继续反查所有 `loadWindowLayout("*.layout")` 子布局、`GetTableByName()` 表名、请求协议、响应协议与 handler，防止首错消失后变成“无报错但不刷新”。

## 验证命令

```powershell
rg -n "GetLayoutFileName|loadWindowLayout" client/resource/res/script
rg -n "subscribeEvent|InsertScriptFunctor|RemoveAllScriptFunctors" client/resource/res/script
rg -n "GetTableByName|RegisterLuaProtocolCreator" client/resource/res/script
```

对变更 Lua 运行 `lua -e "assert(loadfile(...))"`；若文件是 GB18030/CP936，语法校验可使用临时 UTF-8 副本，但写回必须保持原编码。
