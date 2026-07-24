# MT3 Codex Skills 运行评估与脚本化改造优先级报告

> **状态**: 历史快照
> **适用日期**: 2026-04-03
> **当前基线**:
> - `docs/10-管理文档/文档维护指南.md`
> - `.agents/skills/mt3-project-guidelines/SKILL.md`
>
> 说明：本文保留当时的 skills 审计与脚本化优先级判断，不直接替代当前技能入口和治理规则。

> 文档版本: 1.0.0  
> 生成日期: 2026-04-03  
> 适用范围: `E:\MT3\.agents\skills\**` 项目级 Codex Skills  
> 事实来源: `.claude/reports/codex-skills-audit.json`、`.claude/reports/claude-config-audit.json`、`.claude/scripts/audit_codex_skills.ps1`、项目内 `SKILL.md` / `agents/openai.yaml`  
> 官方依据: OpenAI Codex Skills 文档、Customization/Skills 文档、Skills best practices
> 状态更新: 2026-04-03 已落地 P0/P1/P2 脚本骨架，补齐 P3 治理收口，并完成 P4 全量 JSON 双输出升级（12 个 Skills 脚本已支持 `-Json`）

---

## 1. 执行摘要

本轮治理后，MT3 项目内 Codex Skills 已达到“结构合规、路由清晰、可审计、脚本契约统一”的稳定基线，但尚未达到“高自动化、高确定性”的成熟阶段。

当前已确认的基线指标：

- 项目级 Skills 总数: 14
- `allow_implicit_invocation: true`: 11
- `allow_implicit_invocation: false`: 3
- 缺少显式策略的 Skills: 0
- 带 `references/` 的 Skills: 9
- 带 `scripts/` 的 Skills: 12
- 带 `assets/` 的 Skills: 1
- 脚本输出契约漂移: 0
- 支持 `-Json` 的脚本数: 12
- 六类关键章节缺失数: 0
- 审计结果: `PASS`

结论分两层：

1. 文档与元数据层已经显著提升了触发准确性。  
   各 Skill 现在都具备清晰的 `description`、正反路由边界、输入校验、失败处理、输出验证和上下文预算，符合官方“渐进式披露 + 清晰路由 + 显式验证”的最佳实践。

2. 剩余瓶颈主要集中在“模板资产密度和统一 JSON schema 仍不够丰富”。  
   当前已为 12 个 Skills 落地 `scripts/`，并通过审计强制统一 `STATUS/SUMMARY/DETAIL/NEXT` 输出契约；这 12 个脚本现在都已支持 `-Json` 双输出，同时新增了首个项目级模板资产。剩余主要保持说明型的 Skill 只剩入口路由与治理类组件。

---

## 2. 官方规范对照结论

本报告严格参照以下官方口径：

- `https://developers.openai.com/codex/skills/`
- `https://developers.openai.com/codex/concepts/customization/#skills`
- `https://developers.openai.com/codex/skills/#optional-metadata`
- `https://developers.openai.com/cookbook/examples/skills_in_api/#operational-best-practices`

与官方最佳实践对照后的结论如下：

- 已满足:
  - Skill 目录结构合规，`SKILL.md` 与 `agents/openai.yaml` 完整
  - 元数据可发现性良好，支持渐进式披露
  - 隐式触发 Skill 已明确写出正向/负向边界
  - `default_prompt` 已显式包含 `$skill-name`
  - 各 Skill 已具备验证闭环，不再只描述“怎么做”，而是说明“做完怎么确认”

- 待继续增强:
- 仍有少量说明型 Skill 继续保持轻量化；当前脚本型 Skill 已提升到 12，模板型 Skill 资产开始起步
  - 输入校验仍主要依靠自然语言规则，而非更强的结构化参数校验
  - `-Json` 双输出已覆盖全部 12 个脚本，但跨技能统一 schema 仍待收敛
  - `assets/` 仍处于起步阶段，跨技能可复用样例还偏少

换句话说，当前治理已经解决了“会不会触发错、会不会读太多、会不会少验证”的问题；下一阶段要解决的是“能不能更快、更稳、更少靠模型重复思考”的问题。

---

## 3. 当前工作流现状

