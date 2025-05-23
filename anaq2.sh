#!/bin/bash

file="$1"
#spin="$2"
maxf="$3"
minf="$2"


athfile="$file/athinput.pp_master_project"
spin=$(grep -E "^\s*a\s*=" "$athfile" | awk -F'=' '{print $2}' | awk '{print $1}')

./movieq2.sh "$file" "q1 --vmin=0.0 --vmax=12.0 --abs" "q1"
./movieq2.sh "$file" "q2 --vmin=0.0 --vmax=12.0 --abs" "q2"
#./mov3eq2.sh "$file" "q3 --vmin=0.0 --vmax=24.0 --abs" "q3"
./movi2q2.sh "$file" "rho --vmin=0.0 --vmax=1.0"
./spyjob2.sh vis/python/mdot.py "$file" 64 '$WORKDIR/simout/master_project.prim $WORKDIR/mdot.csv' "$minf $maxf 1" "$spin"
./spyjob2.sh vis/python/timeaverage.py "$file" 1 '$WORKDIR/simout/master_project.prim $WORKDIR/tavg.athdf' "$minf $maxf 1"
./spyjob2.sh vis/python/spaceaverage.py "$file" 64 '$WORKDIR/simout/master_project.prim $WORKDIR/savg.csv' "$minf $maxf 1 --lvl=2 --max=20 -q q1 -q q2 -q q3"
