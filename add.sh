#!/usr/bin/env bash
# 把一个资产搬进仓库
#   skill/command/agent → 进 plugins/personal/{skills,commands,agents}/
#   rules/config        → 进仓库根 + symlink
# 用法:
#   bash add.sh ~/.claude/skills/my-new-skill       → plugin/skills/
#   bash add.sh ~/.claude/commands/my-cmd.md        → plugin/commands/
#   bash add.sh ~/.claude/agents/my-agent.md        → plugin/agents/
#   bash add.sh ~/.claude/rules/my-rule.md          → 仓库根 rules/ + symlink

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
PLUGIN_DIR="$REPO_DIR/plugins/personal"

if [[ $# -ne 1 ]]; then
  echo "用法: bash add.sh <~/.claude/ 下的路径>"
  echo ""
  echo "示例:"
  echo "  bash add.sh ~/.claude/skills/my-new-skill"
  echo "  bash add.sh ~/.claude/commands/my-cmd.md"
  echo "  bash add.sh ~/.claude/agents/my-agent.md"
  echo "  bash add.sh ~/.claude/rules/my-rule.md"
  exit 1
fi

# 规范化路径
src="$1"
src="${src/#\~/$HOME}"
[[ "$src" = /* ]] || src="$(pwd)/$src"
src="${src%/}"

if [[ "$src" != "$CLAUDE_DIR"/* ]]; then
  echo "❌ 路径必须在 $CLAUDE_DIR 下: $src"
  exit 2
fi

if [[ -L "$src" ]]; then
  echo "⚠  $src 已经是 symlink,无需再加"
  exit 0
fi

if [[ ! -e "$src" ]]; then
  echo "❌ 路径不存在: $src"
  exit 3
fi

rel="${src#$CLAUDE_DIR/}"          # 如 skills/my-new-skill 或 rules/my-rule.md
top="${rel%%/*}"                   # skills / commands / agents / rules

# 来源警告
warn=""
case "$(basename "$src")" in
  lark-*) warn="这是 lark-* 开头,通常由 lark-cli 自己管。入仓会失去自动升级。" ;;
esac
if [[ -d "$src/.git" ]]; then
  warn="$warn
含 .git/ 子目录,像是从别人仓库 clone 的。入仓会把别人的 git 历史一起搬。"
fi
if [[ -n "$warn" ]]; then
  echo "⚠  可能不该入仓:"
  echo "$warn" | sed 's/^/   /'
  read -p "仍要继续? (y/N) " yn
  [[ "$yn" == "y" || "$yn" == "Y" ]] || { echo "已取消"; exit 0; }
fi

case "$top" in
  skills|commands|agents|hooks)
    # 走 plugin 路径
    dst="$PLUGIN_DIR/$rel"
    if [[ -e "$dst" ]]; then
      echo "❌ plugin 里已存在 $rel"
      exit 4
    fi
    mkdir -p "$(dirname "$dst")"
    mv "$src" "$dst"
    echo "✓ 搬入 plugin: plugins/personal/$rel"
    echo ""
    echo "重新加载: /plugin reload personal"
    echo "下一步 git:"
    echo "  cd $REPO_DIR"
    echo "  git add plugins/personal/$rel"
    echo "  git commit -m \"feat: plugin 新增 $rel\" && git push"
    ;;
  rules|*)
    # 走仓库根 symlink 路径
    dst="$REPO_DIR/$rel"
    if [[ -e "$dst" ]]; then
      echo "❌ 仓库里已存在 $rel"
      exit 4
    fi
    mkdir -p "$(dirname "$dst")"
    mv "$src" "$dst"
    ln -s "$dst" "$src"
    echo "✓ 入仓 + symlink: $rel"
    echo "下一步 git:"
    echo "  cd $REPO_DIR"
    echo "  git add $rel"
    echo "  git commit -m \"feat: 新增 $rel\" && git push"
    ;;
esac
