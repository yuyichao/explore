//

#include <string.h>
#include <stdio.h>
#include <random>
#include <thread>
#include <vector>
#include <atomic>

#define NSLOTS 1000
#define NOBJS 1000000

static int slots[NSLOTS];
static char marked[NOBJS];

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

int main()
{
    run_gc(NaiveGC());
    run_gc(SeqCstGC());
    return 0;
}
