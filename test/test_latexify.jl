using TeX
using Latexify
using Random
Random.seed!(0)

doc = globaldoc("latexify"; build_dir="output_latexify", jmlr=true)
doc.documentfontsizept=10

p = [1,2,3,4,5]
A = rand(UInt8, 3,3)


tex("""
\\section{Vectors}
Here is some text before: $(11p). Then some text after.
""")

@tex T"\section{Matrices}"

tex(string("Here is some text before: ", latexify(A; starred=true)))


@tex T"\section{Expressions}"

@texeq f(x) = (2x^2 + 4x) / log(x^3)


@tex T"\subsection{Cases}"

@texeq R(p,e,d) = e ? 0 : log(p) - d

@texeq function R(p,e,d)
    if e
        return 0
    else
        return log(p) - d
    end
end


texgenerate()