export TERM=xterm-256color

## Golang
export GOROOT="/usr/local/go"
export GOPATH="$HOME/Documents/Code/goworkspace"

## Java
export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0_222`

export TEX_PATH="/Library/TeX/texbin"
export STACK_GHC_BIN_PATH="$HOME/.stack/snapshots/x86_64-osx/lts-8.13/8.0.2/bin:$HOME/.stack/programs/x86_64-osx/ghc-8.0.2/bin"
export STACK_GLOBAL_PATH="$HOME/.local/bin"

## Python
export WORKON_HOME="$HOME/.virtualenvs"

## Rust
export RUST_PATH="$HOME/.cargo/bin"
export RUST_SRC_PATH="$HOME/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src"

# Path
export BREW_PATH="/usr/local/bin"
export PATH="$BREW_PATH:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:$TEX_PATH"
export PATH="$YARN_GLOBAL_PATH:$TEX_PATH:$STACK_GHC_BIN_PATH:$STACK_GLOBAL_PATH:$GOPATH:$RUST_PATH:$PATH"

# Zsh

## omz

if [ -e ~/dotfiles/oh-my-zsh ]
then
    export ZSH=~/dotfiles/oh-my-zsh
    ZSH_THEME="philips"
    COMPLETION_WAITING_DOTS="true"

    plugins=(
        git
        npm
        node
        history-substring-search
        jump
    )

    source "$ZSH/oh-my-zsh.sh"
fi

## zsh-zaw - history search

if [ -e ~/dotfiles/zaw/zaw.zsh ]
then
    source ~/dotfiles/zaw/zaw.zsh

    bindkey '^R' "zaw-history"
    zstyle ':filter-select' max-lines 10
    zstyle ':filter-select' case-insensitive yes
    zstyle ':filter-select' extended-search yes
    zstyle ':filter-select' hist-find-no-dups yes

    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
fi

# Aliases

if [ -e ~/dotfiles/oh-my-zsh ]
then
    # zsh plugin
    alias j="jump"
    alias ms="marks"
fi

if [ -x $(which gls) ]
then
    ## brew install gls
    alias ls="gls --color -hX --group-directories-first"
    alias la="gls --color -o -AhX --group-directories-first"
fi

if [ -x $(which bat) ]
then
    ## brew install bat
    alias cat="bat"
fi

if [ -x $(which rg) ]
then
    ## brew install rg
    alias grep="rg"
fi

if [ -x $(which trash) ]
then
    ## brew install trash
    alias rm="trash"
fi

## grep pipe
alias -g Gi='| grep -i --color=always'

if [ -x $(which tldr) ]
then
    ## brew install tldr
    alias h="tldr"
fi

## git
alias "gh"="git log --oneline --graph --decorate --all"

## killallmatching - kills all running processes that contain a string that's passed in as a first parameter.
## For example, run `killallmatching node` to kill all of the processes that contain `node` in their name.
function killallmatching () {
    ps aux | grep -i "$1" | awk '{print $2}' | xargs kill -9
}