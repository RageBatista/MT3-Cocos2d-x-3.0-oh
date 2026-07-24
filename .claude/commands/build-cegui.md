---
name: build-cegui
version: 1.1.0
description: 编译 CEGUI 0.7.9-r5（v120）
linked-skill: client/cegui-usage
linked-agent: build-expert
allowed-tools:
  - Bash
---

# CEGUI 编译命令

**关联技能**: [cegui-usage](../skills/client/cegui-usage.md)
**关联代理**: [build-expert](../agents/build-expert.md)

## 推荐命令

```powershell
# Debug
"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" "E:\MT3\tools\CEGUI-0.7.9-r5\projects\premake\BaseSystem\CEGUIBase.vcxproj" /t:Build /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo

# Release
"C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" "E:\MT3\tools\CEGUI-0.7.9-r5\projects\premake\BaseSystem\CEGUIBase.vcxproj" /t:Build /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo
```

## 预检查

- 确认 `PlatformToolset=v120`
- 确认 `CEGUIBase.vcxproj` 中模块边界配置符合案例结论

## 参考

- [cases/cegui-0.7.9-r5](../cases/cegui-0.7.9-r5/README.md)
- [cegui-build-workflow](../workflows/cegui-build-workflow.md)

执行后输出错误分类、修复建议与产物路径。