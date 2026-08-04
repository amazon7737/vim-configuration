# ─────────────────────────────────────────────────────────────
# tmux + Claude Code 에이전트 운영용 zsh 함수 모음
#
#   tmux    — iTerm2 통합 모드(-CC)를 조건에 맞을 때만 자동으로 붙이는 래퍼
#   agents  — 에이전트 작업 세션 진입점
#   tmuxh   — 치트시트
#
# 이 파일 전체를 ~/.zshrc 에 붙여넣거나, 파일로 두고 아래처럼 불러온다.
#   source ~/.config/zsh/tmux-agents.zsh
# ─────────────────────────────────────────────────────────────

# tmux 를 iTerm2 통합 모드(-CC)로 기본 실행한다.
# 세션을 새로 만들거나 붙는 명령(new / new-session / attach / a)만 대상이고,
# 아래 경우에는 손대지 않고 원래대로 동작한다:
#   - 이미 tmux 안에 있을 때 ($TMUX)
#   - iTerm2 가 아닌 터미널이거나 SSH 로 붙어 있을 때 (-CC 를 못 알아듣는다)
#   - 출력이 터미널이 아닐 때 — `x=$(tmux display-message -p '#S')` 같은 조회
#   - ls / kill-session / send-keys 같은 비대화형 서브커맨드
#   - 이미 -C 나 -CC 를 직접 준 경우
#   - TMUX_NO_CC=1 로 껐을 때  (예: TMUX_NO_CC=1 tmux new -s plain)
tmux() {
  if [[ -n "$TMUX" || -n "$TMUX_NO_CC" || -n "$SSH_TTY$SSH_CONNECTION" \
        || "$TERM_PROGRAM" != "iTerm.app" || ! -t 1 ]]; then
    command tmux "$@"
    return
  fi

  # 전역 옵션을 건너뛰고 첫 서브커맨드를 찾는다 (-f/-L/-S/-T 는 값을 하나 먹는다)
  local -a a=("$@")
  local i=1 sub=""
  while (( i <= ${#a} )); do
    case "${a[i]}" in
      -f|-L|-S|-T) (( i += 2 )) ;;
      -C|-CC)      command tmux "$@"; return ;;
      -*)          (( i++ )) ;;
      *)           sub="${a[i]}"; break ;;
    esac
  done

  # 인자 없는 `tmux` 는 new-session 과 같다. new-window 는 대상이 아니라서
  # new 는 정확히 일치할 때만, new-s* 는 접두어로 받는다.
  case "$sub" in
    ""|new|new-s*|a|at|att*) command tmux -CC "$@" ;;
    *)                       command tmux "$@" ;;
  esac
}

# 에이전트 작업용 tmux 세션에 iTerm2 통합 모드(-CC)로 진입한다.
# 있으면 붙고(-A) 없으면 만든다. 매일 이거 하나만 치면 된다.
#   agents        → 기본 세션(agents)
#   agents 이름   → 다른 이름의 세션
agents() {
  local name="${1:-agents}"
  if [[ -n "$TMUX" ]]; then
    echo "이미 tmux 안이야 (세션: $(tmux display-message -p '#S'))"
    return 1
  fi
  # -CC 는 위 tmux 래퍼가 환경을 보고 알아서 붙인다.
  # (SSH 나 Terminal.app 에서는 안 붙어야 정상 동작한다)
  tmux new-session -A -s "$name"
}

tmuxh() {
  echo "tmux quick guide — iTerm2 통합 모드(-CC) 기준"
  echo
  echo "현재 세션:"
  tmux ls 2>/dev/null || echo "  없음 (서버 안 떠 있음)"
  echo
  echo "진입 (전부 자동으로 -CC 통합 모드로 뜬다):"
  echo "  agents                      # 평소 이것만 쓰면 됨 (세션명: agents)"
  echo "  agents 이름                 # 다른 이름의 세션으로"
  echo "  tmux new -s 이름            # 새 세션"
  echo "  tmux a -t 이름              # 기존 세션 붙기"
  echo "  TMUX_NO_CC=1 tmux new -s x  # 통합 모드 없이 생 tmux 로"
  echo
  echo "통합 모드에서는 iTerm 단축키가 그대로 tmux를 조작한다:"
  echo "  ⌘T                          # 새 창(tmux window)"
  echo "  ⌘D / ⌘⇧D                    # 좌우 / 상하 분할(pane)"
  echo "  ⌘W                          # 창 닫기 (= 그 window 종료)"
  echo "  창 자체를 닫기               # detach — 세션과 프로세스는 살아있음"
  echo "  마우스 스크롤·드래그 복사    # iTerm 네이티브 그대로"
  echo
  echo "세션 저장/복원:"
  echo "  (자동)                      # 5분마다 tmux 레이아웃 자동 저장"
  echo "  Ctrl-b Ctrl-r               # 저장된 tmux 레이아웃 복원"
  echo "  claude-snapshot             # 지금 돌아가는 claude 세션 목록 기록"
  echo "  claude-restore --dry-run    # 무엇이 복원될지 미리보기"
  echo "  claude-restore              # 재부팅 후 claude 세션 일괄 복구"
  echo
  echo "정리:"
  echo "  tmux kill-session -t 세션명 # 세션 종료"
}
