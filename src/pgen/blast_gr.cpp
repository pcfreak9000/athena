// Spherical blast wave generator for general relativistic hydrodynamics

// Primary header
#include "../mesh.hpp"

// C++ headers
#include <algorithm>  // min()
#include <cmath>      // sqrt()

// Athena headers
#include "../athena.hpp"                   // enums, Real
#include "../athena_arrays.hpp"            // AthenaArray
#include "../coordinates/coordinates.hpp"  // Coordinates
#include "../field/field.hpp"              // Field
#include "../fluid/fluid.hpp"              // Fluid
#include "../fluid/eos/eos.hpp"            // GetGamma()
#include "../parameter_input.hpp"          // ParameterInput

// Function for setting initial conditions
// Inputs:
//   pfl: Fluid
//   pfd: Field
//   pin: parameters
// Outputs: (none)
// Notes:
//   sets conserved variables according to input primitives
void Mesh::ProblemGenerator(Fluid *pfl, Field *pfd, ParameterInput *pin)
{
  // Prepare index bounds
  MeshBlock *pb = pfl->pmy_block;
  int il = pb->is - NGHOST;
  int iu = pb->ie + NGHOST;
  int jl = pb->js;
  int ju = pb->je;
  if (pb->block_size.nx2 > 1)
  {
    jl -= (NGHOST);
    ju += (NGHOST);
  }
  int kl = pb->ks;
  int ku = pb->ke;
  if (pb->block_size.nx3 > 1)
  {
    kl -= (NGHOST);
    ku += (NGHOST);
  }

  // Get ratio of specific heats
  Real gamma_adi = pfl->pf_eos->GetGamma();
  Real gamma_adi_red = gamma_adi / (gamma_adi - 1.0);

  // Read problem parameters
  Real num_x = pin->GetReal("problem", "num_x");
  Real num_y = pin->GetReal("problem", "num_y");
  Real x_spacing = pin->GetReal("problem", "x_spacing");
  Real y_spacing = pin->GetReal("problem", "y_spacing");
  Real radius = pin->GetReal("problem", "radius");
  Real rho_inner = pin->GetReal("problem", "rho_inner");
  Real pgas_inner = pin->GetReal("problem", "pgas_inner");
  Real rho_outer = pin->GetReal("problem", "rho_outer");
  Real pgas_outer = pin->GetReal("problem", "pgas_outer");
  Real bx = 0.0, by = 0.0, bz = 0.0;
  if (MAGNETIC_FIELDS_ENABLED)
  {
    bx = pin->GetReal("problem", "bx");
    by = pin->GetReal("problem", "by");
    bz = pin->GetReal("problem", "bz");
  }

  // Prepare auxiliary arrays
  int ncells1 = pfl->pmy_block->block_size.nx1 + 2*NGHOST;
  int ncells2 = pfl->pmy_block->block_size.nx2;
  if (ncells2 > 1)
    ncells2 += 2*NGHOST;
  int ncells3 = pfl->pmy_block->block_size.nx3;
  if (ncells3 > 1)
    ncells3 += 2*NGHOST;
  AthenaArray<Real> b, g, gi;
  b.NewAthenaArray(3,ncells3,ncells2,ncells1);
  g.NewAthenaArray(NMETRIC,ncells1);
  gi.NewAthenaArray(NMETRIC,ncells1);

  // Initialize hydro variables
  for (int k = kl; k <= ku; k++)
    for (int j = jl; j <= ju; j++)
    {
      pfl->pmy_block->pcoord->CellMetric(k, j, g, gi);
      for (int i = il; i <= iu; i++)
      {
        // Calculate distance to nearest blast center
        Real x1 = pb->x1v(i);
        Real x2 = pb->x2v(j);
        Real x3 = pb->x3v(k);
        Real min_separation = pb->pcoord->DistanceBetweenPoints(x1, x2, x3, 0.0, 0.0,
            0.0);
        for (int x_index = -num_x; x_index <= num_x; ++x_index)
        {
          Real center_x = x_index * x_spacing;
          for (int y_index = -num_y; y_index <= num_y; ++y_index)
          {
            if (x_index == 0 && y_index == 0)
              continue;
            Real center_y = y_index * y_spacing; 
            min_separation = std::min(min_separation,
                pb->pcoord->DistanceBetweenPoints(x1, x2, x3, center_x, center_y, 0.0));
          }
        }

        // Set primitives
        Real rho, pgas;
        if (min_separation < radius)
        {
          rho = rho_inner;
          pgas = pgas_inner;
        }
        else
        {
          rho = rho_outer;
          pgas = pgas_outer;
        }
        pfl->w(IDN,k,j,i) = pfl->w1(IDN,k,j,i) = rho;
        pfl->w(IEN,k,j,i) = pfl->w1(IEN,k,j,i) = pgas;
        pfl->w(IVX,k,j,i) = pfl->w1(IM1,k,j,i) = 0.0;
        pfl->w(IVY,k,j,i) = pfl->w1(IM2,k,j,i) = 0.0;
        pfl->w(IVZ,k,j,i) = pfl->w1(IM3,k,j,i) = 0.0;

        // Calculate cell-centered magnetic fields given Minkowski values
        Real ut = 1.0;
        Real ux = 0.0;
        Real uy = 0.0;
        Real uz = 0.0;
        Real bcont = 0.0;
        Real bconx = bx;
        Real bcony = by;
        Real bconz = bz;
        Real u0, u1, u2, u3;
        Real bcon0, bcon1, bcon2, bcon3;
        pb->pcoord->TransformVectorCell(ut, ux, uy, uz, k, j, i,
            &u0, &u1, &u2, &u3);
        pb->pcoord->TransformVectorCell(bcont, bconx, bcony, bconz, k, j, i,
            &bcon0, &bcon1, &bcon2, &bcon3);
        b(IB1,k,j,i) = bcon1 * u0 - bcon0 * u1;
        b(IB2,k,j,i) = bcon2 * u0 - bcon0 * u2;
        b(IB3,k,j,i) = bcon3 * u0 - bcon0 * u3;
      }
    }
  pb->pcoord->PrimToCons(pfl->w, b, gamma_adi_red, pfl->u);

  // Delete auxiliary arrays
  b.DeleteAthenaArray();
  g.DeleteAthenaArray();
  gi.DeleteAthenaArray();

  // Initialize magnetic field
  if (MAGNETIC_FIELDS_ENABLED)
    for (int k = kl; k <= ku+1; k++)
      for (int j = jl; j <= ju+1; j++)
        for (int i = il; i <= iu+1; i++)
        {
          Real ut = 1.0;
          Real ux = 0.0;
          Real uy = 0.0;
          Real uz = 0.0;
          Real bcont = 0.0;
          Real bconx = bx;
          Real bcony = by;
          Real bconz = bz;
          Real u0, u1, u2, u3;
          Real bcon0, bcon1, bcon2, bcon3;
          if (j != ju+1 && k != ku+1)
          {
            pb->pcoord->TransformVectorFace1(ut, ux, uy, uz, k, j, i,
                &u0, &u1, &u2, &u3);
            pb->pcoord->TransformVectorFace1(bcont, bconx, bcony, bconz, k, j, i,
                &bcon0, &bcon1, &bcon2, &bcon3);
            pfd->b.x1f(k,j,i) = bcon1 * u0 - bcon0 * u1;
          }
          if (i != iu+1 && k != ku+1)
          {
            pb->pcoord->TransformVectorFace2(ut, ux, uy, uz, k, j, i,
                &u0, &u1, &u2, &u3);
            pb->pcoord->TransformVectorFace2(bcont, bconx, bcony, bconz, k, j, i,
                &bcon0, &bcon1, &bcon2, &bcon3);
            pfd->b.x2f(k,j,i) = bcon2 * u0 - bcon0 * u2;
          }
          if (i != iu+1 && j != ju+1)
          {
            pb->pcoord->TransformVectorFace3(ut, ux, uy, uz, k, j, i,
                &u0, &u1, &u2, &u3);
            pb->pcoord->TransformVectorFace3(bcont, bconx, bcony, bconz, k, j, i,
                &bcon0, &bcon1, &bcon2, &bcon3);
            pfd->b.x3f(k,j,i) = bcon3 * u0 - bcon0 * u3;
          }
        }
  return;
}