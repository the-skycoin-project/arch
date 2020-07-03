# Skywire custom bootstrapping package

Shell scripts to configure skywire node and manager on Arch Linux from fresh install

## What is here?

* six shell scripts
* three systemd service
* a golang http server (hosts the package cache)
* a PKGBUILD (which defines where these scripts are installed in the system)
* the created skyminer package (for running image-creator.sh on non-archlinux systems)

## Operation details

* skybootstrap.sh
root portion of manager configuration.
Set hostname
Fix mirrorlist
pacman-key --init && pacman-key --populate
sync package repository databases
reinstall archlinux-keyring
install base-devel group packages, install git, sudo, and macchanger
create and enable macchanger systemd service
give sudo permissions to the user account and run skyboottrap-alarm as the user

* skybootstrap-alarm.sh
User portion of the configuration
manually create and install yay-git (if it doesn't exist)
use yay-git to install skywire (if not installed)
configure skywire systemd service to run as the user & enable it
sync package repository databases
call skyminer-repo-update.sh
enable the readonly-cache service
full system update
disable skyminer.service so these scripts aren't run again
reboot
(When rerun, this script will update AUR packages including skywire, and preform a full system update)

* skyminer-repo-update.sh
add created packages to the skyminer local repository
symlinks package repository databases into the package cache

* readonly-cache-setup.sh
creates a binary from readonlycache.go and puts it in the GOBIN used by the skycoin packages
symlinks readonlycache this to /usr/bin

* readonly-cache.sh
executes the readonlycache binary

* readonlycache.go
a simple http server written in go to host pacman's package cache directory

* nodebootstrap.sh
root portion of node configuration.
Set hostname
Fix mirrorlist
Configure manager IP address as update mirror
Add the skyminer repo (provided by the manager)
pacman-key --init && pacman-key --populate
sync package repository databases
reinstall archlinux-keyring
install skywire and macchanger
edit skywire node systemd service to run as the user and enable it
configure node start script with manager IP address
create and enable macchanger systemd service
full system update
reboot

* fixinternet.sh
prevent DNS resolution issues by toggling the systemd-resolved.service

* fixinternet.service
runs fixinternet.sh at boot

* macchanger.service
starts macchanger at boot to randomize the mac address

* readonly-cache.service
for starting the package mirroring system on boot

* PKGBUILD
all files are installed to /usr/lib/skycoin/skyminer and symlinked to /usr/bin
