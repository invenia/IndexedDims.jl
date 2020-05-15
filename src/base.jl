# Defining our own `_unsafe_getindex!` means we don't have to rely on Base internals.
# If there is a performance cost, we may want to switch to a copy of the Base version,
# but we would then need to call `to_indices` earlier to avoid passing in `Colon`.
function _unsafe_getindex!(
    dest::AbstractArray,
    src::AbstractArray,
    I::Vararg{Union{Real, AbstractArray, Colon}, N}
) where N  # `where N` used to force specialisation
    @inbounds for (i, j) in zip(eachindex(dest), Iterators.product(to_indices(src, I)...))
        dest[i] = src[j...]
    end
    return dest
end

#=
Optimized version (from Base) of the `_unsafe_getindex!` function above.
Can use this if it improves performance, but ideally we'd avoid an `@generated` function.

# This code is copied from Base/multidimensional.jl
# https://github.com/JuliaLang/julia/blob/f12cde0e8c7f4268838d3201dd9e13b90ea44633/base/multidimensional.jl#L761-L777
# Does not support `Colon`, as it assumes `I == to_indices(src, I)`.
@generated function _unsafe_getindex!(dest::AbstractArray, src::AbstractArray, I::Vararg{Union{Real, AbstractArray}, N}) where N
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
=#
