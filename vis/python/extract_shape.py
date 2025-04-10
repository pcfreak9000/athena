#! /usr/bin/env python

import argparse

import athena_read

import math
import csv

kappa = 0.4 #in cgs
solar_mass_si = 1.988e30
bh_mass_si = 5.0*solar_mass_si #in SI in kg
g_si = 6.674e-11 #grav. constant in SI
c_si = 2.998e8 #speed of light in SI
dist_si_cgs = 100.0 #conversion factor from SI meters to cgs centimeters

dist_geom_cgs = g_si/(c_si*c_si)*bh_mass_si*dist_si_cgs #conversion factor from geometric units distance to centimeters

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
    output_filename = kwargs['output_filename']
    
    data = athena_read.athdf(input_filename)
    rho = data['rho'] 
    rcoords = data['x1v']
    thcoords = data['x2v']
    thbord = data['x2f']
    du0 = data['u0']
    du1 = data['u1']
    du2 = data['u2']
    du3 = data['u3']
    xs = []
    ys = []
    densities = []
    u0 = []
    u1 = []
    u2 = []
    u3 = []
    for rInd in range(0, rcoords.shape[0]):
        thtop = getThetaTop(rInd, rho, rcoords, thcoords, thbord)
        # heights in geometric units
        if thtop == -1:
            xs.append(rcoords[rInd])
            ys.append(0.0)
            densities.append(0.0)
            u0.append(0.0)
            u1.append(0.0)
            u2.append(0.0)
            u3.append(0.0)
        else:
            xs.append(rcoords[rInd]*math.sin(getFromBorderIndex(thcoords, thtop)))
            ys.append(rcoords[rInd]*math.cos(getFromBorderIndex(thcoords, thtop)))
            densities.append(getFromBorderIndex(rho[0, :, rInd], thtop))
            u0.append(getFromBorderIndex(du0[0, :, rInd], thtop))
            u1.append(getFromBorderIndex(du1[0, :, rInd], thtop))
            u2.append(getFromBorderIndex(du2[0, :, rInd], thtop))
            u3.append(getFromBorderIndex(du3[0, :, rInd], thtop))

    #lis = [rcoords, heights, densities, u0, u1, u2, u3]
    lis = [xs, ys, densities, u0, u1, u2, u3]
    zl = zip(*lis)
    with open(output_filename, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=' ',
                            quotechar='"', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(['x', 'y', 'density', 'u0', 'u1', 'u2', 'u3'])
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
    args = parser.parse_args()
    main(**vars(args))
