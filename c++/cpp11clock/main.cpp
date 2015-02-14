#include <assert.h>

#include <thread>
#include <chrono>
#include <iostream>

using namespace std::literals::chrono_literals;

int
g(int n)
{
    if (n <= 1)
        return 1;
    return g(n - 1) + g(n - 2);
}

void
f(int n=10)
{
    using namespace std::chrono;
    auto start = high_resolution_clock::now();
    g(n);
    auto end = high_resolution_clock::now();
    auto interval = duration_cast<nanoseconds>(end - start).count();
    std::cout << interval << std::endl;
}

int
main()
{
    for (int i = 0;i < 100;i++) {
        f(i);
    }
    return 0;
}
