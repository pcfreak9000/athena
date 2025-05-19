#!/bin/bash

WORKDIR="$1"
WORKDIR="${WORKDIR%/}"
PLOT_OPTIONS="$2"
MYNAME=$(basename "$WORKDIR")
MNAME="$3"

export MNAME
export WORKDIR
export ATHENA_GIT_DIR=$(pwd)
export PLOT_OPTIONS

cp moviejob2.sh $WORKDIR/
cp create_movie.sh $WORKDIR/


if [ "$BINAC2" ]; then
    sbatch --partition compute -t 20:00 -N 1 --ntasks-per-node=32 --mem=16g -J MOV_$MYNAME --output="$WORKDIR"/LOG_MOVIE --error="$WORKDIR"/LOG_MOVIE --export=ALL "$WORKDIR"/moviejob2.sh
    #qsub -q tiny -l walltime=00:20:00 -l nodes=1:ppn=24 -l mem=12gb -N MOV_$MYNAME -o $WORKDIR/LOG_MOVIE -v WORKDIR="$WORKDIR",ATHENA_GIT_DIR="$ATHENA_GIT_DIR",PLOT_OPTIONS="$PLOT_OPTIONS" $WORKDIR/moviejob2.sh
else
    $WORKDIR/moviejob2.sh 2>&1 | tee $WORKDIR/LOG_MOVIE
fi
