#!/bin/bash

###########################################################################
# script to adjust ubuntu 24.04 for signage
###########################################################################


###########################################################################
# updates
###########################################################################

## changes to run unattended-upgrades

# Backup the original file before making changes
cp /etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades.bak

# Uncomment the line: "${distro_id} ${distro_codename}-updates";
sed -i 's|//\(\s*"\${distro_id} \${distro_codename}-updates";\)|\1|' /etc/apt/apt.conf.d/50unattended-upgrades

# Change Unattended-Upgrade::Automatic-Reboot "false"; to "true"
sed -i 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|' /etc/apt/apt.conf.d/50unattended-upgrades

# Change Unattended-Upgrade::Automatic-Reboot-WithUsers and add Automatic-Reboot "true"
sed -i 's|//Unattended-Upgrade::Automatic-Reboot-WithUsers "true";|Unattended-Upgrade::Automatic-Reboot-WithUsers "true";\nUnattended-Upgrade::Automatic-Reboot "true";|' /etc/apt/apt.conf.d/50unattended-upgrades


## change release-upgrade to never

# Path to the release-upgrades file
CONFIG_FILE="/etc/update-manager/release-upgrades"

# Check if the file exists
if [ -f "$CONFIG_FILE" ]; then
  # Use sed to find and replace the line starting with Prompt= and change it to Prompt=never
  sudo sed -i 's/^Prompt=.*/Prompt=never/' "$CONFIG_FILE"
  
  # If the Prompt line does not exist, add it to the file
  if ! grep -q "^Prompt=never" "$CONFIG_FILE"; then
    echo "Prompt=never" | sudo tee -a "$CONFIG_FILE"
  fi

  echo "Updated $CONFIG_FILE to set Prompt=never."
else
  echo "Configuration file not found at $CONFIG_FILE."
fi


## hide software updater

# Path to the update-notifier.desktop file
FILE="/etc/xdg/autostart/update-notifier.desktop"

# Check if the file exists
if [ -f "$FILE" ]; then
    # Comment out the Exec line
    sudo sed -i 's|^Exec=update-notifier|#Exec=update-notifier|' "$FILE"
    
    # Check if Hidden line already exists, if not, add it
    if ! grep -q "^Hidden=true" "$FILE"; then
        echo "Hidden=true" | sudo tee -a "$FILE" > /dev/null
    fi

    echo "Update notifier configuration updated successfully."
else
    echo "File $FILE does not exist."
fi


## add CronJob for updates at night

# Define the cron job schedule and update /shutdown command for 20.45 mon-fri
CRON_SCHEDULE="45 20 * * 1-5"
COMMAND="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo shutdown now"

# Check if the cron job already exists
CRON_JOB="$CRON_SCHEDULE $COMMAND"
(crontab -l 2>/dev/null | grep -F "$COMMAND") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

## Updates

apt update
apt -y upgrade


###########################################################################
# installation of packages
###########################################################################

# install openssh and flatpak
apt -y install openssh-server
apt -y install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# install browsers from flathub
flatpak -y install flathub org.mozilla.firefox
flatpak -y install flathub com.google.Chrome
flatpak -y install flathub org.chromium.Chromium

# install gnome shell extension mangager - for extension hide-cursor@elcste.com
apt -y install gnome-shell-extension-manager

###########################################################################
# startup-scripts for browsers
###########################################################################

## Firefox
# Create folder /signage
mkdir /signage

# Define the output file path
output_file="/signage/firefox_script.sh"

# Write the content to the file
cat << 'EOF' > $output_file
#!/bin/bash

# wait for WiFi connection
sleep 20

# Define the startup URL
URL="www.enterstartupURLhere.com"

# Start Firefox and open the URL
flatpak run org.mozilla.firefox --kiosk "$URL" &
EOF

# Make the output file executable
chmod +x $output_file


## Chromium
# Define the output file path
output_file="/signage/chromium_script.sh"

# Write the content to the file
cat << 'EOF' > $output_file
#!/bin/bash

# wait for WiFi connection
sleep 20

# Define the startup URL
URL="www.enterstartupURLhere.com"

# Start Chromium and open the URL
flatpak run org.chromium.Chromium --app --start-fullscreen --hide-crash-restore-bubble '--disable-features=Translate' "$URL"
EOF

# Make the output file executable
chmod +x $output_file

## Chrome
# Define the output file path
output_file="/signage/chrome_script.sh"

# Write the content to the file
cat << 'EOF' > $output_file
#!/bin/bash

# wait for WiFi connection
sleep 20

# Define the startup URL
URL="www.enterstartupURLhere.com"

# Start Chrome and open the URL
flatpak run com.google.Chrome --no-first-run --app --start-fullscreen --disable-infobars --hide-crash-restore-bubble "$URL"
EOF

# Make the output file executable
chmod +x $output_file


###########################################################################
# set dhcp-identifier to mac for dhcp lease reservation
###########################################################################

## new file to disable cloud-init network configuration

# Define the output file path
output_file="/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"

# Write the content to the file
cat << 'EOF' > $output_file
network: {config: disabled}
EOF

# Make output file readable
chmod 644 $output_file


## add dhcp-identifier: mac to netplan

# Define the directory where the YAML file is located
input_dir="/etc/netplan"

# Find the YAML file in the specified directory
input_file=$(find "$input_dir" -name "*.yaml" | head -n 1)

# Check if a YAML file was found
if [[ -z "$input_file" ]]; then
    echo "No YAML file found in $input_dir."
fi

# Create a temporary file to store the modified content
temp_file=$(mktemp)

# Read the input file line by line
while IFS= read -r line; do
    # Print the current line to the temp file
    echo "$line" >> "$temp_file"
    
    # Check if the line contains "dhcp4: true"
    if [[ "$line" == *"dhcp4: true"* ]]; then
        # Get the leading spaces using awk
        leading_spaces=$(echo "$line" | awk '{print substr($0, 1, match($0, /[^ ]/) - 1)}')
        
        # Add the new line with the same leading spaces
        echo "${leading_spaces}dhcp-identifier: mac" >> "$temp_file"
    fi
done < "$input_file"

# Move the temp file to the original file
mv "$temp_file" "$input_file"

echo "Updated $input_file successfully."

# apply changes
netplan apply
sleep 5

###########################################################################
# get script for energy settings and autostart
###########################################################################

# script must be executed as user
wget https://raw.githubusercontent.com/danielzoller20/signage/main/install_asUser.sh -O /signage/install_asUser.sh
chmod +x /signage/install_asUser.sh