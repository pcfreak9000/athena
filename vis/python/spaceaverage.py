#!/bin/python

import argparse

import athena_read
import math
import csv
import multiprocessing
import numpy as np

def eval(input_filename):
    maxvv = input_filename[3]
    level = input_filename[2]
    quants = input_filename[1]    
    data = athena_read.athdf(input_filename[0],return_levels=True)
    levels = data['Levels'].flatten()
    weights = []
    for l in levels:
        if l>=level:
            weights.append(1)
        else:
            weights.append(0)
    #print(quants)
    res = [data['Time']]
    if maxvv is not None:
        maxv = np.full(len(weights), maxvv)
    for q in quants:
        qd = data[q].flatten()
        if maxvv is not None:
            qd = np.minimum(qd, maxv)
        avg = np.average(qd, weights=weights)
        res.append(avg)       
    print(input_filename[0])
    return res
     
def main(**kwargs):
    if kwargs['end'] < kwargs['start']:
        raise Exception("end < start")
    file_nums = range(kwargs['start'], kwargs['end']+1, kwargs['stride'])
    pool = multiprocessing.Pool(64)
    input_filenames = []
    toavg = kwargs['quantities']

    #input_filenames.append([kwargs['input_filename'],None,kwargs['lvl'],kwargs['max']])
    for n in file_nums:
        input_filenames.append(['{0}.{1:05d}.athdf'.format(kwargs['input_filename'], n),None,kwargs['lvl'], kwargs['max']])
        
    if toavg is None:        
            toavg = np.array([x.decode('ascii', 'replace') for x in athena_read.athdf(input_filenames[0][0])['VariableNames']])

    for i in input_filenames:
        i[1] = toavg
        
    results = pool.map(eval, input_filenames)
    #lis = []
    #for q in toavg:
    #    lis.append([])
    #for i in range(results):
    #    r = results[i]
    #    for x in r:
    #        lis[i].append(x)
    pool.close()
    pool.terminate()
    #lis = [times, quantity]
    #zl = zip(*lis)
    names = ['#time']
    for q in toavg:
        names.append(q)
    with open(kwargs['output_filename'], 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=' ',quotechar='"', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(names)
        for t in results:
            writer.writerow(t)
        
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
    parser.add_argument('--max', type=float, default=None, help='limit used values to max')
    parser.add_argument('-q', '--quantities',
            type=str,
            nargs='+',
            help='quantities to be averaged')
    parser.add_argument('--lvl', type=int, default=0, help='Min level to avg over')
    args = parser.parse_args()
    main(**vars(args))
