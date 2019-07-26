using IndexedDims
using Test

@testset "IndexedDims.jl" begin
    a = IndexedDimsArray([1 2 3; 4 5 6; 7 8 9], 2:4, 2:4)

    # standard fallback
    @test a[1] == 1
    @test a[3, 2] == 8

    # fancy
    @test a[:, :] == a
    @test typeof(a[:, :]) == typeof(a)
    @test a[3:4, 2:3] == [4 5; 7 8]
    @test a[3:4, :] == [4 5 6; 7 8 9]
    @test a[3:4, bypass(1:2)] == [4 5; 7 8]
end
