# Cocos2d-x 工具使用指南

> MT3 项目 Cocos2d-x 2.0 工具使用指南

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、工具概述

### 1.1 Cocos2d-x 工具集

Cocos2d-x 2.0 提供以下工具：

| 工具名称 | 用途 | 平台 |
|----------|------|------|
| TexturePacker | 纹理打包工具 | Windows |
| ParticleDesigner | 粒子设计器 | Windows |
| SpriteSheetPacker | 精灵表打包工具 | Windows |
| FontMaker | 字体制作工具 | Windows |
| PhysicsEditor | 物理编辑器 | Windows |
| LevelHelper | 关卡编辑器 | Windows |
| SpriteBuilder | 精灵构建器 | Windows |

### 1.2 工具安装

所有 Cocos2d-x 工具都位于 `tools/cocos2dx/` 目录下。

---

## 二、TexturePacker 使用指南

### 2.1 工具简介

TexturePacker 是 Cocos2d-x 的纹理打包工具，用于将多个小纹理打包成一个大纹理。

### 2.2 启动工具

```bash
# Windows
tools/cocos2dx/TexturePacker.exe
```

### 2.3 界面介绍

TexturePacker 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **资源面板**: 显示待打包的纹理列表
- **设置面板**: 显示打包设置
- **预览窗口**: 预览打包后的纹理

### 2.4 添加纹理

1. 点击菜单 `File -> Add Textures`
2. 选择要打包的纹理文件
3. 点击 `Open` 添加

### 2.5 设置打包参数

在设置面板中设置以下参数：

#### 输出格式

- **Texture format**: PNG, PVR, ETC1
- **Data format**: Cocos2d-x, JSON, XML
- **Image format**: RGBA8888, RGB565, RGBA4444, RGB5A1

#### 纹理尺寸

- **Max width**: 最大宽度（1024, 2048, 4096）
- **Max height**: 最大高度（1024, 2048, 4096）
- **Force squared**: 强制正方形
- **Power of two**: 2 的幂次方

#### 边距和内边距

- **Padding**: 纹理之间的边距
- **Inner padding**: 纹理内部的内边距
- **Extrude**: 扩展边缘

#### 优化选项

- **Allow rotation**: 允许旋转纹理
- **Trim**: 裁剪透明区域
- **Trim mode**: 裁剪模式（None, Trim, Crop）
- **Shape padding**: 形状边距

#### 高级选项

- **Premultiply alpha**: 预乘透明度
- **Flip PVR**: 翻转 PVR
- **Reduce border artifacts**: 减少边缘伪影

### 2.6 打包纹理

1. 点击菜单 `File -> Publish`
2. 选择输出路径
3. 点击 `Publish` 开始打包

### 2.7 导出纹理

1. 点击菜单 `File -> Export`
2. 选择导出格式（.png, .plist）
3. 选择导出路径
4. 点击 `Export`

### 2.8 命令行使用

```bash
# 命令行打包
TexturePacker.exe --data output.plist --texture output.png --format cocos2d input/*.png

# 命令行参数
--data: 输出数据文件
--texture: 输出纹理文件
--format: 输出格式
--max-width: 最大宽度
--max-height: 最大高度
--padding: 边距
--inner-padding: 内边距
--allow-rotation: 允许旋转
--trim: 裁剪透明区域
```

---

## 三、ParticleDesigner 使用指南

### 3.1 工具简介

ParticleDesigner 是 Cocos2d-x 的粒子设计器，用于创建和编辑粒子系统。

### 3.2 启动工具

```bash
# Windows
tools/cocos2dx/ParticleDesigner.exe
```

### 3.3 界面介绍

ParticleDesigner 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **粒子面板**: 显示粒子系统列表
- **属性面板**: 显示当前选中粒子的属性
- **预览窗口**: 实时预览粒子效果
- **曲线编辑器**: 编辑粒子属性曲线

### 3.4 创建粒子系统

1. 点击菜单 `File -> New`
2. 设置粒子系统参数：
   - 粒子数量
   - 粒子生命周期
   - 粒子速度
   - 粒子大小
   - 粒子颜色
   - 粒子纹理
