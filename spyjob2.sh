#!/bin/bash

WORKDIR="${2%/}"
SCRIPT=$(pwd)/"$1"
SCRIPT_ARGS="${@:4}"
tasks="$3"




export WORKDIR
export SCRIPT
export SCRIPT_ARGS

myname=$(basename "$WORKDIR")
scriptname=$(basename "$SCRIPT")

if [ "$BINAC2" ]; then
    sbatch --partition compute -t 00:30:00 -N 1 --ntasks-per-node=$tasks --mem=32g -J "$scriptname"_"$myname" --output="$WORKDIR"/LOGO_"$scriptname" --error="$WORKDIR"/LOGE_"$scriptname" --export=ALL pyjob2.sh 
else
    eval "$SCRIPT" $SCRIPT_ARGS 2>&1 | tee "$WORKDIR"/LOG_"$scriptname"
fi
