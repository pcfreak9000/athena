#!/bin/bash

MYNAME=AthenaPP_S21_2025-02-09_21-59-28


if [ "$BINAC" ]; then
    WORKDIR=$WORK/$MYNAME
else
    WORKDIR=$(pwd)/Gartenzwerg/$MYNAME
fi
export WORKDIR
export ATHENA_GIT_DIR=$(pwd)

cp moviejobn.sh $WORKDIR/
cp create_movie.sh $WORKDIR/


if [ "$BINAC" ]; then
    qsub -q tiny -l walltime=00:20:00 -l nodes=1:ppn=20 -l mem=10gb -N MOV_$MYNAME -o $WORKDIR/LOG_MOVIE -v WORKDIR="$WORKDIR",ATHENA_GIT_DIR="$ATHENA_GIT_DIR" $WORKDIR/moviejobn.sh
else
    $WORKDIR/moviejobn.sh 2>&1 | tee $WORKDIR/LOG_MOVIE
fi
