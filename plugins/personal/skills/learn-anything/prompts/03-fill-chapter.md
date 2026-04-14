# Step 3: 为单章生成完整内容 (chapter.json)

**用途**: 对 Step 2 大纲里的**每一章**调用此 prompt,产出符合 schema 的 `chapter.json`。

## 输入

- 当前章的 `{ id, title, mode, concept, based_on, rationale }`
- 对应 abstraction 的 evidence 源码片段 (按需读)

## 通用字段 (所有 mode 都要)

```json
{
  "id": "同输入",
  "title": "同输入",
  "mode": "同输入",
  "concept": "同输入",
  "checkpoint": "读完这章,学习者应该能做到/能说出的一件具体的事",
  "payload": { /* 按下面 mode 分别填 */ }
}
```

## mode = intro

```json
"payload": {
  "markdown": "GitHub-flavored Markdown。控制在 300-500 字。可以带行内代码。",
  "snippet": {
    "path": "src/xxx.py",
    "lang": "python",
    "code": "真实源码片段,10-25 行,关键逻辑"
  }
}
```

- `markdown` 要有**具体画面感**,别泛泛而谈;用比喻、类比让概念落地
- `snippet` 是 optional,但只要有合适的片段就一定放

## mode = visualization

```json
"payload": {
  "intro": "Markdown 简介,100-200 字",
  "type": "graph | tree",
  "nodes": [{ "id": "handler_list", "label": "/users GET", "note": "鼠标悬浮看备注" }],
  "links": [{ "source": "handler_list", "target": "database" }],
  "root": { /* 只当 type=tree 时用, 递归 { id, label, children:[] } */ },
  "interactions": ["拖拽节点改变布局", "悬浮看注释"]
}
```

- `graph` 用于网络/依赖,`tree` 用于层级
- nodes 控制在 5-12 个,再多就糊了
- **label 必须是中文短语**(≤ 6 字,最多 8 字符),英文 API 名/类名/函数名放 `note` 字段(悬停可见)。产品名如 Telegram/Docker 保留原名
- `interactions` 描述用户能玩什么
- 图会自动渲染箭头,设计 `links` 时注意 **source → target** 表达真实流向(不是"相关")

## mode = socratic

```json
"payload": {
  "context": "Markdown 铺垫 100-200 字,给出提问的背景",
  "questions": [
    {
      "q": "开放式问题,引发思考",
      "hint": "一句话提示,不给答案",
      "answer": "参考答案,Markdown,50-150 字,解释本质"
    }
  ]
}
```

- **2-4 个问题**,按难度递增
- 问题要**开放**、能让人思考,禁止 yes/no 问题
- hint 和 answer 必须基于真实源码,不能编造

## mode = sandbox

```json
"payload": {
  "intro": "Markdown 100-200 字,说清要做什么",
  "task": "一句话任务描述 (显示在代码框上方)",
  "starter": "def hello():\n    # TODO: 完成这里\n    pass\n\nprint(hello())",
  "expect": "预期 print 输出包含的字符串(用于自动判分)"
}
```

- `starter` 纯 Python,**可以在 Pyodide 跑**,无 IO 无网络
- 代码 ≤ 30 行
- `expect` 是简单子串匹配;没法自动判的就省略此字段

## 规则总则

- 所有引用的函数/类/变量必须在源码中真实存在 (grep 得到)
- 禁止虚构行号
- Markdown 中的代码块不写超过 15 行 (长片段放 snippet 字段)
- `checkpoint` 要具体、可验证 (不要"理解 X",要"能解释 X 的查找顺序")

## 输出

对每章输出一份 chapter.json。全部完成后合并:

```json
{
  "meta": { /* Step 2 的 meta */ },
  "chapters": [ /* Step 3 每章的 JSON 数组 */ ]
}
```

## 最后一步

把合并后的 JSON 字符串 minify,替换 `templates/base.html` 里的 `/*{{COURSE_JSON}}*/` 注释(连同注释符号都替换),另存为 `<owner>-<name>-learn.html`,放在当前工作目录。然后 `open` 自动打开让用户试玩。
