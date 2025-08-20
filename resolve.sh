#!/bin/bash
#use retrieve script (if dir is not existing...?)
binac_target_name="$1"
local_target_dir="$2"
minrange="$3"
maxrange="$4"
targetmdot=0.15
hstfileindex=13
if [ ! -d "$2" ]; then
    echo "Retrieving..."
    ./retrieve.sh "$1" "$2"
fi
echo "Preparing additional information..."
#calculate avg mdot using script in the appropriate range
avgmdot=$(vis/python/avg_csv.py --no-header -b "$local_target_dir"/hist.hst "$hstfileindex" $(("$minrange"+3)) $(("$maxrange"+3)))
#extract parameters from athinput
spin=$(grep -E '^\s*a\s*=' "$local_target_dir"/athinput | awk -F'=' '{print $2}' | awk '{print $1}')
x3min=$(grep -m1 -E '^\s*x3min\s*=' "$local_target_dir"/athinput | awk -F'=' '{print $2}' | awk '{print $1}')
x3max=$(grep -m1 -E '^\s*x3max\s*=' "$local_target_dir"/athinput | awk -F'=' '{print $2}' | awk '{print $1}')
echo "Spin: $spin"
echo "X3min: $x3min"
echo "X3max: $x3max"
echo "Avg mdot_code: $avgmdot"
#calculate surface shape
echo "Constructing shape..."
vis/python/extract_shape.py "$local_target_dir"/tavg.athdf "$local_target_dir"/dshape.csv "$spin" "$x3min" "$x3max" "$targetmdot" "$avgmdot"
#plot tavg.athdf rho --logc and maybe additional pngs?
echo "Generating additional plots..."
vis/python/plot_spherical.py "$local_target_dir"/tavg.athdf rho "$local_target_dir"/rho_tavg.png
vis/python/plot_spherical.py "$local_target_dir"/tavg.athdf rho --logc "$local_target_dir"/rho_tavg_log.png
echo "Done"
