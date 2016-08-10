#!/usr/bin/julia

@noinline function scale_nothread(a, s)
    for i in 1:length(a)
        a[i] *= s
    end
end

@noinline function scale_nothread_ib(a, s)
    @inbounds for i in 1:length(a)
        a[i] *= s
    end
end

@noinline function scale_nothread_simd(a, s)
    @inbounds @simd for i in 1:length(a)
        a[i] *= s
    end
end

@noinline function scale_thread(a, s)
    Threads.@threads for i in 1:length(a)
        a[i] *= s
    end
end

@noinline function scale_thread_ib(a, s)
    Threads.@threads for i in 1:length(a)
        @inbounds a[i] *= s
    end
end

macro time_scale(fname)
    quote
        println($(esc(fname)))
        a = fill(1e100, 10^4)
        print("10^4")
        $(esc(fname))(a, 0.999)
        @time for i in 1:(10^4)
            $(esc(fname))(a, 0.999)
        end
        a = fill(1e100, 10^5)
        print("10^5")
        $(esc(fname))(a, 0.999)
        @time for i in 1:(10^3)
            $(esc(fname))(a, 0.999)
        end
        # a = fill(1e100, 10^6)
        # print("10^6")
        # @time for i in 1:(10^2)
        #     $(esc(fname))(a, 0.999)
        # end
        # a = fill(1e100, 10^7)
        # print("10^7")
        # @time for i in 1:(10^1)
        #     $(esc(fname))(a, 0.999)
        # end
        # a = fill(1e100, 10^8)
        # print("10^8")
        # @time for i in 1:1
        #     $(esc(fname))(a, 0.999)
        # end
    end
end

function time_all()
    @time_scale scale_nothread
    @time_scale scale_nothread_ib
    @time_scale scale_nothread_simd
    @time_scale scale_thread
    @time_scale scale_thread_ib
end

time_all()
# time_all()
