# MT3 — Cocos2d-x 3.0-oh & CEGUI 0.7.9-r5 双引擎升级

MT3 游戏客户端，基于 Cocos2d-x 3.0-oh 与 CEGUI 0.7.9-r5 的双引擎升级方案。

## 技术栈

| 层 | 技术 |
|---|---|
| 游戏引擎 | Cocos2d-x 3.0-oh (CMake + VS2013 v120) |
| UI 框架 | CEGUI 0.7.9-r5 (Crazy Eddie's GUI) |
| 自研引擎 | Nuclear (场景/世界/精灵/动画/特效) |
| 脚本 | Lua 5.1 + tolua++ |
| 平台 | Win32 / Android / iOS |
| 服务端 | Java + Ant + gnet/XBean |
| 构建工具 | MSBuild 12.0 (VS2013 v120) / NDK r16b / CMake 3.10 |

## 目录结构

```
MT3/
├── client/                  # 客户端
│   ├── FireClient/          # 共享业务层 (C++/Lua)
│   ├── MT3Win32App/         # Win32 壳层
│   └── android/             # Android 壳层
├── engine/                  # Nuclear 自研引擎
├── cocos2d-x-2.2.6/         # 原 Cocos2d-x 2.2.6 (历史主线)
├── cocos2d-x-3.0-oh/        # Cocos2d-x 3.0-oh (升级目标)
├── common/                  # 公共库 (platform/ljfm/tolua++)
├── server/                  # 服务端 (Java/Ant)
├── tools/
│   ├── CEGUI-0.7.9-r5/      # CEGUI 0.7.9-r5 源码 (升级目标)
│   └── scripts/             # 构建与验证脚本
├── dependencies/            # 第三方依赖
├── docs/                    # 项目文档
└── gbeans/                  # 配置源定义
```

## 构建

### Win32 (VS2013 v120)
```powershell
tools/scripts/Build-MT3-Exe-Canonical.ps1
```

### CEGUI 0.7.9-r5
```powershell
# Debug
msbuild tools/CEGUI-0.7.9-r5/cegui-0.7.9.win32.vcxproj /p:Configuration=Debug /p:Platform=Win32

# Release
msbuild tools/CEGUI-0.7.9-r5/cegui-0.7.9.win32.vcxproj /p:Configuration=Release /p:Platform=Win32
```

### Cocos2d-x 3.0-oh (CMake)
```powershell
mkdir build && cd build
cmake -G "Visual Studio 12 2013" ..
```

## 升级路线

详见 [MT3 双引擎升级方案](docs/MT3-双引擎升级方案-cocos2d-x-3.0-oh-CEGUI-0.7.9-r5.md)

## 许可证

内部项目，版权归原作者所有。