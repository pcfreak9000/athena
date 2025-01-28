#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=00:15:00
#PBS -l mem=16gb
#PBS -S /bin/bash
#PBS -N athena_test_job
#PBS -j oe
#PBS -o LOG_TEST

ATHENA_CONFIG_FILE=athinput.master_project

if [ "$PBS_O_WORKDIR" ]; then
    cd $PBS_O_WORKDIR
fi

TEMP=$(grep -F 'num_threads' $ATHENA_CONFIG_FILE)
export OMP_NUM_THREADS=${TEMP#*=}
echo $OMP_NUM_THREADS
if [ "$PBS_O_WORKDIR" ]; then
    module load lib/hdf5/1.12.0-openmpi-4.1-gnu-9.2
    module load mpi/openmpi/4.1-gnu-9.2-cuda-11.4
    TARGETDIR=/beegfs/work/tu_zxorf45/$(date +"%Y-%m-%d_%H-%M-%S")
    mkdir -p $TARGETDIR
    cp $ATHENA_CONFIG_FILE $TARGETDIR/
    mpirun --bind-to core --map-by socket:PE="$OMP_NUM_THREADS" -report-bindings bin/athena -i $ATHENA_CONFIG_FILE -d $TARGETDIR
else
    TARGETDIR=Gartenzwerg-$(date +"%Y-%m-%d_%H-%M-%S")
    mkdir -p $TARGETDIR
    cp $ATHENA_CONFIG_FILE $TARGETDIR/
    bin/athena -i $ATHENA_CONFIG_FILE -d $TARGETDIR
fi