3. 点击 `OK` 创建

### 3.5 编辑粒子属性

#### 发射器属性

- **Emission rate**: 发射速率
- **Duration**: 持续时间
- **Life**: 生命周期
- **Life variance**: 生命周期变化

#### 粒子属性

- **Start size**: 初始大小
- **Start size variance**: 初始大小变化
- **End size**: 结束大小
- **End size variance**: 结束大小变化
- **Angle**: 发射角度
- **Angle variance**: 发射角度变化
- **Speed**: 速度
- **Speed variance**: 速度变化
- **Gravity**: 重力
- **Radial acceleration**: 径向加速度
- **Radial acceleration variance**: 径向加速度变化
- **Tangential acceleration**: 切向加速度
- **Tangential acceleration variance**: 切向加速度变化

#### 颜色属性

- **Start color**: 初始颜色
- **Start color variance**: 初始颜色变化
- **End color**: 结束颜色
- **End color variance**: 结束颜色变化

#### 旋转属性

- **Start spin**: 初始旋转
- **Start spin variance**: 初始旋转变化
- **End spin**: 结束旋转
- **End spin variance**: 结束旋转变化

#### 纹理属性

- **Texture**: 粒子纹理
- **Blend function**: 混合函数
- **Source**: 源混合因子
- **Destination**: 目标混合因子

### 3.6 使用曲线编辑器

曲线编辑器用于编辑粒子属性随时间变化的曲线。

1. 选择要编辑的属性
2. 在曲线编辑器中添加关键点
3. 调整关键点的值和时间
4. 设置关键点的插值方式（线性、贝塞尔、阶梯）

### 3.7 保存粒子系统

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入粒子系统名称
4. 点击 `Save`

### 3.8 导出粒子系统

1. 点击菜单 `File -> Export`
2. 选择导出格式（.plist）
3. 选择导出路径
4. 点击 `Export`

---

## 四、SpriteSheetPacker 使用指南

### 4.1 工具简介

SpriteSheetPacker 是 Cocos2d-x 的精灵表打包工具，用于将多个精灵打包成一个精灵表。

### 4.2 启动工具

```bash
# Windows
tools/cocos2dx/SpriteSheetPacker.exe
```

### 4.3 界面介绍

SpriteSheetPacker 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **精灵面板**: 显示待打包的精灵列表
- **设置面板**: 显示打包设置
- **预览窗口**: 预览打包后的精灵表

### 4.4 添加精灵

1. 点击菜单 `File -> Add Sprites`
2. 选择要打包的精灵文件
3. 点击 `Open` 添加

### 4.5 设置打包参数

在设置面板中设置以下参数：

#### 输出格式

- **Texture format**: PNG, PVR, ETC1
- **Data format**: Cocos2d-x, JSON, XML

#### 精灵表尺寸

- **Max width**: 最大宽度（1024, 2048, 4096）
- **Max height**: 最大高度（1024, 2048, 4096）
- **Force squared**: 强制正方形
- **Power of two**: 2 的幂次方

#### 边距和内边距

- **Padding**: 精灵之间的边距
- **Inner padding**: 精灵内部的内边距
- **Extrude**: 扩展边缘

#### 优化选项

- **Allow rotation**: 允许旋转精灵
- **Trim**: 裁剪透明区域
- **Trim mode**: 裁剪模式（None, Trim, Crop）
- **Shape padding**: 形状边距

#### 动画选项

- **Animation frame rate**: 动画帧率
- **Animation loop**: 动画循环

### 4.6 打包精灵表

1. 点击菜单 `File -> Pack`
2. 选择输出路径
3. 点击 `Pack` 开始打包

### 4.7 导出精灵表

1. 点击菜单 `File -> Export`
2. 选择导出格式（.png, .plist）
3. 选择导出路径
4. 点击 `Export`

---

## 五、FontMaker 使用指南

### 5.1 工具简介

FontMaker 是 Cocos2d-x 的字体制作工具，用于创建位图字体。

### 5.2 启动工具

```bash
# Windows
tools/cocos2dx/FontMaker.exe
```

### 5.3 界面介绍

