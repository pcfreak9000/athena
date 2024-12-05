#PBS -l nodes=1:ppn1=1
#PBS -l walltime=00:10:00
#PBS -l mem=2gb
#PBS -S /bin/bash
#PBS -N athena compile job
#PBS -j oe
#PBS -o LOG

make clean
make -j