### 3.1 实际装载路径

项目内 Skills 的当前运行链路可以概括为：

1. Codex 先读取 Skill 元数据
2. 根据 `name`、`description` 和 `agents/openai.yaml` 做发现与匹配
3. 选中 Skill 后再加载 `SKILL.md`
4. 仅在需要时继续读 `references/`
5. 当前已有 12 个 Skills 继续下沉到 `scripts/`，且 `mt3-project-guidelines` 已开始使用 `assets/`

这与官方“progressive disclosure”机制一致；当前已对高确定性和高频取证场景进入第 5 步的自动化增强，但入口路由与治理 Skill 仍保持说明驱动。

### 3.2 已修复的准确性问题

本轮已消除的主要问题包括：

- 隐式触发策略不再依赖默认值
- 说明边界不再模糊，避免了跨域误触发
- Skill 正文不再只有“流程”，而是同时具备“前置校验 + 失败处理 + 输出验证”
- 入口 Skill 与治理 Skill 已把 Skills 审计纳入标准流程

### 3.3 剩余效率瓶颈

当前最主要的效率瓶颈有四类：

1. 高确定性任务仍靠自然语言推理执行  
   例如环境探测、路径检查、构建链确认、资源引用核对，本质上都适合脚本化。

2. 结构化输出已铺开，但 schema 仍不完全统一  
   目前 12 个脚本都已能稳定产出统一固定文本契约和可选 `-Json` 结果，但字段模型仍偏“按技能各自扩展”，后续适合继续收敛为统一 schema 供后续步骤复用。

3. 多数 Skill 仍缺少轻量模板或样例资产  
   当前已补首个模板资产，但跨技能复用素材仍不足，模型在重复任务中仍会反复组织表述。

4. 强规则场景没有“快速失败”脚本  
   例如编码、生成代码、旧工具链校验，一旦条件不满足，本应立即报错退出，而不是继续展开长推理。

---

## 4. 逐 Skill 评估矩阵

说明：

- `强`: 当前已经比较完整
- `中`: 已有基础，但仍适合脚本补强
- `弱`: 适合优先脚本化

| Skill | 输入校验 | 流程闭环 | 错误处理 | 资源效率 | 当前判断 | 下一步建议 |
|---|---|---|---|---|---|---|
| `mt3-project-guidelines` | 强 | 强 | 强 | 中 | 路由入口成熟，已补模板资产 | 保持说明型，继续沉淀模板 |
| `application-core-flow` | 强 | 强 | 强 | 中 | 已补主链入口探针，主体仍以阶段判断为主 | 保持说明型主导，继续补阶段样例 |
| `platform-bridge` | 强 | 强 | 强 | 中 | 已补三端交接探针，平台差异仍需人工判断 | 继续补渠道差异与生命周期样例 |
| `rendering-pipeline` | 强 | 强 | 强 | 中 | 已补渲染栈探针，复杂症状仍需人工分析 | 后续按需补资源/症状对照表 |
| `resource-packaging-pipeline` | 强 | 强 | 强 | 中 | 适合补发布结构校验脚本 | 进入第二批脚本化 |
| `sprite-pack-algorithm` | 强 | 强 | 强 | 中 | 适合补输出目录与 `pack.ini` 校验 | 进入第二批脚本化 |
| `windows-v120-build` | 强 | 强 | 强 | 弱 | 强确定性、重复性高 | 第一批脚本化 |
| `android-r10e-build` | 强 | 强 | 强 | 弱 | 环境校验和命令顺序都可脚本化 | 第一批脚本化 |
| `server-ant-build` | 强 | 强 | 强 | 弱 | JDK/Ant/代码生成链适合脚本化 | 第一批脚本化 |
| `cegui-layout-integration` | 强 | 强 | 强 | 中 | 说明完整，但校验仍靠人工 | 第二批脚本化 |
| `lua-dialog-integration` | 强 | 强 | 强 | 中 | 可补 Lua/UI 绑定一致性检查 | 第二批脚本化 |
| `encoding-bom-guard` | 强 | 强 | 强 | 弱 | 最适合做成快速失败工具 | 第一批脚本化 |
| `generated-code-guard` | 强 | 强 | 强 | 弱 | 规则清晰，最适合路径识别脚本 | 第一批脚本化 |
| `claude-config-governance` | 强 | 强 | 强 | 中 | 已有外部治理脚本支撑 | 保持说明型，继续复用 `.claude/scripts` |

