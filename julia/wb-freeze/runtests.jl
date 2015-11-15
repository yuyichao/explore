#!/usr/bin/julia -f

srand(123)

d = 1 .+ rand(5)
dl = -rand(4)
du = -rand(4)
A = Tridiagonal(dl, d, du)
U = sprandn(5, 2, 0.2)
@show A
@show U
@show typeof(A)
@show typeof(U)
@show @which A \ U
@code_warntype A \ U
