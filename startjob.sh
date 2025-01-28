#!/bin/bash
#PBS -l nodes=1:ppn=14
#PBS -l walltime=00:10:00
#PBS -l mem=16gb
#PBS -S /bin/bash
#PBS -N athena_test_job
#PBS -j oe
#PBS -o LOG_COMPILATION

export OMP_NUM_THREADS=4
bin/athena -i athinput.master_project -d /beegfs/work/tu_zxorf45/$(date +"%Y-%m-%d_%H-%M-%S")
