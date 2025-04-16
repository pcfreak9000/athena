#!/bin/bash
#PBS -S /bin/bash
#PBS -j oe
#PBS -m a

export P9000_WORKER_THREADS=$PBS_WORKER_THREADS

ATHDF_DIR=$WORKDIR/simout

module load lib/ffmpeg/3.4.7


source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

$WORKDIR/create_movie.sh $ATHDF_DIR $WORKDIR/pngs 25 $WORKDIR/out.mp4 $ATHENA_GIT_DIR "rho --logc" noprogress
