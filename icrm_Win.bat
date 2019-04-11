@ECHO OFF

SET Course_Name=CL210
SET Course_Dir="D:\INSTRUCTOR"
SET GIT_CMD="C:\Program Files\Git\bin\git.exe"


ECHO Install follow three using PIP
pip install pyyaml==3.11 -q
pip install pyreadline==2.0 -q
pip install requests -q
pip install lxml -q

ECHO git icrm
SET PATH=%PATH%;"%ProgramFiles%\Git\bin"
git init RHCI && cd RHCI
git config core.sparsecheckout true
echo 'icrm*' >> .git/info/sparse-checkout
git remote add origin https://github.com/suzhen99/RHCI.git
git pull origin master

ECHO extract icrm
SET PATH=%PATH%;"C:\Program Files\7-Zip"
7z e icrm-1.0.7-2.el7.noarch.rpm
7z x icrm-1.0.7-2.el7.noarch.cpio -y

ECHO Prepare bin and config
python usr\lib\python2.7\site-packages\icrm\__init__.py help > NULL
echo --- > ..\.icrm\config.yml
echo repository: %Course_Dir%\%Course_Name% >> ../.icrm/config.yml

ECHO Run icrm
python usr\lib\python2.7\site-packages\icrm\__init__.py search %Course_Name%
