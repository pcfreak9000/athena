#!/bin/bash
#PBS -l nodes=1:ppn=4
#PBS -l walltime=00:05:00
#PBS -l mem=1gb
#PBS -q tiny
#PBS -S /bin/bash
#PBS -N athena_compile_job
#PBS -j oe
#PBS -o LOG_COMPILATION

which mpicxx

PBS_WORKER_THREADS=$PBS_NP

ATHENA_CONFIG_FILE=athinput.master_project

if [ "$PBS_O_WORKDIR" ]; then
    cd $PBS_O_WORKDIR
fi

TEMP=$(grep -F 'num_threads' "$ATHENA_CONFIG_FILE")
#is this even neccessary for compilation???
export OMP_NUM_THREADS=${TEMP#*=}

if [ "$PBS_O_WORKDIR" ]; then
    export P9000_WORKER_THREADS=$PBS_WORKER_THREADS
    #module load mpi/openmpi/5.0-gnu-14.2-cuda-11.4
    #module load compiler/gnu/14.2
    #source "$HOME"/miniconda3/etc/profile.d/conda.sh
    #conda activate sim_env
    module load mpi/openmpi/5.0-gnu-14.2-cuda-11.4
    module load lib/hdf5
    #module load lib/hdf5/1.12.0-openmpi-4.1-gnu-12.2-cuda-11.4
    #module load mpi/openmpi/4.1-gnu-9.2-cuda-11.4

    python configure.py -g -b -mpi --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5 --hdf5_path="$HDF5_HOME"
#--hdf5_path=$HOME/miniconda3/envs/sim_env
else
    python configure.py -g -b -omp --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5
fi
if [ -n "$P9000_WORKER_THREADS" ]; then
    echo Warning: number of compile workers not specified
fi
make clean
make -j ${P9000_WORKER_THREADS:-4}
