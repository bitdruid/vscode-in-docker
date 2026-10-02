# Powerlevel10k instant prompt. Keep close to the top; anything that needs console
# input (password prompts, [y/n] confirmations, etc.) must go above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode auto

# zsh-completions is added to fpath instead of being loaded as a plugin (see its README).
fpath+=("$ZSH/custom/plugins/zsh-completions/src")

# zsh-syntax-highlighting must stay last.
plugins=(
  git
  z
  dirhistory
  colorize
  colored-man-pages
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# Run `p10k configure` to (re)create this file.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
