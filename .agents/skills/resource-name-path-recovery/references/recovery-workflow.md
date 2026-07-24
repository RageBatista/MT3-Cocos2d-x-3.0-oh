# 资源真实名称与路径恢复工作流

## 1. 目标与工作边界

本流程解决的是“LJFilePack 类资源包解包后，如何把数字文件名恢复成真实目录结构、文件名称与可直接开发的资源树”。

核心目标有三个：

1. 把原始数字残留尽可能恢复为可读路径。
2. 把无法唯一恢复的条目从主 backlog 中剥离，避免噪音淹没有效线索。
3. 把最终结果沉淀为三层产物：
   - 正式报告层：`formal_results_*`
   - 工作恢复层：`unpacked_res`
   - 开发可用层：`dev_res`

本流程不把“猜路径”当成功，而把“证据充分、可复核、可继续增量回流”当成功。

## 2. 真实恢复链的阶段拆分

### 2.1 基线解包阶段

目标：

- 先拿到当前最优解包基线，而不是一上来就处理零散文件。
- 固定失败清单、路径清单和当前文件总量。

关键产物：

- `unpack_path_manifest.tsv/json`
- 严格失败清单
- `review/unresolved`

关键动作：

1. 跑严格模式或当前最优解包链。
2. 导出失败样本、首个解密失败诊断、已恢复路径清单。
3. 明确哪些是：
   - 已恢复成功
   - 严格失败
   - no-verify 可救援
   - 已落到 `review/unresolved`

### 2.2 路径映射补种阶段

目标：

- 尽量用高置信 mapping 先把“路径 CRC -> 真实路径”打通。

关键方法：

- 用 `manifest_seed_pipeline.py` 从清单、参考目录和已有 mapping 补种 seed
- 统一路径规范化、大小写、前缀裁剪和 CRC32 计算规则
- 把低置信路径在 seed 阶段就过滤掉

关键认识：

- LJFilePack 索引只存 `PathFileNameCRC32`，不存原始路径文本。
- 所以“恢复真实路径”本质上不是索引反解，而是“外部证据 + 规范化 CRC 重建”。

### 2.3 结构恢复阶段

这一阶段是整个流程的核心。

#### 文本/XML

优先证据：

- XML 根节点、窗口名、布局名、脚本类名
- 地图记录结构
- sound.inf 结构

典型回源方式：

- `<GUILayout ... Name="friendmailcontent">` -> `ui/layouts/friendmailcontent.layout`
- `<data><item ... destmap=...>` -> 地图 `goto.dat/goto.xml`
- `<data key=...><component ...>` -> 模型 `sound.inf`

#### 二进制表

优先证据：

- `script/tabledef/**/*.lua`
- 客户端 C++ `GameTable` 头文件
- `auto` XML
- 字段语义

实际流程：

1. 先判断能否精确匹配 `tabledef`
2. 再判断能否匹配 C++ schema
3. 再补字段级 parser，导出 CSV / JSON
4. 打不穿时，只输出语义块和失败点，不强行并入主树

典型案例：

- `item.cchatboxout.bin`
- `title.ctitleconfig.bin`

#### 模型 / 动画 / Spine

优先证据：

- `layerdef.lmx`
- `ride1/ride2/ride3/ride4.lmx`
- `action/action.lmx`
- 引擎 `SetRideName` / `GetLayerRideEnable` / `GetComponent`
- 纹理、动画、atlas/json 的内容签名

典型做法：

- 先恢复“模型目录上下文”
- 再恢复 `ridemodel -> layer -> model` 映射
- 再区分：
  - 真实实体路径已命中
  - 只有上下文映射
  - 仅能提升为候选，不能直接并入主树

### 2.4 review/unresolved 压缩阶段

这是“让 backlog 可持续”的关键阶段。

#### 唯一精确同内容

定义：

- `review/unresolved` 文件与 `dev_res` 某个文件字节完全一致
- 且只命中一个目标

处理：

- 移到 `review/resolved_exact_content_alias`
- 记账但不宣称恢复了原始路径

#### 多命中歧义同内容

