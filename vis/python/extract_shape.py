#! /usr/bin/env python

import argparse

import athena_read

import math

kappa = 0.4 #in cgs
dist_geom_cgs = 100.0 #conversion factor from geometric units distance to centimeters

def getThetaTop(radiusInd, rho, rcoords, thcoords, thbord):
    tau = 0.0
    thetaInd = 0
    radius = rcoords[radiusInd] * dist_geom_cgs
    while tau < 1.0:
        if thcoords[thetaInd] > math.pi/2.0:
            return -1
        dtheta = thbord[thetaInd + 1] - thbord[thetaInd] 
        diff = radius * dtheta
        tau += kappa * rho[0, thetaInd, radiusInd] * diff
        thetaInd += 1
    return thetaInd

def getFromBorderIndex(array, indexTauGrOne):
    return 0.5 * array[indexTauGrOne] + 0.5 * array[indexTauGrOne - 1]

def main(**kwargs):
    input_filename = kwargs['input_filename']
    data = athena_read.athdf(input_filename)
    rho = data['rho'] 
    rcoords = data['x1v']
    thcoords = data['x2v']
    thbord = data['x2f']
    heights = []
    densities = []
    for rInd in range(0, rcoords.shape[0]):
        thtop = getThetaTop(rInd, rho, rcoords, thcoords, thbord)
        # heights in geometric units
        if thtop == -1:
            heights.append(0.0)
            densities.append(0.0)
        else:
            heights.append(rcoords[rInd]*math.cos(getFromBorderIndex(thcoords, thtop)))
            densities.append(getFromBorderIndex(rho[0, :, rInd], thtop))
    print(densities)

# Execute main function
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('input_filename',
                        type=str,
                        help='base name of files to be converted, including directory')
    parser.add_argument('output_filename',
                        type=str,
                        help='name of new files to be saved, including directory')
    args = parser.parse_args()
    main(**vars(args))
