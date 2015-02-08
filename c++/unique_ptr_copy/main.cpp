#include <assert.h>

#include <iostream>
#include <memory>

struct Dummy {
};

struct DummyDeleter {
    template<typename T>
    inline void
    operator()(T *p)
    {
        std::cout << "unref: " << (void*)p << std::endl;
    }
    template<typename T>
    inline void
    ref(T *p)
    {
        std::cout << "ref: " << (void*)p << std::endl;
    }
};

template<typename T, typename D>
class RefPtr : public std::unique_ptr<T, D> {
public:
    constexpr
    RefPtr()
        : std::unique_ptr<T, D>()
    {
    }
    RefPtr(T *p)
        : std::unique_ptr<T, D>(p)
    {
        if (p) {
            this->get_deleter().ref(p);
        }
    }
    RefPtr(const RefPtr &other)
        : RefPtr(other.get())
    {
    }
    RefPtr(RefPtr &&other)
        : std::unique_ptr<T, D>(std::move(other))
    {
    }
};

class DumPtr: public RefPtr<Dummy, DummyDeleter> {
public:
    using RefPtr<Dummy, DummyDeleter>::RefPtr;
};

static inline void
testFunc2(DumPtr &&ptr)
{
    DumPtr ptr2 = std::move(ptr);
    DumPtr ptr3 = std::move(ptr2);
    DumPtr ptr4 = ptr3;
}

static inline void
testFunc()
{
    testFunc2(new Dummy);
    testFunc2(nullptr);
}

int
main()
{
    testFunc();
    return 0;
}
