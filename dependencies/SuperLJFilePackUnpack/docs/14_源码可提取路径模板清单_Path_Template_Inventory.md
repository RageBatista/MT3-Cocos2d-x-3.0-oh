# 源码可提取路径模板清单

> 基准日期: 2026-04-23
> 适用范围: `dependencies/SuperLJFilePackUnpack` 当前源码、文档与已验证恢复链

## 1. 结论

“真实路径模板”可以分成三类：

1. **源码可直接给出完整模板**
   - 例如：`map/<resdir>/regiontypeinfo.dat`
   - 这类最适合直接做 `CRC32("真实相对路径")` 精确命中
2. **源码只能给出模板骨架，变量要从配置/文本/运行时语料补齐**
   - 例如：`model/<name>/<name>.atlas`
   - 这类适合“源码规则 + 配置表/脚本文本”组合恢复
3. **源码只能告诉你 CRC 规则，拿不到路径名集合本身**
   - 例如纯目录扫描进入打包器、索引里只存 `PathFileNameCRC32` 的资源
   - 这类必须依赖外部语料、参考资源树、配置表或运行时锚点

所以对“真实路径模板如何获取”这个问题，正确答案不是单一的“靠打包器源码”或“完全靠外部语料”，而是：

```text
打包器源码给 CRC 规则 + 客户端源码给路径拼接模板 + 配置/文本语料补变量 + CRC 做精确命中
```

## 2. 仅靠打包器源码能拿到什么

从当前已整理的打包/逆向对照文档可确认：

- 打包器确实使用真实相对路径字符串生成 `PathFileNameCRC32`
- 但索引里只保留 `PathFileNameCRC32`，不保留原始路径字符串
- 因此打包器源码本身通常只能回答：
  - CRC 输入规则是什么
  - 路径在进入 CRC 前做了哪些规范化
  - 某些硬编码模板如何构造

参考：

- [10_原始打包-逆向解包对照分析__Pack_Unpack_Correspondence_Report.md](10_原始打包-逆向解包对照分析__Pack_Unpack_Correspondence_Report.md)
- [13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md](13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md)

## 3. 源码可提取模板的分层

### 3.1 A 类：源码可直接给出完整模板

这类模板在源码里已经写成固定前后缀，恢复时只需要补一个小变量集合，甚至变量集合也来自同一份结构化表。

#### 3.1.1 地图固定叶子名

来源：

- [SLJFP_Unpack.cpp](../src/SLJFP_Unpack.cpp) 中 `map.cmapconfig.bin` 恢复链
- [05_解包算法_Unpacking_Algorithm.md](05_解包算法_Unpacking_Algorithm.md)

当前已实现的固定叶子名：

| 模板 | 变量来源 | 当前状态 |
| --- | --- | --- |
| `map/<resdir>/maze.dat` | `map.cmapconfig.bin` | 工具已接入 |
| `map/<resdir>/monster.dat` | `map.cmapconfig.bin` | 工具已接入 |
| `map/<resdir>/goto.dat` | `map.cmapconfig.bin` | 工具已接入 |
| `map/<resdir>/regiontypeinfo.dat` | `map.cmapconfig.bin` | 工具已接入 |
| `map/<resdir>/npc.dat` | `map.cmapconfig.bin` | 工具已接入 |
| `map/<resdir>/jumpblock.dat` | `map.cmapconfig.bin` | 工具已接入 |
| `map/<resdir>/island.dat` | `map.cmapconfig.bin` | 工具已接入 |
| `map/<resdir>/island2.dat` | `map.cmapconfig.bin` | 工具已接入 |

说明：

- 这类模板已经非常适合直接做路径 CRC 精确恢复
- 当前 `SuperLJFilePackUnpack` 里已经用这条链恢复了：
  - `map_1601_yunmengze`
  - `zichen1..10`
  - `map_1601_shamo`
  - `map_1888_shuiliandong`
  - `map_1889_pansidong`

#### 3.1.2 固定注册表路径

来源：

- [SLJFP_Unpack.cpp](../src/SLJFP_Unpack.cpp) 中 `kKnownPaths`

