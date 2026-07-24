---
name: clean
version: 1.0.0
description: 清理编译产物和缓存
linked-skill: common/build-troubleshooting
linked-agent: build-expert
allowed-tools:
  - Bash
---

# 清理命令

**关联技能**: [build-troubleshooting](../skills/common/build-troubleshooting.md)
**关联代理**: [build-expert](../agents/build-expert.md)

清理项目编译产物和缓存。

## 清理选项

### 1. 清理 Windows 客户端

```batch
:: 删除编译产物
rd /s /q "E:\MT3\client\MT3Win32App\Debug.win32" 2>nul
rd /s /q "E:\MT3\client\MT3Win32App\Release.win32" 2>nul
rd /s /q "E:\MT3\client\MT3Win32App\ipch" 2>nul

:: 删除中间文件
del /s /q "E:\MT3\client\MT3Win32App\*.obj" 2>nul
del /s /q "E:\MT3\client\MT3Win32App\*.pch" 2>nul
```

### 2. 清理 Android 客户端

```bash
cd E:/MT3/client/android/LocojoyProject
ndk-build clean
ant clean
rm -rf obj/ bin/ libs/
```

### 3. 清理服务器

```bash
cd E:/MT3/server/tools/jgs
ant clean

# 清理全部服务器
for dir in E:/MT3/server/tools/*/; do
    if [ -f "$dir/build.xml" ]; then
        cd "$dir" && ant clean && cd -
    fi
done
```

### 4. 清理全部

执行上述所有清理操作。

## 清理后验证

```bash
# 验证清理结果
dir "E:\MT3\client\MT3Win32App\*.exe" /s 2>nul
dir "E:\MT3\client\android\LocojoyProject\bin\*.apk" 2>nul
dir "E:\MT3\server\tools\jgs\bin\*.jar" 2>nul
```

## 注意事项

- 清理前确认没有重要的本地修改
- 清理后需要重新编译
- 某些清理操作不可逆

根据用户请求执行相应的清理操作。
