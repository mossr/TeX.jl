using TeX

doc = TeXDocument("pgfplots"; title=T"\TeX.jl Example using PGFPlots.jl")
addpdfplots!(doc)

@tex doc "The following Julia code produces the plot below." ->
begin
    using PGFPlots
    x = [1,2,3]
    y = [2,4,1]
    p = Plots.Linear(x, y)
    addplot!(doc, p)
end

texgenerate(doc; output="output_$(doc.jobname)")