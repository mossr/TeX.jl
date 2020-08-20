using Revise
using TeX
using ColorSchemes
using Random
Random.seed!(2)

doc = globaldoc("pgfplots_full"; title=T"More \TeX.jl Examples using PGFPlots.jl")
addpackage!(doc, "url")
doc.pgfplots = true
doc.ieee = true
doc.ieee_options = "technote"
doc.build_dir = "output_$(doc.jobname)"

@tex """
\\begin{abstract}
Additional examples using PGFPlots.jl based on the documentation: \\url{https://nbviewer.jupyter.org/github/JuliaTeX/PGFPlots.jl/blob/master/doc/PGFPlots.ipynb}
\\end{abstract}
"""

@tex """
\\section{Linear}
The following Julia code produces the plot below.
""" ->
begin
    using PGFPlots
    x = [1,2,3]
    y = [2,4,1]
    p = Plots.Linear(x, y)
    addplot!(doc, p)
end


@tex """
\\section{Histograms}
Histograms using normally distributed data from \$\\mathcal{N}(0, 1)\$.
""" ->
begin
    d = randn(100)
    a = Axis(Plots.Histogram(d, bins=10), ymin=0)
    addplot!(doc, a)
end


@tex """
\\newpage
\\section{Images}
Image plots create a PNG bitmap and are useful for visualizing 2D functions.
""" ->
begin
    using ColorSchemes
    vir = ColorMaps.RGBArrayMap(ColorSchemes.viridis,
                                interpolation_levels=500,
                                invert=true)
    f = (x,y)->x*exp(-x^2-y^2)
    img = Plots.Image(f, (-2,2), (-2,2), colormap=vir)
    addplot!(doc, img)
end


@tex """
\\section{Smith Charts}
These are often used in radio-frequency engineering.
""" ->
begin
    sa = SmithAxis([
            PGFPlots.SmithCircle(1, 1, 2, style="blue"),
            PGFPlots.SmithCircle(0.5, -1, 1, style="red")])
    addplot!(doc, sa)
end

texgenerate()