using TeX
using Latexify # https://github.com/mossr/Latexify.jl (forked from korsbo)

doc = globaldoc("latexify_cases"; build_dir="output_latexify_cases", jmlr=true)
doc.title = T"\vspace{-2cm}Testing Latexify.jl cases, and/or, negation\vspace{-1cm}"
doc.documentfontsizept=10


@tex T"\section{Cases}"

# expr = :(R(p,e,d) = e ? 0 : log(p) - d)
# latex = String(latexify(expr; env=:equation, starred=false, cdot=false))
# tex(doc, latex)

@texeq function R(p,e,d) # standard: with explicit return
    if e
        return 0
    else
        return log(p) - d
    end
end

@texeq function R(p,e,d) # without explicit `return`
    if e
        0
    else
        log(p) - d
    end
end

@texeq function R(p,e,d) # without else
    if 2d != 10
        0
    end
end

@texeq function R(p,e,d) # without else, but with elseif
    if sqrt(d) < 777
        0
    elseif e || !t
        999
    end
end


@tex T"\subsection{Ternary Ifs}"

@texeq R(p,e,d) = e ? 0 : log(p) - d

@texeq R(p,e,d,t) = e || t ? 0 : log(p) - d

@texeq R(p,e,d,t) = (t && e) ? 0 : ((t && !e) ? -d : log(p)) # nested (same result w/out parens)

@texeq R(p,e,d,t) = if (t && e); 0 elseif (t && !e); -d else log(p) end # one-line conditional


@tex T"\subsection{Larger Cases}"

@texeq function R(p,e,d,t) # lots of elseifs
    if t && e 
        return 0
    elseif t && !e
        return -d
    elseif 2t && e
        return -2d
    elseif 3t && e
        return -3d
    else
        return log(p)
    end
end

@texeq function R(p,e,d,t) # lots of elseifs (with some nesting)
    if t && e 
        return 0
    elseif t && !e
        return -d
    elseif 2t && e
        if t == 10
            return -10d
        else
            return -2d
        end
    elseif 3t && e
        return -3d
    else
        return log(p)
    end
end

@texeq function reward(s, a, sp, o) # note \mathrm for function names longer than one character
    if a == 1
        return -1.0
    elseif s == a
        return -100.0
    else
        return 10.0
    end
end

# TODO: mathrm for inputs / variables longer than 1 character (just like function naming)

@attachfile!

texgenerate()