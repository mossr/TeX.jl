"""
@tex "\\LaTeX{} code goes here" ->
function algorithm(args)
    # Julia code here
end

A macro to write LaTeX formatted code in-line with your Julia algorithms.
The tex document will be named after the function (example "algorithm.tex")
"""
module TeX

using Parameters
using MacroTools

export @tex,
       @T_str,
       TeXDocument,
       TeXSection,
       texgenerate,
       globaldoc,
       add!,
       addpackage!

include("TeXTypes.jl")
include("sugar.jl")

global USE_GLOBAL_DOC = false
"""
Compile all descriptions and code in the same document.
"""
function globaldoc()
    global USE_GLOBAL_DOC = true
    global WORKINGDOC = TeXDocument()
    return WORKINGDOC::TeXDocument
end


function textranslate!(tex::TeXDocument)
    if tex.tufte
        tex.documentclass = "tufte-writeup"
        tex.preamble = ""
    else
        tex.documentclass = "article"
        tex.preamble = lstlisting_preamble()
        length_added_pkgs = add_lstlisting_packages!(tex)
    end
    str = string("\\documentclass[", tex.documentfontsizept, "pt]{", tex.documentclass, "}\n")
    for p in tex.packages
        op = ""
        if p.option != ""
            op = string("[", p.option, "]")
        end
        str = string(str, "\\usepackage", op, "{", p.name, "}\n")
    end

    if !tex.tufte
        # Clear added lstlisting packages
        tex.packages = tex.packages[1:end-length_added_pkgs]
    end

    if length(tex.preamble) > 0
        str = string(str, tex.preamble, "\n")
    end

    for c in tex.commands
        str = string(str, "\\", c.name, "{", c.value, "}\n")
    end

    if !isempty(tex.title)
        titlespace = tex.tufte ? "" : "\\vspace{-2.0cm}"
        str = string(str, "\n\\title{$titlespace$(tex.title)}\n")
    end
    str = string(str, "\\date{$(tex.date)}\n")

    if !isempty(tex.author)
        if tex.tufte
            str = string(str, "\n\\author{\\name $(tex.author) \\email $(tex.email)\\\\\n")
            str = string(str, "        \\addr $(tex.address) \\hfill \\thedate}\n")
        else
            str = string(str, "\n\\author{$(tex.author)")
            if !isempty(tex.address)
                str = string(str, "\\\\ {\\small $(tex.address)}")
            end
            if !isempty(tex.email)
                str = string(str, "\\\\ {\\small\\texttt{$(tex.email)}}")
            end
            str = string(str, "}\n")
        end
    end


    str = string(str, "\n\\begin{document}\n")
    if !isempty(tex.title)
        str = string(str, "\\maketitle\n")
    end
    for i in tex.inputs
        str = string(str, "\\input{", i.name, "}\n")
    end
    str = string(str, "\\end{document}")


    return str
end

function texwrite(tex::TeXDocument)
    # writes each input file
    for input in tex.inputs
        file = open(abspath(joinpath(tex.build_dir, input.name * ".tex")), "w")
        if input.needs_section_name
            write(file, string("\\section{", texformat(input.name), "}\n"))
        end
        write(file, input.body)
        if !isempty(input.code)
            if tex.tufte
                write(file, juliaverbatim(input.code))
            else
                write(file, lstlisting(input.code))
            end
        end
        close(file)
    end

    # writes the main document
    main = open(tex.jobname * ".tex", "w")
    write(main, textranslate!(tex))
    close(main)
end

function texcompile(tex::TeXDocument)
    if tex.tufte
        cmd_lualatex = ["lualatex",
               "-shell-escape",
               "--aux-directory=output", # TODO: tex.build_dir
               "--include-directory=$(joinpath(@__DIR__, "../include"))",
               "--include-directory=output", # TODO: tex.build_dir
               tex.jobname]
        @info "Running: $(`$cmd_lualatex`)"
        run(`$cmd_lualatex`)

        # open compiled pdf before pdflatex
        if tex.open
            texopen(tex)
        end

        cmd_pythontex = ["pythontex",
                         "output/$(tex.jobname)"]
        @info "Running: $(`$cmd_pythontex`)"
        run(`$cmd_pythontex`)

        # TODO: biber --input-directory=tex output/main

        @info "Running: $(`$cmd_lualatex`)"
        run(`$cmd_lualatex`)
    else
        filename = tex.jobname * ".tex"
        cmd = ["pdflatex", "-quiet", abspath(filename)]
        if tex.build_dir != ""
            push!(cmd, string("-aux-directory=", abspath(tex.build_dir)))
            push!(cmd, string("-output-directory=", abspath(tex.build_dir)))
            include_dir = joinpath(dirname(pathof(TeX)), "include")
            include_dirs = [dirname(abspath(filename)), include_dir]
            map(d->push!(cmd,"-include-directory=$d"), include_dirs)
        end
        @info "Running: $(`$cmd`)"
        run(`$cmd`)
    end
