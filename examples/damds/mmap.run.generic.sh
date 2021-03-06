#!/bin/bash

cp=$HOME/.m2/repository/com/google/guava/guava/15.0/guava-15.0.jar:$HOME/sali/software/jdk1.8.0/jre/../lib/tools.jar:$HOME/.m2/repository/commons-cli/commons-cli/1.2/commons-cli-1.2.jar:$HOME/.m2/repository/edu/indiana/soic/spidal/common/1.0/common-1.0.jar:$HOME/.m2/repository/habanero-java-lib/habanero-java-lib/0.1.4-SNAPSHOT/habanero-java-lib-0.1.4-SNAPSHOT.jar:$HOME/.m2/repository/net/java/dev/jna/jna/4.1.0/jna-4.1.0.jar:$HOME/.m2/repository/net/java/dev/jna/jna-platform/4.1.0/jna-platform-4.1.0.jar:$HOME/.m2/repository/net/openhft/affinity/3.0/affinity-3.0.jar:$HOME/.m2/repository/net/openhft/compiler/2.2.0/compiler-2.2.0.jar:$HOME/.m2/repository/net/openhft/lang/6.7.2/lang-6.7.2.jar:$HOME/.m2/repository/ompi/ompijavabinding/1.10.1/ompijavabinding-1.10.1.jar:$HOME/.m2/repository/org/kohsuke/jetbrains/annotations/9.0/annotations-9.0.jar:$HOME/.m2/repository/org/ow2/asm/asm/5.0.3/asm-5.0.3.jar:$HOME/.m2/repository/org/slf4j/slf4j-api/1.7.12/slf4j-api-1.7.12.jar:$HOME/.m2/repository/org/xerial/snappy/snappy-java/1.1.1.6/snappy-java-1.1.1.6.jar:$HOME/.m2/repository/edu/indiana/soic/spidal/damds/1.1/damds-1.1.jar

wd=$9
x='x'

cps=8
spn=1
cpn=$(($cps*$spn))

tpp=$1
ppn=$2
nodes=$6

mmaps=1
mmapdir=/dev/shm/$USER
commpat=$tpp$x$mmaps$x$nodes

memmultype=g
xmx=1
if [ "$5" ];then
    xmx=$5
    memmultype=$8
fi

bindToUnit=core
if [ $tpp -gt 1 ];then
    bindToUnit=none
fi

#if [ $ppn -gt $cpn ];then
#    bindToUnit=hwthread
#fi

pat=$tpp$x$ppn$x$nodes

TimingFile=$pat.$xmx.$memmultype.$4.$3.comm.$commpat.timing.txt
Alpha=0.85
StressThreshold=0.000001
StressIterations=1000
CGErrorThreshold=0.00001

MDS_OPS="-DTimingFile=$wd/$TimingFile -DAlpha=$Alpha -DThreshold=$StressThreshold -DStressIterations=$StressIterations -DCGErrorThreshold=$CGErrorThreshold"


gclog=$pat.Xmx.$xmx.gb.$4.$3.comm.$commpat.gc.log
#opts="-XX:+UseG1GC -Xms128m -Xmx"$xmx"$memmultype -Xloggc:$gclog -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
opts="-XX:+UseG1GC -Xms256m -Xmx"$xmx"$memmultype"

#sed -i "/5k.bin/c\DistanceMatrixFile=\\${wd}\/..\/data\/5k.bin" $wd/config.properties
echo "Running $pat on `date`" >> $wd/status.txt

$BUILD/bin/mpirun --hostfile $7 --report-bindings --map-by ppr:$ppn:node:SPAN  --bind-to $bindToUnit --rank-by core  -np $(($nodes*$ppn)) java $opts  $MDS_OPS -cp $cp edu.indiana.soic.spidal.damds.Program -c $wd/config.properties -n $nodes -t $tpp -mmaps $mmaps -mmapdir $mmapdir 2>&1 | tee $wd/$pat.$xmx.$memmultype.$4.$3.comm.$commpat.out.txt
echo "Finished $pat on `date`" >> $wd/status.txt

