#!/usr/bin/env bash
# 幂等安装:把仓库内容 symlink 到 ~/.claude/
# 用法:  bash install.sh
# 冲突:  原文件会被备份到 ~/.claude/backups/config-<时间戳>/

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

echo "== 安装 Claude Code 个人配置 =="
echo "   仓库: $REPO_DIR"
echo "   目标: $CLAUDE_DIR"
echo ""

link_all_in() {
  local subdir="$1"
  [[ -d "$REPO_DIR/$subdir" ]] || return
  for item in "$REPO_DIR/$subdir"/*; do
    [[ -e "$item" ]] || continue
    link "$subdir/$(basename "$item")"
  done
}

# 单文件
link CLAUDE.md
link settings.json
link statusline-command.sh

# 目录下所有条目(新增 skill/agent/command 自动生效)
link_all_in rules
link_all_in commands
link_all_in skills
link_all_in agents

echo ""
echo "== ✅ symlink 完成 =="
echo ""

# 打印 plugin 安装指引
if command -v python3 >/dev/null 2>&1; then
  echo "== Plugin 需要手动安装 =="
  python3 - <<PY
import json, pathlib
cfg = json.loads(pathlib.Path("$REPO_DIR/settings.json").read_text())
plugins = cfg.get("enabledPlugins", {})
for spec in plugins:
    print(f"  /plugin install {spec}")
markets = cfg.get("extraKnownMarketplaces", {})
if markets:
    print("")
    print("第三方 marketplace (自动从 settings.json 加载,通常无需手动添加):")
    for name, info in markets.items():
        repo = info.get("source", {}).get("repo", "?")
        print(f"  - {name}: https://github.com/{repo}")
PY
  echo ""
fi

echo "== 可选: 装 lark-cli =="
echo "  npm install -g @larksuiteoapi/lark-cli  # (或官方推荐方式)"
echo "  lark-cli config init                    # 初始化 21 个 lark-* skills"
echo ""
echo "== 其他手动步骤 =="
echo "  1. Claude Code 重启或 /reload-plugins 生效"
echo "  2. 检查 settings.json 是否需要根据本机调整(如 env 变量)"
