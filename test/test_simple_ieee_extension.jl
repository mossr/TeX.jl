include("test_simple.jl")

# Regenerate using the IEEETran-style
resetstyle!(doc)
doc.ieee = true
doc.jobname = "ieee"
doc.title = T"IEEE \TeX.jl Example"
doc.build_dir = "output_simple_ieee"
texgenerate(doc)