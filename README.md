# XLM - 学了么

> 在艾泽拉斯背四六级。  
> Learn English in World of Warcraft.

<div align="center">

![Lua](https://img.shields.io/badge/Lua-WoW_Addon-blue)
![WoW](https://img.shields.io/badge/Game-World%20of%20Warcraft-orange)
![License](https://img.shields.io/badge/License-GPLv3-green)

</div>

---

# 项目介绍

XLM（学了么）是一个基于《魔兽世界》插件系统开发的英语学习插件。

目前专注于：

- 英语四级（CET-4）
- 英语六级（CET-6）

词汇练习与记忆。

玩家可以在：

- 排副本
- 飞行途中
- 主城挂机
- 日常休闲

进行四六级单词学习。

目标：

> 让背单词不再枯燥。

---

# 功能

## 当前功能

- [x] 魔兽插件基础框架
- [x] 自定义 UI
- [x] 四六级词汇显示
- [x] 单词输入检测
- [x] 错误提示
- [x] Lua 插件结构

---

## 计划功能

### 四六级词汇

- CET-4 单词库
- CET-6 单词库
- 随机单词练习
- 中文释义
- 错词记录
- 熟练度系统

---

### 学习模式

- 拼写模式
- 选择题模式
- 默写模式
- 连续答题模式

---

### 魔兽游戏化

- 学习经验值
- 等级系统
- 连击奖励
- 学习成就
- 稀有称号

---

# UI 风格

插件 UI 设计参考：

- 魔兽争霸3
- 原版 WoW 风格
- 暗黑幻想风格

目标：

> 看起来像暴雪官方小游戏。

---

# 技术栈

| 技术 | 用途 |
|---|---|
| Lua | 魔兽插件开发 |
| WoW API | 游戏接口 |
| XML | UI 布局 |
| SavedVariables | 数据存储 |

---

# 安装方式

## 1. 下载项目

```bash
git clone https://github.com/xiaoaoshan/xlm.git
```

或者直接下载 ZIP。

---

## 2. 放入插件目录

```text
World of Warcraft/_classic_/Interface/AddOns/
```

或者：

```text
World of Warcraft/_retail_/Interface/AddOns/
```

最终目录结构：

```text
AddOns/
└── xlm/
    ├── xlm.toc
    ├── core.lua
    ├── ui/
    └── data/
```

---

## 3. 进入游戏启用插件

角色选择界面：

```text
插件 -> 勾选 XLM
```

---

# 开发目标

XLM 希望将：

- 魔兽世界
- 英语学习
- 游戏化成长

结合起来。

让玩家在游戏过程中也能积累英语词汇。

---

# 开源协议

本项目基于 GPL v3 协议开源。

你可以：

- 自由使用
- 修改代码
- 二次开发
- 分发项目

但修改后的项目也必须继续开源并遵循 GPL v3 协议。

协议全文：

https://www.gnu.org/licenses/gpl-3.0.html

---

# 作者

GitHub：

https://github.com/xiaoaoshan/xlm

---

> “为了部落，也为了四六级。”
>
> # 致谢

本项目灵感来源于：

- Qwerty Learner
- 魔兽世界插件生态
- 游戏化学习理念

特别感谢：

Qwerty Learner 项目作者与贡献者们。

Qwerty Learner 让“背单词”这件事第一次变得像游戏一样有趣，  
也给了本项目很多设计灵感。

项目地址：

https://github.com/RealKai42/qwerty-learner
