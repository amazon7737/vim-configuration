# tmuxh

`tmuxh`는 자주 쓰는 tmux 명령어와 현재 tmux 세션 목록을 빠르게 보여주는 shell helper입니다.

## 설치

`~/.zshrc`에 아래 함수를 추가합니다.

```bash
tmuxh() {
  echo "tmux quick guide"
  echo
  echo "현재 세션:"
  tmux ls 2>/dev/null || echo "  없음"
  echo
  echo "자주 쓰는 명령어:"
  echo "  tmux ls                     # 세션 목록 보기"
  echo "  tmux new -s work            # 새 세션 만들기"
  echo "  tmux attach -t 세션명       # 기존 세션 들어가기"
  echo "  tmux a -t 세션명            # attach 줄임말"
  echo "  Ctrl-b d                    # 세션에서 빠져나오기"
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

## 예시

```text
tmux quick guide

현재 세션:
pi-agents: 1 windows

자주 쓰는 명령어:
  tmux ls                     # 세션 목록 보기
  tmux new -s work            # 새 세션 만들기
  tmux attach -t 세션명       # 기존 세션 들어가기
  tmux a -t 세션명            # attach 줄임말
  Ctrl-b d                    # 세션에서 빠져나오기
  tmux kill-session -t 세션명 # 세션 종료
```
