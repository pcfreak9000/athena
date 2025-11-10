#!/bin/bash
#use retrieve script (if dir is not existing...?)
binac_target_name="$1"
local_target_dir="$2"
minrange="$3"
maxrange="$4"
hstfileindex=13
if [ ! -d "$2" ]; then
    echo "Retrieving..."
    ./retrieve.sh "$1" "$2"
fi

exshape () {
    vis/python/extract_shape.py "$local_target_dir"/tavg.athdf "$local_target_dir"/dshape"$1$2".csv "$spin" "$x3min" "$x3max" "$1" "$avgmdot" $2
}


echo "Preparing additional information..."
#calculate avg mdot using script in the appropriate range
avgmdot=$(vis/python/avg_csv.py --no-header -b "$local_target_dir"/hist.hst "$hstfileindex" $(("$minrange"+3)) $(("$maxrange"+3)))
#extract parameters from athinput
spin=$(grep -E '^\s*a\s*=' "$local_target_dir"/athinput | awk -F'=' '{print $2}' | awk '{print $1}')
x3min=$(grep -m1 -E '^\s*x3min\s*=' "$local_target_dir"/athinput | awk -F'=' '{print $2}' | awk '{print $1}')
x3max=$(grep -m1 -E '^\s*x3max\s*=' "$local_target_dir"/athinput | awk -F'=' '{print $2}' | awk '{print $1}')
x1max=$(grep -m1 -E '^\s*x1max\s*=' "$local_target_dir"/athinput | awk -F'=' '{print $2}' | awk '{print $1}')
echo "Spin: $spin"
echo "X1max: $x1max"
echo "X3min: $x3min"
echo "X3max: $x3max"
echo "Avg mdot_code: $avgmdot"
#calculate surface shape
echo "Constructing shape(s)..."
exshape 0.3 -v
exshape 0.3
exshape 0.2 -v
exshape 0.2
exshape 0.1 -v
exshape 0.1
exshape 0.02 -v
exshape 0.02
exshape 0.01 -v
exshape 0.01
exshape 0.9 -v
#plot tavg.athdf rho --logc and maybe additional pngs?
echo "Generating additional plots..."
vis/python/plot_spherical.py "$local_target_dir"/tavg.athdf rho --colormap=jet "$local_target_dir"/rho_tavg.png
vis/python/plot_spherical.py "$local_target_dir"/tavg.athdf rho --colormap=jet --logc "$local_target_dir"/rho_tavg_log.png
vis/python/plot_spherical.py "$local_target_dir"/tavg.athdf q1 --vmin=0.0 --vmax=12.0 --colormap=seismic --abs "$local_target_dir"/q1_tavg.png
vis/python/plot_spherical.py "$local_target_dir"/tavg.athdf q2 --vmin=0.0 --vmax=12.0 --colormap=seismic --abs "$local_target_dir"/q2_tavg.png
cd "$local_target_dir"
gnuplot -e "set terminal png size 1000,1000; set output 'plot_dshapes.png'; set xrange[0:$x1max]; set yrange[0:$x1max]; plot \"dshape0.3-v.csv\" with line, \"dshape0.2-v.csv\" with line, \"dshape0.1-v.csv\" with line, \"dshape0.02-v.csv\" with line, \"dshape0.01-v.csv\" with line, \"dshape0.9-v.csv\" with line;" 
gnuplot -e "set terminal png size 1000,1000; set output 'plot_qf.png'; set xrange[0:30000]; set yrange[0:20]; plot \"savg.csv\" using 1:2, \"savg.csv\" using 1:3, \"savg.csv\" using 1:4;"
echo "Done."
