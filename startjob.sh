#!/bin/bash
#PBS -S /bin/bash
#PBS -j oe



cd $WORKDIR
ATHENA_OUTDIR=$(pwd)/simout
mkdir -p $ATHENA_OUTDIR


TEMP=$(grep -F 'num_threads' $ATHENA_CONFIG_FILE)
export OMP_NUM_THREADS=${TEMP#*=}

if [ "$PBS_O_WORKDIR" ]; then
    module load lib/hdf5/1.12.0-openmpi-4.1-gnu-9.2
    module load mpi/openmpi/4.1-gnu-9.2-cuda-11.4
    mpirun --bind-to core --map-by core -report-bindings $ATHENABIN -i $ATHENA_CONFIG_FILE -d $ATHENA_OUTDIR
else
    $ATHENABIN -i $ATHENA_CONFIG_FILE -d $ATHENA_OUTDIR
fi