定义：

- 与 `dev_res` 多个文件内容完全一致

处理：

- 移到 `review/resolved_ambiguous_content_alias`
- 从主 `unresolved` backlog 中剥离

### 2.5 强信号扩展修正阶段

当同一路径已经恢复，但扩展名明显错误时，不必继续把它留在 `review/unresolved`。

允许的强信号：

- 内容是 JSON 文本 -> 补 `.json`
- 内容命中 PNG 魔数 -> 补 `.png`
- ANI 头特征明显 -> 补 `.ani`
- 当前误落成 `.jpg/.jpeg/.dds` 的稳定二进制块 -> 补 `.dat`
- 地图 `.dat` 再补一份 `.xml` 可读副本

原则：

- 只补高置信 sibling 文件
- 不覆盖已有不同内容目标
- 报告里记录 `copied / exists_conflict / skipped`

### 2.6 候选升级阶段

有些文件还不能直接进主树，但证据已经足够强，不应继续埋在 `unresolved`。

典型候选：

- `sound.inf`
- `ridemodel` 组件上下文
- 部分地图配置
- 半闭环 ANI / 贴图链

这类条目应提升到独立候选目录，并附：

- 候选路径
- 证据链
- 置信度
- 为什么不直接并入主树

### 2.7 回流与开发树组装阶段

最终把结果分层：

- `formal_results_*`
  - 报告、候选、统计、说明
- `unpacked_res`
  - 当前最优恢复工作树
- `dev_res`
  - 二次开发可用资源树

回流原则：

- `unpacked_res` 保留工作痕迹和 review 结构
- `dev_res` 去掉 review 噪音，只保留主资源树和必要辅助资料

## 3. 关键技术方法

### 3.1 证据优先级

推荐按下面顺序判定：

1. 路径清单 / 现成 mapping / CRC 命中
2. 引擎与客户端代码加载逻辑
3. `auto` XML 与 `tabledef`
4. 文件内容结构与魔数
5. 同内容哈希命中
6. 语义块 / 候选上下文
7. 人工猜测

### 3.2 内容判型

常见信号：

- JSON 文本：以 `{` 或 `[` 开头
- PNG：`89 50 4E 47 0D 0A 1A 0A`
- ANI：稳定的动作头结构
- UTF-16 XML：地图 `.dat` 可读内容常以 UTF-16 存储
- Spine：`.json + .atlas + page image`

### 3.3 路径恢复不是一刀切

同一轮里常常会同时存在四种结果：

- 真实路径精确恢复
- 结构正确但扩展错
- 内容已知但路径多候选
- 只有语义上下文，不能直接回流

真正稳定的流程必须允许这四种状态并存，而不是强逼所有文件都落成“已恢复”。

## 4. 潜在挑战

### 4.1 索引天然缺路径

- 根因不是工具弱，而是原始格式就不保存路径文本。
- 因此必须接受“外部证据重建”是常态。

### 4.2 错扩展与误分类

- 同一内容可能被先前链路误落到 `.dds/.jpg/.pngpart/.webp`
- 这类问题如果不单独治理，会反复污染 `unresolved`

### 4.3 二进制表漂移

- 某些表不是单一 schema
- 只能分阶段打穿：先字段、再变体、再完整结构化

### 4.4 模型共享组件

- 坐骑、武器、Spine、贴图页经常是共享组件
- “只找到上下文，没找到实体 payload” 是正常中间状态

### 4.5 重复内容过多

- 如果不把 exact / ambiguous alias 从主 backlog 剥离，`unresolved` 会被重复内容淹没

## 5. 产物组织建议

建议长期维持下面的目录职责：

- `formal_results_*`
  - 事实归档、候选、报告、统计
- `unpacked_res`
  - 恢复工作树
- `review/`
  - 候选、别名、未解决、结构化提升中间态
- `dev_res`
  - 开发可用资源树

## 6. 本流程的核心逻辑

一句话总结：

先固定基线，再用多源证据做结构恢复；无法唯一恢复时优先减噪和候选升级；最后只把高置信结果回流到主资源树。
