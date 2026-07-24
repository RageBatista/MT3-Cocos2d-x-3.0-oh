# 资源恢复问题处理手册

## 1. 数字文件名仍大量存在

现象：

- 解包后根目录或子目录仍是大量数字文件

优先检查：

- 是否有 `unpack_path_manifest.tsv/json`
- 是否已有 mapping / seed / merged mapping
- 当前路径 CRC 规则是否与打包端一致

处理策略：

1. 先补 mapping seed，不直接猜路径。
2. 先过滤低置信路径，避免把错误 mapping 写大。
3. 命中率仍低时，再去客户端代码、`auto`、已恢复树里补证据。

## 2. review/unresolved 长期不下降

现象：

- 每次恢复后 `unresolved` 数量变化不大

高频根因：

- 重复内容没剥离
- 错扩展文件仍被当作独立未知文件
- 候选已经很强但仍躺在 `unresolved`

处理策略：

1. 先跑“唯一精确同内容”分流。
2. 再跑“多命中歧义同内容”分流。
3. 再做强信号扩展修正。
4. 最后把 `sound.inf`、地图配置、模型上下文这类条目提升成候选目录。

## 3. 二进制表无法直接读出结构

现象：

- `tabledef` 读不通
- 字段数量不对
- 某一行开始报错

处理策略：

1. 先确认是否有客户端 C++ `GameTable` 结构。
2. 再确认 `auto` XML 是否覆盖同一张表。
3. 若只有前半段能读，先把成功行导出，再记录失败 offset。
4. 若是多变体表，按“legacy / rank / drift”拆 schema。

质量要求：

- 报告必须保留 parse error、remaining bytes、成功行数。

## 4. 模型目录有 `ride*.lmx`，但没有真实坐骑目录

现象：

- 只看到 `ride1/ride2/ride3/ride4.lmx`
- `ridemodel` 有编号，但实体目录没恢复出来

处理策略：

1. 先抽 `ridemodel -> model/layer` 上下文映射。
2. 再用引擎 `GetLayerRideEnable / GetComponent / SetRideName` 推导共享路径形态。
3. 若 `unresolved` 里没有实体 payload 命中，就只提升上下文映射，不伪造目录。

质量要求：

- 明确区分“上下文已知”和“实体资源已恢复”。

## 5. XML 内容可读，但路径不明

典型类型：

- `ui/layouts/*.layout`
- `model/*/sound.inf`
- `map/*/npc.dat`
- `map/*/goto.dat`

处理策略：

1. 先看根节点和关键字段：
   - `GUILayout` / `Window Name`
   - `component / act / su0`
   - `record id / posx / posy`
   - `item destmap / destx / desty`
2. 再去现有主树做内容比对：
   - 字节完全一致
   - 规范化 XML 一致
   - 结构模式一致
3. 唯一命中时直接回流或提升候选。
4. 多命中时放到歧义别名，不强并主树。

## 6. 目标路径已存在，但内容冲突

现象：

- 同一路径的“修正扩展名”准备写入时，发现目标已存在不同内容

处理策略：

1. 不覆盖。
2. 报告为 `exists_conflict`。
3. 把冲突项列成下一轮单独 backlog。

质量要求：

- 不允许为了压数量而覆盖主树现有文件。

## 7. sound.inf 候选如何处理

高置信信号：

- `component name`
- `act an`
- `/sound/monster/*.ogg`
- 模型目录结构是否支持该 component

处理策略：

1. 若证据足够强但主树里没有稳定落点，提升到 `recovered_soundinf_candidates`
2. 写清：
   - 候选路径
   - 置信度
   - 证据
   - 为什么没直接并入主树

## 8. 地图 XML / DAT 如何处理

处理优先级：

1. 内容完全命中现有 `npc.dat / goto.dat`
2. 可为现有 `.dat` 生成只读 `.xml` 副本
3. 若只知道记录组，但不知道地图名，先保留为地图配置候选

注意：

- 地图条目经常会跨多个楼层或副本复用相同内容
- 遇到多地图同内容时，不要假装唯一恢复

## 9. 什么情况下可以并入主资源树

满足其一即可考虑：

- 路径 CRC 精确命中
- 内容与现有正确路径唯一一致
- 文件头 / 文本结构强信号足够明确
- 客户端代码 / `auto` / 表定义共同指向同一目标

## 10. 什么情况下只能保持候选

- 只有语义，没有实体 payload
- 内容一致但路径多命中
- 模型共享组件无法唯一落地
- sound / map / table 只恢复到“结构正确”但还没有唯一目标路径
