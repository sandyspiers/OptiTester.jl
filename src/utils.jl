function key_vals(collection)
    return zip(keys(collection), values(collection))
end

function unzip(collection)
    return (first.(collection), last.(collection))
end

function flatten(nt::NamedTuple, flat)::NamedTuple
    sub_nt, nt = split(nt, Tuple(flat))
    return merge(values(sub_nt)..., nt)
end

function apply(nt::NamedTuple, fn::Function)::NamedTuple
    return NamedTuple((k => fn(k, v) for (k, v) in key_vals(nt)))
end

function pair_get(pairs, key, default=nothing)
    isnothing(pairs) && return default
    isnothing(key) && return default
    ismissing(key) && return default
    idx = findfirst(pair -> !isnothing(first(pair)) && first(pair) == key, pairs)
    return isnothing(idx) ? default : last(pairs[idx])
end

function pair_get(pairs, pair::Pair, default=nothing)
    return pair_get(pair_get(pairs, first(pair)), last(pair), default)
end
