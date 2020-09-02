#!/bin/bash
#user portion of the setup customization
#rerun to update AUR packages
set -e
if [[ $EUID -eq 0 ]]; then
  echo "Please do not run this script as root." 1>&2
  exit 100
fi

#sync databases before upgrade
sudo pacman -Syy

#full system update
yes | sudo pacman -Syu --noconfirm

package=yay-git
if pacman -Qi $package > /dev/null ; then
  echo "$package is installed, rebuilding to the latest commits"
  yay -S --noconfirm $package
else
  echo "$package is not installed, manually building"
  #clone the build dir for yay-git to it's future package cache
mkdir -p ~/.cache/yay/ && cd ~/.cache/yay/
git clone https://aur.archlinux.org/$package
cd $package
yes | makepkg -scif --noconfirm
cd ~/
fi
echo "installed $package"

#install package cache sharing utility with yay
package=readonly-cache
if pacman -Qi $package > /dev/null ; then
  echo "$package is installed, rebuilding with the latest commits"
  yay -S --noconfirm $package
else
  echo "installing $package now"
  yay -S --noconfirm $package
fi
echo "installed $package"

#install skywire with yay
#package=skywire
#if pacman -Qi $package > /dev/null ; then
#  echo "$package is installed, rebuilding with the latest commits"
#  yay -S --noconfirm $package
#else
#  echo "installing $package now"
#  yay -S --noconfirm $package
#fi
#echo "installed $package"
#
#echo "installed $package"

#packages in yay's cache are added to the skyminer local repo hosted by the manager
#sudo aur-local

#enable the service to host these packges on the LAN
#sudo systemctl enable readonly-cache.service

#systemctl daemon-reload

#reboot
sudo reboot now
