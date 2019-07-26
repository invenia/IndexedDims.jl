function dim_to_indices(arr::IndexedDimsArray{T, N}, inds::Tuple{Vararg{Any, N}}) where {T, N}
    return map(unwrap_index, arr.indexes, inds)
end

unwrap_index(acc::AcceleratedVector, ind) = findall(in(ind), acc)
unwrap_index(acc::AcceleratedVector, ::Colon) = Colon()
unwrap_index(acc::AcceleratedVector, ind::BypassIndex) = ind.index

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
