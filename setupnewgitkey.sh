#!/bin/sh

regex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

if [[ $1 =~ $regex ]] ; then
    echo "Generating your ssh key with email ${1} now."
else
    echo "You must enter an email as an argument."
    exit 1
fi

ssh-keygen -t ed25519 -C "$1"
eval "$(ssh-agent -s)"
mkdir -p .ssh && cp .ssh/config ~/.ssh/config

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     ssh-add -K ~/.ssh/id_ed25519;;
    Darwin*)    ssh-add --apple-use-keychain ~/.ssh/id_ed25519;;
    CYGWIN*)    ssh-add -K ~/.ssh/id_ed25519;;
    MINGW*)     ssh-add -K ~/.ssh/id_ed25519;;
    *)          ssh-add -K ~/.ssh/id_ed25519;;
esac

pbcopy < ~/.ssh/id_ed25519.pub

open https://github.com/settings/ssh/new

