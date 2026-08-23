#!/bin/zsh

BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

_backup() {
  local dest="$1"
  mkdir -p "${BACKUP_DIR}"
  mv "$dest" "${BACKUP_DIR}/"
}

_confirm_overwrite() {
  local dest="$1"
  if [[ -e "$dest" || -L "$dest" ]]; then
    print "Conflict: $dest already exists."
    read -q "REPLY?Overwrite? [y/N] " && echo
    [[ "$REPLY" == "y" ]] && { _backup "$dest"; return 0; } || return 1
  fi
  return 0
}

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
cp -rf zprezto-runcoms/* "${ZDOTDIR:-$HOME}/.zprezto/runcoms"

# .p10k.zsh
p10k_dest="${ZDOTDIR:-$HOME}/.p10k.zsh"
if _confirm_overwrite "$p10k_dest"; then
  cp .p10k.zsh "$p10k_dest"
fi

# zprezto rc symlinks
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  dest="${ZDOTDIR:-$HOME}/.${rcfile:t}"
  if _confirm_overwrite "$dest"; then
    ln -s "$rcfile" "$dest"
  fi
done

# nvim config
mkdir -p "${HOME}/.config/nvim"
nvim_conflicts=()
for f in nvim/**/*(.N); do
  dest="${HOME}/.config/nvim/${f#nvim/}"
  [[ -e "$dest" || -L "$dest" ]] && nvim_conflicts+=("$dest")
done

if (( ${#nvim_conflicts[@]} > 0 )); then
  print "The following nvim config files already exist:"
  printf '  %s\n' "${nvim_conflicts[@]}"
  read -q "REPLY?Overwrite all? [y/N] " && echo
  if [[ "$REPLY" == "y" ]]; then
    mkdir -p "${BACKUP_DIR}/nvim"
    for f in "${nvim_conflicts[@]}"; do
      mv "$f" "${BACKUP_DIR}/nvim/"
    done
    cp -r nvim/* "${HOME}/.config/nvim"
  fi
else
  cp -r nvim/* "${HOME}/.config/nvim"
fi

# Install zoxide
if ! command -v zoxide &>/dev/null; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Install fzf-tab plugin
mkdir -p "${HOME}/.local/share/zsh/plugins"
if [[ ! -d "${HOME}/.local/share/zsh/plugins/fzf-tab" ]]; then
  git clone https://github.com/Aloxaf/fzf-tab "${HOME}/.local/share/zsh/plugins/fzf-tab"
fi
if [[ ! -f "${HOME}/.local/share/zsh/plugins/fzf-tab/init.zsh" ]]; then
  ln -s fzf-tab.plugin.zsh "${HOME}/.local/share/zsh/plugins/fzf-tab/init.zsh"
fi
