autoload -U colors && colors
autoload -U compinit && compinit

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
REPORTTIME=5                    # Display usage statistics for commands running > 5 sec.

export VISUAL=vim
export EDITOR=vim

setopt append_history           # Don't overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt no_hist_ignore_space     # Don't add cmd to hist when first char is blank
setopt hist_reduce_blanks       # Remove superfluous blanks.

setopt interactive_comments     # allow comments even in interactive shells
setopt no_flow_control          # ignore ^S/^Q

# Aliases
alias gitst='git status'
alias hist-full='history -E 1'
alias tcpdump-full='sudo tcpdump -nnvvXSs 1514'
alias tmux='tmux -2'
alias nmap='sudo nmap --stats-every 10s'
alias pg='ping google.com'
export LSCOLORS="GxFxFxdxCxDxDxhbadExEx"
export CLICOLORS="YES"
alias ls='ls -G'

# Prompt
local return_code="%(?..%{$fg[red]%}%? <%{$reset_color%})"

local user_host="%{$fg[magenta]%}%n@%m%{$reset_color%}"
local current_dir="%{$fg[yellow]%} %~%{$reset_color%}"
local current_time="%{$terminfo[bold]$fg[white]%} %T%{$reset_color%}"

export PROMPT="${user_host} ${current_dir} ${current_time}
%%%b "
export RPS1="${return_code}"

# For testing terminal colors
_cols()
{
  local esc="\033["
  print "\t 40\t 41\t 42\t 43\t 44\t 45\t 46\t 47"
  for fore in 30 31 32 33 34 35 36 37; do
    local line1="$fore  "
    local line2="    "
    for back in 40 41 42 43 44 45 46 47; do
      local line1="${line1}${esc}${back};${fore}m Normal  ${esc}0m"
      local line2="${line2}${esc}${back};${fore};1m Bold    ${esc}0m"
    done
    print "$line1\n$line2"
  done
}

LOCAL_ZSHRC="$HOME/.zshrc.local"
if [ -f $LOCAL_ZSHRC ]; then
    source $LOCAL_ZSHRC
fi
