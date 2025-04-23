#!/bin/bash

wt="$2"
nodes="$3"
ppn="$4"

MYNAME="$1"_$(date +"%Y-%m-%d_%H-%M-%S")

#echo $MYNAME
#echo $queue
#echo $wt
#echo $nodes
#echo $ppn

TIMELIMIT_RSTFILE=100000:00:00

ATHENA_CONFIG_FILE=athinput.master_project

if [ "$BINAC2" ]; then
    WORKDIR="$WORK"/"$MYNAME"
else
    WORKDIR="$(pwd)"/Gartenzwerg/"$MYNAME"
fi
export ATHENABIN="$WORKDIR"/athena
export WORKDIR
export ATHENA_CONFIG_FILE
export TIMELIMIT_RSTFILE

mkdir -p "$WORKDIR"
cp "$ATHENA_CONFIG_FILE" "$WORKDIR"/
cp startjob2.sh "$WORKDIR"/
cp bin/athena "$WORKDIR"/


if [ "$BINAC2" ]; then
    sbatch --constraint=ib --partition compute -t $wt -N $nodes --ntasks-per-node=$ppn --cpus-per-task 2 --mem-per-cpu=1gb -J "$MYNAME" --output="$WORKDIR"/LOG_ATHENA --error="$WORKDIR"/LOG_ATHENA --export=ALL "$WORKDIR"/startjob2.sh
else
    "$WORKDIR"/startjob2.sh 2>&1 | tee "$WORKDIR"/LOG_ATHENA
fi
