# LJFilePackUnpacker 架构审查与优化报告

> 日期：2026-03-31  
> 范围：`tools/LJFilePackUnpacker/**`，并交叉核对 `dependencies/SuperLJFilePackUnpack/**` 与 `dependencies/LJFilePack/**`  
> 目标：给出当前现状评估、根因判断、已实施优化、目录清理结果与后续治理建议

## 1. 执行摘要

本次审查后的核心判断如下：

1. `tools/LJFilePackUnpacker` 当前最主要的问题不是“算法不够快”，而是“架构事实混杂”。
2. 目录内同时存在历史 C++ 原型、可运行的 WinForms GUI、分发目录和构建脚本，但真正承担解包功能的后端来自 `dependencies/SuperLJFilePackUnpack`。
3. GUI 与构建脚本此前都默认绑定 `ljfp-unpack.exe` 的 legacy 协议，和当前仓库中实际存在的 CLI 形态已经发生漂移。
4. 历史 C++ 原型中存在多处高风险实现问题，但它目前不在主构建链中；直接继续在这套原型上堆补丁，不会自动改善现有可运行工具。
5. 本次优化已把 `tools/LJFilePackUnpacker` 这一层改造成“能识别真实后端、能兼容当前仓库 CLI 差异、能抑制缓存膨胀、文档边界清晰”的状态。

## 2. 现状评估

### 2.1 架构设计

当前目录可拆成四层：

- `gui-mvp/`
  - 当前唯一明确可运行的桌面入口。
  - 负责参数收集、启动 CLI、采集标准输出、解析进度。
- `scripts/`
  - GUI/CLI 的组装式构建脚本。
- `dist/mvp/`
  - 最终分发目录。
- `inc/` + `src/`
  - 历史 C++ 原型。
  - 有设计价值，但并不是现行主线。

架构上的主要问题：

- 文档长期把“原型代码”和“实际运行链”写在一起，导致维护者容易误判主修复点。
- GUI 只认 legacy CLI 名称与参数协议，导致一旦仓库只剩诊断 CLI，工具就出现构建或运行漂移。
- 构建脚本写死了历史工程名，缺乏对当前项目文件状态的自适应能力。

### 2.2 算法效率

`tools/LJFilePackUnpacker` 目录自身并不直接承载生产解包算法；真正的算法性能主要由 `dependencies/SuperLJFilePackUnpack` 决定。

但在本目录层面，仍存在影响效率的包装层问题：

- GUI 使用字符串拼接构造命令行，存在转义不稳和参数重排风险。
- GUI 只能解析一种进度格式，导致不同 CLI 输出下无法稳定反映真实进度。
- 分发脚本会把调试符号和构建缓存一路带到分发链，增加不必要的复制与目录噪音。

### 2.3 内存管理

历史 C++ 原型中存在以下明显风险：

- 广泛使用裸指针与 `new[]/delete[]`，缺乏 RAII 封装。
- `LJFPU_UnpackCore` 在头文件中未声明 `Cleanup()`，源码与接口不一致，说明该原型未通过完整编译回路。
- `LJFPU_MiniZ::GetUncompressedSize()` 采用“先试小缓冲，再用 `srcLen * 10` 暴力探测”的策略，存在尺寸估算失真和潜在大内存分配风险。
- `LJFPU_FileHandler::CreateOutputDirectory()` 依赖 `MAX_PATH` 固定栈缓冲，长路径下不安全。

### 2.4 安全性

本次静态审查识别出的主要风险：

- 命令行参数此前靠手工引号拼接，理论上存在路径包含特殊字符时的兼容性风险。
- 诊断 CLI 与 legacy CLI 的能力边界不同，旧实现没有显式提示“哪些选项已被忽略”，容易让用户误以为某些校验或覆盖设置已经生效。
- 历史原型把索引结构当作固定 28 字节数组处理，与真实 `.ljpi` 可变长记录不一致，若直接投入生产使用，存在越界解析或逻辑错读风险。
- 原型代码对散文件、包文件命名和“仅解密/仅解压/不解压”分支处理不完整，功能路径存在误用风险。

## 3. 关键问题清单

### P0：运行链事实不清

- 现象：
  - `tools/LJFilePackUnpacker` 看起来像一个完整 C++ 工具目录，但实际运行链依赖外部后端。
