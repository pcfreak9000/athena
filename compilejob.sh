#!/bin/bash
#PBS -l nodes=1:ppn=20
#PBS -l walltime=00:05:00
#PBS -l mem=16gb
#PBS -q tiny
#PBS -S /bin/bash
#PBS -N athena_compile_job
#PBS -j oe
#PBS -o LOG_COMPILATION

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
    module load lib/hdf5/1.12.0-openmpi-4.1-gnu-9.2
    module load mpi/openmpi/4.1-gnu-9.2-cuda-11.4
    python configure.py -g -b -mpi --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5 --hdf5_path="$HDF5_HOME"
else
    python configure.py -g -b -omp --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5
fi
if [ -n "$P9000_WORKER_THREADS" ]; then
    echo Warning: number of compile workers not specified
fi
make clean
make -j ${P9000_WORKER_THREADS:-4}
