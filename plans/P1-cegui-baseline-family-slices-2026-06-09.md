# P1/P2 CEGUI 历史债务分族清理切片（2026-06-09）

> 来源：`tools/scripts/baselines/resource-ui-gate-baseline.json`
> 当前策略：baseline 可见但不阻断；新增/增长 P0-P2 阻断。

## 1. 总览

- baseline issues: 529
- CEGUI issues: 528
- P1: 193
- P2: 268
- P3: 67

## 2. 类别分布

| 类别 | 数量 | 建议处理 |
| --- | ---: | --- |
| `orphan_getwindow` | 150 | 核对 Lua 动态前缀与 layout 控件路径，误报先注入规则 |
| `missing_imageset` | 124 | 补齐 imageset 文件或修正 layout 引用；优先 P1 核心 UI |
| `missing_lua_event_handler` | 118 | 核对 LuaEventOnClicked 与 Lua 函数定义/生命周期 |
| `imageset_not_declared_in_scheme` | 67 | P3；确认加载链后补 scheme 或白名单 |
| `unmapped_window_type` | 60 | 回 scheme/looknfeel 补 FalagardMapping 或修正 Window Type |
| `layout_xml_parse_error` | 5 | 先按单布局 XML 解析修复；禁止批量转码 |
| `missing_font` | 4 | 补齐 font 或替换为现有字体；运行时加载风险高 |

## 3. 分族优先级

| 布局族/切片 | 数量 | 优先级 | 验证入口 |
| --- | ---: | --- | --- |
| `lua_dynamic` | 268 | P2-动态路径专项 | `check-cegui-bindings.ps1 -All -DeepScan -Json` |
| `jingmai` | 64 | P1-第一批 | `check-cegui-bindings.ps1 -Family jingmai -DeepScan -Json` |
| `fabaopack` | 18 | P1-第二批 | `check-cegui-bindings.ps1 -Family fabaopack -DeepScan -Json` |
| `fabaomenpaimain` | 16 | P1-第二批 | `check-cegui-bindings.ps1 -Family fabaomenpaimain -DeepScan -Json` |
| `tounimabidashabi` | 15 | P1-第二批 | `check-cegui-bindings.ps1 -Family tounimabidashabi -DeepScan -Json` |
| `jingmaihecheng` | 14 | P1-第二批 | `check-cegui-bindings.ps1 -Family jingmaihecheng -DeepScan -Json` |
| `fabaoup` | 12 | P1-第二批 | `check-cegui-bindings.ps1 -Family fabaoup -DeepScan -Json` |
| `fabaomenpaiup` | 10 | P1-第二批 | `check-cegui-bindings.ps1 -Family fabaomenpaiup -DeepScan -Json` |
| `fabaomenpaijinjie` | 10 | P1-第二批 | `check-cegui-bindings.ps1 -Family fabaomenpaijinjie -DeepScan -Json` |
| `fabaomenpai` | 10 | P1-第二批 | `check-cegui-bindings.ps1 -Family fabaomenpai -DeepScan -Json` |
| `fabaoshop` | 7 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family fabaoshop -DeepScan -Json` |
| `zuoqity` | 6 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family zuoqity -DeepScan -Json` |
| `fabaojinjie` | 6 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family fabaojinjie -DeepScan -Json` |
| `fabaoxilian` | 6 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family fabaoxilian -DeepScan -Json` |
| `chongwuranse` | 4 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family chongwuranse -DeepScan -Json` |
| `jueseshizhuang` | 4 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family jueseshizhuang -DeepScan -Json` |
| `yichu` | 4 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family yichu -DeepScan -Json` |
| `worldmap` | 4 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family worldmap -DeepScan -Json` |
| `erciqueren` | 4 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family erciqueren -DeepScan -Json` |
| `moshouchuanqi` | 4 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family moshouchuanqi -DeepScan -Json` |
| `guajianniu` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family guajianniu -DeepScan -Json` |
| `fenxiang` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family fenxiang -DeepScan -Json` |
| `petcardwon` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family petcardwon -DeepScan -Json` |
| `baitanduihuan` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family baitanduihuan -DeepScan -Json` |
| `shengsizhanguize` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family shengsizhanguize -DeepScan -Json` |
| `battlenumber` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family battlenumber -DeepScan -Json` |
| `jingmaiui` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family jingmaiui -DeepScan -Json` |
| `chongwushizhuang` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family chongwushizhuang -DeepScan -Json` |
| `baitanhuodejinbi` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family baitanhuodejinbi -DeepScan -Json` |
| `petcard` | 2 | P2/P3-第三批 | `check-cegui-bindings.ps1 -Family petcard -DeepScan -Json` |

## 4. 第一批建议

1. `jingmai*`：数量最高，先核对 imageset、Lua 路径和 handler。
2. `fabao*` 系列：`fabaopack`、`fabaomenpai*`、`fabaoup`、`fabaoshop`、`fabaoxilian`、`fabaojinjie` 可作为一个业务域连续清理。
3. `lua_dynamic`：先区分动态 nameprefix 误报与真实 orphan，再调整检查器或修 Lua。

## 5. 验证命令

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\cegui-layout-integration\scripts\check-cegui-bindings.ps1 -Family jingmai -DeepScan -Json
powershell -NoProfile -ExecutionPolicy Bypass -File .\.agents\skills\cegui-layout-integration\scripts\validate-cegui-resources.ps1 -LayoutFamily jingmai -Json
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\scripts\Test-MT3-ResourceUiGate.ps1 -ReportPath build_logs\resource-ui-gate.json
```
