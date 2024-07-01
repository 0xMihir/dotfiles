#!/bin/zsh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
cp -rf zprezto-runcoms/* "${ZDOTDIR:-$HOME}/.zprezto/runcoms"
cp .p10k.zsh "${ZDOTDIR:-$HOME}/"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
