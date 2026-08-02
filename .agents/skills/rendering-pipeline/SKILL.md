---
name: rendering-pipeline
description: "处理 Cocos2d-x、Nuclear 与 CEGUI 运行时渲染器、绘制顺序、裁剪、批处理和 DrawCall。用于显示异常与渲染性能；不用于 .layout/.scheme/.looknfeel 的加载、声明或 XML 解析，也不用于平台壳层或热更新发布。"
---

负责“渲染处理层”。当问题落在 UI 显示、渲染器、特效、批量绘制、输入到绘制转换链路时，优先用本技能。

## 何时使用

- CEGUI 资源声明已闭环且布局可加载，但窗口仍不显示、裁剪/层级异常或输入命中到绘制转换失效
- 特效、精灵、批量绘制顺序或裁剪异常
- 需要解释 Cocos2d-x -> Nuclear -> FireClient UI 的渲染接管关系
- 需要追踪资源提供器、异步纹理加载或 UI 渲染性能问题

## 不使用

- 问题只在平台输入桥接、JNI、ObjC++、Launcher 或壳层窗口时，改用 `platform-bridge`
- 问题只在 `.layout/.scheme/.looknfeel/.imageset/.font` 的加载、声明、XML 解析或控件路径绑定时，改用 `cegui-layout-integration`
- 问题只在资源包缺失、版本索引、PFS、热更新或下载校验时，改用 `resource-packaging-pipeline`

## 输入校验

- 先确认症状是资源缺失、绘制顺序、输入到绘制转换，还是纯业务逻辑导致“看起来像渲染”
- 先拿到首个可见阻塞证据：日志、截图、控件路径、渲染器调用栈或资源加载错误
- 先判定是否需要联动 `cegui-layout-integration`

## 先做什么

1. 先运行 `scripts/probe-render-stack.ps1`，快速确认 CEGUI 资源提供器、`GameUIManager` 和 Nuclear 渲染器骨架是否齐备；需要供后续脚本或审计链直接消费时，可追加 `-Json`
2. 先判断问题是资源缺失、平台输入、业务逻辑还是纯渲染问题
3. 涉及 PFS 资源查找、版本包或热更新时，联动 `resource-packaging-pipeline`
4. 涉及 JNI、ObjC++、平台输入桥接或 WebView 遮挡时，联动 `platform-bridge`
5. 需要完整渲染栈和关键文件时，再读 `references/render-stack.md`

## 关键锚点

- `tools/CEGUI-0.7.9-r5/cegui/src/RendererModules/Cocos2D/CEGUICocos2DRenderer.cpp`
- `tools/CEGUI-0.7.9-r5/cegui/src/CEGUIWindowManager.cpp`
- `client/FireClient/Application/GameUI`
- `engine`

## 失败处理

- 若无法证明是纯渲染问题，不要顺手修改布局、脚本、平台桥接三层
- 若资源缺失来自版本包或下载器链路，立即切到 `resource-packaging-pipeline`

## 输出与验证

- 输出至少包含：渲染层级判断、首个阻塞锚点、是否为资源链/输入链/绘制链问题、验证建议
- 需要快速建立渲染锚点时，优先附上 `scripts/probe-render-stack.ps1` 的 `STATUS/SUMMARY/DETAIL/NEXT`
- 若需要机器可读结果，优先使用 `probe-render-stack.ps1 -Json`
- 改动后至少验证一个真实显示结果，如窗口显示、特效顺序、点击命中或性能症状

## 资源与上下文预算

- 默认先跑 `scripts/probe-render-stack.ps1`，再只读直接相关的渲染器、窗口管理器、目标 UI 模块和最新日志
- `references/render-stack.md` 仅在需要完整层级图时展开

## 需要时再读

- `references/render-stack.md`
