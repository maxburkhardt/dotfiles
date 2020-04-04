#
# .zshrc
#

# Source user-specific customizations.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Source general files.
for i (~/.zsh/rc/*(.)) { source $i }
