#!/bin/bash
if [ "$BINAC2" ]; then
    export P9000_WORKER_THREADS=$SLURM_JOB_CPUS_PER_NODE
fi

ATHDF_DIR="$WORKDIR"/simout

if [ "$BINAC2" ]; then
    module load vis/ffmpeg/ffmpeg-5.1
    source "$HOME"/miniconda3/etc/profile.d/conda.sh
    conda activate master_project_env
    nop=noprogress
fi

if [ -z "$MNAME" ]; then
    MNAME=out
fi



"$WORKDIR"/create_movie.sh "$ATHDF_DIR" "$WORKDIR"/pngs_"$MNAME" 25 "$WORKDIR"/"$MNAME".mp4 "$ATHENA_GIT_DIR" "$PLOT_OPTIONS" $nop
