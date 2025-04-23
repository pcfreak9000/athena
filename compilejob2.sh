#!/bin/bash
#SBATCH --time=05:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=5g
#SBATCH --partition compute
#SBATCH --output=LOG_COMPILATION
#SBATCH --error=LOG_COMPILATION
#SBATCH --job-name=athena_compile_job


S_WORKER_THREADS=$SLURM_JOB_CPUS_PER_NODE

ATHENA_CONFIG_FILE=athinput.master_project

cd $HOME/athena/

TEMP=$(grep -F 'num_threads' "$ATHENA_CONFIG_FILE")
#is this even neccessary for compilation???
export OMP_NUM_THREADS=${TEMP#*=}

if [ "$BINAC2" ]; then
    export P9000_WORKER_THREADS=$S_WORKER_THREADS
    module load lib/hdf5/1.12-gnu-14.2-openmpi-4.1
    #module load mpi/openmpi/5.0-gnu-14.2
    #which mpicxx
    #module list
    python configure.py -g -b -mpi --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5 --hdf5_path="$HDF5_HOME"
else
    python configure.py -g -b -omp --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5
fi

if [ -n "$P9000_WORKER_THREADS" ]; then
    echo Warning: number of compile workers not specified
fi

make clean
make -j ${P9000_WORKER_THREADS:-4}
