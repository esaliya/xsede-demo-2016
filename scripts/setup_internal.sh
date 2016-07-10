#!/bin/bash

install_ifne(){
  pkg=$1
  if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo apt-get -y install $pkg;
  fi
}
install_ifne build-essential
install_ifne unzip


SFT_DIR=~/software

BUILD_DIR_NAME=build
SPIDAL_DIR_NAME=spidal
BASHRC=~/.bashrc

mkdir -p $SFT_DIR/{$BUILD_DIR_NAME,$SPIDAL_DIR_NAME}
sleep 1
cd $SFT_DIR
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.tar.gz
wget http://ftp.wayne.edu/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
wget http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.1.tar.gz

tar -xzf jdk-8u91-linux-x64.tar.gz
tar -xzf apache-maven-3.3.9-bin.tar.gz
tar -xzf openmpi-1.10.1.tar.gz
sed -i '1i export LD_LIBRARY_PATH=$BUILD/lib:$LD_LIBRARY_PATH' $BASHRC
sed -i '1i export PATH=$JAVA_HOME/bin:$MVN_HOME/bin:$BUILD/bin:$PATH' $BASHRC
sed -i '1i export BUILD=$SFT_DIR/$BUILD_DIR_NAME' $BASHRC
sed -i '1i export OMPI_HOME=$SFT_DIR/openmpi-1.10.1' $BASHRC
sed -i '1i export MVN_HOME=$SFT_DIR/apache-maven-3.3.9' $BASHRC
sed -i '1i export JAVA_HOME=$SFT_DIR/jdk1.8.0_91' $BASHRC
sed -i "1i export SFT_DIR=$SFT_DIR" $BASHRC
sed -i "1i export BUILD_DIR_NAME=$BUILD_DIR_NAME" $BASHRC
sed -i "1i export SPIDAL_DIR_NAME=$SPIDAL_DIR_NAME" $BASHRC

source $BASHRC
sleep 2
cd $OMPI_HOME
./configure --prefix=$BUILD --enable-mpi-java
make j 8;make install
mvn install:install-file -DcreateChecksum=true -Dpackaging=jar -Dfile=$OMPI_HOME/ompi/mpi/java/java/mpi.jar -DgroupId=ompi -DartifactId=ompijavabinding -Dversion=1.10.1

cd $SFT_DIR/$SPIDAL_DIR_NAME
DAMDS_NAME=damds
COMMON_NAME=common
MASTER_NAME=master
wget https://github.com/DSC-SPIDAL/damds/archive/master.zip
mv "$MASTER_NAME".zip "$DAMDS_NAME".zip
unzip "$DAMDS_NAME".zip
mv "$DAMDS_NAME"-"$MASTER_NAME" "$DAMDS_NAME"
wget https://github.com/DSC-SPIDAL/common/archive/master.zip
mv "$MASTER_NAME".zip "$COMMON_NAME".zip
unzip "$COMMON_NAME".zip
mv "$COMMON_NAME"-"$MASTER_NAME" "$COMMON_NAME"

cd $COMMON_NAME
mvn install
cd ../$DAMDS_NAME
mvn install

