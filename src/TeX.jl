"""
@tex T"\\LaTeX{} code goes here" ->
function algorithm(args)
    # Julia code here
end

A macro to write LaTeX formatted code in-line with your Julia algorithms.
The tex document will be named after the function (example "algorithm.tex")
"""
module TeX

using Parameters
using MacroTools
using PGFPlots

export @tex,
       @T_str,
       TeXDocument,
       TeXSection,
       texgenerate,
       globaldoc,
       add!,
       addpackage!,
       addplot!,
       resetstyle!,
       addkeywords!

include("TeXTypes.jl")
include("sugar.jl")
include("pgfplots.jl")


global USE_GLOBAL_DOC = false
"""
Compile all descriptions and code in the same document.
"""
function globaldoc(jobname::String="main"; kwargs...)
    global USE_GLOBAL_DOC = true
    global WORKINGDOC = TeXDocument(jobname; kwargs...)
    return WORKINGDOC::TeXDocument
end


function textranslate!(tex::TeXDocument; use_separate_files::Bool=false, content::String="")
    if tex.tufte
        tex.documentclass = "tufte-writeup"
        documentoptions = ""
        local_preamble = ""
        length_added_pkgs = 0
    elseif tex.jmlr
        tex.documentclass = "article"
        documentoptions = "[twoside,$(tex.documentfontsizept)pt]"
        local_preamble = """
        \\ShortHeadings{$(tex.title)}{$(tex.author)}
        \\firstpageno{1}
        """
        addpackage!(tex, "jmlr2e-writeup")
        length_added_pkgs = 1
        if hascode(tex)
            local_preamble *= lstlisting_preamble()
            length_added_pkgs += add_lstlisting_packages!(tex)
        end
    elseif tex.ieee
        tex.documentclass = "IEEEtran"
        documentoptions = "[$(tex.ieee_options)]" # [conference] | [journal] | [technote]
        local_preamble = "\\IEEEoverridecommandlockouts"
        length_added_pkgs = 0
        if hascode(tex)
            local_preamble *= lstlisting_preamble()
            length_added_pkgs += add_lstlisting_packages!(tex)
        end
    else
        tex.documentclass = "article"
        local_preamble = lstlisting_preamble()
        length_added_pkgs = add_lstlisting_packages!(tex)
        documentoptions = "[$(tex.documentfontsizept)pt]"
    end

    if tex.pgfplots
        addpdfplots!(tex)
    end

    str = string("\\documentclass$documentoptions{", tex.documentclass, "}\n")

    for p in tex.packages
        op = ""
        if p.option != ""
            op = string("[", p.option, "]")
        end
        str = string(str, "\\usepackage", op, "{", p.name, "}\n")
    end

    if length_added_pkgs > 0
        # Clear added lstlisting packages
        tex.packages = tex.packages[length_added_pkgs+1:end]
    end

    # our preamble first, then yours.
    full_preamble = string(local_preamble, tex.preamble)
    if length(full_preamble) > 0
        str = string(str, full_preamble, "\n")
    end

    for c in tex.commands
        str = string(str, "\\", c.name, "{", c.value, "}\n")
    end

    if !isempty(tex.title)
        titlespace = (tex.tufte || tex.jmlr || tex.ieee) ? "" : "\\vspace{-2.0cm}"
        str = string(str, "\n\\title{$titlespace$(tex.title)}\n")
    end
    str = string(str, "\\date{$(tex.date)}\n")

    if !isempty(tex.author)
        if tex.tufte
            str = string(str, "\n\\author{\\name $(tex.author) \\email $(tex.email)\\\\\n")
            str = string(str, "        \\addr $(tex.address) \\hfill \\thedate}\n")
        elseif tex.jmlr
            str *= """
            \\makeatletter
            \\author{\\name $(tex.author) \\email $(tex.email)\\\\
                     \\addr $(tex.address) \\hfill \\@date}
            \\makeatother
            """
        elseif tex.ieee
            ieee_date = isempty(tex.date) ? "" : "\\\\ \\@date"
            str *= """
            \\makeatletter
            \\author{\\IEEEauthorblockN{$(tex.author)}\\\\
            \\IEEEauthorblockA{$(tex.address)\\\\
            $(tex.email)$ieee_date}}
            \\makeatother
            """
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
    if use_separate_files
        for i in tex.inputs
            str = string(str, "\\input{", i.name, "}\n")
        end
    else
        str = string(str, content)
    end
    str = string(str, "\\end{document}")


    return str
end


