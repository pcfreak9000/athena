#!/bin/bash
#PBS -l nodes=1:ppn=14
#PBS -l walltime=00:10:00
#PBS -l mem=16gb
#PBS -S /bin/bash
#PBS -N athena_compile_job
#PBS -j oe
#PBS -o LOG_COMPILATION

#is this even neccessary for compilation???
export OMP_NUM_THREADS=4

if [ "$PBS_O_WORKDIR" ]; then
    cd $PBS_O_WORKDIR
    module load lib/hdf5/1.10.7-gnu-9.2
    python configure.py -g -b -omp --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5 --hdf5_path=$HDF5_HOME
else
    python configure.py -g -b -omp --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5
fi
make clean
make -j 7
