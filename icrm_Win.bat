@ECHO OFF

ECHO Please install Python2.7 and git
SET Course_Name=CL210
SET Course_Dir=D:\INSTRUCTOR
SET PATH="%PATH%;%ProgramFiles%\Git\bin;%ProgramFiles%\7-Zip"
SETX /m path "C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;%ProgramFiles%\Git\bin;%ProgramFiles%\7-Zip"

ECHO Install follow three using PIP
pip install pyyaml==3.11 -q
pip install pyreadline==2.0 -q
pip install requests -q
pip install lxml -q

ECHO git icrm
git init RHCI && cd RHCI
git config core.sparsecheckout true
echo icrm*rpm >> .git/info/sparse-checkout
git remote add origin https://github.com/suzhen99/RHCI.git
git pull origin master

ECHO extract icrm
7z e icrm-1.0.7-2.el7.noarch.rpm
7z x icrm-1.0.7-2.el7.noarch.cpio -y

ECHO Prepare bin and config
python usr\lib\python2.7\site-packages\icrm\__init__.py help > NULL

for /F %%i in ('dir /d /b %Course_Dir%\%Course_Name%*') do (set CNF=%%i)
echo --- > %USERPROFILE%\.icrm\config.yml
echo repository: %Course_Dir%\%CNF% >> %USERPROFILE%\.icrm\config.yml

ECHO Run icrm
python usr\lib\python2.7\site-packages\icrm\__init__.py search %Course_Name%
