#!/bin/bash

binac_target_dir="$1" #name of directory
local_target_dir="$2" #absolute path

binac_work=$(ssh -p 2223 binac2 'echo $WORK')

if [ -z "$binac_work" ]; then
    echo "something is wrong"
    exit 1
fi
if [ -z "$binac_target_dir" ]; then
    echo "name of binac target dir missing"
    exit 1
fi
if [ -z "$local_target_dir" ]; then
    echo "local target dir path is missing"
    exit 1
fi

mkdir -p "$local_target_dir"


function copy() {
    scp -P 2223 binac2:"$binac_work"/"$binac_target_dir"/"$1" "$local_target_dir"/"$2"
    if [ $? -ne 0 ]; then
        if [ "$3" = "" ]; then
            echo "problem with scp"
            exit 1
        else
            echo "Ignoring error with scp..."
        fi
    fi
}
copy "simout/master_project.prim.00000.athdf" "initial_conditions.athdf"
copy "simout/master_project.hst" "hist.hst"
copy "out.mp4" "out.mp4"
copy "out_log.mp4" "out_log.mp4"
copy "q1.mp4" "q1.mp4"
copy "q2.mp4" "q2.mp4"
copy "tavg.athdf" "tavg.athdf"
copy "savg.csv" "savg.csv"
copy "ii.mp4" "ii.mp4"
copy "ii_log.mp4" "ii_log.mp4"
copy "LOG_ATHENA" "LOG_ATHENA"
copy "athinput.pp_master_project" "athinput"
copy "mdot.csv" "mdot_deprecated.csv"

copy "analimits" "analimits" ignoreerrors
