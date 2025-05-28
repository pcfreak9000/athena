#!/bin/python

"""
Read .athdf data files and write new ones as single block at constant refinement
level.

Note: Requires h5py.
"""

# Python standard modules
import argparse
import os

# Other Python modules
import h5py
import numpy as np
import math
# Athena++ modules
import athena_read

# Main function


def main(**kwargs):
    if kwargs['end'] < kwargs['start']:
        raise Exception("end < start")
    print("Determining max level")    
# Determine which files to process given possible MPI information
    # yes, start+1 is correct. start itself is read below.
    file_nums = range(kwargs['start']+1, kwargs['end']+1, kwargs['stride'])
    file_nums_local = file_nums
    level_max = 0
    count0 = 0
    for n in file_nums_local:
        input_filename = '{0}.{1:05d}.athdf'.format(kwargs['input_filename'], n)
        with h5py.File(input_filename, 'r') as f:
            level_max = max(level_max, f.attrs['MaxLevel'])
        count0 = count0 + 1
        print(count0/len(file_nums_local))
    print("Reading starting file")
    input_filename = '{0}.{1:05d}.athdf'.format(kwargs['input_filename'], kwargs['start'])
    output_filename = kwargs['output_filename']
    toavg = kwargs['quantities']
    with h5py.File(input_filename, 'r') as f:
        attributes = f.attrs.items()
        attrs = dict(attributes)
        level_max = max(f.attrs['MaxLevel'], level_max)
        if toavg is None:
            toavg = np.array([x.decode('ascii', 'replace')
                                       for x in f.attrs['VariableNames'][:]])


    basedata = athena_read.athdf(input_filename, quantities=kwargs['quantities'],
                                 level=level_max, subsample=False)

    print("Averaging...")
    # Go through list of files
    count = 1
    for n in file_nums_local:
        count = count + 1
        # Determine filenames
        input_filename = '{0}.{1:05d}.athdf'.format(kwargs['input_filename'], n)
        data = athena_read.athdf(input_filename, quantities=kwargs['quantities'],
                                 level=level_max, subsample=False)
        for datasetName in toavg:
            shape = data[datasetName].shape
            #print(shape)
            for i in range(shape[0]):
                for j in range(shape[1]):
                    for k in range(shape[2]):
                        value = data[datasetName][i,j,k]
                        if kwargs['nanzero'] and math.isnan(value):
                            value = 0.0
                        curavg = basedata[datasetName][i,j,k]
                        if count <= 2 and kwargs['nanzero'] and math.isnan(curavg):
                            curavg = 0.0
                        basedata[datasetName][i,j,k] = curavg * (count-1)/count + value / count
        del data # lets free some memory, even though technically this should be done automatically by python????
        print(count/len(file_nums_local))

    # Determine new grid size
    nx1 = attrs['RootGridSize'][0] * 2**level_max if attrs['MeshBlockSize'][0] > 1 else 1
    nx2 = attrs['RootGridSize'][1] * 2**level_max if attrs['MeshBlockSize'][1] > 1 else 1
    nx3 = attrs['RootGridSize'][2] * 2**level_max if attrs['MeshBlockSize'][2] > 1 else 1

    # Create new HDF5 file
    with h5py.File(output_filename, 'w') as f:

        # Write attributes
        for key, val in attrs.items():
            if key == 'RootGridX1' or key == 'RootGridX2' or key == 'RootGridX3':
                if val[2] > 0.0:
                    value = [val[0], val[1], val[2]**(1.0/2.0**level_max)]
                else:
                    value = [val[0], val[1], val[2]]
            elif key == 'RootGridSize':
                value = [nx1, nx2, nx3]
            elif key == 'NumMeshBlocks':
                value = 1
            elif key == 'MeshBlockSize':
                value = [nx1, nx2, nx3]
            elif key == 'MaxLevel':
                value = 0
            elif key == 'NumVariables' and kwargs['quantities'] is not None:
                value = [len(kwargs['quantities'])]
            elif key == 'DatasetNames' and kwargs['quantities'] is not None:
                value = ['quantities']
            elif key == 'VariableNames' and kwargs['quantities'] is not None:
                value = kwargs['quantities']
            else:
                value = val
            f.attrs.create(key, value, dtype=val.dtype)

        # Write datasets
        f.create_dataset('Levels', data=[0], dtype='>i4')
        f.create_dataset('LogicalLocations', data=[0, 0, 0], dtype='>i8',
                         shape=(1, 3))
        f.create_dataset('x1f', data=basedata['x1f'], dtype='>f4', shape=(1, nx1 + 1))
        f.create_dataset('x2f', data=basedata['x2f'], dtype='>f4', shape=(1, nx2 + 1))
        f.create_dataset('x3f', data=basedata['x3f'], dtype='>f4', shape=(1, nx3 + 1))
        f.create_dataset('x1v', data=basedata['x1v'], dtype='>f4', shape=(1, nx1))
        f.create_dataset('x2v', data=basedata['x2v'], dtype='>f4', shape=(1, nx2))
        f.create_dataset('x3v', data=basedata['x3v'], dtype='>f4', shape=(1, nx3))
        var_offset = 0
        for dataset_name, num_vars in zip(
                f.attrs['DatasetNames'], f.attrs['NumVariables']):
            f.create_dataset(dataset_name.decode('ascii', 'replace'), dtype='>f4',
                             shape=(num_vars, 1, nx3, nx2, nx1))
            for var_num in range(num_vars):
                variable_name = f.attrs['VariableNames'][var_num + var_offset]
                variable_name = variable_name.decode('ascii', 'replace')
                f[dataset_name][var_num, 0, :, :, :] = basedata[variable_name]
            var_offset += num_vars
       # Create new XDMF file
        if not kwargs['x']:
            with open(output_filename + '.xdmf', 'w') as f:
                f.write('<?xml version="1.0" ?>\n')
                f.write('<!DOCTYPE Xdmf SYSTEM "Xdmf.dtd" []>\n')
                f.write('<Xdmf Version="2.0">\n')
                f.write('<Domain>\n')
                f.write('<Grid Name="Mesh" GridType="Collection">\n')
                f.write('  <Grid Name="MeshBlock0" GridType="Uniform">\n')
                f.write(('    <Topology TopologyType="3DRectMesh"'
                         + ' NumberOfElements="{0} {1} {2}"/>\n').format(nx3+1, nx2+1,
                                                                         nx1+1))
                f.write('    <Geometry GeometryType="VXVYVZ">\n')
                for nx, xf_string in zip((nx1, nx2, nx3), ('x1f', 'x2f', 'x3f')):
                    f.write(
                        '      <DataItem ItemType="HyperSlab" Dimensions="{0}">\n'.format(nx + 1))  # noqa
                    f.write(('        <DataItem Dimensions="3 2" NumberType="Int">'
                             + ' 0 0 1 1 1 {0} </DataItem>\n').format(nx + 1))
                    f.write(
                        ('        <DataItem Dimensions="1 {0}" Format="HDF">'
                         + ' {1}:/{2} </DataItem>\n').format(nx + 1, output_base, xf_string))  # noqa
                    f.write('      </DataItem>\n')
                f.write('    </Geometry>\n')
                if kwargs['quantities'] is None:
                    num_variables = attrs['NumVariables']
                    dataset_names = attrs['DatasetNames']
                    variable_names = attrs['VariableNames']
                else:
                    num_variables = [len(kwargs['quantities'])]
                    dataset_names = ['quantities']
                    variable_names = kwargs['quantities']
                var_offset = 0
                for dataset_name, num_vars in zip(dataset_names, num_variables):
                    for var_num in range(num_vars):
                        variable_name = variable_names[var_num + var_offset]
                        f.write(
                            '    <Attribute Name="{0}" Center="Cell">\n'.format(variable_name))  # noqa
                        f.write(
                            '      <DataItem ItemType="HyperSlab" Dimensions="{0} {1} {2}">\n' .format(nx3, nx2, nx1))  # noqa
                        f.write(('        <DataItem Dimensions="3 5" NumberType="Int">'
                                 + ' {0} 0 0 0 0 1 1 1 1 1 1 1 {1} {2} {3} </DataItem>\n')
                                .format(var_num, nx3, nx2, nx1))
                        f.write(
                            ('        <DataItem Dimensions="{0} 1 {1} {2} {3}" Format="HDF">'  # noqa
                             + ' {4}:/{5} </DataItem>\n') .format(num_vars, nx3, nx2, nx1, output_base, dataset_name))  # noqa
                        f.write('      </DataItem>\n')
                        f.write('    </Attribute>\n')
                    var_offset += num_vars
                f.write('  </Grid>\n')
                f.write('</Grid>\n')
                f.write('</Domain>\n')
                f.write('</Xdmf>')
    
    #dddd = athena_read.athdf(output_filename)
    #print(dddd)
 
# Execute main function
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('input_filename',
                        type=str,
                        help='base name of files to be converted, including directory')
    parser.add_argument('output_filename',
                        type=str,
                        help='name of new files to be saved, including directory')
    parser.add_argument('start',
                        type=int,
                        help='first file number to be converted')
    parser.add_argument('end',
                        type=int,
                        help='last file number to be converted')
    parser.add_argument('stride',
                        type=int,
                        default=0,
                        help='stride in file numbers to be converted')
    parser.add_argument('-x',
                        action='store_false',
                        help='flag indicating an XDMF file should be written')
    parser.add_argument('--nanzero', action='store_true', help='flag indicating to turn NANs into 0.0')
    #parser.add_argument('--max', type=float, default=None, help='limit abs of used values to max')
    parser.add_argument('-q', '--quantities',
                        type=str,
                        nargs='+',
                        help='names of quantities to extract')
    args = parser.parse_args()
    main(**vars(args))
