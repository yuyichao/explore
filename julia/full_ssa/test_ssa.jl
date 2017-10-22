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

import Base: getindex, setindex!, start, next, done, show

struct Metadata
end

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
    metadata::Union{Metadata,Void}
end

mutable struct BasicBlockBase{BBList}
    first::Union{InstBase{BasicBlockBase{BBList}},Void}
    last::Union{InstBase{BasicBlockBase{BBList}},Void}
    preds::Vector{BasicBlockBase{BBList}}

    prev::Union{BasicBlockBase{BBList},Void}
    next::Union{BasicBlockBase{BBList},Void}

    parent::BBList

    br_true::BasicBlockBase{BBList}
    br_false::BasicBlockBase{BBList}
    BasicBlockBase{BBList}(parent::BBList, preds=BasicBlockBase{BBList}[]) where BBList =
        new(nothing, nothing, preds,
            nothing, nothing, parent)
end

mutable struct BBList
    first::BasicBlockBase{BBList}
    last::BasicBlockBase{BBList}
    @inline function BBList()
        self = new()
        bb = BasicBlockBase{BBList}(self)
        self.first = self.last = bb
        return self
    end
end

const BasicBlock = BasicBlockBase{BBList}
const Inst = InstBase{BasicBlock}
const InstArg = InstArgBase{Inst}

mutable struct InsertPt
    before::Union{Inst,BasicBlock}
end

struct StaticParam
    id::Int
end

get_bblist(::Void) = nothing
get_bblist(bb::BasicBlock) = bb.parent
get_bblist(inst::Inst) = get_bblist(inst.bb)
get_bblist(arg::InstArg) = get_bblist(arg.parent)

# Create a new argument for an instruction
function new_arg(@nospecialize(val), parent::Inst, idx::Int)
    if isa(val, InstArg)
        val = val.val
    end
    arg = InstArg(val, nothing, nothing, parent, idx)
    if isa(val, Inst)
        old_uses = val.uses
        if old_uses !== nothing
            arg.next = old_uses
            old_uses.prev = arg
        end
        val.uses = arg
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

function Inst(head::Symbol, args, @nospecialize(typ), ins_before=nothing)
    nargs = length(args)
    argv = Vector{InstArg}(nargs)
    inst = Inst(head, argv, typ, nothing, nothing, nothing, nothing, nothing)
    for i in 1:nargs
        argv[i] = new_arg(args[i], inst, i)
    end
    if ins_before !== nothing
        insert_before!(inst, ins_before)
    end
    return inst
end

mutable struct Builder
    bblist::BBList
    ins::InsertPt
    cur_meta::Metadata
end

start(bb::BasicBlock) = bb.first
done(::BasicBlock, @nospecialize(inst)) = inst === nothing
next(::BasicBlock, inst) = (inst, inst.next)

start(bblist::BBList) = bblist.first
done(::BBList, @nospecialize(bb)) = bb === nothing
next(::BBList, bb) = (bb, bb.next)

function number_vals(bblist::BBList)
    nums = ObjectIdDict()
    cur_id = 0
    bb_id = 0
    for bb in bblist
        nums[bb] = bb_id
        bb_id += 1
        for inst in bb
            inst.uses === nothing && continue
            nums[inst] = cur_id
            cur_id += 1
        end
    end
    return nums
end
number_vals(::Void) = ObjectIdDict()

function print_instarg(io::IO, arg::InstArg, nums::ObjectIdDict=number_vals(get_bblist(arg)))
    val = arg.val
    if isa(val, Inst)
        id = get(nums, val, -1)::Int
        print(io, "%", id)
        if val.typ !== Any
            print(io, "::", val.typ)
        end
    else
        Base.show_unquoted(io, val, 0, 0)
        # show(io, val)
    end
    return
end

function print_inst(io::IO, inst::Inst, nums::ObjectIdDict=number_vals(get_bblist(inst)))
    id = get(nums, inst, -1)::Int
    if id != -1
        print(io, "%", id)
        if inst.typ !== Any
            print(io, "::", inst.typ)
        end
        print(io, " = ")
    end
    head = inst.head
    args = inst.args
    # head = inst.head
    # elseif head === :invoke
    # elseif head === :static_parameter
    # end
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
    if head === :call
        callee = args[1]
        print_instarg(io, callee, nums)
        print(io, '(')
        for i in 2:length(args)
            if i != 2
                print(io, ", ")
            end
            print_instarg(io, args[i], nums)
        end
        print(io, ')')
    elseif head === :return && length(args) == 1
        print(io, "return ")
        print_instarg(io, args[1], nums)
    else
        print(io, "Inst(:", head)
        for i in 1:length(args)
            print(io, ", ")
            print_instarg(io, args[i], nums)
        end
        print(io, ')')
    end
    meta = inst.metadata
    if meta !== nothing
        print(io, ' ', meta)
    end
end

function print_bb(io::IO, bb::BasicBlock, nums::ObjectIdDict=number_vals(get_bblist(bb)))
    bb_id = nums[bb]::Int
    println(io, bb_id, ':')
    for inst in bb
        print(io, "  ")
        print_inst(io, inst, nums)
        println(io)
    end
    return
end

function print_bblist(io::IO, bblist::BBList, nums::ObjectIdDict=number_vals(bblist))
    for bb in bblist
        print_bb(io, bb, nums)
        println(io)
    end
    return
end

function ast2ir(ci::CodeInfo)
    code = ci.code
    bblist = BBList()
    ins = InsertPt(bblist.first)
    ssamap = ObjectIdDict()
    for expr in code
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
    end
    return bblist
end

show(io::IO, arg::InstArg) = print_instarg(io, arg)
show(io::IO, inst::Inst) = print_inst(io, inst)
show(io::IO, bb::BasicBlock) = print_bb(io, bb)
show(io::IO, bblist::BBList) = print_bblist(io, bblist)

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

# ci = code_typed(sumit2, Tuple{Vector{MyMutable}})[1].first
ci = code_typed(+, Tuple{Int8,Float32})[1].first
@show ci
print(IR.ast2ir(ci))

bblist = IR.BBList()
bb = bblist.first
ins = IR.InsertPt(bb)
a = IR.Inst(:call, (:identity, 2), Int, ins)
b = IR.Inst(:call, (:identity, a), Int, ins)
c = IR.Inst(:call, (:+, a, b), Int, ins)
d = IR.Inst(:return, (c,), Void, ins)
print(bblist)
