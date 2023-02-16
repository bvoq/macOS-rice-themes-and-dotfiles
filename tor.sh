#!/usr/bin/env bash
#
# ######################################################################
# Start Tor and switch the system-wide proxy settings in macOS
# ----------------------------------------------------------------------
# Usage:
# `./tor.sh` in Terminal, kill with ctrl + c
# ----------------------------------------------------------------------
# Source:
# https://kremalicious.com/simple-tor-setup-on-mac-os-x/
# ######################################################################

# 'Wi-Fi' or 'Ethernet' or 'Display Ethernet'
INTERFACE=Wi-Fi

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Trap ctrl-c and call disable_proxy()
function disable_proxy() {
  sudo networksetup -setsocksfirewallproxystate $INTERFACE off
  echo "$(tput setaf 64)" #green
  echo "SOCKS proxy disabled."
  echo "$(tput sgr0)" # color reset
}
trap disable_proxy INT

# Let's roll
sudo networksetup -setsocksfirewallproxy $INTERFACE 127.0.0.1 9050 off
sudo networksetup -setsocksfirewallproxystate $INTERFACE on

echo "$(tput setaf 64)" # green
echo "SOCKS proxy 127.0.0.1:9050 enabled."
echo "$(tput setaf 136)" # orange
echo "Starting Tor..."
echo "$(tput sgr0)" # color reset

tor
