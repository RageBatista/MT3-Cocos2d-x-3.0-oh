# CEGUI 工具使用指南

> MT3 项目 CEGUI 工具使用指南

## 文档信息

- **文档版本**: v1.0
- **创建日期**: 2026-01-27
- **最后更新**: 2026-01-27
- **维护人员**: 架构师

---

## 一、工具概述

### 1.1 CEGUI 工具集

CEGUI 提供以下工具：

| 工具名称 | 用途 | 平台 |
|----------|------|------|
| CELayoutEditor | 布局编辑器 | Windows |
| CEImagesetEditor | 图像集编辑器 | Windows |
| CEFalagardEditor | 外观编辑器 | Windows |
| CEDLookEditor | LookNFeel 编辑器 | Windows |
| CEDemo | CEGUI 演示程序 | Windows |

### 1.2 工具安装

所有 CEGUI 工具都位于 `tools/cegui/` 目录下。

---

## 二、CELayoutEditor 使用指南

### 2.1 工具简介

CELayoutEditor 是 CEGUI 的布局编辑器，用于创建和编辑 UI 布局。

### 2.2 启动工具

```bash
# Windows
tools/cegui/CELayoutEditor.exe
```

### 2.3 界面介绍

CELayoutEditor 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **控件面板**: 显示可用控件列表
- **层次面板**: 显示 UI 控件层次结构
- **属性面板**: 显示当前选中控件的属性
- **预览窗口**: 实时预览 UI 布局

### 2.4 创建新布局

1. 点击菜单 `File -> New`
2. 设置布局参数：
   - 布局名称
   - 布局尺寸
   - 背景颜色
3. 点击 `OK` 创建

### 2.5 添加控件

#### 添加基础控件

1. 在控件面板中选择控件类型
2. 在预览窗口中拖拽创建控件
3. 在属性面板中设置控件属性

#### 常用控件

| 控件类型 | 说明 |
|----------|------|
| DefaultWindow | 基础窗口 |
| DefaultButton | 按钮 |
| DefaultEditbox | 编辑框 |
| DefaultCheckbox | 复选框 |
| DefaultRadioButton | 单选按钮 |
| DefaultCombobox | 下拉框 |
| DefaultListbox | 列表框 |
| DefaultProgressBar | 进度条 |
| DefaultScrollbar | 滚动条 |
| DefaultSlider | 滑块 |
| DefaultSpinner | 微调框 |
| DefaultTabButton | 标签按钮 |
| DefaultFrameWindow | 框架窗口 |
| DefaultTitlebar | 标题栏 |
| DefaultCloseButton | 关闭按钮 |

### 2.6 编辑控件属性

#### 基础属性

- **Name**: 控件名称
- **Type**: 控件类型
- **UnifiedPosition**: 统一位置
- **UnifiedSize**: 统一尺寸
- **UnifiedMinSize**: 最小尺寸
- **UnifiedMaxSize**: 最大尺寸
- **AspectRatio**: 宽高比
- **Visible**: 是否可见
- **Enabled**: 是否启用
- **ClippedByParent**: 是否被父控件裁剪
- **AlwaysOnTop**: 是否始终在顶层
- **InheritsAlpha**: 是否继承透明度
- **Alpha**: 透明度

#### 文本属性

- **Text**: 文本内容
- **Font**: 字体
- **TextColour**: 文本颜色
- **HorzFormatting**: 水平格式化
- **VertFormatting**: 垂直格式化
- **HorzExtent**: 水平范围
- **VertExtent**: 垂直范围

#### 事件属性

- **MousePassThroughEnabled**: 鼠标穿透
- **MouseButtonDownEvent**: 鼠标按下事件
- **MouseButtonUpEvent**: 鼠标释放事件
- **MouseEnterEvent**: 鼠标进入事件
- **MouseLeaveEvent**: 鼠标离开事件
- **MouseMoveEvent**: 鼠标移动事件
- **MouseWheelEvent**: 鼠标滚轮事件
- **KeyDownEvent**: 键盘按下事件
- **KeyUpEvent**: 键盘释放事件
- **CharacterEvent**: 字符输入事件

