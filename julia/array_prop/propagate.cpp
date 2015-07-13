//

#include <vector>
#include <cmath>
#include <chrono>

#include <stdio.h>
#include <stdint.h>

uint64_t
getTime()
{
    using namespace std::chrono;
    return time_point_cast<nanoseconds>(high_resolution_clock::now())
        .time_since_epoch().count();
}

struct Propagator1D {
    double omega;
    int64_t nstep;
    int64_t nele;
    __attribute__((noinline)) void
    propagate(std::vector<double> &psi0, std::vector<double> &psis,
              double gamma)
    {
        for (int64_t i = 0;i < nele;i++) {
            psis[i * 2] = psi0[i * 2];
            psis[i * 2 + 1] = psi0[i * 2 + 1];
        }
        double T12 = std::sin(omega);
        double T11 = std::cos(omega);
        for (int64_t i = 0;i < nstep;i++) {
            for (int64_t j = 0;j < nele;j++) {
                double psi_e = psis[j * 2];
                double psi_g = psis[j * 2 + 1] * gamma;
                psis[j * 2 + 1] = T11 * psi_e + T12 * psi_g;
                psis[j * 2] = T11 * psi_g - T12 * psi_e;
            }
        }
    }
};

int
main()
{
    int64_t grid_size = 256;
    double grid_space = 0.01;

    double x_center = (grid_size + 1) * grid_space / 2;

    std::vector<double> psi0(2 * grid_size);

    for (int64_t i = 0;i < grid_size;i++) {
        double x = (i * grid_space - x_center + 0.2) / 0.3;
        double psi = exp(-x * x);
        psi0[i * 2] = psi;
        psi0[i * 2 + 1] = 0;
    }

    Propagator1D P{2 * 3.1415926 * 10.0 * 0.005, 10000, grid_size};

    std::vector<double> psis(2 * P.nele);

    for (double g = 0;g < 1;g += 0.05) {
        auto tstart = getTime();
        P.propagate(psi0, psis, g);
        auto tend = getTime();
        printf("g = %.2f, time: %.3f ms\n", g, double(tend - tstart) / 1e6);
    }

    return 0;
}
