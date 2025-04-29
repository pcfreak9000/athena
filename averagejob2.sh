#!/bin/bash

ATHDF_DIR = "$WORKDIR"/simout

source "$HOME"/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

"$HOME"/athena/vis/python/average.py "$ATHDF_DIR"/master_project.prim "$WORKDIR"/average.athdf 0 6000 1 

