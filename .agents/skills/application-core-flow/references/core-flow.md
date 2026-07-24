# 应用核心主链参考

## 共享入口

- Win32 入口：`client/MT3Win32App/main.cpp`
- 共享主链入口：`gRunGameApplication()`
- 主应用类：`client/FireClient/Application/Framework/GameApplication.cpp`

## 初始化阶段

`GameApplication::OnInit(int step)` 是共享主链的阶段式初始化入口。分析启动问题时，先确定卡在哪个阶段，再追该阶段依赖的管理器或资源。

重点关注：

- Framework 初始化
- Manager 注册与单例拉起
- 网络与协议准备
- UI 与场景框架接管
- 角色登录、选角、入世界前置准备

## 核心业务模块

| 目录 | 作用 |
|---|---|
| `Application/Framework` | 应用主循环、生命周期、总入口控制 |
| `Application/Manager` | 登录、网络、UI、音频、配置等管理器 |
| `Application/SceneObj` | 地图、角色、场景对象与世界表现 |
| `Application/Battle` | 战斗主流程、表现与状态同步 |
| `Application/GameUI` | FireClient 侧界面逻辑和交互管理 |

## 关键 API 锚点

- `GetEngine()`
- `IWorld::NewSprite(...)`
- `IWorld::AttachSprite(...)`
- `IQuery::GetActionInfo(...)`
- `IEnv`

这些接口分别对应引擎访问、世界对象创建、动作信息查询和环境抽象，是共享层排障时最常见的真实 API 锚点。

## 登录到入世界

优先按下面顺序定位：

1. `LoginManager` 是否完成登录态切换
2. 网络回包是否驱动到角色/世界准备逻辑
3. 场景对象是否开始创建与挂接
4. UI 是否等待某个前置状态，导致表面上像“卡登录”

## 边界

- 还在平台壳层入口、JNI、ObjC++ 或 SDK 回调时，不用本技能，改用 `platform-bridge`
- 症状出现在补丁包、资源索引或下载器层面时，改用 `resource-packaging-pipeline`
