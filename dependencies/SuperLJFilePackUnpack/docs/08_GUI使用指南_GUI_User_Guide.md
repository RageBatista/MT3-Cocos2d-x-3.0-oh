# 08 GUI 使用指南

> 基准日期: 2026-04-22
> 事实源: `gui/SLJFP_MainFrame.*`、`gui/SLJFP_WorkflowSession.h`

## 1. 程序组成

GUI 当前由以下部分组成：

- `SLJFP_App`
  - wxWidgets 程序入口
- `MainFrame`
  - 主窗口、工作流、配置面板、结果审阅页
- `ProgressDialog`
  - 独立进度窗口
- `WorkflowSessionController`
  - 会话状态
- `WorkflowPresenter`
  - 结果页/概览页模型
- `WorkflowReviewController`
  - 过滤、定位、复跑逻辑

## 2. 主界面结构

### 左侧

- 资源树
- 按来源和筛选模式组织文件

### 右侧

- 工作流控制区
- 文件列表页
- 预览页
- 配置页
- 结果审阅页
- 概览与状态文本

## 3. 工作流区

顶部工作流状态固定为四步：

1. 索引
2. 映射
3. 输出
4. 解包

快速按钮包括：

- 打开资源目录
- 打开索引文件
- 设置输出目录
- 加载映射
- 生成/合并路径映射
- 一键解包
- 暂停 / 继续
- 停止

## 4. 配置页实际暴露项

GUI 当前真正暴露的配置包括：

- 验证 CRC32
- 覆盖已存在文件
- 按文件类型分类存放
- 启用流式解包
- 流式块大小（MB）
- 自动加载同目录映射
- 线程数
- 解密模式
- Android `libgame.so` 路径
- 解密 key
- 映射前缀
- 映射历史

当前没有显式暴露、会继续沿用 `UnpackOptions` 默认值的高级项包括：

- `forceCrcOutputFirst = false`
- `restorePathStructureAfterUnpack = false`
- `strictRestoreValidation = false`
- `relocateRootNumericResiduals = false`
- `writeReviewAliases = false`

## 5. 解密模式下拉框

当前三项与枚举直接对应：

- 自动探测 -> `DecryptMode::Auto`
- LJFilePack-SMS4 -> `DecryptMode::LJFilePackSMS4`
- APK-ClientObf -> `DecryptMode::ApkClientObf`

## 6. 当前预设

### 标准闭环

- `verifyCRC32 = true`
- `overwriteExisting = false`
- `organizeByType = true`
- `useStreamMode = false`
- `streamChunkMB = 4`
- `threadCount = 4`

### 快速审阅

- `verifyCRC32 = false`
- `overwriteExisting = false`
- `organizeByType = false`
- `useStreamMode = false`
- `threadCount = 2`

### 长任务/大文件

- `verifyCRC32 = true`
- `overwriteExisting = false`
- `organizeByType = true`
- `useStreamMode = true`
- `streamChunkMB = 8`
- `threadCount = 6`

## 7. 自动映射行为

### 7.1 自动加载

打开索引后，如果启用了“自动加载同目录映射”，GUI 会优先尝试：

- 最近一次加载/生成的映射
- 同目录常见命名
- 含 `mapping/path/crc` 关键字的文件

支持：

- `.ljpm`
- `.txt`
- `.map`
- `.csv`

### 7.2 自动重建

命中率不足时，GUI 会尝试：

1. 收集参考资源目录
2. 合并扫描目录生成映射
3. 调用 `manifest_seed_pipeline.py` 做 txt manifest 补种（脚本存在时）
4. 调用 `source_template_seed_pipeline.py` 做“源码模板 + 配置变量 + CRC 精确命中”补种（脚本存在时）
5. 重新加载映射并复核命中率

GUI 当前把 `>= 95%` 视为“映射基本健康”的阈值；低于这个阈值时会主动提示继续补全。

补充说明：

- 第 3 步更适合“目录清单 / manifest 已存在”的场景
- 第 4 步更适合“客户端源码、Lua、XML、auto 或 `map.cmapconfig.bin` 里仍保留模板变量”的场景
- 两步都只在脚本、Python 和可用输入根目录可被检测到时才执行，不会阻断原有 GUI 流程

## 8. 解包流程

点击“一键解包”后，当前实际流程是：

1. 校验索引已加载
2. 校验输出目录
3. 组装 `UnpackOptions`
4. 尝试保证映射可用
5. 创建 `ProgressDialog`
6. 启动 `UnpackThread`
7. 在完成后刷新结果审阅页、概览页和状态栏

补充：

- GUI 会在启动前调用 `EnsureUsablePathMapping()`
- 若命中率不足，会先尝试补全映射再继续执行
- GUI 启动的是后台 `UnpackThread`，不是主线程直跑

## 9. 结果审阅页

结果审阅页当前支持：

- 汇总失败组
- 根据失败组定位文件
- 对问题组复跑
- 导出失败项
- 清除审阅过滤
- 打开输出目录

这是当前 GUI 与旧版说明相比最容易被低估的一块能力。

## 10. 暂停 / 恢复 / 停止

当前 GUI 会把暂停状态同步到底层解包器：

- `SetPaused(true/false)`
- `Stop()`

特性：

- 暂停是协作式的，不是抢占式线程冻结
- 停止会尽量在当前处理点安全退出

## 11. 当前限制

以下限制仍然真实存在：

- 预览页主要展示元信息，不是通用资源渲染器
- GUI 没有把全部高级恢复选项做成显式控件
- GUI 默认不是 CLI 那条固定两阶段恢复主链
- wxWidgets 依赖不可用时，GUI 目标不会生成

## 12. 使用建议

### 首次排障

- 用“标准闭环”
- 先看命中率
- 再看结果审阅页

### 大文件任务

- 用“长任务/大文件”
- 显式指定解密模式会更稳

### 想快速浏览样本

- 用“快速审阅”
- 先关 CRC，再抽样定位失败组
