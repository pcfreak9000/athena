#!/bin/bash

MYNAME="$1"
PLOT_ARGS="$2"


if [ "$BINAC" ]; then
    WORKDIR=$WORK/$MYNAME
else
    WORKDIR=$(pwd)/Gartenzwerg/$MYNAME
fi
export WORKDIR
export ATHENA_GIT_DIR=$(pwd)
export PLOT_ARGS

cp moviejob.sh $WORKDIR/
cp create_movie.sh $WORKDIR/


if [ "$BINAC" ]; then
    qsub -q tiny -l walltime=00:20:00 -l nodes=1:ppn=24 -l mem=12gb -N MOV_$MYNAME -o $WORKDIR/LOG_MOVIE -v WORKDIR="$WORKDIR",ATHENA_GIT_DIR="$ATHENA_GIT_DIR",PLOT_ARGS="$PLOT_ARGS" $WORKDIR/moviejob.sh
else
    $WORKDIR/moviejob.sh 2>&1 | tee $WORKDIR/LOG_MOVIE
fi
