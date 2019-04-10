#!/bin/bash

# Copyright 2019 East Home, Inc.
#
# NAME
#     ClassPrep-usb - F0 Make USB Tool
#
# SYNOPSIS
#     ClassPrep-usb
#
# DESCRIPTION
#     ClassPrep-usb
#
# CHANGELOG
#   * Mon Apr 1 2019 Alex Su <suzhen@easthome.com>
#   - initial code

# Server Ip
SI=172.25.0.89
# Server Share
SS=Instructor
# User Name
UN=sven
# User Pass
read -p "Please input your password: " UP

function netdisk {
  if findmnt /mnt >/dev/null; then
    umount /mnt 2>/dev/null
  fi
  # network state
  ping -c 1 ${SI} &>/dev/null || echo "INFO\tnetwork is disconnect" && exit 1
  mount -o username=$UN,password=$UP,nounix,sec=ntlmssp,noserverino,vers=2.0 //$SI/$SS /mnt && echo -e "mounted sucessfully\033[0m" ;;
}

function selectcn {
  CNP=$(ls -d /mnt/[CDR]* | awk -F / '{print $NF}' | awk -F - '{print $1"-"$2}')
  echo -e '\033[36mPlease input the first number:\033[0m'
  select CN in "$CNP" EXIT
  do
    break
  done
  if [ "${CN}" = "EXIT" ]; then
    exit
  fi
}

function ufdisk {
  if lsblk -S | awk '/usb/ {print $1}'; then
    echo -e " INFO\tUsb disk"
    UD=$(lsblk -S | awk '/usb/ {print $1}')
  elif lsblk -S | awk '/disk/ {print $1}' | grep -v sda; then
    echo -e " INFO\tSecond disk"
    UD=$(lsblk -S | awk '/disk/ {print $1}' | grep -v sda)
  else
    echo -e " INFO\tPlease insert Usb disk or Second disk"
    exit 2
  fi
  # umount /tmp/usb
  for i in {1..4}; do
    if lsblk | grep ${UD}{i}.*part.*\ /tmp; then
      umount /dev/${UD}{i}
    fi
  done
  # fdisk
  echo -e "d\nd\nd\nd\n\nn\n\n\n\n\nw\n" | fdisk /dev/${UD} >/dev/null
  if [ -e /dev/${UD}1 ]; then
    echo -e "\033[36mINFO\t--UD:\t/dev/${UD}1\033[0m"
  fi
}

function rhci {
  RU=$(ls /mnt/RHCI*/rht-usb*)
  echo -e "\033[36mINFO\t--RU:\t${RU}\033[0m"
  SP1=$(ls -d /mnt/RHCI*)
  icrm help &>/dev/null
  sed -i "/repository/s|:.*|: ${SP1}|" ~/.icrm/config.yml
  cd ${SP1} && ICMF=$(ls *.icmf)
  echo -e "\033[36mINFO\t--SP1:\t${SP1}\033[0m"
  $RU usbadd $ICMF
}

function course {
  SP2=$(ls -d /mnt/${CN}*)
  sed -i "/repository/s|:.*|: ${SP2}|" ~/.icrm/config.yml
  echo -e "\033[36mINFO\t--SP2:\t${SP2}\033[0m"
  cd ${SP2} && ICMF=$(ls *.icmf)
  $RU usbadd $ICMF
}

function uformat {
  echo -e "\033[36mINFO\t--FORMAT\033[0m"
  echo y | $RU usbformat /dev/$UD\1
  echo
}

function uboot {
  echo -e "\033[36mINFO\t--BOOTABLE\033[0m"
  sleep 3
  echo y | $RU usbmkboot
}

function env_clear {
  echo -e "\033[36mINFO\t--UNSET\033[0m"
  unset netdisk udisk rhci course
  unset SI SS UN UP RU UD SP1 SP2 ICMF
  sleep 15
  umount /mnt
}

# Main area
netdisk
selectcn
ufdisk
uformat
rhci
course
uboot
#env_clear
