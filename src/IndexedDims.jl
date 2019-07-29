module IndexedDims

using AcceleratedArrays
import Base: to_index, tail

export IndexedDimsArray, bypass

include("autoaccelerate.jl")

struct BypassIndex{T}
    index::T
end

bypass(val::T) where {T} = BypassIndex{T}(val)

include("indexeddimsarray.jl")
include("stdindexing.jl")  # a wrapper for non-value (regular) indexing (hypothetical)
include("dimindexing.jl")  # value indexing

end # module
