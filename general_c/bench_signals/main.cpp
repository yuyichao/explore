//

#include <time.h>
#include <signal.h>
#include <stdio.h>
#include <atomic>
#include <thread>
#include <mutex>

static uint64_t get_time_ns(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * uint64_t(1000000000) + t.tv_nsec;
}

static std::atomic_bool ready;

static void handle_usr2(int)
{
    ready.store(true, std::memory_order_release);
}

static uint64_t test_on_thread(pthread_t thread, size_t n)
{
    auto tstart = get_time_ns();
    for (size_t i = 0;i < n;i++) {
        ready = false;
        pthread_kill(thread, SIGUSR2);
        while (!ready.load(std::memory_order_acquire)) {}
    }
    auto tend = get_time_ns();
    return tend - tstart;
}

int main()
{
    signal(SIGUSR2, handle_usr2);
    auto nself = 1000000L;
    auto tself = test_on_thread(pthread_self(), nself);
    printf("tself: %.3f us\n", double(tself) / nself / 1000);

    std::mutex lock;
    lock.lock();
    std::thread thread([&] {
            lock.lock();
            lock.unlock();
        });
    auto nother = 1000000L;
    auto tother = test_on_thread(thread.native_handle(), nother);
    printf("tother: %.3f us\n", double(tother) / nother / 1000);
    lock.unlock();
    thread.join();
    return 0;
}
