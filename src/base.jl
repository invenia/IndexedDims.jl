# this file contains code copied from Base
# multidimensional.jl, 289
@generated function _unsafe_getindex_old!(dest::AbstractArray, src::AbstractArray, I::Vararg{Union{Real, AbstractArray}, N}) where N
    quote
        Base.@_inline_meta
        D = eachindex(dest)
        Dy = iterate(D)
        @inbounds Base.Cartesian.@nloops $N j d->I[d] begin
            # This condition is never hit, but at the moment
            # the optimizer is not clever enough to split the union without it
            Dy === nothing && return dest
            (idx, state) = Dy
            dest[idx] = Base.Cartesian.@ncall $N getindex src j
            Dy = iterate(D, state)
        end
        return dest
    end
end

function _unsafe_getindex!(dest::AbstractArray, src::AbstractArray, I::Vararg{Union{Real, AbstractArray, Colon}, N}) where N
    @inbounds for (i, j) in zip(eachindex(dest), Iterators.product(Base.to_indices(src, I)...))
        dest[i] = src[j...]
    end
    return dest
end
