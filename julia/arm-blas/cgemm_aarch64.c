//

#include <cblas.h>
#include <stdio.h>

int main()
{
    const float A[2] = {0.4713259, 0.14339028};
    const float B[2] = {0.4713259, 0.14339028};
    float C[2];
    const float alpha[2] = {1, 0};
    const float beta[2] = {0, 0};
    cblas_cgemm(CblasRowMajor, CblasNoTrans, CblasConjTrans,
                1, 1, 1, alpha, A, 1, B, 1, beta, C, 1);
    printf("%g, %g\n", C[0], C[1]);
    cblas_cgemm(CblasColMajor, CblasNoTrans, CblasConjTrans,
                1, 1, 1, alpha, A, 1, B, 1, beta, C, 1);
    printf("%g, %g\n", C[0], C[1]);
    return 0;
}
