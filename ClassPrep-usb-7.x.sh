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

LOG_FACILITY=local0
LOG_PRIORITY=info
LOG_TAG="${0##*/}"
DEBUG=true
LOGGER='/usr/bin/logger'

function log {
  if [[ ${#1} -gt 0 ]] ; then
    $LOGGER -p ${LOG_FACILITY}.${LOG_PRIORITY} -t $LOG_TAG -- "$1"
  else
    while read data ; do
        $LOGGER -p ${LOG_FACILITY}.${LOG_PRIORITY} -t $LOG_TAG -- "$1" "$data"
    done
  fi
}

function debug {
  if [[ ${#1} -gt 0 ]] ; then
    msg="$1"
    if [[ "$DEBUG" = "true" ]] ; then
        echo "$msg"
    fi
    log "$msg"
  else
    while read data ; do
        if [[ "$DEBUG" = "true" ]] ; then
            echo "$data"
        fi
        log "$data"
    done
  fi
}

function pad {
  local text="$1"
  local dots='...............................................................'
  printf '%s%s  ' "${text}" "${dots:${#text}}"
}

function print_SUCCESS() {
  echo -e '\033[1;36mSUCCESS\033[0;39m'
}

function print_FAIL() {
  echo -e "\\033[1;31mFAIL\\033[0;39m"
}

function nets {
  pad ". network state "
  if ping -c 1 ${SI} &>/dev/null; then
    print_SUCCESS
  else
    print_FAIL
    exit
  fi
}

function netdisk {
  if findmnt /mnt >/dev/null; then
    umount /mnt 2>/dev/null
  fi
  pad ". mounting //$SI/$SS /mnt "
  mount -o username=$UN,password=$UP,nounix,sec=ntlmssp,noserverino,vers=2.0 //$SI/$SS /mnt
  if findmnt /mnt &>/dev/null; then
    print_SUCCESS
  else
    print_FAIL
    exit
  fi
}

function selectCN {
    CNP=$(ls -d /mnt/[CDR]* | awk -F / '{print $NF}' | awk -F - '{print $1"-"$2}')
    zentry=$(zenity --width=300 --height=800 --list --checklist --column "Select" --column "Course" $(for i in $CNP; do echo FALSE $i; done))
    if [ -z $zentry ]; then
      exit
    else
      echo "Your select course is :" $(echo -e '\033[36m'"$zentry"'\033[0m' | sed 's/|/, /g')
    fi
}

function rhtu {
  RU=$(ls /mnt/$(echo $zentry | grep -o RHCI.*RHEL[0-9][0-9])*/rht-usb*)
  pad ". rht-usb "
  if [ ! -z "${RU}" ]; then
    print_SUCCESS
  else
    print_FAIL
    exit
  fi
}

function ufdisk {
  pad ". confirm disk "
  if ! lsblk -S | awk '/usb/ {print $1}'; then
     print_SUCCESS
     UD=$(lsblk -S | awk '/usb/ {print $1}')
  elif [ $(lsblk -S | awk '/disk/ {print $1}' | wc -l) -ge 2 ]; then
     print_SUCCESS
     UD=$(lsblk -S | awk '/disk/ {print $1}' | grep -v sda)
  else
    print_FAIL
    echo -e "\033[36mINFO\tPlease insert Usb disk or Second disk\033[0m"
    exit
  fi
  # umount /tmp/usb
  for i in {1..4}; do
    if lsblk | grep ${UD}{i}.*part.*\ /tmp; then
      umount /dev/${UD}{i}
    fi
  done
  pad ". fdisk /dev/${UD} "
  echo -e "d\nd\nd\nd\n\nn\n\n\n\n\nw\n" | fdisk /dev/${UD} >/dev/null
  if [ -e /dev/${UD}1 ]; then
    print_SUCCESS
  else
    print_FAIL
    exit
  fi
}

function uaddcourse {
  icrm help &>/dev/null
  for i in $(echo $zentry | sed 's/|/ /g'); do
    SP1=$(ls -d /mnt/${i}*)
    sed -i "/repository/s|:.*|: ${SP1}|" ~/.icrm/config.yml
    cd ${SP1} && ICMF=$(ls *.icmf)
    echo -e "\033[36mINFO\t--COURSE:\t${SP1}\033[0m"
    $RU usbadd $ICMF
  done
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

# Main area
# Server Ip
SI=172.25.0.89
# Server Share
SS=Instructor
# User Name
UN=alex
# User Pass
UP=sven99su

ufdisk
nets
netdisk
selectCN
rhtu
uformat
uaddcourse
uboot