FontMaker 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **字符面板**: 显示字符列表
- **属性面板**: 显示当前选中字符的属性
- **预览窗口**: 预览字体效果

### 5.4 创建新字体

1. 点击菜单 `File -> New`
2. 设置字体参数：
   - 字体名称
   - 字体文件
   - 字体大小
   - 字符集
3. 点击 `OK` 创建

### 5.5 添加字符

1. 点击菜单 `Edit -> Add Characters`
2. 输入要添加的字符
3. 点击 `OK` 添加

### 5.6 编辑字体属性

#### 基础属性

- **Font name**: 字体名称
- **Font file**: 字体文件
- **Font size**: 字体大小
- **Character set**: 字符集

#### 纹理属性

- **Texture width**: 纹理宽度
- **Texture height**: 纹理高度
- **Texture format**: 纹理格式
- **Padding**: 边距
- **Spacing**: 间距

#### 渲染属性

- **Anti-alias**: 抗锯齿
- **Bold**: 粗体
- **Italic**: 斜体
- **Underline**: 下划线

### 5.7 保存字体

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入字体名称
4. 点击 `Save`

### 5.8 导出字体

1. 点击菜单 `File -> Export`
2. 选择导出格式（.fnt, .png）
3. 选择导出路径
4. 点击 `Export`

---

## 六、PhysicsEditor 使用指南

### 6.1 工具简介

PhysicsEditor 是 Cocos2d-x 的物理编辑器，用于创建物理刚体。

### 6.2 启动工具

```bash
# Windows
tools/cocos2dx/PhysicsEditor.exe
```

### 6.3 界面介绍

PhysicsEditor 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **精灵面板**: 显示精灵列表
- **属性面板**: 显示当前选中刚体的属性
- **预览窗口**: 预览物理效果

### 6.4 导入精灵

1. 点击菜单 `File -> Import Sprite`
2. 选择要导入的精灵文件
3. 点击 `Open` 导入

### 6.5 创建刚体

1. 在精灵面板中选择精灵
2. 点击菜单 `Edit -> Create Body`
3. 设置刚体参数：
   - 刚体类型（静态、动态、运动学）
   - 密度
   - 摩擦力
   - 弹性
4. 点击 `OK` 创建

### 6.6 编辑刚体

#### 编辑刚体属性

1. 在精灵面板中选择刚体
2. 在属性面板中编辑刚体属性：
   - Type: 刚体类型
   - Density: 密度
   - Friction: 摩擦力
   - Restitution: 弹性
   - Is sensor: 是否为传感器

#### 编辑形状

1. 在预览窗口中选择形状
2. 在属性面板中编辑形状属性：
   - Type: 形状类型（圆形、多边形）
   - Radius: 半径（圆形）
   - Vertices: 顶点（多边形）

### 6.7 保存物理刚体

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入刚体名称
4. 点击 `Save`

### 6.8 导出物理刚体

1. 点击菜单 `File -> Export`
2. 选择导出格式（.plist）
3. 选择导出路径
4. 点击 `Export`

---

## 七、LevelHelper 使用指南

### 7.1 工具简介

LevelHelper 是 Cocos2d-x 的关卡编辑器，用于创建游戏关卡。

### 7.2 启动工具

```bash
# Windows
tools/cocos2dx/LevelHelper.exe
```

### 7.3 界面介绍

LevelHelper 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **资源面板**: 显示可用资源
- **层次面板**: 显示关卡层次结构
- **属性面板**: 显示当前选中对象的属性
- **预览窗口**: 预览关卡效果

### 7.4 创建新关卡

1. 点击菜单 `File -> New`
2. 设置关卡参数：
   - 关卡名称
   - 关卡尺寸
   - 背景颜色
3. 点击 `OK` 创建

### 7.5 添加对象

#### 添加精灵

1. 在资源面板中选择精灵
2. 在预览窗口中拖拽创建精灵
3. 在属性面板中设置精灵属性

#### 添加物理刚体

1. 在资源面板中选择物理刚体
2. 在预览窗口中拖拽创建物理刚体
3. 在属性面板中设置物理刚体属性

#### 添加触发器

1. 在资源面板中选择触发器
2. 在预览窗口中拖拽创建触发器
3. 在属性面板中设置触发器属性

