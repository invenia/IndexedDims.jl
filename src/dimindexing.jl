function dim_to_indices(arr::IndexedDimsArray{T, N}, inds::Tuple{Vararg{Any, N}}) where {T, N}
    return map(unwrap_index, arr.indexes, inds)
end

unwrap_index(acc::AcceleratedVector, ind) = findall(in(ind), acc)
unwrap_index(acc::AcceleratedVector, ::Colon) = Colon()
unwrap_index(acc::AcceleratedVector, ind::BypassIndex) = ind.index

### simple fallback indexing (might delete later)
#=
Differes from base in that:
The terminal call `to_index` isn't using the original array (in this case `arr`)
   but uses the axis and index (i.e. `to_index(inds, I)`

=#
function Base.to_indices(arr::IndexedDimsArray,
                         inds::Tuple{AbstractVector,Vararg{AbstractVector,N}},
                         I::Tuple{Any,Vararg{Any,N}}) where N
    (to_index(first(inds), first(I)), to_indices(arr, tail(inds), tail(I))...)
end

function Base.to_indices(arr::IndexedDimsArray,
                         inds::Tuple{AbstractVector,Vararg{AbstractVector,N}},
                         I::Tuple{Colon,Vararg{Any,N}}) where N
    (axes(first(inds), 1), to_indices(arr, tail(inds), tail(I))...)
end

function Base.to_indices(arr::IndexedDimsArray, inds::Tuple{AbstractVector}, I::Tuple{Any})
    to_index(first(inds), first(I))
end

function Base.to_indices(arr::IndexedDimsArray, inds::Tuple{AbstractVector}, I::Tuple{Colon})
    (axes(first(inds), 1),)
end

function Base.getindex(arr::IndexedDimsArray{T, N}, inds::Any) where {T, N}
    getindex(parent(arr), inds)
end

Base.getindex(arr::IndexedDimsArray, inds::Colon) = arr


function Base.getindex(arr::IndexedDimsArray{T, N}, inds::Vararg{Any, N}) where {T, N}
    getindex(parent(arr), to_indices(arr, inds)...)
end

function Base.setindex!(arr::IndexedDimsArray{T, N}, val, inds::Vararg{Any, N}) where {T, N}
    setindex!(parent(arr), val, to_indices(arr, inds)...)
end

#=
function dim_getindex(arr::IndexedDimsArray{T, N}, inds::Vararg{Any, N}) where {T, N}
    # return Base.getindex(parent(arr), dim_to_indices(arr, inds)...)
    return invoke(getindex, Tuple{AbstractArray, Vararg{Any, N}}, arr, dim_to_indices(arr, inds)...)
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

=#
