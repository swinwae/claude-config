---
name: learn-anything
description: Use when user wants to turn a GitHub repository into an interactive single-page learning website — generates a zero-install HTML with visual manipulation, Socratic Q&A, code sandbox, and optional AI tutor. Triggers include "把 xxx 做成交互式教程", "生成学习 xxx 的网页", "边玩边学源码".
---

# learn-anything

## Overview

输入 GitHub URL → AI 拆解代码库 → 输出一个**双击即玩**的单文件 HTML 学习网站。

融合 learnGitBranching(关卡+可视化)、Exercism(评测反馈)、Sandpack(代码沙盒)、PocketFlow(AI 提炼抽象)的设计思路。

## 核心原则

1. **单文件产出** — 只生成一个 `<repo>-learn.html`,走 CDN,用户双击即可用
2. **渐进启用** — 没填 API key 时 AI 助手隐藏,其他一切照常运行
3. **章节自包含** — 每章 JSON 独立,不跨章引用状态
4. **循证生成** — 所有讲解/问答必须基于真实源码片段,禁止虚构 API

## When to Use

- "把 xxx repo 做成可交互教程"
- "生成 xxx 源码的学习网页"
- "做个边玩边学 xxx 的小工具"

**不适用**: 纯博客/文档(无交互需求)、单个文件的玩具脚本。

## 4 种交互模式

| mode | 用于 | 渲染引擎 |
|---|---|---|
| `intro` | 每章开场讲解 + 代码片段 | Markdown + highlight.js |
| `visualization` | 可拖拽/点击的抽象图 | D3 / SVG |
| `socratic` | AI 引导式提问(本地预设 + 可调 AI) | Alpine 状态机 |
| `sandbox` | 浏览器里跑 30 行代码 | CodeMirror + Pyodide(懒加载) |

## 生成流程

```
[1] gh repo clone <url> /tmp/learn-<name>       # 拉代码
[2] 读 README + 主要源文件 + package metadata
[3] prompts/01-analyze-repo.md  → 3-7 个核心抽象 + 依赖图
[4] prompts/02-design-curriculum.md → 章节大纲(每章标注 mode)
[5] for each chapter:
      prompts/03-fill-chapter.md → chapter.json
[6] 合并 course.json → 替换 templates/base.html 的 {{COURSE_JSON}}
[7] 写出 ./<repo>-learn.html
[8] `open ./<repo>-learn.html` 自动打开
```

**默认一路到底,不等用户确认**。Step 1-7 连续执行,完成后把产物路径告诉用户。如果用户事后想调整章节/模式,基于生成的 course.json 再改,比在中间停下确认更省 token。

## 章节 JSON schema

见 `schemas/course.schema.json`。最小字段:

```json
{
  "id": "kebab-case-id",
  "title": "人话标题",
  "mode": "intro|visualization|socratic|sandbox",
  "concept": "一句话说清这章讲什么",
  "payload": { /* 按 mode 不同 */ },
  "checkpoint": "读者学会后能做什么"
}
```

每个 mode 的 `payload` 结构见 schema 文件。

## 实现要点

- **不要**把源码整块塞进 HTML,挑 **10-30 行关键片段**
- **不要**为不存在的 API 编问答,所有问题必须能在源码中找到答案
- **visualization 优先**级: 有明确状态流(请求→响应、数据流、树结构)→ 用此模式;否则用 intro
- **sandbox** 仅用于能在 Pyodide 跑的纯逻辑片段(无 IO、无网络)
- **AI 助手**侧边栏:默认折叠,用户点击 → 弹输入 API key 的模态框 → 存 localStorage

## 输出文件命名

`<repo-owner>-<repo-name>-learn.html`,例如 `pallets-flask-learn.html`。

## 常见错误

| 错误 | 正确做法 |
|---|---|
| 中途停下等确认 | 默认一路到底;产物生成后用户自行审阅再迭代 |
| 章节 >10 个 | 控制在 5-8 章,宁少勿多,确保完整 |
| 虚构代码 | 所有引用的函数/类必须 grep 得到 |
| sandbox 里调网络 | Pyodide 不稳定,只用纯逻辑 |
| CSS 全用 Tailwind 动态 class | 复杂视觉用 `<style>` 写死 |

## 文件引用

- 模板: `templates/base.html`
- Prompts: `prompts/01-analyze-repo.md`, `prompts/02-design-curriculum.md`, `prompts/03-fill-chapter.md`
- Schema: `schemas/course.schema.json`
- 参考产物: `examples/demo-flask-mini.html`
