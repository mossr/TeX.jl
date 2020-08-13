using Optionals
using Test

@testset "optional" begin
    testdir = joinpath(dirname(@__DIR__), "test")

    @testset "type" begin
        @test try
            include(joinpath(testdir, "test_tex.jl"))
            true
        catch err
            display(err)
            false
        end
    end

    @testset "customers" begin
        @test try
            include(joinpath(testdir, "test_simple.jl"))
            true
        catch err
            display(err)
            false
        end
    end
end