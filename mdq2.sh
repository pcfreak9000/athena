#!/bin/bash

BH_SPIN="$2"
WORKDIR="$1"
WORKDIR="${WORKDIR%/}"
myname=$(basename "$WORKDIR")

export WORKDIR
export BH_SPIN

#echo "$WORKDIR"

if [ "$BINAC2" ]; then
    sbatch --partition compute -t 2:00:00 -N 1 --ntasks-per-node=64 --mem=32g -J MDOT_"$myname" --output="$WORKDIR"/LOG_MDOT --error="$WORKDIR"/LOG_MDOT --export=ALL "$HOME"/athena/mdotjob2.sh
else
    ./mdotjob2.sh 2>&1 | tee "$WORKDIR"/LOG_MDOT
fi
