#!/bin/bash
#PBS -l nodes=1:ppn=4
#PBS -l walltime=00:15:00
#PBS -l mem=16gb
#PBS -S /bin/bash
#PBS -N athena_test_job
#PBS -j oe
#PBS -o LOG_TEST

ATHENA_CONFIG_FILE=athinput.master_project

export OMP_NUM_THREADS="$(grep -F \"num_threads\" $ATHENA_CONFIG_FILE | cut -d ' ' -f 3)"

if [ "$PBS_O_WORKDIR" ]; then
    cd $PBS_O_WORKDIR
    module load lib/hdf5/1.10.7-gnu-9.2
    bin/athena -i $ATHENA_CONFIG_FILE -d /beegfs/work/tu_zxorf45/$(date +"%Y-%m-%d_%H-%M-%S")
else
    bin/athena -i $ATHENA_CONFIG_FILE -d Gartenzwerg-$(date +"%Y-%m-%d_%H-%M-%S")
fi
