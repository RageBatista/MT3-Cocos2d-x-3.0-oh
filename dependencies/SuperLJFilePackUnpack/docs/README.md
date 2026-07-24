# SuperLJFilePackUnpack 文档导航

> 基准日期: 2026-04-22
> 文档事实源: `dependencies/SuperLJFilePackUnpack` 当前源码、CMake、测试与清理后的目录状态

## 阅读顺序

首次接手建议按下面顺序阅读：

1. [01_工具概述_Tool_Overview.md](01_工具概述_Tool_Overview.md)
2. [02_快速开始_Quick_Start.md](02_快速开始_Quick_Start.md)
3. [03_API接口_API_Reference.md](03_API接口_API_Reference.md)
4. [08_GUI使用指南_GUI_User_Guide.md](08_GUI使用指南_GUI_User_Guide.md)
5. [12_现状审计与目录清理报告_Current_State_Audit.md](12_现状审计与目录清理报告_Current_State_Audit.md)

## 文档分层

### 规范性文档

以下文档直接承担“当前怎么用、当前有什么、当前限制是什么”的职责：

- [01_工具概述_Tool_Overview.md](01_工具概述_Tool_Overview.md)
- [02_快速开始_Quick_Start.md](02_快速开始_Quick_Start.md)
- [03_API接口_API_Reference.md](03_API接口_API_Reference.md)
- [06_错误代码_Error_Codes.md](06_错误代码_Error_Codes.md)
- [07_性能优化_Performance.md](07_性能优化_Performance.md)
- [08_GUI使用指南_GUI_User_Guide.md](08_GUI使用指南_GUI_User_Guide.md)
- [08_常见问题_FAQ.md](08_常见问题_FAQ.md)
- [11_发布验收_Release_Checklist.md](11_发布验收_Release_Checklist.md)
- [12_现状审计与目录清理报告_Current_State_Audit.md](12_现状审计与目录清理报告_Current_State_Audit.md)

### 实现细节与补充分析

以下文档保留为深挖材料，主要解释“为什么这样设计”或“对应原始 LJFilePack 的关系”：

- [04_文件格式_File_Format.md](04_文件格式_File_Format.md)
- [05_解包算法_Unpacking_Algorithm.md](05_解包算法_Unpacking_Algorithm.md)
- [06_客户端资源读取逻辑分析__Client_Resource_Loading_Analysis.md](06_客户端资源读取逻辑分析__Client_Resource_Loading_Analysis.md)
- [09_运行时密钥抓取_Runtime_Key_Probe.md](09_运行时密钥抓取_Runtime_Key_Probe.md)
- [10_原始打包-逆向解包对照分析__Pack_Unpack_Correspondence_Report.md](10_原始打包-逆向解包对照分析__Pack_Unpack_Correspondence_Report.md)
- [13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md](13_路径CRC32精确恢复规则_Path_CRC32_Exact_Recovery.md)
- [14_源码可提取路径模板清单_Path_Template_Inventory.md](14_源码可提取路径模板清单_Path_Template_Inventory.md)
- [15_源码模板补种工作流_Source_Template_Seeding_Workflow.md](15_源码模板补种工作流_Source_Template_Seeding_Workflow.md)
- [16_模块边界与运行治理_Module_Boundaries.md](16_模块边界与运行治理_Module_Boundaries.md)

### 开发辅助资产

以下内容属于开发/排障辅助层，不属于常规用户入口：

- [tools/README.md](../tools/README.md)
- [tools/runtime/README.md](../tools/runtime/README.md)
- [tools/tests/README.md](../tools/tests/README.md)
- [tools/extension_mismatch_classifier.py](../tools/extension_mismatch_classifier.py)

## 当前目录与入口事实

当前源码目录只保留：

- `cmake/`
- `docs/`
- `examples/`
- `gui/`
- `include/`
- `libs/`
- `src/`
- `test/`
- `tools/`

以下路径按规则视为本地生成物或临时物，不作为源码目录事实：

- `build/`
- `test_output/`
- `tools/**/__pycache__/`
- `include/tmp_`
- `gui/temp_bom_file`

## 当前功能入口

当前实际可用的执行入口是：

- GUI：`ljfp-gui`
  - 实际输出文件名：`LJFilePackUnpacker.exe`
- CLI 示例：`ljfp-unpack`
- CLI 诊断：`ljfp-unpack-diag`
- GUI/CLI 共享路径映射生成：`SLJFP::PathMappingGenerator`
- 清单补种脚本：`tools/manifest_seed_pipeline.py`

当前不再保留独立的 `PathMappingGenerator.exe` 叙述，也不再把 `BUILD_CLI` 当作真实主入口。

## 当前验证基线

2026-04-30 最新验证结果：

- `ljfp-test.exe` 全量通过，`283/283`
- `ctest -C Release --output-on-failure` 通过，`2/2`
- `python -m unittest tools/tests/test_manifest_seed_pipeline.py tools/tests/test_source_template_seed_pipeline.py tools/tests/test_extension_mismatch_classifier.py` 通过，`10/10`

## 代码事实源

优先以以下文件为准：

- `CMakeLists.txt`
- `include/SLJFP_Unpack.h`
- `include/SLJFP_PathMappingGenerator.h`
- `include/SLJFP_FileTypeDetector.h`
- `include/SLJFP_AndroidBinaryKey.h`
- `src/SLJFP_Unpack.cpp`
- `src/SLJFP_UnpackIndexIO.cpp`
- `src/SLJFP_PathMappingGenerator.cpp`
- `src/SLJFP_FileTypeDetector.cpp`
- `gui/SLJFP_MainFrame.*`
- `gui/SLJFP_WorkflowSession.h`
- `test/Test_Main.cpp`
