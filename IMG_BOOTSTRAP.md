## Bootstrapping Procedure Overview

* Insert the prepared microSD card into the board
* Power on the board
* SSH to the board
* Initialize and populate pacman-key
* Sync available package database and update
* Install `git` and build `yay`
* use `yay` to install `skywire` from the [AUR](https://aur.archlinux.org)

# Bootstrapping Procedure Details

## 1) Access the board via SSH

Insert the microSD card into the first board, and access the board via ssh:
```
ssh alarm@alarm
#password is alarm
```

*Note on rpis this may instead be:* `alarm@alarmpi`

Note: if hostname resolution doesn't work with your router, you may need to determine the IP address of the board from your router's interface and use that instead of the hostname.

Typically the router's interface can be accessed from a web browser at something like [http://192.168.0.1](http://192.168.0.1) or [http://192.168.0.1](http://192.168.0.1). The IP address of the default interface is typically written on the router.

*Tip: if your image has a static IP set, it will not show up in the list of DHCP clients!*

You will need to remove the line in ~/.ssh/known_hosts every time before attempting to connect to a new node **by it's hostname** i.e.:
```
grep -v "^alarm" $HOME/.ssh/known_hosts > $HOME/.ssh/known_hosts.bak && mv $HOME/.ssh/known_hosts.bak $HOME/.ssh/known_hosts
```

## 2) Bootstrap & Update

__note that you will want to install sudo and set sudo permissions for your user after preforming the following steps as root.__

Initialize and populate the pacman-keyring
```
sudo pacman-key --init
sudo pacman-key --populate
```

Update the system
```
sudo pacman -Syy
sudo pacman -Syu
```

__Please note here that you should visit [archlinuxarm.org](https://archlinuxarm.org/) and follow any extra steps that may be specific to your board, such as installing the appropriate uboot package.__

## 3) build and install `yay`

first install `git` and `base-devel`
```
sudo pacman -S git base-devel
```

clone `yay` to its future cache dir
```
mkdir -p ~/.cache/yay && cd ~/.cache/yay
git clone https:/aur.archlinux.org/yay-git
```

build and install `yay`
```
cd yay-git
makepkg -sif
```

`yay` should be installed and it's makedependancy, `golang`

## Install Skywire with yay

```
yay -S skywire
```

The hypervisor should automatically start when the package has been installed. Note that cloning the skywire github repo and building the package may take 10-15 minutes.

follow the prompts to configure additional nodes.
