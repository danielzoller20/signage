#!/bin/bash

## Energy settings to prevent disablig of screen

# Disable screen blanking
gsettings set org.gnome.desktop.session idle-delay 0

# Disable automatic screen lock
gsettings set org.gnome.desktop.screensaver lock-enabled false

# Disable power saving options for display on battery and AC
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false


## Configure remote-access
gsettings set org.gnome.desktop.remote-desktop.rdp enable true
# password from keyring needs to be removed!
# otherwise rdp-password wont persist
# rdp-password needs to be specified in settings 


## Firefox-Autostart

mkdir -p ~/.config/autostart

# Define the output file path
output_file="$HOME/.config/autostart/firefox_startup.desktop"

# Write the content to the file
cat << EOF > $output_file
[Desktop Entry]
Type=Application
Exec=/signage/firefox_script.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Start Browser
Comment=Run Firefox as specified in /signage/firefox_startup.sh
EOF

echo "Autostart entry created for Firefox script."


## Autologin

# Define the output file path
output_file="/etc/gdm3/custom.conf"

# Get the first non-system user
username=$(awk -F: '($3 >= 1000) && ($1 != "nobody") {print $1; exit}' /etc/passwd)

# Check if a username was found
if [ -n "$username" ]; then
    # Write the content to the file
    sudo bash -c "cat << EOF >> $output_file
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$username
EOF"
    echo "Automatic login set for user: $username"
else
    echo "No valid user found."
fi