#!/bin/bash

ATHDF_DIR="$WORKDIR"/simout

echo "$ATHDF_DIR"

source "$HOME"/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

#echo Test

python -u "$HOME"/athena/vis/python/average.py "$ATHDF_DIR"/master_project.prim "$WORKDIR"/average.athdf 0 6000 1 

