# Step 2: 设计章节大纲,为每章匹配交互模式

**用途**: 基于 Step 1 的抽象清单,规划 5-8 章的学习路径,并为每章选最合适的**交互模式**。

## 输入

- Step 1 产出的 `abstractions.json` (已经过用户确认)
- repo 源码(按需 grep 查看)

## 你要做的

1. **排序**: 按 `learn_priority` + 依赖关系拓扑排序
2. **合并/拆分**: 把过小的抽象合并成一章;过大的拆成 2 章(但总数 ≤ 8)
3. **选模式**: 为每章在 4 种交互模式中挑**最能让这个概念"活起来"**的那种
4. **起名**: 章节标题要是**人话**,不是 API 名(例: "路由是怎么找到处理函数的" 好过 "Router 类")

## 4 种模式的选择原则

| 模式 | 什么时候用 | 避开 |
|---|---|---|
| `intro` | 章节开篇,或纯讲解类(设计哲学、术语)| 可以可视化/沙盒的东西别用 intro |
| `visualization` | 有**明确结构/状态流**: 树、图、请求链路、数据流 | 抽象到没有图可画的东西 |
| `socratic` | 有**思考分叉**: 为什么 A 不 B?如果...会怎样? | 无法引发思考的纯事实 |
| `sandbox` | 有**30 行内可跑的纯逻辑片段**(Pyodide 可运行) | 需要网络/文件/框架依赖的代码 |

**建议混搭**: 第 1 章 intro (破冰),中间几章 visualization + socratic 交替,靠后放 1-2 个 sandbox,末章 intro 做总结。

## 输出格式

```json
{
  "meta": {
    "title": "学习 <repo-name>: <副标题>",
    "repo": "https://github.com/owner/name",
    "repoName": "owner/name"
  },
  "curriculum": [
    {
      "id": "ch01-intro",
      "title": "<人话标题>",
      "mode": "intro|visualization|socratic|sandbox",
      "concept": "一句话说这章讲什么",
      "based_on": ["abstraction-id"],
      "rationale": "为什么选这个模式(给作者看,不进最终产物)"
    }
  ]
}
```

## 规则

- **5-8 章**,不要超
- 每章 `based_on` 至少一个 abstraction id
- 同一模式连续 ≤ 2 章(避免节奏单调)
- 最后一章建议是 intro 类型的"串起来"总结

## 衔接下一步

**不要停下问用户**。输出 JSON 后可以简短告知用户大纲(一行 N 章+模式分布),然后立刻对每章调用 Step 3 填内容。整个生成过程一路到底,完成后告知产物路径。