当前硬编码样本：

| 模板 | 状态 |
| --- | --- |
| `table/bintable/battle.cbattleaiconfig.bin` | 已实现 |
| `table/bintable/map.cmapconfig.bin` | 已实现 |
| `table/bintable/effectpath.ceffectpath.bin` | 已实现 |
| `table/bintable/effectpath.ceffectpathnonedrama.bin` | 已实现 |
| `table/bintable/EffectPath.ceffectpathnonedrama.bin` | 已实现 |
| `table/bintable/battle.cstageinfo.bin` | 已实现 |
| `table/bintable/role.createroleconfig.bin` | 已实现 |
| `table/bintable/npc.cnpcshape.bin` | 已实现 |
| `table/bintable/npc.cactioninfo.bin` | 已实现 |
| `table/bintable/npc.cride.bin` | 已实现 |
| `model/sprites.set` | 已实现 |
| `model/actiontype.set` | 已实现 |

这类路径不需要额外语料，源码本身就是模板字典。

### 3.2 B 类：源码能给模板骨架，变量要从内容语料补

这类是当前最常见、最有价值的一层。

#### 3.2.1 表定义与表二进制

来源：

- `GetTableByName("分类.表名")`
- `script/tabledef/<分类>/<表名>.lua -> table/bintable/<分类>.<表名>.bin`
- [SLJFP_Unpack.cpp](../src/SLJFP_Unpack.cpp) 中 `GetTableByName` / `script/tabledef` 规则

模板：

| 模板 | 变量来源 |
| --- | --- |
| `table/bintable/<group>.<table>.bin` | Lua / 文本中的表名 |
| `script/tabledef/<group>/<table>.lua` | 表名反推 |

#### 3.2.2 UI 资源

来源：

- `*.layout` 字面量
- `set:<imageset>`
- `Font` / `Imageset` / `GUIScheme` / `Falagard` 根节点名
- [SLJFP_Unpack.cpp](../src/SLJFP_Unpack.cpp) 中 UI 规则

模板：

| 模板 | 变量来源 |
| --- | --- |
| `ui/layouts/<name>.layout` | Lua/UI 文本中的 layout 名 |
| `ui/imagesets/<name>.imageset` | `set:` 或根节点名 |
| `ui/fonts/<name>.font` | Font 名 |
| `ui/schemes/<name>.scheme` | Scheme 名 |
| `ui/looknfeel/<name>.looknfeel` | Falagard / looknfeel 名 |

#### 3.2.3 Spine 资源

来源：

- `spine/foo/bar`
- `UISpineSprite:new("foo")`
- `SetSpineModel("foo")`
- `spine_effect.set`
- `role.createroleconfig.bin`

模板：

| 模板 | 变量来源 |
| --- | --- |
| `effect/spine/<path>.atlas` | `spine/<path>` 注册名 |
| `effect/spine/<path>.json` | `spine/<path>` 注册名 |
| `model/<name>/<name>.atlas` | Spine model 字面量/配置表 |
| `model/<name>/<name>.json` | Spine model 字面量/配置表 |
| `model/<name>/<page>.png` | atlas 页名 |

#### 3.2.4 模型资源

来源：

- `model/sprites.set`
- `model/actiontype.set`
- `npc.cnpcshape.bin`
- `npc.cactioninfo.bin`
- `npc.cride.bin`
- `layerdef.lmx`
- `action.lmx`

模板：

| 模板 | 变量来源 |
| --- | --- |
| `model/<name>/action/action.lmx` | 模型名 |
| `model/<name>/layerdef.lmx` | 模型名 |
| `model/<name>/dyeinfo.dye` | 模型名 |
| `model/<name>/action/<action>.act` | 模型名 + 动作名 |
| `model/<name>/body/<part>/<action>.ani` | 模型名 + body 部件 + 动作 |
| `model/<name>/weapon/<part>/<action>.ani` | 模型名 + weapon 部件 + 动作 |
| `model/mt_zuoqi/ride1/<id>/<riding_action>.ani` | 坐骑 id + riding 动作 |

#### 3.2.5 特效资源

来源：

