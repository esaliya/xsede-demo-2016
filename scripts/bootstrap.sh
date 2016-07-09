#!/bin/bash

install_ifne(){
  pkg=$1
  if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo apt-get install $pkg;
  fi
}

if [ -z "$1" ]
  then
    echo "Please provide the path to nodes file"
else
  DEMO_NAME=xsede-demo-2016
  NODE_FILE=$1
  MASTER=`cat $NODE_FILE | head -1 $NODEFILE`
  
  install_ifne unzip
  cd ~/
  wget https://github.com/esaliya/xsede-demo-2016/archive/master.zip
  unzip master.zip
  mv "$DEMO_NAME"-master $DEMO_NAME
  rm -rf master.zip
  chmod +x $DEMO_NAME/scripts/*.sh

  sudo sed -i "1i 127.0.0.1 $HOSTNAME" /etc/hosts
  install_ifne pdsh
  sudo bash -c 'echo ssh > /etc/pdsh/rcmd_default'
  SCRIPT=~/$DEMO_NAME/scripts/setup_internal.sh
  pdsh -w ^$NODE_FILE scp -r $MASTER:~/$DEMO_NAME ~/
#  pdsh -w ^$NODE_FILE $SCRIPT
#  pdsh -w ^$NODE_FILE rm $SCRIPT
fi