end

function texopen(tex::TeXDocument)
    pdf = tex.jobname * ".pdf"
    try
        run(`explorer $pdf`)
    catch e
    end
end

const TeXSections = Array{TeXSection}

function texgenerate(document::TeXDocument; output="output")
    isdir(output) ? nothing : mkdir(output) # TODO. document.build_dir
    cd(output) do
        # writes the LaTeX string and function code to a .tex file
        texwrite(document)

        # compiles the latex document
        texcompile(document)

        # open compiled pdf
        if document.open
            texopen(document)
        end
    end
end


function texgenerate(;kwargs...)
    if USE_GLOBAL_DOC
        document = WORKINGDOC
    else
        error("texgenerate requires either a TeXDocument input or usage of globaldoc()")
    end
    return texgenerate(document; kwargs...)
end

# Specify main TeX filename
function texgenerate(jobname::String; kwargs...)
    if USE_GLOBAL_DOC
        document = WORKINGDOC
    else
        error("texgenerate requires either a TeXDocument input or usage of globaldoc()")
    end
    document.jobname = jobname
    texgenerate(document; kwargs...)
end



function texformat(str::String; replace_with_spaces::Bool=true, use_title_case::Bool=true)
    if replace_with_spaces
        str = replace(str, "_" => " ")
        if use_title_case
            str = titlecase(str)
        end
    else
        str = replace(str, "_" => "\\_")
    end
    return str
end

# TODO: environment function.
function lstlisting(code::String)
    str = "\n\\begin{lstlisting}\n"
    str *= code
    str *= "\n\\end{lstlisting}\n"
end

function juliaverbatim(code::String)
    str = "\n\\begin{algorithm}\n"
    str *= "\n\\begin{juliaverbatim}\n"
    str *= code # TODO: Strip left space
    str *= "\n\\end{juliaverbatim}\n"
    str *= "\n\\end{algorithm}\n"
end

function parse_latex(idx, args...)
    local accompanying_func::Bool

    if isa(args[idx].args[1], Symbol)
        expr = args[idx]
        accompanying_func = false
    else
        expr = args[idx].args[1]
        accompanying_func = true
    end
    latex = expr.args[3] # [@T_str, "#= comment node =#", "Auto-escaped LaTeX string"]

    return (latex, accompanying_func)
end


function add!(document::TeXDocument, latex_str::String, name_str::String = "", func_str::String = "")
    input = TeXSection(name_str)
    input.body = latex_str
    if !isempty(func_str)
        input.code = func_str
    end
    push!(document.inputs, input)
end

function add!(document::TeXDocument, input::TeXSection)
    push!(document.inputs, input)
end

function _tex(tmodule, args...)
    global USE_GLOBAL_DOC

    if !isa(args[1], Symbol) # i.e. doc wasn't passed in, USE_GLOBAL_DOC
        global WORKINGDOC
        # uses existing working document (global)
        doc_idx = 0
        document = WORKINGDOC
        parse_idx = 1
    else
        # use TeXDocument passed in as input: @tex doc T"..."
        doc_idx = 1
        document = @eval(tmodule, $(args[doc_idx]))
        parse_idx = 2
    end

    desc_idx = doc_idx+1
    # grabs the latex string
    (latex, accompanying_func::Bool) = parse_latex(parse_idx, args...)

    if accompanying_func
        expr = args[desc_idx].args

        func = expr[2].args[2]

        is_func_block::Bool = isa(func, Expr)
        if is_func_block
            # grabs the function name
            name_sym = func.args[1].args[1]
            name_str = string(name_sym)
        else
            name_str = ""

            # grab code block that's not necessarily a function
            func = expr[2]
        end

        firstline::LineNumberNode = args[desc_idx].args[2].args[1]
        file::Symbol = firstline.file
        startline::Int = firstline.line + 1

        func_str = get_source(file, startline)

        add!(document, latex, name_str, func_str)

        return esc(func) # pass code back to scope of calling module
    else
        add!(document, latex)
    end
end

# T"..." formatted LaTeX string with accompanying function
# @tex T"\LaTeX un-escaped formatted string" -> function name(...) ... end
macro tex(args...)
    _tex(__module__, args...)
end

# T"\blah \blah \blah un-escaped"
macro T_str(latex_str)
    ########################################
    # No op. Used for escaping string before
    # passing to the @tex macro
    ########################################
    return latex_str
end

end # module TeX