#
# .zshrc
#

# Source general files.
for i (~/.zsh/rc/*(.)) { source $i }

# Source user-specific customizations.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
