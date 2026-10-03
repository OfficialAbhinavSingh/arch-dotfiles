# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# starship is the prompt when installed; p10k's instant prompt would paint a
# cached powerlevel10k prompt first and flash on every shell start.
if ! command -v starship >/dev/null 2>&1; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Empty theme when starship is installed: two prompt engines both setting PROMPT
# fight, and the loser usually wins on the second redraw.
if command -v starship >/dev/null 2>&1; then
  ZSH_THEME=""
else
  ZSH_THEME="powerlevel10k/powerlevel10k"
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ── Prompt ───────────────────────────────────────────────────────────────────
# starship (config: ~/.config/starship.toml). Falls back to powerlevel10k if
# starship is not installed, so this file is safe on a machine without it.
# Customize starship: edit ~/.config/starship.toml  ·  p10k: `p10k configure`
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi
export BROWSER=zen
export PATH="$HOME/.local/bin:/opt/claude-code/bin:$PATH"
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias n='nvim'
alias ff='fastfetch'
clear-and-ff() { # clear && ff on alt + L
    clear
    ff
    zle redisplay
}
zle -N clear-and-ff
bindkey '\el' clear-and-ff
 

. "$HOME/.local/share/../bin/env"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
alias gl="git log --graph --all --decorate --oneline --format=format:'%C(bold 141)%h%C(reset) - %C(cyan)(%ar)%C(reset) %C(white)%s%C(reset) %C(blue)- %an%C(reset)%C(bold 203)%d%C(reset)'"
# >>> Codex installer >>>
export PATH="/home/laterabhi/.local/bin:$PATH"
# <<< Codex installer <<<

source /home/laterabhi/.daytona.completion_script.zsh

# kimi-code
export PATH="/home/laterabhi/.kimi-code/bin:$PATH"
alias cgc="~/.venvs/cgc/bin/cgc"

source ~/.config/secret

# bun completions
[ -s "/home/laterabhi/.bun/_bun" ] && source "/home/laterabhi/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
 

# Autosuggestion ghost text: default fg=8 is near-invisible on a dark bg.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'

# Entire CLI: no OS keyring in this session, store tokens in ~/.config/entire/tokens.json (0600)
export ENTIRE_TOKEN_STORE=file

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/laterabhi/google-cloud-sdk/path.zsh.inc' ]; then . '/home/laterabhi/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/laterabhi/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/laterabhi/google-cloud-sdk/completion.zsh.inc'; fi

# ── impasto greeting ──────────────────────────────────────────────────────
# fastfetch with the greeting scene chosen in quickshell's settings.
# fastfetch's config points at the chosen scene; "random" is resolved here.
# `fa koi` forces a scene. From github.com/andreumassanet/impasto .zshrc.
function fa() {
    local dir="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell" choice=""
    if [[ -n "$1" && "$1" != -* ]]; then
        if [[ ! -f "$dir/greeting-$1.gif" ]]; then
            print -u2 "fa: no scene called $1 — lava, critters, koi, invaders"
            return 1
        fi
        fastfetch --logo "$dir/greeting-$1.gif"
        return
    fi
    [[ -r "$dir/greeting" ]] && choice="$(<"$dir/greeting")"
    local scenes=("$dir"/greeting-*.gif(N))
    if [[ "$choice" == random ]] && (( $#scenes )); then
        fastfetch --logo "${scenes[RANDOM % $#scenes + 1]}" "$@"
    else
        fastfetch "$@"
    fi
}
