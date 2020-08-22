getrandtexname() = string("tex_", lowercase(basename(tempname())))

mutable struct TeXPackage
    name::String
    option::String

    TeXPackage(option, name) = new(name, option)
    TeXPackage(name) = new(name, "")
end

mutable struct TeXCommand
    name::String
    value::String

    TeXCommand(name, value) = new(name, value)
    TeXCommand(name) = new(name, "")
end

mutable struct TeXSection
    name::String
    body::String
    code::String
    needs_section_name::Bool

    TeXSection(name="", body="", code="", needs_section_name = true) = new(isempty(name) ? getrandtexname() : name, body, code, isempty(name) ? false : needs_section_name)
end

@with_kw mutable struct TeXDocument
    jobname::String = "main"
    documentclass::String = "article"
    documentfontsizept::Integer = 11
    packages::Array{TeXPackage} = TeXPackage[TeXPackage("amsmath")]
    preamble::String = ""
    commands::Array{TeXCommand} = []
    inputs::Array{TeXSection} = []
    build_dir::String = joinpath(".", "output")
    title::String = ""
    author::String = ""
    email::String = ""
    address::String = ""
    date::String = ""
    open::Bool = true # open document after compilation
    tufte::Bool = false # use Tufte style (requires `lualatex` and `pdflatex`)
    jmlr::Bool = false # use JMLR style (http://www.jmlr.org/format)
    ieee::Bool = false # use IEEEtran style (https://ctan.org/tex-archive/macros/latex/contrib/IEEEtran/?lang=en)
    ieee_options::String = "conference" # conference, journal, or technote
    auto_sections::Bool = true # automatically create \sections using function names
    remove_begin::Bool = true # remove begin/end block (for multi-lines of non-function code)
    pgfplots::Bool = false # use PGFPlots.jl (loads preamble at compile time if true)
    pwds::Vector{String} = [] # directories that @tex were called in (to add to --include-directory)
    noeval::Bool = false # do not execute code block (for invalid syntax blocks)
    title_case_sections::Bool = true # automatically title case function names for sections
end

function TeXDocument(jobname::String; kwargs...)
    doc = TeXDocument(; kwargs...)
    doc.jobname = jobname
    return doc
end

core_preamble() = read(joinpath(dirname(pathof(TeX)), "..", "include", "preamble.tex"), String)
mathematics_preamble() = read(joinpath(dirname(pathof(TeX)), "..", "include", "mathematics.tex"), String)
lstlisting_preamble() = read(joinpath(dirname(pathof(TeX)), "..", "include", "julia_preamble.tex"), String)
tufte_preamble() = read(joinpath(dirname(pathof(TeX)), "..", "include", "julia_preamble.tex"), String)
arrows_preamble() = read(joinpath(dirname(pathof(TeX)), "..", "include", "arrows_and_braces.tex"), String)

addpackage!(doc::TeXDocument, package::TeXPackage) = push!(doc.packages, package)
addpackage!(doc::TeXDocument, package::String) = push!(doc.packages, TeXPackage(package))
addpackage!(doc::TeXDocument, option::String, package::String) = push!(doc.packages, TeXPackage(option, package))
addpackage!(package::String) = addpackage!(WORKINGDOC, package)
addpackage!(option::String, package::String) = addpackage!(WORKINGDOC, option, package)

function add_lstlisting_packages!(doc::TeXDocument)
    packages = [TeXPackage("american", "babel"),
                TeXPackage("usenames, dvipsnames", "xcolor"),
                TeXPackage("pdfpages"),
                TeXPackage("listings"),
                TeXPackage("beramono"),
                TeXPackage("fontenc"),
                TeXPackage("inconsolata"),
               ]
    map(pkg->pushfirst!(doc.packages, pkg), reverse(packages)) # prepend
    return length(packages)
end

hascode(doc::TeXDocument) = any([!isempty(input.code) for input in doc.inputs])

resetstyle!(doc::TeXDocument) = doc.tufte = doc.jmlr = doc.ieee = false

mkbuilddir(doc::TeXDocument) = isdir(doc.build_dir) ? nothing : mkdir(doc.build_dir)

addkeywords!(doc::TeXDocument, keyword::String; kwargs...) = addkeywords!(doc, [keyword]; kwargs...)
function addkeywords!(doc::TeXDocument, keywords::Vector{String}; num::Int=2)
    morekeywords = join(keywords, ",")
    doc.preamble *= """
    \\lstset{
        morekeywords=[$num]{$morekeywords}
    }
    """
end

addkeywords!(keyword::String; kwargs...) = addkeywords!(WORKINGDOC, keyword; kwargs...)
addkeywords!(keywords::Vector{String}; kwargs...) = addkeywords!(WORKINGDOC, keywords; kwargs...)