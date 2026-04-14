# 记忆总结

从最近的 Claude Code 会话记录中提取值得长期记住的内容，经用户圈选后写入记忆文件。

## 记忆存储位置

~/.claude/notes/memory/，按主题分 5 个文件：
- preferences.md — 用户偏好与工作习惯
- projects.md — 项目状态与决策
- learnings.md — 技术学习与验证过的实践
- references.md — 外部资源与参考指针
- feedback.md — 对 Claude 协作方式的反馈

## 执行步骤

### 第一步：找到最近的会话文件

运行以下命令，取最近 5 个顶层 session JSONL（排除 subagents）：

```bash
find ~/.claude/projects -maxdepth 3 -name "*.jsonl" -not -path "*/subagents/*" -print0 | xargs -0 stat -f "%m %z %N" | sort -rn | head -5
```

### 第二步：派 Explore subagent 提取候选记忆

派一个 Explore subagent 读取这些 JSONL 文件。提取以下类别的信息：
- **user** — 用户身份、角色、偏好、技术背景
- **feedback** — 用户对 Claude 工作方式的纠正或确认
- **project** — 正在进行的工作、决策、原因
- **reference** — 外部系统的指针（URL、工具、文档位置）
- **learning** — 反复确认过的技术事实或最佳实践

忽略：一次性调试过程、代码片段、闲聊、工具原始输出。

提取前先读一遍现有的记忆文件（~/.claude/notes/memory/*.md），避免输出重复内容。

每条候选记忆需包含：编号、类别、标题、一两句话内容（保留"为什么"）、来源 session 标识、信心（高/中/低）。

### 第三步：展示候选清单给用户

按建议归档的主题文件分组，用表格展示。附上简要建议（哪些推荐留、哪些偏弱）。

等用户圈选。

### 第四步：写入记忆文件

将用户选中的条目**追加**到对应的 .md 文件末尾（不覆盖已有内容）。使用 Edit 工具追加，不用 Write 覆盖。

## 特殊指令

- 如果用户说"记一下 xxx"而不是要求完整总结，直接判断主题追加到对应文件即可，不需要走完整流程
- 如果用户指定了要总结的 session 数量（如"最近 10 个"），按用户要求调整
- 大文件（>500KB）用 offset 分批读，重点提取用户发言和 assistant 文字回复
