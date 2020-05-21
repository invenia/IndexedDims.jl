module IndexedDims

using AcceleratedArrays
using AcceleratedArrays: AbstractUniqueIndex

export AcceleratedArray, UniqueHashIndex, HashIndex, UniqueSortIndex, SortIndex
export IndexedDimsArray, bypass

include("array.jl")  # IndexedDimsArray type
include("base.jl")
include("autoaccelerate.jl")
include("stdindexing.jl")  # a wrapper for non-value (regular) indexing (hypothetical)
include("dimindexing.jl")  # value indexing

end # module
