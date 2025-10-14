#!/bin/bash

file="$1"
maxf="$3"
minf="$2"


athfile="$file/athinput.pp_master_project"
spin=$(grep -E "^\s*a\s*=" "$athfile" | awk -F'=' '{print $2}' | awk '{print $1}')

refenabled=$(grep -m1 -E '^\s*refinement\s*=' "$athfile" | awk -F'=' '{print $2}' | awk '{print $1}')
lvlmax=$(grep -E '^\s*level\s*=' "$athfile" \
    | awk -F'=' '{print $2}' \
    | awk '{print $1}' \
    | sort -nr | head -1)

if [ "$refenabled" = "none" ]; then
    lvlvar=0
else
    lvlvar=$lvlmax
fi

./movieq2.sh "$file" "q1 --vmin=0.0 --vmax=12.0 --abs" "q1"
./movieq2.sh "$file" "q2 --vmin=0.0 --vmax=12.0 --abs" "q2"
#./mov3eq2.sh "$file" "q3 --vmin=0.0 --vmax=24.0 --abs" "q3"
./movieq2.sh "$file" "rho --vmin=0.0 --vmax=1.0"
./movieq2.sh "$file" "rho --vmin=0.0 --vmax=1.0 -r 10" "ii"
./movieq2.sh "$file" "rho --logc" "out_log"
./movieq2.sh "$file" "rho --logc -r 10" "ii_log"
./spyjob2.sh vis/python/mdot.py "$file" 64 00:20:00 '$WORKDIR/simout/master_project.prim $WORKDIR/mdot.csv' "$minf $maxf 1" "$spin"
./spyjob2.sh vis/python/timeaverage.py "$file" 1 3:00:00 '$WORKDIR/simout/master_project.prim $WORKDIR/tavg.athdf' "$minf $maxf 1 --nanzero -q rho u0 u1 u2 u3 q1 q2 q3"
./spyjob2.sh vis/python/spaceaverage.py "$file" 64 00:30:00 '$WORKDIR/simout/master_project.prim $WORKDIR/savg.csv' "0 $maxf 1 --lvl=$lvlvar --max=20 -q q1 q2 q3"
