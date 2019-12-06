"""
    dim_to_indices(arr::IndexedDimsArray{T, N}, inds::Tuple{Vararg{Any, N}}) where {T, N}

Convert indexes into the IndexedDimsArray into indexes into the underlying array.

```jldoctest; setup = :(using IndexedDims)
julia> arr = IndexedDimsArray([4.0, 5.0], ["a", "b"]);

julia> IndexedDims.dim_to_indices(arr, (["b"],))
([2],)
```
"""
function dim_to_indices(arr::IndexedDimsArray{T, N}, inds::Tuple{Vararg{Any, N}}) where {T, N}
    return map(unwrap_index, arr.indexes, inds)
end

function unwrap_index(acc::AcceleratedVector{T, <:AbstractVector{T}, <:AcceleratedArrays.AbstractUniqueIndex}, ind) where T
    return _unwrap_unique_index(acc, ind)
end
_unwrap_unique_index(acc::AcceleratedVector, ind) = findfirst(isequal(ind), acc)
_unwrap_unique_index(acc::AcceleratedVector, ind::Union{AbstractArray, Colon, BypassIndex}) = _unwrap_index(acc, ind)
unwrap_index(acc::AcceleratedVector, ind) = _unwrap_index(acc, ind)
# NOTE: we don't guarantee that we will find the first match, just any single match
_unwrap_index(acc::AcceleratedVector, ind) = findfirst(isequal(ind), acc)
_unwrap_index(acc::AcceleratedVector, ind::AbstractArray) = findall(in(ind), acc)
_unwrap_index(acc::AcceleratedVector, ::Colon) = Colon()
_unwrap_index(acc::AcceleratedVector, ind::BypassIndex) = ind.index

# --- #
# TODO: move to AcceleratedArrays.jl

function _unwrap_index(acc::AcceleratedVector{T, <:AbstractUnitRange{T}}, ind::AbstractRange{<:Integer}) where T<:Integer
    return findall(in(ind), parent(acc))
end

# --- #

function dim_getindex(arr::IndexedDimsArray{T, N}, inds::Vararg{Any, N}) where {T, N}
    unwrapped_indices = dim_to_indices(arr, inds)
    new_indices = (reindex(arr_idx, idx) for (arr_idx, idx) in zip(arr.indexes, unwrapped_indices) if !(idx isa Integer))
    new_underlying_indices = (Base.OneTo(length(ind)) for ind in new_indices)
    new_array = IndexedDimsArray(similar(parent(arr), new_underlying_indices...), new_indices...)
    _unsafe_getindex!(parent(new_array), parent(arr), unwrapped_indices...)
    return new_array
end

function dim_setindex!(arr::IndexedDimsArray{T, N}, val, inds::Vararg{Any, N}) where {T, N}
    return Base.setindex!(parent(arr), val, dim_to_indices(arr, inds)...)
end

function Base.getindex(arr::IndexedDimsArray{T, N}, inds::Vararg{Any, N}) where {T, N}
    return dim_getindex(arr, inds...)
end

function Base.setindex!(arr::IndexedDimsArray{T, N}, val, inds::Vararg{Any, N}) where {T, N}
    return dim_setindex!(arr, inds...)
end
