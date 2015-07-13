//

#include "propagate.h"

#include <stdint.h>

void
Propagator1D::propagate(double *psis, double gamma)
{
    psis[0] = 1;
    psis[1] = 0;
    for (int64_t i = 0;i < nstep;i++) {
        double psi_e = psis[0];
        double psi_g = psis[1] * gamma;
        psis[1] = T11 * psi_e + T12 * psi_g;
        psis[0] = T11 * psi_g - T12 * psi_e;
    }
}
