#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define __ARG_COUNT_2(dummy, arg, count, ...) \
    count

#define ARG_COUNT_1(args...)                    \
    __ARG_COUNT_2(NULL, ##args, 1, 0)

#define DEF_DEFAULT_ARG_FUNC(name, type)                        \
    typedef struct {                                            \
        type args[2];                                           \
    } __##name##__##type_def;                                   \
    static inline type                                          \
    __##name##__##func(int c, __##name##__##type_def args)      \
    {                                                           \
        if (c)                                                  \
            return args.args[1];                                \
        return args.args[0];                                    \
    }

DEF_DEFAULT_ARG_FUNC(int, int)
DEF_DEFAULT_ARG_FUNC(char_p, const char *)
DEF_DEFAULT_ARG_FUNC(char, char)

#define DEFAULT_ARG(name, type, def, arg...)                    \
    __##name##__##func(ARG_COUNT_1(arg),                        \
                       (__##name##__##type_def){{def, arg}})

void
real_function(int a, int b, const char *c, char d)
{
    printf("%s, %d, %d, %s, %c\n", __func__, a, b, c, d);
}

#define _func_wrapper2(dummy, a, b, c, d, ...)                  \
    real_function(DEFAULT_ARG(int, int, 100, a),                \
                  DEFAULT_ARG(int, int, 200, b),                \
                  DEFAULT_ARG(char_p, const char*, "default", c),       \
                  DEFAULT_ARG(char, char, 'd', d))

#define func_wrapper(args...)                   \
    _func_wrapper2(NULL, ##args, , , ,)

int
main()
{
    func_wrapper();
    func_wrapper(1, 2, "ckkk");
    func_wrapper(, 400, "dd");
    func_wrapper(, , , 'g');
    func_wrapper(, , "mm", );
    func_wrapper(, , , 'k');
    return 0;
}
