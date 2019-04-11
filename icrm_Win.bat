@ECHO OFF

SET Course_Name=CL210
SET Course_Dir="D:\INSTRUCTOR"
SET GIT_CMD="C:\Program Files\Git\bin\git.exe"


# Install follow three using PIP
pip install pyyaml==3.11 -q
pip install pyreadline==2.0 -q
pip install requests -q
pip install lxml -q

# Extract icrm
%GIT_CMD% init RHCI && cd RHCI
%GIT_CMD% config core.sparsecheckout true
echo 'tt*' >> .git/info/sparse-checkout
%GIT_CMD% remote add origin git@github.com:mygithub/test.git
%GIT_CMD% pull origin master

wget https://github.com/suzhen99/RHCI/raw/master/icrm-1.0.7-2.el7.noarch.rpm
rpm2cpio icrm-1.0.7-2.el7.noarch.rpm | cpio -dium

# Prepare bin
sudo ln -s /usr/bin/python2.7 /usr/bin/python2
sudo cp -r usr/lib/python2.7/site-packages/icrm /usr/lib/python2.7
sudo sed -ie '/setterm/s|".*"|"echo"|' /usr/lib/python2.7/icrm/__init__.py
sudo cp usr/bin/icrm /usr/local/bin

# Prepare config
icrm help >/dev/null
Course_DN=$(ls -d "${Course_Dir}"/${Course_Name}*)
sed -ie "/repository/s|:.*|: ${Course_DN}|" ~/.icrm/config.yml

# Run icrm
icrm search ${Course_Name}
