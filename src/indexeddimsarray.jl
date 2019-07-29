struct IndexedDimsArray{T, N, A<:AbstractArray{T, N}, Is<:Tuple{Vararg{<:AbstractVector,N}}} <: AbstractArray{T, N}
    data::A
    indexes::Is

    function IndexedDimsArray{T,N,A,Is}(data::A, indexes::Is) where {T,N,A,Is}
        check_indexeddims_params(data, indexes)
        new{T,N,A,Is}(data, indexes)
    end
end

Base.parent(arr::IndexedDimsArray) = arr.data

Base.size(arr::IndexedDimsArray) = size(parent(arr))

Base.axes(arr::IndexedDimsArray) = arr.indexes

IndexedDimsArray(data::AbstractArray) = IndexedDimsArray(data, axes(data)...)

function IndexedDimsArray(data::AbstractArray{T, N}, dim_inds::Vararg{AcceleratedVector, N}) where {T, N}
    return IndexedDimsArray(data, dim_inds)
end

function IndexedDimsArray(data::AbstractArray{T, N}, dim_inds::Vararg{AbstractVector, N}) where {T, N}
    return IndexedDimsArray(data, map(autoaccelerate, dim_inds))
end

function IndexedDimsArray(data::AbstractArray{T, N}, dim_inds::Vararg{AbstractRange, N}) where {T, N}
    return IndexedDimsArray{T,N,typeof(data),typeof(dim_inds)}(data, dim_inds)
end

###

function Base.similar(arr::IndexedDimsArray{T, N, A}, inds::Tuple{Vararg{AbstractUnitRange, N}}) where {T, N, A}
    return IndexedDimsArray(similar(parent(arr), inds), map(reindex, arr.indexes, inds))
end


function check_indexeddims_params(data::AbstractArray{T,N}, indexes::Tuple{Vararg{Any,N}}) where {T,N}
    if size(data) == length.(indexes)
        return nothing
    else
        error("IndexedDimsArray indexes must each be the same length as the parent data's dimensions,
              got length.(indexes) = $(length.(indexes)) and size(parent) = $(size(parent)).")
    end
end
