# 分步修复

1. 检查并移除 CEGUIBase 中不应参与编译的 Cocos2d 源文件。
2. 检查并移除 CEGUIBase 中不应参与编译的 Falagard 源文件。
3. 校正导出宏，避免 `dllimport/dllexport` 冲突。
4. 清理并重编译 Debug/Release。
5. 验证产物与日志。
