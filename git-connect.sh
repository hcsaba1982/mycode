#! /bin/bash
#
# Create your Personal Access Token. Complete the following tasks:
#
# 1 Click on the tiny round icon in the upper right corner
# 2 Click Settings on the dropdown
# 3 Click Developer settings on the bottom of the left menu
# 4 Click Personal access tokens
# 5 Click Tokens (classic)
# 6 Click Generate new token
# 7 Click Generate new token (classic)
# 8 Title the key to "tmux access to github"
# 9 Check the box for repo
# 10 Check the box for admin:public_key
# 11 Click the green Generate token button at the bottom
# 12 AT THE TOP OF THE PAGE, COPY THE NEWLY GENERATED TOKEN TO YOUR CLIPBOARD
#
# export TOKEN=XXXXXXXXX
#
# export USERNAME=XXXXXXXXX
#
# export EMAIL=XXXXXXXXX
#
# wget https://labs.alta3.com/courses/github/scripts/git-connect.sh
#
# bash ~/git-connect.sh



if [ -f "~/.ssh/id_rsa_github" ]
then
  echo "rsa key exists, moving on"
else
  ssh-keygen -f ~/.ssh/id_rsa_github -q -N ""
fi

if [ -z "${USERNAME}" ]
then
  echo "USERNAME not defined"
  exit
fi

if [ -z "${EMAIL}" ]
then
  echo "EMAIL not defined"
  exit
fi

git config --global user.name $USERNAME
git config --global user.email $EMAIL
export SSH_TMUX_KEY=`cat ~/.ssh/id_rsa_github.pub`

echo "USERNAME = $USERNAME"
echo "EMAIL = $EMAIL"
echo "SSH_TMUX_KEY = $SSH_TMUX_KEY"

mkdir -p ~/mycode
cd ~/mycode

if [ "$(ls -A ~/mycode)" ]
then
  echo "Your ~/mycode directory is not empty, cowardly refusing to continue!"
  exit
else
  echo "~/mycode is empty, Excellent!"
fi

echo $TOKEN
if [ -z "${TOKEN}" ]
then
  echo "TOKEN not defined"
  exit
fi
curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $TOKEN" https://api.github.com/user/repos -d '{"name":"mycode","description":"This is your first repo"}'
curl -X POST -H "Accept: application/vnd.github+json"   -H "Authorization: Bearer $TOKEN"   https://api.github.com/repos/$USERNAME/mycode/keys   -d '{"title":"tmux_key","key":"'"$SSH_TMUX_KEY"'","read_only":false}'

cd ~/mycode
git clone git@github.com:$USERNAME/mycode.git ~/mycode
touch $USERNAME.md
cat <<EOF >> ~/mycode/.gitignore
echo "*.log" >> ~/mycode/.gitignore
echo "*.key" >> ~/mycode/.gitignore
echo "id_rsa*" >> ~/mycode/.gitignore
EOF
git add *
git commit -m "my first commit"
git push origin HEAD
