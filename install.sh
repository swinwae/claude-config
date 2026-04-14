#!/usr/bin/env bash
# 幂等安装:symlink 全局配置 + 打印 plugin 安装指引
# 自制 skill/command/agent 走 plugin 路径,不 symlink
# 冲突:原文件备份到 ~/.claude/backups/config-<时间戳>/

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TS=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$CLAUDE_DIR/backups/config-$TS"

link() {
  local rel="$1"
  local src="$REPO_DIR/$rel"
  local dst="$CLAUDE_DIR/$rel"

  if [[ ! -e "$src" ]]; then
    echo "⚠  仓库里没有 $rel,跳过"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      echo "✓  $rel (已链接)"
      return
    fi
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dst" "$BACKUP_DIR/$rel"
    echo "↻  备份 $rel → backups/config-$TS/$rel"
  fi

  ln -s "$src" "$dst"
  echo "+  $rel"
}

link_all_in() {
  local subdir="$1"
  [[ -d "$REPO_DIR/$subdir" ]] || return
  for item in "$REPO_DIR/$subdir"/*; do
    [[ -e "$item" ]] || continue
    link "$subdir/$(basename "$item")"
  done
}

echo "== 安装 Claude Code 个人配置 =="
echo "   仓库: $REPO_DIR"
echo "   目标: $CLAUDE_DIR"
echo ""

# 全局配置类 (symlink)
link CLAUDE.md
link settings.json
link statusline-command.sh
link_all_in rules

echo ""
echo "== ✅ symlink 完成 =="
echo ""

# 打印 plugin 安装指引
echo "== 在 Claude Code 里执行以下命令 =="
echo ""
echo "1. 注册本仓库为本地 plugin marketplace:"
echo "   /plugin marketplace add $REPO_DIR"
echo ""
echo "2. 安装自制 plugin(含 learn-anything skill + memory-digest 命令等):"
echo "   /plugin install personal@swinwae-personal"
echo ""

# 外部 plugin 指引
if command -v python3 >/dev/null 2>&1; then
  echo "3. 安装 settings.json 里声明的外部 plugin:"
  python3 - <<PY
import json, pathlib
cfg = json.loads(pathlib.Path("$REPO_DIR/settings.json").read_text())
for spec in cfg.get("enabledPlugins", {}):
    print(f"   /plugin install {spec}")
PY
  echo ""
fi

echo "== 可选: 装 lark-cli (如需要 lark-* skills) =="
echo "   npm install -g @larksuiteoapi/lark-cli"
echo "   lark-cli config init"
echo ""
echo "完成后 /reload-plugins 或重启 Claude Code 生效。"
