//

#include <atomic>
#include <thread>
#include <condition_variable>
#include <iostream>
#include <time.h>
#include <stdint.h>

uint64_t get_time_ns()
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec * uint64_t(1000000000) + t.tv_nsec;
}

class Barrier
{
    std::mutex m_mutex;
    std::condition_variable m_cv;
    std::size_t m_count;
public:
    explicit Barrier(std::size_t count) : m_count{count} { }
    void wait()
    {
        std::unique_lock<std::mutex> lock{m_mutex};
        if (--m_count == 0) {
            m_cv.notify_all();
        } else {
            m_cv.wait(lock, [this] { return m_count == 0; });
        }
    }
};

template<typename Lock>
static void test_lock(size_t n=100000L)
{
    Lock lock1;
    Lock lock2;
    Lock lock3;
    Barrier b_start(3);
    Barrier b_loop1(3);
    Barrier b_loop2(3);
    Barrier b_end(3);
    auto test_lock_loop = [&] {
        auto t_start = get_time_ns();
        lock1.lock();
        for (size_t i = 0;i < n;i++) {
            lock2.lock();
            lock1.unlock();

            lock3.lock();
            lock2.unlock();

            lock1.lock();
            lock3.unlock();
        }
        lock1.unlock();
        return get_time_ns() - t_start;
    };
    auto test_lock_loop2 = [&] {
        auto t_start = get_time_ns();
        for (size_t i = 0;i < n;i++) {
            lock2.lock();
            lock2.unlock();
        }
        return get_time_ns() - t_start;
    };
    uint64_t tlock_loop1_1;
    uint64_t tlock_loop1_2;
    uint64_t tlock_loop2_1;
    uint64_t tlock_loop2_2;
    uint64_t tlock_loop3_1;
    std::thread t1([&] {
            b_start.wait();
            tlock_loop1_1 = test_lock_loop();
            b_loop1.wait();
            tlock_loop2_1 = test_lock_loop2();
            b_loop2.wait();
            tlock_loop3_1 = test_lock_loop2();
            b_end.wait();
        });
    std::thread t2([&] {
            b_start.wait();
            tlock_loop1_2 = test_lock_loop();
            b_loop1.wait();
            tlock_loop2_2 = test_lock_loop2();
            b_loop2.wait();
            b_end.wait();
        });
    b_start.wait();
    b_loop1.wait();
    b_loop2.wait();
    b_end.wait();
    t1.join();
    t2.join();
    printf("Loop1: %.1f ns, %.1f ns\n", tlock_loop1_1 / (double)n,
           tlock_loop1_2 / (double)n);
    printf("Loop2: %.1f ns, %.1f ns\n", tlock_loop2_1 / (double)n,
           tlock_loop2_2 / (double)n);
    printf("Loop3: %.1f ns\n", tlock_loop3_1 / (double)n);
}

template<bool yield=false>
class SpinLock {
    std::atomic_bool m_spin;
public:
    SpinLock()
        : m_spin(false)
    {}
    inline void
    lock()
    {
        while (m_spin.exchange(true)) {
            if (yield)
                std::this_thread::yield();
#if defined(__i386__) || defined(__x86_64__)
            __asm__ __volatile__ ("pause");
#endif
        }
    }
    inline void
    unlock()
    {
        m_spin = false;
    }
};

class PthreadMutex {
    pthread_mutex_t m_lock;
public:
    inline
    PthreadMutex()
        : m_lock()
    {
        pthread_mutex_init(&m_lock, nullptr);
    }
    inline
    ~PthreadMutex()
    {
        pthread_mutex_destroy(&m_lock);
    }
    inline void
    lock()
    {
        pthread_mutex_lock(&m_lock);
    }
    inline void
    unlock()
    {
        pthread_mutex_unlock(&m_lock);
    }
};

class PthreadHybridMutex {
    pthread_mutex_t m_lock;
public:
    inline
    PthreadHybridMutex()
        : m_lock()
    {
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_ADAPTIVE_NP);
        pthread_mutex_init(&m_lock, &attr);
        pthread_mutexattr_destroy(&attr);
    }
    inline
    ~PthreadHybridMutex()
    {
        pthread_mutex_destroy(&m_lock);
    }
    inline void
    lock()
    {
        pthread_mutex_lock(&m_lock);
    }
    inline void
    unlock()
    {
        pthread_mutex_unlock(&m_lock);
    }
};

int main()
{
    test_lock<SpinLock<true>>(1000000L);
    test_lock<SpinLock<false>>(1000000L);
    test_lock<PthreadMutex>();
    test_lock<PthreadHybridMutex>();
    return 0;
}
