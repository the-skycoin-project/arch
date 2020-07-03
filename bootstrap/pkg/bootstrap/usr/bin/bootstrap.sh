#!/bin/bash
#root portion of the setup customization
set -e

if [[ $EUID -ne 0 ]]; then
   echo "You must be root to do this." 1>&2
   exit 100
fi

#set hostname to hypervisor
#echo "hypervisor" > /etc/hostname

#toggle systemd-resolved.service to fix DNS
systemctl enable fixinternet.service
systemctl start fixinternet.service

#boilerplate archlinux setup
pacman-key --init
pacman-key --populate
#sync the repos
pacman -Syy

#update the keyring first to avoid errors from missing keys
pacman -S archlinux-keyring --noconfirm

#install a few things needed for makepkg
yes | pacman -S base-devel git sudo --needed --noconfirm

#install macchanger, create and enable a systemd service or MAC address will be 36:c9:e3:f1:b8:05
pacman -S macchanger --noconfirm --needed
systemctl enable macchanger.service

#set easy sudo for user portion of configuration
ISO_USER="$(cat /etc/passwd | grep "/home" |cut -d: -f1 |head -1)"
wfile=/etc/sudoers
wfile1=/etc/sudoers-bak
wfile2=/root/sudoers
if [ ! -f $wfile1 ]; then
  cp $wfile $wfile1
  cp -a $wfile1 $wfile2
  echo "$ISO_USER ALL=(ALL:ALL) NOPASSWD:ALL" >> $wfile2
  mv $wfile2 $wfile
else
  cp -a $wfile1 $wfile2
  echo "$ISO_USER ALL=(ALL:ALL) NOPASSWD:ALL" >> $wfile2
  mv $wfile2 $wfile
fi

echo "sudo permissions granted to $ISO_USER"
#run the user portion of the configuration - makepkg cannot be run as root
su -c "skybootstrap-alarm" $ISO_USER
