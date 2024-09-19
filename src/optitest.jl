# # OptiTest
@TypedNamedTuple OptiTest

# # TestRun
@MutableTypedNamedTuple TestRun
function tests(optitest::OptiTest)
    return (TestRun(nt) for nt in _iterate(NamedTuple(optitest)))
end

# # Runner
function run(optitest::OptiTest, solver::Function)
    return pmap(solver, tests(optitest))
end

# # Dataframe
function DataFrame(test::Array{TestRun})
    return DataFrame(vcat(test...))
end
function DataFrame(test::Matrix{TestRun})
    return DataFrame(vcat(test...))
end
function DataFrame(test::Vector{TestRun})
    cols = union(keys.(test)...)
    return DataFrame([c => get.(test, c, missing) for c in cols]...)
end

# # Iterable
abstract type AbstractIterable end
struct Iterable <: AbstractIterable
    iterate
    Iterable(iterates...) = new([iterates...])
end
struct FlattenIterable <: AbstractIterable
    iterate
    FlattenIterable(iterates::NamedTuple) = new(iterates)
    FlattenIterable(iterates::NamedTuple...) = new([iterates...])
    FlattenIterable(; iterates...) = new(NamedTuple(iterates))
end

# # Special Iterables
struct Seed
    seed::Integer
    seed_ref::Ref{<:Integer}
    Seed(seed) = new(seed, Ref(seed))
end

# # Iterate method
_iterate(any) = any
_iterate(vec::Vector) = double_flatten(_iterate.(vec))
_iterate(iter::AbstractIterable) = _iterate(getfield(iter, :iterate))
function _iterate(nt::NamedTuple)
    iter_pairs = ((k, v) for (k, v) in key_vals(nt) if v isa AbstractIterable)
    names, iter = unzip(iter_pairs)
    if length(names) == 0
        return nt
    end
    prods = Iterators.product(_iterate.(iter)...)
    iterates = (merge(nt, NamedTuple(zip(names, prod))) for prod in prods)

    # specials
    seed_fn(_, v) = v isa Seed ? v.seed_ref[] += 1 : v
    iterates = (apply(iter, seed_fn) for iter in iterates)

    flat = (k for (k, v) in iter_pairs if v isa FlattenIterable)
    iterates = (flatten(iter, flat) for iter in iterates)

    return collect(iterates)
end
