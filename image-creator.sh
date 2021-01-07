#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  $DIALOG1 \
  --title "Error:" --msgbox "\nYou must be root to do this" 7 32
  #echo "You must be root to do this."
  1>&2
  exit 100
fi
set -ex

# load env variables.
# shellcheck source=./image-creator.conf
source "$(pwd)/image-creator.conf"

ensure_cleanup() {
  set +e
  umount arch-root/proc
  umount arch-root/sys
  umount arch-root/dev/pts
  umount arch-root/dev
  umount arch-root
  losetup -d /dev/loop0
  set -e
}
ensure_cleanup

#modify_chroot() {
#  #add bootstrapping packages
#  if [ -d "$_packagedir" ]; then
#    cd $_packagedir
#    toinstall=$(ls *.pkg.tar.*)
#    cd ..
#    for i in $toinstall; do
#    cp $_packagedir/$i arch-root/root/$i
#    done
#    cp pacman.conf arch-root/etc/pacman.conf
#    cp /usr/bin/qemu-arm-static arch-root/usr/bin
#    #	arch-chroot arch-root pacman -U /root/*.pkg.tar.xz --noconfirm
#    #manually chroot to support image creation on other distros
#    mount -t proc /proc arch-root/proc
#    mount -o bind /dev arch-root/dev
#    mount -o bind /dev/pts arch-root/dev/pts
#    mount -o bind /sys arch-root/sys
#    chroot arch-root /bin/bash -c "pacman -U /root/*.pkg.tar.* --noconfirm"
#    rm arch-root/usr/bin/qemu-arm-static
#    umount arch-root/proc
#    umount arch-root/sys
#    umount arch-root/dev/pts
#    umount arch-root/dev
#  fi
#
#}

