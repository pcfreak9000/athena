#!/bin/python

# Python standard modules
import argparse
import os

# Other Python modules
import h5py

# Athena++ modules
import athena_read

def main(**kwargs):
    toavg = ['rho', 'press', 'vel1', 'vel2', 'vel3', 'Bcc1', 'Bcc2', 'Bcc3']
    #toavg = ['rho']
    #read files one by one and accumulate average of the fields we are interested in
    #write output file where fields which were not averaged are taken from the first file or left empty?
    #generate list of files to avg
    files = []
    # file basename, start number, end number or length, stride?, file suffix
    
    basedata = athena_read.athdf(files[0])
    count = 1
    for file in files[1:]:
        count = count + 1 
        data = athena_read.athdf(file)
        for datasetName in toavg:
            shape = data[datasetName].shape
            for i in range(shape[0]):
                for j in range(shape[1]):
                    for k in range(shape[2]):
                        value = data[datasetName][i,j,k]
                        curavg = basedata[datasetName][i,j,k]
                        basedata[datasetName][i,j,k] = curavg * (count-1)/count + value / count
        del data # lets free some memory, even though technically this should be done automatically by python????

    # here we need to write the basedata again to a new athdf file
    # see uniform.py for that

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('data_file')
    
    args = parser.parse_args()
    main(**vars(args))