### 7.6 编辑对象属性

#### 精灵属性

- **Name**: 对象名称
- **Position**: 位置
- **Rotation**: 旋转
- **Scale**: 缩放
- **Z order**: Z 轴顺序
- **Visible**: 是否可见
- **Tag**: 标签

#### 物理刚体属性

- **Type**: 刚体类型
- **Density**: 密度
- **Friction**: 摩擦力
- **Restitution**: 弹性
- **Category mask**: 类别掩码
- **Collision mask**: 碰撞掩码

#### 触发器属性

- **Name**: 触发器名称
- **Position**: 位置
- **Size**: 尺寸
- **Trigger type**: 触发器类型
- **Trigger data**: 触发器数据

### 7.7 保存关卡

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入关卡名称
4. 点击 `Save`

### 7.8 导出关卡

1. 点击菜单 `File -> Export`
2. 选择导出格式（.plist）
3. 选择导出路径
4. 点击 `Export`

---

## 八、SpriteBuilder 使用指南

### 8.1 工具简介

SpriteBuilder 是 Cocos2d-x 的精灵构建器，用于创建和编辑精灵。

### 8.2 启动工具

```bash
# Windows
tools/cocos2dx/SpriteBuilder.exe
```

### 8.3 界面介绍

SpriteBuilder 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **资源面板**: 显示可用资源
- **层次面板**: 显示精灵层次结构
- **属性面板**: 显示当前选中精灵的属性
- **预览窗口**: 预览精灵效果

### 8.4 创建新精灵

1. 点击菜单 `File -> New`
2. 设置精灵参数：
   - 精灵名称
   - 精灵尺寸
   - 精灵纹理
3. 点击 `OK` 创建

### 8.5 编辑精灵

#### 编辑精灵属性

1. 在层次面板中选择精灵
2. 在属性面板中编辑精灵属性：
   - Name: 精灵名称
   - Position: 位置
   - Rotation: 旋转
   - Scale: 缩放
   - Anchor point: 锚点
   - Color: 颜色
   - Opacity: 透明度
   - Visible: 是否可见
   - Z order: Z 轴顺序

#### 编辑精灵动画

1. 在层次面板中选择精灵
2. 点击菜单 `Edit -> Add Animation`
3. 设置动画参数：
   - Animation name: 动画名称
   - Frame rate: 帧率
   - Loop: 是否循环
4. 添加动画帧

### 8.6 保存精灵

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入精灵名称
4. 点击 `Save`

### 8.7 导出精灵

1. 点击菜单 `File -> Export`
2. 选择导出格式（.png, .plist）
3. 选择导出路径
4. 点击 `Export`

---

## 九、最佳实践

### 9.1 纹理优化

- 使用纹理图集减少 Draw Call
- 使用纹理压缩减少内存占用
- 优化纹理尺寸
- 使用 Mipmap

### 9.2 粒子优化

- 减少粒子数量
- 使用粒子池
- 优化粒子生命周期
- 使用纹理图集

### 9.3 动画优化

- 使用动画帧缓存
- 优化动画帧率
- 使用动画压缩
- 使用动画混合

---

## 十、常见问题

### 10.1 工具无法启动

**问题**: 工具无法启动

**原因**: 缺少依赖库

**解决方案**:
1. 检查是否安装了 Visual C++ Redistributable
2. 检查 Cocos2d-x 库是否正确安装
3. 检查配置文件是否正确

### 10.2 纹理打包失败

**问题**: 纹理打包失败

**原因**: 纹理尺寸超过限制

**解决方案**:
1. 减少纹理数量
2. 增加纹理尺寸限制
3. 使用多个纹理图集

### 10.3 粒子显示异常

**问题**: 粒子显示异常

**原因**: 粒子配置错误

**解决方案**:
1. 检查粒子配置是否正确
2. 检查粒子纹理是否存在
3. 检查粒子属性是否合理

---

## 十一、参考资料

- [Cocos2d-x 技能](../skills/cocos2dx/SKILL.md)
- [Nuclear 集成指南](../references/nuclear-integration.md)
- [性能优化指南](../references/performance-guide.md)
