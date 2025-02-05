#!/bin/bash

MYNAME=$(date +"%Y-%m-%d_%H-%M-%S")_vl2

ATHENA_CONFIG_FILE=athinput.master_project

if [ "$BINAC" ]; then
    WORKDIR=$WORK/$MYNAME
else
    WORKDIR=$(pwd)/Gartenzwerg/$MYNAME
fi
export ATHENABIN=$WORKDIR/athena
export WORKDIR
export ATHENA_CONFIG_FILE

mkdir -p $WORKDIR
cp $ATHENA_CONFIG_FILE $WORKDIR/
cp startjob.sh $WORKDIR/
cp bin/athena $WORKDIR/


if [ "$BINAC" ]; then
    qsub -q short -l walltime=02:00:00 -l nodes=1:ppn=16 -l pmem=768mb -N AthenaPPvl2 -o $WORKDIR/LOG_ATHENA -v WORKDIR="$WORKDIR",ATHENA_CONFIG_FILE="$ATHENA_CONFIG_FILE",ATHENABIN="$ATHENABIN" $WORKDIR/startjob.sh
else
    $WORKDIR/startjob.sh 2>&1 | tee $WORKDIR/LOG_ATHENA
fi
