# tmuxh

`tmuxh`는 자주 쓰는 tmux 명령어와 현재 tmux 세션 목록을 빠르게 보여주는 shell helper입니다.

전체 환경(자동 `-CC`, 세션 복원)은 [`tmux-agents.md`](tmux-agents.md)를 참고하세요.

## 설치

[`zsh/tmux-agents.zsh`](zsh/tmux-agents.zsh)에 `tmuxh`가 `tmux` 래퍼, `agents`와 함께 들어 있습니다.
파일 전체를 `~/.zshrc`에 붙여넣거나 `source`로 불러옵니다.

```bash
source ~/.config/zsh/tmux-agents.zsh
```

`tmuxh`만 따로 쓰려면 아래 함수만 `~/.zshrc`에 추가해도 됩니다.

```bash
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
```

변경사항을 바로 적용합니다.

```bash
source ~/.zshrc
```

## 사용법

```bash
tmuxh
```

실행하면 현재 tmux 세션과 자주 쓰는 명령어가 출력됩니다.
