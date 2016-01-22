#!/usr/bin/julia -f

function bug{T<:AbstractFloat}(data::Matrix{T})
    n = size(data, 2)
    cumulantT4 = SharedArray(T, n, n, n, n)

    for i = 1:n, j = i:n, k = j:n
      println("$i $j $k")
      @sync @parallel for l = k:n
            a = 1.0
            cumulantT4[i,j,k,l] = a
            cumulantT4[l,j,k,i] = a
            cumulantT4[i,l,k,j] = a
            cumulantT4[i,j,l,k] = a

            cumulantT4[i,k,j,l] = a
            cumulantT4[l,k,j,i] = a
            cumulantT4[i,l,j,k] = a
            cumulantT4[i,k,l,j] = a

            cumulantT4[j,i,k,l] = a
            cumulantT4[l,i,k,j] = a
            cumulantT4[j,l,k,i] = a
            cumulantT4[j,i,l,k] = a

            cumulantT4[j,k,i,l] = a
            cumulantT4[l,k,i,j] = a
            cumulantT4[j,l,i,k] = a
            cumulantT4[j,k,l,i] = a

            cumulantT4[k,i,j,l] = a
            cumulantT4[l,i,j,k] = a
            cumulantT4[k,l,j,i] = a
            cumulantT4[k,i,l,j] = a

            cumulantT4[k,j,i,l] = a
            cumulantT4[l,j,i,k] = a
            cumulantT4[k,l,i,j] = a
            cumulantT4[k,j,l,i] = a
        end
    end
    return Array(cumulantT4)
end

bug(randn(2000,100))
