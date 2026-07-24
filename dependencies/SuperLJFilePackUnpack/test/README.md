# SuperLJFilePackUnpack 测试说明

> 基准日期: 2026-04-22

## 1. 测试框架

当前使用项目内置轻量测试框架：

- 入口：`Test_Main.cpp`
- 框架头：`SLJFP_TestFramework.h`

不是 Google Test，也不依赖外部测试运行器。

## 2. 当前测试文件与用例数

| 文件 | 用例数 |
|------|-------:|
| `Test_CRC32.cpp` | 8 |
| `Test_Compression.cpp` | 10 |
| `Test_SMS4.cpp` | 13 |
| `Test_Unpacker.cpp` | 123 |
| `Test_AndroidBinaryKey.cpp` | 2 |
| `Test_Integration.cpp` | 6 |
| `Test_FileTypeDetector.cpp` | 71 |
| `Test_PathMappingGenerator.cpp` | 31 |
| `Test_WorkflowSession.cpp` | 3 |
| `Test_WorkflowPresenter.cpp` | 4 |
| `Test_WorkflowReviewController.cpp` | 3 |
| `Test_WorkflowReviewExportService.cpp` | 3 |
| `Test_UnpackExampleHelp.cpp` | 5 |
| `Test_RegressionFixtures.cpp` | 1 |

合计当前注册测试：`283`

## 3. 构建

`build/` 是本地生成目录，不要求仓库内预置：

```powershell
Set-Location E:\MT3\dependencies\SuperLJFilePackUnpack
New-Item -ItemType Directory -Force build | Out-Null
Set-Location build
cmake .. -G "Visual Studio 12 2013" -DBUILD_TESTS=ON
cmake --build . --config Release --target ljfp-test
```

如需测试数据生成器：

```powershell
cmake --build . --config Release --target ljfp-testgen
```

## 4. 运行

### 全量

```powershell
.\bin\Release\ljfp-test.exe
```

### 常用过滤

```powershell
.\bin\Release\ljfp-test.exe CRC32
.\bin\Release\ljfp-test.exe SMS4
.\bin\Release\ljfp-test.exe Compression
.\bin\Release\ljfp-test.exe Integration
.\bin\Release\ljfp-test.exe Unpacker
.\bin\Release\ljfp-test.exe FileType
.\bin\Release\ljfp-test.exe PathMapping
```

当前过滤规则是“测试名包含子串即可”。

## 4.1 当前实测基线

2026-04-30 本轮实测：

- `.\bin\Release\ljfp-test.exe`：`283/283`
- `ctest -C Release --output-on-failure`：`2/2`

## 5. 当前重点覆盖面

除了基础 CRC / 压缩 / SMS4，当前测试还覆盖：

- `.ljzip` 坏包与截断包边界
- `PathMappingGenerator` 默认和兼容哈希模式
- Android `libgame.so` key 提取
- 解密探针诊断
- GUI 审阅工作流模型
- 失败项导出
- `orange_subset` 差异化回归夹具
- 安装导出后的包消费验证
- manifest 物理路径对账与扩展名一致性审计

## 6. 维护建议

每次新增解包行为或坏包校验时，优先把回归补到：

- `Test_Unpacker.cpp`
- `Test_PathMappingGenerator.cpp`

如果涉及 GUI 审阅逻辑，再补：

- `Test_WorkflowPresenter.cpp`
- `Test_WorkflowReviewController.cpp`
- `Test_WorkflowReviewExportService.cpp`
