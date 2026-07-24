# 代码索引 __ Code Index

> **版本**: 1.0
> **创建日期**: 2026-01-27
> **目的**: 提供按文件/类名/功能的可搜索索引

---

## 目录

1. [按文件名索引](#按文件名索引)
2. [按类名索引](#按类名索引)
3. [按功能索引](#按功能索引)

---

## 按文件名索引

### 核心引擎文件

| 文件路径 | 描述 | 主要类 |
|---------|------|---------|
| `cocos2dx/CCDirector.h` | 导演类，管理场景和游戏循环 | CCDirector |
| `cocos2dx/CCScheduler.h` | 调度器，管理定时器和更新 | CCScheduler |
| `cocos2dx/CCActionManager.h` | 动作管理器 | CCActionManager |
| `cocos2dx/platform/CCFileUtils.h` | 文件工具类 | CCFileUtils |
| `cocos2dx/platform/CCImage.h` | 图像加载和处理 | CCImage |
| `cocos2dx/shaders/CCGLProgram.h` | OpenGL着色器程序 | CCGLProgram |
| `cocos2dx/support/CCPointExtension.h` | 点扩展函数 | ccp, ccpAdd, ccpSub |
| `cocos2dx/support/CCUserDefault.h` | 用户默认设置 | CCUserDefault |

### 节点相关文件

| 文件路径 | 描述 | 主要类 |
|---------|------|---------|
| `base_nodes/CCNode.h` | 节点基类 | CCNode |
| `layers_scenes_transitions_nodes/CCScene.h` | 场景类 | CCScene |
| `layers_scenes_transitions_nodes/CCLayer.h` | 层基类 | CCLayer |
| `layers_scenes_transitions_nodes/CCLayerColor.h` | 颜色层 | CCLayerColor |
| `layers_scenes_transitions_nodes/CCLayerMultiplex.h` | 多层管理 | CCLayerMultiplex |

### 精灵相关文件

| 文件路径 | 描述 | 主要类 |
|---------|------|---------|
| `sprite_nodes/CCSprite.h` | 精灵类 | CCSprite |
| `sprite_nodes/CCSpriteBatchNode.h` | 精灵批处理节点 | CCSpriteBatchNode |
| `sprite_nodes/CCSpriteFrame.h` | 精灵帧 | CCSpriteFrame |
| `sprite_nodes/CCSpriteFrameCache.h` | 精灵帧缓存 | CCSpriteFrameCache |

### 动作相关文件

| 文件路径 | 描述 | 主要类 |
|---------|------|---------|
| `actions/CCAction.h` | 动作基类 | CCAction |
| `actions/CCActionInterval.h` | 间隔动作基类 | CCActionInterval |
| `actions/CCActionInstant.h` | 瞬时动作基类 | CCActionInstant |
| `actions/CCSequence.h` | 序列动作 | CCSequence |
| `actions/CCSpawn.h` | 并行动作 | CCSpawn |
| `actions/CCRepeat.h` | 重复动作 | CCRepeat |
| `actions/CCRepeatForever.h` | 永久重复动作 | CCRepeatForever |

### 触摸相关文件

| 文件路径 | 描述 | 主要类 |
|---------|------|---------|
| `touch_dispatcher/CCTouchDispatcher.h` | 触摸事件分发器 | CCTouchDispatcher |
| `touch_dispatcher/CCTouch.h` | 触摸类 | CCTouch |
| `touch_dispatcher/CCTouchHandler.h` | 触摸处理器 | CCTouchHandler |

### 纹理相关文件

| 文件路径 | 描述 | 主要类 |
|---------|------|---------|
| `textures/CCTexture2D.h` | 2D纹理 | CCTexture2D |
| `textures/CCTextureCache.h` | 纹理缓存 | CCTextureCache |
| `textures/CCTexturePVR.h` | PVR纹理 | CCTexturePVR |

---

## 按类名索引

### A-C

| 类名 | 文件位置 | 功能 |
|-----|---------|------|
| CCAction | actions/CCAction.h | 动作基类 |
| CCActionInterval | actions/CCActionInterval.h | 间隔动作 |
| CCActionInstant | actions/CCActionInstant.h | 瞬时动作 |
| CCArray | support/data_support/CCArray.h | 数组容器 |
| CCArray | support/data_support/ccArray.h | 数组结构 |
| CCAnimation | sprite_nodes/CCAnimation.h | 动画 |
| CCAnimate | actions/CCAnimate.h | 帧动画动作 |
| CCApplication | platform/CCApplication.h | 应用程序基类 |
| CCAssert | support/CCAssert.h | 断言宏 |
| CCBezierBy | actions/CCBezierBy.h | 贝塞尔曲线动作 |
| CCBlendFunc | cocos2dx/CCGL.h | 混合函数 |
| CCBoolean | support/CCValue.h | 布尔值 |
| CCBool | support/CCValue.h | 布尔值 |
| CCBox2 | support/CCGeometry.h | 边界框 |
| CCByteArray | support/CCData.h | 字节数组 |
| CCBy | actions/CCActionInterval.h | 相对动作基类 |
| CCButton | extensions/GUI/CCControlButton.h | 按钮控件 |
| CC_CALLFUNC | support/CCActionInstant.h | 回调函数 |
| CC_CALLBACK | support/CCActionInstant.h | 回调 |
| CCCallFunc | actions/CCCallFunc.h | 函数调用动作 |
| CCCallFuncN | actions/CCCallFuncN.h | 带节点参数的函数调用 |
| CCColor3B | cocos2dx/CCGeometry.h | RGB颜色 |
| CCColor4B | cocos2dx/CCGeometry.h | RGBA颜色 |
| CCColor4F | cocos2dx/CCGeometry.h | RGBA浮点颜色 |
| CCConfiguration | cocos2dx/CCConfiguration.h | 配置类 |
| CCData | support/CCData.h | 数据类 |
| CCDelayTime | actions/CCDelayTime.h | 延迟动作 |
| CCDictionary | support/data_support/CCDictionary.h | 字典容器 |
| CCDirector | cocos2dx/CCDirector.h | 导演类 |
| CCDouble | support/CCValue.h | 双精度浮点数 |
| CCDrawNode | draw_nodes/CCDrawNode.h | 绘制节点 |
| CCEaseAction | actions/CCActionEase.h | 缓动动作基类 |
| CCEaseBackIn | actions/CCActionEase.h | 回退缓动 |
| CCEaseBounce | actions/CCActionEase.h | 弹跳缓动 |
| CCEaseElastic | actions/CCActionEase.h | 弹性缓动 |
| CCEaseExponential | actions/CCActionEase.h | 指数缓动 |
| CCEaseInOut | actions/CCActionEase.h | 进出缓动 |
| CCEaseRate | actions/CCActionEase.h | 速率缓动 |
| CCEaseSine | actions/CCActionEase.h | 正弦缓动 |
| CCFileData | platform/CCFileUtils.h | 文件数据 |
| CCFileUtils | platform/CCFileUtils.h | 文件工具 |
| CCFiniteTimeAction | actions/CCActionInterval.h | 有限时间动作 |
| CCFloat | support/CCValue.h | 浮点数 |
| CCFlipX | actions/CCActionInstant.h | 水平翻转 |
| CCFlipY | actions/CCActionInstant.h | 垂直翻转 |
| CCFollow | actions/CCFollow.h | 跟随动作 |
| CCFont | cocos2dx/CCFont.h | 字体类 |
| CCFontAtlas | label_nodes/CCLabelAtlas.h | 字体图集 |
| CCGLProgram | shaders/CCGLProgram.h | 着色器程序 |
| CCGLProgramCache | shaders/CCGLProgramCache.h | 着色器缓存 |
| CCGLView | platform/CCGLView.h | OpenGL视图 |
| CCGridAction | actions/CCGridAction.h | 网格动作 |
| CCGrid3DAction | actions/CCGrid3DAction.h | 3D网格动作 |
| CCGrabber | effects/CCGrabber.h | 抓取器 |
| CCImage | platform/CCImage.h | 图像类 |
| CCInteger | support/CCValue.h | 整数 |
| CCJumpBy | actions/CCJumpBy.h | 跳跃动作 |
| CCJumpTo | actions/CCJumpTo.h | 跳跃到动作 |
| CCLabel | label_nodes/CCLabel.h | 标签基类 |
| CCLabelAtlas | label_nodes/CCLabelAtlas.h | 图集标签 |
| CCLabelBMFont | label_nodes/CCLabelBMFont.h | 位图字体标签 |
| CCLabelTTF | label_nodes/CCLabelTTF.h | TTF字体标签 |
| CCLayer | layers_scenes_transitions_nodes/CCLayer.h | 层基类 |
| CCLayerColor | layers_scenes_transitions_nodes/CCLayerColor.h | 颜色层 |
| CCLayerGradient | layers_scenes_transitions_nodes/CCLayerGradient.h | 渐变层 |
| CCLayerMultiplex | layers_scenes_transitions_nodes/CCLayerMultiplex.h | 多层 |
| CCMenu | menu_nodes/CCMenu.h | 菜单 |
| CCMenuItem | menu_nodes/CCMenuItem.h | 菜单项基类 |
| CCMenuItemImage | menu_nodes/CCMenuItemImage.h | 图像菜单项 |
| CCMenuItemLabel | menu_nodes/CCMenuItemLabel.h | 标签菜单项 |
| CCMenuItemSprite | menu_nodes/CCMenuItemSprite.h | 精灵菜单项 |
| CCMenuItemToggle | menu_nodes/CCMenuItemToggle.h | 切换菜单项 |
| CCMoveBy | actions/CCMoveBy.h | 移动动作 |
| CCMoveTo | actions/CCMoveTo.h | 移动到动作 |
| CCNode | base_nodes/CCNode.h | 节点基类 |
| CCNotificationCenter | support/CCNotificationCenter.h | 通知中心 |
| CCObject | cocoa/CCObject.h | 对象基类 |
| CCOrbitCamera | actions/CCOrbitCamera.h | 轨道相机 |
| CCParallaxNode | sprite_nodes/CCParallaxNode.h | 视差节点 |
| CCParticleBatchNode | particle_nodes/CCParticleBatchNode.h | 粒子批处理 |
| CCParticleSystem | particle_nodes/CCParticleSystem.h | 粒子系统 |
| CCParticleSystemQuad | particle_nodes/CCParticleSystemQuad.h | 四边形粒子系统 |
| CCPoint | cocos2dx/CCGeometry.h | 点 |
| CCPointArray | support/CCPointArray.h | 点数组 |
| CCProgressFromTo | actions/CCProgressTo.h | 进度动作 |
| CCProgressTimer | sprite_nodes/CCProgressTimer.h | 进度计时器 |
| CCProgressTo | actions/CCProgressTo.h | 进度到动作 |
| CCProperty | support/CCProperty.h | 属性 |
| CCRect | cocos2dx/CCGeometry.h | 矩形 |
| CCRepeat | actions/CCRepeat.h | 重复动作 |
| CCRepeatForever | actions/CCRepeatForever.h | 永久重复 |
| CCRotateBy | actions/CCRotateBy.h | 旋转动作 |
| CCRotateTo | actions/CCRotateTo.h | 旋转到动作 |
| CCScene | layers_scenes_transitions_nodes/CCScene.h | 场景 |
| CCScaleBy | actions/CCScaleBy.h | 缩放动作 |
| CCScaleTo | actions/CCScaleTo.h | 缩放到动作 |
| CCScheduler | cocos2dx/CCScheduler.h | 调度器 |
| CCSequence | actions/CCSequence.h | 序列动作 |
| CCSkewBy | actions/CCSkewBy.h | 倾斜动作 |
| CCSkewTo | actions/CCSkewTo.h | 倾斜到动作 |
| CCSpeed | actions/CCSpeed.h | 速度动作 |
| CCSprite | sprite_nodes/CCSprite.h | 精灵 |
| CCSpriteBatchNode | sprite_nodes/CCSpriteBatchNode.h | 精灵批处理 |
| CCSpriteFrame | sprite_nodes/CCSpriteFrame.h | 精灵帧 |
| CCSpriteFrameCache | sprite_nodes/CCSpriteFrameCache.h | 精灵帧缓存 |
| CCSpawn | actions/CCSpawn.h | 并行动作 |
| CCString | support/CCString.h | 字符串类 |
| CCTargetedAction | actions/CCAction.h | 目标动作 |
| CCTexture2D | textures/CCTexture2D.h | 2D纹理 |
| CCTextureCache | textures/CCTextureCache.h | 纹理缓存 |
| CCTexturePVR | textures/CCTexturePVR.h | PVR纹理 |
| CCTimer | cocos2dx/CCScheduler.h | 定时器 |
| CCTint | support/CCValue.h | 有符号整型 |
| CCTouch | touch_dispatcher/CCTouch.h | 触摸 |
| CCTouchDispatcher | touch_dispatcher/CCTouchDispatcher.h | 触摸分发器 |
| CCTouchHandler | touch_dispatcher/CCTouchHandler.h | 触摸处理器 |
| CCTransitionEaseScene | transitions/CCTransitionEaseScene.h | 缓动过渡 |
| CCTransitionFade | transitions/CCTransitionFade.h | 淡入淡出过渡 |
| CCTransitionMoveInB | transitions/CCTransitionMoveInB.h | 移入过渡 |
| CCTransitionMoveInL | transitions/CCTransitionMoveInL.h | 左移入过渡 |
| CCTransitionMoveInR | transitions/CCTransitionMoveInR.h | 右移入过渡 |
| CCTransitionMoveInT | transitions/CCTransitionMoveInT.h | 上移入过渡 |
| CCTransitionMoveInBL | transitions/CCTransitionMoveInBL.h | 左下移入过渡 |
| CCTransitionPageTurn | transitions/CCTransitionPageTurn.h | 翻页过渡 |
| CCTransitionProgress | transitions/CCTransitionProgress.h | 进度过渡 |
| CCTransitionRotoZoom | transitions/CCTransitionRotoZoom.h | 旋转缩放过渡 |
| CCTransitionScene | transitions/CCTransitionScene.h | 过渡场景基类 |
| CCTransitionShrinkGrow | transitions/CCTransitionShrinkGrow.h | 收缩增长过渡 |
| CCTransitionSlideInB | transitions/CCTransitionSlideInB.h | 下滑入过渡 |
| CCTransitionSlideInL | transitions/CCTransitionSlideInL.h | 左滑入过渡 |
| CCTransitionSlideInR | transitions/CCTransitionSlideInR.h | 右滑入过渡 |
| CCTransitionSlideInT | transitions/CCTransitionSlideInT.h | 上滑入过渡 |
| CCTransitionSplitCols | transitions/CCTransitionSplitCols.h | 列分割过渡 |
| CCTransitionSplitRows | transitions/CCTransitionSplitRows.h | 行分割过渡 |
| CCTransitionTurnOverTiles | transitions/CCTransitionTurnOverTiles.h | 翻转瓦片过渡 |
| CCTransitionZoomFlipX | transitions/CCTransitionZoomFlipX.h | X轴缩放翻转过渡 |
| CCTransitionZoomFlipY | transitions/CCTransitionZoomFlipY.h | Y轴缩放翻转过渡 |
| CCTuint | support/CCValue.h | 无符号整型 |
| CCUserDefault | support/CCUserDefault.h | 用户默认设置 |
| CCValue | support/CCValue.h | 值类 |
| CCVector | support/CCVector.h | 向量 |
| CCWaves | actions/CCWaves.h | 波浪动作 |

---

## 按功能索引

### 场景图系统

- **CCNode** - 节点基类，所有可视对象的父类
- **CCScene** - 场景类，游戏场景的容器
- **CCLayer** - 层类，用于组织游戏元素
- **CCDirector** - 导演类，管理场景切换和游戏循环

### 动作系统

- **CCAction** - 动作基类
- **CCActionInterval** - 间隔动作，需要时间的动作
- **CCActionInstant** - 瞬时动作，立即完成的动作
- **CCSequence** - 序列动作，按顺序执行多个动作
- **CCSpawn** - 并行动作，同时执行多个动作
- **CCRepeat** - 重复动作，重复执行指定次数
- **CCRepeatForever** - 永久重复，无限循环执行

### 渲染系统

- **CCSprite** - 精灵，可渲染的2D图像
- **CCSpriteBatchNode** - 精灵批处理节点，优化渲染性能
- **CCDrawNode** - 绘制节点，用于绘制几何图形
- **CCTexture2D** - 2D纹理，图像数据
- **CCTextureCache** - 纹理缓存，管理纹理资源

### 事件系统

- **CCTouchDispatcher** - 触摸事件分发器
- **CCTouch** - 触摸对象
- **CCTouchHandler** - 触摸处理器
- **CCNotificationCenter** - 通知中心，用于事件通知

### UI组件

- **CCMenu** - 菜单，包含多个菜单项
- **CCMenuItem** - 菜单项基类
- **CCMenuItemImage** - 图像菜单项
- **CCMenuItemLabel** - 标签菜单项
- **CCLabel** - 标签基类
- **CCLabelTTF** - TTF字体标签
- **CCLabelBMFont** - 位图字体标签
- **CCLabelAtlas** - 图集标签

### 动画系统

- **CCAnimation** - 动画类，包含多个帧
- **CCAnimate** - 帧动画动作
- **CCSpriteFrame** - 精灵帧
- **CCSpriteFrameCache** - 精灵帧缓存

### 粒子系统

- **CCParticleSystem** - 粒子系统基类
- **CCParticleSystemQuad** - 四边形粒子系统
- **CCParticleBatchNode** - 粒子批处理节点

### 过渡效果

- **CCTransitionScene** - 过渡场景基类
- **CCTransitionFade** - 淡入淡出过渡
- **CCTransitionMoveInB/L/R/T** - 移入过渡
- **CCTransitionSlideInB/L/R/T** - 滑入过渡
- **CCTransitionZoomFlipX/Y** - 缩放翻转过渡

---

## 相关文档

- [00_文档索引__Documentation-Index.md](00_文档索引__Documentation-Index.md)
- [01_项目概览__Project-Overview.md](01_项目概览__Project-Overview.md)
- [02_核心类架构__Core-Classes-Architecture.md](02_核心类架构__Core-Classes-Architecture.md)

---

**文档版本**: 1.0
**最后更新**: 2026-01-27
