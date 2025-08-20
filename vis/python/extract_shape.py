#! /usr/bin/env python

import argparse

import athena_read

import math
import csv

#kappa = 0.4 #in cgs
eta = 0.06 #radiative
#mdottarget = 0.1
#mdotcode = 0.039189*50
#solar_mass_cgs = 1.988e33
#bh_mass_cgs = 10*solar_mass_cgs
#g_cgs = 6.674e-8 #grav. constant in cgs
#c_cgs = 2.998e10 #speed of light in cgs
#rho_code_cgs = 4*math.pi*c_cgs*c_cgs*mdottarget/(eta*mdotcode*g_cgs*bh_mass_cgs)
#rho_code_cgs_simple = 4*math.pi*mdottarget/(eta*mdotcode)

#print(rho_code_cgs)
#print(rho_code_cgs_simple)

#tau_factor = rho_code_cgs_simple
tau_target = 1.0

def getTauFactor(kwargs):
    mdottarget=float(kwargs['mdt'])
    x3min=float(kwargs['x3min'])
    x3max=float(kwargs['x3max'])
    modifier=2.0*math.pi/(x3max-x3min)
    mdotcode=kwargs['mdc']
    return 4.0*math.pi*mdottarget/(eta*mdotcode*modifier)


def getThetaTop(radiusInd, rho, rcoords, thcoords, thbord, a, tau_factor):
    tau = 0.0
    thetaInd = 0
    prevTau = 0.0
    while tau < tau_target:
        if thcoords[thetaInd] > math.pi/2.0:
            return -1, 0.0

        dtheta = thbord[thetaInd + 1] - thbord[thetaInd]
        #Kerr-Schild coordinates -> ds^2=(a^2*cos^2(th)+r^2) dth^2
        costh = math.cos(thcoords[thetaInd])
        radius = rcoords[radiusInd]
        diff = math.sqrt(a*a*costh*costh + radius*radius) * dtheta

        effRho = rho[0, thetaInd, radiusInd]
        if effRho <= 1.5e-5 * (radius**-1.5):
            effRho = 0
        prevTau = tau
        tau += tau_factor * effRho * diff

        thetaInd += 1

    interpol = (tau_target - prevTau) / (tau - prevTau)
    if thcoords[thetaInd] > math.pi/2.0:
        return -1, 0.0
    return thetaInd, interpol

def getFromBorderIndex(array, indexTauGrOne, interpol):
    if indexTauGrOne == 0:
        print("bad value")
    return interpol * array[indexTauGrOne] + (1.0 - interpol) * array[indexTauGrOne - 1]

def main(**kwargs):
    input_filename = kwargs['input_filename']
    output_filename = kwargs['output_filename']
    tau_factor = getTauFactor(kwargs)
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
    xs = [0.0]
    ys = [0.0]
    densities = [0.0]
    u0 = [0.0]
    u1 = [0.0]
    u2 = [0.0]
    u3 = [0.0]
    for rInd in range(0, rcoords.shape[0]):
        #print(len(rcoords))
        thtop, interpol = getThetaTop(rInd, rho, rcoords, thcoords, thbord, a, tau_factor)
        # interpol = 0.5
        # heights in geometric units
        if thtop == -1:
            #xs.append(rcoords[rInd])
            xs.append(math.sqrt(rcoords[rInd]**2 + a*a))
            ys.append(0.0)
            densities.append(0.0)
            u0.append(0.0)
            u1.append(0.0)
            u2.append(0.0)
            u3.append(0.0)
        else:
            xs.append(math.sqrt(rcoords[rInd]**2 + a*a) * math.sin(getFromBorderIndex(thcoords, thtop, interpol)))
            #xs.append(rcoords[rInd])
            ytoappend = rcoords[rInd] * math.cos(getFromBorderIndex(thcoords, thtop, interpol))
            if ytoappend < 0.0:
                print("negative y should not occur at this place")
                ytoappend = 0.0
            ys.append(ytoappend)
            densities.append(getFromBorderIndex(rho[0, :, rInd], thtop, interpol))
            u0.append(getFromBorderIndex(du0[0, :, rInd], thtop, interpol))
            u1.append(getFromBorderIndex(du1[0, :, rInd], thtop, interpol))
            u2.append(getFromBorderIndex(du2[0, :, rInd], thtop, interpol))
            u3.append(getFromBorderIndex(du3[0, :, rInd], thtop, interpol))
    #make sure the disk is closed towards the outer edge
    xs.append(xs[-1]+0.5)
    ys.append(0.0)
    densities.append(densities[-1])
    u0.append(u0[-1])
    u1.append(u1[-1])
    u2.append(u2[-1])
    u3.append(u3[-1])
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
    parser.add_argument('x3min', type=float, help='x3min')
    parser.add_argument('x3max', type=float, help='x3max')
    parser.add_argument('mdt', type=float, help='mdot target')
    parser.add_argument('mdc', type=float, help='mdot code')
    args = parser.parse_args()
    main(**vars(args))
