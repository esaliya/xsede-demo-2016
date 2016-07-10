#!/bin/bash
pd=$(dirname $0)
nodes=$2
name="$nodes"n
nodefile=$1

$pd/mmap.run.generic.sh 1 8 $name xsede.2016.demo 1 $nodes $nodefile g $pd

cd $pd/../../utils
mvn install

