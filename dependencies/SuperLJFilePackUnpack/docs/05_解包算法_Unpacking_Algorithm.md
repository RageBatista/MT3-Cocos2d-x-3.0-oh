# 05 解包算法

> 基准日期: 2026-03-13
> 以 `src/SLJFP_Unpack.cpp` 为准

## 1. 总体流程

`Unpacker` 的真实解包链路可以分为五段：

1. 索引解析
2. 路径映射准备
3. 读取源数据
4. 解密/解压/校验
5. 路径构建与写出

## 2. 索引加载算法

### 2.1 入口

```text
LoadIndex(indexPath)
  -> 判断扩展名是否包含 ".ljzip"
  -> LoadLjzipIndex() 或 LoadLjpiIndex()
```

### 2.2 `.ljpi`

`.ljpi` 加载是顺序流读取：

```text
read FileCount
repeat count:
  parse FileEntry
  push to m_fileList
  accumulate m_totalBytes
```

### 2.3 `.ljzip`

`.ljzip` 加载包含模式候选重试：

```text
read magic / size / payload / footer
build decrypt candidates
for each mode:
  decrypt
  decompress
  verify CRC32 if enabled
  if success -> ParseLjpiData()
```

当前 `Auto` 模式不是“神奇自适应”，而是固定候选顺序：

1. `LJFilePackSMS4`
2. `ApkClientObf`

## 3. 单文件解包算法

### 3.1 入口选择

```text
UnpackSingleFile()
  if useStreamMode:
    try stream path
    if not safe / not complete:
      fallback to normal path
  normal path:
    ReadFileData()
    DecryptAndDecompress()
    verify CRC32
    BuildOutputPath()
    write file
```

### 3.2 源文件定位

当前实现没有复杂资源查找器，只有两条规则：

- `m_PackIndex == 0`
  - `<inputDir>/<PathFileNameCRC32>`
- `m_PackIndex > 0`
  - `<inputDir>/<PackIndex>.ljfp`

## 4. 解密算法选择

### 4.1 候选生成

`BuildDecryptCandidates()` 的实际用途是：

- 需要解密时，根据 `DecryptMode` 生成一个候选列表
- 普通解包路径允许逐个候选尝试
- 流式路径为了避免状态不可回滚，不支持自动重试

### 4.2 普通路径

普通路径中会：

1. 读完整输入
2. 尝试一个解密模式
3. 若失败则尝试下一个
4. 若成功且启用了 CRC32，再核对原始 CRC32

### 4.3 流式路径

流式路径下，以下情况直接回退普通路径：

- 需要解密且 `decryptMode == Auto`
- 加密数据块不是 16 字节对齐
- 压缩流解压过程中出现异常状态

## 5. `DecryptAndDecompress()` 真实逻辑

伪代码如下：

```text
if needDecrypt:
  decrypt to temp buffer

if needDecompress:
  allocate output buffer by originalSize or guessed size
  try uncompress
  if MZ_BUF_ERROR:
    enlarge buffer and retry
  retry up to 10 times
else:
  copy currentData to finalData
```

关键事实：

- 最大解压大小硬限制为 `100MB`
- 重试仅针对 `MZ_BUF_ERROR`
- 不是流式 inflate，这里是完整缓冲区路径

## 6. 输出路径构建算法

`BuildOutputPath()` 的优先级非常关键：

### 6.1 路径映射优先

如果：

- `preferPathMapping=true`
- `m_pathMapping` 命中 `m_PathFileNameCRC32`

