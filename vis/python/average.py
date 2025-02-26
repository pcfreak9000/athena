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
    basename = kwargs['basename']
    suffix = kwargs['suffix']
    start = int(kwargs['start'])
    end = int(kwargs['end'])
    zfi = int(kwargs['zerofill'])
    # file basename, start number, end number or length, stride?, file suffix
    for i in range(start, end + 1):
        files.append(basename + str(i).zfill(zfi) + suffix)
        #print(files[i-start])
        
    basedata = athena_read.athdf(files[0], return_levels=True, raw=True)
    count = 1
    for file in files[1:]:
        count = count + 1 
        data = athena_read.athdf(file, return_levels=True, raw=True)
        for datasetName in toavg:
            shape = data[datasetName].shape
            #print(shape)
            
            for i in range(shape[0]):
                for j in range(shape[1]):
                    for k in range(shape[2]):
                        for a in range(shape[3]):
                            value = data[datasetName][i,j,k,a]
                            curavg = basedata[datasetName][i,j,k,a]
                            basedata[datasetName][i,j,k,a] = curavg * (count-1)/count + value / count
        del data # lets free some memory, even though technically this should be done automatically by python????

    # here we need to write the basedata again to a new athdf file
    # see uniform.py for that
    outfile = kwargs['file_out']
    with h5py.File(files[0], 'r') as f:
        attributes = f.attrs.items()
        attrs = dict(attributes)
        print(f['x1f'].shape)
        #ll = f['LogicalLocations'][:]
    with h5py.File(outfile, 'w') as f:
        for k,v in attrs.items():
            f.attrs.create(k, v, dtype=v.dtype)

        # Write datasets
        # not sure if the top two are correct... do they matter??
        nx1 = attrs['RootGridSize'][0]
        nx2 = attrs['RootGridSize'][1]
        nx3 = attrs['RootGridSize'][2]
        f.create_dataset('Levels', data=basedata['Levels'], dtype='>i4')
        f.create_dataset('LogicalLocations', data=basedata['LogicalLocations'], dtype='>i8')
        f.create_dataset('x1f', data=basedata['x1f'], dtype='>f4')
        f.create_dataset('x2f', data=basedata['x2f'], dtype='>f4')
        f.create_dataset('x3f', data=basedata['x3f'], dtype='>f4')
        f.create_dataset('x1v', data=basedata['x1v'], dtype='>f4')
        f.create_dataset('x2v', data=basedata['x2v'], dtype='>f4')
        f.create_dataset('x3v', data=basedata['x3v'], dtype='>f4')
        var_offset = 0
        #nx1 = attrs['RootGridSize'][0]
        #nx2 = attrs['RootGridSize'][1]
        #nx3 = attrs['RootGridSize'][2]
        for dataset_name, num_vars in zip(
            f.attrs['DatasetNames'], f.attrs['NumVariables']):
            f.create_dataset(dataset_name.decode('ascii', 'replace'), dtype='>f4',
                    shape=(num_vars, basedata.shape[0], basedata.shape[1], basedata.shape[2], basedata.shape[3]))
            for var_num in range(num_vars):
                variable_name = f.attrs['VariableNames'][var_num + var_offset]
                variable_name = variable_name.decode('ascii', 'replace')
                f[dataset_name][var_num, :, :, :, :] = basedata[variable_name]
            var_offset += num_vars


   
    print(basedata)
    bd_reread = athena_read.athdf(outfile)
    print(bd_reread)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('basename')
    parser.add_argument('suffix')
    parser.add_argument('start')
    parser.add_argument('end')
    parser.add_argument('-z', '--zerofill', default=0)
    parser.add_argument('file_out')
    
    args = parser.parse_args()
    main(**vars(args))
