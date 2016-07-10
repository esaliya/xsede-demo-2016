#!/bin/bash

install_ifne(){
  pkg=$1
  if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo apt-get install $pkg;
  fi
}

download_repo(){
  DEMO_NAME=$1
  
  cd ~/
  rm -rf $DEMO_NAME
  wget https://github.com/esaliya/xsede-demo-2016/archive/master.zip
  unzip master.zip
  mv "$DEMO_NAME"-master $DEMO_NAME
  rm -rf master.zip
  sed -i "/5k.bin/c\DistanceMatrixFile=\\${HOME}\/\\${DEMO_NAME}\/examples\/data\/5k.bin" $HOME/$DEMO_NAME/examples/damds/config.properties
  sed -i "/damds-points.txt/c\PointsFile=\\${HOME}\/\\${DEMO_NAME}\/examples\/damds\/damds-points.txt" $HOME/$DEMO_NAME/examples/damds/config.properties
}

setup(){
  DEMO_NAME=$1
  NODE_FILE=$2
  MASTER=$3

  SCRIPT=~/$DEMO_NAME/scripts/setup_internal.sh
  pdsh -w ^$NODE_FILE scp $MASTER:$NODE_FILE $NODE_FILE
  pdsh -w ^$NODE_FILE scp -r $MASTER:~/$DEMO_NAME ~/
  pdsh -w ^$NODE_FILE chmod +x $DEMO_NAME/scripts/*.sh
  pdsh -w ^$NODE_FILE $SCRIPT

}


if [ -z "$1" ]
  then
    echo "Please provide the path to nodes file"
else
  DEMO_NAME=xsede-demo-2016
  NODE_FILE=$1
  MASTER=`cat $NODE_FILE | head -1 $NODEFILE`

  sudo sed -i "1i 127.0.0.1 $HOSTNAME" /etc/hosts
  install_ifne unzip
  install_ifne pdsh
  sudo bash -c 'echo ssh > /etc/pdsh/rcmd_default'

  sleep 2
  download_repo $DEMO_NAME

  sleep 2
  setup $DEMO_NAME $NODE_FILE $MASTER
fi
