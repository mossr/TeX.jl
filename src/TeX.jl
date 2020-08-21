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
using Latexify

export tex,
       @tex,
       @texn,
       @texeq,
       @texeqn,
       @T_str,
       @attachfile!,
       attachfile!,
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


function textranslate!(doc::TeXDocument; use_separate_files::Bool=false, content::String="")
    if doc.tufte
        doc.documentclass = "tufte-writeup"
        documentoptions = ""
        local_preamble = ""
        length_added_pkgs = 0
    elseif doc.jmlr
        doc.documentclass = "article"
        documentoptions = "[twoside,$(doc.documentfontsizept)pt]"
        shortheading1 = doc.title
        shortheading2 = isempty(doc.author) ? doc.title : doc.author
        local_preamble = """
        \\ShortHeadings{$shortheading1}{$shortheading2}
        \\firstpageno{1}
        """
        if any([pkg.name == "attachfile" for pkg in doc.packages])
            # attachfile already loads hyperref
            addpackage!(doc, "nohyperref", "jmlr2e-writeup")
        else
            addpackage!(doc, "jmlr2e-writeup")
        end
        length_added_pkgs = 1
        if hascode(doc)
            local_preamble *= lstlisting_preamble()
            length_added_pkgs += add_lstlisting_packages!(doc)
        end
    elseif doc.ieee
        doc.documentclass = "IEEEtran"
        documentoptions = "[$(doc.ieee_options)]" # [conference] | [journal] | [technote]
        local_preamble = "\\IEEEoverridecommandlockouts"
        length_added_pkgs = 0
        if hascode(doc)
            local_preamble *= lstlisting_preamble()
            length_added_pkgs += add_lstlisting_packages!(doc)
        end
    else
        doc.documentclass = "article"
        local_preamble = lstlisting_preamble()
        length_added_pkgs = add_lstlisting_packages!(doc)
        documentoptions = "[$(doc.documentfontsizept)pt]"
    end

    local_preamble *= core_preamble()
    local_preamble *= arrows_preamble()
    local_preamble *= mathematics_preamble()

    if doc.pgfplots
        addpdfplots!(doc)
    end

    str = string("\\documentclass$documentoptions{", doc.documentclass, "}\n")

    for p in doc.packages
        op = ""
        if p.option != ""
            op = string("[", p.option, "]")
        end
        str = string(str, "\\usepackage", op, "{", p.name, "}\n")
    end

    if length_added_pkgs > 0
        # Clear added lstlisting packages
        doc.packages = doc.packages[length_added_pkgs+1:end]
    end

    # our preamble first, then yours.
    full_preamble = string(local_preamble, doc.preamble)
    if length(full_preamble) > 0
        str = string(str, full_preamble, "\n")
    end

    for c in doc.commands
        str = string(str, "\\", c.name, "{", c.value, "}\n")
    end

    if !isempty(doc.title)
        titlespace = (doc.tufte || doc.jmlr || doc.ieee) ? "" : "\\vspace{-2.0cm}"
        str = string(str, "\n\\title{$titlespace$(doc.title)}\n")
    end
    str = string(str, "\\date{$(doc.date)}\n")

    if !isempty(doc.author)
        if doc.tufte
            str = string(str, "\n\\author{\\name $(doc.author) \\email $(doc.email)\\\\\n")
            str = string(str, "        \\addr $(doc.address) \\hfill \\thedate}\n")
        elseif doc.jmlr
            str *= """
            \\makeatletter
            \\author{\\name $(doc.author) \\email $(doc.email)\\\\
                     \\addr $(doc.address) \\hfill \\@date}
            \\makeatother
            """
        elseif doc.ieee
            ieee_date = isempty(doc.date) ? "" : "\\\\ \\@date"
            str *= """
            \\makeatletter
            \\author{\\IEEEauthorblockN{$(doc.author)}\\\\
            \\IEEEauthorblockA{$(doc.address)\\\\
            $(doc.email)$ieee_date}}
            \\makeatother
            """
        else
            str = string(str, "\n\\author{$(doc.author)")
            if !isempty(doc.address)
                str = string(str, "\\\\ {\\small $(doc.address)}")
            end
            if !isempty(doc.email)
                str = string(str, "\\\\ {\\small\\texttt{$(doc.email)}}")
            end
            str = string(str, "}\n")
        end
    end


    str = string(str, "\n\\begin{document}\n")
    if !isempty(doc.title)
        str = string(str, "\\maketitle\n")
    end
    if use_separate_files
        for i in doc.inputs
            str = string(str, "\\input{", i.name, "}\n")
        end
    else
        str = string(str, content)
    end
    str = string(str, "\n\\end{document}")


    return str
