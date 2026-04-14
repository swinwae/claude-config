#!/usr/bin/env bash
# 还原:删除 symlink,从最近一次备份恢复原件(如有)
# 用法:  bash uninstall.sh

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
LATEST_BACKUP=$(ls -1dt "$CLAUDE_DIR/backups"/config-* 2>/dev/null | head -1 || true)

unlink_one() {
  local rel="$1"
  local dst="$CLAUDE_DIR/$rel"
  if [[ -L "$dst" ]]; then
    rm "$dst"
    echo "-  $rel (移除 symlink)"
    if [[ -n "$LATEST_BACKUP" && -e "$LATEST_BACKUP/$rel" ]]; then
      mkdir -p "$(dirname "$dst")"
      mv "$LATEST_BACKUP/$rel" "$dst"
      echo "↩  $rel (从 $(basename $LATEST_BACKUP) 还原)"
    fi
  fi
}

echo "== 卸载 (最近备份: ${LATEST_BACKUP:-无}) =="
unlink_one CLAUDE.md
unlink_one settings.json
unlink_one statusline-command.sh
unlink_one rules/git-rules.md
unlink_one rules/deploy-rules.md
unlink_one commands/memory-digest.md
unlink_one skills/learn-anything
echo ""
echo "== 完成 =="
echo "仓库 $(cd "$(dirname "$0")" && pwd) 保持不变,可随时重跑 install.sh"
