struct IndexedDimsArray{T, N, A<:AbstractArray{T, N}, Is<:Tuple{Vararg{<:AcceleratedVector, N}}} <: AbstractArray{T, N}
    data::A
    indices::Is
end

IndexedDimsArray(data::AbstractArray) = IndexedDimsArray(data, axes(data)...)

function IndexedDimsArray(data::AbstractArray{T, N}, inds::Vararg{AcceleratedVector, N}) where {T, N}
    return IndexedDimsArray(data, inds)
end

function IndexedDimsArray(data::AbstractArray{T, N}, inds::Vararg{AbstractVector, N}) where {T, N}
    return IndexedDimsArray(data, map(autoaccelerate, inds))
end

Base.parent(arr::IndexedDimsArray) = arr.data
Base.size(arr::IndexedDimsArray) = size(parent(arr))

function Base.similar(
    arr::IndexedDimsArray{T, N, A},
    inds::Tuple{Vararg{Union{Int, AbstractUnitRange}, N}}
) where {T, N, A}
    return IndexedDimsArray(similar(parent(arr), inds), map(reindex, arr.indices, inds))
end
