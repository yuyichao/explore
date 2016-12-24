//

#include <string.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <signal.h>
#include <ucontext.h>

#include <random>
#include <thread>
#include <vector>
#include <atomic>

#define NSLOTS 1000
#define NOBJS 100000

static int slots[NSLOTS];
static char marked[NOBJS];
static size_t page_size = sysconf(_SC_PAGESIZE);
static auto sp_page = (volatile int*)mmap(nullptr, page_size,
                                          PROT_WRITE | PROT_READ,
                                          MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
static std::vector<int> missed_objs;

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

struct NaiveGC {
    bool gc_running{false};
    const char *name(void)
    {
        return "Naive";
    }
    inline void start_gc(void)
    {
        gc_running = true;
    }
    void reset(void)
    {
        gc_running = false;
    }
    inline bool creator(volatile int*, int obj)
    {
        if (!gc_running)
            return false;
        missed_objs.push_back(obj);
        return true;
    }
};

struct SeqCstGC {
    std::atomic_bool gc_running{false};
    const char *name(void)
    {
        return "SeqCst";
    }
    inline void start_gc(void)
    {
        gc_running = true;
        std::atomic_thread_fence(std::memory_order_seq_cst);
    }
    void reset(void)
    {
        gc_running = false;
    }
    inline bool creator(volatile int*, int obj)
    {
        std::atomic_thread_fence(std::memory_order_seq_cst);
        if (!gc_running)
            return false;
        missed_objs.push_back(obj);
        return true;
    }
};

static volatile bool safepoint_triggered = false;

struct SafepointGC {
    const char *name(void)
    {
        return "Safepoint";
    }
    inline void start_gc(void)
    {
        mprotect((void*)sp_page, sysconf(_SC_PAGESIZE), PROT_NONE);
    }
    void reset(void)
    {
        safepoint_triggered = false;
        mprotect((void*)sp_page, sysconf(_SC_PAGESIZE), PROT_READ | PROT_WRITE);
    }
    inline bool creator(volatile int*, int obj)
    {
#ifdef __aarch64__
        asm volatile ("ldr %0, [%1]\n"
                      : "+r" (obj)
                      : "r" (sp_page)
                      : "memory");
        return obj;
#else
        asm volatile ("" ::: "memory");
        int dummy = *sp_page;
        (void)dummy;
        if (safepoint_triggered) {
            missed_objs.push_back(obj);
            return true;
        }
        return false;
#endif
    }
};

template<typename T>
static bool run_gc_once(T &&gc)
{
    init();
    gc.reset();
    missed_objs.clear();
    std::thread creator_thread([&] {
            create_objs([&] (auto slot, auto obj) {
                    return gc.creator(slot, obj);
                });
        });
    while (__atomic_load_n(&slots[10], __ATOMIC_ACQUIRE) == 0) {
    }
    gc.start_gc();
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

template<typename T>
static void run_gc(T &&gc)
{
    printf("Running %s\n", gc.name());
    bool pass = true;
    for (int i = 0;i < 100000;i++) {
        if (!run_gc_once(std::forward<T>(gc))) {
            printf("    Failed in run %d\n", i);
            pass = false;
            break;
        }
    }
    if (pass) {
        printf("    Passed\n");
    }
}

static void segv_handler(int, siginfo_t*, void *_ctx)
{
#ifdef __aarch64__
    ucontext_t *ctx = (ucontext_t*)_ctx;
    uint32_t *pc = (uint32_t*)ctx->uc_mcontext.pc;
    ctx->uc_mcontext.pc = uintptr_t(ctx->uc_mcontext.pc) + 4;
    uint32_t ldr = *pc;
    int reg = ldr & 0x1f;
    int obj = (int)ctx->uc_mcontext.regs[reg];
    missed_objs.push_back(obj);
    ctx->uc_mcontext.regs[reg] = 1;
#else
    safepoint_triggered = true;
    mprotect((void*)sp_page, page_size, PROT_READ | PROT_WRITE);
#endif
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