- `geffect/...`
- `animation/...`
- `r_f="animation/..."`
- `effect/animation/skill/<family>/...`

模板：

| 模板 | 变量来源 |
| --- | --- |
| `effect/geffect/<path>.eff.inf` | `geffect/...` 注册名 |
| `effect/animation/<path>.ani` | `animation/...` 引用 |
| `effect/particle/path/<name>.path` | `.path` 字面量 |
| `effect/particle/texture/<name>` | 粒子贴图引用 |
| `effect/animation/skill/accN-<family>/<leaf>.ani` | 技能 family 别名扩展 |

### 3.3 C 类：源码只能给 CRC 规则，拿不到路径名集合

这类情况的典型特征是：

- 打包端只是扫描资源目录
- 扫到什么文件就直接把真实路径做 CRC
- 源码里没有单独的注册表或硬编码字符串表

这种情况下，打包器源码最多只能给出：

- 路径如何规范化
- 哪些根目录会被扫描
- 是否 lower-case
- 是否统一 slash
- 是否跳过空文件

但拿不到：

- 当时磁盘上到底有哪些真实文件名
- 哪些目录名是真实项目里实际存在的

所以这类必须靠外部语料：

- 参考资源树
- 配置表
- 客户端加载代码
- XML/Lua
- auto 文件
- 旧版本客户端
- 运行时/审计产物

## 4. 当前最值得优先提取的模板来源

按投入产出比排序，建议优先级如下：

1. **客户端运行时硬拼接路径**
   - 收益最高
   - 一旦拿到就是高置信模板
2. **结构化配置表**
   - 例如 `map.cmapconfig.bin`
   - 能直接提供变量集合
3. **注册表与集合文件**
   - `sprites.set`
   - `spine_effect.set`
   - `actiontype.set`
4. **文本中的显式字面量**
   - `GetTableByName(...)`
   - `SetSpineModel(...)`
   - `*.layout`
   - `geffect/...`
5. **目录扫描型打包源码**
   - 主要用于确认 CRC 规范
   - 不应指望它单独给出完整语料

## 5. 对“能否通过打包工具源码分析得到”的直接回答

### 5.1 可以得到的

- `PathFileNameCRC32` 的计算规则
- 参与 CRC 的路径字符串格式
- 路径规范化规则
- 某些硬编码路径模板
- 某些固定注册表路径

### 5.2 不能单独得到的

- 完整真实路径名词表
- 所有目录名集合
- 所有实例化后的 `<resdir>` / `<name>` / `<table>` / `<family>` 值

### 5.3 正确理解

更准确的说法是：

```text
打包工具源码分析可以提供“模板规则”和“CRC 校验机制”，
但通常不能单独提供“完整真实路径语料”。
```

## 6. 当前工具里已验证可复用的模板获取方案

以当前 `SuperLJFilePackUnpack` 为准，最稳定的获取链是：

1. 从源码/文档拿到模板骨架
2. 从配置/文本/已恢复结果里拿到变量
3. 生成候选真实路径
4. 用 `CRC32("真实相对路径")` 精确命中
5. 命中后注册到 `m_pathMapping`，形成后续可复用映射

这条链已经被实际验证过：

- `zichen1..10`
- `map_1601_yunmengze`
- `map_1601_shamo`
- `map_1888_shuiliandong`
- `map_1889_pansidong`

## 7. 推荐的后续工作方式

### 7.1 做“模板字典”，不要做“猜名脚本”

优先沉淀：

- 模板类别
- 变量来源
- CRC 输入规范
- 成功样例

而不是上来就扩大猜测空间。

### 7.2 每新增一类模板，都要补三件东西

1. 来源锚点
   - 哪段源码或哪张表
2. 变量来源
   - 配置表 / 文本 / 已恢复目录 / 运行时代码
3. 验证方式
   - `CRC32("真实路径") == PathFileNameCRC32`

### 7.3 对仍无语料的残留，保持候选分层

如果当前只有：

- CRC 规则
- 但没有路径变量

那就应该留在：

- family candidate
- pair candidate
- unresolved

而不是因为“源码里有一条类似规则”就直接落盘。
