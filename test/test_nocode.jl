# Full LaTeX document written in Julia
using TeX

doc = TeXDocument("nocode")
addpackage!(doc, "lipsum")
addpackage!(doc, "pangram", "blindtext")
doc.title = T"No Code \TeX.jl Example"
doc.author = "Robert Moss"
doc.address = "Stanford University, Stanford, CA 94305"
doc.email = "mossr@cs.stanford.edu"
doc.date = T"\today"
doc.tufte = true # skips pythontex when no code is present.


@tex doc T"\section{Introduction}"

@tex doc T"""
\lipsum[2]\footnote{\blindtext[1]}

\lipsum[3]\footnote{\blindtext[3]}

\lipsum[4]
"""

texgenerate(doc; output="output_$(doc.jobname)")