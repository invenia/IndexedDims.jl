struct UnindexedDimsArray{T, N, IA<:IndexedDimsArray{T, N}} <: AbstractArray{T, N}
    data::IA
end

Base.parent(arr::UnindexedDimsArray) = arr.data
Base.size(arr::UnindexedDimsArray) = size(parent(arr))

function Base.getindex(arr::UnindexedDimsArray, inds::Int...)
    return getindex(parent(parent(arr)), inds...)
end

function Base.setindex!(arr::UnindexedDimsArray, val, inds::Int...)
    return setindex!(parent(parent(arr)), val, inds...)
end
