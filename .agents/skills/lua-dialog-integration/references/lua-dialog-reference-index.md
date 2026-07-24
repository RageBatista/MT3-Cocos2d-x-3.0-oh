# Lua Dialog 参考文档索引

> 本文件只做按需路由。共享事实以仓库源码、项目开发指南和下表中的活跃参考为准，不在多个技能目录重复维护。

## 共享参考

| 需要的上下文 | 活跃参考 |
| --- | --- |
| Dialog 生命周期、ScriptFunctor、事件绑定、控件转换、动态布局、Cell 与常用属性 API | [lua-dialog-patterns.md](lua-dialog-patterns.md) |
| Lua `require`、协议镜像、表配置、handler、半初始化销毁与主界面接线排障 | [lua-runtime-troubleshooting.md](lua-runtime-troubleshooting.md) |
| CEGUI 资源目录、资源组初始化、`scheme -> looknfeel/imageset/font -> layout` 与 Lua 主链 | [07-CEGUI与Lua资源集成.md](../../../../docs/03-开发指南/07-CEGUI与Lua资源集成.md) |
| layout 的直接 dialog、动态子布局/cell、C++ 与隐式入口反查 | [08-CEGUI布局Lua与C++关系表.md](../../../../docs/03-开发指南/08-CEGUI布局Lua与C++关系表.md) |
| 核心 UI 发布阻断条件、Smoke 路径与聚合验证命令 | [17-核心UI资源健康门禁.md](../../../../docs/03-开发指南/17-核心UI资源健康门禁.md) |

## 选择原则

1. 先读目标脚本、最近 layout、直接调用方和当前日志。
2. 只在主链缺少事实时打开对应一项参考，不批量加载全部文档。
3. 文档统计可能随仓库演进而变化；涉及数量、入口或资源实物时，以当前 `rg`、静态检查脚本和源码为准。
