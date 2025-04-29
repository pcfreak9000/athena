#!/bin/bash

WORKDIR = "$1"
myname = $(basename "$WORKDIR")

export $WORKDIR

if [ "$BINAC2" ]; then
    sbatch --partition compute -t 2:00:00 -N 1 --ntasks-per-node=1 --mem=32g -J AVG_$myname --output="$WORKDIR"/LOG_AVG -error="$WORKDIR"/LOG_AVG --export=ALL "$HOME"/athena/averagejob2.sh
else
    ./averagejob2.sh 2>&1 | tee "$WORKDIR"/LOG_AVG
fi
