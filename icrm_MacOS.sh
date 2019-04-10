#!/bin/bash

# Install wget using BREW
brew install wget

# Install PIP using the get-pip.py script
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

# Install follow three using PIP
sudo pip install pyyaml==3.11
sudo pip install pyreadline==2.0
sudo pip install requests==2.3.0

# Extract icrm
wget https://github.com/suzhen99/RHCI/raw/master/icrm-1.0.7-2.el7.noarch.rpm
rpm2cpio icrm-1.0.7-2.el7.noarch.rpm | cpio -dium

# Run the download manager using __init__.py in the icrm directory
cd usr/lib/python2.7/site-packages/icrm
python __init__.py