end


function texwrite(doc::TeXDocument; use_separate_files::Bool=false)
    # writes each input file
    if !use_separate_files
        io = IOBuffer()
    end

    for input in doc.inputs
        if use_separate_files
            io = open(abspath(input.name * ".tex"), "w")
        end
        if input.needs_section_name && doc.auto_sections
            write(io, string("\\section{", texformat(input.name), "}\n"))
        end
        write(io, input.body)
        if !isempty(input.code)
            if doc.tufte
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
    main = open(doc.jobname * ".tex", "w")
    write(main, textranslate!(doc; use_separate_files=use_separate_files, content=content))
    close(main)
end


function texcompile(doc::TeXDocument)
    if doc.tufte
        output_directory = abspath("output")
        cmd_lualatex = ["lualatex",
               "-shell-escape",
               "--aux-directory=output", # TODO: doc.build_dir
               "--include-directory=$(joinpath(@__DIR__, "../include"))",
               "--include-directory=output", # TODO: doc.build_dir
               doc.jobname]
        @info "Running: $(`$cmd_lualatex`)"
        try
            run(`$cmd_lualatex`)
        catch err
            error("See log file for error information: $(joinpath(output_directory, doc.jobname*".log"))")
        end            

        # open compiled pdf before pdflatex
        if doc.open
            texopen(doc)
        end

        # only run `pythontex` if there's Julia code in the document
        if hascode(doc)
            cmd_pythontex = ["pythontex",
                             "output/$(doc.jobname)"]
            @info "Running: $(`$cmd_pythontex`)"
            run(`$cmd_pythontex`)

            # TODO: biber --input-directory=tex output/main

            @info "Running: $(`$cmd_lualatex`)"
            try
                run(`$cmd_lualatex`)
            catch err
                error("See log file for error information: $(joinpath(output_directory, doc.jobname*".log"))")
            end
        end
    else
        filename = doc.jobname * ".tex"
        output_directory = abspath(doc.build_dir)
        cmd = ["pdflatex", "-quiet", abspath(filename)]
        if !isempty(doc.build_dir)
            for dir in doc.pwds
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
            error("See log file for error information: $(joinpath(output_directory, doc.jobname*".log"))")
        end
    end
end


function texopen(doc::TeXDocument)
    pdf = doc.jobname * ".pdf"
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


lstlisting(code::String) = environment("algorithm", environment("lstlisting", code))
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


macro attachfile!()
    doc::TeXDocument = check_globaldoc()
    attachfile!(doc, string(__source__.file))
end


macro attachfile!(doc_sym::Symbol)
    doc::TeXDocument = @eval(__module__, $doc_sym)
    attachfile!(doc, string(__source__.file))
end


function attachfile!(doc::TeXDocument, filename="")
    if !any([pkg.name == "attachfile" for pkg in doc.packages])
        addpackage!(doc, "colorlinks=false,allbordercolors={1 1 1}", "attachfile")
    end
    if !any([pkg.name == "xcolor" for pkg in doc.packages])
        addpackage!(doc, "usenames, dvipsnames", "xcolor")
    end
    source_file = replace(filename, "\\"=>"/")
    tex(doc, "\\blfootnote{\\textattachfile{$source_file}{\\color[HTML]{19177C}Embedded Julia source file.}}")
end


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


function __tex(document::TeXDocument, code::Union{Expr, Nothing}=nothing;
              file::String="", doc_sym::Symbol=Symbol(), latex::String="",
              func_name::String="", startline::Int=0,
              _module=nothing, _source=nothing, noeval::Bool=false)
    if code !== nothing
        func_str = get_source(file, startline)

        # remove @tex macro and `doc` from same-line functions
        doc_str::String = string(doc_sym)
        if isempty(doc_str)
            r_tex_doc = Regex("@tex(eq)*(n)*\\s+")
        else
            r_tex_doc = Regex("@tex(eq)*(n)*\\s+($doc_str)\\s+")
        end
        func_str = replace(func_str, r_tex_doc=>"")

        # remove begin/end block and reindent
        if document.remove_begin
            func_str = remove_begin_block(func_str)
        end

        add!(document, latex, func_name, func_str)

        if !noeval
            return esc(code) # pass code back to scope of calling module
        end
    else
        add!(document, latex)
    end
