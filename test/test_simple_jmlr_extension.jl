include("test_simple.jl")

# Regenerate using the JMLR-style
resetstyle!(doc)
doc.jmlr = true
doc.jobname = "jmlr"
doc.title = T"JMLR \TeX.jl Example"
doc.build_dir = "output_simple_jmlr"
texgenerate(doc)