#!/bin/bash
pd=$(dirname $0)
nodes=$2
name="$nodes"n
nodefile=$1

$pd/mmap.run.generic.sh 1 8 $name xsede.2016.demo 1 $nodes $nodefile g $pd

cd $pd/../../utils
mvn install
cp=$HOME/.m2/repository/com/google/guava/guava/19.0/guava-19.0.jar:$HOME/.m2/repository/edu/indiana/soic/spidal/xsede/utils/1.0/utils-1.0.jar

java -cp $cp edu.indiana.soic.spidal.xsede.utils.PvizBuilder $pd/damds-points.txt $HOME 5000 3 