end


function _tex(doc::TeXDocument, tex_and_or_code::Union{Expr, String};
               doc_sym::Symbol=Symbol(), _module=nothing, _source=nothing, noeval::Bool=false)
    file, source_line = get_context(_source)
    dir = dirname(file)
    if !in(dir, doc.pwds)
        # save working directory where @tex was called
        push!(doc.pwds, dir)
    end

    if isa(tex_and_or_code, String)
        # LaTeX description only.
        return __tex(doc; file=file, latex=tex_and_or_code, _module=_module, noeval=noeval)
    elseif tex_and_or_code.head == :macrocall && tex_and_or_code.args[1] in (Symbol("@T_str"), Symbol("@raw_str"))
        # LaTeX description only (using T"...")
        latex = @eval($tex_and_or_code)
        return __tex(doc; file=file, latex=latex, _module=_module, noeval=noeval)
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
            return __tex(doc, code; file=file, latex=latex, func_name=name_str, startline=startline, _module=_module, noeval=noeval)
        else
            # No function name (i.e. begin blocks, etc)
            return __tex(doc, code; file=file, latex=latex, startline=startline, _module=_module, noeval=noeval)
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

        return __tex(doc, code; file=file, doc_sym=doc_sym, func_name=name_str, startline=startline, _module=_module, noeval=noeval)
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
    return _tex(doc, tex_and_or_code; doc_sym=doc_sym, _module=__module__, _source=__source__, noeval=doc.noeval)
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
    doc::TeXDocument = check_globaldoc() # use global document
    return _tex(doc, tex_and_or_code, _module=__module__, _source=__source__, noeval=doc.noeval)
end


"""
Add Julia code to document, do not evaluate.
"""
macro texn(doc_sym::Symbol, tex_and_or_code::Union{Expr, String})
    doc::TeXDocument = @eval(__module__, $doc_sym)
    return _tex(doc, tex_and_or_code; doc_sym=doc_sym, _module=__module__, _source=__source__, noeval=true)
end
macro texn(tex_and_or_code::Union{Expr, String})
    doc::TeXDocument = check_globaldoc() # use global document
    return _tex(doc, tex_and_or_code, _module=__module__, _source=__source__, noeval=true)
end


"""
@texeq uses Latexify to format Julia expression
"""
macro texeq(code::Union{Expr, Symbol})
    doc::TeXDocument = check_globaldoc()
    texeq(doc, code, __source__; noeval=doc.noeval)
end
macro texeq(doc_sym::Symbol, code::Union{Expr, Symbol})
    doc::TeXDocument = @eval(__module__, $doc_sym)
    texeq(doc, code, __source__; noeval=doc.noeval)
end


"""
@texeqn uses Latexify to format Julia expression (without evaluating it)
"""
macro texeqn(code::Union{Expr, Symbol})
    doc::TeXDocument = check_globaldoc()
    texeq(doc, code, __source__; noeval=true)
end
macro texeqn(doc_sym::Symbol, code::Union{Expr, Symbol})
    doc::TeXDocument = @eval(__module__, $doc_sym)
    texeq(doc, code, __source__; noeval=true)
end


# Use Latexify to format Julia expression
function texeq(doc::TeXDocument, code::Union{Expr, Symbol}, _source; noeval=false)
    latex::String = latexify(code; env=:equation, cdot=false, starred=true)
    file, source_line = get_context(_source)
    __tex(doc, code; latex=latex, file=file, startline=source_line)
    noeval ? nothing : esc(code)
end


"""
`tex` function for interpolated strings.
"""
tex(doc::TeXDocument, str::String) = __tex(doc; latex=str)
tex(str::String) = __tex(check_globaldoc(); latex=str)


# Check for global document and return, or error.
function check_globaldoc()
    global WORKINGDOC
    if !@isdefined(WORKINGDOC)
        error("Please call globaldoc() before using @tex without a document parameter:\n\te.g. @tex function name(...) ... end")
    end
    return WORKINGDOC::TeXDocument
end


# Get file name and source code line from the calling file.
function get_context(_source)
    file::String = string(_source.file)
    source_line::Int = _source.line
    return file, source_line
end


# T"\blah \blah \blah un-escaped" (i.e. raw"...")
macro T_str(latex_str)
    ###################################
    # No op. Used for escaping string
    # before passing to the @tex macro
    ###################################
    return latex_str
end


end # module TeX