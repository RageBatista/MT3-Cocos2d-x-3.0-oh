---
name: git-workflow
version: 1.3.0
priority: medium
category: common
description: |
  MT3项目Git工作流技能。涵盖分支策略、提交规范、合并冲突处理和代码审查流程。
  触发词: Git, 版本控制, 分支, 提交, 合并, 冲突, PR, 代码审查, rebase, cherry-pick, hotfix, develop
allowed-tools:
  - Bash
---

# Git 工作流技能 (MT3 项目)

**版本**: v1.3.0
**最后更新**: 2026-04-11

---

## 🔄 MT3 项目工作流

### 分支策略

```
main (主分支)
  ├── develop (开发分支)
  │     ├── feature/player-system (功能分支)
  │     ├── feature/chat-system (功能分支)
  │     └── bugfix/login-crash (修复分支)
  └── hotfix/critical-bug (热修复分支)
```

### 分支命名规范

| 分支类型 | 命名格式 | 示例 |
|---------|---------|------|
| **功能分支** | feature/功能名 | feature/player-inventory |
| **修复分支** | bugfix/问题描述 | bugfix/login-timeout |
| **热修复** | hotfix/紧急问题 | hotfix/server-crash |
| **发布分支** | release/版本号 | release/v1.2.0 |

---

## 🛠️ 常用命令

### 1. 初始化和克隆

```bash
# 克隆项目
git clone <repository-url>
cd MT3

# 查看当前状态
git status

# 查看当前分支
git branch
```

### 2. 日常工作流

```bash
# 1. 更新主分支
git checkout main
git pull origin main

# 2. 创建功能分支
git checkout -b feature/my-feature

# 3. 修改代码...

# 4. 查看修改
git status
git diff

# 5. 暂存修改
git add .
# 或者选择性暂存
git add client/src/MyFile.cpp

# 6. 提交修改
git commit -m "feat: 添加玩家背包系统

- 实现背包数据结构
- 添加物品增删改查接口
- 完成 Lua 接口绑定"

# 7. 推送到远程
git push origin feature/my-feature
```

### 3. 分支管理

```bash
# 查看所有分支
git branch -a

# 切换分支
git checkout develop

# 创建并切换分支
git checkout -b feature/new-feature

# 删除本地分支
git branch -d feature/old-feature

# 删除远程分支
git push origin --delete feature/old-feature

# 合并分支
git checkout develop
git merge feature/my-feature

# 变基 (rebase)
git checkout feature/my-feature
git rebase develop
```

### 4. 撤销操作

```bash
# 撤销工作区修改
git checkout -- file.cpp

# 撤销暂存区修改
git reset HEAD file.cpp

# 修改最后一次提交
git commit --amend

# 回退到某个提交
git reset --soft HEAD~1  # 保留修改
git reset --hard HEAD~1  # 丢弃修改

# 回退某个文件到某次提交
git checkout <commit-hash> -- file.cpp
```

### 5. 查看历史

```bash
# 查看提交历史
git log

# 简洁查看
git log --oneline

# 查看图形化历史
git log --graph --oneline --all

# 查看某个文件的修改历史
git log --follow file.cpp

# 查看某次提交的详情
git show <commit-hash>

# 查看谁修改了某行代码
git blame file.cpp
```

---

## 📝 提交规范

### 提交消息格式

```
<类型>: <简短描述>

<详细描述>

<相关信息>
```

### 提交类型

| 类型 | 说明 | 示例 |
|-----|------|------|
| **feat** | 新功能 | feat: 添加背包系统 |
| **fix** | 修复 bug | fix: 修复登录超时问题 |
| **refactor** | 重构 | refactor: 优化精灵渲染流程 |
| **perf** | 性能优化 | perf: 优化物品查询性能 |
| **docs** | 文档 | docs: 更新 API 文档 |
| **style** | 代码格式 | style: 统一代码缩进 |
| **test** | 测试 | test: 添加背包系统测试 |
| **chore** | 构建/工具 | chore: 更新构建脚本 |

