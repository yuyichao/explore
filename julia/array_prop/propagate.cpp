//

#include "propagate.h"

#include <stdint.h>

#define __ldmxcsr(__csr) __asm __volatile("ldmxcsr %0" : : "m" (__csr))
#define __stmxcsr(__csr) __asm __volatile("stmxcsr %0" : "=m" (*(__csr)))

void
Propagator1D::propagate(double *psis, double gamma)
{
    uint32_t csr;
    uint32_t old_csr;
    __stmxcsr(&old_csr);
    csr = old_csr | 0x8040;
    __ldmxcsr(csr);
    psis[0] = 1;
    psis[1] = 0;
    for (int64_t i = 0;i < nstep;i++) {
        double psi_e = psis[0];
        double psi_g = psis[1] * gamma;
        psis[1] = T11 * psi_e + T12 * psi_g;
        psis[0] = T11 * psi_g - T12 * psi_e;
    }
    __ldmxcsr(old_csr);
}
