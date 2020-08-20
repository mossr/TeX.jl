using Test

testfiles = ["test_simple.jl",
             "test_simple_jmlr_extension.jl",
             "test_simple_ieee_extension.jl",
             "test_simple_tufte_extension.jl",
             "test_full.jl",
             "test_tufte.jl",
             "test_multiline.jl",
             "test_stressing.jl",
             "test_nocode.jl",
             "test_pgfplots.jl",
             "test_pgfplots_full.jl",
             "test_escaping.jl",
             "test_random_variables.jl",
             "test_machine_learning.jl",
            ]

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

    @testset "save" begin
        @test try
            include("savepdfs.jl")
            true
        catch err
            display(err)
            false
        end
    end
end