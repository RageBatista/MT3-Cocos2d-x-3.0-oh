# 源码模板补种工作流

> 基准日期: 2026-04-23
> 目的: 把“打包器源码给 CRC 规则 + 客户端源码给路径模板 + 配置/文本语料补变量 + CRC 精确命中”落成可执行流程

## 1. 适用场景

当解包结果里仍有大量 root numeric 文件时，如果已经知道：

- 索引里的 `PathFileNameCRC32` 是怎么来的
- 客户端源码或配置表里还保留了部分真实路径模板

就不应该继续只靠人工猜目录，而应该先跑“源码模板补种”。

当前推荐入口：

- [tools/source_template_seed_pipeline.py](../tools/source_template_seed_pipeline.py)

## 2. 核心思路

这条工作流分四层：

1. **打包器源码给 CRC 规则**
   - 负责回答“什么字符串会参与 CRC”
2. **客户端源码给路径模板**
   - 负责回答“真实路径骨架长什么样”
3. **配置/文本语料补变量**
   - 负责补 `resdir / name / table / family`
4. **CRC 精确命中**
   - 负责把候选路径变成可直接落盘的确定结果

也就是说：

```text
模板规则 != 真实路径语料
真实路径语料 = 模板规则 + 变量
可落盘结果 = 真实路径语料 + CRC 命中
```

## 3. 当前脚本的输入

`source_template_seed_pipeline.py` 当前支持三类输入：

### 3.1 `--scan-root`

扫描客户端源码、Lua、XML、配置文本等语料，抽取：

- `GetTableByName("group.table")`
- `UISpineSprite:new("foo")`
- `SetSpineModel("foo")`
- `geffect/...`
- `animation/...`
- `spine/...`
- `*.layout`
- `set:<imageset>`
- 以及直接写在文本里的 `effect/model/table/script/ui/map` 路径

### 3.2 `--map-config-bin`

直接结构化解析 `table/bintable/map.cmapconfig.bin`，提取真实 `resdir`，再展开：

- `map/<resdir>/maze.dat`
- `map/<resdir>/monster.dat`
- `map/<resdir>/goto.dat`
- `map/<resdir>/regiontypeinfo.dat`
- `map/<resdir>/npc.dat`
- `map/<resdir>/jumpblock.dat`
- `map/<resdir>/island.dat`
- `map/<resdir>/island2.dat`

### 3.3 `--mapping`

加载已有 `.txt` 或 `.ljpm`，用于：

- 识别“已命中无需重复补种”的路径
- 生成 merged mapping
- 报告 mapping conflict

## 4. 当前脚本的输出

脚本会生成三类结果：

### 4.1 审阅报告

- `source_template_direct_hits.tsv`
- `source_template_seed_candidates.tsv`
- `source_template_conflicts.tsv`
- `source_template_summary.json`
- `source_template_summary.md`

### 4.2 seed mapping

可选：

- `--write-seed-txt`
- `--write-seed-ljpm`

只包含“本轮新增且无冲突”的高置信路径。

### 4.3 merged mapping

可选：

- `--write-merged-txt`
- `--write-merged-ljpm`
- `--promote-dir`

会把已有映射与新增 seed 合并成一份后续可直接复用的 mapping。

## 5. 推荐执行顺序

### 第一步：先确认 CRC 规则

优先阅读：

- [13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md](13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md)
- [14_源码可提取路径模板清单_Path_Template_Inventory.md](14_源码可提取路径模板清单_Path_Template_Inventory.md)

### 第二步：跑源码模板补种脚本

典型命令示例：

```powershell
python tools/source_template_seed_pipeline.py `
  --res-dir E:\梦屿西游\assets\unpacked_res `
  --mapping E:\梦屿西游\assets\promote_ready\path_mapping.ljpm `
  --scan-root E:\MT3\client `
  --scan-root E:\梦屿西游\auto `
  --map-config-bin E:\梦屿西游\assets\unpacked_res\table\bintable\map.cmapconfig.bin `
  --output-dir E:\梦屿西游\assets\source_template_reports `
  --write-seed-ljpm E:\梦屿西游\assets\source_template_reports\seed.ljpm `
  --write-merged-ljpm E:\梦屿西游\assets\source_template_reports\merged.ljpm `
  --promote-dir E:\梦屿西游\assets\source_template_promoted
```

### 第三步：再让解包器复用 merged mapping

把第 2 步生成的 `merged.ljpm` 或 `promote_dir/path_mapping.ljpm` 重新喂给：

- GUI 的路径映射加载
- `ljfp-unpack`
- `ljfp-unpack-diag`
- `Unpacker::LoadPathMapping()`

### 第四步：再进入 `restorePathStructureAfterUnpack`

这样做的顺序是：

```text
先扩大 m_pathMapping 的高置信覆盖率
再让后处理恢复链处理剩余未命名文件
```

而不是让后处理链独自承担所有命名恢复工作。

## 6. 当前脚本适合解决的问题

### 6.1 适合

- 已知代码里明文写了表名、layout 名、spine 名、geffect 名
- 已知配置表里能直接读出 `resdir`
- 目标文件仍是 root numeric，适合做 CRC 精确命中
- 想先把高置信结果并入 mapping，再驱动后续恢复

### 6.2 不适合

- 完全没有任何模板变量语料
- 只有数字文件，没有源码、配置、文本、注册表
- 想直接从单个 CRC 反推出真实路径

这种情况仍然需要：

- 参考资源树
- 历史客户端
- manifest
- 运行时日志
- 人工候选分层

## 7. 当前已验证收益

这条 workflow 当前已经能稳定覆盖：

- `map_1601_yunmengze`
- `zichen1..10`
- 各类 `GetTableByName(...)` 驱动的 `table/bintable/*.bin`
- `UISpineSprite:new(...)` / `SetSpineModel(...)` 驱动的 `model/<name>/<name>.atlas/json/png`
- `spine/...` / `geffect/...` / `animation/...` 驱动的特效与动画模板路径

## 8. 与核心解包器的关系

这条脚本链不是替代 `Unpacker`，而是补在 `Unpacker` 前面的一层“高置信路径种子生成”：

```text
source_template_seed_pipeline
  -> merged mapping
  -> Unpacker.LoadPathMapping()
  -> forceCrcOutputFirst + restorePathStructureAfterUnpack
```

也就是说，它属于：

- 工具链前置增强层
- 不是主库 ABI 的一部分
- 但对真实项目的大规模路径恢复非常有价值
