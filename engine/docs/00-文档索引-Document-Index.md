# 00-文档索引 Document Index

## 概述 Overview

本文档是Nuclear Engine技术文档的索引，提供了所有文档的快速导航和查找功能。

This document is the index of Nuclear Engine technical documentation, providing quick navigation and lookup functions for all documents.

## 文档列表 Document List

### 1. 01-架构设计文档-Architecture-Design-Document.md

**描述 Description**: 详细描述Nuclear Engine的整体架构设计、模块划分、技术栈、核心设计模式等。

**内容 Contents**:
- 项目简介与技术栈
- 系统架构图
- 核心模块详解（引擎核心、管理器、组件、渲染等）
- 目录结构说明
- 核心设计模式
- 关键技术（坐标系统、内存管理、异步加载、渲染优化、A*寻路）
- 性能优化策略
- 平台适配
- 扩展性
- 安全性

**适用人群 Target Audience**: 架构师、技术负责人、高级开发人员

**阅读顺序 Reading Order**: 第一篇必读

---

### 2. 02-API接口文档-API-Reference-Document.md

**描述 Description**: 详细描述Nuclear Engine的所有公共API接口，包括引擎核心接口、精灵接口、特效接口、世界接口、环境接口等。

**内容 Contents**:
- 引擎核心接口（IEngine）
  - 引擎生命周期
  - 屏幕管理
  - 时间管理
  - 核心管理器访问
  - 任务调度
  - 日志管理
  - 内存管理
  - 渲染控制
  - 窗口状态
- 世界接口（IWorld）
  - 地图管理
  - 精灵管理
  - 不可移动对象管理
  - 特效管理
  - 相机控制
  - A*寻路
  - 障碍管理
  - 游戏时间
  - 战斗背景
- 环境接口（IEnv）
  - 显示模式
  - FPS控制
  - 渲染效果配置
  - 半透明配置
  - 声音系统配置
  - GC配置
  - 平滑移动配置
  - 涉水效果配置
  - 卸载地图声音淡出配置
  - 精灵移动平滑配置
  - 逻辑坐标到世界坐标转换配置
- 精灵接口（ISprite）
  - 位置和方向
  - 可见性控制
  - 颜色和透明度
  - 缩放
  - 模型和组件
  - 动作系统
  - 移动系统
  - 特效绑定
  - 阴影和残影
  - 标题系统
  - 通知系统
- 特效接口（IEffect、IParticleEffect）
  - 播放控制
  - 位置和方向
  - 变换
  - 特效属性
  - 声音控制
  - 通知系统
  - 更新
  - 发射器控制
  - 盲区设置
  - 循环模式
  - 特效链
  - 粒子统计
  - 特殊粒子特效
- 查询接口（IQuery）
  - 动作信息查询
  - 精灵层级信息查询
- 数据结构
  - EngineParameter
  - ActionInfo
  - SpriteLayerInfo
- 枚举类型
  - NuclearSpriteLayer
  - Nuclear_EffectLayer
  - NuclearDirection
  - NuclearWindowState
  - Nuclear_EffectState
  - XPSPRITE_ACTION_LOAD_TYPE
- 使用示例

**适用人群 Target Audience**: 所有开发人员

**阅读顺序 Reading Order**: 在理解架构后阅读

---

### 3. 03-环境配置文档-Environment-Configuration-Document.md

**描述 Description**: 详细说明Nuclear Engine的环境配置方法，包括编译配置、运行时配置、资源路径配置、性能优化配置等。

**内容 Contents**:
- 编译环境配置
  - Windows平台
    - 开发环境要求
    - 项目配置
    - 预处理器定义
    - 包含目录
    - 输出目录
  - Android平台
    - 开发环境要求
    - Android.mk配置
    - 关键编译标志
  - iOS平台
    - 开发环境要求
    - Xcode项目配置
    - 预处理器定义
- 运行时配置
  - 引擎参数配置
    - EngineParameter结构
    - NuclearDisplayMode结构
    - NuclearMultiSampleType枚举
    - 渲染标志
  - 环境配置接口
    - 显示模式配置
    - FPS控制配置
    - 任务执行时间配置
    - 渲染效果配置
    - 半透明配置
    - 声音系统配置
    - GC配置
    - 平滑移动配置
    - 涉水效果配置
    - 卸载地图声音淡出配置
    - 精灵移动平滑配置
    - 逻辑坐标到世界坐标转换配置
- 资源路径配置
  - 资源目录结构
  - 资源加载配置
  - 资源GC配置
- 性能优化配置
  - 渲染优化配置
  - 内存优化配置
  - CPU优化配置
- 调试配置
  - 日志配置
  - 控制台信息配置
  - 帧状态调试信息配置
  - 显示调试信息配置
- 平台特定配置
  - Windows平台特定配置
  - Android平台特定配置
  - iOS平台特定配置
- 配置文件示例
  - 引擎初始化配置示例
  - 环境配置示例
  - 性能优化配置示例
