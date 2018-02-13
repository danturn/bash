#!/bin/bash

function install_sudo {
  if ! dpkg -s sudo > /dev/null; then
    echo "Installing sudo... enter the root password:"
    su -c "apt-get install sudo
    adduser `whoami` sudo"
    newgrp sudo
  fi
}


function install_tools {
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
  sudo apt-get update -y
  sudo apt-get install esl-erlang elixir git curl tmux build-essential -y
}

function configure_vim {
  mkdir -p ~/src
  cd ~/src/ 
  git clone https://github.com/danturn/vimrc.git
  ./vimrc/setup_dotfiles.sh
  cd -
}

function setup_ssh {
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
}

function install_phoenix_with_node_6 {
  mix local.hex --force
  mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez --force
  sudo apt-get update
  sudo apt-get install inotify-tools -y
  sudo apt-get install curl -y
  curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

function install_postgress {
  sudo apt-get install postgresql postgresql-client -y
}

function configure_postgress {
  sudo service postgresql start
  sudo -u postgres psql -c "alter user postgres with password 'postgres';"
}

install_sudo
install_tools
configure_vim
setup_ssh
install_phoenix_with_node_6
install_postgress
configure_postgress

