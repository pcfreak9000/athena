#!/bin/bash

ATHDF_DIR="$WORKDIR"/simout

echo "$ATHDF_DIR"

source "$HOME"/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

python -u "$SCRIPT" $SCRIPT_ARGS
