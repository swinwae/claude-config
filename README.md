# claude-config

个人 Claude Code 配置集中管理:全局偏好、规则、自制 skill、自定义命令、状态栏脚本。

用 **symlink** 把仓库内容链接到 `~/.claude/`,在仓库里改 = Claude Code 立刻生效。

## 📁 目录结构

```
claude-config/
├── CLAUDE.md                  # 全局语言/写作规范
├── settings.json              # harness 设置(permissions / statusLine / enabledPlugins)
├── statusline-command.sh      # 状态栏渲染脚本
├── rules/
│   ├── git-rules.md           # Git commit / 分支 / GitHub 规范
│   └── deploy-rules.md        # 部署流程规范
├── commands/
│   └── memory-digest.md       # /memory-digest 斜杠命令
├── skills/
│   └── learn-anything/        # 自制: GitHub repo → 交互式学习网页
├── install.sh                 # 幂等 symlink 到 ~/.claude/
├── uninstall.sh               # 还原 symlink(从最近备份恢复)
└── .gitignore
```

## 🚀 新机器安装

```bash
git clone git@github.com:swinwae/claude-config.git ~/projects/claude-config
cd ~/projects/claude-config
bash install.sh
```

脚本会:

1. 把仓库内容 symlink 到 `~/.claude/`(冲突的原件备份到 `~/.claude/backups/config-<时间戳>/`)
2. 打印 **plugin 手动安装指引**(从 `settings.json` 的 `enabledPlugins` 读)
3. 提示装 `lark-cli` 初始化 21 个 lark-* skills(如需要)

## 📦 安装后的手动步骤

### Plugin(`install.sh` 会打印具体命令)

```
/plugin install frontend-design@claude-plugins-official
/plugin install context7@claude-plugins-official
/plugin install superpowers@claude-plugins-official
/plugin install playwright@claude-plugins-official
/plugin install jdtls-lsp@claude-plugins-official
/plugin install ui-ux-pro-max@ui-ux-pro-max-skill
/plugin install last30days@last30days-skill
```

### Lark skills(可选)

仓库**不含** lark-* skills(由 `lark-cli` 自己装和升级)。需要的话:

```bash
npm install -g @larksuiteoapi/lark-cli
lark-cli config init     # 会往 ~/.claude/skills/lark-* 写文件
lark-cli auth login      # 登录
```

## 🔄 日常使用

**改现有配置** = 直接编辑仓库文件(symlink 透明):

```bash
cd ~/projects/claude-config
vim skills/learn-anything/SKILL.md
git add . && git commit -m "feat: 调整 learn-anything 的章节规则"
git push
```

**新增 skill / agent / command** — 两种方式:

### A) 已经在 `~/.claude/` 里捣鼓好了,搬进仓库

```bash
bash ~/projects/claude-config/add.sh ~/.claude/skills/my-new-skill
# → 自动 mv 到仓库,再 symlink 回去,并提示 git 三连命令
```

### B) 直接在仓库里新建

```bash
mkdir -p ~/projects/claude-config/skills/another-skill
vim ~/projects/claude-config/skills/another-skill/SKILL.md
bash ~/projects/claude-config/install.sh   # 自动扫描并 symlink 新条目
```

`install.sh` 幂等:已链接的跳过,新增的自动 link。

新机器 `git pull` + `bash install.sh` 即同步全部(含新增的)。

## 🗑 卸载

```bash
bash uninstall.sh   # 删 symlink + 从最近备份恢复原件
```

## 🔐 敏感信息

- `settings.json` 的 `env` 字段目前只有无害标志(`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`),已入仓
- 若未来往 `env` 加 API key,应改用 `.env.local` 或系统 keychain,不要 commit
