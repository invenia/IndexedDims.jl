module IndexedDims

using AcceleratedArrays

export AcceleratedArray
export IndexedDimsArray, bypass

include("array.jl")  # IndexedDimsArray type
include("base.jl")
include("autoaccelerate.jl")
include("stdindexing.jl")  # a wrapper for non-value (regular) indexing (hypothetical)
include("dimindexing.jl")  # value indexing

end # module
