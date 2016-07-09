#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please provide the path to nodes file"
else
  install_ifne(){
    pkg=$1
    if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
      sudo apt-get install $pkg;
    fi
  }
  
  NODE_FILE=$1
  sudo sed -i "1i 127.0.0.1 $HOSTNAME" /etc/hosts
  install_ifne pdsh
  sudo bash -c 'echo ssh > /etc/pdsh/rcmd_default'

  SCRIPT=~/setup_internal.sh

  pdsh -w ^$NODE_FILE $SCRIPT
  
fi