create_rpi_img(){
  #rpi2
  #IMG=rpi2-archlinux-armv7-$(date +%Y%m%d)
  #URL=$BASEURL/ArchLinuxARM-rpi-2-latest.tar.gz
  #RPIMG=ArchLinuxARM-rpi-2-latest.tar.gz
  #rpi3
  #IMG=rpi3-archlinux-armv7-$(date +%Y%m%d)
  #URL=$BASEURL/ArchLinuxARM-rpi-3-latest.tar.gz
  #RPIMG=ArchLinuxARM-rpi-3-latest.tar.gz
  #rpi4
  #IMG=rpi4-archlinux-armv8-$(date +%Y%m%d)
  #URL=$BASEURL/ArchLinuxARM-rpi-4-latest.tar.gz
  #RPIMG=ArchLinuxARM-rpi-4-latest.tar.gz

#check for an image alerady created
IMGPATH=$SRCDIR/$IMG
ROOTFSGZPATH=$SRCDIR/$RPIMG
if [ ! -f $IMGPATH  ]; then
  set -ex
	losetup /dev/loop0 && exit 1 || true
  if [ ! -f "$ROOTFSGZPATH" ]; then
	wget -P $SRCDIR -N $URL
fi
	truncate -s 2G $IMGPATH
	losetup /dev/loop0 $IMGPATH
	parted -s /dev/loop0 mklabel msdos
	parted -s /dev/loop0 unit MiB mkpart primary fat32 -- 1 128
	parted -s /dev/loop0 set 1 boot on
	parted -s /dev/loop0 unit MiB mkpart primary ext2 -- 128 -1
	parted -s /dev/loop0 print
	mkfs.vfat -n SYSTEM /dev/loop0p1
	mkfs.ext4 -L root -b 4096 -E stride=4,stripe_width=1024 /dev/loop0p2
	mkdir -p arch-boot
	mount /dev/loop0p1 arch-boot
	mkdir -p arch-root
	mount /dev/loop0p2 arch-root
	bsdtar -xpf $ROOTFSGZPATH -C arch-root
	sed -i "s/ defaults / defaults,noatime /" arch-root/etc/fstab
	mv arch-root/boot/* arch-boot/
  #modify_chroot
  umount arch-boot arch-root
  losetup -d /dev/loop0
fi
mv $SRCDIR/$IMG $OUTDIR/$IMG
if [ -f $IMGPATH ]; then
img_created
fi
}


create_orpi_prime_img() {
  IMG=orangepiprime-archlinux-aarch64-$(date +%Y%m%d).img

if [ ! -f $IMG ]; then
  set -ex
  if [ ! -f $SRCDIR/ArchLinuxARM-aarch64-latest.tar.gz ]; then
    wget -P $SRCDIR -N $BASEURL/ArchLinuxARM-aarch64-latest.tar.gz
  fi
  if [ ! -f $SRCDIR/ArchPrimeH5.img.tar.xz ]; then
    wget -P $SRCDIR -N https://github.com/0pcom/skyalarm-old/releases/download/ArchPrimeH5/ArchPrimeH5.img.tar.xz
  fi
  bsdtar -xpf $SRCDIR/ArchPrimeH5.img.tar.xz -C $SRCDIR
	gnome-disk-image-mounter -w $SRCDIR/ArchPrimeH5.img
	mkdir -p arch-root
	mount  /dev/loop0p2 arch-root
	#cd arch-root
	rm -rf arch-root/bin arch-root/dev arch-root/home arch-root/mnt arch-root/proc arch-root/run arch-root/srv arch-root/tmp arch-root/var arch-root/etc arch-root/lib arch-root/opt arch-root/root arch-root/sbin arch-root/sys arch-root/usr
	#cd $WORKINGDIR
	bsdtar -xpf $SRCDIR/ArchLinuxARM-aarch64-latest.tar.gz -C arch-root --exclude 'boot'
#modify_chroot
umount arch-root
losetup -d /dev/loop0
mv $SRCDIR/ArchPrimeH5.img $OUTDIR/$IMG
fi
if [ -f $OUTDIR/$IMG ]; then
img_created
else
  echo "error has occured!!"
fi
}

create_orpi_zero_img() {
  #https://github.com/0pcom/skyalarm-old/releases/download/ArchZeroH2/ArchLinuxARM-OrangePiZero-latest.img.tar.xz
  IMG=orangepizero-archlinux-armv7-$(date +%Y%m%d).img
  if [ ! -f "$SRCDIR/$IMG" ]; then
    set -ex
    if [ ! -f "$SRCDIR/ArchLinuxARM-armv7-latest.tar.gz" ]; then
      wget -P $SRCDIR -N $BASEURL/ArchLinuxARM-armv7-latest.tar.gz
    fi
    if [ ! -f "$SRCDIR/ArchLinuxARM-OrangePiZero-latest.img.tar.xz" ]; then
      wget -P $SRCDIR -N https://github.com/0pcom/skyalarm-old/releases/download/ArchZeroH2/ArchLinuxARM-OrangePiZero-latest.img.tar.xz
    fi
    bsdtar -xpf $SRCDIR/ArchLinuxARM-OrangePiZero-latest.img.tar.xz -C $SRCDIR
    gnome-disk-image-mounter -w $SRCDIR/ArchLinuxARM-OrangePiZero-latest.img
    mkdir -p arch-root
    mount  /dev/loop0p1 arch-root
    rm -rf arch-root/bin arch-root/dev arch-root/home arch-root/mnt arch-root/proc arch-root/run arch-root/srv arch-root/tmp arch-root/var arch-root/etc arch-root/lib arch-root/opt arch-root/root arch-root/sbin arch-root/sys arch-root/usr
    bsdtar -xpf $SRCDIR/ArchLinuxARM-armv7-latest.tar.gz -C arch-root --exclude 'boot'
    #modify_chroot
    umount arch-root
    losetup -d /dev/loop0
    mv $SRCDIR/ArchLinuxARM-OrangePiZero-latest.img $OUTDIR/$IMG
  fi
  if [ -f $OUTDIR/$IMG ]; then
  img_created
  else
    echo "error has occured!!"
  fi
}

create_pine64_img(){

  IMG=pine64-archlinux-aarch64-$(date +%Y%m%d).img
  FULLIMGNAME=$PLATFORM-$AARCH64

  URL1=$BASEURL1$BOOTSCR
  URL2=$BASEURL1$UBOOT

if [ ! -f $IMG ]; then
  set -ex
	losetup /dev/loop0 && exit 1 || true
  if [ ! -f "$SRCDIR/ArchLinuxARM-aarch64-latest.tar.gz" ]; then
    wget -P $SRCDIR -N $BASEURL/ArchLinuxARM-aarch64-latest.tar.gz
  fi
	truncate -s 2G $IMG
	losetup /dev/loop0 $IMG
	parted -s /dev/loop0 mklabel msdos
	parted -s /dev/loop0 unit MiB mkpart primary fat32 -- 1 64
	parted -s /dev/loop0 set 1 boot on
	parted -s /dev/loop0 unit MiB mkpart primary ext2 -- 64 -1
	parted -s /dev/loop0 print
	mkfs.vfat -n SYSTEM /dev/loop0p1
	mkfs.ext4 -L root -b 4096 -E stride=4,stripe_width=1024 /dev/loop0p2
	#mkdir -p arch-boot
	#mount /dev/loop0p1 arch-boot
  mkdir -p $SRCDIR/pine64boot
  if [ ! -f "$SRCDIR/pine64boot/boot.scr" ]; then
  wget -P $SRCDIR/pine64boot/ -N ${BASEURL}/allwinner/boot/pine64/boot.scr
  fi
  dd if=pine64boot/boot.scr of=/dev/loop0 bs=8k seek=1
	mkdir -p arch-root
	mount /dev/loop0p2 arch-root
	bsdtar -xpf $SRCDIR/ArchLinuxARM-aarch64-latest.tar.gz -C arch-root
	#sed -i "s/ defaults / defaults,noatime /" arch-root/etc/fstab
	#mv arch-root/boot/* arch-boot/
  if [ ! -f "$SRCDIR/pine64boot/u-boot-sunxi-with-spl.bin" ]; then
    wget -N ${BASEURL}/allwinner/boot/pine64/u-boot-sunxi-with-spl.bin
  fi
  cp pine64boot/u-boot-sunxi-with-spl.bin  arch-root/boot/u-boot-sunxi-with-spl.bin
  #modify_chroot
  umount arch-root
  losetup -d /dev/loop0
fi
    mv $SRCDIR/$IMG $OUTDIR/$IMG
if [ -f $OUTDIR/$IMG ]; then
img_created
else
  echo "error has occured!!"
fi
}

img_created() {
  $DIALOG1 \
  --title "DHCP base image created at:" --msgbox "
  $(ls $OUTDIR/$IMG)" 0 0
}

static_img_created() {
  $DIALOG1 \
  --title "Static IP image created at:" --msgbox "
  $(ls $OUTDIR/*.img)" 0 0
}

create_all_base() {
  IMG=orangepiprime-archlinux-aarch64-$(date +%Y%m%d).img
  create_orpi_prime_img
  IMG=orangepizero-archlinux-armv7-$(date +%Y%m%d).img
  create_orpi_zero_img
  IMG=rpi2-archlinux-armv7-$(date +%Y%m%d).img
  URL=$BASEURL/ArchLinuxARM-rpi-2-latest.tar.gz
  RPIMG=ArchLinuxARM-rpi-2-latest.tar.gz
  create_rpi_img
  IMG=rpi3-archlinux-armv7-$(date +%Y%m%d).img
  URL=$BASEURL/ArchLinuxARM-rpi-3-latest.tar.gz
  RPIMG=ArchLinuxARM-rpi-3-latest.tar.gz
  create_rpi_img
  IMG=rpi4-archlinux-armv8-$(date +%Y%m%d).img
  URL=$BASEURL/ArchLinuxARM-rpi-4-latest.tar.gz
  RPIMG=ArchLinuxARM-rpi-4-latest.tar.gz
  create_rpi_img
  IMG=pine64-archlinux-aarch64-$(date +%Y%m%d).img
  create_pine64_img
}

select_board_dhcp() {
   $DIALOG1 \
   --title "Choose Board Type" \
   --menu "Board select:" 0 0 5 \
    "1" "Orange Pi Prime" \
    "2" "Orange Pi Zero" \
    "3" "Rpi2" \
    "4" "Rpi3" \
    "5" "Rpi4" \
    "6" "Pine64" \
    "7" "go back" 2>${ANSWER}

    case $(cat ${ANSWER}) in
      "1")
      IMG=orangepiprime-archlinux-aarch64-$(date +%Y%m%d).img
      create_orpi_prime_img
      break ;;
      "2")
      IMG=orangepizero-archlinux-armv7-$(date +%Y%m%d).img
      create_orpi_zero_img
      break ;;
      "3")
      IMG=rpi2-archlinux-armv7-$(date +%Y%m%d).img
      URL=$BASEURL/ArchLinuxARM-rpi-2-latest.tar.gz
      RPIMG=ArchLinuxARM-rpi-2-latest.tar.gz
      create_rpi_img
      break ;;
      "4")
      IMG=rpi3-archlinux-armv7-$(date +%Y%m%d).img
      URL=$BASEURL/ArchLinuxARM-rpi-3-latest.tar.gz
      RPIMG=ArchLinuxARM-rpi-3-latest.tar.gz
      create_rpi_img
      break ;;
      "5")
      IMG=rpi4-archlinux-armv8-$(date +%Y%m%d).img
      URL=$BASEURL/ArchLinuxARM-rpi-4-latest.tar.gz
      RPIMG=ArchLinuxARM-rpi-4-latest.tar.gz
      create_rpi_img
      break ;;
      "6")
      IMG=pine64-archlinux-aarch64-$(date +%Y%m%d).img
      create_pine64_img
      break ;;
      "7")
      static_ip_set
      break ;;
      *)
      exit 1
      ;;
  esac
}

select_board_static() {
   $DIALOG1 \
   --title "Choose Board Type" \
   --menu "Board select:" 0 0 5 \
    "1" "Orange Pi Prime" \
    "2" "Orange Pi Zero" \
    "3" "Rpi2" \
    "4" "Rpi3" \
    "5" "Rpi4" \
    "6" "Pine64" \
    "7" "go back" 2>${ANSWER}

    case $(cat ${ANSWER}) in

        "1")
        IMG=orangepiprime-archlinux-aarch64-$(date +%Y%m%d).img
        create_orpi_prime_img
        create_ip_preset_imgs  $SKY_MGR_IP 1
        break ;;
        "2")
        IMG=orangepizero-archlinux-armv7-$(date +%Y%m%d).img
        create_orpi_zero_img
        create_ip_preset_imgs  $SKY_MGR_IP 1
        break ;;
        "3")
        IMG=rpi2-archlinux-armv7-$(date +%Y%m%d).img
        URL=$BASEURL/ArchLinuxARM-rpi-2-latest.tar.gz
        RPIMG=ArchLinuxARM-rpi-2-latest.tar.gz
        create_rpi_img
        create_ip_preset_imgs  $SKY_MGR_IP 1
        break ;;
        "4")
        IMG=rpi3-archlinux-armv7-$(date +%Y%m%d).img
        URL=$BASEURL/ArchLinuxARM-rpi-3-latest.tar.gz
        RPIMG=ArchLinuxARM-rpi-3-latest.tar.gz
        create_rpi_img
        create_ip_preset_imgs  $SKY_MGR_IP 1
        break ;;
        "5")
     		IMG=rpi4-archlinux-armv8-$(date +%Y%m%d).img
        URL=$BASEURL/ArchLinuxARM-rpi-4-latest.tar.gz
        RPIMG=ArchLinuxARM-rpi-4-latest.tar.gz
     		create_rpi_img
        create_ip_preset_imgs $SKY_MGR_IP 1
     		break ;;
        "6")
        IMG=pine64-archlinux-aarch64-$(date +%Y%m%d).img
        create_pine64_img
        create_ip_preset_imgs  $SKY_MGR_IP 1
        break ;;
        "7")
        static_ip_set
        break ;;
        *)
        exit 1
        ;;
    esac
}

create_ip_preset_imgs() {
  set -ex
SKY_MGR_IP=$1
  if [ -d "$OUTDIR" ]; then
    rm -rf $OUTDIR
  fi
  if [ $2 = "1" ]; then
    IPDIR=$CUSTDIR
    cd $IPDIR
    HOSTNAMES=$(ls *)
    cd $WORKINGDIR
  else
    IPDIR=$PRESETDIR
    cd $IPDIR
    HOSTNAMES=$(ls *)
    cd $WORKINGDIR
  fi
  mkdir -p $OUTDIR
  for i in $HOSTNAMES; do
    cp -b $IMG $OUTDIR/${FULLIMGNAME}-${i}.img
    gnome-disk-image-mounter -w $OUTDIR/${FULLIMGNAME}-${i}.img
    mount  /dev/loop0p2 arch-root
    cp -b $IPDIR/$i arch-root/etc/systemd/network/eth.network
    echo "$i" > arch-root/etc/hostname
    if [[ "$i" == *"node"* ]] && [ ! -z "$SKY_MGR_IP" ]; then
    echo "SKYMGRIP=$SKY_MGR_IP" >> arch-root/etc/profile
  fi
    sleep 1
    umount arch-root
    losetup -d /dev/loop0
  done
  static_img_created
  exit
}

#the hostname is the filename, inside is the static ip
hostname_set() {
  set +e
  rm $CUSTDIR/*
  set -e
   $DIALOG1 \
   --radiolist "Choose Hostname:" 0 0 6 \
   "1" "skymanager" off \
   "2" "node1" off \
   "3" "node2" off \
   "4" "node3" off \
   "5" "node4" off \
   "6" "node5" off \
   "7" "node6" off \
   "8" "node7" off 2> ${ANSWER}
   case $(cat ${ANSWER}) in
       "1")
       IMGHOSTNAME="skymanager"
       ;;
       "2")
       IMGHOSTNAME="node1"
       ;;
       "3")
       IMGHOSTNAME="node2"
       ;;
       "4")
       IMGHOSTNAME="node3"
       ;;
       "5")
       IMGHOSTNAME="node4"
       ;;
       "6")
       IMGHOSTNAME="node5"
       ;;
       "7")
       IMGHOSTNAME="node6"
       ;;
       "8")
       IMGHOSTNAME="node7"
       ;;
       *)
       cd $WORKINGDIR
       rm -r $CUSTDIR
       exit 1
       ;;
   esac
   if [ -z $IMGHOSTNAME ]; then
     hostname_set
   else
   touch $IMGHOSTNAME
 fi
 if [ "$IMGHOSTNAME" == *"skymanager"* ]; then
   SKY_MGR_IP=127.0.0.1
  static_ip_set continue
else
mgr_ip_enter
static_ip_set continue
fi
}

img_ip_enter() {
   $DIALOG1 \
    --title "Image IP Address?" \
    --inputbox "\nEnter desired image IP Address:"  8 40 2> ${ANSWER}
  IMGIPADDRESS=$(cat ${ANSWER})
  case $(cat ${ANSWER}) in
    *.*.*.*)
    if [ -z $SKY_MGR_IP ]; then
      mgr_ip_enter
    fi
    static_ip_set continue
    break;;
    *)
    $DIALOG1 \
    --title "Error:" --msgbox "\nInvalid IP address provided" 7 40
    HIGHLIGHT=2
    static_ip_set continue
    break;;
  esac

  if [ -z $IMGIPADDRESS ]; then
    img_ip_enter
  fi
  static_ip_set continue
}

mgr_ip_enter() {
   $DIALOG1 \
   --title "Sky Manager IP Address?" \
   --inputbox "\nEnter skymanager IP Address:"  8 40 2> ${ANSWER}
  SKY_MGR_IP=$(cat ${ANSWER})
  case $(cat ${ANSWER}) in
    *.*.*.*)
    if [ -z $SKY_MGR_IP ]; then
      mgr_ip_enter
    fi
    static_ip_set continue
    break;;
    *)
    $DIALOG1 \
    --title "Error:" --msgbox "\nInvalid IP address provided" 7 40
    HIGHLIGHT=1
    static_ip_set
    break;;
  esac
}

router_ip_enter() {
   $DIALOG1 \
   --title "Router / Gateway IP Address?" \
   --inputbox "\nEnter router IP Address:"  8 40 2> ${ANSWER}
  ROUTERIP=$(cat ${ANSWER})
  case $(cat ${ANSWER}) in
    *.*.*.*)
    if [ -z $ROUTERIP ]; then
      router_ip_enter
    fi
    static_ip_set continue
    break;;
    *)
    $DIALOG1 \
    --title "Error:" --msgbox 'Invalid IP address provided' 7 40
    HIGHLIGHT=3
    static_ip_set continue
    break;;
  esac

}

confirm_static_cfg() {
   $DIALOG1 \
   --title "Use this config?" --clear \
   --yesno "\nHostname: $IMGHOSTNAME\nImage IP: $IMGIPADDRESS\nGateway: $ROUTERIP\nManager IP: $SKY_MGR_IP" 9 40
    case $? in
    0)
      select_board_static
      break;;
  esac
}

static_ip_set() {
  set -ex
  cd $WORKINGDIR
if [[ "$1" != *"continue"* ]]; then
if [ -d $CUSTDIR ]; then
rm -rf $CUSTDIR
fi
if [ ! -d $CUSTDIR ]; then
mkdir -p $CUSTDIR
cd $CUSTDIR
fi
fi
#if [ "$1" == *"continue"* ] && [[ $HIGHLIGHT != 4 ]]; then
#	   HIGHLIGHT=$(( HIGHLIGHT + 1 ))
#fi
 $DIALOG1 \
 --default-item ${HIGHLIGHT} \
 --title "Choose" \
 --menu "Please select: " 0 0 3 \
  "1" "Set Hostname / manager IP" \
  "2" "Set Image IP" \
  "3" "Set Router IP" \
  "4" "Confirm Settings" \
  "5" "Back" 2> ${ANSWER1}
  case $(cat ${ANSWER1}) in
      "1")
      HIGHLIGHT=2
      hostname_set
      IMGHOSTNAME=$(ls *)
      if [ $IMGHOSTNAME != *"hypervisor"* ]; then
      mgr_ip_enter
      fi
      ;;
      "2")
      if [ -z $IMGHOSTNAME ]; then
         $DIALOG1 \
         --title "Error:" \
         --yesno  "\nPlease configure the hostname first.\n" 7 40
          case $? in
          0)
          HIGHLIGHT=1
          static_ip_set
          break;;
        esac
      else
        HIGHLIGHT=3
        img_ip_enter
      fi
      IMGIPADDRESS=$(cat ${ANSWER})
      ;;
      "3")
      if [ -z $IMGIPADDRESS ]; then
        $DIALOG1 \
        --title "Error:" \
        --yesno  "\nPlease set the image IP first.\n" 7 40
         case $? in
         0)
         HIGHLIGHT=1
           static_ip_set
           break;;
       esac
      else
        HIGHLIGHT=4
      router_ip_enter
      ROUTERIP=$(cat ${ANSWER})
    fi
      ;;
      "4")
      if [ -z $IMGHOSTNAME ]; then
        $DIALOG1 \
        --title "Error:" \
        --yesno  "\nPlease configure the hostname first.\n" 7 40
         case $? in
         0)
         HIGHLIGHT=1
           static_ip_set
           break;;
       esac
      else
      if [ -z $IMGIPADDRESS ]; then
         $DIALOG1 \
         --title "Error:" \
         --yesno  "\nPlease set the image IP first.\n" 7 40
          case $? in
          0)
          HIGHLIGHT=2
            static_ip_set
            break;;
        esac
      else
      if [ -z $ROUTERIP ]; then
         $DIALOG1 \
         --title "Error:" \
         --yesno  "\nPlease set the router IP first.\n" 7 40
          case $? in
          0)
          HIGHLIGHT=1
            static_ip_set
            break;;
        esac
      else
        HIGHLIGHT=1
echo "[Match]
Name=eth*

[Network]
Address=$IMGIPADDRESS
Gateway=$ROUTERIP
DNS=$ROUTERIP
" > ${CUSTDIR}/${IMGHOSTNAME}
        cd $WORKINGDIR
      confirm_static_cfg $IMGHOSTNAME
    fi
  fi
fi
      ;;
      "5")
      cd $WORKINGDIR
      rm -rf "customIP"
      main_menu
      ;;
      *)
      exit 1
      ;;
  esac
static_ip_set
}

main_menu() {

   $DIALOG1 \
   --title "Choose Installation Type" \
   --menu "Please select: " 0 0 1 \
    "1" "Official Skyminer (8 Image Set)" \
    "2" "Single IP Preset Image" \
    "3" "DHCP Image" \
    "4" "All Base images" 2> answer
#    HIGHLIGHT=$(cat ${ANSWER})
    case $(cat answer) in
        "1")
        create_orpi_prime_img
        create_ip_preset_imgs 192.168.0.2
        ;;
        "2")
        static_ip_set
        ;;
        "3")
        select_board_dhcp
        ;;
        "4")
        create_all_base
        ;;
        *)
        exit 1
        ;;
    esac
    main_menu
}

while true; do
main_menu
done
