//

#include "propagate.h"

#include <chrono>
#include <cmath>

#include <stdio.h>

static inline uint64_t
getTime()
{
    using namespace std::chrono;
    return time_point_cast<nanoseconds>(high_resolution_clock::now())
        .time_since_epoch().count();
}

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
