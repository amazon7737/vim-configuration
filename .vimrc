" Escape tweaks
set nocompatible              " vim 고유 기능 다 켜짐
set backspace=indent,eol,start " 자동 들여쓰기 지우기 허용, 줄바꿈 기준 허용, insert 시작점 이전까지 지우기

" 기본 편집 옵션
syntax on                    " 문법 강조
set number                   " 줄 번호 표시
set autoindent               " 자동 들여쓰기
set expandtab                " tab -> 스페이스
set tabstop=4                " tab 너비 = 4
set shiftwidth=4             " 들여쓰기 너비 = 4

" 검색 옵션
set ignorecase               " 대소문자 무시 검색
set smartcase                " 대문자 포함하면 case 매칭

" 편의 기능
set clipboard=unnamedplus    " 시스템 클립보드 공유
set mouse=a                  " 마우스 클릭 활성
set cursorline               " 현재 줄 강조
set wildmenu                 " 자동완성 메뉴 보기
set wildmode=longest:full,full

" 색상
set termguicolors            " true color 활성화
colorscheme desert           " 기본 desert 컬러 스킴

" 편리한 단축키
nnoremap <leader>w :w<CR>    " ,w 저장
nnoremap <leader>q :q<CR>    " ,q 종료

" 플러그인 매니저 (vim-plug)
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'    " Git wrapper
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " 편의기능 Files..
Plug 'junegunn/fzf.vim' 
call plug#end()

