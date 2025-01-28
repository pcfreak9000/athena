#!/bin/bash
#PBS -l nodes=1:ppn=4
#PBS -l walltime=00:15:00
#PBS -l mem=16gb
#PBS -S /bin/bash
#PBS -N athena_test_job
#PBS -j oe
#PBS -o LOG_TEST

export OMP_NUM_THREADS=4
if [ "$PBS_O_WORKDIR" ]; then
    cd $PBS_O_WORKDIR
    module load lib/hdf5/1.10.7-gnu-9.2
    bin/athena -i athinput.master_project -d /beegfs/work/tu_zxorf45/$(date +"%Y-%m-%d_%H-%M-%S")
fi
