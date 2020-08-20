# Full LaTeX document written in Julia
using TeX

doc = TeXDocument("nocode"; jmlr=true)
addpackage!(doc, "lipsum")
addpackage!(doc, "american", "babel")
addpackage!(doc, "pangram", "blindtext")
doc.title = T"No Code \TeX.jl Example"
doc.author = "Robert Moss"
doc.address = "Stanford University, Stanford, CA 94305"
doc.email = "mossr@cs.stanford.edu"
doc.date = T"\today"
doc.build_dir = "output_$(doc.jobname)"


@tex doc T"""
\begin{abstract}
\lipsum[1]
\end{abstract}
"""

@tex doc T"""
\section{Introduction}
\lipsum[2]\footnote{\blindtext[1]}

\lipsum[3]\footnote{\blindtext[3]}

\lipsum[4]
"""

@tex doc T"""
\section{Approach}
\lipsum[5-7]
"""

@tex doc T"""
\section{Conclusion}
\lipsum[8-9]
"""

texgenerate(doc)