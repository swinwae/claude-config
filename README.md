# claude-config

个人 Claude Code 配置集中管理,**双轨制**:

- **全局配置**(必装) → symlink 到 `~/.claude/`
- **自制 skill/command/agent**(按需) → 打包成 plugin,通过官方 plugin 机制安装,物理上与 `~/.claude/skills/`(lark-cli 地盘)隔离

## 📁 目录结构

```
claude-config/
├── .claude-plugin/
│   └── marketplace.json        # 本仓库也是一个 plugin marketplace
├── plugins/
│   └── personal/               # ← 自制 plugin,装到 ~/.claude/plugins/cache/ 下
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── learn-anything/ # GitHub repo → 交互式学习 HTML
│       ├── commands/
│       │   └── memory-digest.md
│       └── agents/             # 未来加
│
├── CLAUDE.md                   # ← symlink 到 ~/.claude/CLAUDE.md
├── settings.json               # ← symlink
├── statusline-command.sh       # ← symlink
├── rules/                      # ← symlink(被 CLAUDE.md @引用)
│   ├── git-rules.md
│   └── deploy-rules.md
│
├── install.sh                  # symlink 上面的全局项 + 打印 plugin 安装指引
├── uninstall.sh                # 还原 symlink
├── add.sh                      # 把 ~/.claude/ 下新建的资产搬进仓库
└── README.md
```

## 🚀 新机器安装

```bash
git clone git@github.com:swinwae/claude-config.git ~/projects/claude-config
cd ~/projects/claude-config
bash install.sh
```

然后按 `install.sh` 提示在 Claude Code 里执行:

```
/plugin marketplace add /Users/<你>/projects/claude-config
/plugin install personal@swinwae-personal
```

自制 plugin 安装到 `~/.claude/plugins/cache/swinwae-personal/personal/`,**物理上**与 `~/.claude/skills/`(lark-cli 等外部管理的地盘)隔离。

## 🆕 加新 skill / command / agent

### 已在 `~/.claude/` 里创建

```bash
bash ~/projects/claude-config/add.sh ~/.claude/skills/my-new-skill
# → 自动 mv 到 plugins/personal/skills/,并提示 git 命令
# 随后:/plugin reload personal 生效
```

### 直接在仓库 plugin 里创建

```bash
mkdir -p ~/projects/claude-config/plugins/personal/skills/another-skill
vim ~/projects/claude-config/plugins/personal/skills/another-skill/SKILL.md
# /plugin reload personal 让 Claude 重新扫描
```

`add.sh` 智能分流:
- `skills/` `commands/` `agents/` `hooks/` → 进 `plugins/personal/`(走 plugin)
- `rules/` 及其他 → 仓库根 + symlink

## 🔄 日常编辑

修改自制内容 = 直接编辑仓库:

```bash
vim ~/projects/claude-config/plugins/personal/skills/learn-anything/SKILL.md
# Claude 通过 plugin 路径读取,改完 /plugin reload personal 即可
```

改完 `git push`,新机器 `git pull` 秒同步(但记得重新 `/plugin reload personal` 或重启)。

## 🔐 敏感信息

`settings.json` 的 `env` 目前无敏感内容。若未来加 API key,应改用 keychain 或 `.env.local`(已在 `.gitignore`)。

## 🗑 卸载

```bash
bash uninstall.sh             # 还原 symlink(从最近备份恢复)
# Claude Code 内:
/plugin uninstall personal@swinwae-personal
/plugin marketplace remove swinwae-personal
```
