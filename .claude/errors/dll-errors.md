# DLL 错误速查

> 版本: 1.0.0  
> 更新: 2026-02-28

## 常见类型

- `找不到 DLL`：运行目录缺少依赖库，检查产物拷贝脚本与 PATH。
- `入口点不存在`：DLL 版本不匹配，检查同名旧 DLL 残留。
- `无法加载模块`：位数或运行时不兼容（Win32/x64、CRT 冲突）。

## 诊断步骤

1. 使用 `dumpbin /dependents <exe|dll>` 检查依赖链。
2. 确认 `PlatformToolset=v120` 与运行时库一致（`/MD` 或 `/MDd`）。
3. 清理旧目录后重新部署。

## 关联文档

- [MSBuild 错误](msbuild-errors.md)
- [链接错误](linker-errors.md)
- [编译完整指南](../../docs/03-开发指南/02-Windows完整构建指南.md)
