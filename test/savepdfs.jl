testdir = joinpath(dirname(@__DIR__), "test")

# Save PDFs and SVGs (output directory => pdf/svg name)
files2save = ["output_simple"=>"default",
              "output_simple_jmlr"=>"jmlr",
              "output_simple_ieee"=>"ieee",
              "output_simple_tufte"=>"tufte",
              "output_full"=>"full",
              "output_tufte_solo"=>"tufte_solo",
              "output_nocode"=>"nocode",
              "output_pgfplots"=>"pgfplots",
              "output_pgfplots_full"=>"pgfplots_full",
              "output_random_variables"=>"random_variables",
              "output_ml"=>"ml",
             ]

cd(testdir) do
    for (folder, file) in files2save
        @info "Copying $file.pdf from $folder, converting to SVG."
        cp(joinpath(folder, file*".pdf"), joinpath("pdf", file*".pdf"); force=true)
        run(`pdf2svg $(joinpath("pdf", file*".pdf")) $(joinpath("svg", file*".svg"))`)
    end
end
