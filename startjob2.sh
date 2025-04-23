#!/bin/bash
#SBATCH --mail-type=ALL 


#echo $WORKDIR
#echo $ATHENABIN
#echo $ATHENA_CONFIG_FILE


if [ -z "${WORKDIR+x}" ]; then
    exit 1
fi
if [ -z "${ATHENABIN+x}" ]; then
    exit 1
fi
if [ -z "${ATHENA_CONFIG_FILE+x}" ]; then
    exit 1
fi
if [ -z "${TIMELIMIT_RSTFILE+x}" ]; then
    exit 1
fi


cd "$WORKDIR"
ATHENA_OUTDIR="$WORKDIR"/simout
mkdir -p "$ATHENA_OUTDIR"

TEMP=$(grep -F 'num_threads' "$ATHENA_CONFIG_FILE")
export OMP_NUM_THREADS=${TEMP#*=}

if [ "$BINAC2" ]; then
    module load lib/hdf5/1.12-gnu-14.2-openmpi-4.1
    #module load mpi/openmpi/5.0-gnu-14.2
    #which mpirun
    #module list
    mpirun  --bind-to core --map-by core -report-bindings "$ATHENABIN" -i "$ATHENA_CONFIG_FILE" -d "$ATHENA_OUTDIR" -t "$TIMELIMIT_RSTFILE"
else
    "$ATHENABIN" -i "$ATHENA_CONFIG_FILE" -d "$ATHENA_OUTDIR" -t "$TIMELIMIT_RSTFILE"
fi
