#!/bin/bash
#root portion of the setup customization
set -e
if [[ $EUID -ne 0 ]]; then
   echo "You must be root to do this." 1>&2
   exit 100
fi

### SET HOSTNAME ###
HOST_NAME=$(cat /etc/hostname)
if [ $HOST_NAME == *"alarm"*  ]; then
echo "Skyminer node setup"
echo "Setting hostname, please enter a unique identifier for this node"
read -p "A number between 1 and 8 is recommended: " -r
HOST_NAME=${REPLY}
echo "visor$HOST_NAME" > /etc/hostname
#else
#echo "$HOST_NAME" > /etc/hostname
#fi
fi

if [ ! -z $1 ]; then
AURLOCAL=${1}
fi

if [ -z $AURLOCAL ]; then
  set -e
#prompt to enter sky manager IP address
read -p "Please input IP address of the hypervisor: " -r
AURLOCAL=${REPLY}
fi

# backup the mirrorlist
if [ ! -f /etc/pacman.d/mirrorlist-bak ]; then
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-bak
fi

#set the AURLOCAL IP as a mirror for pacman to retrieve updates from
echo  "$(echo "Server = http://$AURLOCAL:8079" | cat - /etc/pacman.d/mirrorlist-bak)" > /root/mirrorlist
mv /root/mirrorlist /etc/pacman.d/mirrorlist

#backup pacman.conf
if [ ! -f /etc/pacman.conf-bak ]; then
  cp /etc/pacman.conf /etc/pacman.conf-bak
fi

#add the skyminer repo to pacman.conf
cat /etc/pacman.conf-bak > /root/pacman.conf
echo -e "
[aur-local]
SigLevel = PackageOptional
Server = http://$AURLOCAL:8079
" >> /root/pacman.conf
mv /root/pacman.conf /etc/pacman.conf


### BOOTSTRAPPING ###
#boilerplate archlinux setup
pacman-key --init
pacman-key --populate

#sync the repos
pacman -Syy

#update the keyring first to avoid errors from missing keys
pacman -S archlinux-keyring --noconfirm

#install skywire-mainnet from the skyminer repo on the manager
yes | pacman -S skywire --noconfirm

#install macchanger, create and enable a systemd service or MAC address will be 36:c9:e3:f1:b8:05
pacman -S macchanger --noconfirm

systemctl enable macchanger.service

#full system update
yes | pacman -Syu --noconfirm

#reboot for stablity because the kernel was probably updated
reboot now
