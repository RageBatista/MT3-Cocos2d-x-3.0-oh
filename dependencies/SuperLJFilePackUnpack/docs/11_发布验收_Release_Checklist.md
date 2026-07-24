# 11 发布验收清单

> 基准日期: 2026-04-22
> 适用范围: `dependencies/SuperLJFilePackUnpack`

## 1. 构建前提

- Windows 主线工具链保持项目现状
- `build/` 是本地生成目录，不要求目录预存在仓库里
- 若需 GUI，机器必须具备 wxWidgets
- 同一 `build/` 目录不要并行跑多个 `cmake --build` 或“重编 + 运行测试”，否则在 Windows 下容易撞到 `LNK1104`

## 2. 推荐构建步骤

```powershell
Set-Location E:\MT3\dependencies\SuperLJFilePackUnpack
New-Item -ItemType Directory -Force build | Out-Null
Set-Location build
cmake .. -G "Visual Studio 12 2013" -DBUILD_TESTS=ON -DBUILD_EXAMPLES=ON -DBUILD_GUI=ON
cmake --build . --config Release --target ljfp-test
cmake --build . --config Release --target ljfp-unpack
cmake --build . --config Release --target ljfp-unpack-diag
cmake --build . --config Release --target ljfp-gui
```

如果本机没有 wxWidgets，可以跳过 `ljfp-gui`。

## 3. 必跑验证

至少执行：

```powershell
.\bin\Release\ljfp-test.exe
ctest -C Release --output-on-failure
```

当前最新测试基线是：

- `ljfp-test.exe`：`265/265`
- `ctest -C Release --output-on-failure`：`1/1`
- `python -m unittest tools/tests/test_manifest_seed_pipeline.py`：`3/3`

## 4. 可执行物核对

按当前配置，至少核对：

- `build\bin\Release\ljfp-test.exe`
- `build\bin\Release\ljfp-unpack.exe`
- `build\bin\Release\ljfp-unpack-diag.exe`
- `build\bin\Release\LJFilePackUnpacker.exe`（若 GUI 构建开启且依赖满足）
- `build\lib\Release\SuperLJFilePackUnpack.lib`

## 5. 安装与打包

```powershell
cpack -C Release --verbose
cmake -DCMAKE_INSTALL_PREFIX=E:/MT3/dependencies/SuperLJFilePackUnpack/build/install-release -P cmake_install.cmake
```

或在支持的环境下：

```powershell
cmake --install . --config Release --prefix .\install-release
```

当前安装文档应至少包含：

- `README.md`
- `DOCS_INDEX.md`
- `RELEASE_CHECKLIST.md`
- `CURRENT_STATE_AUDIT.md`

## 6. GUI Smoke

至少覆盖一次完整闭环：

1. 打开索引
2. 设置输出目录
3. 加载或生成映射
4. 选择预设
5. 启动解包
6. 执行一次暂停 / 恢复
7. 执行一次停止
8. 检查结果审阅页
9. 导出失败项
10. 对一个问题组复跑

## 7. 发布门槛

以下任一项不满足，不应标记为发布候选：

- `ljfp-test.exe` 非全绿
- `ctest` 存在失败
- `manifest_seed_pipeline.py` 的 Python 单测存在失败
- 目标可执行物与 README / docs 不一致
- 安装或打包失败
- GUI 主闭环没有 smoke 记录（当 GUI 作为交付物时）

## 8. 附带记录建议

建议在发布说明里附上：

- 构建命令
- 测试总数与通过数
- 是否包含 GUI
- 是否包含示例 CLI
- 失败项是否为 0
- 未解决风险与回滚方式
