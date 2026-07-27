# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MT3（梦幻西游 MG 版本）是一个 2D MMORPG 商业游戏，代码规模约 530 万行，涵盖 C++、Lua、Java 和工具代码。

## Key Entry Points (Priority Order)

1. **AGENTS.md** — Repository facts, task routing, root-level boundaries (read every session)
2. **RULES.md** — Toolchain constraints, ABI safety, generated code rules
3. **BUILD_GUIDE.md** — Verified build commands for current machine
4. **CLAUDE.md** — This file, configuration explanation

## Four-Layer Architecture

```
FireClient Business Layer (C++/Lua/CEGUI/Protocol/Manager/Battle/SceneObj)
    ↓
Nuclear Engine Layer (Scene/Sprite/Animation/Effects/Rendering)
    ↓
Cocos2d-x Base Layer (Win32: 2.2.6; Android: 2.2.6; iOS: 2.2.6)
    ↓
Platform Layer (Win32/Android/iOS lifecycle and channel bridges)
```

## Key Subsystems

| Subsystem | Path | Description |
|-----------|------|-------------|
| Platform Shell | `client/MT3Win32App/`, `client/android/` | Process entry, lifecycle, window/input |
| FireClient | `client/FireClient/Application/` | Network, UI, Lua scripting, business logic |
| Nuclear Engine | `engine/` | Scene, world, sprite, map, animation, effects |
| Server | `server/server/game_server/` | Java/Ant + gnet/XBean |
| Resources | `client/resource/res/` | Lua scripts, UI config, game resources |

## Build Commands

### Win32 Client (VS2013 v120)

```powershell
# Standard build (recommended entry point)
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Release

# Fast local debug build
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-Exe-Canonical.ps1 -Configuration Debug -FastLocal -MaxParallelJobs 8

# Full validation (Debug + Release + runtime audit)
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-MT3-FullValidation.ps1 -Configuration Both
```

### Android (Locojoy free channel)

```powershell
powershell -ExecutionPolicy Bypass -File tools\scripts\Build-Android-Locojoy-WithGate.ps1 -ProjectDir client\android\LocojoyProject -BuildType Debug -Channel free -Jobs 4
```

### Server

```bash
cd server/server/game_server
ant init      # First-time: genfiles + mhsdcounter.jar
ant genfiles  # Regenerate: genrpc + genxdb + gengbeans + jsconvert
ant dist      # Compile and package
```

## Toolchain Constraints (MANDATORY)

| Platform | Toolchain | Forbidden |
|----------|-----------|-----------|
| Win32 | VS2013 v120 + Windows SDK 8.1 | v140/v141/v142/v143 |
| Android | NDK r16b (16.1.4479499) + Ant + JDK 8 | Gradle, JDK 9+ |
| Server | JDK 1.7/1.8 + Ant | JDK 9+, Maven, Gradle |

## ABI Safety Rules

- `engine/**/*.h` changed → `Rebuild engine → Rebuild FireClient → Build MT3`
- `client/FireClient/Application/**/*.h` changed → `Rebuild FireClient → Build MT3`
- `FireClient.win32.vcxproj` and `mt3.win32.vcxproj` share `$(SolutionDir)$(Configuration).win32` output directory

## Generated Code Boundaries (DO NOT edit manually)

| Generator | Source Definition | Generated Output |
|-----------|------------------|-----------------|
| xbean | `server/**/gsx.mkdb.xml` | `server/**/xbean/*.java`, `xtable/*.java` |
| gnet | `server/server/game_server/protocol.main.xml` | `server/**/rpc/*.java` |
| tolua++ | `client/tolua++-pkgs/**/*.pkg`, `engine/tolua++-pkgs/engine.pkg` | `client/FireClient/Application/Framework/Lua*.cpp` |
| ProtoDef | `client/FireClient/Application/*.xml` + `genprotocol*.bat/.sh` | `ProtoDef/**`, `script/protodef/**` |

## Development Skills Reference

- **C++ Development**: `.claude/skills/client/cpp-development.md`
- **Lua Scripting**: `.claude/skills/client/lua-scripting.md`
- **Java Server**: `.claude/skills/server/java-development.md`
- **gbean System**: `.claude/skills/server/xbean-system.md`
- **gnet Framework**: `.claude/skills/server/gnet-framework.md`
- **Build Troubleshooting**: `.claude/skills/common/build-troubleshooting.md`

## Rules Documentation Index

| File | Priority | Description |
|------|----------|-------------|
| `.claude/rules/01-toolchain.md` | 🔴 Mandatory | Toolchain constraints |
| `.claude/rules/02-code-style.md` | 🟡 Important | C++/Lua/Java code standards |
| `.claude/rules/03-security.md` | 🔴 Mandatory | Security rules and checklist |
| `.claude/rules/04-generated-code.md` | 🔴 Mandatory | xbean/gnet/tolua++ rules |
| `.claude/rules/08-verification-gates.md` | 🔴 Mandatory | Verification gates and delivery criteria |

## Platform Conditional Compilation

- `WIN32` / `WIN7_32` — Windows desktop
- `ANDROID` — Android
- `OS_IOS` / `_OS_IOS` — iOS
- `CC_TARGET_PLATFORM == CC_PLATFORM_IOS/ANDROID/WIN32` — Cocos2d-x macros

iOS-specific implementations live in `.mm` files (e.g., `IOSDeviceInfo.mm`)

## Documentation Hierarchy

Priority (highest first): engineering files → `AGENTS.md` → `.claude/RULES.md` → `.claude/BUILD_GUIDE.md` → `.claude/config/*.json` → `.claude/CLAUDE.md`
