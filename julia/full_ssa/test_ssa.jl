#

# Valid expressions
# :call => 1:typemax(Int),
# :invoke => 2:typemax(Int),
# :static_parameter => 1:1,
# :gotoifnot => 2:2,
# :(&) => 1:1,
# :(=) => 2:2,
# :method => 1:4,
# :const => 1:1,
# :new => 1:typemax(Int),
# :return => 1:1,
# :the_exception => 0:0,
# :enter => 1:1,
# :leave => 1:1,
# :inbounds => 1:1,
# :boundscheck => 0:0,
# :copyast => 1:1,
# :meta => 0:typemax(Int),
# :global => 1:1,
# :foreigncall => 3:typemax(Int),
# :isdefined => 1:1,
# :simdloop => 0:0,
# :gc_preserve_begin => 0:typemax(Int),
# :gc_preserve_end => 0:typemax(Int)


module IR

import Base: getindex, setindex!

mutable struct InstArgBase{Inst}
    val::Any # `Inst` or other special values
    # `prev` and `next` are always `nothing` unless `val` is `Inst`
    prev::Union{InstArgBase{Inst},Void}
    next::Union{InstArgBase{Inst},Void}
    parent::Inst
    idx::Int # Position in the args array
end

mutable struct InstBase{BB}
    head::Symbol
    args::Vector{InstArgBase{InstBase{BB}}}
    typ::Any
    prev::Union{InstBase{BB},Void}
    next::Union{InstBase{BB},Void}
    uses::Union{InstArgBase{InstBase{BB}},Void}
    bb::Union{BB,Void}
end

mutable struct BasicBlock
    first::Union{InstBase{BasicBlock},Void}
    last::Union{InstBase{BasicBlock},Void}
    preds::Vector{BasicBlock}

    prev::Union{BasicBlock,Void}
    next::Union{BasicBlock,Void}

    br_true::BasicBlock
    br_false::BasicBlock
    BasicBlock(preds=BasicBlock[]) = new(nothing, nothing, preds, nothing, nothing)
end

const Inst = InstBase{BasicBlock}
const InstArg = InstArgBase{Inst}

mutable struct InsertPt
    before::Union{Inst,BasicBlock}
end

# Create a new argument for an instruction
function new_arg(@nospecialize(val), parent::Inst, idx::Int)
    arg = InstArg(val, nothing, nothing, parent, idx)
    if isa(val, Inst)
        old_uses = parent.uses
        if old_uses !== nothing
            arg.next = old_uses
            old_uses.prev = arg
        end
        parent.uses = arg
    end
    return arg
end

# Delete the arg from the use list.
# This does **not** remove the argument from the parent instruction.
function unlink_arg(arg::InstArg)
    inst = arg.val
    if isa(inst, Inst)
        p = arg.prev
        n = arg.next
        if p === nothing
            inst.uses = n
        else
            p.next = n
        end
        if n !== nothing
            n.prev = p
        end
    end
end

getindex(inst::Inst, idx::Int) = inst.args[idx]
function setindex!(inst::Inst, @nospecialize(val), idx::Int)
    nargs = length(inst.args)
    if idx > nargs + 1
        throw(BoundsError(inst, idx))
    end
    if isa(val, InstArg)
        val = val.val
    end
    arg = new_arg(val, inst, idx)
    if idx == nargs + 1
        push!(inst.args, arg)
    else
        unlink_arg(inst.args[idx])
        inst.args[idx] = arg
    end
    return
end
@inline function setindex!(arg::InstArg, @nospecialize(val))
    arg.parent[arg.idx] = val
    return
end

function next!(ins::InsertPt)
    pt = ins.before
    if isa(pt, BasicBlock)
        throw(ArgumentError("Insert point already at the end of a BB"))
    end
    n = pt.next
    if n === nothing
        bb = pt.bb
        isa(bb, BasicBlock) || throw(ArgumentError("Dangling insert point"))
        ins.before = bb
    else
        ins.before = n
    end
    return
end

function prev!(ins::InsertPt)
    pt = ins.before
    if isa(pt, BasicBlock)
        new_pt = pt.last
    else
        new_pt = pt.prev
    end
    if new_pt === nothing
        throw(ArgumentError("Insert point already at the beginning of a BB"))
    else
        ins.before = new_pt
    end
    return
end

function insert_last!(inst::Inst, bb::BasicBlock)
    old_last = bb.last
    bb.last = inst
    inst.bb = bb
    if old_last === nothing
        bb.first = inst
    else
        old_last.next = inst
        inst.prev = old_last
    end
    return
end

function insert_first!(inst::Inst, bb::BasicBlock)
    old_first = bb.first
    bb.first = inst
    inst.bb = bb
    if old_first === nothing
        bb.last = inst
    else
        old_first.prev = inst
        inst.next = old_first
    end
    return
end

function insert_between_inst!(inst::Inst, inst1::Inst, inst2::Inst)
    inst1.next = inst
    inst2.prev = inst
    inst.prev = inst1
    inst.next = inst2
    inst.bb = inst1.bb
    return
end

@inline function insert_before!(inst::Inst, ins::InsertPt)
    inst.bb === nothing || throw(ArgumentError("Inst already has a parent."))
    pt = ins.before
    if isa(pt, BasicBlock)
        insert_last!(inst, pt)
    else
        prev_inst = pt.prev
        if prev_inst === nothing
            insert_first!(inst, pt.bb::BasicBlock)
        else
            insert_betwen_inst!(inst, prev_inst, pt)
        end
    end
end

insert_before!(inst::Inst, before::Inst) = insert_before!(inst, InsertPt(before))

mutable struct BBList
    first::BasicBlock
    last::BasicBlock
    @inline function BBList()
        bb = BasicBlock()
        return new(bb, bb)
    end
end

function createSlotLoad(cur::BasicBlock)
end

function ast2ir(ci::CodeInfo)
    code = ci.code
    bbs = BBList()
    cur_bb = bbs.first
    for expr in code
    end
    return bbs
end

function Base.show(io::IO, inst::Inst)
end

function Base.show(io::IO, bbs::BBList)
    bb_counter = 0
    bb_ids = ObjectIdDict()
    cur_bb = bbs.first
    while true
        bb_ids[cur_bb] = bb_counter
        bb_counter += 1
        cur_bb = cur_bb.next
        isa(cur_bb, Void) && break
    end
    cur_bb = bbs.first
    first_bb = true
    while true
        if first_bb
            first_bb = false
        else
            println(io)
        end
        bb_id = bb_ids[cur_bb]
        println(io, "$bb_id:")
        cur_bb = cur_bb.next
        isa(cur_bb, Void) && break
    end
    return
end

end


mutable struct MyMutable
    a::Int
end

function sumit2(arr)
    val = 0
    for (i, obj) in enumerate(arr)
        val += obj.a
    end
    return val
end

ci = code_typed(sumit2, Tuple{Vector{MyMutable}})[1].first
println(IR.ast2ir(ci))
