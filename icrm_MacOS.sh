#!/bin/bash

Course_Name=CL210
Course_Dir="/Volumes/DATA 1/INSTRUCTOR"

# Install wget using BREW
brew install wget

# Install PIP using the get-pip.py script
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

# Install follow three using PIP
sudo pip install pyyaml==3.11
sudo pip install pyreadline==2.0
sudo pip install requests
sudo pip install lxml

# Extract icrm
wget https://github.com/suzhen99/RHCI/raw/master/icrm-1.0.7-2.el7.noarch.rpm
rpm2cpio icrm-1.0.7-2.el7.noarch.rpm | cpio -dium

# Prepare bin
sudo ln -s /usr/bin/python2.7 /usr/bin/python2
sudo cp -r usr/lib/python2.7/site-packages/icrm /usr/lib/python2.7
sudo cp usr/bin/icrm /usr/local/bin

# Prepare config
icrm help >/dev/null
Course_DN=$(ls -d "${Course_Dir}"/${Course_Name}*)
sed -ie "/repository/s|:.*|: ${Course_DN}|" ~/.icrm/config.yml

# Run icrm
icrm search ${Course_Name}
