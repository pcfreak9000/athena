#!/bin/bash
#PBS -l nodes=1:ppn=14
#PBS -l walltime=00:10:00
#PBS -l mem=16gb
#PBS -S /bin/bash
#PBS -N athena_compile_job
#PBS -j oe
#PBS -o LOG_COMPILATION
if [ "$PBS_O_WORKDIR" ]; then
    module load lib/hdf5/1.10.7-gnu-9.2
    cd $PBS_O_WORKDIR
fi
python configure.py -g -b --prob gr_torus --coord=kerr-schild --flux hlle --nghost 4 -hdf5
make clean
make -j