- 影响：
  - 修错位置，返工成本高。

### P1：GUI 与后端协议漂移

- 现象：
  - GUI 只查找 `ljfp-unpack.exe`，构建脚本也优先假定 legacy 工程与输出名固定。
- 影响：
  - 仓库中如果只有 `ljfp-unpack-diag.exe`，GUI 可能无法直接工作。

### P1：构建脚本对工程名写死

- 现象：
  - 脚本直接引用 `UnpackExample.vcxproj`，而当前 `build/` 目录实物未必保持该名称。
- 影响：
  - 一键构建失效。

### P1：历史 C++ 原型不可直接视为生产代码

- 现象：
  - 头源不一致、索引假设过于简化、包文件命名规则与真实格式不符、散文件逻辑未闭环。
- 影响：
  - 直接在原型上修补无法改善现行 GUI + CLI 的可用性。

### P2：目录冗余

- 现象：
  - `gui-mvp/bin`、`gui-mvp/obj` 为可再生缓存。
  - `docs/` 下存在两份名称相近但内容不同、且均声称是“全量技术分析报告”的文档。
- 影响：
  - 目录噪音高，事实入口不唯一。

## 4. 已实施的优化方案

### 4.1 GUI 重构与功能增强

已实施：

- 新增 `gui-mvp/UnpackCliSupport.cs`
  - 把 CLI 解析、命令构造、兼容性校验、进度识别从窗体代码中抽离。
- `MainForm.cs` 重构为“表单逻辑 + 后端计划”模式
  - 不再手工拼接 `Arguments` 字符串，改用 `ProcessStartInfo.ArgumentList`。
  - 自动识别 `ljfp-unpack.exe` 与 `ljfp-unpack-diag.exe`。
  - 兼容 legacy 进度格式与 `progress=xx% (a/b)` 诊断格式。
  - 新增解密模式、解密 Key、诊断线程数、诊断流式模式输入项。
  - 对诊断 CLI 不支持的选项给出运行前提示，而不是静默忽略。
  - 增加日志行数上限，避免 RichTextBox 无限增长。

直接收益：

- 代码可维护性显著提升。
- CLI 更换或输出格式变化时，不再需要在 UI 代码里全量硬改。
- 参数安全性与可解释性更好。

### 4.2 构建脚本自适应

已实施：

- 重写 `scripts/Build-MVP-OneClickUnpacker.ps1`
  - 自动检测可用 CLI 工程：
    - `UnpackExample.vcxproj`
    - `ljfp-unpack.vcxproj`
    - `ljfp-unpack-diag.vcxproj`
  - 根据真实工程选择输出的可执行文件名。
  - 清理分发目录时增加目标路径校验，避免误删范围扩大。
  - 复制 GUI 产物时排除 `.pdb`，减小分发目录噪音。

直接收益：

- 一键构建不再强依赖单个历史工程名。
- `dist/mvp/` 更接近最终交付形态。

### 4.3 文档与事实边界收敛

已实施：

- 重写根 `README.md`
  - 明确说明本目录只是“GUI 壳层 + 脚本 + 文档 + 原型代码”。
- 重写 `gui-mvp/README.md`
  - 写明 legacy CLI 与诊断 CLI 的兼容边界。
- 新增本报告作为最新审查入口。

直接收益：

- 维护者可以快速知道“哪里是当前可运行链，哪里只是原型参考”。

### 4.4 目录治理

已实施：

- 新增 `tools/LJFilePackUnpacker/.gitignore`
  - 忽略 `gui-mvp/bin/`
  - 忽略 `gui-mvp/obj/`
  - 忽略 `output/`
  - 忽略日志文件

直接收益：

- 后续本地运行不会继续把构建缓存和解包输出混进工具目录事实层。

## 5. C++ 原型代码审查结论

本次没有把 `inc/` + `src/` 原型直接转正，原因如下：

1. 它不在当前主构建链中。
2. 存在结构级错误，不适合作为“快速补丁点”。
3. 修复它本身并不能自动提升当前 GUI 的可交付能力。

静态审查确认的高风险点包括：

