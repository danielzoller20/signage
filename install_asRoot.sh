#!/bin/bash

## changes to run unattended-upgrades

# Backup the original file before making changes
cp /etc/apt/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades.bak

# Uncomment the line: "${distro_id} ${distro_codename}-updates";
sed -i 's|//\(\s*"\${distro_id} \${distro_codename}-updates";\)|\1|' /etc/apt/apt.conf.d/50unattended-upgrades

# Change Unattended-Upgrade::Automatic-Reboot "false"; to "true"
sed -i 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|' /etc/apt/apt.conf.d/50unattended-upgrades

# Change Unattended-Upgrade::Automatic-Reboot-WithUsers and add Automatic-Reboot "true"
sed -i 's|//Unattended-Upgrade::Automatic-Reboot-WithUsers "true";|Unattended-Upgrade::Automatic-Reboot-WithUsers "true";\nUnattended-Upgrade::Automatic-Reboot "true";|' /etc/apt/apt.conf.d/50unattended-upgrades

## Change release-upgrade to never

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

## Updates

# add CronJob for updates at night

# Define the cron job schedule and update command
CRON_SCHEDULE="0 2 * * *"
COMMAND="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"

# Check if the cron job already exists
CRON_JOB="$CRON_SCHEDULE $COMMAND"
(crontab -l 2>/dev/null | grep -F "$COMMAND") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -


## Firefox-Autostart

# Create folder /signage
mkdir /signage

# Define the output file path
output_file="/signage/firefox_script.sh"

# Write the content to the file
cat << 'EOF' > $output_file
#!/bin/bash

# Define the startup URL
URL="www.enterstartupURLhere.com"

# Start Firefox and open the URL
latpak run org.mozilla.firefox --kiosk "$URL" &
EOF

# Make the output file executable
chmod +x $output_file


## Chromium-Autostart

# Define the output file path
output_file="/signage/chromium_script.sh"

# Write the content to the file
cat << 'EOF' > $output_file
#!/bin/bash

# Define the startup URL
URL="www.enterstartupURLhere.com"

# Start Chromium and open the URL
flatpak run org.chromium.Chromium --app --start-fullscreen "$URL"
EOF

# Make the output file executable
chmod +x $output_file

## Chrome-Autostart

# Define the output file path
output_file="/signage/chrome_script.sh"

# Write the content to the file
cat << 'EOF' > $output_file
#!/bin/bash

# Define the startup URL
URL="www.enterstartupURLhere.com"

# Start Chrome and open the URL
flatpak run com.google.Chrome --app --start-fullscreen "$URL"
EOF

# Make the output file executable
chmod +x $output_file