using Documenter
using IndexedDims
using Test

@testset "IndexedDims.jl" begin
    doctest(IndexedDims)

    data = [1 2 3; 4 5 6; 7 8 9]
    a = IndexedDimsArray(data, 2:4, 2:4)

    # constructor
    @test ==(
        IndexedDimsArray([1 2; 3 4; 5 6]),
        IndexedDimsArray([1 2; 3 4; 5 6], Base.OneTo(2), Base.OneTo(3))
    )

    # standard fallback
    @test a[1] == data[1]
    @test a[3, 2] == data[3, 2]
    @test a == data
    @test a[:, :] == data[:, :]
    @test a[:, :] isa IndexedDimsArray
    @test a[:] == data[:]

    # fancy
    @test a[:, :] == a
    @test typeof(a[:, :]) == typeof(a)
    @test a[3:4, 2:3] == data[2:3, 1:2]
    @test a[3:4, 2:3] isa IndexedDimsArray
    @test a[3:4, :] == data[2:3, :]
    @test a[3:4, bypass(1:2)] == data[2:3, 1:2]

    # strings
    a = IndexedDimsArray([1 2 3; 4 5 6; 7 8 9], ["a", "b", "c"], ["b", "a", "b"])
    @test a[1] == data[1]
    @test a[3, 2] == data[3, 2]
    @test a[:, :] == a
    @test typeof(a[:, :]) == typeof(a)
    @test a[["b", "c"], "a"] == data[[2, 3], 2]
    @test a[["b", "c"], "b"] in (data[[2, 3], 1], data[[2, 3], 3])
    @test a[["b", "c"], ["b"]] == data[[2, 3], [1, 3]]
    @test a["b", ["b", "a"]] == data[2, 1:3]
end
