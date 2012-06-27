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

int
main()
{
    ffi_cif cif;
    ffi_type *args[1];
    void *values[1];
    char *s;

    args[0] = &ffi_type_pointer;
    values[0] = &s;

    if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1,
                     &ffi_type_void, args) == FFI_OK) {
        s = "aaa";
        ffi_call(&cif, (fpointer)print_str, NULL, values);
        s = NULL;
        ffi_call(&cif, (fpointer)print_str, NULL, values);
    }
    return 0;
}
