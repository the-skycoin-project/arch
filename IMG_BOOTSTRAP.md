## Bootstrapping Procedure Overview

First and foremost:
**Power on only one board at a time to avoid mac address conflicts**


* Insert the microSD card into the board
* Power on the board
* SSH to the board
* Run the `bootstrap` command (script)
* Wait for the bootstrapping to complete (board should reboot)
* SSH to the board again
* Install your desired software (skywire)


# Bootstrapping Procedure Details

I would encourage users to scrutinize the [bootstrap.sh](/bootstrap/bootstrap.sh) and [bootstrap-alarm.sh](bootstrap/bootstrap-alarm.sh) scripts for the details of the bootstrapping procedure. Basic bootstrapping is detailed on [archlinuxarm.org](https://archlinuxarm.org)

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

## 2) Run the bootstrap command as root

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

## 3) Install Skywire

Access the alarm account on the board via ssh as detailed in step 1.

Install skywire with one of the following commands;

For the latest versioned binary release:
```
yay -S skywire-bin
```

To build from the latest github sources on the develop branch:
```
yay -S skywire
```

**The usual configuration steps have been carried out at the packaging level to automatically configure and start a visor and hypervisor.**

To configure aditional nodes to appear in the hypervisor interface, you must run the following **FROM THE HYPERVISOR**:

```
skywire
```

You will be prompted to run or start the readonly-cache service.
```
sudo readonly-cache
```

## 4) Setting up additional nodes faster

When you have one board running archlinuxARM on your local network, you can bootstrap additional nodes much faster by first configuring them to use the shared package cache of the first board. In addition to acting as an update mirror, all created [AUR packages](https://aur.archlinux.org) (which include `yay`, `skywire`, etc.) are added to a local package repoitory. Here is how to configure each of these:

To configure the local package repository, add these lines to `/etc/pacman.conf` on each **additional** node
```
[aur-local]
SigLevel = PackageOptional
Server = http://<ip-of-other-machine-on-lan>:8079
```

To set the first board as an update mirror for the others, add this line to `/etc/pacman.d/mirrorlist`  on each **additional** node
```
Server = http://<ip-of-other-machine-on-lan>:8079
```

**Then** run the `bootstrap` command as root which was covered in step 2

## 5) Configuring additional Visors with the hypervisor key

Before you install skywire on additional boards, install the hypervisorconfig package. This pacage is provided by the local package repo on the first board you configured.

After installing skywire, the visor will appear in the hypervisor.

By this point, you have configured one or more boards with archlinuxARM on your local network.

Continue with the [OS updating and troubleshooting guide](/IMG_UPDATE.md)
