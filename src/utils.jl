"""
    key_vals(collection)
using Base: default_color_debug

Returns `zip(keys(collection), values(collection))`.
Nice to use on dictionaries and named tuples.
"""
function key_vals(collection)
    return zip(keys(collection), values(collection))
end

"""
    unzip(collection)

Returns `(first.(collection), last.(collection))`.
Nice to use `zip`'d objects with two entries each.
"""
function unzip(collection)
    return (first.(collection), last.(collection))
end

"""
    flatten(nt::NamedTuple, key)::NamedTuple

Flattens the `key` of a named tuple.
```julia
julia> flatten((a = 1, b = (x = :X, y = :Y)), :b)
(x = :X, y = :Y, a = 1)
```
"""
function flatten(nt::NamedTuple, key)::NamedTuple
    if !(key isa Symbol) && !(key isa Tuple)
        key = Tuple(key)
    end
    sub_nt, nt = split(nt, key)
    return merge(values(sub_nt)..., nt)
end

function double_flatten(vec::Vector)::Vector
    flat = []
    for v in vec
        if v isa AbstractVecOrMat
            push!(flat, v...)
        else
            push!(flat, v)
        end
    end
    return flat
end

"""
    apply(nt::NamedTuple, fn::Function)::NamedTuple

Applys the given function to every `(key,value)` pair in `nt`.
The function should by of form `fn(key,value)=...`.
"""
function apply(nt::NamedTuple, fn::Function)::NamedTuple
    return NamedTuple((k => fn(k, v) for (k, v) in key_vals(nt)))
end

"""
    pair_get(pairs, key, default=nothing)

Looks for `key` as the **first** item in the collection of pairs.
```julia
julia> pair_get([:q => 1, :w => 1], :q)
1
```
"""
function pair_get(pairs, key, default=nothing)
    if isnothing(pairs) || isnothing(key) || ismissing(key)
        return default
    end
    for pair in pairs
        if first(pair) == key
            return last(pair)
        end
    end
    return default
end

"""
    pair_get(pairs, pair::Pair, default=nothing)

Looks for `pair` as amongst the collection of pairs.
```julia
julia> pair_get([:q => 1, :w => 1], :q => 1)
1
```
"""
function pair_get(pairs, pair::Pair, default=nothing)
    key, val = pair
    return pair_get(pair_get(pairs, key, default), val, default)
end
