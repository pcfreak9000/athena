#!/bin/bash

#ATHDF_DIR="$WORKDIR"/simout

#echo "$ATHDF_DIR"

source "$HOME"/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

echo "$SCRIPT"
echo "$WORKDIR"
echo $(eval echo $SCRIPT_ARGS)

python -u "$SCRIPT" $(eval echo $SCRIPT_ARGS)
