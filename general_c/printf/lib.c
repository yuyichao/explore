#include "lib.h"

void
print_strs1(FILE *fp, const char *str1, const char *str2)
{
    fwrite(str1, strlen(str1), 1, fp);
    fwrite("=", strlen("="), 1, fp);
    fwrite(str2, strlen(str2), 1, fp);
    fwrite("\n", strlen("\n"), 1, fp);
}

void
print_strs2(FILE *fp, const char *str1, const char *str2)
{
    fwrite(str1, 1, strlen(str1), fp);
    fwrite("=", 1, strlen("="), fp);
    fwrite(str2, 1, strlen(str2), fp);
    fwrite("\n", 1, strlen("\n"), fp);
}

void
print_strs3(FILE *fp, const char *str1, const char *str2)
{
    fprintf(fp, "%s=%s\n", str1, str2);
}
