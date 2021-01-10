# Luks-Encrypt-Raspbian-Stretch
Enable [LUKS disk encryption](https://gitlab.com/cryptsetup/cryptsetup/blob/master/README.md) for an existing Raspberry Pi OS installation without the use of a second computer/OS.

## Requirements

What you need:
* A Raspberry Pi model 3 or 4
* An sdcard with [Raspberry Pi OS](https://www.raspberrypi.org/software/) installed
* A USB drive connected to the RPi

**Note:** Existing contents of the USB drive will be lost.  USB drive must be large enough to backup the files in the root partion.

## Setup
### Step 0: Download scripts
Run the following commands to download the necessary scripts to '/boot/install':
```shell
wget https://github.com/styper/Luks-Encrypt-Raspbian-Stretch/archive/master.zip -P /tmp/boot-install
sudo unzip /tmp/boot-install/master.zip -d /tmp/boot-install
sudo mkdir /boot/install
sudo cp -R /tmp/boot-install/Luks-Encrypt-Raspbian-Stretch-master/* /boot/install
sudo rm -rf /tmp/boot-install
```

### Step 1: Update OS
Run script:
```shell
sudo /boot/install/1.update.sh
```
This script updates the OS to the latest version.  (This avoids a kernel panic with older stretch releases.)

```shell
sudo reboot
```
**Note:** Rebooting is necessary to load the new kernel version.

### Step 2: Prepare initramfs environment
Run script:
```shell
sudo /boot/install/2.disk_encrypt.sh
```
This script prepares the initramfs environment with the necessary tools for encrypting the root partition.

Note that the following messages are benign:
```
cryptsetup: ERROR: Couldn't resolve device /dev/root
cryptsetup: WARNING: Couldn't determine root device
```

When the script finishes, reboot to enter `(initramfs)` shell environment:
```shell
sudo reboot
```

### Step 3: Encrypt root partition
Wait several seconds for the system to give up locating the 'root' partition and drop to an `(initramfs)` shell prompt:
```
Begin: Running /scripts/local-block ... done.
Begin: Running /scripts/local-block ... done.
Begin: Running /scripts/local-block ... done.
...
ALERT! /dev/mapper/sdcard does not exist.  Dropping to a shell!
...
(initramfs)
```
Run script:
```sh
mkdir /tmp/boot
mount /dev/mmcblk0p1 /tmp/boot/
/tmp/boot/install/3.disk_encrypt_initramfs.sh
```

This script encrypts the root partition using the following steps:
* Clones 'root' partition to the USB drive (**Note**: Existing contents of USB drive are lost)
* Formats 'root' partition as LUKS encrypted partition
    * When prompted `Are you sure? (Type uppercase yes):` type `YES` and hit enter.
    * You will then be prompted to create/verify your new LUKS passphrase.
* Clones USB drive to new encrypted 'root' partition
    * You will be prompted a third time for your LUKS passphrase.

When script completes, **remove the USB drive** and use the following command to reboot to the `(initramfs)` environment:
```
reboot -f
```

### Step 4: First encrypted boot
On your first boot after encrypting the 'root' partition, you will again drop into the `(initramfs)` environment:

Run script:
```sh
mkdir /tmp/boot
mount /dev/mmcblk0p1 /tmp/boot/
/tmp/boot/install/4.luks_open.sh
```
The script will prompt you for your LUKS decryption passphrase to open the encrypted 'root' volume'.

Exit the initramfs environment to boot Raspberry Pi OS now:
```
exit
```

### Step 5: Automatically prompt for passphrase on boot
Run script:
```
sudo /boot/install/5.rebuild_initram.sh
```
This script rebuilds the 'initramfs' environment so that your pi will now automatically ask for your LUKS passphrase on boot.

### Notes:
* There is probably an easier way to do this using chroot so you don't need to reboot so much but I don't know how to do it yet.
* I added 'expect' to the initramfs hook because I'll probably add another script to auto generate a strong password, it can be removed though.

## References
* [Original forum post](https://www.raspberrypi.org/forums/viewtopic.php?t=219867)
* [Raspberry Pi LUKS Root Encryption](https://robpol86.com/raspberry_pi_luks.html)
* [PrivateKeyVault - Setup LUKS Full Disk Encryption](https://github.com/johnshearing/PrivateKeyVault#setup-luks-full-disk-encryption)
