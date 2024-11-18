# Autoinstall for Signage-Ubuntu
- Ubuntu 24.04 Image is altered
- autoinstall.yaml from this repo is used
- grub.cfg is changed
- scripts are copied to device / executed

## copy iso to folder
```
mkdir /tmp/mountfolder
mount ./ubuntu.iso /tmp/mountfolder
mkdir /tmp/ubuntufolder
rsync -a /tmp/mountfolder/ /tmp/ubuntufolder
```

copy autoinstall.yaml to /tmp/ubuntufoolder
```
wget -O /tmp/ubuntufolder/autoinstall.yaml https://raw.githubusercontent.com/danielzoller20/signage/main/autoinstall.yaml
```

## add menuentry to grub
grub.cfg seems to have permissions 444.
need to change at least to 644 to change.

```
chmod 644 /tmp/ubuntufolder/boot/grub/grub.cfg
nano /tmp/ubuntufolder/boot/grub/grub.cfg
```
add these lines
```
menuentry "Autoinstall Ubuntu Signage" {
        set gfxpayload=keep
        linux /casper/vmlinuz --- autoinstall ds=nocloud-net;s=file:///cdrom/autoinstall.yaml
        initrd /casper/initrd
}
```

## create new .iso
xorriso needs to be installed.

```
xorriso -as mkisofs \
  -r -V "ubuntu-autoinstall" \
  -J -joliet-long \
  -b boot/grub/i386-pc/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/bootx64.efi \
  -no-emul-boot -isohybrid-gpt-basdat \
  -o ubuntu-autoinstall.iso /tmp/ubuntufolder
  ```


## post installation
Script from https://raw.githubusercontent.com/danielzoller20/signage/main/install_asRoot.sh gets copied to device (/tmp).
In this script:
- Update-Settings are made,
- Cronjob for updates at 02.00 PM is set up
- Script for autostart of firefox is generated in /signage.
Script runs automatically during autoinstall.

Script from https://raw.githubusercontent.com/danielzoller20/signage/main/install_asUser.sh gets copied to device (/tmp).
In this script:
- Energy settings are adjustet to prevent disabling of screen,
- RDP is enabled for remote access,
- Firefox is added to autostart,
- Autologin is configured.
Script needs to be run as User!

### needs to be done in GUI:
- Password for RDP needs to be specified ![specify Password](/img/password.png)
- Password for keyring needs to be removed (otherwise RDP-PW changes) ![remove Password for Keyring](/img/keyring.png)