- 配置最佳实践
  - 性能优化建议
  - 内存管理建议
  - 调试建议
- 常见问题FAQ

**适用人群 Target Audience**: 构建工程师、运维人员、开发人员

**阅读顺序 Reading Order**: 在开始项目前阅读

---

### 4. 04-操作流程文档-Operation-Workflow-Document.md

**描述 Description**: 详细说明Nuclear Engine的完整操作流程，包括引擎初始化、精灵管理、特效管理、地图管理、资源管理等核心功能的操作步骤和最佳实践。

**内容 Contents**:
- 引擎初始化流程
  - 完整初始化流程图
  - 初始化代码示例
- 精灵管理流程
  - 创建精灵流程
  - 创建精灵代码示例
  - 精灵移动流程
  - 精灵移动代码示例
  - 精灵动作播放流程
  - 精灵动作播放代码示例
  - 删除精灵流程
  - 删除精灵代码示例
- 特效管理流程
  - 创建场景特效流程
  - 创建场景特效代码示例
  - 创建精灵特效流程
  - 创建精灵特效代码示例
  - 删除特效流程
  - 删除特效代码示例
- 地图管理流程
  - 加载地图流程
  - 加载地图代码示例
  - 卸载地图流程
  - 卸载地图代码示例
- 相机管理流程
  - 附加相机流程
  - 附加相机代码示例
- 资源管理流程
  - 资源预取流程
  - 资源预取代码示例
  - 内存管理流程
  - 内存管理代码示例
- 性能优化流程
  - FPS控制流程
  - FPS控制代码示例
  - 渲染优化流程
  - 渲染优化代码示例
- 调试流程
  - 日志记录流程
  - 日志记录代码示例
  - 调试信息显示流程
  - 调试信息显示代码示例
- 完整游戏流程示例
  - 游戏主循环
- 最佳实践
  - 性能优化建议
  - 内存管理建议
  - 代码规范建议
  - 调试建议

**适用人群 Target Audience**: 所有开发人员

**阅读顺序 Reading Order**: 在理解API后阅读

---

## 文档阅读建议 Document Reading Recommendations

### 新手开发者 Beginner Developers

**推荐阅读顺序 Recommended Reading Order**:
1. 01-架构设计文档-Architecture-Design-Document.md
   - 了解引擎整体架构和技术栈
2. 03-环境配置文档-Environment-Configuration-Document.md
   - 配置开发环境
3. 02-API接口文档-API-Reference-Document.md
   - 学习API接口使用方法
4. 04-操作流程文档-Operation-Workflow-Document.md
   - 学习具体操作流程

### 中级开发者 Intermediate Developers

**推荐阅读顺序 Recommended Reading Order**:
1. 01-架构设计文档-Architecture-Design-Document.md
   - 深入理解引擎架构
2. 02-API接口文档-API-Reference-Document.md
   - 熟悉所有API接口
3. 03-环境配置文档-Environment-Configuration-Document.md
   - 掌握环境配置方法
4. 04-操作流程文档-Operation-Workflow-Document.md
   - 学习最佳实践

### 高级开发者 Advanced Developers

**推荐阅读顺序 Recommended Reading Order**:
1. 01-架构设计文档-Architecture-Design-Document.md
   - 理解引擎设计思想和扩展点
2. 02-API接口文档-API-Reference-Document.md
   - 作为API参考手册使用
3. 03-环境配置文档-Environment-Configuration-Document.md
   - 根据需求调整配置
4. 04-操作流程文档-Operation-Workflow-Document.md
   - 参考最佳实践

### 架构师和技术负责人 Architects and Technical Leads

**推荐阅读顺序 Recommended Reading Order**:
1. 01-架构设计文档-Architecture-Design-Document.md
   - 全面了解引擎架构
2. 03-环境配置文档-Environment-Configuration-Document.md
   - 评估配置方案
3. 02-API接口文档-API-Reference-Document.md
   - 评估API设计

---

## 快速查找 Quick Lookup

### 按功能查找 By Function

#### 引擎初始化 Engine Initialization
- 相关文档: 01-架构设计文档, 03-环境配置文档, 04-操作流程文档
- 关键章节: 引擎初始化流程, 引擎参数配置

#### 精灵管理 Sprite Management
- 相关文档: 02-API接口文档, 04-操作流程文档
- 关键章节: 精灵接口, 精灵管理流程

#### 特效管理 Effect Management
- 相关文档: 02-API接口文档, 04-操作流程文档
- 关键章节: 特效接口, 特效管理流程

#### 地图管理 Map Management
- 相关文档: 02-API接口文档, 04-操作流程文档
- 关键章节: 世界接口, 地图管理流程

#### 性能优化 Performance Optimization
- 相关文档: 01-架构设计文档, 03-环境配置文档, 04-操作流程文档
- 关键章节: 性能优化, 性能优化配置, 性能优化流程

#### 内存管理 Memory Management
- 相关文档: 01-架构设计文档, 03-环境配置文档, 04-操作流程文档
- 关键章节: 内存管理, GC配置, 内存管理流程

