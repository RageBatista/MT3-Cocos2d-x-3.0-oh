# SpriteEditor 打包算法参考

## 可用性与证据边界

- `tools/engine/SpriteEditor/**` 当前是运行时工作区本地内容，在 Git 中未跟踪；清理检出不保证存在。
- 目录存在时，当前可核对的源码锚点是 `tools/engine/SpriteEditor/SpritePackCoreService.{h,cpp}`。
- 仓库内不存在规范 `pack.ini`；它不是仓库链接，而是调用方提供的必填输入。先设置 `$packIniPath`，再显式传入 `-ConfigPath $packIniPath`。
- 历史文档里的 `OnPack()`、`OnToolPack()` 和 `PackFromIni()` 只能作为控制层线索；对应源码不存在时不得宣称已验证。

## 当前工作区本地入口

- `SpritePackCoreService::BuildAtlas()`
- `SpritePackCoreService::RectPacking()`
- `SpritePackCoreService::GetBigPicSize()`
- `SpritePackCoreService::PicArrange()`
- `SpritePackCoreService::WriteConvertedAni()`

## 常见模式

| 模式 | 含义 |
|---|---|
| A | 单资源或当前选择打包（历史控制层模式） |
| B | 目录级批量打包（历史控制层模式） |
| C | 基于调用方 `pack.ini` 的批处理 |
| D | 导出特定规格或专项导出流程（以实际源码为准） |

## 八步主流程

1. 由调用层收集动画、图片与帧信息
2. 将候选矩形交给 `BuildAtlas()`
3. `RectPacking()` 执行矩形装箱
4. `GetBigPicSize()` 汇总图集尺寸
5. `PicArrange()` 绘制并写出图集
6. `WriteConvertedAni()` 回写 ANI 中的新图集引用
7. 核对 ANI/XAP/图集产物数量、布局和体积
8. 仅在控制层源码存在时，再延伸追踪菜单或批处理入口

## `pack.ini` 常见键

- `texfmt`
- `blend`
- `centerx`
- `centery`
- `dirmode`
- `packtime`
- `bBindType`
- `sysLevel`
- `OutputPath`

兼容批处理时，还可能遇到：

- `frameseq`
- `regioncount`
- `partpath`

## 耦合提醒

当前工作区本地 `SpritePackCoreService` 通过 `CSpriteEditorDoc` 与编辑器状态协作。若要替换核心策略，需要评估调用层输入、矩形布局、图集导出与 ANI 回写整条链；源码缺席时先停在证据缺口，不根据历史文档猜实现。

## 边界

- 若问题是版本包、热更新或客户端下载失败，转 `resource-packaging-pipeline`
- 若只是解释资源如何进入运行时渲染，可再联动 `rendering-pipeline`
