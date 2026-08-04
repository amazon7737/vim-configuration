#!/usr/bin/env bash
# 새 맥에 tmux + Claude Code 에이전트 운영 환경을 세팅한다.
#
#   ./install-tmux-agents.sh              실제 설치
#   ./install-tmux-agents.sh --dry-run    무엇이 바뀔지만 출력
#
# 하는 일:
#   1. tmux/tmux.conf          → ~/.tmux.conf              (기존 파일은 .bak 로 백업)
#   2. bin/claude-*            → ~/.local/bin/             (실행 권한 부여)
#   3. launchd/*.plist         → ~/Library/LaunchAgents/   (__HOME__ 치환 후 로드)
#   4. zsh/tmux-agents.zsh     → ~/.zshrc 에 source 라인 추가 (이미 있으면 건너뜀)
#   5. tpm + tmux-resurrect/continuum 설치
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

say() { printf '%s\n' "$*"; }
run() {
  if [ "$DRY" -eq 1 ]; then say "  [dry] $*"; else eval "$@"; fi
}

say "== 1. tmux.conf =="
if [ -f "$HOME/.tmux.conf" ] && ! cmp -s "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf"; then
  run "cp '$HOME/.tmux.conf' '$HOME/.tmux.conf.bak'"
  say "  기존 ~/.tmux.conf → ~/.tmux.conf.bak"
fi
run "cp '$REPO/tmux/tmux.conf' '$HOME/.tmux.conf'"

say "== 2. claude-snapshot / claude-restore =="
run "mkdir -p '$HOME/.local/bin'"
for f in claude-snapshot claude-restore; do
  run "cp '$REPO/bin/$f' '$HOME/.local/bin/$f'"
  run "chmod +x '$HOME/.local/bin/$f'"
done
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) say "  주의: ~/.local/bin 이 PATH 에 없다. ~/.zshrc 에 추가할 것:"
     say "        export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

say "== 3. LaunchAgent (5분마다 세션 스냅샷) =="
run "mkdir -p '$HOME/Library/LaunchAgents'"
for p in "$REPO"/launchd/*.plist; do
  name="$(basename "$p")"
  label="${name%.plist}"
  dest="$HOME/Library/LaunchAgents/$name"
  run "sed 's#__HOME__#$HOME#g' '$p' > '$dest'"
  run "launchctl bootout gui/\$(id -u)/$label 2>/dev/null || true"
  run "launchctl bootstrap gui/\$(id -u) '$dest'"
  say "  $label 등록"
done

say "== 4. zsh 함수 =="
marker="source .*tmux-agents.zsh"
if grep -qE "$marker" "$HOME/.zshrc" 2>/dev/null; then
  say "  ~/.zshrc 에 이미 source 라인 있음 — 건너뜀"
elif grep -q '^tmux() {' "$HOME/.zshrc" 2>/dev/null; then
  say "  ~/.zshrc 에 tmux 래퍼가 이미 인라인으로 있음 — 건너뜀"
  say "  (레포 쪽 최신 내용으로 바꾸려면 zsh/tmux-agents.zsh 를 직접 반영할 것)"
else
  run "mkdir -p '$HOME/.config/zsh'"
  run "cp '$REPO/zsh/tmux-agents.zsh' '$HOME/.config/zsh/tmux-agents.zsh'"
  run "printf '\n# tmux + Claude Code 에이전트 운영 함수\nsource \"\$HOME/.config/zsh/tmux-agents.zsh\"\n' >> '$HOME/.zshrc'"
  say "  ~/.zshrc 에 source 라인 추가"
fi

say "== 5. tmux 플러그인 (tpm + resurrect + continuum) =="
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  say "  tpm 이미 설치됨"
else
  run "git clone --depth 1 https://github.com/tmux-plugins/tpm '$HOME/.tmux/plugins/tpm'"
fi
if [ "$DRY" -eq 0 ]; then
  # tpm 설치 스크립트는 tmux 서버가 떠 있어야 동작한다
  tmux new-session -d -s __install 2>/dev/null || true
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true
  tmux kill-session -t __install 2>/dev/null || true
  say "  플러그인 설치 완료"
else
  say "  [dry] tpm install_plugins"
fi

say
if [ "$DRY" -eq 1 ]; then
  say "미리보기 끝. 실제로 설치하려면 --dry-run 빼고 실행."
else
  say "완료. 새 터미널을 열고 'agents' 로 진입하면 된다."
  say "치트시트는 'tmuxh'."
fi
