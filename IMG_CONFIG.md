# Installation

## 1) Download a Release Image

* [Orange Pi Prime](https://github.com/Skyfleet/archlinuxarm/releases/download/latest/orange_pi_prime.img.tar.gz)
* [Orange Pi Zero](https://github.com/Skyfleet/archlinuxarm/releases/download/latest/orange_pi_zero.img.tar.gz)
* [Pine64](https://github.com/Skyfleet/archlinuxarm/releases/download/latest/pine_64.img.tar.gz)
* [RPi 2](https://github.com/Skyfleet/archlinuxarm/releases/download/latest/rpi2.img.tar.gz)
* [RPi 3](https://github.com/Skyfleet/archlinuxarm/releases/download/latest/rpi3.img.tar.gz)
* [RPi 4](https://github.com/Skyfleet/archlinuxarm/releases/download/latest/rpi4.img.tar.gz)


DHCP images are provided by the above links.

## 2) Extract the image from the archive

Usually right-click -> extract.

*Tip: you can use the tar command in the linux subsystem for windows*

## 3) Write the image to a microSD card (linux)

Identify your microSD card using the output of `lsblk` and flash the created image to your microSD Card with `dd` or `dcfldd`:
```
$ sudo dd if=arch-linux-X-XXXXXXXX.img of=/dev/sdX
```

## 3) Write the image to a microSD card (windows)

Windows users should use the [rufus](https://github.com/pbatard/rufus/releases) utility to write the image to the microSD card.

**Be sure you don't forget to expand the rootFS partition to occupy the rest of the microSD card!**
Forgetting to expand the root partition is the number 1 source of errors.
I am unfamiliar with the process for doing this on windows.

## 4) Expand the rootFS partition to occupy the rest of the microSD card

To expand the root filesystem partition, I use `gnome-disks`.
Many utilities exist on linux for doing this including `parted` `gparted` `cfdisk` just to name a few.


## 5) Bootstrapping

You should have an image on the microSD card at this point.

Continue with the [Bootstrappig guide](/IMG_BOOTSTRAP.md)
