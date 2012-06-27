#include <stdio.h>
#include <stdlib.h>
#include <ffi.h>

typedef void (*fpointer)();

void
print_str(char *str)
{
    if (str)
        printf("%s\n", str);
    else
        printf("(null)\n");
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
    ffi_type *args[1];
    void *values[1];
    char *s;

    args[0] = &ffi_type_pointer;
    values[0] = &s;
    printf("ffi_type_pointer:\n");
    print_type(args[0]);
    printf("ffi_type_void:\n");
    print_type(&ffi_type_void);

    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1,
                     &ffi_type_void, args) == FFI_OK) {
        print_cif(&cif);
        s = "aaa";
        ffi_call(&cif, (fpointer)print_str, NULL, values);
        print_cif(&cif);
        s = NULL;
        ffi_call(&cif, (fpointer)print_str, NULL, values);
    }
    return 0;
}
