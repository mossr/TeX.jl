using Optionals
using Test

testdir = joinpath(dirname(@__DIR__), "test")
cd(testdir) do
    @testset "tex" begin

        @testset "simple" begin
            @test try
                include(joinpath(testdir, "test_simple.jl"))
                true
            catch err
                display(err)
                false
            end
        end

        @testset "full" begin
            @test try
                include(joinpath(testdir, "test_full.jl"))
                true
            catch err
                display(err)
                false
            end
        end

        @testset "tufte" begin
            @test try
                include(joinpath(testdir, "test_tufte.jl"))
                true
            catch err
                display(err)
                false
            end
        end
    end
end