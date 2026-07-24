# MeiqiaSdk dx 兼容修复

> 返回 [Android 文档索引](00-README.md)。本页只记录 MeiqiaSdk 在当前 Ant/dx 构建链中的专项兼容处理。

## 1. 现象与根因

旧 `dx` 阶段可能报：

```text
ParseException: bad class file magic (cafebabe) or version (0034.0000)
```

根因是 `client/3rdplatform/MeiqiaSdk` 产出的 class 字节码版本高于旧 dx 可接受范围。主工程即使使用 `NDK r16 clang + Ant + JDK 8 + Python 2.7`，依赖库 class 版本过高仍会阻塞 dex。

## 2. 仓库内修复

- `client/3rdplatform/MeiqiaSdk/ant.properties`
  - `java.source=1.7`
  - `java.target=1.7`
- `client/3rdplatform/MeiqiaSdk/custom_rules.xml`
  - 清理旧 `bin/classes`；
  - 使用 source/target 1.7 全量编译 `src + gen`；
  - 重新生成 `bin/classes.jar`。

这两个文件属于当前兼容基线，不要用升级构建后端掩盖 dx 首错。

## 3. 验证

```powershell
Push-Location .\client\3rdplatform\MeiqiaSdk
& "D:\apache-ant-1.9.7\bin\ant.bat" clean release
javap -verbose -classpath bin/classes.jar 'com.meiqia.meiqiasdk.activity.MQConversationActivity$MessageReceiver' | Select-String 'major version'
Pop-Location
```

预期：`major version: 51`。

然后回到仓库根运行 [Android 构建流程](04-构建流程.md) 的 free 全链路，确认 dx、APK 结构和输出均通过。

## 4. 回归触发条件

以下变更后重新检查 class major version：

- JDK、Android build-tools 或 Ant 环境变化；
- MeiqiaSdk 源码/依赖更新；
- `ant.properties` 或 `custom_rules.xml` 被覆盖；
- 再次出现 `version (0034.0000)`。

其他 Android 首错转 [排错手册](06-排错手册.md)。
