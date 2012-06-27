#include <stdio.h>
#include <stdlib.h>
#include <ffi.h>
#include <string.h>
#include <stdarg.h>

typedef void (*fpointer)();

unsigned int
type_total_size(ffi_type *type)
{
    int i;
    unsigned int size;
    if (!type)
        return 0;
    if (!type->elements)
        return sizeof(ffi_type);
    size = sizeof(ffi_type);
    for (i = 0;type->elements[i];i++)
        size += type_total_size(type->elements[i]);
    size += (i + 1) * sizeof(ffi_type*);
    return size;
}

unsigned int
type_fill_buff(void *buff, const ffi_type *type)
{
    int i;
    void *p;
    ffi_type *tmp_type;
    ffi_type **eles_type;
    unsigned int size = 0;
    unsigned int tmp_size;

    if (!buff || !type)
        return 0;

    memcpy(buff, type, sizeof(ffi_type));

    if (!type->elements)
        return sizeof(ffi_type);

    tmp_type = buff;
    p = buff + sizeof(ffi_type);
    size += sizeof(ffi_type);

    tmp_type->elements = eles_type = p;

    for (i = 0;type->elements[i];i++) {
    }

    tmp_size = (i + 1) * sizeof(ffi_type*);
    p += tmp_size;
    size += tmp_size;
    eles_type[i] = NULL;

    for (i = 0;type->elements[i];i++) {
        tmp_size = type_fill_buff(p, type->elements[i]);
        eles_type[i] = p;
        p += tmp_size;
        size += tmp_size;
    }
    return size;
}

ffi_type *type_copy(ffi_type *type)
{
    unsigned int size;
    void *buff;
    size = type_total_size(type);
    printf("total size: %u\n", size);
    if (!size)
        return NULL;
    buff = malloc(size);
    if (!buff)
        return NULL;
    size = type_fill_buff(buff, type);
    printf("copy size: %u\n", size);
    return buff;
}

ffi_type*
type_create(unsigned int argc, ...)
{
    if (!argc)
        return NULL;
    int i;
    va_list ap;
    ffi_type *eles[argc + 1];
    ffi_type tmpres = {
        .size = 0,
        .alignment = 0,
        .elements = eles
    };
    va_start(ap, argc);
    for (i = 0;i < argc;i++) {
        eles[i] = va_arg(ap, ffi_type*);
    }
    va_end(ap);
    eles[i] = NULL;
    return type_copy(&tmpres);
}

ffi_cif*
cif_create(ffi_type *ret_t, unsigned int argc, ...)
{
    unsigned int i;
    unsigned int size;
    ffi_cif *res;
    va_list ap;

    ffi_type *argv[argc];
    void *ret_p;
    void *argv_p;
    void *arg_p;

    size = sizeof(ffi_cif);
    if (!ret_t)
        ret_t = &ffi_type_void;
    size += type_total_size(ret_t) + sizeof(argv);

    va_start(ap, argc);
    for (i = 0;i < argc;i++) {
        argv[i] = va_arg(ap, ffi_type*);
        size += type_total_size(argv[i]);
    }
    va_end(ap);

    res = malloc(size);
    if (!res)
        return NULL;
    ret_p = res + sizeof(ffi_cif);
    argv_p = ret_p + type_fill_buff(ret_p, ret_t);
    arg_p = argv_p + sizeof(argv);
    for (i = 0;i < argc;i++) {
        ((ffi_cif**)argv_p)[i] = arg_p;
        arg_p += type_fill_buff(arg_p, argv[i]);
    }
    if (!argc)
        argv_p = NULL;
    if (ffi_prep_cif(res, FFI_DEFAULT_ABI, argc, ret_p, argv_p) == FFI_OK)
        return res;
    free(res);
    return NULL;
}

typedef struct {
    int i;
    char *str;
    int j;
} my_struct;

typedef struct {
    int i;
    char *str;
    int j;
    struct {
        int i;
        int j;
        char *str1;
        char *str2;
    } stu;
} cmplx_struct;

void
print_str(char *str)
{
    if (str)
        printf("%s\n", str);
    else
        printf("(null)\n");
}

void
print_my_struct(my_struct ms)
{
    printf("i: %d\n", ms.i);
    printf("str: ");
    print_str(ms.str);
    printf("j: %d\n", ms.j);
}

void
print_type(ffi_type *type)
{
    if (!type) {
        printf("Empty type.\n");
        return;
    }
    printf("type @ %lx\n", (unsigned long)type);
    printf("\tsize: %lu\n", type->size);
    printf("\talignment: %u\n", (unsigned)type->alignment);
    printf("\ttype: %u\n", (unsigned)type->type);
    printf("\telements: %lx\n", (unsigned long)type->elements);
}

void
print_cif(ffi_cif *cif)
{
    int i;
    if (!cif) {
        printf("Empty cif.\n");
        return;
    }
    printf("cif @ %lx\n", (unsigned long)cif);
    printf("nargs: %u\n", cif->nargs);
    printf("bytes: %u\n", cif->bytes);
    printf("flags: %u\n", cif->flags);
    printf("rtype:");
    print_type(cif->rtype);
    printf("arg_types:\n");
    for (i = 0;i < cif->nargs;i++) {
        printf("args[%d]:\n", i);
        print_type(cif->arg_types[i]);
    }
    printf("\n");
}

int
main()
{
    ffi_cif *cif;
    void *values[1];
    my_struct ms = {
        .i = 1,
        .j = 2,
        .str = "asdf"
    };
    values[0] = &ms;

    ffi_type *copied_type = type_create(3, &ffi_type_sint, &ffi_type_pointer,
                                        &ffi_type_sint);
    printf("\033[31;1mBefore Init\033[0m\n");
    printf("my_struct_type:\n");
    print_type(copied_type);

    cif = cif_create(NULL, 1, copied_type);
    free(copied_type);
    if (cif) {
        printf("\033[31;1mAfter Prep CIF\033[0m\n");
        print_cif(cif);
        printf("\033[32;1mCall First Time\033[0m\n");
        ffi_call(cif, (fpointer)print_my_struct, NULL, values);
        printf("\033[31;1mAfter First Call\033[0m\n");
        print_cif(cif);
        ms.str = "Hello";
        printf("\033[32;1mCall Second Time\033[0m\n");
        ffi_call(cif, (fpointer)print_my_struct, NULL, values);
        printf("\033[31;1mAfter Second Call\033[0m\n");
        print_cif(cif);
    }
    free(cif);
    return 0;
}
