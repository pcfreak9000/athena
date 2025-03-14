#!/bin/bash

MYNAME=AthenaPP_S40_$(date +"%Y-%m-%d_%H-%M-%S")

TIMELIMIT_RSTFILE=100000:00:00

ATHENA_CONFIG_FILE=athinput.master_project

if [ "$BINAC" ]; then
    WORKDIR=$WORK/$MYNAME
else
    WORKDIR=$(pwd)/Gartenzwerg/$MYNAME
fi
export ATHENABIN=$WORKDIR/athena
export WORKDIR
export ATHENA_CONFIG_FILE
export TIMELIMIT_RSTFILE

mkdir -p $WORKDIR
cp $ATHENA_CONFIG_FILE $WORKDIR/
cp startjob.sh $WORKDIR/
cp bin/athena $WORKDIR/


if [ "$BINAC" ]; then
    qsub -q short -l walltime=04:00:00 -l nodes=10:ppn=22 -l pmem=768mb -N $MYNAME -o $WORKDIR/LOG_ATHENA -v WORKDIR="$WORKDIR",ATHENA_CONFIG_FILE="$ATHENA_CONFIG_FILE",ATHENABIN="$ATHENABIN",TIMELIMIT_RSTFILE="$TIMELIMIT_RSTFILE" $WORKDIR/startjob.sh
else
    $WORKDIR/startjob.sh 2>&1 | tee $WORKDIR/LOG_ATHENA
fi
