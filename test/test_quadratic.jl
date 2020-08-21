using TeX

doc = globaldoc("quadratic"; build_dir="output_quadratic", auto_sections=false, jmlr=true)
addpackage!(doc, "url")
doc.title = T"""
Quadratic Formula \TeX.jl Example: \texttt{@texeq}%
\thanks{Julia-to-\LaTeX~expression conversions done using
Latexify.jl: \protect\url{https://github.com/korsbo/Latexify.jl}}
"""

@tex T"""
\section{Quadratic formula and its derivation}
Completing the square can be used to derive a general formula for solving quadratic equations,
called the \textit{quadratic formula}.\footnote{\url{https://en.wikipedia.org/wiki/Quadratic_equation}}
The mathematical proof will now be briefly summarized. It can easily be seen, by polynomial expansion,
that the following equation is equivalent to the quadratic equation:
"""
# using @texeqn does not evaluate (because this is not a valid Julia assignment)
@texeqn (x + b/2a)^2 = (b^2 - 4ac) / 4a^2


@tex T"""
Taking the square root of both sides, and isolating $x = \mathrm{quad}(a,b,c)$, gives:
"""
@texeq quad(a,b,c) = (-b ± sqrt(b^2 - 4a*c)) ./ 2a


@tex T"""
\section{Examples}
Using the following definition of the plus-minus function that returns a \texttt{Tuple}
in $\R^2$, we can find the roots of a few examples.
""" ->
±(a,b) = (a+b, a-b)


@tex "\\begin{itemize}\n"
ABC = [(1, 5, -14), (1, -5, -24), (1, 3, -10)]
for (a,b,c) in ABC
    tex("\\item Let \$a=$a, b=$b, c=$c\$. The quadratic formula gives us the roots \$$(Int.(quad(a,b,c)))\$.\n")
end
@tex "\\end{itemize}"

@attachfile! # embed this source file as a footnote.

texgenerate()