### 2.7 控件层次管理

#### 添加子控件

1. 在层次面板中选择父控件
2. 在控件面板中选择子控件类型
3. 点击 `Add Child` 按钮

#### 删除控件

1. 在层次面板中选择控件
2. 点击 `Delete` 按钮或按 `Delete` 键

#### 移动控件

1. 在层次面板中拖拽控件
2. 移动到目标位置

#### 复制控件

1. 在层次面板中选择控件
2. 点击 `Copy` 按钮或按 `Ctrl+C`
3. 选择目标父控件
4. 点击 `Paste` 按钮或按 `Ctrl+V`

### 2.8 对齐和分布

#### 对齐控件

1. 选择要对齐的控件
2. 点击菜单 `Edit -> Align`
3. 选择对齐方式：
   - Left (左对齐)
   - Center (居中对齐)
   - Right (右对齐)
   - Top (顶对齐)
   - Middle (中间对齐)
   - Bottom (底对齐)

#### 分布控件

1. 选择要分布的控件
2. 点击菜单 `Edit -> Distribute`
3. 选择分布方式：
   - Horizontal (水平分布)
   - Vertical (垂直分布)

### 2.9 保存布局

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入布局名称
4. 点击 `Save`

### 2.10 导出布局

1. 点击菜单 `File -> Export`
2. 选择导出格式（.layout）
3. 选择导出路径
4. 点击 `Export`

---

## 三、CEImagesetEditor 使用指南

### 3.1 工具简介

CEImagesetEditor 是 CEGUI 的图像集编辑器，用于创建和编辑图像集。

### 3.2 启动工具

```bash
# Windows
tools/cegui/CEImagesetEditor.exe
```

### 3.3 界面介绍

CEImagesetEditor 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **图像面板**: 显示图像集图像
- **属性面板**: 显示当前选中图像的属性
- **预览窗口**: 预览图像集

### 3.4 创建新图像集

1. 点击菜单 `File -> New`
2. 设置图像集参数：
   - 图像集名称
   - 图像尺寸
   - 原始图像路径
3. 点击 `OK` 创建

### 3.5 添加图像

1. 点击菜单 `Edit -> Add Image`
2. 设置图像参数：
   - 图像名称
   - 图像位置
   - 图像尺寸
   - 原始图像区域
3. 点击 `OK` 添加

### 3.6 编辑图像

#### 编辑图像属性

1. 在图像面板中选择图像
2. 在属性面板中编辑图像属性：
   - Name: 图像名称
   - XPos: X 位置
   - YPos: Y 位置
   - Width: 宽度
   - Height: 高度
   - XOffset: X 偏移
   - YOffset: Y 偏移

#### 删除图像

1. 在图像面板中选择图像
2. 点击 `Delete` 按钮或按 `Delete` 键

### 3.7 保存图像集

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入图像集名称
4. 点击 `Save`

### 3.8 导出图像集

1. 点击菜单 `File -> Export`
2. 选择导出格式（.imageset）
3. 选择导出路径
4. 点击 `Export`

---

## 四、CEFalagardEditor 使用指南

### 4.1 工具简介

CEFalagardEditor 是 CEGUI 的外观编辑器，用于创建和编辑 Falagard 外观。

### 4.2 启动工具

```bash
# Windows
tools/cegui/CEFalagardEditor.exe
```

### 4.3 界面介绍

CEFalagardEditor 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **外观面板**: 显示外观列表
- **属性面板**: 显示当前选中外观的属性
- **预览窗口**: 预览外观效果

### 4.4 创建新外观

1. 点击菜单 `File -> New`
2. 设置外观参数：
   - 外观名称
   - 基础控件类型
   - 外观类型
3. 点击 `OK` 创建

### 4.5 编辑外观

#### 编辑外观属性

