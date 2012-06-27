#include <stdio.h>
#include <stdlib.h>
#include <ffi.h>

typedef void (*fpointer)();

typedef struct {
    int i;
    char *str;
    int j;
} my_struct;

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
    ffi_cif cif;
    ffi_type my_struct_type;
    ffi_type *my_struct_eles[4] = {
        &ffi_type_sint,
        &ffi_type_pointer,
        &ffi_type_sint,
        NULL
    };
    ffi_type *args[1];
    void *values[1];
    my_struct ms = {
        .i = 1,
        .j = 2,
        .str = "asdf"
    };

    my_struct_type.size = my_struct_type.alignment = 0;
    my_struct_type.elements = my_struct_eles;

    args[0] = &my_struct_type;
    values[0] = &ms;
    printf("\033[31;1mBefore Init\033[0m\n");
    printf("my_struct_type:\n");
    print_type(args[0]);
    printf("ffi_type_void:\n");
    print_type(&ffi_type_void);

    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1,
                     &ffi_type_void, args) == FFI_OK) {
        printf("\033[31;1mAfter Prep CIF\033[0m\n");
        print_cif(&cif);
        printf("\033[32;1mCall First Time\033[0m\n");
        ffi_call(&cif, (fpointer)print_my_struct, NULL, values);
        printf("\033[31;1mAfter First Call\033[0m\n");
        print_cif(&cif);
        ms.str = "Hello";
        printf("\033[32;1mCall Second Time\033[0m\n");
        ffi_call(&cif, (fpointer)print_my_struct, NULL, values);
        printf("\033[31;1mAfter Second Call\033[0m\n");
        print_cif(&cif);
    }
    return 0;
}
