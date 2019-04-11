#!/bin/bash

# Copyright 2019 East Home, Inc.
#
# NAME
#     f0-external - Foundation0 connection Internet tool
#
# SYNOPSIS
#     f0-external
#
# DESCRIPTION
#     f0-external
#
# CHANGELOG
#   * Mon Apr 1 2019 Alex Su <suzhen@easthome.com>
#   - initial code

function f0_internet {
    FNIC2=$(nmcli dev status | awk '/disconnected/ {print $1}')
    sleep 1s 
    nmcli con add type ethernet autoconnect yes \
    ifname ${FNIC2} connection.id ${FNIC2} ipv4.method auto
    sleep 5s
    ping -c 1 www.baidu.com | head -n 2
}

# Main Area
f0_internet
