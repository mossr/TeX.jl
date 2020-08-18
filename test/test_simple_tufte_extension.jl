include("test_simple.jl")

# Regenerate using the Tufte-style (and adding an author/email/address)
doc.tufte = true
doc.jobname = "tufte"
doc.title = "Tufte TeX.jl Example"
texgenerate(doc; output="output_simple_tufte")