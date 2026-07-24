# SuperSpriteEditor 技术边界

> **当前工作树证据**：`tools/engine/SpriteEditor/` 仅保留部分抽取源码、`docs/` 与产物资产。
> **可直接核对的源码**：`SpritePackCoreService.*`、`SpritePackTypes.h`、`SpriteEditorOperationUi.*`、`SpriteEditorViewInteractionUtils.*`、`SpriteEditorViewRenderUtils.*`。
> **文档索引**：[docs/07-参考文档/02-文档索引.md](../07-参考文档/02-文档索引.md)

## 1. 证据边界

当前工作树缺少 `SpriteEditorDoc.cpp`、`SpriteEditorView.cpp`、`SpriteEditorConstants.h`、完整工程文件和默认 `pack.ini`。因此：

- 可以将现存 service/helper 的接口与算法写成当前事实。
- 工具整体 Doc/View、菜单、对话框和构建行为只能作为工具内文档/历史研究，不声称已由当前源码全量验证。
- 旧“3,492 行 God Object”、“72 个 handler”等统计只是历史背景，不代表当前抽取后架构。

## 2. 当前抽取结构

```text
SpriteEditorOperationUi
  -> 操作结果与用户提示辅助

SpriteEditorViewInteractionUtils
  -> 视图交互和坐标/命中辅助

SpriteEditorViewRenderUtils
  -> 视图渲染辅助

SpritePackCoreService
  -> 图集建立、矩形装箱、大图尺寸、纹理排列
  -> 独立 ANI 转换写出接口
```

## 3. 打包核心

[`SpritePackCoreService.cpp`](../../tools/engine/SpriteEditor/SpritePackCoreService.cpp) 当前主链：

```text
BuildAtlas
  -> RectPacking
  -> GetBigPicSize
  -> PicArrange

WriteConvertedAni
  -> 独立方法；当前抽取源码未发现调用者
```

| 方法 | 职责 |
| --- | --- |
| `BuildAtlas()` | 聚合图片矩形、调度装箱和图集写出。 |
| `RectPacking()` | 使用 MaxRects 风格装箱，将图片分配到一个或多个 bin。 |
| `GetBigPicSize()` | 根据装箱结果计算每张大纹理尺寸并记录利用率。 |
| `PicArrange()` | 创建 render target，将源图片绘制到目标纹理并保存图集。 |
| `WriteConvertedAni()` | 独立接收 `picPosInfos`、ANI 路径和 `COldAniPack`，将新图集位置写入转换后动画数据；不由 `BuildAtlas()` 自动调用。 |

当前抽取源码中，`BuildAtlas()` 在 `PicArrange()` 成功后直接返回图集数量；全仓当前 C/C++ 源码未发现 `WriteConvertedAni()` 的调用者。因此，图集生成与 ANI 回写是两个独立动作，完整工具流程若需要 ANI 转换，必须由上层显式编排并重新核对调用点。

## 4. `pack.ini` 边界

仓库内没有当前默认 `pack.ini`。`pack.ini` 必须是调用方提供的真实配置路径，不把文档占位符或历史路径当作仓库链接。

预检命令：

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\sprite-pack-algorithm\scripts\verify-pack-output.ps1 -ConfigPath <调用方真实pack.ini路径>
```

配置解释必须同时保留实际输入目录、输出目录、图集上限、图像/纹理格式和样本产物。

## 5. 输出与不变量

- 每个源图片必须唯一映射到某个输出纹理和矩形。
- 方向、帧、锨点/偏移和装备层语义不因图集重排而改变。
- 纹理尺寸不超过配置/渲染设备上限。
- 上层若另行生成 ANI/XAP，必须保证其纹理索引/矩形与本次图集输出一致。
- 任何失败不留下被当作完整产物的部分输出。

## 6. 验证

1. 静态检查调用方 `pack.ini`。
2. 选一个可重现样本执行打包，保留日志和输出哈希。
3. 检查图集数、尺寸、利用率、边界渗色和透明通道。
4. 若上层流程另行写出 ANI/XAP，检查其纹理索引和矩形是否与图集一致，并确认该步骤不是由 `BuildAtlas()` 隐式完成。
5. 在工具预览或客户端运行时检查完整动画、方向、帧、偏移和装备层。

## 7. 相关研究

- [SpriteEditor 架构分析](research/sprite-editor/01-架构分析.md)
- [SpriteEditor 完整工作流](research/sprite-editor/02-完整工作流.md)
- [SpriteEditor 对话框与辅助类](research/sprite-editor/03-对话框与辅助类.md)
- [工具内文档索引](../../tools/engine/SpriteEditor/docs/00-文档索引.md)
