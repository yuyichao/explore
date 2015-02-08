//

struct B {
    void mem();
    void mem(int);
};

void B::mem()
{
}

void B::mem(int)
{
}

struct C : public B {
    void mem2();
    void mem3();
    void mem3(int);
};

void C::mem2()
{
}

void C::mem3()
{
}

void C::mem3(int)
{
}

template<typename... Args, typename Class>
static inline auto
temp_func(const Class&, void (Class::*v)(Args...)) -> decltype(v)
{
    return v;
}

// template<typename... Args, typename Class>
// static inline auto
// temp_func(Class &c, void (Class::*v)(Args...)) -> decltype(v)
// {
//     return v;
// }

#define mem_ptr(c, name) &decltype(c)::name

#define temp_macro(c, name, args...)            \
    temp_func<args>(&decltype(c)::name)

int
main()
{
    C c;
    c.mem();
    temp_func<int>(c, &C::mem3);
    temp_func<>(c, &C::mem3);
    (void)static_cast<void(C::*)(int)>(&C::mem3);
    (void)static_cast<void(C::*)(int)>(&C::mem);
    // temp_func<>(c, &C::mem);
    // temp_func<int>(mem_ptr(c, mem));
    // temp_func<>(mem_ptr(c, mem));
    // temp_func(mem_ptr(c, mem2));
    // temp_macro(c, mem, int);
    // temp_macro(c, mem);
    return 0;
}
