## Bootstrapping Procedure Overview

* Insert the microSD card into the board
* Power on the board
* SSH to the board
* Initialize and populate pacman-key
* Sync available package database and update
* Generate visor, hypervisor config .jsons
* Set hypervisor key in visor configs
* Enable and start the corresponding systemd service

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

## 2) Bootstrap & update


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

## 3) Configure Skywire

Create the hypervisor config:
```
sudo skywire-hypervisor gen-config -o /etc/skywire-hypervisor.json
```

Create the visor config:
```
sudo skywire-cli visor gen-config -o /etc/skywire-visor.json
```

For details on adding the hypervisor key to the visor's config.json refer to the relevant parts of the [skywire wiki](https://github.com/skycoin/skywire/wiki/Skywire-Mainnet-Installation-From-Source) on installation from source.

Scripts for generating the tls key and cert have been included in the package installation at `/usr/lib/skycoin/skywire`

It is left to the user to accomplish additional configuration.

## Start Skywire

start skywire hypervisor
```
systemctl enable --now skywire-hypervisor
```

start skywire visor
```
systemctl enable --now skywire-visor
```
