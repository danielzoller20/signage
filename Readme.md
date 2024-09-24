# Autoinstall for Signage-Ubuntu
- Ubuntu 24.04 Image is altered
- autoinstall.yaml from this repo is used
- grub.cfg is changed

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