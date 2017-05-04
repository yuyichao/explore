//

#include <thread>
#include <vector>
#include <random>

#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <sys/mman.h>
#include <assert.h>

static __thread int thread_id;

struct thread_data_t {
    uint8_t padding[128];
    volatile uintptr_t self_count;
    volatile uintptr_t other_count;
    int other_id;
    bool triggered;
};

static std::vector<thread_data_t> thread_datas;

static volatile uint32_t *page;

static bool thread_done = false;

#if defined(__x86_64__) || defined(__i386__)
#  include <immintrin.h>
#  define cpu_pause() _mm_pause()
#  define cpu_wake() ((void)0)
#elif defined(__aarch64__) || defined(__arm__)
#  define cpu_pause() asm volatile ("wfe" ::: "memory")
#  define cpu_wake() asm volatile ("sev" ::: "memory")
#else
#  define cpu_pause() ((void)0)
#  define cpu_wake() ((void)0)
#endif

static void segv_handler(int, siginfo_t*, void*)
{
    int tid = thread_id;
    thread_data_t &data = thread_datas[tid];
    __atomic_store_n(&data.triggered, true, __ATOMIC_RELAXED);
    const thread_data_t &other_data = thread_datas[data.other_id];
    data.other_count = other_data.self_count;
    while (1) {
        if (__atomic_load_n(&thread_done, __ATOMIC_RELAXED))
            return;
        cpu_pause();
    }
}

static void run_thread_loop(int tid)
{
    thread_id = tid;
    thread_data_t &data = thread_datas[tid];
    auto &self_count = data.self_count;
    while (*page == 0) {
        self_count += 1;
    }
}

static int run_n_threads(int n)
{
    thread_done = false;
    thread_datas.resize(n);
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, n - 1);
    for (int i = 0;i < n;i++) {
        auto &data = thread_datas[i];
        data.self_count = 0;
        data.triggered = false;
        data.other_id = dis(gen);
    }
    page = (uint32_t*)mmap(0, 4096, PROT_READ, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    std::vector<std::thread> threads;
    for (int i = 0;i < n;i++) {
        threads.emplace_back(run_thread_loop, i);
    }
    usleep(100);
    mprotect((void*)page, 4096, PROT_NONE);
    // wait for all thread to segfault
    for (int i = 0;i < n;i++) {
        auto &data = thread_datas[i];
        while (1) {
            if (__atomic_load_n(&data.triggered, __ATOMIC_RELAXED))
                break;
            cpu_pause();
        }
    }
    mprotect((void*)page, 4096, PROT_READ | PROT_WRITE);
    *page = 1;
    thread_done = true;
    int violation = 0;
    for (int i = 0;i < n;i++) {
        auto &data = thread_datas[i];
        auto other_count = data.other_count;
        auto real_other_count = thread_datas[data.other_id].self_count;
        if (other_count != real_other_count && other_count + 1 != real_other_count) {
            violation += 1;
            printf("%d, %zu, %zu\n", data.other_id, other_count, real_other_count);
        }
        threads[i].join();
    }
    munmap((void*)page, 4096);
    page = nullptr;
    return violation;
}

int main(int argc, char *argv[])
{
    assert(argc >= 3);
    struct sigaction act;
    memset(&act, 0, sizeof(struct sigaction));
    sigemptyset(&act.sa_mask);
    act.sa_sigaction = segv_handler;
    act.sa_flags = SA_SIGINFO;
    sigaction(SIGSEGV, &act, NULL);
    int nt = atoi(argv[1]);
    int n = atoi(argv[2]);
    for (int i = 0;i < n;i++) {
        if (int violation = run_n_threads(nt)) {
            printf("%d\n", violation);
        }
    }
    return 0;
}
