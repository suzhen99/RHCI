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

function rhtu {
  RU=$(ls /mnt/RHCI*/rht-usb*)
  pad ". rht-usb "
  if [ ! -z "${RU}" ]; then
    print_SUCCESS
  else
    print_FAIL
    exit
  fi
}

function selectcn {
  CNP=$(ls -d /mnt/[CDR]* | awk -F / '{print $NF}' | awk -F - '{print $1"-"$2}' | grep -v RHCI)
  echo
  echo -e '\033[36mPlease input the first number:\033[0m'
  select CN in $CNP EXIT
  do
    break
  done
  if [ "${CN}" = "EXIT" ]; then
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

function rhci {
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
# Server Ip
SI=172.25.0.89
# Server Share
SS=Instructor
# User Name
UN=sven

ufdisk
nets
# User Pass
echo -e '\033[36m'
read -p "Please input your password: " UP
echo -e '\033[0m'
netdisk
rhtu
selectcn
uformat
rhci
course
uboot
#env_clear
