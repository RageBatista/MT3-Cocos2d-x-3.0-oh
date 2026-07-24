# 路径CRC32精确恢复规则

## 1. 结论

对 LJFilePack / SuperLJFilePackUnpack 当前处理的这类资源，若已经知道真实相对路径字符串，则可以直接用下面的规则判断数字文件名是否就是该路径：

```text
PathFileNameCRC32 == CRC32(规范化后的相对路径字符串)
```

对 MT3 当前已验证的地图资源，最常见的形式是：

```text
CRC32("map/<resdir>/<leaf>")
```

例如：

- `CRC32("map/map_1888_shuiliandong/regiontypeinfo.dat") == 107031767`
- `CRC32("map/map_1601_shamo/regiontypeinfo.dat") == 2362947266`
- `CRC32("map/map_1601_yunmengze/regiontypeinfo.dat") == 1527753193`
- `CRC32("map/map_1601_yunmengze/island.dat") == 4119852063`
- `CRC32("map/zichen1/island.dat") == 1219710014`
- `CRC32("map/zichen1/jumpblock.dat") == 3304968779`
- `CRC32("map/zichen1/island2.dat") == 612635242`

这条规则一旦命中，就是“精确恢复”，不是候选推断。

## 2. 参与 CRC 的路径字符串

### 2.1 当前已确认的形式

- 使用相对路径，不带磁盘盘符
- 使用正斜杠 `/`
- 以资源根下的逻辑路径为准
- 对当前 MT3 已命中的地图资源，叶子名使用当前包内实际大小写
  - 已验证样本中为：
    - `regiontypeinfo.dat`
    - `jumpblock.dat`
    - `island.dat`
    - `island2.dat`

也就是说，当前这条规则不是：

- 不是绝对路径
- 不是 `E:/.../map/...`
- 不是带前导 `/` 的 `/map/...`
- 不是把目录名再额外 lower/upper 后重新猜一个字符串

### 2.2 工具里的计算入口

当前项目里可复用的 CRC 计算入口主要有两类：

1. `SLJFP::Unpacker`
   - 在后处理恢复阶段用 `m_crc32Func(0, path.data(), path.size())`
2. `SLJFP::PathMappingGenerator`
   - 使用 `CalculatePathCRC32()`

只要传入的路径字符串一致，两处算出来的值应一致。

## 3. 为什么这条规则重要

LJFilePack 索引本身只保存 `PathFileNameCRC32`，不保存原始路径字符串。

所以恢复真实路径，本质上是在做两步：

1. 想办法拿到“可能的真实路径字符串”
2. 再用这条 CRC 规则做精确校验

只有第 2 步命中，工具才应该把数字文件移动到真实路径。

## 4. 当前在解包工具里的落地方案

### 4.1 落地点

当前规则已经落在 `Unpacker::PostProcessRestoredOutputs()` 的地图恢复链里。

核心做法是：

1. 先把 `table/bintable/map.cmapconfig.bin` 恢复出来
2. 再按真实表结构解析每一行 `resdir`
3. 对每个 `resdir` 直接生成固定叶子名路径：
   - `map/<resdir>/maze.dat`
   - `map/<resdir>/monster.dat`
   - `map/<resdir>/goto.dat`
   - `map/<resdir>/regiontypeinfo.dat`
   - `map/<resdir>/npc.dat`
   - `map/<resdir>/jumpblock.dat`
   - `map/<resdir>/island.dat`
   - `map/<resdir>/island2.dat`
4. 对每个候选路径直接计算 CRC
5. 若命中当前 root numeric 文件，就直接搬运并注册到 `m_pathMapping`

### 4.2 为什么这次要改成“结构化解析 `map.cmapconfig.bin`”

旧逻辑主要靠从 `.bin` 文本 token 里猜 `resdir`，只对“数字开头带下划线”的目录名比较友好。

这样会漏掉：

- `zichen1`
- `map_1601_yunmengze`
- `fengdushichonglian_1`

这些真实目录名虽然就写在 `map.cmapconfig.bin` 里，但如果只靠 token 启发式，恢复率会明显受限。

现在改成直接按真实表结构读 `resdir` 字段后，CRC 直命中可以稳定覆盖这类路径。

## 5. 当前已验证的复用场景

### 5.1 地图资源固定叶子名

这是当前最稳定的一类：

- `map/<resdir>/regiontypeinfo.dat`
- `map/<resdir>/jumpblock.dat`
- `map/<resdir>/island.dat`
- `map/<resdir>/island2.dat`

已确认可直接用于：

- `map_1601_shamo`
- `map_1888_shuiliandong`
- `map_1889_pansidong`
- `map_1601_yunmengze`
- `zichen1..10`

### 5.2 任何“已知真实路径模板”的资源

这条规则并不只适用于地图。

只要满足：

1. 我们已经知道真实路径模板
2. 包里保存的是该路径的 `PathFileNameCRC32`

那就都可以复用这条方案。

例如：

- `table/bintable/<group>.<table>.bin`
- `ui/layouts/<name>.layout`
- `effect/geffect/...`
- `model/...`

区别只在于“真实路径模板从哪里来”。

## 6. 边界与风险

### 6.1 不能把“CRC 可计算”误解成“路径已知”

CRC 规则只负责校验，不负责凭空发明路径。

如果当前只有数字文件名，没有真实路径模板，就不能反推出原始路径。

因此正确流程永远是：

1. 先从配置表、客户端代码、已恢复目录、注册表、XML/Lua、manifest 等地方拿路径模板
2. 再拿 CRC 去验

### 6.2 大小写和斜杠必须和真实打包路径一致

CRC 对字符串逐字节敏感，所以：

- `map/zichen1/island.dat` 和 `map/zichen1/Island.dat` 不一样
- `map/zichen1/island.dat` 和 `/map/zichen1/island.dat` 不一样
- `map\\zichen1\\island.dat` 也不一样

工具内部统一使用正斜杠路径做计算，且优先使用已经从配置/源码确认过的真实大小写。

### 6.3 这条规则不能替代候选分层

对没有直接路径模板的残留，仍然应该留在：

- family candidate
- pair candidate
- unresolved

不能因为“看起来像某个目录”就直接搬运。

## 7. 推荐使用方式

### 7.1 在解包工具内部

优先走：

1. `forceCrcOutputFirst = true`
2. `restorePathStructureAfterUnpack = true`
3. 在后处理阶段从已恢复配置/代码锚点生成真实路径模板
4. 用 CRC 规则直接命中并落盘

### 7.2 在外部脚本/报告里

如果要做离线核对，建议统一使用：

```text
CRC32("逻辑相对路径")
```

并把“路径字符串本身”连同 CRC 一起写进报告，避免只保留数字结论。

## 8. 本次接入后的实际收益

本次把这条规则正式接进 `SuperLJFilePackUnpack` 后，工具已经可以直接复用它完成：

- `zichen1..10` 的 `island / jumpblock / island2` 精确回流
- `map_1601_yunmengze` 的 `regiontypeinfo / island` 精确回流

也就是说，这条规则现在已经不再只是会话级人工经验，而是工具内可重复执行的正式能力。
