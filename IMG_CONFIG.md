# Installation

## Download a Release Image

* [Orange Pi Prime](https://github.com/Skyfleet/archlinuxarm/releases/download/skyminer/orangepiprime-archlinux-aarch64.img.tar.gz)
* [Pine64](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/pine64-archlinux-aarch64.img.tar.gz)
* [RPi 2](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/rpi2-archlinux-armv7.img.tar.gz)
* [RPi 3](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/rpi3-archlinux-armv7.img.tar.gz)
* [RPi 4](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/rpi4-archlinux-armv8.img.tar.gz)

DHCP images are provided by the above links. If you require ip-preset images please create them with the image-creator.sh script as detailed [here](/IMG_CREATOR.md).

## Extract the image from the archive

Usually right-click -> extract.

*Tip: you can use the tar command in the linux subsystem for windows*

## Writing the image to a microSD card (linux)

Identify your microSD card using the output of `lsblk` and flash the created image to your microSD Card with `dd` or `dcfldd`:
```
$ sudo dd if=arch-linux-X-XXXXXXXX.img of=/dev/sdX
```

## Expand the rootFS partition to occupy the rest of the microSD card

To expand the root filesystem partition, I use `gnome-disks`.
Many utilities exist on linux for doing this including `parted` `gparted` `cfdisk` just to name a few.

*Tip: you will repeat this step for every node in your skyminer.*

## Writing the image to a microSD card (windows)

Windows users should use the [rufus](https://github.com/pbatard/rufus/releases) utility to write the image to the microSD card.

**Be sure you don't forget to expand the rootFS partition to occupy the rest of the microSD card!**
Forgetting to expand the root partition is the number 1 source of errors. I am unfamiliar with the process for doing this on windows.

## Bootstrapping Procedure Overview

First and foremost:
**Power on only one board at a time to avoid mac address conflicts**

* Insert the microSD card into the board
* Power on the board
* SSH to the board
* Run the bootstrapping script for manager or node
* Wait for the board to reboot
* SSH to the board again
* Install your desired software (skywire)

Newly connected (dhcp) nodes can be reached with `ssh alarm@alarm`

*Note on rpis this may instead be:* `alarm@alarmpi`

Note: if hostname resolution doesn't work with your router *use the IP address of the image instead of the hostname such as: `ssh alarm@192.168.0.2`*

You may need to determine the IP address of the board from your router's interface.

Typically this is something like [http://192.168.0.1](http://192.168.0.1) or [http://192.168.0.1](http://192.168.0.1)

*Tip: if your image has a static IP set, it will not show up in the list of DHCP clients*

You will need to remove the line in ~/.ssh/known_hosts every time before attempting to connect to a new node by it's hostname; i.e.:
```
grep -v "^alarm" $HOME/.ssh/known_hosts > $HOME/.ssh/known_hosts.bak && mv $HOME/.ssh/known_hosts.bak $HOME/.ssh/known_hosts
```

# Bootstrapping Procedure Details

I would encourage users to scrutinize the [bootstrap.sh](/bootstrap/bootstrap.sh) and [bootstrap-alarm.sh](bootstrap/bootstrap-alarm.sh) scripts for the details of the bootstrapping procedure. Basic bootstrapping is detailed on [archlinuxarm.org](https://archlinuxarm.org)

Insert the microSD card into your manager board, and access the board via ssh:
```
ssh alarm@alarm
#password is alarm
```

Become root:
```
su - root
#password is root
```

Run the provided bootstrapping script
```
bootstrap
```

It may take 15-20 minutes for the initial configuration and software updates to complete, at which point the board should reboot.

## Installing Skywire

Access the alarm account on the board via ssh as detailed above.

Install skywire with one of the following commands;

For the latest binary release:
```
yay -S skywire-bin
```

To build from the latest github sources on the develop branch:
```
yay -S skywire
```

The usual configuration steps have been carried out at the packaging level to automatically configure and start a visor and hypervisor.
To configure aditional nodes to appear in the hypervisor interface, you must run the following:

```
skywire
```

as the script completes it will prompt you to run or start the readonly-cache service.
```
readonly-cache
```

## Setting up additional nodes faster

When you have one board running archlinuxARM on your local network, you can bootstrap additional nodes much faster by first configuring them to use the shared package cache of the first board. In addition to acting as an update mirror, all created AUR packages (which include `skywire`, `yay`, etc.) are added to a local package repoitory. Here is how to configure each of these:

add this to /etc/pacman.conf
```
[aur-local]
SigLevel = PackageOptional
Server = http://<ip-of-other-machine-on-lan>:8079
```

Add this to /etc/pacman.d/mirrorlist
```
Server = http://<ip-of-other-machine-on-lan>:8079
```

Then run the `bootstrap` command as root

## Configuring additional Visors with the hypervisor key

Before you install skywire on additional boards, install the hypervisorconfig package. This pacage is provided by the local package repo on the first board you configured.

After installing skywire, the visor will appear in the hypervisor.

## OS Updates

It is strongly recommended the administrator read the following articles in order to become familiar with Archlinux updating conventions:

[System Maintenance - Upgrading the System](https://wiki.archlinux.org/index.php/System_maintenance#Upgrading_the_system)

[Pacman - Upgrading Packages](https://wiki.archlinux.org/index.php/Pacman#Upgrading_packages)

In the rare instance that updates require manual intervention, this will be noted in the [news section](https://www.archlinux.org/news/) of [archlinux.org](https://www.archlinux.org)

To update software across all nodes, first pass a full system update on the manager.
```
sudo pacman -Syy
sudo pacman -Syu
```
or
```
yay -Syy
yay -Syu
```

## Troubleshooting no DNS on the board

The `systemd-resolved.service` is to blame for this. Stop / start it until DNS becomes responsive.