function texwrite(tex::TeXDocument; use_separate_files::Bool=false)
    # writes each input file
    if !use_separate_files
        io = IOBuffer()
    end

    for input in tex.inputs
        if use_separate_files
            io = open(abspath(input.name * ".tex"), "w")
        end
        if input.needs_section_name && tex.auto_sections
            write(io, string("\\section{", texformat(input.name), "}\n"))
        end
        write(io, input.body)
        if !isempty(input.code)
            if tex.tufte
                write(io, juliaverbatim(input.code))
            else
                write(io, lstlisting(input.code))
            end
        end
        if use_separate_files
            close(io)
        end
    end

    if use_separate_files
        content = ""
    else
        content = String(take!(io))
    end

    # writes the main document
    main = open(tex.jobname * ".tex", "w")
    write(main, textranslate!(tex; use_separate_files=use_separate_files, content=content))
    close(main)
end


function texcompile(tex::TeXDocument)
    if tex.tufte
        output_directory = abspath("output")
        cmd_lualatex = ["lualatex",
               "-shell-escape",
               "--aux-directory=output", # TODO: tex.build_dir
               "--include-directory=$(joinpath(@__DIR__, "../include"))",
               "--include-directory=output", # TODO: tex.build_dir
               tex.jobname]
        @info "Running: $(`$cmd_lualatex`)"
        try
            run(`$cmd_lualatex`)
        catch err
            error("See log file for error information: $(joinpath(output_directory, tex.jobname*".log"))")
        end            

        # open compiled pdf before pdflatex
        if tex.open
            texopen(tex)
        end

        # only run `pythontex` if there's Julia code in the document
        if hascode(tex)
            cmd_pythontex = ["pythontex",
                             "output/$(tex.jobname)"]
            @info "Running: $(`$cmd_pythontex`)"
            run(`$cmd_pythontex`)

            # TODO: biber --input-directory=tex output/main

            @info "Running: $(`$cmd_lualatex`)"
            try
                run(`$cmd_lualatex`)
            catch err
                error("See log file for error information: $(joinpath(output_directory, tex.jobname*".log"))")
            end
        end
    else
        filename = tex.jobname * ".tex"
        # output_directory = abspath(tex.build_dir)
        cmd = ["pdflatex", "-quiet", abspath(filename)]
        if !isempty(tex.build_dir)
            for dir in tex.pwds
                # add all directories where @tex was called in
                push!(cmd, string("-include-directory=", dir))
            end
            # push!(cmd, string("-aux-directory=", output_directory))
            # push!(cmd, string("-output-directory=", output_directory))
            include_dir = joinpath(dirname(pathof(TeX)), "..", "include")
            include_dirs = [dirname(abspath(filename)), include_dir]
            map(d->push!(cmd,"-include-directory=$d"), include_dirs)
        end
        @info "Running: $(`$cmd`)"
        try
            run(`$cmd`)
        catch err
            error("See log file for error information: $(joinpath(output_directory, tex.jobname*".log"))")
        end
    end
end


function texopen(tex::TeXDocument)
    pdf = tex.jobname * ".pdf"
    try
        run(`explorer $pdf`)
    catch e
    end
end


function texgenerate(document::TeXDocument)
    # isdir(output) ? nothing : mkdir(output) # TODO. document.build_dir
    mkbuilddir(document)
    cd(document.build_dir) do
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


function environment(envname::String, code::String; options::String="")
    isempty(options) ? nothing : options="[$options]"
    str = """
    \\begin{$envname}$options
    $code
    \\end{$envname}
    """
end


lstlisting(code::String) = environment("lstlisting", code)
juliaverbatim(code::String) = environment("algorithm", environment("juliaverbatim", code))


function add!(document::TeXDocument, latex_str::String, name_str::String = "", func_str::String = "")
    input = TeXSection(name_str)
    input.body = latex_str
    if !isempty(func_str)
        input.code = func_str
    end
    push!(document.inputs, input)
end

add!(document::TeXDocument, input::TeXSection) = push!(document.inputs, input)



function find_first_line(code::Union{Expr, LineNumberNode})
    if isa(code, LineNumberNode)
        return code.line
    end
    local lnn = missing
    for arg in code.args
        if !isa(arg, Symbol)
            lnn = find_first_line(arg)
            if lnn !== missing
                break
            end
        end
    end
    return lnn
end


function remove_begin_block(func_str::String)
    if match(r"^begin", func_str) !== nothing
        r_begin = r"^begin\n(.*)\n^end"ms
        m_begin = match(r_begin, func_str)
        if m_begin !== nothing
            # remove begin/end
            func_str = string(m_begin.captures[1])
            r_first_indent = r"^(\s+)"
            m_first_indent = match(r_first_indent, func_str)

            # if there are indents, remove one set of them
            if m_first_indent !== nothing
                if m_first_indent.captures[1] == "\t"
                    # using tabs.
                    r_indent = Regex("^\t")
                else
                    # using spaces.
                    num_spaces = length(m_first_indent.captures[1])
                    r_indent = Regex("^ {$num_spaces,$num_spaces}")
                end
                lines = split(func_str, '\n')
                unindented_lines = map(line->replace(line, r_indent=>""), lines)
                func_str = join(unindented_lines, '\n')
            end
        end
    end
    return func_str::String