---

## 5. 分层优先级与脚本化建议

### 5.1 P0: 立即脚本化

这批 Skill 的共同特征是：

- 输入边界清晰
- 判断条件高度确定
- 重复执行频率高
- 一旦判断错误，代价较大

建议优先级如下：

1. `windows-v120-build`
   - 建议新增:
     - `.agents/skills/windows-v120-build/scripts/verify-build-env.ps1`
     - `.agents/skills/windows-v120-build/scripts/check-solution-entry.ps1`
   - 目标:
     - 自动检查 VS2013/v120/MSBuild 12.0
     - 自动确认正确构建入口
     - 统一输出 PASS/WARN/FAIL

2. `android-r10e-build`
   - 建议新增:
     - `.agents/skills/android-r10e-build/scripts/verify-android-r10e-env.ps1`
   - 目标:
     - 校验 NDK r10e、Ant、JDK 版本
     - 自动识别错误工具链路径
     - 输出最小修复建议

3. `server-ant-build`
   - 建议新增:
     - `.agents/skills/server-ant-build/scripts/verify-server-ant-chain.ps1`
   - 目标:
     - 检查 JDK/Ant
     - 检查 `genrpc/genxdb/gengbeans/dist` 执行前提
     - 输出失败节点而不是泛化说明

4. `encoding-bom-guard`
   - 建议新增:
     - `.agents/skills/encoding-bom-guard/scripts/detect-file-encoding.ps1`
   - 目标:
     - 自动输出原始 BOM、推定编码、换行风格
     - 统一给出“可 `apply_patch` / 不可 `apply_patch`”结论

5. `generated-code-guard`
   - 建议新增:
     - `.agents/skills/generated-code-guard/scripts/find-generation-source.ps1`
   - 目标:
     - 自动判定是否命中生成目录
     - 尝试定位源定义或生成入口
     - 给出“禁止直改 / 可改源定义”的结论

### 5.2 P1: 第二批脚本化

这批 Skill 仍偏领域分析，但存在稳定的结构检查价值。

1. `cegui-layout-integration`
   - 建议新增:
     - `scripts/check-cegui-bindings.ps1`
   - 目标:
     - 校验布局文件、控件命名、scheme/imageset/font 路径一致性

2. `lua-dialog-integration`
   - 建议新增:
     - `scripts/check-lua-ui-bindings.ps1`
   - 目标:
     - 校验 `GetLayoutFileName()`、窗口路径、事件绑定与布局名一致性

3. `resource-packaging-pipeline`
   - 建议新增:
     - `scripts/verify-patch-layout.ps1`
   - 目标:
     - 校验热更目录结构、索引文件和补丁布局

4. `sprite-pack-algorithm`
   - 建议新增:
     - `scripts/verify-pack-output.ps1`
   - 目标:
     - 检查 `pack.ini`、图集输出、ANI/XAP 结果完整性

### 5.3 P2: 低侵入探针已落地，主体仍保持说明型

以下 Skill 更依赖上下文判断和架构理解，不适合为了“脚本化率”继续堆砌重逻辑脚本：

- `mt3-project-guidelines`
- `claude-config-governance`

本轮已为以下 3 个 Skill 落地低侵入静态探针，用于建立锚点而不是替代分析：

- `application-core-flow` -> `scripts/probe-core-flow-entry.ps1`
- `platform-bridge` -> `scripts/probe-platform-handoff.ps1`
- `rendering-pipeline` -> `scripts/probe-render-stack.ps1`

建议后续仍以补充 `references/`、案例模板和固定输出模板为主，不要为了“脚本化率”强行加入低价值脚本。

---

## 6. 逐 Skill 后续动作清单