#### 编译配置 Compilation Configuration
- 相关文档: 03-环境配置文档
- 关键章节: 编译环境配置

### 按平台查找 By Platform

#### Windows平台 Windows Platform
- 相关文档: 03-环境配置文档
- 关键章节: Windows平台编译配置, Windows平台特定配置

#### Android平台 Android Platform
- 相关文档: 03-环境配置文档
- 关键章节: Android平台编译配置, Android平台特定配置

#### iOS平台 iOS Platform
- 相关文档: 03-环境配置文档
- 关键章节: iOS平台编译配置, iOS平台特定配置

---

## 文档维护 Document Maintenance

### 文档版本 Document Version

- **当前版本 Current Version**: 1.0
- **最后更新 Last Updated**: 2026-01-27
- **维护者 Maintainer**: Nuclear Engine Team

### 更新记录 Update Log

#### Version 1.0 (2026-01-27)
- 初始版本发布
- 包含完整的架构设计文档
- 包含完整的API接口文档
- 包含完整的环境配置文档
- 包含完整的操作流程文档

### 反馈与建议 Feedback and Suggestions

如果您发现文档中的错误或有改进建议，请通过以下方式联系我们：

- **邮箱 Email**: support@nuclearengine.com
- **GitHub Issues**: https://github.com/nuclearengine/engine/issues
- **文档仓库 Document Repository**: https://github.com/nuclearengine/docs

---

## 附录 Appendix

### A. 术语表 Glossary

| 术语 Term | 英文 English | 说明 Description |
|----------|--------------|----------------|
| 引擎 | Engine | Nuclear Engine的核心系统 |
| 精灵 | Sprite | 游戏中的角色、NPC等可移动对象 |
| 特效 | Effect | 游戏中的视觉效果，如技能特效、环境特效等 |
| 地图 | Map | 游戏场景，包含地面、障碍物、背景等 |
| 相机 | Camera | 视口控制，决定玩家看到的内容 |
| 世界 | World | 游戏世界的管理器，包含地图、精灵、特效等 |
| 环境 | Environment | 引擎的环境配置管理器 |
| 管理器 | Manager | 负责管理特定类型资源的组件 |
| 组件 | Component | 精灵的装备部件，如武器、护甲等 |
| 动作 | Action | 精灵的动画，如行走、攻击、待机等 |
| GC | Garbage Collection | 垃圾回收，自动释放不再使用的资源 |
| FPS | Frames Per Second | 每秒帧数，衡量游戏流畅度 |
| API | Application Programming Interface | 应用程序编程接口 |
| SDK | Software Development Kit | 软件开发工具包 |

### B. 常见缩写 Common Abbreviations

| 缩写 Abbreviation | 全称 Full Name | 说明 Description |
|----------------|---------------|----------------|
| API | Application Programming Interface | 应用程序编程接口 |
| SDK | Software Development Kit | 软件开发工具包 |
| GC | Garbage Collection | 垃圾回收 |
| FPS | Frames Per Second | 每秒帧数 |
| A* | A-Star Algorithm | A*寻路算法 |
| 2D | Two-Dimensional | 二维 |
| 3D | Three-Dimensional | 三维 |
| UI | User Interface | 用户界面 |
| NPC | Non-Player Character | 非玩家角色 |
| RT | Render Target | 渲染目标 |
| ARGB | Alpha Red Green Blue | 颜色格式 |
| RGBA | Red Green Blue Alpha | 颜色格式 |
| NDK | Native Development Kit | 原生开发工具包（Android） |
| MSVC | Microsoft Visual C++ | 微软Visual C++编译器 |

### C. 相关资源 Related Resources

- **官方网站 Official Website**: https://www.nuclearengine.com
- **GitHub仓库 GitHub Repository**: https://github.com/nuclearengine/engine
- **API文档在线版 Online API Documentation**: https://docs.nuclearengine.com/api
- **示例代码 Example Code**: https://github.com/nuclearengine/examples
- **视频教程 Video Tutorials**: https://www.youtube.com/nuclearengine
- **社区论坛 Community Forum**: https://forum.nuclearengine.com

### D. 技术支持 Technical Support

如果您在使用Nuclear Engine时遇到问题，可以通过以下方式获取技术支持：

- **官方文档 Official Documentation**: https://docs.nuclearengine.com
- **FAQ页面 FAQ Page**: https://docs.nuclearengine.com/faq
- **技术支持邮箱 Support Email**: support@nuclearengine.com
- **技术支持热线 Support Hotline**: +86-400-XXX-XXXX

---

## 结语 Conclusion

Nuclear Engine技术文档旨在为开发者提供全面、准确、实用的技术参考资料。我们持续改进和更新文档，欢迎您的反馈和建议。

Nuclear Engine technical documentation aims to provide comprehensive, accurate, and practical technical reference materials for developers. We continuously improve and update the documentation and welcome your feedback and suggestions.

感谢您使用Nuclear Engine！

Thank you for using Nuclear Engine!
