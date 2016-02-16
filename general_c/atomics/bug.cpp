//

#include <atomic>
#include <thread>
#include <assert.h>

void store_release(std::atomic_int &a, int &b)
{
    b = 2;
    a.store(1, std::memory_order_release);
    b = 3;
}

void load_acquire(std::atomic_int &a, int &b)
{
    if (a.load(std::memory_order_acquire)) {
        assert(b >= 2);
    }
}

int main()
{
    static const int n = 1000000;
    std::atomic_int a[n];
    int b[n];
    for (int i = 0;i < n;i++) {
        a[i].store(0);
        b[i] = 0;
    }
    std::thread stores([&] {
            for (int i = 0;i < n;i++) {
                store_release(a[i], b[i]);
            }
        });
    std::thread loads([&] {
            for (int i = 0;i < n;i++) {
                load_acquire(a[i], b[i]);
            }
        });
    stores.join();
    loads.join();
    return 0;
}
