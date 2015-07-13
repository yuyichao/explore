//

#include <stdint.h>

struct Propagator1D {
    int64_t nstep;
    double T11;
    double T12;
    __attribute__((noinline)) void propagate(double *psis, double gamma);
};
