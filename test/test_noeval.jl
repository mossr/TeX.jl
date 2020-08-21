using TeX

doc = globaldoc("noeval"; build_dir="output_noeval", auto_sections=false, jmlr=true)
doc.title = T"Skip Evaluation \TeX.jl Example"

# Still does surface level syntax parsing
# https://docs.julialang.org/en/v1/devdocs/ast/
@texn (x + b/2a)^2 = (b^2 - 4ac) / 4a^2

texgenerate()