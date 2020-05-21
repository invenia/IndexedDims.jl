struct BypassIndex{T}
    val::T
end

bypass(val::T) where {T} = BypassIndex{T}(val)

"""
    parent_indices(arr::IndexedDimsArray{T, N}, inds::Tuple{Vararg{Any, N}}) where {T, N}

Return indicies of the underlying array corresponding the indices `inds` of the
`IndexedDimsArray` `arr`.

```jldoctest; setup = :(using IndexedDims)
julia> arr = IndexedDimsArray([4.0, 5.0], ["a", "b"]);

julia> IndexedDims.parent_indices(arr, (["b"],))
([2],)
```
"""
function parent_indices(arr::IndexedDimsArray{T, N}, inds::Tuple{Vararg{Any, N}}) where {T, N}
    return map(parent_index, arr.indices, inds)
end

"""
    parent_index(v::AcceleratedVector, idx)

Return the index of `idx` in the underlying vector `parent(v)`p

```jldoctest; setup = :(using IndexedDims: autoaccelerate, _parent_index)
julia> v = autoaccelerate(4:6);

julia> idx = 5:6;

julia> parent_idx = _parent_index(v, idx)
2:3

julia> @assert idx == parent(v)[parent_idx]
```
"""
parent_index(acc::AcceleratedVector, idx) = _parent_index(acc, idx)
# NOTE: we don't guarantee that we will find the first match, just any single match
_parent_index(acc::AcceleratedVector, idx) = findfirst(isequal(idx), acc)
_parent_index(acc::AcceleratedVector, idx::AbstractArray) = findall(in(idx), acc)
_parent_index(acc::AcceleratedVector, ::Colon) = Colon()
_parent_index(acc::AcceleratedVector, idx::BypassIndex) = idx.val

# --- #
# TODO: move to AcceleratedArrays.jl
function _parent_index(
    acc::AcceleratedVector{T, <:AbstractUnitRange{T}},
    idx::AbstractRange{<:Integer}
) where T<:Integer
    return findall(in(idx), parent(acc))
end
# --- #

#=
# treat `<:AbstractUniqueIndex`s differently
function parent_index(acc::AcceleratedVector{T, <:AbstractVector{T}, <:AbstractUniqueIndex}, ind) where T
    return _parent_unique_index(acc, ind)
end

_parent_unique_index(acc::AcceleratedVector, ind) = findfirst(isequal(ind), acc)
function _parent_unique_index(acc::AcceleratedVector, ind::Union{AbstractArray, Colon, BypassIndex})
    return _parent_index(acc, ind)
end
=#

# Fancy getindex
function Base.getindex(arr::IndexedDimsArray{T, N}, inds::Vararg{Any, N}) where {T, N}
    par = parent(arr)
    par_inds = parent_indices(arr, inds)

    inds
    new_arr_inds = (reindex(a, p) for (a, p) in zip(arr.indices, par_inds) if !(p isa Integer))
    new_par_inds = (Base.OneTo(length(ind)) for ind in new_arr_inds)

    # new_arr = IndexedDimsArray(similar(parent(arr), new_par_inds...), new_arr_inds...)
    new_par = similar(par, new_par_inds...)
    # _unsafe_getindex!(parent(new_arr), parent(arr), par_inds...)
    _unsafe_getindex!(new_par, par, par_inds...)
    # return new_arr
    return IndexedDimsArray(new_par, new_arr_inds...)
end

# Int getindex
function Base.getindex(arr::IndexedDimsArray{T, N}, inds::Vararg{Int, N}) where {T, N}
    return Base.getindex(parent(arr), inds...)
end

# Fancy setindex!
function Base.setindex!(arr::IndexedDimsArray{T, N}, val, inds::Vararg{Any, N}) where {T, N}
    return Base.setindex!(parent(arr), val, parent_indices(arr, inds)...)
end

# Int setindex!
function Base.setindex!(arr::IndexedDimsArray{T, N}, val, inds::Vararg{Int, N}) where {T, N}
    return Base.setindex!(parent(arr), val, inds...)
end