则直接使用映射路径，且会把 `\` 统一为 `/`。

### 6.1.1 命中不足时的自动补推断

若已加载映射但命中率仍低于索引总数，`InferPathMappingFromStage1Output()` 会对阶段一的 CRC 输出做最多 `3` 轮扫描：

1. 抽取带 `/` 的显式资源路径
2. 抽取 Lua 模块名并尝试补成 `script/...`
3. 若当前 CRC 已有已知路径，再利用该路径的目录上下文补裸文件名

当前已实现的上下文补推断重点覆盖：

- `ui/schemes/*.scheme` 中的 `*.imageset / *.font / *.looknfeel`
- `ui/imagesets/*.imageset` 中的 `Imagefile="*.png|*.jpg|*.tga|..."`
- `ui/fonts/*.font` 中的 `Filename="*.ttf|*.otf"`
- `effect/animation/ui/**/*.ani` 中的同目录帧图片引用
- 未命名 `GUILayout` 中首个根窗口 `Name` 对应的 `ui/layouts/<root>.layout`
- 未命名 `Imageset` / `Font` / `GUIScheme` 根节点 `Name` 对应的 `ui/imagesets/<name>.imageset`、`ui/fonts/<name>.font`、`ui/schemes/<name>.scheme`
- UI Layout/XML 中 `set:foo` 形式的 imageset 名称

多轮扫描的作用是允许链式恢复，例如：

```text
layout root -> layout
layout set  -> imageset -> png
imageset    -> imageset -> png
scheme name -> scheme -> imageset -> png
scheme -> imageset -> png
font name -> font -> ttf
ani    -> sibling png frame
```

注意：

- 该阶段会优先恢复“包内还留有文件名线索”的资源
- 对模型链会额外利用 `model/sprites.set` 和固定目录规则做确定性 CRC 反推，不依赖原始目录树
- 纯图片、纯二进制数据、以及无根窗口名/无 `set:` 线索的 `GUILayout` 仍可能只能保留 CRC 输出
- 若仍有未命名 CRC 文件残留，且 `detectFileType=true`，会进入阶段三仅补后缀，不改目录结构

### 6.1.2 阶段三后缀补全

当阶段二结束后仍存在 `123456789` 这类未命名文件时，`RestoreDetectedExtensionsForStage1Outputs()` 会：

1. 逐个检查阶段一输出目录中仍保留为 CRC 名的实际文件
2. 仅读取残留 CRC 文件的前缀字节
3. 优先按内容语义补专用 UI 后缀：
   - `<GUILayout ...>` -> `.layout`
   - `<Imageset ...>` -> `.imageset`
   - `<Font ...>` -> `.font`
   - `<GUIScheme ...>` -> `.scheme`
   - `<Falagard ...>` -> `.looknfeel`
4. 对模型链已确认的二进制结构优先补专用后缀：
   - `Action::marshal()` 版本头 -> `.act`
   - `PAniPack::VERSION` 版本头 -> `.ani`
   - `DYEP` 魔数 -> `.dye`
5. 对已确认的 MT3 自定义头标识继续补专用后缀：
   - `MRMP` -> `.mrmp`
   - `RMAP-` -> `.rmp`
   - `QUYU` -> `.dat`
   - `LDZY` -> `.bin`
6. 对已确认的地图二进制结构补 `.dat`：
   - `MMHeader { hsize=12, width, height }` 且文件总长满足 `12 + width * height` 的迷宫网格 -> `maze.dat` 同类 `.dat`
   - `headfile=16, width, height, count` 且文件总长满足 `16 + count * 8` 的怪物点位表 -> `monster.dat` 同类 `.dat`
7. 对标准 TGA 图像补 `.tga`：
   - 头部 `imageType` 命中 `1/2/3/9/10/11`
   - 宽高与像素位深落在合理范围
   - 尾部带 `TRUEVISION-XFILE.` 标准签名
8. 对粒子主配置二进制补 `.ptc`：
   - 文件头首个版本值位于低位范围
   - 内容同时携带 `D3DTOP_ / D3DBLEND_ / D3DTADDRESS_` 混合模式字符串
   - 且至少引用一个粒子贴图或路径（如 `.png / .dds / .path`）
9. 对纯文本残留继续做轻量语义探测：
   - `require "utils.binutil"` / `Openui = {}` 这类 Lua 文本 -> `.lua`
   - `Microsoft Visual Studio Solution File` 且引用 `.luaproj` -> `.luaproj`
   - `import os` 且引用 `os.path` -> `.py`
   - `Index: xxx.lua / --- / +++` 这类补丁文本 -> `.patch`
   - 无空字节、控制字符占比很低，且呈现多行文本或 Windows 路径文本 -> `.txt`
   - `Setmap id=... / CreateNpc id=... / Wait time=...` 这类剧情脚本 -> `.txt`
   - `[ClientSetting]` / `[LocalizedFileNames]` 这类分节配置文本 -> `.ini`
   - 首行贴图名 + `size/format/filter` 元信息的 Spine atlas -> `.atlas`
8. 若专用规则仍未命中，再回退到 `FileTypeDetector::DetectExtension()`
9. 将文件从 `123456789` 重命名为 `123456789.<ext>`

### 6.1.2.1 阶段四目录归位

当阶段三已经确认类型、但仍无法恢复原始基名时，会再做一轮“只恢复目录层级”的保守整理：

- 目前已接入 `.ptc`、地图扰动对象 `.dis`、地图连接物件 `.lko`
- 会把 `123456789.ptc` 归位为 `effect/particle/psl/123456789.ptc`
- 若二进制内部直接携带 `/map/elements/.../*.img`，会归位为 `map/distortionobjects/<basename>.dis`
- 若二进制内部直接携带 `/map/elements/.../*.set`，会归位为 `map/linkedobjects/<basename>.lko`
- 若 root `CRC.xml` 被识别为未命名 `GEffect` 主配置，且全部 `clip r_f` 都能稳定落到同一资源族目录，
  还会做一轮 canonical 归类：
  - `animation/skill/<dir>/* -> effect/geffect/skill/<dir>/CRC.eff.inf`
  - `animation/number/<dir>/* -> effect/geffect/number/<dir>/CRC.eff.inf`
  - `animation/ui/<dir>/* -> effect/geffect/ui/<dir>/CRC.eff.inf`
  - `animation/sence/<dir>/* -> effect/geffect/sence/<dir>/CRC.eff.inf`
  - `animation/sprite/<dir>/* -> effect/geffect/sprite/<dir>/CRC.eff.inf`
  - `animation/sprite/<leaf> -> effect/geffect/sprite/CRC.eff.inf`
  - 该步骤只修正目录，不恢复真实叶子名；文件名仍保留 `CRC`
- 若 root `CRC.atlas / CRC.json` 被识别为未命名 Spine 资源，且内容里已能稳定暴露模型 stem，
  还会做一轮 canonical `model/` 目录归类：
  - 对 `CRC.ani`：
    - 先解析内部 `strPicPathPrefix + strPicPath` 组合出的图片 token
    - 再与当前已恢复模型链中的动画基路径逐一比对；只有当这些图片 token 只能唯一落到一个 `model/.../<stem>` 时，
      才保守归位到对应 `model/.../CRC.ani`
    - 若当前 CRC 同时精确命中该动画基路径对应的 `<stem>.ani`，则恢复标准叶子名；否则继续保留 `CRC.ani`
  - 对 `CRC.atlas`：
    - 先解析 atlas 首个页图文件名，提取形如 `spine_createrole_nvde.png -> spine_createrole_nvde` 的模型 stem
    - 若当前 CRC 精确命中 `model/<stem>/<stem>.atlas`，则恢复为标准叶子名
    - 否则保守归位为 `model/<stem>/CRC.atlas`
  - 对 `CRC.json`：
    - 先在 JSON 文本里抽取唯一的显式 `spine_*` 模型名
    - 若当前 CRC 精确命中 `model/<stem>/<stem>.json`，则恢复为标准叶子名
    - 否则保守归位为 `model/<stem>/CRC.json`
    - 若 JSON 不带唯一 `spine_*` 模型名，则继续提取 `attachment` 集合，与已恢复 `model/*.atlas` 的 region 集合做 100% 覆盖比对
    - 只有当所有满覆盖 atlas 候选都落在同一个 `model/<dir>/` 时，才保守归位到该目录
    - 归位后仍会先验证 `model/<dir>/<dir>.json` 的路径 CRC；只有精确命中才恢复标准叶子名，否则保留 `model/<dir>/CRC.json`
    - 若索引顺序里 `CRC.json` 先于对应 `CRC.atlas` 出现，阶段四会在 atlas 归位后自动刷新 atlas signature 并重试一次，
      避免因为 atlas 签名缓存加载过早而漏掉本可确认目录的 Spine JSON
  - 若 atlas 页图文件名还能精确命中 `model/<stem>/<page>.png|jpg|dds|webp` 的路径 CRC，
    页图也会一并恢复到相同目录
  - 若命令行额外启用 `--review-aliases`，对于已经确认目录但叶子仍保留数字的
    `model/<dir>/CRC.atlas|json`，阶段四会再复制一份 `model/<dir>/<dir>.atlas|json`
    作为人工核对别名；原始 CRC 文件不会删除
  - 同一模式下，阶段四还会扫描这些 `model/*.atlas` 的首页页图文件名与页尺寸，输出
    `review_alias_model_pages.txt` 作为人工核对报告
  - 若某个缺失页图只对应到“唯一一个”root 数字 `png` 尺寸候选，会额外复制一份
    `model/<dir>/<page>.png` 作为核对别名；root 下原数字 `png` 继续保留
  - 若某个缺失页图存在多个等尺寸 root 数字 `png` 候选，会把这些候选额外复制到
    `model/<dir>/_review/<page-stem>.candidate.<crc>.png`，用于就地人工核对
  - 同一模式下，阶段四还会扫描剩余 root 数字 `CRC.ani`，提取其
    `version/fileFormat/textureFormat/playTime/regionCount/frameCount/directionMode + 文件长度 + UTF-16 图片令牌`
    组成结构签名，再与已恢复 `model/*.ani` 的签名做比对
  - 若结构签名只能唯一命中某个模型尾路径，例如 `body/bodyonly/stand3.ani`，
    会额外复制一份 `review/model_ani/body/bodyonly/stand3.candidate.<crc>.ani`
  - 若尾路径仍不唯一，但叶子文件名唯一，例如只剩 `attack1.ani` 一种候选，
    会保守写出 `review/model_ani_leaf/attack1.candidate.<crc>.ani`
  - 这条 `review alias model ani` 链除了消费已恢复的 `model/*.ani`，
    还会额外读取 `table/bintable/npc.cnpcshape.bin` 与 `table/bintable/npc.cactioninfo.bin`
    中可识别的模型目录名，把它们作为外部命名源参与 `model/<dir>/<tail>.ani` 的精确 CRC 命中
  - 上述 `npc` 外部命名源现在按真实 `LDZY` 二进制表结构解析，
    直接读取 `shape/model + attack/magic/...` 字段，不再只依赖二进制里的裸 token；
    因此像 `mushi`、`denglu` 这类没有 `-/_` 分隔符的模型目录名也可以稳定参与 exact restore
  - 若某个 root `CRC.ani` 在“结构签名 + 外部模型目录名”双重约束下只剩唯一精确命中，
    阶段四会直接把它恢复为真实 `model/<dir>/<tail>.ani`，而不是仅写 review 别名
  - 当这类 `exact_restore` 成功后，阶段四会立刻继续解析该 `ani` 的
    `strPicPathPrefix + strPicPath`，并对同目录 `_resNNN.png/.dds/.tga/.jpg/.jpeg`
    做一轮即时补扫；这样新恢复出来的 `model/*.ani` 可以在同一轮继续带出模型贴图
  - 若某个 root `CRC.ani` 暂时还只能写成 `review/model_ani*`，但其候选尾路径已经收敛到
    `tail_alias / leaf_alias`，阶段四会继续基于这些候选尾路径枚举
    `model/<dir>/..._resNNN.png/.dds/.tga/.jpg/.jpeg`，并对 root 数字贴图做精确 CRC 命中；
    只有命中真实完整路径时，才会把这类贴图直接恢复到对应 `model/...` 目录
  - 若该 root `CRC.ani` 还停留在 `ambiguous`，阶段四会退回到“同结构签名下已命名
    `model/*.ani` 的实际完整路径”集合，继续对其贴图做一次精确 CRC 探测；这一步只恢复
    已被完整路径证明正确的 `model/..._resNNN.*`，不会据此直接改写原始 `ani` 的命名
  - 这批 `review_alias_model_ani.txt` / `review/model_ani*` 输出只服务人工核对，
    不会回写路径映射，也不会参与后续 root CRC 去重
  - 这些 review alias 不参与后续 root CRC 去重，因此只作为人工核对锚点，不会触发删除原始数字文件
  - 与 `GEffect` canonical 归类相同，这一步默认只修正目录层级；除非 CRC 已经证明标准叶子名正确，否则不做猜测性重命名
- 不伪造原始文件名，不改现有 debug/映射机制
- 若未来拿到更强的文件名线索，仍可继续在此基础上做更精确的路径恢复

### 6.1.2.2 阶段五地图配置驱动恢复

若残留 `.bin` 中命中了 `table/bintable/map.cmapconfig.bin` 的真实表结构：

1. 先把该文件自身归位为 `table/bintable/map.cmapconfig.bin`
2. 优先按真实表结构直接解析每一行的 `resdir`
   - 当前已确认字段顺序与客户端 `BINUtil:LoadBeanFromBinFile()` 一致
   - 不再只依赖“从文本 token 里猜 `resdir`”的启发式
   - 这一步可覆盖 `zichen1`、`map_1601_yunmengze`、`fengdushichonglian_1`
     这类“不以数字开头”的真实目录名
3. 额外从当前已解包内容里抽取 `map/elements/<resdir>/...` token，补入候选 `resdir`（主要来自 `CRC.bin / CRC.rmp / CRC.mrmp`，并覆盖 ASCII 与 UTF-16 LE 两种字符串布局，只做候选补充，不直接重命名）
4. 按客户端真实拼接规则批量尝试，并直接做路径 CRC 精确命中：
   - `map/<resdir>/map.rmp`
   - `map/<resdir>/maze.dat`
   - `map/<resdir>/monster.dat`
   - `map/<resdir>/regiontypeinfo.dat`
   - `map/<resdir>/goto.dat`
   - `map/<resdir>/npc.dat`
   - `map/<resdir>/jumpblock.dat`
   - `map/<resdir>/island.dat`
   - `map/<resdir>/island2.dat`
   - `map/<resdir>/mapeditor1..40.mrmp`（同时兼容索引中可能出现的 `MapEditorN.mrmp` 大小写变体，统一归位为 `mapeditorN.mrmp`）
5. 仅当 `CRC32("map/<resdir>/<leaf>") == PathFileNameCRC32` 时才移动文件
   - 这是一条“直接命中”规则，不是模糊候选
   - 一旦命中，解包器会把该路径注册进 `m_pathMapping`，后续轮次可直接复用
6. 若同 CRC 在 `m_pathMapping` 中已有映射且该映射目标文件已真实落盘，则保持现状跳过；若映射是“悬空目标”（目标文件不存在），阶段五允许接管并继续恢复
7. 若 `map.cmapconfig.bin` 已在前序阶段被恢复到 `table/bintable/`，阶段五会直接复用该已映射输出；若 `map.rmp` 已在阶段三先补成 `CRC.rmp`，`maze.dat / monster.dat / regiontypeinfo.dat / jumpblock.dat / island.dat / island2.dat` 已先补成 `CRC.dat`，`goto.dat / npc.dat` 因 XML内容先补成 `CRC.xml`，或 `mapeditor*.mrmp` 已先补成 `CRC.mrmp`，阶段五也会继续从这些已补后缀的文件上做最终归位

这一步完全依赖包内配置表与客户端固定命名规则，不依赖外部原始资源目录。

补充说明：

- 对 MT3 当前已验证的地图资源，参与 CRC 的是相对路径字符串本身，例如：
  - `map/map_1888_shuiliandong/regiontypeinfo.dat`
  - `map/map_1601_yunmengze/island.dat`
  - `map/zichen1/jumpblock.dat`
- 这条规则的详细边界、示例与复用方式见：
  - `13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md`


### 6.1.2.3 阶段六唯一精确重复归并

当阶段五结束后，root 目录仍残留 `CRC.png / CRC.ani` 这类文件时，`RestoreUniqueExactDuplicateOutputs()` 会做一轮保守去重：

1. 递归扫描当前输出目录
2. 仅收集：
   - root 下 numeric basename 的 `.png / .ani`
   - 已恢复到非 root 子目录中的 `.png / .ani`
3. 对每个文件计算 `(extension, size, content_crc32)` 签名
4. 仅当某个 root `CRC.<ext>` 与“一个且仅一个”已命名文件字节完全一致时，才删除 root 下的重复件
5. 若同签名命中多个已命名路径，或精确比对后并非唯一，则保留原 CRC 文件

设计边界：

- 该阶段不伪造新路径，不移动文件到猜测目录
- 它只消除“已被唯一解释”的重复内容簇，常见于 `model` 和 `effect` 下的重复 `ani/png`
- 因为这一步是在删除完全重复的 root 副本，最终输出目录中的文件总数可能小于索引条目数
- 若后续需要保留这些重复别名做人工核对，应以索引条目数和日志为准，而不是单纯以最终落盘文件数为准

### 6.1.2.4 阶段七冗余 root 重复件清理

阶段六结束后，仍可能存在一类 root `CRC.<ext>`：它们与多个已恢复命名文件字节完全一致，因此不会被“唯一命中”规则删除。`PruneRedundantRootExactDuplicateOutputs()` 会继续做一轮更偏清理用途的去重：

1. 递归扫描当前输出目录
2. 收集：
   - root 下 numeric basename 且已经带后缀的 `CRC.<ext>`
   - 已恢复到非 root 子目录中的所有命名文件
3. 对每个文件计算 `(extension, size, content_crc32)` 签名
4. 若某个 root `CRC.<ext>` 与至少一个已命名文件字节完全一致，则删除该 root 冗余副本
5. 若同内容命中多个已命名路径：
   - 视为“歧义重复件”
   - 仍删除 root 冗余副本
   - 在日志中记录统计和样例，方便人工核对这类“同内容多路径”资源簇

受控跨后缀别名：

- `CRC.xml -> *.lmx`
  - 典型是模型 `action.lmx / layerdef.lmx / <layer>.lmx` 的 XML 文本内容，被阶段三先按内容识别成 `.xml`
- `CRC.xml -> *.dat`
  - 典型是地图 `goto.dat / npc.dat` 这类 XML 内容配置
- `CRC.xml -> *.eff.inf`
  - 典型是特效主配置 XML，被阶段三先补成 `.xml`

设计边界：

- 该阶段不宣称已经恢复出该 root CRC 的“唯一原始路径”
- 它的作用是清掉“数据已经被命名副本完整覆盖”的 root 冗余件，缩小真正未恢复命名的待分析集合
- 典型受益对象包括：
  - `model` 下多角色/多时装共享的重复 `ani / png / act / dye`
  - `effect/animation/skill` 下基础目录与 `accN-<family>` 别名目录的同内容副本
  - `map` / `table` / `script` 中已存在命名副本的根目录残留

### 6.1.3 模型目录结构恢复

在进入通用 Token 推断前，会先做一轮“确定性模型路径展开”：

1. 从 `sprites.set` 中提取模型名表
2. 直接按固定路径尝试命中：
   - `model/<name>/action/action.lmx`
   - `model/<name>/layerdef.lmx`
   - `model/<name>/sound.inf`
   - `model/actiontype.set`
3. 从 `layerdef.lmx` 继续展开：
   - `model/<name>/dyeinfo.dye`
   - `model/<name>/<layer>/<layer>.lmx`
   - 坐骑层优先按 `model/<name>/rideN/rideN.lmx` 恢复，兼容回退 `model/mt_zuoqi/rideN/rideN.lmx`
4. 从 `action.lmx` 展开 `model/<name>/action/*.act`
5. 从各层 `<layer>.lmx` 的组件清单，结合动作名集合展开：
   - `model/<name>/<layer>/<component>/*.ani`
   - 对 `fashion-*` 的 `weapon` 层，会同时尝试：
     - `model/<fashion-model>/weapon/<component>/*.ani`
     - `model/<role-model>/weapon/<component>/*.ani`
   - 这是因为真实资源包里经常同时存在“时装武器目录”和“基础角色武器目录”，两者内容可能完全重复，但路径 CRC 不同
   - 对 `model/<name>/body/bodyonly/*.ani`，还会额外补充一组窄范围 fallback：
     - `model/actiontype.set` 中的标准动作，例如 `attack1`、`stand2`
     - 其它已解析 `action.lmx` 中出现过的全局 `riding_*` 动作
   - 这是因为真实资源包里存在一批模型：包内确实打了 `body/bodyonly/<action>.ani`，但该模型自己的 `action.lmx` 并没有把动作名完整列出来
6. 对已经确定路径的 `model/**/*.ani`，继续按客户端 `PAniPack` 结构解析：
   - 读取每个 `FileSec.strPicPath`
   - 读取版本 15 的 `strPicPathPrefix`
   - 按客户端真实规则拼接 `packbaseuri + strPicPath` 或 `dirname(packbaseuri) + strPicPathPrefix + strPicPath`
   - 进一步恢复 `model/<name>/<layer>/<component>/stand1_res000.png` 这类模型素材图片
   - 对已经恢复出来的 `model/*/body/bodyonly/*.ani`，还会再按 `model/<name>/body/bodyonly/<action>_resNNN.png` 模板做一轮精确 CRC 扫描
   - 这条 sweep 只覆盖已映射的 body 动画基路径，目标是补回真实资源包里“同动作目录下还有更高序号贴图，但 `ani` 内部并没有把全部 `_resNNN` 名字枚举出来”的尾部残留
   - 同样的 `_resNNN.png` sweep 也会扩展到其它已恢复的 `model/**/*.ani` 基路径，例如
     `model/<name>/weapon/<component>/run.ani -> model/<name>/weapon/<component>/run_res002.png`
   - sweep 上限会取“当前已观测到的最高 `_resNNN` 索引”和保守固定上限 `_res016` 的较大值，
     因此即使 `ani` 文本里只显式带出 `_res000`，也能继续命中真实包里常见的 `_res002/_res010` 尾部贴图
   - 这一步仍然只接受“候选真实路径 CRC 在当前包中精确存在”的命中，不会盲目为所有模型目录生成图片
   - 若同 CRC 命中 `...pngpart / ...ddspart` 侧车文件，也会一起恢复
   - ride 层同样会先尝试 `model/<name>/rideN/<component>/<action>.ani`，再回退共享坐骑目录
   - 时装武器层不会只保留基础角色回退；若 `fashion-*` 自己的武器贴图路径 CRC 存在，也会一并恢复
6. 对“内容里直接带文件名”的资源做额外自恢复：
   - 粒子路径文件名会按引擎固定目录恢复为 `effect/particle/path/*.path`
   - 若任意已解出的文件里直接带出粒子贴图 token，例如 `animation/a00012_3x3.png`、
     `object/ob00054.dds` 或裸 `line04.path`，会继续按固定目录恢复到
     `effect/particle/texture/...` 与 `effect/particle/path/...`
   - Lua 工程文本会恢复为 `script/*.luaproj`

补充说明：

- `actiontype.set` 的真实 XML 结构是 `<type id=\"...\" des=\"...\"><action name=\"...\"/></type>`，不是旧版文档里假定的 `<item>` 风格。
- 在 `梦屿西游` 这类真实资源包里，`ride1~ride4` 的层配置 CRC 实际更多命中 `model/<fashion-model>/rideN/rideN.lmx`，而不是单一的 `model/mt_zuoqi/...`。

这部分恢复完全走“已知模型名 + 固定路径模板 + CRC 命中校验”，不依赖外部原始资源目录。

### 6.1.4 Spine 资源结构恢复

在模型链之外，解包器还会对“包内显式登记了 Spine 效果名”的场景做一轮低风险恢复：

1. 识别 `spine_effect.set` 风格的 XML：
   - 必须出现 `<effect name="spine/...">`
   - 命中后优先恢复为 `effect/spine/spine_effect.set`
2. 从注册表中的 `spine/foo/bar` 这类效果名，按客户端真实规则直接展开：
   - `effect/spine/foo/bar.atlas`
   - `effect/spine/foo/bar.json`
3. 若已恢复的 Lua 脚本里出现 `UISpineSprite:new("foo")` 或 `SetSpineModel("foo", ...)` 这类字面量调用：
   - 会按 `SpineSprite::SetModel()` 的真实加载路径补回 `model/foo/foo.atlas`
   - 同时补回 `model/foo/foo.json`
4. 若已恢复的 `model/sprites.set` 中存在 `<model ... type="1" ...>` 这类标准模型 Spine 注册项：
   - 会提取其中的 `name`
   - 再按 `SpineSprite::SetModel()` 相同的标准模板补回 `model/<name>/<name>.atlas`
   - 同时补回 `model/<name>/<name>.json`
5. 对已经确定路径的 `*.atlas`，继续解析 atlas 页图：
   - 仅把“后面紧跟 `size:` 元数据”的顶层页名视为真实贴图页
   - 再按 `dirname(atlas) + pageName` 拼接出贴图路径
   - 命中后恢复为 `effect/spine/foo/bar.png`、`model/foo/foo.png` 等同目录素材
6. 对已恢复的 `script/tabledef/<分类>/<表名>.lua`，会继续按约定补回：
   - `table/bintable/<分类>.<表名>.bin`
   - 例如 `script/tabledef/role/createroleconfig.lua -> table/bintable/role.createroleconfig.bin`
7. 对已恢复的文本型输出，若存在 `GetTableByName("分类.表名")` 或 `GetTableByName(CheckTableName("分类.表名"))` 这类字面表引用：
   - 会把表名反推成 `script/tabledef/<分类>/<表名>.lua`
   - 同时补回 `table/bintable/<分类>.<表名>.bin`
   - 这条链适合恢复仍为 CRC 名的表定义 Lua 与对应二进制配置
8. 对客户端 `GameTable::GetBinFileName()` 已固定注册的一组表二进制：
   - 会按内置已知路径清单直接做精确 CRC 反查
   - 例如 `table/bintable/battle.cbattleaiconfig.bin`、`table/bintable/battle.cskillinfo.bin`
   - 例如 `table/bintable/npc.cmonsterconfig.bin`、`table/bintable/sysconfig.cgameconfig.bin`
   - 这条链适合恢复“包里只剩 `CRC.bin`，但客户端源码已经写死真实路径”的表格资源
9. 对已恢复的 Lua/UI 文本，若直接出现 `addcashdlg.layout` 这类布局字面量：
   - 会把裸布局名规范化为小写
   - 再按 `ui/layouts/<name>.layout` 做精确 CRC 反查
   - 命中后直接恢复到 `ui/layouts/`
   - 这条链专门补“布局文件内容本身不足以反推原名，但业务脚本已经显式写死布局名”的场景
10. 对已恢复的 `table/bintable/role.createroleconfig.bin`，会按表头和字段定义继续解析：
   - 校验 `fileType=1499087948`、`version=101`、`checkNumber=2163342`
   - 提取每条记录里的 `spine`、`lizi`、`bg`
   - 再按 `SpineSprite::SetModel()` 真实规则补回 `model/<name>/<name>.atlas` 与 `model/<name>/<name>.json`

这条链直接对应客户端真实加载逻辑：

- `SpineEffect` 会把效果名 `spine/foo/bar` 展开成 `/effect/spine/foo/bar.atlas` 与 `/effect/spine/foo/bar.json`
- `SpineSprite::SetModel()` 会把字面模型名 `foo` 展开成 `/model/foo/foo.atlas` 与 `/model/foo/foo.json`
- `SpineManager` 再基于 atlas 内容，把页图按 atlas 所在目录的相对路径加载

### 6.1.5 动画/特效注册链恢复

这轮新增了一条专门针对 `geffect` 体系的恢复链，目标是把“仍保留为根目录 CRC 名”的 `GEffect` 主配置和其下游动画素材搬回真实目录：

1. 从已恢复的 Lua、表格二进制以及未命名文本中提取 `geffect/...` 注册名：
   - 例如 `geffect/ui/youjian`
   - 例如 `geffect/ui/mt_duanxian/mt_duanxian`
   - 例如 `geffect/number/baojisubhp/6`
2. 对根目录仍未命名的 `.xml`，识别其中的 `GEffect` 主配置特征：
   - 必须出现 `<clip ... r_f=\"...\">`
   - 同时要求存在 `t_f=`、`fps=` 这类 `GEffect` 根属性
   - 会排除 `GUILayout / Imageset / Font / GUIScheme / Falagard / model/layer/component/action` 等其他 XML 结构
3. 若某个 `geffect/...` 的真实主配置路径 `effect/geffect/...eff.inf` 对应的 CRC 确实存在于当前包中，但当前还没有被映射出来：
   - 就用该 `geffect` 名和未命名 XML 里的 `animation/...` 引用做匹配
   - 评分优先级依次是：
     - `animation/<geffect-tail>` 的完全同名命中
     - `animation/<geffect-tail>/...` 的直接子路径命中
     - 同目录下 basename 的高置信度近似命中
   - 仅在“唯一高分命中”时才恢复，避免把多个 CRC XML 误搬到同一路径
4. 对一类客户端运行时会扁平化命名的 Sprite 特效主配置，会先走更直接的精确恢复：
   - 若 `<clip r_f=\"...\">` 命中了 `animation/sprite/npc/<分类>/<叶子名>`，优先尝试 `effect/geffect/sprite/npc/<叶子名>.eff.inf`
   - 若命中了 `animation/sprite/title/<叶子名>`，优先尝试 `effect/geffect/sprite/title/<叶子名>.eff.inf`
   - 这条规则对应客户端真实加载方式，例如 `Npc::SetAttribute()` 最终使用的是 `geffect/sprite/npc/<headtitle>` 这种扁平路径，而不是动画目录里的中间分类名
   - 只有推导出的目标路径 CRC 在当前包里精确命中时才会移动，因此不会因为“分类目录看起来像名字”而误归位
5. 一旦 `effect/geffect/...eff.inf` 成功恢复：
   - 后续多轮推断会继续从其中的 `<clip r_f=\"animation/...\">` 补回 `effect/animation/.../*.ani`
   - 对已经恢复出来的 `effect/animation/skill/<family>/...`，还会额外尝试一组窄范围技能家族别名目录：
     - `<family>`
     - `acc-<family>`
     - `acc1-<family>` 到 `acc7-<family>`
   - 例如已恢复 `effect/animation/skill/lg/3011.ani` 后，会继续尝试 `effect/animation/skill/acc5-lg/3011.ani`
   - 同理也会对 `3011_resNNN.png` 这类贴图做同 stem 的精确 CRC 扫描
   - 这条规则只覆盖已经观察到的技能 family，且只有目标路径 CRC 在当前包里精确命中时才会移动
6. 路径 token 抽取允许 `+` 作为合法资源名字符，因此 `geffect/ui/red+`、`animation/ui/red+` 这类 UI 特效路径不会再被截断成 `red`
7. 对 `geffect/...`、`animation/...`、`particle/...` 这类语义 token，即使 basename 自带 `.`，也不会再被误判成“已有扩展名”：
   - 例如 `geffect/skill/acc-teji/cc.huihunzhou`
   - 例如 `animation/skill/acc-chongwu/cc.jdsf-gj`
   - 只要 token 末尾还不是 `.eff.inf/.audio.xml/.ani/.ptc`，仍会继续补真实后缀后再做 CRC 命中
8. 对客户端源码里路径固定、CRC 可直接验证的特效注册表，也会走精确恢复：
   - `table/bintable/effectpath.ceffectpath.bin`
   - `table/bintable/effectpath.ceffectpathnonedrama.bin`
   - 这两张表会按客户端 `LDZY + version=101` 的二进制结构直接解析出真实记录值
   - `CEffectPath` 取 `Patn` 字段，`CEffectPathNoneDrama` 取 `Path` 字段
   - 对表内的 `geffect/...`、`animation/...`、`particle/...` 路径，会继续做 `effect/...` 精确 CRC 命中恢复
   - 已恢复出的 `effect/animation/**/*.ani` 会继续解析内部贴图引用
   - 最终补回 `effect/animation/.../*_res000.png`、`*.dds` 等动画素材
   - 若动画内常见令牌仍是 `*_resNNN.png`，但包里的真实文件路径 CRC 对应 `*_resNNN.dds/.tga/.jpg/.jpeg`，阶段二还会按客户端图片加载回退规则补试这些同基名扩展
9. 对另外几张客户端固定结构的技能/状态表，也会继续提取特效字段并做精确恢复：
   - `table/bintable/battle.cstageinfo.bin`
   - `table/bintable/battle.cstageinfo2.bin`
   - `table/bintable/buff.cbuffconfig.bin`
   - `CStageInfo/CStageInfo2` 读取 `effectname`、`effectsound`
   - `CBuffConfig` 读取 `effect`、`wordeffect`
   - 对这些字段里出现的 `geffect/...` 会直接补回 `effect/geffect/...*.eff.inf`

这条链的价值在于：即使 `PathFileNameCRC32` 不能直接回推 `effect/geffect/...eff.inf`，只要包内还保留了 `geffect` 注册名和 `animation` 引用，解包器就能利用客户端真实加载关系，把 `GEffect 主配置 -> ani -> texture` 这整条特效链恢复出来。

### 6.2 文件类型探测补扩展名

在没有映射时，若满足：

- `detectFileType=true`
- 提供了 `fileData`
- `dataSize>0`

则会先尝试 UI/XML 语义后缀判断和模型链二进制结构判断，再回退到 `FileTypeDetector::DetectExtension()` 补扩展名。

当前已额外覆盖的低风险内容识别包括：

- `0x00010000` 的 sfnt 头补成 `.ttf`
- `OTTO` 头补成 `.otf`
- `D0 CF 11 E0 A1 B1 1A E1` 复合文档头补成 `.cfb`
- `MDMP` 头补成 `.dmp`
- `NuclearImg` version 6 结构、且尾部 `m_filefmt / m_texfmt` 命中合法纹理格式时补成 `.img`
- 头部满足 TGA 基本约束、且尾部带 `TRUEVISION-XFILE.` 标准签名时补成 `.tga`
- `MMHeader { hsize=12, width, height }` 且总长满足 `12 + width * height` 的地图网格补成 `.dat`
- `headfile=16, width, height, count` 且总长满足 `16 + count * 8` 的怪物点位表补成 `.dat`
- 无空字节、控制字符占比很低，且呈现多行文本或 Windows 路径文本时补成 `.txt`

### 6.3 类型分桶

若 `organizeByType=true` 且没有映射路径，就按扩展名归类到固定目录。

## 7. 流式解包算法

### 7.1 未压缩流

`UnpackSingleFileStream()`：

- 分块读取
- 若需要解密则逐块解密
- 可增量计算 CRC32
- 第一块数据可用于决定扩展名

适用条件：

- 文件未压缩
- 若需要解密，则模式不能是 `Auto`
- 块大小满足对齐要求

### 7.2 压缩流

`UnpackSingleFileStreamCompressed()`：

- 分块读入压缩数据
- 可选逐块解密
- 使用 `mz_inflate` 做增量解压
- 每次有输出时立即写文件并增量算 CRC32
- 校验最终产出大小必须等于 `m_SizeOriginal`

压缩流路径回退条件更多，包括：

- `inflateInit` 失败
- 输出超出原始大小
- inflate 停滞
- 流未正常结束
- 最终输出大小不匹配

## 8. 并行算法

### 8.1 默认并行实现

当前 `UnpackAll()` 在 `threadCount > 1` 时调用：

```text
UnpackAllParallelOptimized(threadCount)
```

不是旧版 `UnpackAllParallel()`。

### 8.2 优化点

`UnpackAllParallelOptimized()` 真实做了三件事：

1. 任务预排序
   - 按 `PackIndex`
   - 再按 `Pos`
2. 目录预创建
3. 固定分片
   - 不是工作线程抢共享队列
   - 每个线程拿一个连续区间

这能减少：

- 同一 `.ljfp` 的随机寻道
- 动态调度锁竞争
- 解包过程中重复建目录

### 8.3 进度策略

进度并不由工作线程直接刷新 UI，而是：

- 工作线程只更新完成数
- 主线程定期汇总并节流回调

## 9. 路径映射命中率算法

`UpdatePathMappingStats()` 会遍历 `m_fileList`：

- 命中映射则 `hit++`
- 未命中且采样数不足 5 个时，记录缺失样本
- `rateBasis = hit * 10000 / total`

GUI 就依赖这个值来判断：

- 是否需要自动重建映射
- 当前映射是否足够可信

## 10. 错误恢复与回退策略

代码中的回退策略主要有四类：

1. 自动解密模式回退
2. 流式失败回退普通路径
3. 自动映射命中率不足时重建映射
4. 二进制映射 CRC 自修复

这也是当前实现最核心的工程化特征：不是只追求“最快”，而是优先保证结果可用。
