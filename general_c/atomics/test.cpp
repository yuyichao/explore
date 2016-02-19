//

#include <thread>
#include <atomic>
#include <vector>

#include <assert.h>
#include <string.h>
#include <stdio.h>

__attribute__((noinline)) void f(volatile char *p, char v, char *p1, char *p2)
{
    char v1 = *p;
    *p = v;
    char v2 = *p;
    std::atomic_signal_fence(std::memory_order_seq_cst);
    *p1 = v1;
    *p2 = v2;
}

void check(char vwin, char vlose, char v1win, char v2win,
           char v1lose, char v2lose)
{
    assert(v1win == 0 || v1win == vlose);
    assert(v2win == vwin);
    assert(v1lose == 0);
    assert(v2lose == vlose || v2lose == vwin);
}

void runtest(size_t n)
{
    std::vector<char> a1(n);
    std::vector<char> a11(n);
    std::vector<char> a12(n);
    std::vector<char> a21(n);
    std::vector<char> a22(n);
    memset(&a1[0], 0, n * sizeof(char));
    auto func = [&] (char v, char *p1, char *p2) {
        volatile char *p = &a1[0];
        for (size_t i = 0;i < n;i++) {
            f(&p[i], v, &p1[i], &p2[i]);
        }
    };
    std::thread t1(func, (char)1, &a11[0], &a12[0]);
    std::thread t2(func, (char)2, &a21[0], &a22[0]);
    t1.join();
    t2.join();
    for (size_t i = 0;i < n;i++) {
        assert(a1[i] == 1 || a1[i] == 2);
        if (a1[i] == 1) {
            check(1, 2, a11[i], a12[i], a21[i], a22[i]);
        }
        else {
            assert(a1[i] == 2);
            check(2, 1, a21[i], a22[i], a11[i], a12[i]);
        }
    }
}

int main()
{
    for (int i = 0;i < 1000;i++) {
        if (i % 10 == 0)
            printf("Running: %d\n", i);
        runtest(1000000);
    }
    return 0;
}
