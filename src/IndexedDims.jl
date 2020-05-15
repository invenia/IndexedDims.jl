module IndexedDims

using AcceleratedArrays

export IndexedDimsArray, bypass

include("base.jl")
include("autoaccelerate.jl")

struct BypassIndex{T}
    index::T
end

bypass(val::T) where {T} = BypassIndex{T}(val)

struct IndexedDimsArray{T, N, A<:AbstractArray{T, N}, Is<:Tuple{Vararg{<:AcceleratedVector,N}}} <: AbstractArray{T, N}
    data::A
    indexes::Is
end

Base.parent(arr::IndexedDimsArray) = arr.data
Base.size(arr::IndexedDimsArray) = size(parent(arr))

IndexedDimsArray(data::AbstractArray) = IndexedDimsArray(data, axes(data)...)

function IndexedDimsArray(data::AbstractArray{T, N}, dim_inds::Vararg{AcceleratedVector, N}) where {T, N}
    return IndexedDimsArray(data, dim_inds)
end

function IndexedDimsArray(data::AbstractArray{T, N}, dim_inds::Vararg{AbstractVector, N}) where {T, N}
    return IndexedDimsArray(data, map(autoaccelerate, dim_inds))
end

### simple fallback indexing (might delete later)
function Base.getindex(arr::IndexedDimsArray{T, N}, inds::Vararg{Int, N}) where {T, N}
    return Base.getindex(parent(arr), inds...)
end

function Base.setindex!(arr::IndexedDimsArray{T, N}, val, inds::Vararg{Int, N}) where {T, N}
    return Base.setindex!(parent(arr), val, inds...)
end
###

function Base.similar(arr::IndexedDimsArray{T, N, A}, inds::Tuple{Vararg{Union{Int, AbstractUnitRange}, N}}) where {T, N, A}
    return IndexedDimsArray(similar(parent(arr), inds), map(reindex, arr.indexes, inds))
end

include("stdindexing.jl")  # a wrapper for non-value (regular) indexing (hypothetical)
include("dimindexing.jl")  # value indexing

end # module
