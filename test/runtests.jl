using Optionals
using Test

testfiles = ["test_simple.jl",
             "test_simple_tufte_extension.jl",
             "test_full.jl",
             "test_tufte.jl",
             "test_multiline.jl"]

testdir = joinpath(dirname(@__DIR__), "test")
cd(testdir) do
    @testset "tex" begin

        for testfile in testfiles
            @test try
                include(testfile)
                true
            catch err
                display(err)
                false
            end
        end
    end
end