| Skill | 推荐动作 | 目标结果 |
|---|---|---|
| `mt3-project-guidelines` | 补充 2-3 个跨域分流样例 | 提升首轮分流稳定性 |
| `application-core-flow` | 已增加主链入口探针，继续补启动/登录/入世界锚点样例 | 缩短定位时间 |
| `platform-bridge` | 已增加平台交接探针，继续补渠道差异样例 | 快速识别平台壳层问题 |
| `rendering-pipeline` | 已增加渲染栈探针，继续补渲染症状到锚点的对照表 | 降低排障试错 |
| `resource-packaging-pipeline` | 新增补丁结构校验脚本 | 降低发布链误判 |
| `sprite-pack-algorithm` | 新增图集输出校验脚本 | 提升工具链稳定性 |
| `windows-v120-build` | 新增环境与入口校验脚本 | 快速失败，减少误构建 |
| `android-r10e-build` | 新增旧链路环境校验脚本 | 降低 Android 构建排障成本 |
| `server-ant-build` | 新增服务端构建链校验脚本 | 降低代码生成链误操作 |
| `cegui-layout-integration` | 新增资源与命名一致性检查脚本 | 提升 UI 集成准确率 |
| `lua-dialog-integration` | 新增 Lua/UI 绑定一致性检查脚本 | 提升事件绑定准确率 |
| `encoding-bom-guard` | 新增编码探测脚本 | 降低乱码和转码事故 |
| `generated-code-guard` | 新增生成边界识别脚本 | 降低误改生成物风险 |
| `claude-config-governance` | 继续复用 `.claude/scripts` 审计链 | 避免治理逻辑重复下沉 |

---

## 7. 实施路径

### 阶段一: 1 周内

- 完成 P0 五个 Skill 的脚本骨架
- 统一脚本输出格式:
  - `STATUS: PASS|WARN|FAIL`
  - `SUMMARY: ...`
  - `NEXT: ...`
- 在对应 `SKILL.md` 中增加“何时运行脚本”和“脚本输出如何解读”
- 扩展 `audit_codex_skills.ps1`，检查 P0 Skill 是否已具备 `scripts/`

### 阶段二: 2-4 周

- 完成 P1 四个 Skill 的静态校验脚本
- 给 CEGUI、Lua UI、资源发布链补一批最小样例输入/输出
- 若脚本开始增多，再引入 `assets/` 保存模板

### 阶段三: 1-2 个月

- 为 P0/P1/P2 脚本补充统一回归验证命令
- 已在 Skills 审计中加入“脚本输出契约”检查，并完成 12 个脚本的 `-Json` 覆盖；后续继续收敛统一 JSON schema
- 评估是否需要在 `.claude/reports/` 下增加 Skills 运行质量趋势报告
- 继续扩充 `assets/`，沉淀跨技能可复用模板与样例

---

## 8. 管理建议

为了避免 Skills 再次回到“只靠文档描述”的状态，建议后续采用以下治理规则：

1. 新增 Skill 时，先判断它是“说明型”还是“脚本型”
2. 满足以下任一条件时，优先配套 `scripts/`
   - 需要重复执行至少 3 次
   - 结果可明确判定 PASS/FAIL
   - 环境检查或路径检查高度确定
   - 错误代价较高
3. `audit_codex_skills.ps1` 已新增两项检查
   - P0/P1/P2 Skill 是否已具备必需脚本
   - 脚本是否输出固定状态字段并满足统一契约
4. 不把所有 Skill 都脚本化
   - 路由、架构判断、复杂根因分析类 Skill 仍以说明型为主

---

## 9. 最终结论

MT3 当前的项目级 Codex Skills 已经从“可用但容易漂移”的状态，进入“结构稳定、路由准确、可持续治理”的状态。

下一阶段不需要再继续大规模补文案，真正的重点是：

- 让现有 12 个脚本继续从“可输出 JSON”收敛到“共享 JSON schema”
- 继续为高频技能补样例资产、模板和输入输出示例，而不是重复扩增说明文本
- 保持入口 Skill 和治理 Skill 的轻量化，不要为脚本化而牺牲路由清晰度
- 在新增脚本时继续复用统一输出契约和模板资产，而不是再各写一套风格

如果按本报告推进，MT3 的 Codex Skills 会从“描述工作流”进一步升级为“描述 + 校验 + 快速失败”的混合工作流体系，运行效率和执行准确性都会继续提升。
