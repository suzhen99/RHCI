```bash
FOLDER=RHCI

function nets {
  if ! ping -c 1 ${SI} &>/dev/null; then
    echo -e "INFO\tPlease connect to INTERNET."
    exit
  fi
}

function git_install {
  if ! rpm -q git &>/dev/null; then
    yum -y install git &>/dev/null
  fi
}

function git_clone {
  if [ ! -d $FOLDER/.git ]; then
    git clone https://github.com/suzhen99/$FOLDER
    cd $FOLDER
  fi
}

function git_config {
  if ! git config --list | grep -q adder99; then
    git config --global push.default simple
    git config user.name 'suzhen99'
    git config user.email 'adder99@163.com'
  fi
}

function git_push {
  read -p "Please input File Name: " FILEN
  read -p "Please input Commit Message: " FILEM
  git add ${FILEN}
  git commit -m "${FILEM}"
  git push
}

# Main area
git_install
git_clone
git_push

```
