#!/bin/bash
#PBS -S /bin/bash
#PBS -j oe
#PBS -m a

ATHDF_DIR=$WORKDIR/simout

module load lib/ffmpeg/3.4.7


source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

$WORKDIR/create_movie.sh $ATHDF_DIR $WORKDIR/pngs 25 $WORKDIR $ATHENA_GIT_DIR
