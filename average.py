#!/bin/python

# Python standard modules
import argparse
import os

# Other Python modules
import h5py

# Athena++ modules
import athena_read

def main(**kwargs):
    #read files one by one and accumulate average of the fields we are interested in
    #write output file where fields which were not averaged are taken from the first file or left empty?

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    
    args = parser.parse_args()
    main(**vars(args))
