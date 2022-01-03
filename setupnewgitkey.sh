#!/bin/sh
ssh-keygen -t ed25519 -C "dekeyser.kevin97@gmail.com"
eval "$(ssh-agent -s)"
mkdir -p .ssh && cp .ssh/config ~/.ssh/config

# for monterey and higher use --apple-use-keychain
ssh-add -K ~/.ssh/id_ed25519

pbcopy < ~/.ssh/id_ed25519.pub

open https://github.com/settings/ssh/new

