#!/bin/bash

## Energy settings to prevent disablig of screen

# Disable screen blanking
gsettings set org.gnome.desktop.session idle-delay 0

# Disable automatic screen lock
gsettings set org.gnome.desktop.screensaver lock-enabled false

# Disable power saving options for display on battery and AC
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false