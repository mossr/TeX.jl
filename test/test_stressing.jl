# Stressing cases
using TeX

doc = TeXDocument("stressing")
addpackage!(doc, "lipsum")
addpackage!(doc, "pangram", "blindtext")
# doc.tufte = true
doc.title = T"Stressing \TeX.jl Example"
doc.author = "Robert Moss"
doc.address = "Stanford University, Stanford, CA 94305"
doc.email = "mossr@cs.stanford.edu"
doc.date = T"\today"
doc.build_dir = "output_$(doc.jobname)"


@tex doc T"""
\section{Introduction}
\lipsum[2]\footnote{\blindtext[1]}

\lipsum[3]\footnote{\blindtext[3]}

\lipsum[4]
"""

@tex doc T"\lipsum[1]\footnote{\blindtext[1]}" ->
function example_function(inputs)
    # ...
end


GDOC = globaldoc()
GDOC.title = "Global Document"
GDOC.jobname = "stressing_global"
GDOC.build_dir = "output_$(doc.jobname)_global"
@tex T"Example without doc." ->
function example_no_doc(inputs)
    # ...
end


@tex doc F(inputs) = missing


# globaldoc()
@tex G(inputs) = nothing


@tex doc function example_no_latex_inline(inputs)
    # ...
end


texgenerate(doc)

texgenerate()