### 好的提交示例

```bash
# ✅ 好的提交
git commit -m "feat: 实现玩家背包系统

- 添加 Inventory 类管理背包数据
- 实现物品增删改查接口
- 完成 Lua 接口绑定
- 添加单元测试

相关 Issue: #123"

# ❌ 不好的提交
git commit -m "修改"
git commit -m "update"
git commit -m "fix bug"
```

---

## 🔀 合并策略

### 1. Merge (合并)

```bash
# 从 feature 分支合并到 develop
git checkout develop
git merge feature/my-feature

# 优点: 保留完整历史
# 缺点: 产生合并提交
```

### 2. Rebase (变基)

```bash
# 将 feature 分支变基到 develop
git checkout feature/my-feature
git rebase develop

# 优点: 历史线性，干净
# 缺点: 改写历史，可能有风险
```

### 3. Squash (压缩)

```bash
# 压缩提交后合并
git checkout develop
git merge --squash feature/my-feature
git commit -m "feat: 完整功能描述"

# 优点: 多个提交合并为一个
# 缺点: 丢失中间提交信息
```

### 选择建议

| 场景 | 推荐策略 |
|-----|---------|
| 功能分支合并到 develop | Merge (保留历史) |
| 更新 feature 分支 | Rebase (保持干净) |
| 实验性多次提交 | Squash (简化历史) |
| 热修复合并到 main | Merge (保留记录) |

---

## ⚠️ 冲突处理

### 1. 识别冲突

```bash
# 合并时出现冲突
git merge feature/my-feature
# Auto-merging client/src/Player.cpp
# CONFLICT (content): Merge conflict in client/src/Player.cpp
# Automatic merge failed; fix conflicts and then commit the result.

# 查看冲突文件
git status
```

### 2. 解决冲突

```cpp
// 冲突标记
<<<<<<< HEAD
// 当前分支的代码
void Player::SetLevel(int level) {
    m_level = level;
    UpdateDisplay();
}
=======
// 合并分支的代码
void Player::SetLevel(int level) {
    m_level = level;
    NotifyObservers();
}
>>>>>>> feature/my-feature

// 解决后
void Player::SetLevel(int level) {
    m_level = level;
    UpdateDisplay();
    NotifyObservers();
}
```

### 3. 完成合并

```bash
# 标记冲突已解决
git add client/src/Player.cpp

# 继续合并
git commit

# 如果是 rebase，使用
git rebase --continue
```

---

## 🎯 工作流程示例

### 场景1：开发新功能

```bash
# 1. 确保主分支最新
git checkout main
git pull origin main

# 2. 创建功能分支
git checkout -b feature/player-trade

# 3. 开发功能 (多次提交)
git add .
git commit -m "feat: 添加交易请求协议"

git add .
git commit -m "feat: 实现交易逻辑"

git add .
git commit -m "feat: 添加交易 UI"

# 4. 推送到远程
git push origin feature/player-trade

# 5. 创建 Pull Request (在 GitHub/GitLab)

# 6. 代码审查通过后，合并到 main
git checkout main
git pull origin main
git merge feature/player-trade
git push origin main

# 7. 删除功能分支
git branch -d feature/player-trade
git push origin --delete feature/player-trade
```

### 场景2：修复紧急 bug

```bash
# 1. 从 main 创建热修复分支
git checkout main
git checkout -b hotfix/server-crash

# 2. 修复 bug
git add .
git commit -m "hotfix: 修复服务器崩溃问题

问题: 空指针导致服务器崩溃
原因: PlayerManager 未检查 null
解决: 添加空指针检查"

# 3. 合并回 main
git checkout main
git merge hotfix/server-crash
git push origin main

# 4. 同时合并到 develop
git checkout develop
git merge hotfix/server-crash
git push origin develop

# 5. 删除热修复分支
git branch -d hotfix/server-crash
```

### 场景3：同步远程更新

