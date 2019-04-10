#!/bin/bash

# Copyright 2019 East Home, Inc.
#
# NAME
#     vmnet1_host - VMware vmnet1 host-only set tool for MacOS
#
# SYNOPSIS
#     vmnet1_host
#
# DESCRIPTION
#     vmnet1_host
#
# CHANGELOG
#   * Mon Apr 1 2019 Alex Su <suzhen@easthome.com>
#   - initial code

function vmnet1_host {
    VFN="/Library/Preferences/VMware Fusion/networking"
    sed -i.bk \
    -e '/VNET_1_DHCP /s/yes/no/' \
    -e '/VNET_1.*NETMASK/s/NETMASK.*/NETMASK 255.255.0.0/' \
    -e '/VNET_1.*SUBNET/s/SUBNET.*/SUBNET 172.25.0.88/' "${VFN}"
}

# Main area
vmnet1_host