1. 在外观面板中选择外观
2. 在属性面板中编辑外观属性：
   - Name: 外观名称
   - TargetType: 目标控件类型
   - Renderer: 渲染器
   - LookNFeel: LookNFeel 名称

#### 编辑外观组件

1. 在外观面板中选择组件
2. 在属性面板中编辑组件属性：
   - Type: 组件类型
   - Name: 组件名称
   - Area: 组件区域
   - Imageset: 图像集
   - Image: 图像

### 4.6 保存外观

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入外观名称
4. 点击 `Save`

### 4.7 导出外观

1. 点击菜单 `File -> Export`
2. 选择导出格式（.scheme）
3. 选择导出路径
4. 点击 `Export`

---

## 五、CEDLookEditor 使用指南

### 5.1 工具简介

CEDLookEditor 是 CEGUI 的 LookNFeel 编辑器，用于创建和编辑 LookNFeel。

### 5.2 启动工具

```bash
# Windows
tools/cegui/CEDLookEditor.exe
```

### 5.3 界面介绍

CEDLookEditor 界面分为以下几个区域：

- **菜单栏**: 文件、编辑、视图、工具、帮助
- **工具栏**: 常用操作快捷按钮
- **LookNFeel 面板**: 显示 LookNFeel 列表
- **属性面板**: 显示当前选中 LookNFeel 的属性
- **预览窗口**: 预览 LookNFeel 效果

### 5.4 创建新 LookNFeel

1. 点击菜单 `File -> New`
2. 设置 LookNFeel 参数：
   - LookNFeel 名称
   - 基础控件类型
3. 点击 `OK` 创建

### 5.5 编辑 LookNFeel

#### 编辑 LookNFeel 属性

1. 在 LookNFeel 面板中选择 LookNFeel
2. 在属性面板中编辑 LookNFeel 属性：
   - Name: LookNFeel 名称
   - Inherits: 继承的 LookNFeel

#### 编辑 LookNFeel 组件

1. 在 LookNFeel 面板中选择组件
2. 在属性面板中编辑组件属性：
   - Type: 组件类型
   - Name: 组件名称
   - Area: 组件区域
   - Property: 组件属性

### 5.6 保存 LookNFeel

1. 点击菜单 `File -> Save`
2. 选择保存路径
3. 输入 LookNFeel 名称
4. 点击 `Save`

### 5.7 导出 LookNFeel

1. 点击菜单 `File -> Export`
2. 选择导出格式（.looknfeel）
3. 选择导出路径
4. 点击 `Export`

---

## 六、最佳实践

### 6.1 布局优化

- 使用相对布局而非绝对布局
- 使用控件层次结构
- 避免过深的控件层次
- 使用统一的尺寸和位置

### 6.2 图像集优化

- 使用图像集减少纹理切换
- 优化图像尺寸
- 使用图像压缩
- 使用图像图集

### 6.3 外观优化

- 使用外观复用
- 避免过多的外观定义
- 使用外观继承
- 优化外观组件

---

## 七、常见问题

### 7.1 工具无法启动

**问题**: 工具无法启动

**原因**: 缺少依赖库

**解决方案**:
1. 检查是否安装了 Visual C++ Redistributable
2. 检查 CEGUI 库是否正确安装
3. 检查配置文件是否正确

### 7.2 布局导出失败

**问题**: 布局导出失败

**原因**: 布局文件路径错误

**解决方案**:
1. 检查布局文件路径是否正确
2. 检查图像集文件是否存在
3. 检查文件权限

### 7.3 图像显示异常

**问题**: 图像显示异常

**原因**: 图像集配置错误

**解决方案**:
1. 检查图像集配置是否正确
2. 检查图像文件是否存在
3. 检查图像格式是否支持

---

## 八、参考资料

- [CEGUI 技能](../skills/cegui/SKILL.md)
- [Nuclear 集成指南](../references/nuclear-integration.md)
- [性能优化指南](../references/performance-guide.md)
