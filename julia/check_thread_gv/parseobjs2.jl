#!/usr/bin/julia -f

using ELF
using FileIO

function open_objfile(fname)
    stm = FileIO.Stream(format"ELF", open(fname), fname)
    return FileIO.load(stm)
end

function get_gv_names(hdl)
    srcname = ""
    symbols = Tuple{String,Int,Bool,Bool}[]
    sections = ELF.Sections(hdl)
    for sym in ELF.Symbols(hdl)
        x = ELF.deref(sym)
        shndx = x.st_shndx
        sz = x.st_size
        typ = ELF.st_type(x)
        if typ == ELF.STT_FILE
            srcname = ELF.symname(sym)
            continue
        elseif (shndx == ELF.SHN_UNDEF || shndx == ELF.SHN_COMMON ||
                shndx == ELF.SHN_ABS)
            continue
        elseif sz == 0
            continue
        end
        typ == ELF.STT_OBJECT || continue
        section = sections[shndx + 1]
        sec = ELF.deref(section)
        (sec.sh_flags & ELF.SHF_WRITE) == 0 && continue
        sec_name = ELF.sectionname(section)
        startswith(sec_name, ".data.rel.ro") && continue
        islocal = ELF.islocal(x)
        symname = ELF.symname(sym)
        isfunclocal = false
        if ismatch(r"\.[0-9]*$", symname)
            isfunclocal = true
            symname = replace(symname, r"\.[0-9]*$", "")
        elseif startswith(symname, "_Z")
            # FIXME
            symname = strip(readstring(`c++filt $symname`))
            startswith(symname, "guard variable for ") && continue
        end
        push!(symbols, (symname, sz, islocal, isfunclocal))
    end
    srcname, symbols
end

count = Ref(0)

function process_objfile(fname)
    hdl = open_objfile(fname)
    srcname, symbols = get_gv_names(hdl)
    isempty(symbols) && return
    name_printed = false
    print_fname = function ()
        name_printed && return
        name_printed = true
        info("Filename: ", srcname)
    end
    for (sym, sz, islocal, isfunclocal) in symbols
        check_symbol(srcname, sym, sz, isfunclocal) && continue
        count[] += 1
        print_fname()
        if isfunclocal
            warn("<c local>::$sym ($sz)")
        else
            warn("$sym ($sz)")
        end
    end
end

function check_codegen_symbol(sym, sz, islocal)
    if !islocal
        sym in ("V_null", "__stack_chk_guard", "last_time", "builder",
                "mbuilder", "NoopType", "imaging_mode", "PM") && return true
        startswith(sym, "JL_I::") && return true
        endswith(sym, "::atomic_hdl") && return true
    end
    return false
end

const known_safe = [# constants
                    (r"^jl_.*_(type(|name)|exception)$", sizeof(Int)),
                    (r"_sym$", sizeof(Int)),
                    r"std::",
                    r"^jl_builtin_",
                    (r"^boxed_.*_cache$", "alloc.c"),
                    (("jl_true", "jl_false", "jl_an_empty_vec_any",
                      "jl_ANY_flag", "jl_typetype_tvar", "jl_nothing",
                      "jl_emptytuple", "jl_emptysvec", "jl_append_any_func",
                      "jl_show_gf", "array_ptr_void_type", "jl_typeinf_func",
                      "jl_arr_xtralloc_limit"), sizeof(Int)),
                    (("threadsafe", "region_pg_cnt", "current_pg_count"),),
                    (r"^jl_(top|core|base)_module$", sizeof(Int)),
                    (r"^(T|tbaa)_", sizeof(Int), r"\.cpp$"),
                    (r"_(func|llvmt|var|dillvmt|func_sig)$", sizeof(Int), r"\.cpp$"),
                    (("int16", "int32"), true, sizeof(Int), "typemap.c"),
                    (r"_func$", sizeof(Int), "task.c"),
                    (r"^jltls_states_func_", "codegen.cpp"),
                    # lock
                    (r"_lock$", sizeof(Culong) * 2),
                    # ast context
                    (r"^jl_ast.*_ctx", "ast.c"),
                    r"^jl_.*_tracer$",
                    ("symtab", sizeof(Int), "alloc.c"),
                    ("flisp_system_image", "ast.c"),
                    # threading profile
                    (r"_ns$", 8, "threading.c"),
                    # llvm memory manager
                    (r".*", "cgmemmgr.cpp"),
                    (r".*", "safepoint.c"),
                    # llvm internal
                    (r"^llvm::", r"\.cpp$")]

function check_known_safe(fname, sym, sz, islocal)
    for pattern in known_safe
        if isa(pattern, Tuple)
            _pattern = pattern[1]
            match = true
            for i in 2:length(pattern)
                v = pattern[i]
                match = if isa(v, String)
                    fname == v::String
                elseif isa(v, Regex)
                    ismatch(v::Regex, fname)
                elseif isa(v, Int)
                    v::Int == sz
                elseif isa(v, Bool)
                    v::Bool == islocal
                else
                    v(fname, sz, islocal)::Bool
                end
                match || break
            end
            match || continue
            pattern = _pattern
        end
        if isa(pattern, String)
            pattern::String == sym
        elseif isa(pattern, Regex)
            ismatch(pattern::Regex, sym)
        elseif isa(pattern, Tuple{Vararg{String}})
            sym in pattern::Tuple{Vararg{String}}
        else
            pattern(sym)::Bool
        end && return true
    end
    return false
end

function check_symbol(fname, sym, sz, islocal)
    check_known_safe(fname, sym, sz, islocal) && return true
    return false
    fname == "codegen.cpp" && return check_codegen_symbol(sym, sz, islocal)
    return false
end

for f in ARGS
    process_objfile(f)
end
if count[] != 0
    println()
    warn("$(count[]) symbols unhandled")
end
