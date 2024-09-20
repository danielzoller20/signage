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
firefox --kiosk "$URL" &
EOF

# Make the output file executable
chmod +x $output_file


# add CronJob for updates at night

# Define the cron job schedule and update command
CRON_SCHEDULE="0 2 * * *"
COMMAND="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y"

# Check if the cron job already exists
CRON_JOB="$CRON_SCHEDULE $COMMAND"
(crontab -l 2>/dev/null | grep -F "$COMMAND") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
