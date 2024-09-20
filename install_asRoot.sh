#!/bin/bash

# install xdotool for input
apt -y install xdotool

# install openssh-server for maintenance
apt -y install openssh-server



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

# Define the URL
#URL="http://10.42.5.50/"
URL="https://www.schule-rorschacherberg.ch"

# Start Firefox and open the URL
firefox --kiosk "$URL" &

# Wait for Firefox to launch
sleep 5

# Use xdotool to press F11 to make Firefox fullscreen
xdotool search --sync --onlyvisible --class "firefox" windowactivate key F11

# Wait for the page to load
sleep 2

# Automatically type the password if a password field is focused
xdotool type "TopSecretScreen!"
xdotool key Return
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
