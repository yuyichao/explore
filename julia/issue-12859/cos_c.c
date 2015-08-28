//

#include <math.h>

double __attribute__((noinline))
call_cos(double t)
{
    return cos(t);
}

void cos_c(double start_val, double end_val, long n)
{
    double step = 1e-6;
    for (double t = start_val;t < end_val;t += step) {
        for (long i = 0;i < n;i++) {
            /* call_cos(t); */
            cos(t);
        }
    }
}
