#!/bin/bash

file="$1"
spin="$2"

./movieq2.sh "$file" "q1 --vmin=0.0 --vmax=12.0 --abs" "q1"
./movieq2.sh "$file" "q2 --vmin=0.0 --vmax=12.0 --abs" "q2"
./movieq2.sh "$file" "q3 --vmin=0.0 --vmax=24.0 --abs" "q3"
./movieq2.sh "$file" "rho --vmin=0.0 --vmax=1.0"
./mdq2.sh "$file" "$spin"
