#https://github.com/johnshearing/MyEtherWalletOffline/blob/master/Air-Gap_Setup.md#setup-luks-full-disk-encryption
#https://robpol86.com/raspberry_pi_luks.html
#https://www.howtoforge.com/automatically-unlock-luks-encrypted-drives-with-a-keyfile

#sudo cp -R ~/install/ /boot/

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

apt-get update
apt-get upgrade -y
#sudo rpi-update
echo "Done. Reboot with: sudo reboot"
#reboot #needed to load new kernel