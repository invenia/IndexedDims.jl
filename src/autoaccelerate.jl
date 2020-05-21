"""
	autoaccelerate(a::AbstractVector) -> AcceleratedVector

Generate an `AcceleratedVector` from any `AbstractVector` by choosing an appropriate index
based on the type of the vector.
This function is a no-op for `AcceleratedVector`s.

```jldoctest; setup = :(using IndexedDims: autoaccelerate)
julia> autoaccelerate(1:3)
3-element UnitRange{Int64} + UniqueSortIndex:
 1
 2
 3

julia> autoaccelerate(["foo", "bar", "baz", "bar"])
4-element Array{String,1} + HashIndex (3 unique elements):
 "foo"
 "bar"
 "baz"
 "bar"

julia> autoaccelerate(["foo", "bar", "baz"])
3-element Array{String,1} + UniqueHashIndex:
 "foo"
 "bar"
 "baz"
```
"""
function autoaccelerate end

autoaccelerate(v::AcceleratedVector) = v

autoaccelerate(r::OrdinalRange) = accelerate(r, UniqueSortIndex)
function autoaccelerate(v::AbstractVector)
    sorted = issorted(v)
    uniq = allunique(v)

    if sorted && uniq
        return accelerate(v, UniqueSortIndex)
    elseif sorted
        return accelerate(v, SortIndex)
    elseif uniq
        return accelerate(v, UniqueHashIndex)
    else
        return accelerate(v, HashIndex)
    end
end


"""
    reindex(vec::AcceleratedVector, inds) -> AcceleratedVector

Return an `AcceleratedVector` from a subset of the given `vec`.

The returned `AcceleratedVector` may have the same underlying data.

The returned `AcceleratedVector` is not guarnteed to have the same `AbstractIndex` type as
the given `vec`, and the `AbstractIndex` index type of the return is not part of the API.

```jldoctest; setup = :(using AcceleratedArrays, IndexedDims)
julia> v = accelerate(4:8, UniqueSortIndex)
5-element UnitRange{Int64} + UniqueSortIndex:
 4
 5
 6
 7
 8

julia> IndexedDims.reindex(v, [3, 2, 1])
3-element Array{Int64,1} + HashIndex (3 unique elements):
 6
 5
 4
```
"""
reindex(v::AcceleratedVector, ::Colon) = v

function reindex(v::AcceleratedVector{<:Any, <:Any, I}, index) where I
    return accelerate(parent(v)[index], _reindex_type(I, index))
end

# no way to know whether a given AbstractArray is unique or sorted
function reindex(v::AcceleratedVector{<:Any, <:Any, I}, index::AbstractArray) where I
    return accelerate(parent(v)[index], HashIndex)
end

# Ranges should be unique and sorted, so we should not lose any unique/sorted properties.
for index_type in (UniqueSortIndex, SortIndex, UniqueHashIndex)
    @eval _reindex_type(::Type{<:$index_type}, index::AbstractRange) = $index_type
end

_reindex_type(::Type{<:Union{HashIndex, UniqueHashIndex}}, index) = HashIndex
