# Scripts to adjust ubuntu for signage 

## after installation
Copy script from https://raw.githubusercontent.com/danielzoller20/signage/main/install_asRoot.sh to device (e.g. /tmp).

```
wget https://raw.githubusercontent.com/danielzoller20/signage/main/install_asRoot.sh -O /tmp/install_asRoot.sh
chmod +x /tmp/install_asRoot.sh
sudo /bin/bash /tmp/install_asRoot.sh
```
In the script "install_asRoot.sh":
- Update-Settings are made,
- Cronjob for updates at 02.00 PM is set up,
- Files are created, where the URL of the screen has to be specified,
- Script for autostart of firefox is generated in /signage,
- Script to run as user gets copied to /signage.


In the script "install_asUser.sh":
- Energy settings are adjustet to prevent disabling of screen,
- RDP is enabled for remote access,
- Firefox is added to autostart,
- Autologin is configured.

Script needs to be run as User!

```
/bin/bash /signage/install_asUser.sh
```

## needs to be done in GUI:
- Password for RDP needs to be specified ![specify Password](/img/password.png)
- Password for keyring needs to be removed (otherwise RDP-PW changes) ![remove Password for Keyring](/img/keyring.png)