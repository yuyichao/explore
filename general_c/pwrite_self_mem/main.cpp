//

#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <assert.h>

static void *try_allocate_high_page(void)
{
    uintptr_t addr_lb = uintptr_t(1) << (sizeof(void*) * 8 - 1);
    uintptr_t addr_ub = addr_lb + 1024 * 1024 * 1024;
    size_t pgsz = sysconf(_SC_PAGESIZE);
    for (uintptr_t addr = addr_lb; addr <= addr_ub; addr += pgsz) {
        void *res = mmap((void*)addr, pgsz, PROT_READ | PROT_EXEC,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (res != MAP_FAILED) {
            fprintf(stderr, "Allocated high page at %p\n", res);
            return res;
        }
    }
    return nullptr;
}

static bool write_mem_pwrite(uint32_t *ptr, uint32_t val)
{
    static int fd = open("/proc/self/mem", O_RDWR);
    if (fd == -1) {
        fprintf(stderr, "Open /proc/self/mem failed\n");
        return false;
    }
    auto res = pwrite(fd, &val, 4, (uintptr_t)ptr);
    return res == 4;
}

static void try_write_mem_pwrite(void *ptr)
{
    auto ptr32 = static_cast<uint32_t*>(ptr);
    if (!write_mem_pwrite(ptr32, 123)) {
        fprintf(stderr, "pwrite at %p failed\n", ptr32);
    }
    else if (ptr32[0] != 123) {
        fprintf(stderr, "pwrite at %p did not write the correct value\n", ptr32);
    }
    if (!write_mem_pwrite(&ptr32[5], 123)) {
        fprintf(stderr, "pwrite at %p failed\n", &ptr32[5]);
    }
    else if (ptr32[5] != 123) {
        fprintf(stderr, "pwrite at %p did not write the correct value\n", &ptr32[5]);
    }
}

int main()
{
    auto ptr = try_allocate_high_page();
    if (!ptr) {
        fprintf(stderr, "Can't allocate high page\n");
        return 1;
    }
    try_write_mem_pwrite(ptr);
    return 0;
}
