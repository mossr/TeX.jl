include("test_simple.jl")

# Regenerate using the Tufte-style
resetstyle!(doc)
doc.tufte = true
doc.jobname = "tufte"
doc.title = T"Tufte \TeX.jl Example"
doc.build_dir = "output_simple_tufte"
texgenerate(doc)