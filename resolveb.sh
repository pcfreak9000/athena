#!/bin/bash
#use retrieve script (if dir is not existing...?)
local_target_dir="$1"
minrange="$2"
maxrange="$3"
hstfileindex=13

exshape () {
    $HOME/athena/vis/python/extract_shape.py "$local_target_dir"/tavg.athdf "$local_target_dir"/dshape"$1$2".csv "$spin" "$x3min" "$x3max" "$1" "$avgmdot" $2
}


echo "Preparing additional information..."
#calculate avg mdot using script in the appropriate range
avgmdot=$($HOME/athena/vis/python/avg_csv.py --no-header -b "$local_target_dir"/simout/master_project.hst "$hstfileindex" $(("$minrange"+3)) $(("$maxrange"+3)))
#extract parameters from athinput
spin=$(grep -E '^\s*a\s*=' "$local_target_dir"/athinput* | awk -F'=' '{print $2}' | awk '{print $1}')
x3min=$(grep -m1 -E '^\s*x3min\s*=' "$local_target_dir"/athinput* | awk -F'=' '{print $2}' | awk '{print $1}')
x3max=$(grep -m1 -E '^\s*x3max\s*=' "$local_target_dir"/athinput* | awk -F'=' '{print $2}' | awk '{print $1}')
x1max=$(grep -m1 -E '^\s*x1max\s*=' "$local_target_dir"/athinput* | awk -F'=' '{print $2}' | awk '{print $1}')
echo "Spin: $spin"
echo "X1max: $x1max"
echo "X3min: $x3min"
echo "X3max: $x3max"
echo "Avg mdot_code: $avgmdot"
#calculate surface shape
echo "Constructing shape(s)..."
exshape 0.5
exshape 0.3
exshape 0.2
exshape 0.1
exshape 0.02
exshape 0.01
echo "Done."
