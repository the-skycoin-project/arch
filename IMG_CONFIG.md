# Installation

## Release Images

The eight IP preset images for the official skyminer comprise two archives:

* [Nodes 1-4](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer-official/nodes1to4.tar.gz)
* [Nodes 5-8](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer-official/nodes5to8.tar.gz)

DHCP images for various boards can be found at these links:

* [Orange Pi Prime](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/orangepiprime-archlinux-aarch64.img.tar.gz)
* [Pine64](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/pine64-archlinux-aarch64.img.tar.gz)
* [RPi 2](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/rpi2-archlinux-armv7.img.tar.gz)
* [RPi 3](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/rpi3-archlinux-armv7.img.tar.gz)
* [RPi 4](https://github.com/Skyfleet/skyminer-archlinuxarm/releases/download/skyminer/rpi4-archlinux-armv8.img.tar.gz)

You can also [create any image](/IMG_CREATOR.md) such as a custom IP preset image for a specific board

Extract the image from the archive once you have downloaded it (usually left-click -> extract).

## Writing the image to a microSD card (linux)

Identify your microSD card using the output of `lsblk` and flash the created image to your microSD Card with `dd` or `dcfldd`:
```
$ sudo dd if=arch-linux-X-XXXXXXXX.img of=/dev/sdX
```

**When the image has been written to the microSD card, expand the rootFS partition to occupy the rest of the microSD card**

*Repeat this step for every node in your skyminer.*

## Writing the image to a microSD card (windows)

Windows users should use the [rufus](https://github.com/pbatard/rufus/releases) utility to write the image to the microSD card.

Be sure to **expand the rootFS partition to occupy the rest of the microSD card**

## Procedure

It is critical to run this configuration on only *one node at a time*

* Run the configuration script for manager or node
* wait for the board to reboot
* check the web interface in your browser *before powering on additional nodes.*
* clear your browser cache (`ctrl+shift+del`) every time you expect to see a new node in the manager's web interface

Newly connected (dhcp) nodes can be reached with `ssh alarm@alarm`

*Note on rpis this may instead be:* `alarm@alarmpi`

Note: hostname resolution doesn't work with the official router: *use the IP address of the image instead of the hostname such as: `ssh alarm@192.168.0.2`* if using IP preset images

You will need to remove the line in ~/.ssh/known_hosts every time before attempting to connect to a new node by it's hostname; i.e.:
```
grep -v "^alarm" $HOME/.ssh/known_hosts > $HOME/.ssh/known_hosts.bak && mv $HOME/.ssh/known_hosts.bak $HOME/.ssh/known_hosts
```

# Image configuration

## Manager Setup

Insert the microSD card into your manager board, and access the board via ssh:
```
ssh alarm@alarm
#password is alarm
su - root
#password is root
```
If using official hardware, substituite the hostname `alarm` with the IP address of the manager - 192.168.0.2

To configure a manager, run the setup for the manager as root with:
```
skybootstrap
```

It will take 15-20 minutes for the configuration and software updates to complete, at which point the board should reboot.
When the board has rebooted, it's hostname will be `skymanager`, and the board will be reachable with `ssh alarm@skymanager`

Before continuing to the node setup, check the manager interface in your web browser (for example: 192.168.0.2:8000)
Also check that the readonly-cache service is working with your web browser (for example: 192.168.0.2:8080)
This should show a directory listing of all currently installed packages on the manager.

## Node Setup

You will need to remove the line in ~/.ssh/known_hosts every time before attempting to connect to a new node; i.e.:
```
grep -v "^alarm" $HOME/.ssh/known_hosts > $HOME/.ssh/known_hosts.bak && mv $HOME/.ssh/known_hosts.bak $HOME/.ssh/known_hosts
```

Insert the microSD card into the node, and access the board via ssh:
```
ssh alarm@alarm
#password is alarm
su - root
#password is root
```
If using official hardware, substituite the hostname `alarm` with the IP address of the node - 192.168.0.3 to 192.168.0.9


To configure additional nodes (the manager **must** be set up and running first):

```
nodebootstrap
```

Enter the IP address of your manager if / when prompted.
You may also provide the manager ip address as an argument to `nodebootstrap`
for example:
```
nodebootstrap 192.168.0.2
```

You will be prompted to enter a unique identifier for the node in order to change it's hostname (non ip-presetted images).
This identifier will be prepended to `node`

The board should reboot when the configuration is completed, and the hostname will be changed to `node#`

You will need to remove the line in ~/.ssh/known_hosts every time before attempting to connect to a new node; i.e.
```
grep -v "^alarm" $HOME/.ssh/known_hosts > $HOME/.ssh/known_hosts.bak && mv $HOME/.ssh/known_hosts.bak $HOME/.ssh/known_hosts
```

## Changing Skymanager IP address in the nodes

In the instance they you have relocated your skyminer or deleted the DHCP lease in the router, the following can be run on the nodes to change the manager IP address in the skywire node start script (*as root*):
```
skywire-node-setup <skymanager-ip>
```
replace <skymanager-ip> with the actual IP address of skymanager on your LAN

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

## Updating Skywire to the latest commits

**To update your skywire installaion** or any AUR package, install or reinstall it on the manager.
*This must be done from a user account.*
```
yay -S --noconfirm skywire
```
*Be sure to cleanbuild the package.*
*If you encounter issues:*
```
rm -rf $HOME/.cache/yay/skywire
```

Any packages in yay's cache can be added to the skyminer repo with the command:
```
skyminer-repo-update
```
*the package does not have to be installed on skymanager to be available to the nodes, but must exist in the package cache*

Check that the readonly-cache service is running by going to the `<skymanager-ip>:8080` in a web browser, replacing `<skymanager-ip>` with the actual ip address of skymanager on your LAN.

If the readonly-cache service is not running, you can start it explicitly with
```
sudo readonly-cache
```
or
```
sudo systemctl start readonly-cache
```

On the nodes, a full system update should download the newer version of the skywire package from the skyminer repo on the manager and install it. The following commands must be run with root or sudo on each node:
```
pacman -Syy
pacman -Syu
```

## Updating From Testnet to Mainnet

The procedure as described above still holds.
On the manager (*This must be done from a user account*):
```
yay -Syy
yay -Syu
yay -S --noconfirm skywire-mainnet
skyminer-repo-update
#start the readonly-cache service if it's not running
```

On each of the the nodes, (*as root*):
```
pacman -Syy
pacman -Syu
pacman -S skywire-mainnet
```
