using TeX

globaldoc("escaping"; title="Escaping Example")
@tex """
You don't have to use \\texttt{T"..."}, but need to manually escape \\verb+'\\'+ and \\verb+'\$'+.

\\begin{equation}
\\sum_{i=1}^n i = \\frac{n(n+1)}{2} \\tag{arithmetic series}
\\end{equation}
"""

texgenerate(output="output_escaping")