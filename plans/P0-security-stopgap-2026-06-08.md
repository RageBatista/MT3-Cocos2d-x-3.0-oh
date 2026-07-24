# P0 安全止血任务单（Security Stopgap）

> 创建日期：2026-06-08  
> 严重程度：致命  
> 优先级：P0  
> 状态：待执行  
> 负责人建议：客户端负责人 + 安全负责人 + 运维/账号系统负责人

## 目标

立即止血 MT3 客户端与工具链中已确认的高危安全问题：硬编码凭证、本地明文密码持久化、HTTP/测试地址进入客户端、支付链路疑似携带密码参数。

## 范围

- `client/FireClient/Application/Manager/ReportManager_IOS.h`
- `client/FireClient/Application/Manager/LoginManager.cpp`
- `client/FireClient/Application/Framework/GameApplication.cpp`
- `client/resource/res/script/logic/chargedialog.lua`
- `tools/scripts/**` 中新增或复用安全扫描门禁

## 已确认证据

- `ReportManager_IOS.h:64-66` 存在 FTP 用户名/密码字段（本任务单不记录明文）。
- `LoginManager.cpp:768-800` 存在 `LastPassword`、`passwordN` 等本地密码持久化线索。
- `GameApplication.cpp` 多处存在 `http://`、私网/固定 IP、测试域名线索。
- `chargedialog.lua` 的支付请求参数包含 `account`、`roleid`、`password`、`paytype` 等字段。

## 执行项

### 1. 凭证轮换与源码清除

- [ ] 由运维/安全负责人轮换 `ReportManager_IOS.h` 中对应账号的真实密码。
- [ ] 确认旧凭证不可再登录。
- [ ] 删除源码中的硬编码用户名/密码，改为安全配置、服务端签发或短期 token。
- [ ] 确认客户端日志、崩溃日志、上传日志不输出凭证原文。

### 2. 停止保存真实账号密码

- [ ] 移除 `LoginManager.cpp` 中 `LastPassword` 的真实密码写入。
- [ ] 移除 `AccountList/passwordN` 的真实密码写入。
- [ ] 如仍需自动登录，改用短期 token、平台 SDK session 或系统安全存储。
- [ ] 增加历史配置清理逻辑：首次启动清理旧配置中的真实密码字段。

### 3. HTTP、私网 IP、测试域名门禁

- [ ] 将 `GameApplication.cpp` 中硬编码地址迁移到明确环境配置源。
- [ ] 区分 dev/test/prod，发布包不得携带测试域名或私网 IP。
- [ ] 新增或复用发布前扫描脚本，阻断以下内容：
  - 真实凭证
  - `http://` 生产地址
  - 私网 IP
  - 测试域名
  - 明文 crash/report/upload 地址

### 4. 支付参数安全整改

- [ ] 确认服务端支付接口是否仍需要 `password` 参数。
- [ ] 移除支付请求中的真实密码参数，改为短期 token、订单签名或服务端态校验。
- [ ] 客户端、服务端、网关、支付回调日志全部做脱敏验证。
- [ ] 支付失败提示必须保留订单号或可追踪流水，便于客服定位。

## 建议验证命令

```powershell
# 硬编码敏感信息回扫
rg -n --glob '!dependencies/**' --glob '!build/**' --glob '!build_logs/**' --glob '!Testing/**' -i "(sPassWord|LastPassword|passwordN|api[_-]?key|secret|token\s*=|BEGIN .*PRIVATE KEY)" client common server tools .claude .codex .agents

# HTTP / 私网 / 测试域名回扫
rg -n --glob '!dependencies/**' --glob '!build/**' --glob '!build_logs/**' --glob '!Testing/**' -i "(http://|192\.168\.|127\.0\.0\.1|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|testot|test|dev)" client/FireClient/Application client/resource/res/script common tools/scripts

# Win32 构建验证
powershell -ExecutionPolicy Bypass -File .\tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release
```

## 验收标准

- [ ] 已轮换风险凭证，旧凭证不可用。
- [ ] 仓库不再包含真实 FTP 密码或等价明文凭证。
- [ ] 客户端不再持久化真实账号密码。
- [ ] 支付请求不再携带真实密码。
- [ ] 发布门禁能阻断真实凭证、HTTP、私网 IP、测试域名。
- [ ] Win32 Release 构建通过，无新增编码/ABI 问题。

## 回滚策略

- 凭证轮换不可回滚到旧密码。
- 客户端改造异常时，可短期保留服务端双栈兼容 token 与旧接口，但不得恢复明文密码方案。

