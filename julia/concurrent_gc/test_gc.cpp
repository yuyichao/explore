//

#include <string.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <signal.h>

#include <random>
#include <thread>
#include <vector>
#include <atomic>

#define NSLOTS 1000
#define NOBJS 1000000

static int slots[NSLOTS];
static char marked[NOBJS];
static size_t page_size = sysconf(_SC_PAGESIZE);
static auto sp_page = (volatile int*)mmap(nullptr, page_size,
                                          PROT_WRITE | PROT_READ,
                                          MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

static void init(void)
{
    memset(slots, 0, sizeof(slots));
    memset(marked, 0, sizeof(marked));
}

template<typename Func>
static void create_objs(Func &&func)
{
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, NSLOTS - 1);
    for (int i = 0;i < NOBJS;i++) {
        volatile auto *slot = &slots[dis(gen)];
        *slot = i + 1;
        if (func(slot, i + 1)) {
            return;
        }
    }
}

struct Runner {
    std::vector<int> missed_objs;
    virtual const char *name(void) = 0;
    virtual void start_gc(void) = 0;
    virtual void reset(void) = 0;
    virtual bool creator(volatile int*, int) = 0;
    bool run(void)
    {
        init();
        reset();
        missed_objs.empty();
        std::thread creator_thread([&] {
                create_objs([&] (auto slot, auto obj) {
                        return this->creator(slot, obj);
                    });
            });
        while (__atomic_load_n(&slots[10], __ATOMIC_ACQUIRE) == 0) {
        }
        start_gc();
        for (int i = 0;i < NSLOTS;i++) {
            int obj = slots[i];
            if (obj != 0) {
                marked[obj - 1] = 1;
            }
        }
        creator_thread.join();
        for (auto obj: missed_objs)
            marked[obj - 1] = 1;
        for (int i = 0;i < NSLOTS;i++) {
            int obj = slots[i];
            if (obj != 0 && marked[obj - 1] == 0) {
                printf("    Missed object: %d\n", obj);
                return false;
            }
        }
        return true;
    }
};

struct NaiveGC : Runner {
    bool gc_running{false};
    const char *name(void) override
    {
        return "Naive";
    }
    void start_gc(void) override
    {
        gc_running = true;
    }
    void reset(void) override
    {
        gc_running = false;
    }
    bool creator(volatile int*, int obj) override
    {
        if (!gc_running)
            return false;
        missed_objs.push_back(obj);
        return true;
    }
};

struct SeqCstGC : Runner {
    std::atomic_bool gc_running{false};
    const char *name(void) override
    {
        return "SeqCst";
    }
    void start_gc(void) override
    {
        gc_running = true;
        std::atomic_thread_fence(std::memory_order_seq_cst);
    }
    void reset(void) override
    {
        gc_running = false;
    }
    bool creator(volatile int*, int obj) override
    {
        std::atomic_thread_fence(std::memory_order_seq_cst);
        if (!gc_running)
            return false;
        missed_objs.push_back(obj);
        return true;
    }
};

static volatile bool safepoint_triggered = false;

struct SafepointGC : Runner {
    const char *name(void) override
    {
        return "Safepoint";
    }
    void start_gc(void) override
    {
        mprotect((void*)sp_page, sysconf(_SC_PAGESIZE), PROT_NONE);
    }
    void reset(void) override
    {
        safepoint_triggered = false;
        mprotect((void*)sp_page, sysconf(_SC_PAGESIZE), PROT_READ | PROT_WRITE);
    }
    bool creator(volatile int*, int obj) override
    {
        // std::atomic_signal_fence(std::memory_order_seq_cst);
        asm volatile ("" ::: "memory");
        int dummy = *sp_page;
        (void)dummy;
        if (safepoint_triggered) {
            missed_objs.push_back(obj);
            return true;
        }
        return false;
    }
};

template<typename T>
static void run_gc(T &&gc)
{
    printf("Running %s\n", gc.name());
    bool pass = true;
    for (int i = 0;i < 100000;i++) {
        if (!gc.run()) {
            printf("    Failed in run %d\n", i);
            pass = false;
            break;
        }
    }
    if (pass) {
        printf("    Passed\n");
    }
}

static void segv_handler(int, siginfo_t*, void*)
{
    safepoint_triggered = true;
    mprotect((void*)sp_page, page_size, PROT_READ | PROT_WRITE);
}

int main()
{
    struct sigaction act;
    memset(&act, 0, sizeof(struct sigaction));
    sigemptyset(&act.sa_mask);
    act.sa_sigaction = segv_handler;
    act.sa_flags = SA_SIGINFO;
    sigaction(SIGSEGV, &act, NULL);
    // run_gc(NaiveGC());
    // run_gc(SeqCstGC());
    run_gc(SafepointGC());
    return 0;
}
