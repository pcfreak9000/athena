#!/bin/bash
#PBS -l nodes=1:ppn=6
#PBS -l walltime=00:10:00
#PBS -l mem=10gb
#PBS -S /bin/bash
#PBS -N athena_movie_job
#PBS -j oe
#PBS -o LOG_MOVIE

ATHDFPATH=$MYWORK/2025-02-03_18-00-30

if [ "$PBS_O_WORKDIR" ]; then
    cd $PBS_O_WORKDIR
fi

module load lib/ffmpeg/3.4.7
#module load numlib/scipy/1.1.0-numpy-1.14.5-python-3.7.1

source $HOME/miniconda3/etc/profile.d/conda.sh
conda activate master_project_env

./create_movie.sh $ATHDFPATH $ATHDFPATH/pngs 25
