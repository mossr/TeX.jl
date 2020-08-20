using TeX

doc = globaldoc("escaping"; title="Escaping Example")
doc.build_dir = "output_escaping"
@tex """
You don't have to use \\texttt{T"..."}, but need to manually escape \\verb+'\\'+ and \\verb+'\$'+.

\\begin{equation}
\\sum_{i=1}^n i = \\frac{n(n+1)}{2} \\tag{arithmetic series}
\\end{equation}
"""

texgenerate()