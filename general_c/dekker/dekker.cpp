//

#include <thread>
#include <stdint.h>
#include <stdio.h>

int thread1_lock __attribute__((aligned(128))) = 0;
int thread2_lock __attribute__((aligned(128))) = 0;

void thread_fun_naive(volatile int *self_lock, volatile int *other_lock, int num, int *gp)
{
    // This obviously doesn't work
    auto try_lock = [&] () {
        *self_lock = 1;
        if (*other_lock == 0)
            return true;
        *self_lock = 0;
        return false;
    };
    for (int i = 0;i < num;i++) {
        while (!try_lock()) {
            asm volatile ("pause" ::: "memory");
        }
        *gp += 1;
        *self_lock = 0;
    }
}

void thread_fun_seq_cst(int *self_lock, int *other_lock, int num, int *gp)
{
    auto try_lock = [&] () {
        __atomic_store_n(self_lock, 1, __ATOMIC_SEQ_CST);
        if (__atomic_load_n(other_lock, __ATOMIC_SEQ_CST) == 0)
            return true;
        __atomic_store_n(self_lock, 0, __ATOMIC_RELEASE);
        return false;
    };
    for (int i = 0;i < num;i++) {
        while (!try_lock()) {
            asm volatile ("pause" ::: "memory");
        }
        *gp += 1;
        __atomic_store_n(self_lock, 0, __ATOMIC_RELEASE);
    }
}

void thread_fun_atomic(int*, int*, int num, int *gp)
{
    for (int i = 0;i < num;i++) {
        __atomic_add_fetch(gp, 1, __ATOMIC_RELAXED);
    }
}

void thread_fun_acq_rel(volatile int *self_lock, volatile int *other_lock, int num, int *gp)
{
    auto try_lock = [&] () {
        __atomic_store_n(self_lock, 1, __ATOMIC_RELEASE);
        // The two load that follows does not guarantee correctness
        // Semantically this is caused by the absence of a global ordering.
        // Acquire load only sync with release store but not other aquire loads on other threads
        // This thread is not allowed to reorder the two but multiple threads does not need to
        // agree on this unless one of the load observes the result of a release store on the
        // other thread.
        // In the hardware (on x86) this is likely because of load re-ordering due to
        // write buffer bypassing.
        int self = __atomic_load_n(self_lock, __ATOMIC_ACQUIRE);
        int other = __atomic_load_n(other_lock, __ATOMIC_ACQUIRE);
        if (self == 1 && other == 0)
            return true;
        __atomic_store_n(self_lock, 0, __ATOMIC_RELEASE);
        return false;
    };
    for (int i = 0;i < num;i++) {
        while (!try_lock()) {
            asm volatile ("pause" ::: "memory");
        }
        *gp += 1;
        __atomic_store_n(self_lock, 0, __ATOMIC_RELEASE);
    }
}

template<typename F>
int run_func(F f, int num)
{
    int counter = 0;
    std::thread t1([&] () {
            f(&thread1_lock, &thread2_lock, num, &counter);
        });
    std::thread t2([&] () {
            f(&thread2_lock, &thread1_lock, num, &counter);
        });
    t1.join();
    t2.join();
    return counter;
}

int main()
{
    int counter = run_func(thread_fun_naive, 1000000);
    printf("Naive: %d\n", counter);
    counter = run_func(thread_fun_seq_cst, 1000000);
    printf("Seq-Cst: %d\n", counter);
    counter = run_func(thread_fun_atomic, 1000000);
    printf("Atomic: %d\n", counter);
    counter = run_func(thread_fun_acq_rel, 1000000);
    printf("Acq-Rel: %d\n", counter);
    return 0;
}
