#!/usr/bin/env bash
set -x
pacman -Syu --noconfirm --needed gnupg curl
cd ~
GPG_TTY="\$(tty)" || true
export GPG_TTY
gpg --version
curl -Lo grimler.gpg https://github.com/termux/termux-packages/raw/master/packages/termux-keyring/grimler.gpg
gpg --import grimler.gpg
gpg --no-tty --command-file <(echo -e "trust\n5\ny") --edit-key 2C7F29AE97891F6419A9E2CDB0076E490B71616B
gpg --list-keys
set +x
