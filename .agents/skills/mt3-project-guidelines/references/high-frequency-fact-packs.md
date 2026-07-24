# MT3 高频任务最小事实包模板

本文件用于收敛高频构建/UI 任务的最小取证字段，减少“先猜、后返工、再补日志”的往返成本。

使用方式：

- 用户信息很薄时，用对应模板组织你的首轮检查和后续输出。
- 需要向用户补充关键信息时，优先从对应模板里挑最少字段问，不要重新发明问法。
- 作为技能输出模板时，优先保留“首个阻塞点、环境事实、下一步动作”三类信息。

## 1. Windows v120 构建事实包

适用技能：

- `windows-v120-build`
- `mt3-project-guidelines`

```md
# Windows v120 构建事实包
- 目标工程：
- 构建配置：Debug / Release / Both
- 入口命令：
- 首个阻塞错误：
- 首个失败工程/目标：
- `PlatformToolset`：
- `vcvarsall.bat` 路径：
- `MSBuild.exe` 路径：
- 是否命中 ABI 敏感头文件：是 / 否
- 是否已跑 `verify-build-env.ps1`：是 / 否
- 是否已跑 canonical build 入口：是 / 否
- 相关日志路径：
```

最少结论要求：

- 当前入口是否正确
- 当前工具链是否仍为 `VS2013 + v120`
- 首个阻塞点是什么
- 下一步是修环境、修入口还是修代码

## 2. Android r16/Ant 构建事实包

适用技能：

- `android-r10e-build`
- `platform-bridge`
- `mt3-project-guidelines`

```md
# Android r16/Ant 构建事实包
- 目标工程：
- 渠道：free / monthpayment / other
- 入口命令：
- 首个阻塞错误：
- `ndk-build` 路径（当前免费服应为 NDK r16）：
- `ant` 路径：
- `java/javac` 版本：
- `aapt` 路径：
- 是否已跑 `verify-android-r10e-env.ps1`：是 / 否
- 是否涉及 JNI：是 / 否
- 是否涉及渠道 SDK：是 / 否
- 是否涉及 `adb logcat` 运行时崩溃：是 / 否
- APK 产物路径：
- 相关日志路径：
```

最少结论要求：

- 当前是否仍在 `NDK r16 clang + Ant + JDK 8` 主线
- 首个阻塞点在环境、构建顺序、渠道工程还是运行时
- 下一步是修环境、修工程文件还是修平台桥接

## 3. CEGUI/Lua UI 集成事实包

适用技能：

- `cegui-layout-integration`
- `lua-dialog-integration`
- `rendering-pipeline`

```md
# CEGUI/Lua UI 集成事实包
- 目标布局：
- 目标 Lua 脚本：
- 首个报错：
- 问题类型：layout / scheme / looknfeel / imageset / font / getWindow 路径 / 渲染显示
- 根窗口名：
- 受影响控件路径：
- 受影响资源名（scheme/looknfeel/imageset/font）：
- 是否已跑 `check-cegui-bindings.ps1`：是 / 否
- 是否已跑 `check-lua-ui-bindings.ps1`：是 / 否
- 是否同时命中渲染异常：是 / 否
- 截图或录屏：
- 日志路径：
```

最少结论要求：

- 首个阻塞点在资源链、布局链还是 Lua 路径链
- 是否属于静态闭环缺口，还是运行时渲染问题
- 下一步是修资源、修布局命名还是切到渲染技能
