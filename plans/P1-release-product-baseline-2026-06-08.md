# P1 发布与产品验收基线任务单（Release Product Baseline）

> 创建日期：2026-06-08  
> 严重程度：严重  
> 优先级：P1  
> 状态：待执行  
> 负责人建议：产品经理 + QA 负责人 + 发布负责人 + 客服/运营负责人

## 目标

建立 MT3 当前有效的发布清单、玩家路径验收基线与客服定位手册，避免“功能存在但不可验证、不可运营、不可定位”。

## 范围

- `docs/03-开发指南/功能规格书索引-Functional-Specification-Index.md`
- `docs/03-开发指南/跨平台功能对比规格书-Cross-Platform-Functional-Comparison.md`
- `docs/03-开发指南/16-资源打包与热更新避坑与发布检查清单.md`
- `docs/06-工具链/workflows/正式包发布流程-Release-Package-Workflow.txt`
- `docs/05-平台专项/android/02-打包前检查清单.md`
- `docs/05-平台专项/ios/01-iOS发布前10项闸门清单.md`
- `scheme_doc/策划文档/**`
- `scheme_doc/测试文档/**`

## 已确认证据

- 功能规格书显示多端功能已实现/通过，但审计报告仍指出 Android/iOS/UI/异常处理文档缺失。
- 正式包流程仍包含较多手工改版本、包名、渠道、ICON、自动更新开关步骤。
- 热更新文档具备 CRC/索引/回滚检查，但缺少灰度、监控、客服兜底闭环。
- 客服/玩家问题定位文档偏技术排障，缺少玩家可读错误码与工单字段。

## 执行项

### 1. 当前产品验收基线

- [ ] 新建 `docs/03-开发指南/当前产品验收基线-2026-06-08.md`。
- [ ] 固化 10 条核心玩家路径：
  1. 启动更新
  2. 登录
  3. 选服
  4. 创建角色
  5. 入世界
  6. 战斗
  7. 背包
  8. 商城/充值
  9. 社交/聊天
  10. 客服/公告
- [ ] 每条路径必须包含：
  - 前置条件
  - 操作步骤
  - 成功标准
  - 失败分支
  - 玩家提示文案要求
  - 客服定位字段
  - 技术验证命令或日志入口

### 2. 当前版 Release Checklist

- [ ] 新建 `docs/06-工具链/workflows/当前版发布清单-Release-Checklist-2026-06-08.md`。
- [ ] 将旧正式包流程中的手工项收敛为发布参数表：
  - 版本号
  - 渠道 ID
  - 包名 / Bundle ID
  - 热更新地址
  - 自动更新开关
  - ICON / 渠道资源
  - 签名配置
- [ ] 每个平台列出发布前必跑命令。

建议命令：

```powershell
# Win32
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release -Platform Win32 -BuildMode SafeChain -MaxParallelJobs 8 -StrictRuntimeAudit

# Android
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir "client/android/LocojoyProject" -Channel free -Jobs 4 -CleanIntermediates

# Server
ant -f .\server\server\game_server\build.xml genfiles
ant -f .\server\server\game_server\build.xml dist
```

### 3. 客服定位手册

- [ ] 新建 `docs/04-问题排查/玩家问题客服定位手册-2026-06-08.md`。
- [ ] 覆盖问题类型：
  - 更新失败
  - 登录失败
  - 选服失败
  - 创建角色失败
  - 入世界失败
  - 支付失败
  - UI 按钮无响应
  - 战斗/地图显示异常
- [ ] 工单字段不得包含用户密码。
- [ ] 必填字段：
  - 账号 ID
  - 角色 ID（可为空）
  - 区服
  - 客户端版本
  - 资源版本
  - 平台/渠道
  - 设备型号/系统版本
  - 订单号（支付问题必填）
  - 截图/错误码
  - 发生时间

### 4. 当前有效策划/测试资产索引

- [ ] 新建 `docs/10-管理文档/当前有效策划测试资产索引-2026-06-08.md`。
- [ ] 盘点 `scheme_doc/策划文档/**` 与 `scheme_doc/测试文档/**`。
- [ ] 每个资产标记为：
  - 当前有效
  - 历史参考
  - 已废弃
  - 需产品确认
  - 需迁移到 docs 当前基线
- [ ] 只有产品确认的当前有效资产才能迁移到 docs 当前基线。

## 验收标准

- [ ] 10 条核心玩家路径均有验收标准与失败分支。
- [ ] 当前版 Release Checklist 覆盖 Win32、Android、iOS、Server、资源热更。
- [ ] 客服手册不要求、不记录、不展示用户密码。
- [ ] 策划/测试资产索引明确当前有效、历史参考、废弃与需确认状态。
- [ ] 文档不把历史审计快照写成当前工程事实。

## 回滚策略

- 若新文档与工程事实冲突，以源码、构建脚本、`AGENTS.md`、`.claude/RULES.md`、`.claude/BUILD_GUIDE.md` 为准修正文档。
- 不删除旧文档；旧文档在当前索引中降级为历史参考。

