//

#include <cmath>
#include <chrono>

#include <stdio.h>
#include <stdint.h>

static inline uint64_t
getTime()
{
    using namespace std::chrono;
    return time_point_cast<nanoseconds>(high_resolution_clock::now())
        .time_since_epoch().count();
}

struct Propagator1D {
    int64_t nstep;
    double T11;
    double T12;
    __attribute__((noinline)) void
    propagate(double *psis, double gamma)
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
};

int
main()
{
    double omega = 0.3;
    Propagator1D P{1000000, std::cos(omega), std::sin(omega)};

    double psis[2];

    for (double g = 0;g <= 2;g += 0.05) {
        auto tstart = getTime();
        P.propagate(psis, g);
        auto tend = getTime();
        printf("g = %.2f, time: %.5f ms\n", g, double(tend - tstart) / 1e6);
    }

    return 0;
}
