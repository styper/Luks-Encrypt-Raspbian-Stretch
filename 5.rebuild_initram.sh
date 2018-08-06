#!/bin/sh

sudo mkinitramfs -o /boot/initramfs.gz
lsinitramfs /boot/initramfs.gz |grep -P "sbin/(cryptsetup|resize2fs|fdisk|dumpe2fs|expect)"
#sudo reboot