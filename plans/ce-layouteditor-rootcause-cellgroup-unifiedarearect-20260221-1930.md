# CELayoutEditor 根因定位与修复记录（CellGroupButton4 + UnifiedAreaRect）

时间：2026-02-21

## 0. 关联文档

- 主链路机制分析：`plans/cegui-layout-loading-analysis.md`
- 根因实证与修复清单（本文）：`plans/ce-layouteditor-rootcause-cellgroup-unifiedarearect-20260221-1930.md`

## 1. 结论

`res/ui` 与 `res6/ui` 的“打不开/闪退”核心触发点不是目录整体差异，而是布局里以下组合：

- 窗口类型：`TaharezLook/CellGroupButton4`
- 属性：`Property Name="UnifiedAreaRect" ...`

在当前 `client/resource/tools/CELayoutEditor.exe` 构建下，上述属性路径会触发 `CEGUIBase.dll` 异常（事件日志固定偏移 `0x000dfcd0`，`0xC0000005/0xC000041D`）。

## 2. 关键证据

1. 同布局（`cbgcell1.layout`）修复前可稳定复现 7~8 秒崩溃：
- `plans/ce-layouteditor-rootcmp-res-cbgcell1-40s.log`
- `plans/ce-layouteditor-rootcmp-res6-cbgcell1-40s.log`

2. 最小探针验证：
- `CellGroupButton4` 无 `UnifiedAreaRect`：可稳定存活
- 仅给 `CellGroupButton4` 加 `UnifiedAreaRect`：快速崩溃
- 将该属性改为 `Area`：可稳定存活

3. Windows 应用日志：
- Provider: `Application Error`
- Faulting module: `CEGUIBase.dll`
- Exception: `0xc0000005` / `0xc000041d`
- Fault offset: `0x000dfcd0`

## 3. 修复策略（资源层兼容，不改功能逻辑）

将 `CellGroupButton4` 窗口上的属性从：

- `Name="UnifiedAreaRect"`

改为：

- `Name="Area"`

值保持不变。

## 4. 已修复文件

### `client/resource/res/ui/layouts`

- `cbgcell1.layout`
- `cbgcell2.layout`
- `familychengyuandiacell.layout`
- `familyduizhencell3.layout`
- `familyjiarudiacell.layout`
- `familyshenqingdiacell.layout`
- `familyshijiandiacell.layout`
- `familyxinxidiacell.layout`
- `jingjichangcell3v3.layout`
- `workshopdzpreviewcell.layout`

### `client/resource/res6/ui/layouts`

- `cbgcell1.layout`
- `cbgcell2.layout`
- `familychengyuandiacell.layout`
- `familyduizhencell3.layout`
- `familyfuwenqingqiudiacell.layout`
- `familyfuwentongjidiacell.layout`
- `familyjiarudiacell.layout`
- `familyshenqingdiacell.layout`
- `familyshijiandiacell.layout`
- `familyxinxidiacell.layout`
- `familyyaoqingdiacell.layout`
- `jingjichangcell.layout`
- `jingjichangcell3v3.layout`
- `workshopdzpreviewcell.layout`

## 5. 回归结果

修复后：

- `res` + `cbgcell1.layout`：20s 存活
  - `plans/ce-layouteditor-rootcmp-res-cbgcell1-finalcheck.log`
- `res6` + `cbgcell1.layout`：30s 存活
  - `plans/ce-layouteditor-rootcmp-res6-cbgcell1-after-area-fix-defaultfeatures.log`

并且扫描确认（排除探针文件）：

- `res/ui/layouts` 中 `CellGroupButton4 + UnifiedAreaRect` 剩余命中：`0`
- `res6/ui/layouts` 中 `CellGroupButton4 + UnifiedAreaRect` 剩余命中：`0`
