# Arch Linux ARM image creator

This project has moved away from a scripted build process to manually chrooting to, and updating existing images.
The image-creator.sh should be examined for any questions regarding creating such images from scratch.

## User-relevant information

A scripted bootstrapping process is replaced with instructions:
* initialize and populate pacman-key
* sync available package database and update

Then, the required steps for configuration of skywire:
* generate visor, hypervisor config .jsons
* set hypervisor key in visors
* enable and start systemd service

## Maintainer-relevant information

Everything that is not done by the user is configured initially in the images by the maintainer.
The changes that are made in the images are documented here. The process is as follows

Existing images are downloaded or base images are generated. Then the image is mounted as writeable, ex.:
```
gnome-disk-image-mounter -w /path/to/image.img
```

The root filesystem is mounted (from the gnome-disks gui interface)

The /usr/bin/qemu-arm-static binay is copied into the rot filesystem

Chroot is entered:
* grant sudo privelages to alarm or default user
* /etc/makepkg.conf edited to create .zst packages
* all packages available in the release section for the architecture which matches the image are installed in the chroot (mirrorlist, keyring, skywire, skycoin, fixdns, macchanger-service, yay)
* `skycoin` package repository is set in /etc/pacman.conf
* pacman key is initialized and populated
* a package mirror is configured on a running board of the same architecture
* chrooted system set to update from the LAN mirror (DNS DOES NOT WORK IN CHROOT)
* update is preformed.
* install golang
* package cache cleaned
* unset LAN mirror from mirrorlist
* reset pacman-key (`rm -r /etc/pacman.d/gnupg`)

For images which have been previously configured this way, the redundant steps are skipped and the image is updated, making sure to reset the pacman-key afterwards.
