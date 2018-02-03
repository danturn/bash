#!/bin/bash
if ! dpkg -s sudo > /dev/null; then
  echo "Installing sudo... enter the root password:"
  su -c "apt-get install sudo
         adduser `whoami` sudo"
  $newgrp sudo
fi
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update -y
sudo apt-get install esl-erlang elixir git curl tmux -y
cd ~/src/ 
git clone https://github.com/danturn/vimrc.git
./vimrc/setup_dotfiles.sh
if [ ! -f ~/.ssh/id_rsa ]; then
  mkdir -p ~/.ssh
  ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_rsa
  echo "Adding to github account... what's your username:"
  read git_username

  response=$(curl -u "$git_username" \
                  -sS \
                  -w 'httpcode=%{http_code}\n' \
                  --data "{\"title\":\"`hostname`-key\",\"key\":\"`cat ~/.ssh/id_rsa.pub`\"}" \
                  https://api.github.com/user/keys)
  httpCode=$(echo "${response}" | sed -n 's/^.*httpcode=//p')
  if [ "$httpCode" -ne 201 ]; then
    echo "Unable to add public key to your github account..."
    echo $response
  fi
fi
