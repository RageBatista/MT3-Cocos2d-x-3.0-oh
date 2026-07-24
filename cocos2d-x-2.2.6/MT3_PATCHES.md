# MT3 Cocos2d-x 2.2.6 Local Patches

This file records MT3-specific patches applied on top of upstream Cocos2d-x 2.2.6.

## Current state

- Upstream 2.2.6 source imported: yes.
- Win32 build-system migration: in progress.
- Engine/FireClient API compatibility patches: active; limited to MT3 audio API shims over the official Win32 MCI backend.

## Patch log

| Area | Files | Reason | Verification |
| --- | --- | --- | --- |
| Upstream import | Whole `cocos2d-x-2.2.6-mt3/` tree | Replace pseudo 2.2.6 tree with real official tag `1fc007df0ed6f01ef458083504260d0752d19049` | Source gate must pass |
| Win32 audio shim | `CocosDenshion/include/SimpleAudioEngine.h`, `CocosDenshion/win32/SimpleAudioEngine.cpp` | Preserve MT3 legacy effect query/priority/enable calls while using the official 2.2.6 MCI backend and removing FMOD | Rebuild `libCocosDenshion`, `engine`, `FireClient`, `MT3` |
| Shader compatibility shim | cocos2dx/shaders/CCShaderCache.*, CCGLProgram.*, ccShaders.*, ccGLStateCache.*, ccShader_PositionTextureColor* | Restore MT3-required shader stack, ETC/HSV/X/Gray shader keys, multi-texture active unit API and part-parameter uniforms without reintroducing old engine projects | msbuild cocos2d.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 and msbuild engine.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 |
| Texture compression compatibility shim | cocos2dx/textures/CCTexture2D.*, cocos2dx/include/ccTypes.h, cocos2dx/CCConfiguration.* | Restore MT3 DDS/ATC/PVRTC/ETC direct texture loading, ETC alpha channel access and texture data URI APIs required by Nuclear renderer assets | msbuild cocos2d.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 and msbuild engine.win32.vcxproj /t:Rebuild /p:Configuration=Release /p:Platform=Win32 |
| Lua script bridge compatibility shim | cocos2dx/script_support/CCScriptSupport.*, scripting/lua/cocos2dx_support/CCLuaEngine.* | Restore MT3 2.0-era `CCScriptEngineProtocol` Lua bridge helpers, `gGetScriptEngine`, protocol callbacks, stack push helpers, `CCLuaEngine::engine()` and dotted Lua global function lookup on top of the official 2.2.6 Lua stack | Rebuild `libcocos2d`, then rebuild `FireClient` |
| Spine Json compatibility shim | extensions/spine/Json.* | Preserve MT3 legacy global Spine C Json API, `size`, `valueString`, `valueInt` and `valueFloat` fields; keep the concrete `struct Json` tag global so old tolua++ output and the 2.2.6 namespaced implementation resolve to the same ABI type | Rebuild `libExtensions`, then rebuild `FireClient` |
| Video player compatibility shim | `cocos2dx/platform/VideoPlayerEngine.h` | Keep MT3 startup-CG call sites compiling without restoring the old 2.0 Win32 WMP/CWMPView ActiveX backend; reports completion on the next Win32 scheduler tick so login flow is not blocked | Rebuild `FireClient`, then build `MT3` |
| Photo picker compatibility shim | `cocos2dx/platform/PhotoPicker.h` | Keep MT3 photo-picker update/callback call sites compiling without adding platform camera/album dependencies to the Win32 2.2.6 standard build; Win32 operations remain unavailable, matching the old Win32 stub behavior | Rebuild `FireClient`, then build `MT3` |
| Cocos 2.0-era API compatibility shim | `cocos2dx/CCDirector.*`, `textures/CCTextureCache.*`, `extensions/network/HttpClient.*`, `cocos2dx/script_support/CCScriptSupport.h`, `platform/CCImage.*` | Restore MT3 call-site compatibility for render pause/background flags, split draw/swap calls, texture reload providers, HTTP queue clearing, Lua search path dispatch and image downscale without restoring obsolete engine/vendor projects | Rebuild `libcocos2d`, `libExtensions`, `engine`, `FireClient`, then build `MT3` |
| FireClient compatibility pass | `scripting/lua/tolua/tolua++.h`, `common/ljfm/code/include/ljfmtableloader.h`, `dependencies/cegui/CEGUI/include/CEGUIBase.h`, `cocos2dx/platform/win32/CCStdC.h` | Restore MT3 tolua++ `std::wstring` helpers plus legacy Lua function/object reference helpers under explicit `extern "C++"` linkage so files that include `tolua++.h` inside `extern "C"` remain buildable, resolve LJFM `s2ws()` through the existing string utility, harden CEGUI `ceguimin`/`ceguimax` against late Win32 `min`/`max` macros, and preserve the 2.0-era global `gettimeofday` call shape through a Win32 forwarding shim, including null-literal overloads required by Cocos internal callers | Rebuild `libcocos2d`, then rebuild `FireClient` |
