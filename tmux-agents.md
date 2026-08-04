# tmux + Claude Code 에이전트 운영 환경

Claude Code 에이전트를 여러 개 동시에 돌리기 위한 터미널 환경이다.
두 가지 문제를 푼다.

1. **생 tmux의 조작감** — iTerm2 통합 모드(`tmux -CC`)를 자동으로 붙여서 해결한다.
   tmux window가 iTerm 탭, pane이 iTerm split으로 렌더링되므로 `Cmd+T`, 마우스 스크롤,
   드래그 복사가 전부 iTerm 네이티브 그대로 동작한다. `Ctrl-b` prefix를 거의 안 쓴다.
2. **재부팅하면 다 날아가는 것** — tmux는 슬립·뚜껑 닫기·SSH 끊김은 견디지만 재부팅은
   못 견딘다. 그래서 "무엇이 어디서 돌고 있었는지"를 주기적으로 기록해두고
   재부팅 후 한 번에 되살린다.

## 설치

```sh
git clone https://github.com/amazon7737/vim-configuration.git
cd vim-configuration
./install-tmux-agents.sh --dry-run   # 무엇이 바뀔지 먼저 확인
./install-tmux-agents.sh
```

새 터미널을 열고 `agents` 로 진입한다.

## 구성 요소

| 파일 | 설치 위치 | 역할 |
|---|---|---|
| `zsh/tmux-agents.zsh` | `~/.zshrc` 또는 `~/.config/zsh/` | `tmux` 래퍼 / `agents` / `tmuxh` |
| `tmux/tmux.conf` | `~/.tmux.conf` | tmux 설정 + tpm 플러그인 선언 |
| `bin/claude-snapshot` | `~/.local/bin/` | 돌아가는 세션 목록 기록 |
| `bin/claude-restore` | `~/.local/bin/` | 기록대로 tmux 창 복원 |
| `launchd/com.local.claude-snapshot.plist` | `~/Library/LaunchAgents/` | 5분마다 스냅샷 |

## tmux 래퍼 — `-CC` 자동 적용

`tmux` 를 zsh 함수로 감싸서, 세션을 새로 만들거나 붙는 명령에만 `-CC` 를 붙인다.

```sh
tmux new -s work     # 실제로는 tmux -CC new -s work
tmux a -t work       # 실제로는 tmux -CC a -t work
tmux                 # 실제로는 tmux -CC
```

아래 경우에는 손대지 않고 원래대로 동작한다.

- 이미 tmux 안일 때 (`$TMUX`)
- iTerm2가 아닌 터미널이거나 SSH로 붙어 있을 때 — `-CC` 를 못 알아듣는다
- 출력이 터미널이 아닐 때 — `x=$(tmux display-message -p '#S')` 같은 조회가 깨지지 않는다
- `ls` / `kill-session` / `send-keys` 같은 비대화형 서브커맨드
- 이미 `-C` 나 `-CC` 를 직접 준 경우

일부러 생 tmux로 띄우려면:

```sh
TMUX_NO_CC=1 tmux new -s plain
```

## 세션 스냅샷 / 복원

```sh
claude-snapshot            # 지금 돌아가는 claude 세션 기록 (LaunchAgent가 5분마다 자동 실행)
claude-restore --dry-run   # 무엇이 복원될지 미리보기
claude-restore             # tmux 창을 만들고 claude --resume 일괄 실행
```

스냅샷은 `~/.claude/session-snapshot.tsv` 에 `작업디렉터리 / 세션ID / 출처` 형식으로 쌓인다.
직전 스냅샷은 `.tsv.prev` 로 한 세대 보관된다.

세션 ID를 얻는 방법은 두 가지다.

- **`cmd`** — 프로세스 커맨드라인의 `--resume <id>` 에서 확실하게 얻음
- **`guess`** — 커맨드라인에 없어서, `~/.claude/projects/<디렉터리 slug>/` 안에서
  mtime이 가장 최신인 대화 파일로 추정. 이미 확정된 ID는 후보에서 빼므로 중복 배정은 없지만,
  한 디렉터리에서 여러 세션을 동시에 돌리면 어긋날 수 있다. `claude-restore` 출력에서 `*` 로 표시된다.

안전장치:

- 실행 중인 claude가 하나도 없으면 **기존 스냅샷을 덮어쓰지 않는다.**
  재부팅 직후 스냅샷이 돌면서 복구 목록이 통째로 지워지는 게 가장 큰 사고다.
- 이미 같은 (디렉터리, 세션 ID)로 돌고 있으면 복원에서 건너뛴다.
- 새 tmux 세션을 만들 때 딸려오는 기본 창을 첫 항목에 재사용하므로 빈 창이 남지 않는다.

## tmux 플러그인

`tmux-resurrect` + `tmux-continuum` 이 5분마다 tmux 레이아웃을 자동 저장한다.

- `Ctrl-b Ctrl-s` — 수동 저장
- `Ctrl-b Ctrl-r` — 복원

**자동 복원은 일부러 꺼놨다** (`@continuum-restore 'off'`).
tmux 서버가 뜨자마자 에이전트가 한꺼번에 기동되면 통제가 안 되기 때문이다.

## 한계

- 재부팅 시 **실행 중이던 작업 진행 상태(미완료 툴 호출 등)는 복원되지 않는다.**
  복원되는 것은 창 배치와 대화 히스토리다.
- `guess` 로 추정한 항목은 엉뚱한 대화가 열릴 수 있다. 그 창에서 `/resume` 으로 다시 고르면 된다.
- tmux 소켓이 `/tmp` 에 있어 재부팅 시 정리되지만, 재부팅이면 서버도 어차피 죽으므로 영향은 없다.
