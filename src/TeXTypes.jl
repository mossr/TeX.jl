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
	needs_section_name::Bool

	TeXSection(name = "", body = "", needs_section_name = true) = new(isempty(name) ? getrandtexname() : name, body, isempty(name) ? false : needs_section_name)
end

mutable struct TeXDocument
	jobname::String
	documentclass::String
	documentfontsizept::Integer
	packages::Array{TeXPackage}
	preamble::String
	commands::Array{TeXCommand}
	inputs::Array{TeXSection}
	build_dir::String
	title::String
	open::Bool

	TeXDocument(jobname, documentclass, documentfontsizept, packages, preamble, commands, inputs, build_dir, title, open) = new(jobname, documentclass, documentfontsizept, packages, preamble, commands, inputs, build_dir, title, open)

	function TeXDocument()
		jobname = "main"
		documentclass = "article"
		documentfontsizept = 11
		packages = TeXPackage[
			TeXPackage("english", "babel"),
			TeXPackage("usenames, dvipsnames", "xcolor"),
			TeXPackage("pdfpages"),
			TeXPackage("amsmath"),
			TeXPackage("listings"),
			TeXPackage("tikz"),
			TeXPackage("beramono"),
			TeXPackage("fontenc"),
			TeXPackage("inconsolata"),
			# TeXPackage("T1", "fontenc"), % blurs pdf2svg
		]
		preamble = read(joinpath(dirname(pathof(TeX)), "..", "include", "julia_preamble.tex"), String)
		inputs = TeXSection[]
		commands = TeXCommand[]
		build_dir = joinpath(".", "")
		title = ""
		open = true

		return TeXDocument(jobname, documentclass, documentfontsizept, packages, preamble, commands, inputs, build_dir, title, open)
	end

	function TeXDocument(jobname::String)
		tex = TeXDocument()
		tex.jobname = jobname
		return tex
	end
end

addpackage!(doc::TeXDocument, package::String) = push!(doc.packages, TeXPackage(package))
addpackage!(doc::TeXDocument, option::String, package::String) = push!(doc.packages, TeXPackage(option, package))
addpackage!(package::String) = addpackage!(WORKINGDOC, package)
addpackage!(option::String, package::String) = addpackage!(WORKINGDOC, option, package)

addtitle!(doc::TeXDocument, title::String) = doc.title=title
addtitle!(title::String) = WORKINGDOC.title=title