```bash
# 当前在功能分支开发
git checkout feature/my-feature

# 远程 develop 有更新，需要同步
git fetch origin
git rebase origin/develop

# 如果有冲突，解决后
git add .
git rebase --continue

# 强制推送 (因为改写了历史)
git push origin feature/my-feature --force-with-lease
```

---

## 📚 最佳实践

### 1. 提交原则

```
✅ DO:
- 每个提交只做一件事
- 提交消息清晰明确
- 提交前测试代码
- 提交完整的功能

❌ DON'T:
- 不要提交未完成的代码
- 不要提交大量无关文件
- 不要提交敏感信息
- 不要跳过测试就提交
```

### 2. 分支管理

```
✅ DO:
- 定期删除已合并的分支
- 保持分支命名规范
- 及时同步远程更新
- 使用有意义的分支名

❌ DON'T:
- 不要在 main 分支直接开发
- 不要保留过时的分支
- 不要在错误的分支工作
- 不要忘记推送分支
```

### 3. 协作原则

```
✅ DO:
- 提交前先 pull
- 推送前先测试
- 定期同步主分支
- 及时处理冲突

❌ DON'T:
- 不要强制推送到共享分支
- 不要改写已推送的历史
- 不要忽略代码审查
- 不要提交冲突标记
```

---

## 🔧 常见问题

### Q1: 如何撤销已推送的提交?

```bash
# 方法1: revert (推荐)
git revert <commit-hash>
git push origin main

# 方法2: reset (慎用)
git reset --hard <commit-hash>
git push origin main --force-with-lease
```

### Q2: 如何合并多个提交?

```bash
# 交互式 rebase
git rebase -i HEAD~3

# 在编辑器中将 pick 改为 squash
# pick abc123 first commit
# squash def456 second commit
# squash ghi789 third commit
```

### Q3: 如何暂存未完成的工作?

```bash
# 暂存当前修改
git stash

# 查看暂存列表
git stash list

# 恢复暂存
git stash pop

# 恢复特定暂存
git stash apply stash@{0}
```

### Q4: 如何查找引入 bug 的提交?

```bash
# 使用 git bisect
git bisect start
git bisect bad              # 当前版本有 bug
git bisect good <commit>    # 某个版本没有 bug

# Git 会自动二分查找
# 每次测试后标记
git bisect good  # 或 git bisect bad

# 找到后
git bisect reset
```

---

## ✅ 技能检查清单

### 初级检查点
- [ ] 能够克隆和初始化仓库
- [ ] 能够进行日常提交和推送
- [ ] 能够创建和切换分支
- [ ] 能够查看提交历史
- [ ] 能够解决简单冲突

### 中级检查点
- [ ] 理解不同合并策略
- [ ] 能够使用 rebase
- [ ] 能够压缩提交
- [ ] 能够使用 stash
- [ ] 能够处理复杂冲突

### 高级检查点
- [ ] 能够设计工作流程
- [ ] 能够进行代码审查
- [ ] 能够使用 bisect 定位问题
- [ ] 能够维护清晰的历史
- [ ] 能够指导团队使用 Git

---

## 📚 推荐资源

### 官方文档
- [Pro Git Book](https://git-scm.com/book/zh/v2) - Git 官方教程
- [Git Cheat Sheet](https://training.github.com/) - Git 速查表

### 可视化工具
- **GitKraken** - 图形化 Git 客户端
- **SourceTree** - 免费 Git GUI
- **VS Code Git** - VS Code 内置 Git 支持

---

**相关技能**:
- [C++ 开发](../client/cpp-development.md)
- [Java 开发](../server/java-development.md)
- [调试技巧](debugging.md)

**下次更新**: 2026-02-20

---

## 📋 更新日志

### v1.1.0 (2025-11-24)
- 添加版本控制和更新日志
- 完善技能检查清单
- 更新相关技能链接

### v1.0.0 (初始版本)
- 创建 Git 工作流技能文档
- 包含分支策略、提交规范、冲突处理
