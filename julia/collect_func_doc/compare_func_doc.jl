#!/usr/bin/julia -f

using JSON

function trans_sig(sig)
    # sig = replace(sig, "UInt", "Uint")
    # sig = replace(sig, "AbstractString", "String")
    # sig = replace(sig, "AbstractFloat", "FloatingPoint")
    # sig = replace(sig, "PipeEndpoint", "Pipe")
    sig = replace(sig, r"\s", "")
end

function compare_sigs(sigs_old, sigs_new)
    has_missing = false
    sigs_new_trans = [trans_sig(sig) for sig in sigs_new]
    for sig in sigs_old
        sig_nosp = replace(sig, r"\s", "")
        if !(sig_nosp in sigs_new) && !(sig_nosp in sigs_new_trans)
            info("Missing signature $sig")
            has_missing = true
        end
    end
    has_missing && println(STDERR)
end

function compare_all(docs_old, docs_new)
    for (func, sig) in docs_old
        if !(func in keys(docs_new))
            warn("Missing function $func")
            println(STDERR)
        else
            compare_sigs(sig, docs_new[func])
        end
    end
end

compare_all(JSON.parsefile(ARGS[1]), JSON.parsefile(ARGS[2]))
