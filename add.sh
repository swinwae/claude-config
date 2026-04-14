#!/usr/bin/env bash
# 把 ~/.claude/ 下某个已有的资产 mv 到仓库并建 symlink 回去
# 用法: bash add.sh ~/.claude/skills/my-new-skill
#       bash add.sh ~/.claude/agents/my-agent.md
#       bash add.sh ~/.claude/commands/my-cmd.md

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

if [[ $# -ne 1 ]]; then
  echo "用法: bash add.sh <~/.claude/ 下的路径>"
  exit 1
fi

# 规范化路径:展开 ~,去掉尾 /
src="$1"
src="${src/#\~/$HOME}"
[[ "$src" = /* ]] || src="$(pwd)/$src"
src="${src%/}"

# 必须在 ~/.claude/ 下
if [[ "$src" != "$CLAUDE_DIR"/* ]]; then
  echo "❌ 路径必须在 $CLAUDE_DIR 下: $src"
  exit 2
fi

# 不能已经是 symlink
if [[ -L "$src" ]]; then
  echo "⚠  $src 已经是 symlink,无需再加"
  exit 0
fi

if [[ ! -e "$src" ]]; then
  echo "❌ 路径不存在: $src"
  exit 3
fi

rel="${src#$CLAUDE_DIR/}"
dst="$REPO_DIR/$rel"

if [[ -e "$dst" ]]; then
  echo "❌ 仓库里已存在 $rel,若要覆盖请先手动删除 $dst"
  exit 4
fi

mkdir -p "$(dirname "$dst")"
mv "$src" "$dst"
ln -s "$dst" "$src"

echo "✓ 已加入仓库: $rel"
echo "  $src"
echo "  → $dst"
echo ""
echo "下一步:"
echo "  cd $REPO_DIR"
echo "  git add $rel && git commit -m \"feat: 新增 $rel\" && git push"
