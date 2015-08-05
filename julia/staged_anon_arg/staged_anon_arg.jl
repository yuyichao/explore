#!/usr/bin/julia -f

@generated function f(::Any)
    :(for i in 1
      end)
end

println(@code_typed f(1.2))
