```bash
FOLDER=RHCI

function git_clone {
  git clone https://github.com/suzhen99/$FOLDER
}

cd $FOLDER
git add *.sh
git commit -m "chmod +x *.sh"
git push
```
