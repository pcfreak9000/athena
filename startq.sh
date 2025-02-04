#!/bin/bash

MYNAME=$(date +"%Y-%m-%d_%H-%M-%S")

ATHENA_CONFIG_FILE=athinput.master_project

if [ "$BINAC" ]; then
    WORKDIR=$WORK/$MYNAME
else
    WORKDIR=$(pwd)/Gartenzwerg/$MYNAME
fi
export ATHENABIN=$(pwd)/bin/athena
export WORKDIR
export ATHENA_CONFIG_FILE
mkdir -p $WORKDIR
cp $ATHENA_CONFIG_FILE $WORKDIR/

if [ "$BINAC" ]; then
    qsub -q short -l walltime=00:20:00 -l nodes=2:ppn=8 -l pmem=768mb -N AthenaPP -o $WORKDIR/LOG_ATHENA -v WORKDIR=$WORKDIR -v ATHENA_CONFIG_FILE=$ATHENA_CONFIG_FILE -v ATHENABIN=$ATHENABIN startjob.sh
else
    ./startjob.sh 2>&1 | tee $WORKDIR/LOG_ATHENA
fi
