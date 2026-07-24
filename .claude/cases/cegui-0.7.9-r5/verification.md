# 验证结果

## 验证项

1. `CEGUIBase_d.lib` 与 `CEGUIBase.lib` 生成成功。
2. 无 `LNK2019/LNK2001/C2491` 阻断错误。
3. 构建日志可追溯并可二次复现。

## 验证命令

```bat
"C:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe" "E:\\MT3\\tools\\CEGUI-0.7.9-r5\\projects\\premake\\BaseSystem\\CEGUIBase.vcxproj" /t:Build /p:Configuration=Debug /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo
"C:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe" "E:\\MT3\\tools\\CEGUI-0.7.9-r5\\projects\\premake\\BaseSystem\\CEGUIBase.vcxproj" /t:Build /p:Configuration=Release /p:Platform=Win32 /p:PlatformToolset=v120 /m /nologo
```
