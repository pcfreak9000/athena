#! /usr/bin/env python

import argparse

import athena_read

import math
import csv

# kappa = 0.4 #in cgs
eta = 0.06 #radiative 
mdottarget = 0.3
mdotcode = 0.01
# solar_mass_cgs = 1.988e33
# bh_mass_cgs = 5.0*solar_mass_cgs
# g_cgs = 6.674e-8 #grav. constant in cgs
# c_cgs = 2.998e10 #speed of light in cgs
# rho_code_cgs = 4*math.pi*c_cgs*c_cgs/(g_cgs*bh_mass_cgs*kappa)*(mdottarget/eta)/mdotcode
# dist_geom_cgs = bh_mass_cgs * g_cgs/(c_cgs*c_cgs)

tau_factor = 4*math.pi*mdottarget/(eta*mdotcode)


def getThetaTop(radiusInd, rho, rcoords, thcoords, thbord, a):
    tau = 0.0
    thetaInd = 0
    while tau < 1.0:
        if thcoords[thetaInd] > math.pi/2.0:
            return -1
        dtheta = thbord[thetaInd + 1] - thbord[thetaInd]
        #Kerr-Schild coordinates -> ds^2=(a^2*cos^2(th)+r^2) dth^2
        costh = math.cos(thcoords[thetaInd])
        radius = rcoords[radiusInd]
        diff = math.sqrt(a*a*costh*costh + radius*radius)
        tau += tau_factor * rho[0, thetaInd, radiusInd] * diff
        thetaInd += 1
    return thetaInd

def getFromBorderIndex(array, indexTauGrOne):
    return 0.5 * array[indexTauGrOne] + 0.5 * array[indexTauGrOne - 1]

def main(**kwargs):
    input_filename = kwargs['input_filename']
    output_filename = kwargs['output_filename']
    a = kwargs['a']
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
        #print(len(rcoords))
        thtop = getThetaTop(rInd, rho, rcoords, thcoords, thbord, a)
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
        writer.writerow(['#x', 'y', 'density', 'u0', 'u1', 'u2', 'u3'])
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
    parser.add_argument('a',
                        type=float,
                        help='BH spin parameter')
    args = parser.parse_args()
    main(**vars(args))
