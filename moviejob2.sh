#!/bin/bash
#PBS -S /bin/bash
#PBS -j oe
#PBS -m a

export P9000_WORKER_THREADS=$PBS_NP

ATHDF_DIR="$WORKDIR"/simout

module load vis/ffmpeg/ffmpeg-5.1


source "$HOME"/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

"$WORKDIR"/create_movie.sh "$ATHDF_DIR" "$WORKDIR"/pngs 25 "$WORKDIR"/out.mp4 "$ATHENA_GIT_DIR" "$PLOT_OPTIONS" noprogress
