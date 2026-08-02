# CEGUI 0.7.9 可行性研究

> **状态**：研究结论已落地到 Win32 `Upgrade30`；本文保留样本差异与迁移决策记录。
> **研究样本**：`tools/CEGUI-0.7.9-r5/`。
> **当前客户端**：Win32 使用 `tools/CEGUI-0.7.9-r5/`；Android/iOS 仍使用 `dependencies/cegui/` 的 0.7.1 兼容链。
> **实施记录**：[MT3 双引擎升级实施记录](../MT3-双引擎升级实施记录-2026-08-02.md)。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 可验证的样本边界

`tools/CEGUI-0.7.9-r5/` 当前包含 `bin/`、`lib/`、`dependencies/`、`docs/`、`projects/` 和知识库，也保留了 `.obj`、`.lib`、`.dll`、`.exe` 等研究产物。

这些实物可以证明“仓库内存在 0.7.9 研究样本和阶段性产物”，但不能证明：

- 当前客户端已链接 0.7.9。
- 0.7.9 已完整承载 MT3 定制补丁。
- 当前 HEAD 下可从零重现同一构建。
- Win32、Android、iOS 和全量 UI 资源已验证通过。

## 2. 研究问题

1. 0.7.9 与 MT3 0.7.1 定制 API 的编译差异是什么？
2. Cocos2D Renderer 能否使用 Cocos2d-x 2.2.6 和当前 GL 状态模型？
3. `IAdapter`、BinLayout、纹理恢复和业务 Falagard 扩展如何迁移？
4. Lua 绑定和 2,000+ 业务脚本的 API/事件兼容性如何？
5. XML/BIN Layout、Scheme、LookNFeel、Imageset、Font 能否无损加载？
6. v120/Win32、Android NDK r16 clang 和 iOS 工程能否保持 ABI/产物一致？

## 3. 差异核对清单

| 领域 | 当前 0.7.1 必须保留的能力 | 0.7.9 研究动作 |
| --- | --- | --- |
| Renderer | `RendererModules/Cocos2D` 与 Cocos2d-x 2.2.6 桥接 | 做源码/接口差异和最小渲染样例。 |
| 分辨率 | `CEGUI::IAdapter` + `ResolutionAdapter` | 编译适配并对照 runtime profile。 |
| Layout | XML + `BinLayout/v1` + 子布局/property callback | 列出格式和 API 差异，做历史样本往返。 |
| 资源 | PFS/Default provider、自定义 resource groups | 验证打包资源和松散资源两种模式。 |
| 纹理生命周期 | Imageset texture state update/cleanup | 在前后台和 GL 重建中回归。 |
| Lua/API | MT3 自定义 Window、回调和 tolua 暴露 | 生成 API 差异清单并扫描 Lua 调用。 |
| Falagard | MT3 业务 renderer/属性 | 逐类迁移并使用实际 LookNFeel 回归。 |

## 4. 建议研究阶段

### Phase A：静态差异

- 建立 0.7.1 定制文件/API/工程清单。
- 将 0.7.9 样本中的等价模块和缺口分类。
- 不修改当前客户端工程引用。

### Phase B：独立最小编译

- 只构建核心库 + Cocos2D Renderer + XML/ImageCodec + Falagard + Lua 必要模块。
- 记录完整构建命令、工具链、警告、产物哈希和运行时 DLL。
- 构建结果只作为研究证据，不直接覆盖 0.7.1 产物。

### Phase C：资源与 API 兼容

- 从真实 Scheme/Layout/LookNFeel/Imageset/Font 选择最小集合。
- 对照 XML/BIN、Lua 事件、Window 属性和 renderer 输出。
- 把未迁移定制点作为阻断项，不用资源绕过。

### Phase D：三端候选集成

- 在独立分支/产物目录中评估 Win32、Android、iOS。
- 执行登录、入世界、大型 UI、前后台、切场景、文字输入和性能回归。
- 只有在定制能力、格式、三端与回滚验证闭环后，才进入升级决策。

## 5. 成功标准

- 所有当前 CEGUI 工程引用仍明确，研究产物不污染 0.7.1 输出。
- 定制补丁清单无缺项，每项有迁移/保留/取消决策和测试。
- 实际资源集无解析、类型注册、纹理、字体、事件或布局回归。
- Win32、Android、iOS 都有可复现构建、运行日志、截图/性能和回滚证据。

## 6. 当前结论

0.7.9 样本具有继续做差异研究的价值，但当前工程事实仍是 0.7.1 MT3 定制分叉。本页不记录“已验证构建成功”或“可直接升级”的结论，因为当前 Task 9 取证没有完成上述闭环。