- `LJFPU_UnpackCore` 头文件缺少 `Cleanup()` 声明，接口与实现脱节。
- `LJFPU_FileHandler::GetPackFilePath()` 假设包文件名为 `pack%04u.ljfp`，与真实 `N.ljfp` 规则不一致。
- `LJFPU_FileHandler::DecryptAndDecompressFile()` 对“未压缩文件”仍然强行进入解压路径。
- `LJFPU_PackInfo::Deserialize()` 把索引条目当成固定 28 字节结构，不适配真实可变长 `.ljpi`。
- `LJFPU_FileHandler` 对散文件 `packIndex == 0` 的读取路径未闭环。
- `LJFPU_MiniZ::GetUncompressedSize()` 的尺寸探测策略粗糙。
- `LJFPU_SMS4.cpp` 的实现细节需要重新和真实库比对，不能直接作为算法可信基线。

建议：

- 把这套代码继续保留为“原型/逆向参考”，但不要当成生产后端。
- 若未来真要重建本目录内的独立原生解包器，应先以 `SuperLJFilePackUnpack` 的现行格式与行为为基线重写，而不是在原型上增量打补丁。

## 6. 代码变更记录

本次实际改动如下：

- `gui-mvp/MainForm.cs`
  - 重构为后端自适应模式，加入诊断参数与日志限流。
- `gui-mvp/UnpackCliSupport.cs`
  - 新增 CLI 识别、命令构造、兼容性检查、进度解析逻辑。
- `scripts/Build-MVP-OneClickUnpacker.ps1`
  - 改为按实物工程自适应构建并瘦身分发目录。
- `README.md`
  - 重写目录职责说明。
- `gui-mvp/README.md`
  - 重写 GUI 使用与协议边界说明。
- `.gitignore`
  - 新增工具目录缓存治理规则。

## 7. 目录清理清单

### 已删除

- `tools/LJFilePackUnpacker/docs/02-LJFilePackUnpacker全量技术分析报告.md`
  - 与同目录 canonical 报告命名近似，造成事实入口重复。

### 建议清理并已执行

- `tools/LJFilePackUnpacker/gui-mvp/bin/`
  - 可再生构建输出。
- `tools/LJFilePackUnpacker/gui-mvp/obj/`
  - 可再生中间产物。

### 保留

- `tools/LJFilePackUnpacker/dist/mvp/`
  - 交付目录，保留。
- `tools/LJFilePackUnpacker/docs/02-LJFilePackUnpacker-全量技术分析报告.md`
  - 作为历史基线保留。
- `tools/LJFilePackUnpacker/inc/` 与 `src/`
  - 尽管不是主构建链，但仍保留为原型审查资料。

## 8. 后续建议

### 建议 1：确定唯一 CLI 主线

应明确以下二选一：

- 继续以 `ljfp-unpack.exe` 为 GUI 主线。
- 正式切换到 `ljfp-unpack-diag.exe`，并同步统一协议。

若长期保持双轨并存，文档和脚本还会继续漂移。

### 建议 2：把“格式事实”与“工具包装”彻底分离

- 格式与算法事实：放到 `dependencies/LJFilePack`、`dependencies/SuperLJFilePackUnpack`
- GUI、脚本、分发与使用说明：放到 `tools/LJFilePackUnpacker`

### 建议 3：为 GUI 增加轻量回归检查

可在后续加入最小级别自动化验证：

- 参数生成单测
- 进度格式解析单测
- CLI 解析/回退策略单测

### 建议 4：若要重启本地 C++ 原型，先重定目标

推荐目标不是“把旧原型修到能跑”，而是：

1. 先以真实 `.ljpi/.ljzip` 格式为准。
2. 直接复用或映射 `SuperLJFilePackUnpack` 的现行行为。
3. 再决定是否保留独立原生 GUI。

## 9. 结论

本次优化的重点不是替换解包内核，而是把 `tools/LJFilePackUnpacker` 从“事实漂移、入口混杂、缓存易膨胀”的状态，整理成“前后端边界清楚、构建链自适应、GUI 可兼容当前 CLI 形态、目录更干净”的状态。

这一步已经把当前工具目录最影响维护效率的架构性问题解决掉了。后续若继续深入，应转向统一 CLI 主线与补充自动化验证，而不是回到历史原型上继续做表层修补。