end


function _tex(document::TeXDocument, code::Union{Expr, Nothing};
              file::String="", doc_sym::Symbol=Symbol(), latex::String="",
              func_name::String="", startline::Int=0, tmodule=nothing)
    if code !== nothing
        func_str = get_source(file, startline)

        # remove @tex macro and `doc` from same-line functions
        doc_str::String = string(doc_sym)
        if isempty(doc_str)
            r_tex_doc = Regex("@tex\\s+")
        else
            r_tex_doc = Regex("@tex\\s+($doc_str)\\s+")
        end
        func_str = replace(func_str, r_tex_doc=>"")

        # remove begin/end block and reindent
        if document.remove_begin
            func_str = remove_begin_block(func_str)
        end

        add!(document, latex, func_name, func_str)

        if !document.noeval
            return esc(code) # pass code back to scope of calling module
        end
        # mkbuilddir(document)
        # cd(document.build_dir) do # in case function calls write out files (e.g., PGFPlots.Image)
            # @eval(tmodule, $code) # eval code in the current module
        # end
    else
        add!(document, latex)
    end
end


function __tex(doc::TeXDocument, tex_and_or_code::Union{Expr, String}, file::String, source_line::Int; doc_sym::Symbol=Symbol(), tmodule=nothing)
    dir = dirname(file)
    if !in(dir, doc.pwds)
        # save working directory where @tex was called
        push!(doc.pwds, dir)
    end

    if isa(tex_and_or_code, String)
        # LaTeX description only.
        return _tex(doc, nothing; file=file, latex=tex_and_or_code, tmodule=tmodule)
    elseif tex_and_or_code.head == :macrocall && tex_and_or_code.args[1] == Symbol("@T_str")
        # LaTeX description only (using T"...")
        latex = @eval($tex_and_or_code)
        return _tex(doc, nothing; file=file, latex=latex, tmodule=tmodule)
    elseif tex_and_or_code.head == :(->)
        # Includes LaTeX descriptions.
        desc_block = tex_and_or_code.args[1]
        if isa(desc_block, Expr)
            # Used T"..."
            latex::String = @eval($desc_block)
        else
            # Passed in as a String
            latex = desc_block
        end

        code::Expr = tex_and_or_code.args[2]
        
        startline::Int = find_first_line(code) + 1

        func::Expr = code.args[end]
        has_function_name::Bool = func.head != :call
        if has_function_name
            # Use the function name as the section name
            name_str::String = string(func.args[1].args[1])
            return _tex(doc, code; file=file, latex=latex, func_name=name_str, startline=startline, tmodule=tmodule)
        else
            # No function name (i.e. begin blocks, etc)
            return _tex(doc, code; file=file, latex=latex, startline=startline, tmodule=tmodule)
        end
    else
        # Does not include a latex description (i.e. code only)
        if isa(tex_and_or_code.args[1], LineNumberNode)
            name_str = ""
        else
            name_sym = tex_and_or_code.args[1].args[1]
            name_str = string(name_sym)
        end

        code = tex_and_or_code
        startline = source_line

        return _tex(doc, code; file=file, doc_sym=doc_sym, func_name=name_str, startline=startline, tmodule=tmodule)
    end
end


"""
Examples:

@tex doc function name(inputs)
    ...
end


@tex doc T"LaTeX formatted string" ->
function name(inputs)
    ...
end


@tex doc T"Just LaTeX strings and no Julia code"


@tex doc "Just strings with manual escaping"
"""
macro tex(doc_sym::Symbol, tex_and_or_code::Union{Expr, String})
    doc::TeXDocument = @eval(__module__, $doc_sym)
    file::String = string(__source__.file)
    source_line::Int = __source__.line
    return __tex(doc, tex_and_or_code, file, source_line; doc_sym=doc_sym, tmodule=__module__)
end


"""
Examples (global document):

@tex function name(inputs)
    ...
end

@tex T"LaTeX formatted strings and no Julia code"

@tex "Strings with manual escaping and no Julia code"
"""
macro tex(tex_and_or_code::Union{Expr, String})
    # use global document
    global WORKINGDOC
    if !@isdefined(WORKINGDOC)
        error("Please call globaldoc() before using @tex without a document parameter:\n\te.g. @tex function name(...) ... end")
    end
    doc::TeXDocument = WORKINGDOC
    file::String = string(__source__.file)
    source_line::Int = __source__.line
    return __tex(doc, tex_and_or_code, file, source_line, tmodule=__module__)
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