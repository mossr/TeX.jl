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
    preamble::String = lstlisting_preamble()
    commands::Array{TeXCommand} = []
    inputs::Array{TeXSection} = []
    build_dir::String = joinpath(".", "")
    title::String = ""
    author::String = ""
    email::String = ""
    address::String = ""
    date::String = ""
    open::Bool = true # open document after compilation
    tufte::Bool = false # use Tufte style (requires `lualatex` and `pdflatex`)

end
function TeXDocument(jobname::String; kwargs...)
    tex = TeXDocument(; kwargs...)
    tex.jobname = jobname
    return tex
end

lstlisting_preamble() = read(joinpath(dirname(pathof(TeX)), "..", "include", "julia_preamble.tex"), String)
tufte_preamble() = read(joinpath(dirname(pathof(TeX)), "..", "include", "julia_preamble.tex"), String)

addpackage!(doc::TeXDocument, package::TeXPackage) = push!(doc.packages, package)
addpackage!(doc::TeXDocument, package::String) = push!(doc.packages, TeXPackage(package))
addpackage!(doc::TeXDocument, option::String, package::String) = push!(doc.packages, TeXPackage(option, package))
addpackage!(package::String) = addpackage!(WORKINGDOC, package)
addpackage!(option::String, package::String) = addpackage!(WORKINGDOC, option, package)

function add_lstlisting_packages!(doc::TeXDocument)
    packages = [TeXPackage("usenames, dvipsnames", "xcolor"),
                TeXPackage("pdfpages"),
                TeXPackage("listings"),
                TeXPackage("beramono"),
                TeXPackage("fontenc"),
                TeXPackage("inconsolata"),
               ]
    map(pkg->addpackage!(doc, pkg), packages)
    return length(packages)
end