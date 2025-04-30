#!/bin/python

import argparse

import athena_read
import math
import csv

def integrate_flow(rho, velr, thcoords, thbord, radius):
    flow = 0.0
    for thetaInd in range(len(thcoords)):
        dtheta = thbord[thetaInd + 1] - thbord[thetaInd]
        dS = radius*radius * math.sin(thcoords[thetaInd]) * dtheta #does this make sense????
        flow += - 2 * math.pi * rho[0, thetaInd, 0] * velr[0, thetaInd, 0] * dS
    return flow
    
def main(**kwargs):
    if kwargs['end'] < kwargs['start']:
        raise Exception("end < start")
    file_nums = range(kwargs['start'], kwargs['end']+1, kwargs['stride'])
    flows = []
    times = []
    for n in file_nums:
        #input_filename = kwargs['input_filename']
        input_filename = '{0}.{1:05d}.athdf'.format(kwargs['input_filename'], n)
        data = athena_read.athdf(input_filename)
        rho = data['rho']
        velr = data['vel1']
        thcoords = data['x2v']
        thbord = data['x2f']
        rcoords = data['x1v']
        flow = integrate_flow(rho, velr, thcoords, thbord, rcoords[0])
        flows.append(flow)
        times.append(data['Time'])
    lis = [times, flows]
    zl = zip(*lis)
    with open(kwargs['output_filename'], 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=' ',quotechar='"', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(['time', 'flow'])
        for t in zl:
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
    args = parser.parse_args()
    main(**vars(args))
