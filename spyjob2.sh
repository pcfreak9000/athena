#!/bin/bash

WORKDIR="${2%/}"
SCRIPT=$(pwd)/"$1"
SCRIPT_ARGS="${@:5}"
tasks="$3"
time="$4"




export WORKDIR
export SCRIPT
export SCRIPT_ARGS

myname=$(basename "$WORKDIR")
scriptname=$(basename "$SCRIPT")

if [ "$BINAC2" ]; then
    sbatch --partition compute -t "$time" -N 1 --ntasks-per-node=$tasks --mem=32g -J "$scriptname"_"$myname" --output="$WORKDIR"/LOG_"$scriptname" --error="$WORKDIR"/LOG_"$scriptname" --export=ALL "$HOME"/athena/pyjob2.sh 
else
    eval "$SCRIPT" $SCRIPT_ARGS 2>&1 | tee "$WORKDIR"/LOG_"$scriptname"
fi
